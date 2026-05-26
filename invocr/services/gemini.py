import json
import base64

from google import genai
from google.genai import types

from invocr.core.config import settings
from invocr.models.invoice import Address, InvoiceData, LineItem, Party
from invocr.services.improvements import load_improvements

_SYSTEM_PROMPT = """You are an invoice data extraction specialist.
You receive an invoice image or PDF. Your tasks:
1. Perform OCR to read all text from the document.
2. Extract and normalize all invoice fields (dates to ISO 8601, amounts to float, currency to ISO 4217).
3. Translate any non-English text to English for field values.
4. Infer missing fields where possible from context.
5. Return ONLY a valid JSON object matching the schema below. No markdown, no explanation.

Schema:
{
  "invoice_number": string | null,
  "invoice_date": "YYYY-MM-DD" | null,
  "due_date": "YYYY-MM-DD" | null,
  "currency": "ISO-4217 code",
  "tax_currency_code": "ISO-4217 code" | null,
  "tax_exchange_rate": float | null,
  "total": float | null,
  "subtotal": float | null,
  "tax_amount": float | null,
  "tax_rate": float | null,
  "payment_terms": string | null,
  "purchase_order_number": string | null,
  "note": string | null,
  "supplier": {
    "name": string | null,
    "registration_name": string | null,
    "tax_id": string | null,
    "endpoint_id": string | null,
    "endpoint_scheme": string | null,
    "email": string | null,
    "address": { "street": string|null, "city": string|null, "state": string|null, "postal_code": string|null, "country": string|null }
  },
  "customer": {
    "name": string | null,
    "registration_name": string | null,
    "tax_id": string | null,
    "endpoint_id": string | null,
    "endpoint_scheme": string | null,
    "email": string | null,
    "address": { "street": string|null, "city": string|null, "state": string|null, "postal_code": string|null, "country": string|null }
  },
  "line_items": [
    {
      "description": string | null,
      "quantity": float | null,
      "unit_price": float | null,
      "unit_code": string | null,
      "total": float | null,
      "tax_rate": float | null
    }
  ]
}"""


_EXTENSION_PROMPT = """You are a UBL 2.1 XML extension specialist.

You will receive:
1. CORE DATA: The invoice data already extracted as JSON (covering the standard fields)
2. IMPROVEMENT NOTES: Rules from past human corrections about additional UBL elements to include

Your task:
- Generate ONLY the additional UBL 2.1 XML elements that are NOT already covered by the core data fields
- Return a single XML fragment with no XML declaration and no root Invoice element
- Include proper UBL namespace declarations on each top-level element you add
- The fragment will be merged into an existing UBL Invoice document
- If no extra elements are needed, return an empty string

UBL namespaces to use:
  xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
  xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"

Do NOT duplicate elements already present from the core data (ID, IssueDate, DocumentCurrencyCode,
AccountingSupplierParty, AccountingCustomerParty, TaxTotal, LegalMonetaryTotal, InvoiceLine, etc.)
Return ONLY raw XML, no markdown fences, no explanation."""


class GeminiService:
    def __init__(self):
        self.client = genai.Client(
            api_key=settings.gemini_api_key,
            http_options=types.HttpOptions(api_version="v1beta"),
        )

    async def extract_invoice(self, file_bytes: bytes, mime_type: str) -> tuple[InvoiceData, str | None]:
        improvements = load_improvements()
        system_prompt = _SYSTEM_PROMPT
        if improvements:
            system_prompt += f"\n\n## Improvement notes from past human corrections (apply these):\n{improvements}"

        response = self.client.models.generate_content(
            model=settings.gemini_model,
            contents=[
                types.Part.from_bytes(data=file_bytes, mime_type=mime_type),
                "Extract all invoice data from this document and return the JSON.",
            ],
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0,
            ),
        )
        raw = response.text.strip()

        if raw.startswith("```"):
            raw = raw.split("\n", 1)[-1]
            raw = raw.rsplit("```", 1)[0]

        data = json.loads(raw)
        invoice = _build_invoice(data)

        # Step 2: generate XML extension fragment if improvements exist
        xml_extension = None
        if improvements:
            xml_extension = await self._extract_extension(data, improvements)

        return invoice, xml_extension

    async def _extract_extension(self, core_data: dict, improvements: str) -> str | None:
        prompt = f"""CORE DATA (already extracted):
{json.dumps(core_data, ensure_ascii=False, indent=2)}

IMPROVEMENT NOTES:
{improvements}"""

        try:
            response = self.client.models.generate_content(
                model=settings.gemini_model,
                contents=[prompt],
                config=types.GenerateContentConfig(
                    system_instruction=_EXTENSION_PROMPT,
                    temperature=0,
                ),
            )
            result = response.text.strip()
            if result.startswith("```"):
                result = result.split("\n", 1)[-1]
                result = result.rsplit("```", 1)[0].strip()
            return result if result else None
        except Exception:
            return None


def _build_invoice(data: dict) -> InvoiceData:
    def _address(d: dict | None) -> Address | None:
        if not d:
            return None
        return Address(
            street=d.get("street"),
            city=d.get("city"),
            state=d.get("state"),
            postal_code=d.get("postal_code"),
            country=d.get("country"),
        )

    def _party(d: dict | None) -> Party:
        if not d:
            return Party()
        return Party(
            name=d.get("name"),
            registration_name=d.get("registration_name"),
            tax_id=d.get("tax_id"),
            endpoint_id=d.get("endpoint_id"),
            endpoint_scheme=d.get("endpoint_scheme") or "0195",
            email=d.get("email"),
            address=_address(d.get("address")),
        )

    line_items = [
        LineItem(
            description=li.get("description"),
            quantity=_float(li.get("quantity")),
            unit_price=_float(li.get("unit_price")),
            unit_code=li.get("unit_code"),
            total=_float(li.get("total")),
            tax_rate=_float(li.get("tax_rate")),
        )
        for li in data.get("line_items", [])
    ]

    return InvoiceData(
        invoice_number=data.get("invoice_number"),
        invoice_date=data.get("invoice_date"),
        due_date=data.get("due_date"),
        currency=data.get("currency") or "USD",
        tax_currency_code=data.get("tax_currency_code"),
        tax_exchange_rate=_float(data.get("tax_exchange_rate")),
        total=_float(data.get("total")),
        subtotal=_float(data.get("subtotal")),
        tax_amount=_float(data.get("tax_amount")),
        tax_rate=_float(data.get("tax_rate")),
        payment_terms=data.get("payment_terms"),
        purchase_order_number=data.get("purchase_order_number"),
        note=data.get("note"),
        supplier=_party(data.get("supplier")),
        customer=_party(data.get("customer")),
        line_items=line_items,
    )


def _float(v) -> float | None:
    if v is None:
        return None
    try:
        return float(v)
    except (TypeError, ValueError):
        return None
