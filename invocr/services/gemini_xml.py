import json
import pathlib
import re

from google import genai
from google.genai import types
from lxml import etree

from invocr.core.config import settings
from invocr.services.improvements import load_improvements
from invocr.services.validation import validate_xml

_XSD_PATH = pathlib.Path(__file__).parent.parent / "invoice" / "maindoc" / "UBL-Invoice-2.1.xsd"

# Country-specific UBL header values
_COUNTRY_HEADERS: dict[str, dict[str, str]] = {
    "sg": {
        "CustomizationID": "urn:peppol:pint:billing-1@sg-1",
        "ProfileID": "urn:peppol:bis:billing",
    },
}

_CBC = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"


def _apply_country_headers(xml_str: str, country: str) -> str:
    """Replace CustomizationID and ProfileID for country-specific formats."""
    headers = _COUNTRY_HEADERS.get(country.lower())
    if not headers:
        return xml_str
    for tag, value in headers.items():
        xml_str = re.sub(
            rf'(<cbc:{tag}[^>]*>)[^<]*(</cbc:{tag}>)',
            rf'\g<1>{value}\2',
            xml_str,
        )
    return xml_str

_SYSTEM_PROMPT = """You are a UBL 2.1 Invoice XML generation specialist.

You receive an invoice image or PDF. Your tasks:
1. Perform OCR to read all text from the document.
2. Extract all invoice fields and generate a complete, valid UBL 2.1 Invoice XML document.
3. Translate any non-English text to English for field values.
4. Normalize dates to ISO 8601 (YYYY-MM-DD), amounts to decimal numbers, currency to ISO 4217.
5. Return ONLY the raw XML — no markdown fences, no explanation, no extra text.

Required UBL 2.1 namespaces on the root Invoice element:
  xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
  xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
  xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"

Required header elements (in this order):
  cbc:UBLVersionID = 2.1
  cbc:CustomizationID = urn:piaozone.com:ubl-2.1-customizations:v1.0
  cbc:ProfileID = urn:piaozone.com:profile:bill:v1.0
  cbc:ID (invoice number)
  cbc:IssueDate (YYYY-MM-DD)
  cbc:InvoiceTypeCode = 380
  cbc:DocumentCurrencyCode (ISO 4217)

Required party elements:
  cac:AccountingSupplierParty / cac:Party
  cac:AccountingCustomerParty / cac:Party

Each Party must include:
  cbc:EndpointID with schemeID="0195"
  cac:PartyName / cbc:Name
  cac:PostalAddress
  cac:PartyTaxScheme / cbc:CompanyID + cac:TaxScheme/cbc:ID = VAT
  cac:PartyLegalEntity / cbc:RegistrationName

Required totals:
  cac:TaxTotal / cbc:TaxAmount
  cac:LegalMonetaryTotal with cbc:LineExtensionAmount, cbc:TaxExclusiveAmount, cbc:TaxInclusiveAmount, cbc:PayableAmount

Each cac:InvoiceLine must include:
  cbc:ID, cbc:InvoicedQuantity (with unitCode), cbc:LineExtensionAmount
  cac:Item / cbc:Name
  cac:Price / cbc:PriceAmount"""

_FIX_PROMPT = """You are a UBL 2.1 XML repair specialist.

You will receive a UBL 2.1 Invoice XML and a list of XSD validation errors.
Fix the XML to pass XSD validation. Do NOT change any invoice business data (amounts, dates, names, etc.).
Return ONLY the fixed raw XML — no markdown fences, no explanation."""

_SCHEMATRON_FIX_PROMPT = """You are a UBL 2.1 Invoice XML repair specialist for country-specific Schematron rules.

You will receive a UBL 2.1 Invoice XML and a list of Schematron validation errors (rule ID + message).
Fix the XML structure to resolve these errors. Do NOT change any invoice business data (amounts, dates, invoice number, party names, line items).
You may add missing required elements, fix element ordering, add required attributes or codes.
Return ONLY the fixed raw XML — no markdown fences, no explanation."""


