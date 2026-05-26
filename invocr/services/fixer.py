import json

from google import genai
from google.genai import types

from invocr.core.config import settings
from invocr.services.validation import validate_xml

_FIX_PROMPT = """You are a UBL 2.1 XML repair specialist.

You will receive a UBL 2.1 Invoice XML and a list of validation errors from a Schematron validator.
Your task is to fix the XML so it passes validation, WITHOUT changing any invoice business content
(amounts, dates, invoice number, party names, line items, etc.).

You may ONLY:
- Add missing required structural elements with placeholder/default values
- Fix element ordering to match UBL 2.1 schema sequence
- Add missing namespace declarations
- Add required attributes

Common fixes:
- Missing seller/buyer name: ensure cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name exists
- Missing electronic address (ibt-034/ibt-049): add cac:Contact/cbc:ElectronicMail or cbc:EndpointID with schemeID="0195"
- Missing party legal entity: add cac:PartyLegalEntity/cbc:RegistrationName
- Missing tax scheme: ensure cac:TaxScheme/cbc:ID = "VAT" exists in TaxCategory

Return ONLY the fixed XML, no explanation, no markdown fences."""


def fix_and_validate(xml_str: str, country_code: str, max_iterations: int = 3) -> tuple[str, list[dict]]:
    """Iteratively fix XML until validation passes or max_iterations reached.
    Returns (fixed_xml, remaining_errors).
    """
    current_xml = xml_str
    errors = validate_xml(current_xml, country_code)

    if not errors:
        return current_xml, []

    client = genai.Client(
        api_key=settings.gemini_api_key,
        http_options=types.HttpOptions(api_version="v1beta"),
    )

    for _ in range(max_iterations):
        if not errors:
            break

        error_summary = "\n".join(
            f"- [{e['id']}] {e['message']}" for e in errors
        )

        prompt = f"""Fix the following UBL 2.1 XML to resolve these validation errors:

VALIDATION ERRORS:
{error_summary}

XML TO FIX:
{current_xml}"""

        response = client.models.generate_content(
            model=settings.gemini_model,
            contents=[prompt],
            config=types.GenerateContentConfig(
                system_instruction=_FIX_PROMPT,
                temperature=0,
            ),
        )

        fixed = response.text.strip()
        if fixed.startswith("```"):
            fixed = fixed.split("\n", 1)[-1]
            fixed = fixed.rsplit("```", 1)[0].strip()

        if not fixed.startswith("<?xml") and not fixed.startswith("<"):
            break

        current_xml = fixed
        errors = validate_xml(current_xml, country_code)

    return current_xml, errors
