from fastapi import APIRouter, File, HTTPException, UploadFile
from pydantic import BaseModel

from invocr.core.config import settings
from invocr.models.invoice import DirectXmlResult, ValidationError
from invocr.services.gemini_xml import GeminiXmlService
from invocr.services.improvements import analyze_and_merge, load_improvements

router = APIRouter(prefix="/invoices", tags=["invoices"])

ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/tiff", "image/webp", "application/pdf"}

_gemini_xml_service: GeminiXmlService | None = None


def get_gemini_xml_service() -> GeminiXmlService:
    global _gemini_xml_service
    if _gemini_xml_service is None:
        _gemini_xml_service = GeminiXmlService()
    return _gemini_xml_service


@router.post("/extract-xml", response_model=DirectXmlResult)
async def extract_invoice_xml(file: UploadFile = File(...)):
    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=415,
            detail=f"Unsupported file type: {file.content_type}. Allowed: {', '.join(ALLOWED_MIME_TYPES)}",
        )

    content = await file.read()
    max_bytes = settings.max_file_size_mb * 1024 * 1024
    if len(content) > max_bytes:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum size is {settings.max_file_size_mb}MB.",
        )

    try:
        xsd_xml, pint_xml, final_xml, xsd_errors, schematron_errors, detected_country = \
            await get_gemini_xml_service().extract_invoice_xml(content, file.content_type)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))

    return DirectXmlResult(
        xsd_xml=xsd_xml,
        pint_xml=pint_xml,
        final_xml=final_xml,
        xsd_errors=xsd_errors,
        xsd_valid=len(xsd_errors) == 0,
        schematron_errors=[ValidationError(**e) for e in schematron_errors],
        schematron_valid=len(schematron_errors) == 0,
        detected_country=detected_country,
    )


class FeedbackRequest(BaseModel):
    xsd_xml: str    # original AI-generated XML (Step 2, before country headers)
    edited_xml: str  # human-corrected version


@router.post("/feedback")
async def submit_feedback(req: FeedbackRequest):
    try:
        merged = await analyze_and_merge(req.xsd_xml, req.edited_xml)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))
    return {"improvements": merged}


@router.get("/improvements")
async def get_improvements():
    return {"improvements": load_improvements()}
