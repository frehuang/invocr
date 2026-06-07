from pydantic import BaseModel


class ValidationError(BaseModel):
    id: str
    message: str


class DirectXmlResult(BaseModel):
    xsd_xml: str
    pint_xml: str
    final_xml: str
    xsd_errors: list[str]
    xsd_valid: bool
    schematron_errors: list[ValidationError] = []
    schematron_valid: bool = True
    detected_country: str = ""