def _load_xsd_schema() -> etree.XMLSchema:
    xsd_doc = etree.parse(str(_XSD_PATH))
    return etree.XMLSchema(xsd_doc)


def _validate_xsd(xml_str: str) -> list[str]:
    try:
        schema = _load_xsd_schema()
        doc = etree.fromstring(xml_str.encode("utf-8"))
        schema.validate(doc)
        return [str(e) for e in schema.error_log]
    except etree.XMLSyntaxError as e:
        return [f"XML parse error: {e}"]
    except Exception as e:
        return [f"Validation error: {e}"]


def _clean_xml(raw: str) -> str:
    raw = raw.strip()
    if raw.startswith("```"):
        raw = raw.split("\n", 1)[-1]
        raw = raw.rsplit("```", 1)[0].strip()
    return raw


class GeminiXmlService:
    def __init__(self):
        self.client = genai.Client(
            api_key=settings.gemini_api_key,
            http_options=types.HttpOptions(api_version="v1beta"),
        )

    async def extract_invoice_xml(
        self, file_bytes: bytes, mime_type: str, country: str = "sg"
    ) -> tuple[str, list[str], list[dict]]:
        """Extract invoice as UBL 2.1 XML directly from Gemini.
        Returns (xml_str, xsd_errors, schematron_errors).
        """
        improvements = load_improvements()
        system_prompt = _SYSTEM_PROMPT
        if improvements:
            system_prompt += f"\n\n## Improvement notes from past human corrections (apply these):\n{improvements}"

        # Step 1: initial extraction
        response = self.client.models.generate_content(
            model=settings.gemini_model,
            contents=[
                types.Part.from_bytes(data=file_bytes, mime_type=mime_type),
                "Extract all invoice data from this document and return a complete UBL 2.1 Invoice XML.",
            ],
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0,
            ),
        )
        xml_str = _clean_xml(response.text)

        # Step 2: XSD validation + retry loop (max 3 attempts)
        for attempt in range(3):
            errors = _validate_xsd(xml_str)
            if not errors:
                break

            if attempt == 2:
                return xml_str, errors, []

            error_summary = "\n".join(f"- {e}" for e in errors[:20])
            fix_prompt = f"""XSD VALIDATION ERRORS:
{error_summary}

XML TO FIX:
{xml_str}"""

            fix_response = self.client.models.generate_content(
                model=settings.gemini_model,
                contents=[fix_prompt],
                config=types.GenerateContentConfig(
                    system_instruction=_FIX_PROMPT,
                    temperature=0,
                ),
            )
            xml_str = _clean_xml(fix_response.text)

        # Step 3: apply country-specific header values
        xml_str = _apply_country_headers(xml_str, country)

        # Step 4: Schematron validation + retry loop (max 3 attempts)
        try:
            schematron_errors = validate_xml(xml_str, country)
        except ValueError:
            return xml_str, [], []

        for attempt in range(3):
            if not schematron_errors:
                break

            if attempt == 2:
                break

            error_summary = "\n".join(
                f"- [{e['id']}] {e['message']}" for e in schematron_errors[:20]
            )
            fix_prompt = f"""SCHEMATRON VALIDATION ERRORS:
{error_summary}

XML TO FIX:
{xml_str}"""

            fix_response = self.client.models.generate_content(
                model=settings.gemini_model,
                contents=[fix_prompt],
                config=types.GenerateContentConfig(
                    system_instruction=_SCHEMATRON_FIX_PROMPT,
                    temperature=0,
                ),
            )
            xml_str = _clean_xml(fix_response.text)
            # Re-apply country headers after fix (Gemini may have reset them)
            xml_str = _apply_country_headers(xml_str, country)
            try:
                schematron_errors = validate_xml(xml_str, country)
            except ValueError:
                schematron_errors = []
                break

        return xml_str, [], schematron_errors
