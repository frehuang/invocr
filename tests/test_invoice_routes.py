import io
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from invocr.api.app import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_index_page():
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]


def test_extract_xml_unsupported_type():
    response = client.post(
        "/invoices/extract-xml",
        files={"file": ("test.txt", io.BytesIO(b"hello"), "text/plain")},
    )
    assert response.status_code == 415


def test_extract_xml_file_too_large():
    big_content = b"x" * (11 * 1024 * 1024)
    response = client.post(
        "/invoices/extract-xml",
        files={"file": ("invoice.jpg", io.BytesIO(big_content), "image/jpeg")},
    )
    assert response.status_code == 413


@patch("invocr.api.routes.invoice.get_gemini_xml_service")
def test_extract_xml_returns_result(mock_get_svc):
    mock_svc = MagicMock()
    mock_svc.extract_invoice_xml = AsyncMock(return_value=(
        "<Invoice/>",   # xsd_xml
        "<Invoice/>",   # pint_xml
        "<Invoice/>",   # final_xml
        [],             # xsd_errors
        [],             # schematron_errors
        "SG",           # detected_country
    ))
    mock_get_svc.return_value = mock_svc

    response = client.post(
        "/invoices/extract-xml",
        files={"file": ("invoice.pdf", io.BytesIO(b"fake-pdf-bytes"), "application/pdf")},
    )
    assert response.status_code == 200
    data = response.json()
    assert "xsd_xml" in data
    assert "pint_xml" in data
    assert "final_xml" in data
    assert data["xsd_valid"] is True
    assert data["schematron_valid"] is True
    assert data["detected_country"] == "SG"


@patch("invocr.api.routes.invoice.get_gemini_xml_service")
def test_extract_xml_with_xsd_errors(mock_get_svc):
    mock_svc = MagicMock()
    mock_svc.extract_invoice_xml = AsyncMock(return_value=(
        "<Invoice/>", "<Invoice/>", "<Invoice/>",
        ["Error: missing element ID"],
        [],
        "",
    ))
    mock_get_svc.return_value = mock_svc

    response = client.post(
        "/invoices/extract-xml",
        files={"file": ("invoice.pdf", io.BytesIO(b"fake-pdf-bytes"), "application/pdf")},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["xsd_valid"] is False
    assert len(data["xsd_errors"]) == 1


def test_get_improvements():
    response = client.get("/invoices/improvements")
    assert response.status_code == 200
    assert "improvements" in response.json()


def test_supplier_country_detection():
    from invocr.services.gemini_xml import _detect_supplier_country

    xml = """<?xml version="1.0"?>
<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
         xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
         xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
  <cac:AccountingSupplierParty>
    <cac:Party>
      <cac:PostalAddress>
        <cac:Country>
          <cbc:IdentificationCode>SG</cbc:IdentificationCode>
        </cac:Country>
      </cac:PostalAddress>
    </cac:Party>
  </cac:AccountingSupplierParty>
</Invoice>"""
    assert _detect_supplier_country(xml) == "SG"


def test_supplier_country_detection_missing():
    from invocr.services.gemini_xml import _detect_supplier_country
    assert _detect_supplier_country("<Invoice/>") is None
