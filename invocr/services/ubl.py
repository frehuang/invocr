"""UBL 2.1 Invoice serializer.

Spec: http://docs.oasis-open.org/ubl/os-UBL-2.1/UBL-2.1.html
"""
from datetime import date
from lxml import etree

from invocr.models.invoice import InvoiceData

_NS = {
    None: "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2",
    "cac": "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2",
    "cbc": "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2",
}
_CAC = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
_CBC = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"


def _cbc(tag: str) -> str:
    return f"{{{_CBC}}}{tag}"


def _cac(tag: str) -> str:
    return f"{{{_CAC}}}{tag}"


def _sub(parent, tag: str, text: str | None) -> etree._Element | None:
    if text is None:
        return None
    el = etree.SubElement(parent, tag)
    el.text = str(text)
    return el


def _amount(parent, tag: str, value: float | None, currency: str) -> None:
    if value is None:
        return
    el = etree.SubElement(parent, tag)
    el.set("currencyID", currency)
    el.text = f"{value:.2f}"


def _party_element(parent, tag: str, party) -> None:
    if not party or not party.name:
        return
    cac_party = etree.SubElement(parent, _cac(tag))
    party_el = etree.SubElement(cac_party, _cac("Party"))

    if party.endpoint_id:
        ep = etree.SubElement(party_el, _cbc("EndpointID"))
        ep.set("schemeID", party.endpoint_scheme or "0195")
        ep.text = party.endpoint_id
    elif party.tax_id:
        ep = etree.SubElement(party_el, _cbc("EndpointID"))
        ep.set("schemeID", "0195")
        ep.text = party.tax_id

    name_el = etree.SubElement(party_el, _cac("PartyName"))
    _sub(name_el, _cbc("Name"), party.name)

    if party.address:
        addr = party.address
        postal = etree.SubElement(party_el, _cac("PostalAddress"))
        _sub(postal, _cbc("StreetName"), addr.street)
        _sub(postal, _cbc("CityName"), addr.city)
        _sub(postal, _cbc("PostalZone"), addr.postal_code)
        if addr.state:
            sub_el = etree.SubElement(postal, _cac("CountrySubentity"))
            sub_el.text = addr.state
        if addr.country:
            country_el = etree.SubElement(postal, _cac("Country"))
            _sub(country_el, _cbc("IdentificationCode"), addr.country)

    if party.tax_id:
        tax_scheme = etree.SubElement(party_el, _cac("PartyTaxScheme"))
        _sub(tax_scheme, _cbc("CompanyID"), party.tax_id)
        scheme_el = etree.SubElement(tax_scheme, _cac("TaxScheme"))
        _sub(scheme_el, _cbc("ID"), "VAT")

    legal = etree.SubElement(party_el, _cac("PartyLegalEntity"))
    _sub(legal, _cbc("RegistrationName"), party.registration_name or party.name)

    if party.email:
        contact = etree.SubElement(party_el, _cac("Contact"))
        _sub(contact, _cbc("ElectronicMail"), party.email)


def _merge_extension(root: etree._Element, xml_extension: str) -> None:
    """Parse xml_extension fragment and append non-duplicate elements to root."""
    try:
        # Wrap in a temporary root to parse the fragment
        wrapped = f'<_root xmlns:cac="{_CAC}" xmlns:cbc="{_CBC}">{xml_extension}</_root>'
        frag = etree.fromstring(wrapped.encode("utf-8"))
    except etree.XMLSyntaxError:
        return

    existing_tags = {child.tag for child in root}
    for child in frag:
        if child.tag not in existing_tags:
            root.append(child)


