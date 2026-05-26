import io
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from invocr.api.app import app
from invocr.models.invoice import Address, InvoiceData, LineItem, Party

client = TestClient(app)

_SAMPLE_INVOICE = InvoiceData(
    invoice_number="INV-2024-001",
    invoice_date="2024-01-15",
    due_date="2024-02-15",
    currency="USD",
    total=1210.00,
    subtotal=1100.00,
    tax_amount=110.00,
    tax_rate=10.0,
    supplier=Party(name="Acme Corp", address=Address(city="New York", country="US")),
    customer=Party(name="Buyer Ltd", address=Address(city="London", country="GB")),
    line_items=[
        LineItem(description="Consulting services", quantity=10.0, unit_price=110.0, total=1100.0)
    ],
)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_extract_unsupported_type():
    response = client.post(
        "/invoices/extract",
        files={"file": ("test.txt", io.BytesIO(b"hello"), "text/plain")},
    )
    assert response.status_code == 415


def test_extract_file_too_large():
    big_content = b"x" * (11 * 1024 * 1024)
    response = client.post(
        "/invoices/extract",
        files={"file": ("invoice.jpg", io.BytesIO(big_content), "image/jpeg")},
    )
    assert response.status_code == 413


@patch("invocr.api.routes.invoice.get_gemini_service")
def test_extract_returns_xml(mock_get_gemini):
    mock_gemini = MagicMock()
    mock_gemini.extract_invoice = AsyncMock(return_value=(_SAMPLE_INVOICE, None))
    mock_get_gemini.return_value = mock_gemini

    response = client.post(
        "/invoices/extract",
        files={"file": ("invoice.pdf", io.BytesIO(b"fake-pdf-bytes"), "application/pdf")},
    )
    assert response.status_code == 200
    assert "application/json" in response.headers["content-type"]
    data = response.json()
    assert "xml" in data
    assert "missing_fields" in data
    xml = data["xml"]
    assert "INV-2024-001" in xml
    assert "Invoice" in xml
    assert "UBLVersionID" in xml


def test_index_page():
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]


def test_ubl_xml_structure():
    from invocr.services.ubl import to_ubl_xml
    from lxml import etree

    xml_bytes = to_ubl_xml(_SAMPLE_INVOICE)
    root = etree.fromstring(xml_bytes)

    cbc = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    cac = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"

    assert root.find(f"{{{cbc}}}ID").text == "INV-2024-001"
    assert root.find(f"{{{cbc}}}DocumentCurrencyCode").text == "USD"
    assert root.find(f"{{{cbc}}}IssueDate").text == "2024-01-15"
    lines = root.findall(f"{{{cac}}}InvoiceLine")
    assert len(lines) == 1


def test_ubl_header_fields():
    from invocr.services.ubl import to_ubl_xml
    from lxml import etree

    xml_bytes = to_ubl_xml(_SAMPLE_INVOICE)
    root = etree.fromstring(xml_bytes)
    cbc = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"

    assert root.find(f"{{{cbc}}}UBLVersionID").text == "2.1"
    assert root.find(f"{{{cbc}}}CustomizationID").text == "urn:piaozone.com:ubl-2.1-customizations:v1.0"
    assert root.find(f"{{{cbc}}}ProfileID").text == "urn:piaozone.com:profile:bill:v1.0"


@patch("invocr.api.routes.invoice.get_gemini_service")
def test_extract_missing_fields(mock_get_gemini):
    incomplete_invoice = InvoiceData(
        invoice_number="INV-001",
        invoice_date="2024-01-15",
        currency="USD",
        total=100.0,
    )
    mock_gemini = MagicMock()
    mock_gemini.extract_invoice = AsyncMock(return_value=(incomplete_invoice, None))
    mock_get_gemini.return_value = mock_gemini

    response = client.post(
        "/invoices/extract",
        files={"file": ("invoice.pdf", io.BytesIO(b"fake-pdf-bytes"), "application/pdf")},
    )
    assert response.status_code == 200
    data = response.json()
    assert "missing_fields" in data
    assert "due_date" in data["missing_fields"]
    assert "subtotal" in data["missing_fields"]
    assert "tax_amount" in data["missing_fields"]


def test_validate_unsupported_country():
    response = client.post(
        "/invoices/validate",
        json={"xml": "<Invoice/>", "country": "xx"},
    )
    assert response.status_code == 400
