from pydantic import BaseModel


class LineItem(BaseModel):
    description: str | None = None
    quantity: float | None = None
    unit_price: float | None = None
    unit_code: str | None = None
    total: float | None = None
    tax_rate: float | None = None


class Address(BaseModel):
    street: str | None = None
    city: str | None = None
    state: str | None = None
    postal_code: str | None = None
    country: str | None = None


class Party(BaseModel):
    name: str | None = None
    tax_id: str | None = None
    registration_name: str | None = None
    endpoint_id: str | None = None
    endpoint_scheme: str = "0195"
    email: str | None = None
    address: Address | None = None


class InvoiceData(BaseModel):
    invoice_number: str | None = None
    invoice_date: str | None = None
    due_date: str | None = None
    supplier: Party = Party()
    customer: Party = Party()
    line_items: list[LineItem] = []
    subtotal: float | None = None
    tax_amount: float | None = None
    tax_rate: float | None = None
    total: float | None = None
    currency: str = "USD"
    tax_currency_code: str | None = None
    tax_exchange_rate: float | None = None
    payment_terms: str | None = None
    purchase_order_number: str | None = None
    note: str | None = None


class ValidationError(BaseModel):
    id: str
    message: str


class ExtractionResult(BaseModel):
    xml: str
    missing_fields: list[str]
    validation_errors: list[ValidationError]
    country: str
    fixed_xml: str | None = None
    fixed_validation_errors: list[ValidationError] = []


class DirectXmlResult(BaseModel):
    xsd_xml: str
    pint_xml: str
    final_xml: str
    xsd_errors: list[str]
    xsd_valid: bool
    schematron_errors: list[ValidationError] = []
    schematron_valid: bool = True
    detected_country: str = ""