def to_ubl_xml(invoice: InvoiceData, xml_extension: str | None = None) -> bytes:
    root = etree.Element("Invoice", nsmap=_NS)

    _sub(root, _cbc("UBLVersionID"), "2.1")
    _sub(root, _cbc("CustomizationID"), "urn:piaozone.com:ubl-2.1-customizations:v1.0")
    _sub(root, _cbc("ProfileID"), "urn:piaozone.com:profile:bill:v1.0")
    _sub(root, _cbc("ID"), invoice.invoice_number or "UNKNOWN")
    _sub(root, _cbc("IssueDate"), invoice.invoice_date or date.today().isoformat())
    if invoice.due_date:
        _sub(root, _cbc("DueDate"), invoice.due_date)
    _sub(root, _cbc("InvoiceTypeCode"), "380")  # 380 = Commercial Invoice
    if invoice.note:
        _sub(root, _cbc("Note"), invoice.note)
    _sub(root, _cbc("DocumentCurrencyCode"), invoice.currency)
    if invoice.tax_currency_code:
        _sub(root, _cbc("TaxCurrencyCode"), invoice.tax_currency_code)
    if invoice.purchase_order_number:
        order_ref = etree.SubElement(root, _cac("OrderReference"))
        _sub(order_ref, _cbc("ID"), invoice.purchase_order_number)

    _party_element(root, "AccountingSupplierParty", invoice.supplier)
    _party_element(root, "AccountingCustomerParty", invoice.customer)

    if invoice.tax_exchange_rate and invoice.tax_currency_code:
        ter = etree.SubElement(root, _cac("TaxExchangeRate"))
        _sub(ter, _cbc("SourceCurrencyCode"), invoice.currency)
        _sub(ter, _cbc("TargetCurrencyCode"), invoice.tax_currency_code)
        rate_el = etree.SubElement(ter, _cbc("CalculationRate"))
        rate_el.text = f"{invoice.tax_exchange_rate:.6f}"

    if invoice.payment_terms:
        pt = etree.SubElement(root, _cac("PaymentTerms"))
        _sub(pt, _cbc("Note"), invoice.payment_terms)

    # Tax total
    if invoice.tax_amount is not None:
        tax_total = etree.SubElement(root, _cac("TaxTotal"))
        _amount(tax_total, _cbc("TaxAmount"), invoice.tax_amount, invoice.currency)
        if invoice.tax_rate is not None:
            tax_sub = etree.SubElement(tax_total, _cac("TaxSubtotal"))
            _amount(tax_sub, _cbc("TaxableAmount"), invoice.subtotal, invoice.currency)
            _amount(tax_sub, _cbc("TaxAmount"), invoice.tax_amount, invoice.currency)
            tax_cat = etree.SubElement(tax_sub, _cac("TaxCategory"))
            _sub(tax_cat, _cbc("Percent"), str(invoice.tax_rate))
            scheme = etree.SubElement(tax_cat, _cac("TaxScheme"))
            _sub(scheme, _cbc("ID"), "VAT")

    # Monetary totals
    lm = etree.SubElement(root, _cac("LegalMonetaryTotal"))
    _amount(lm, _cbc("LineExtensionAmount"), invoice.subtotal, invoice.currency)
    _amount(lm, _cbc("TaxExclusiveAmount"), invoice.subtotal, invoice.currency)
    _amount(lm, _cbc("TaxInclusiveAmount"), invoice.total, invoice.currency)
    _amount(lm, _cbc("PayableAmount"), invoice.total, invoice.currency)

    # Line items
    for idx, item in enumerate(invoice.line_items, start=1):
        line = etree.SubElement(root, _cac("InvoiceLine"))
        _sub(line, _cbc("ID"), str(idx))
        if item.quantity is not None:
            qty = etree.SubElement(line, _cbc("InvoicedQuantity"))
            qty.set("unitCode", item.unit_code or "EA")
            qty.text = f"{item.quantity:.4f}"
        _amount(line, _cbc("LineExtensionAmount"), item.total, invoice.currency)

        if item.tax_rate is not None:
            item_tax_total = etree.SubElement(line, _cac("TaxTotal"))
            item_tax_amount = (item.total or 0) * (item.tax_rate / 100)
            _amount(item_tax_total, _cbc("TaxAmount"), item_tax_amount, invoice.currency)
            item_tax_sub = etree.SubElement(item_tax_total, _cac("TaxSubtotal"))
            _amount(item_tax_sub, _cbc("TaxableAmount"), item.total, invoice.currency)
            _amount(item_tax_sub, _cbc("TaxAmount"), item_tax_amount, invoice.currency)
            item_tax_cat = etree.SubElement(item_tax_sub, _cac("TaxCategory"))
            _sub(item_tax_cat, _cbc("Percent"), str(item.tax_rate))
            item_scheme = etree.SubElement(item_tax_cat, _cac("TaxScheme"))
            _sub(item_scheme, _cbc("ID"), "VAT")

        item_el = etree.SubElement(line, _cac("Item"))
        _sub(item_el, _cbc("Description"), item.description)
        _sub(item_el, _cbc("Name"), item.description)

        if item.unit_price is not None:
            price = etree.SubElement(line, _cac("Price"))
            _amount(price, _cbc("PriceAmount"), item.unit_price, invoice.currency)

    if xml_extension:
        _merge_extension(root, xml_extension)

    return etree.tostring(root, xml_declaration=True, encoding="UTF-8", pretty_print=True)
