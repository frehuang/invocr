from fastapi import APIRouter, Body, File, HTTPException, Query, UploadFile
from pydantic import BaseModel

from invocr.core.config import settings
from invocr.models.invoice import DirectXmlResult, ExtractionResult, ValidationError
from invocr.services.fixer import fix_and_validate
from invocr.services.gemini import GeminiService
from invocr.services.gemini_xml import GeminiXmlService
from invocr.services.improvements import analyze_and_merge, load_improvements
from invocr.services.ubl import to_ubl_xml
from invocr.services.validation import validate_xml

router = APIRouter(prefix="/invoices", tags=["invoices"])

ALLOWED_MIME_TYPES = {"image/jpeg", "image/png", "image/tiff", "image/webp", "application/pdf"}

_gemini_service: GeminiService | None = None
_gemini_xml_service: GeminiXmlService | None = None


def get_gemini_service() -> GeminiService:
    global _gemini_service
    if _gemini_service is None:
        _gemini_service = GeminiService()
    return _gemini_service


def get_gemini_xml_service() -> GeminiXmlService:
    global _gemini_xml_service
    if _gemini_xml_service is None:
        _gemini_xml_service = GeminiXmlService()
    return _gemini_xml_service


@router.post(
    "/extract",
    response_model=ExtractionResult,
)
async def extract_invoice(
    file: UploadFile = File(...),
    country: str = Query(default="sg"),
):
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
        invoice, xml_extension = await get_gemini_service().extract_invoice(content, file.content_type)
        xml_bytes = to_ubl_xml(invoice, xml_extension)
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e))

    missing_fields = [
        field
        for field, value in invoice.model_dump().items()
        if field not in ("supplier", "customer", "line_items")
        and (value is None or value == "")
    ]

    xml_str = xml_bytes.decode("utf-8")
    try:
        raw_errors = validate_xml(xml_str, country)
        validation_errors = [ValidationError(**e) for e in raw_errors]
    except ValueError:
        validation_errors = []

    fixed_xml = None
    fixed_validation_errors = []
    if validation_errors:
        try:
            fixed_xml, remaining = fix_and_validate(xml_str, country)
            fixed_validation_errors = [ValidationError(**e) for e in remaining]
        except Exception:
            fixed_xml = None

    return ExtractionResult(
        xml=xml_str,
        missing_fields=missing_fields,
        validation_errors=validation_errors,
        country=country,
        fixed_xml=fixed_xml,
        fixed_validation_errors=fixed_validation_errors,
    )


@router.post("/validate")
async def validate_invoice(xml: str = Body(...), country: str = Body(...)):
    try:
        errors = validate_xml(xml, country)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    return {"errors": errors}


class FeedbackRequest(BaseModel):
    original_xml: str
    edited_xml: str


@router.post("/feedback")
async def submit_feedback(req: FeedbackRequest):
    try:
        merged = await analyze_and_merge(req.original_xml, req.edited_xml)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))
    return {"improvements": merged}


@router.get("/improvements")
async def get_improvements():
    return {"improvements": load_improvements()}


@router.post("/extract-xml", response_model=DirectXmlResult)
async def extract_invoice_xml(
    file: UploadFile = File(...),
):
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
        xml_str, xsd_errors = await get_gemini_xml_service().extract_invoice_xml(content, file.content_type)
    except Exception as e:
        raise HTTPException(status_code=502, detail=str(e))

    return DirectXmlResult(
        xml=xml_str,
        xsd_errors=xsd_errors,
        valid=len(xsd_errors) == 0,
    )
