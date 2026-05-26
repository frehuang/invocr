import json
import pathlib
from datetime import datetime, timezone

from google import genai
from google.genai import types

from invocr.core.config import settings

_STORE = pathlib.Path(__file__).parent.parent / "learning" / "improvements.json"

_ANALYZE_PROMPT = """You are an invoice OCR quality analyst.

You will receive two UBL 2.1 XML documents:
1. ORIGINAL: AI-generated XML from OCR extraction
2. EDITED: Human-corrected version of the same XML

Your task:
1. Compare the two XMLs and identify every meaningful difference (ignore whitespace/formatting).
2. For each difference, determine the ROOT CAUSE — was it a field mapping error, a missing element, wrong value normalization, structural issue, etc.
3. Summarize the findings as concise, actionable improvement rules for the AI extractor.

Focus on patterns that would help the AI do better next time, not one-off data values.
Return a short bulleted list of improvement rules in English. Be specific and actionable.
Example: "- Always include cbc:EndpointID with schemeID='0195' for both supplier and buyer parties"
"""

_MERGE_PROMPT = """You are maintaining a compact set of AI improvement rules for invoice OCR extraction.

You will receive:
1. EXISTING RULES: The current set of improvement rules (may be empty)
2. NEW RULES: Newly discovered improvement rules from a human correction

Your task:
- Merge NEW RULES into EXISTING RULES
- Remove duplicates and redundancies
- Consolidate similar rules into more general ones where appropriate
- Keep the result concise (max ~20 bullet points)
- Preserve all unique insights
- Output ONLY the merged bullet list, no preamble or explanation
"""


def load_improvements() -> str:
    if not _STORE.exists():
        return ""
    try:
        data = json.loads(_STORE.read_text(encoding="utf-8"))
        return data.get("improvements", "")
    except Exception:
        return ""


def save_improvements(text: str) -> None:
    _STORE.parent.mkdir(parents=True, exist_ok=True)
    data = {
        "version": 1,
        "improvements": text,
        "updated_at": datetime.now(timezone.utc).isoformat(),
    }
    _STORE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


async def analyze_and_merge(original_xml: str, edited_xml: str) -> str:
    client = genai.Client(
        api_key=settings.gemini_api_key,
        http_options=types.HttpOptions(api_version="v1beta"),
    )

    # Step 1: analyze diff
    diff_prompt = f"""ORIGINAL XML:
{original_xml}

EDITED XML:
{edited_xml}"""

    resp1 = client.models.generate_content(
        model=settings.gemini_model,
        contents=[diff_prompt],
        config=types.GenerateContentConfig(
            system_instruction=_ANALYZE_PROMPT,
            temperature=0,
        ),
    )
    new_rules = resp1.text.strip()

    # Step 2: merge with existing
    existing = load_improvements()
    merge_prompt = f"""EXISTING RULES:
{existing if existing else "(none)"}

NEW RULES:
{new_rules}"""

    resp2 = client.models.generate_content(
        model=settings.gemini_model,
        contents=[merge_prompt],
        config=types.GenerateContentConfig(
            system_instruction=_MERGE_PROMPT,
            temperature=0,
        ),
    )
    merged = resp2.text.strip()
    save_improvements(merged)
    return merged
