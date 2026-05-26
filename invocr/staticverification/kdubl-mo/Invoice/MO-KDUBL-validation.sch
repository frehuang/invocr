<?xml version="1.0" encoding="UTF-8"?>
<!--
Macau KDUBL Invoice Validation Rules
Based on European EN16931 standard with Europe-specific logic removed

This schematron defines validation rules for Macau invoices based on universal business rules
from the EN16931 standard, excluding EU-specific VAT categories and country-specific requirements.

规则来源：Based on CEN-EN16931-UBL.sch with EU-specific rules removed
适用范围：澳门发票通用业务规则验证

规则分类：
- BR-XX: 核心业务规则 (Core business rules)
- BR-CO-XX: 一致性规则 (Consistency rules)
- BR-DEC-XX: 小数精度规则 (Decimal precision rules)

已移除的欧洲特定规则：
- BR-AE, BR-E, BR-G, BR-IC, BR-IG, BR-IP, BR-O, BR-S, BR-Z, BR-B (VAT category specific rules)
- PEPPOL-specific requirements
- Country-specific rules (NO-R, DK-R, etc.)
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
        xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
        xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
        xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
        xmlns:cn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        schemaVersion="iso"
        queryBinding="xslt2">
	
	<title>Macau KDUBL Invoice Validation Rules (Based on EN16931)</title>
	
	<ns uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" prefix="cbc"/>
	<ns uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" prefix="cac"/>
	<ns uri="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" prefix="cn"/>
	<ns uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" prefix="ubl-invoice"/>
	<ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
	
	<!-- Pattern 1: Document Level - Core Business Rules (BR-01 to BR-16) -->
	<pattern id="MO-document-level">
		<rule context="/ubl-invoice:Invoice | /cn:CreditNote">
			<!-- BR-01: Specification identifier -->
			<assert id="MO-BR-01" test="normalize-space(cbc:CustomizationID) != ''" flag="fatal">
				[MO-BR-01] An Invoice shall have a Specification identifier (BT-24).
			</assert>
			
			<!-- BR-02: Invoice number -->
			<assert id="MO-BR-02" test="normalize-space(cbc:ID) != ''" flag="fatal">
				[MO-BR-02] An Invoice shall have an Invoice number (BT-1).
			</assert>
			
			<!-- BR-03: Issue date -->
			<assert id="MO-BR-03" test="normalize-space(cbc:IssueDate) != ''" flag="fatal">
				[MO-BR-03] An Invoice shall have an Invoice issue date (BT-2).
			</assert>
			
			<!-- BR-04: Invoice type code -->
			<assert id="MO-BR-04" test="normalize-space(cbc:InvoiceTypeCode) != '' or normalize-space(cbc:CreditNoteTypeCode) !=''" flag="fatal">
				[MO-BR-04] An Invoice shall have an Invoice type code (BT-3).
			</assert>
			
			<!-- BR-05: Document currency code -->
			<assert id="MO-BR-05" test="normalize-space(cbc:DocumentCurrencyCode) != ''" flag="fatal">
				[MO-BR-05] An Invoice shall have an Invoice currency code (BT-5).
			</assert>
			
			<!-- BR-06: Seller name -->
			<assert id="MO-BR-06" test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName) != ''" flag="fatal">
				[MO-BR-06] An Invoice shall contain the Seller name (BT-27).
			</assert>
			
			<!-- BR-07: Buyer name -->
			<assert id="MO-BR-07" test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName) != ''" flag="fatal">
				[MO-BR-07] An Invoice shall contain the Buyer name (BT-44).
			</assert>
			
			<!-- BR-08: Seller postal address -->
			<assert id="MO-BR-08" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress)" flag="fatal">
				[MO-BR-08] An Invoice shall contain the Seller postal address.
			</assert>
			
			<!-- BR-10: Buyer postal address -->
			<assert id="MO-BR-10" test="exists(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress)" flag="fatal">
				[MO-BR-10] An Invoice shall contain the Buyer postal address (BG-8).
			</assert>
			
			<!-- BR-16: At least one invoice line -->
			<assert id="MO-BR-16" test="exists(cac:InvoiceLine) or exists(cac:CreditNoteLine)" flag="fatal">
				[MO-BR-16] An Invoice shall have at least one Invoice line (BG-25).
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 2: Supplier and Customer Address -->
	<pattern id="MO-party-address">
		<rule context="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress">
			<!-- BR-09: Seller country code -->
			<assert id="MO-BR-09" test="normalize-space(cac:Country/cbc:IdentificationCode) != ''" flag="fatal">
				[MO-BR-09] The Seller postal address shall contain a Seller country code (BT-40).
			</assert>
		</rule>
		
		<rule context="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress">
			<!-- BR-11: Buyer country code -->
			<assert id="MO-BR-11" test="normalize-space(cac:Country/cbc:IdentificationCode) != ''" flag="fatal">
				[MO-BR-11] The Buyer postal address shall contain a Buyer country code (BT-55).
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 3: Legal Monetary Total (BR-12 to BR-15) -->
	<pattern id="MO-monetary-total">
		<rule context="cac:LegalMonetaryTotal">
			<!-- BR-12: Sum of invoice line net amount -->
			<assert id="MO-BR-12" test="exists(cbc:LineExtensionAmount)" flag="fatal">
				[MO-BR-12] An Invoice shall have the Sum of Invoice line net amount (BT-106).
			</assert>
			
			<!-- BR-13: Invoice total amount without VAT -->
			<assert id="MO-BR-13" test="exists(cbc:TaxExclusiveAmount)" flag="fatal">
				[MO-BR-13] An Invoice shall have the Invoice total amount without VAT (BT-109).
			</assert>
			
			<!-- BR-14: Invoice total amount with VAT -->
			<assert id="MO-BR-14" test="exists(cbc:TaxInclusiveAmount)" flag="fatal">
				[MO-BR-14] An Invoice shall have the Invoice total amount with VAT (BT-112).
			</assert>
			
			<!-- BR-15: Amount due for payment -->
			<assert id="MO-BR-15" test="exists(cbc:PayableAmount)" flag="fatal">
				[MO-BR-15] An Invoice shall have the Amount due for payment (BT-115).
			</assert>
			
			<!-- BR-DEC-09: Decimal precision for line extension amount -->
			<assert id="MO-BR-DEC-09" test="string-length(substring-after(cbc:LineExtensionAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-09] The allowed maximum number of decimals for the Sum of Invoice line net amount (BT-106) is 2.
			</assert>
			
			<!-- BR-DEC-10: Decimal precision for allowance total -->
			<assert id="MO-BR-DEC-10" test="string-length(substring-after(cbc:AllowanceTotalAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-10] The allowed maximum number of decimals for the Sum of allowances on document level (BT-107) is 2.
			</assert>
			
			<!-- BR-DEC-11: Decimal precision for charge total -->
			<assert id="MO-BR-DEC-11" test="string-length(substring-after(cbc:ChargeTotalAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-11] The allowed maximum number of decimals for the Sum of charges on document level (BT-108) is 2.
			</assert>
			
			<!-- BR-DEC-12: Decimal precision for tax exclusive amount -->
			<assert id="MO-BR-DEC-12" test="string-length(substring-after(cbc:TaxExclusiveAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-12] The allowed maximum number of decimals for the Invoice total amount without VAT (BT-109) is 2.
			</assert>
			
			<!-- BR-DEC-14: Decimal precision for tax inclusive amount -->
			<assert id="MO-BR-DEC-14" test="string-length(substring-after(cbc:TaxInclusiveAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-14] The allowed maximum number of decimals for the Invoice total amount with VAT (BT-112) is 2.
			</assert>
			
			<!-- BR-DEC-16: Decimal precision for prepaid amount -->
			<assert id="MO-BR-DEC-16" test="string-length(substring-after(cbc:PrepaidAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-16] The allowed maximum number of decimals for the Paid amount (BT-113) is 2.
			</assert>
			
			<!-- BR-DEC-17: Decimal precision for rounding amount -->
			<assert id="MO-BR-DEC-17" test="string-length(substring-after(cbc:PayableRoundingAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-17] The allowed maximum number of decimals for the Rounding amount (BT-114) is 2.
			</assert>
			
			<!-- BR-DEC-18: Decimal precision for payable amount -->
			<assert id="MO-BR-DEC-18" test="string-length(substring-after(cbc:PayableAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-18] The allowed maximum number of decimals for the Amount due for payment (BT-115) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 4: Consistency Rules (BR-CO-XX) -->
	<pattern id="MO-consistency-rules">
		<rule context="/ubl-invoice:Invoice | /cn:CreditNote">
			<!-- BR-CO-10: Sum of line net amounts -->
			<assert id="MO-BR-CO-10" test="(xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) = xs:decimal(round(sum(//(cac:InvoiceLine|cac:CreditNoteLine)/xs:decimal(cbc:LineExtensionAmount)) * 10 * 10) div 100))" flag="fatal">
				[MO-BR-CO-10] Sum of Invoice line net amount (BT-106) = Σ Invoice line net amount (BT-131).
			</assert>
			
			<!-- BR-CO-11: Sum of allowances -->
			<assert id="MO-BR-CO-11" test="xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) = (round(sum(cac:AllowanceCharge[cbc:ChargeIndicator=false()]/xs:decimal(cbc:Amount)) * 10 * 10) div 100) or (not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and not(cac:AllowanceCharge[cbc:ChargeIndicator=false()]))" flag="fatal">
				[MO-BR-CO-11] Sum of allowances on document level (BT-107) = Σ Document level allowance amount (BT-92).
			</assert>
			
			<!-- BR-CO-12: Sum of charges -->
			<assert id="MO-BR-CO-12" test="xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) = (round(sum(cac:AllowanceCharge[cbc:ChargeIndicator=true()]/xs:decimal(cbc:Amount)) * 10 * 10) div 100) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:AllowanceCharge[cbc:ChargeIndicator=true()]))" flag="fatal">
				[MO-BR-CO-12] Sum of charges on document level (BT-108) = Σ Document level charge amount (BT-99).
			</assert>
			
			<!-- BR-CO-13: Tax exclusive amount calculation -->
			<assert id="MO-BR-CO-13" test="((cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and (cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) + xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount)) * 10 * 10) div 100 )) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and (cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount)) * 10 * 10 ) div 100)) or ((cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) + xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount)) * 10 * 10 ) div 100)) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount)))" flag="fatal">
				[MO-BR-CO-13] Invoice total amount without VAT (BT-109) = Σ Invoice line net amount (BT-131) - Sum of allowances on document level (BT-107) + Sum of charges on document level (BT-108).
			</assert>
			
			<!-- BR-CO-15: Tax inclusive amount calculation -->
			<assert id="MO-BR-CO-15" test="every $Currency in cbc:DocumentCurrencyCode satisfies (count(cac:TaxTotal/xs:decimal(cbc:TaxAmount[@currencyID=$Currency])) eq 1) and (cac:LegalMonetaryTotal/xs:decimal(cbc:TaxInclusiveAmount) = round( (cac:LegalMonetaryTotal/xs:decimal(cbc:TaxExclusiveAmount) + cac:TaxTotal/xs:decimal(cbc:TaxAmount[@currencyID=$Currency])) * 10 * 10) div 100)" flag="fatal">
				[MO-BR-CO-15] Invoice total amount with VAT (BT-112) = Invoice total amount without VAT (BT-109) + Invoice total VAT amount (BT-110).
			</assert>
			
			<!-- BR-CO-16: Payable amount calculation -->
			<assert id="MO-BR-CO-16" test="(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount) and not(exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) and (xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) = (round((xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) * 10 * 10) div 100))) or (not(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) and not(exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) and xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) = xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount)) or (exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount) and exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount) and ((round((xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) * 10 * 10) div 100) = (round((xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) * 10 * 10) div 100))) or (not(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) and exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount) and ((round((xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) * 10 * 10) div 100) = xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount)))" flag="fatal">
				[MO-BR-CO-16] Amount due for payment (BT-115) = Invoice total amount with VAT (BT-112) - Paid amount (BT-113) + Rounding amount (BT-114).
			</assert>
			
			<!-- BR-CO-18: At least one VAT breakdown -->
			<assert id="MO-BR-CO-18" test="exists(cac:TaxTotal/cac:TaxSubtotal)" flag="fatal">
				[MO-BR-CO-18] An Invoice shall at least have one VAT breakdown group (BG-23).
			</assert>
		</rule>
		
		<rule context="/ubl-invoice:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount | /cn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount">
			<!-- BR-CO-25: Payment terms when amount is positive -->
			<assert id="MO-BR-CO-25" test="((. > 0) and (exists(//cbc:DueDate) or exists(//cac:PaymentTerms/cbc:Note))) or (. &lt;= 0)" flag="fatal">
				[MO-BR-CO-25] In case the Amount due for payment (BT-115) is positive, either the Payment due date (BT-9) or the Payment terms (BT-20) shall be present.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 5: Document Level Allowances (BR-31 to BR-33) -->
	<pattern id="MO-document-allowances">
		<rule context="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:ChargeIndicator = false()] | /cn:CreditNote/cac:AllowanceCharge[cbc:ChargeIndicator = false()]">
			<!-- BR-31: Allowance amount -->
			<assert id="MO-BR-31" test="exists(cbc:Amount)" flag="fatal">
				[MO-BR-31] Each Document level allowance (BG-20) shall have a Document level allowance amount (BT-92).
			</assert>
			
			<!-- BR-32: Allowance VAT category code -->
			<assert id="MO-BR-32" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID)" flag="fatal">
				[MO-BR-32] Each Document level allowance (BG-20) shall have a Document level allowance VAT category code (BT-95).
			</assert>
			
			<!-- BR-33: Allowance reason -->
			<assert id="MO-BR-33" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" flag="fatal">
				[MO-BR-33] Each Document level allowance (BG-20) shall have a Document level allowance reason (BT-97) or a Document level allowance reason code (BT-98).
			</assert>
			
			<!-- BR-DEC-01: Decimal precision for allowance amount -->
			<assert id="MO-BR-DEC-01" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-01] The allowed maximum number of decimals for the Document level allowance amount (BT-92) is 2.
			</assert>
			
			<!-- BR-DEC-02: Decimal precision for allowance base amount -->
			<assert id="MO-BR-DEC-02" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-02] The allowed maximum number of decimals for the Document level allowance base amount (BT-93) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 6: Document Level Charges (BR-36 to BR-38) -->
	<pattern id="MO-document-charges">
		<rule context="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:ChargeIndicator = true()] | /cn:CreditNote/cac:AllowanceCharge[cbc:ChargeIndicator = true()]">
			<!-- BR-36: Charge amount -->
			<assert id="MO-BR-36" test="exists(cbc:Amount)" flag="fatal">
				[MO-BR-36] Each Document level charge (BG-21) shall have a Document level charge amount (BT-99).
			</assert>
			
			<!-- BR-37: Charge VAT category code -->
			<assert id="MO-BR-37" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID)" flag="fatal">
				[MO-BR-37] Each Document level charge (BG-21) shall have a Document level charge VAT category code (BT-102).
			</assert>
			
			<!-- BR-38: Charge reason -->
			<assert id="MO-BR-38" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" flag="fatal">
				[MO-BR-38] Each Document level charge (BG-21) shall have a Document level charge reason (BT-104) or a Document level charge reason code (BT-105).
			</assert>
			
			<!-- BR-DEC-05: Decimal precision for charge amount -->
			<assert id="MO-BR-DEC-05" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-05] The allowed maximum number of decimals for the Document level charge amount (BT-99) is 2.
			</assert>
			
			<!-- BR-DEC-06: Decimal precision for charge base amount -->
			<assert id="MO-BR-DEC-06" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-06] The allowed maximum number of decimals for the Document level charge base amount (BT-100) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 7: Additional Document Reference (BR-52) -->
	<pattern id="MO-additional-document">
		<rule context="cac:AdditionalDocumentReference">
			<!-- BR-52: Supporting document reference -->
			<assert id="MO-BR-52" test="normalize-space(cbc:ID) != ''" flag="fatal">
				[MO-BR-52] Each Additional supporting document (BG-24) shall contain a Supporting document reference (BT-122).
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 8: Delivery Location (BR-57) -->
	<pattern id="MO-delivery">
		<rule context="cac:Delivery/cac:DeliveryLocation/cac:Address">
			<!-- BR-57: Deliver to country code -->
			<assert id="MO-BR-57" test="exists(cac:Country/cbc:IdentificationCode)" flag="fatal">
				[MO-BR-57] Each Deliver to address (BG-15) shall contain a Deliver to country code (BT-80).
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 9: Invoice Line Level Rules (BR-21 to BR-28) -->
	<pattern id="MO-invoice-line">
		<rule context="cac:InvoiceLine | cac:CreditNoteLine">
			<!-- BR-21: Line identifier -->
			<assert id="MO-BR-21" test="normalize-space(cbc:ID) != ''" flag="fatal">
				[MO-BR-21] Each Invoice line (BG-25) shall have an Invoice line identifier (BT-126).
			</assert>
			
			<!-- BR-22: Invoiced quantity -->
			<assert id="MO-BR-22" test="exists(cbc:InvoicedQuantity) or exists(cbc:CreditedQuantity)" flag="fatal">
				[MO-BR-22] Each Invoice line (BG-25) shall have an Invoiced quantity (BT-129).
			</assert>
			
			<!-- BR-23: Quantity unit of measure -->
			<assert id="MO-BR-23" test="exists(cbc:InvoicedQuantity/@unitCode) or exists(cbc:CreditedQuantity/@unitCode)" flag="fatal">
				[MO-BR-23] An Invoice line (BG-25) shall have an Invoiced quantity unit of measure code (BT-130).
			</assert>
			
			<!-- BR-24: Line net amount -->
			<assert id="MO-BR-24" test="exists(cbc:LineExtensionAmount)" flag="fatal">
				[MO-BR-24] Each Invoice line (BG-25) shall have an Invoice line net amount (BT-131).
			</assert>
			
			<!-- BR-25: Item name -->
			<assert id="MO-BR-25" test="normalize-space(cac:Item/cbc:Name) != ''" flag="fatal">
				[MO-BR-25] Each Invoice line (BG-25) shall contain the Item name (BT-153).
			</assert>
			
			<!-- BR-26: Item net price -->
			<assert id="MO-BR-26" test="exists(cac:Price/cbc:PriceAmount)" flag="fatal">
				[MO-BR-26] Each Invoice line (BG-25) shall contain the Item net price (BT-146).
			</assert>
			
			<!-- BR-27: Item net price not negative -->
			<assert id="MO-BR-27" test="(cac:Price/cbc:PriceAmount) >= 0" flag="fatal">
				[MO-BR-27] The Item net price (BT-146) shall NOT be negative.
			</assert>
			
			<!-- BR-28: Item gross price not negative -->
			<assert id="MO-BR-28" test="(cac:Price/cac:AllowanceCharge/cbc:BaseAmount) >= 0 or not(exists(cac:Price/cac:AllowanceCharge/cbc:BaseAmount))" flag="fatal">
				[MO-BR-28] The Item gross price (BT-148) shall NOT be negative.
			</assert>
			
			<!-- BR-CO-04: VAT category code -->
			<assert id="MO-BR-CO-04" test="(cac:Item/cac:ClassifiedTaxCategory[cac:TaxScheme/(normalize-space(upper-case(cbc:ID))='VAT')]/cbc:ID)" flag="fatal">
				[MO-BR-CO-04] Each Invoice line (BG-25) shall be categorized with an Invoiced item VAT category code (BT-151).
			</assert>
			
			<!-- BR-DEC-23: Decimal precision for line net amount -->
			<assert id="MO-BR-DEC-23" test="string-length(substring-after(cbc:LineExtensionAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-23] The allowed maximum number of decimals for the Invoice line net amount (BT-131) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 10: Invoice Line Allowances (BR-41 to BR-42) -->
	<pattern id="MO-line-allowances">
		<rule context="//cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator = false()] | //cac:CreditNoteLine/cac:AllowanceCharge[cbc:ChargeIndicator = false()]">
			<!-- BR-41: Line allowance amount -->
			<assert id="MO-BR-41" test="exists(cbc:Amount)" flag="fatal">
				[MO-BR-41] Each Invoice line allowance (BG-27) shall have an Invoice line allowance amount (BT-136).
			</assert>
			
			<!-- BR-42: Line allowance reason -->
			<assert id="MO-BR-42" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" flag="fatal">
				[MO-BR-42] Each Invoice line allowance (BG-27) shall have an Invoice line allowance reason (BT-139) or an Invoice line allowance reason code (BT-140).
			</assert>
			
			<!-- BR-DEC-24: Decimal precision for line allowance amount -->
			<assert id="MO-BR-DEC-24" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-24] The allowed maximum number of decimals for the Invoice line allowance amount (BT-136) is 2.
			</assert>
			
			<!-- BR-DEC-25: Decimal precision for line allowance base amount -->
			<assert id="MO-BR-DEC-25" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-25] The allowed maximum number of decimals for the Invoice line allowance base amount (BT-137) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 11: Invoice Line Charges (BR-43 to BR-44) -->
	<pattern id="MO-line-charges">
		<rule context="//cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator = true()] | //cac:CreditNoteLine/cac:AllowanceCharge[cbc:ChargeIndicator = true()]">
			<!-- BR-43: Line charge amount -->
			<assert id="MO-BR-43" test="exists(cbc:Amount)" flag="fatal">
				[MO-BR-43] Each Invoice line charge (BG-28) shall have an Invoice line charge amount (BT-141).
			</assert>
			
			<!-- BR-44: Line charge reason -->
			<assert id="MO-BR-44" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" flag="fatal">
				[MO-BR-44] Each Invoice line charge (BG-28) shall have an Invoice line charge reason (BT-144) or an Invoice line charge reason code (BT-145).
			</assert>
			
			<!-- BR-DEC-27: Decimal precision for line charge amount -->
			<assert id="MO-BR-DEC-27" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-27] The allowed maximum number of decimals for the Invoice line charge amount (BT-141) is 2.
			</assert>
			
			<!-- BR-DEC-28: Decimal precision for line charge base amount -->
			<assert id="MO-BR-DEC-28" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" flag="fatal">
				[MO-BR-DEC-28] The allowed maximum number of decimals for the Invoice line charge base amount (BT-142) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 12: Price Level Allowance (BR-46) -->
	<pattern id="MO-price-allowance">
		<rule context="cac:Price/cac:AllowanceCharge">
			<!-- BR-46: Item net price calculation -->
			<assert id="MO-BR-46" test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)" flag="fatal">
				[MO-BR-46] Item net price MUST equal (Gross price - Allowance amount) when gross price is provided.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 13: Tax Total and Decimal Rules -->
	<pattern id="MO-tax-total">
		<rule context="/ubl-invoice:Invoice | /cn:CreditNote">
			<!-- BR-DEC-13: Decimal precision for tax amount in document currency -->
			<assert id="MO-BR-DEC-13" test="(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode] and (string-length(substring-after(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode],'.'))&lt;=2)) or (not(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode]))" flag="fatal">
				[MO-BR-DEC-13] The allowed maximum number of decimals for the Invoice total VAT amount (BT-110) is 2.
			</assert>
			
			<!-- BR-DEC-15: Decimal precision for tax amount in accounting currency -->
			<assert id="MO-BR-DEC-15" test="(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode] and (string-length(substring-after(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode],'.'))&lt;=2)) or (not(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode]))" flag="fatal">
				[MO-BR-DEC-15] The allowed maximum number of decimals for the Invoice total VAT amount in accounting currency (BT-111) is 2.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 14: Price Decimal Rules -->
	<pattern id="MO-price-decimals">
		<rule context="//cac:Price/cbc:PriceAmount">
			<!-- BR-DEC-29: Decimal precision for item net price -->
			<assert id="MO-BR-DEC-29" test="string-length(substring-after(.,'.'))&lt;=4" flag="fatal">
				[MO-BR-DEC-29] The allowed maximum number of decimals for the Item net price (BT-146) is 4.
			</assert>
		</rule>
		
		<rule context="//cac:Price/cac:AllowanceCharge/cbc:BaseAmount">
			<!-- BR-DEC-30: Decimal precision for item gross price -->
			<assert id="MO-BR-DEC-30" test="string-length(substring-after(.,'.'))&lt;=4" flag="fatal">
				[MO-BR-DEC-30] The allowed maximum number of decimals for the Item gross price (BT-148) is 4.
			</assert>
		</rule>
		
		<rule context="//cac:Price/cac:AllowanceCharge/cbc:Amount">
			<!-- BR-DEC-31: Decimal precision for item price discount -->
			<assert id="MO-BR-DEC-31" test="string-length(substring-after(.,'.'))&lt;=4" flag="fatal">
				[MO-BR-DEC-31] The allowed maximum number of decimals for the Item price discount (BT-147) is 4.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 15: Tax Currency Code Rules -->
	<pattern id="MO-tax-currency">
		<rule context="cbc:TaxCurrencyCode">
			<!-- Tax currency must be different from document currency when provided -->
			<assert id="MO-R-TAX-01" test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))" flag="fatal">
				[MO-R-TAX-01] VAT accounting currency code (cbc:TaxCurrencyCode) MUST be different from invoice currency code (cbc:DocumentCurrencyCode) when provided.
			</assert>
		</rule>
		
		<rule context="/ubl-invoice:Invoice | /cn:CreditNote">
			<!-- BR-53: Tax amount in accounting currency when tax currency provided -->
			<assert id="MO-BR-53" test="every $taxcurrency in cbc:TaxCurrencyCode satisfies exists(//cac:TaxTotal/cbc:TaxAmount[@currencyID=$taxcurrency])" flag="fatal">
				[MO-BR-53] If the VAT accounting currency code (BT-6) is present, then the Invoice total VAT amount in accounting currency (BT-111) shall be provided.
			</assert>
			
			<!-- Only one tax total with subtotals -->
			<assert id="MO-R-TAX-02" test="count(cac:TaxTotal[cac:TaxSubtotal]) = 1" flag="fatal">
				[MO-R-TAX-02] Only one tax total with tax subtotals MUST be provided.
			</assert>
			
			<!-- Tax total without subtotals when TaxCurrencyCode provided -->
			<assert id="MO-R-TAX-03" test="count(cac:TaxTotal[not(cac:TaxSubtotal)]) = (if (cbc:TaxCurrencyCode) then 1 else 0)" flag="fatal">
				[MO-R-TAX-03] Only one tax total without tax subtotals MUST be provided when tax currency code is provided.
			</assert>
			
			<!-- Tax amount sign consistency -->
			<assert id="MO-R-TAX-04" test="not(cbc:TaxCurrencyCode) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] &lt;= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] &lt;= 0) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] &gt;= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] &gt;= 0)" flag="fatal">
				[MO-R-TAX-04] Invoice total VAT amount and Invoice total VAT amount in accounting currency MUST have the same operational sign.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 16: Currency Consistency -->
	<pattern id="MO-currency-consistency">
		<rule context="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cac:TaxTotal[cac:TaxSubtotal]/cbc:TaxAmount | cac:TaxSubtotal/cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount">
			<!-- All currency IDs must match document currency (except tax in accounting currency) -->
			<assert id="MO-R-CURR-01" test="@currencyID = /*/cbc:DocumentCurrencyCode" flag="fatal">
				[MO-R-CURR-01] All currencyID attributes must have the same value as the invoice currency code (cbc:DocumentCurrencyCode), except for the invoice total VAT amount in accounting currency.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 17: Allowance/Charge Calculation Rules -->
	<pattern id="MO-allowance-charge-calculation">
		<rule context="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | /cn:CreditNote/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]">
			<!-- Base amount required when percentage provided -->
			<assert id="MO-R-AC-01" test="false()" flag="fatal">
				[MO-R-AC-01] Allowance/charge base amount (cbc:BaseAmount) MUST be provided when allowance/charge percentage (cbc:MultiplierFactorNumeric) is provided.
			</assert>
		</rule>
		
		<rule context="/ubl-invoice:Invoice/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | /cn:CreditNote/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]">
			<!-- Percentage required when base amount provided -->
			<assert id="MO-R-AC-02" test="false()" flag="fatal">
				[MO-R-AC-02] Allowance/charge percentage (cbc:MultiplierFactorNumeric) MUST be provided when allowance/charge base amount (cbc:BaseAmount) is provided.
			</assert>
		</rule>
		
		<rule context="/ubl-invoice:Invoice/cac:AllowanceCharge | /cn:CreditNote/cac:AllowanceCharge">
			<!-- ChargeIndicator must be true or false -->
			<assert id="MO-R-AC-03" test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'" flag="fatal">
				[MO-R-AC-03] Allowance/charge ChargeIndicator value MUST equal 'true' or 'false'.
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 18: Credit Note Specific Rules -->
	<pattern id="MO-creditnote">
		<rule context="cn:CreditNote">
			<!-- Credit note must contain invoice reference -->
			<assert id="MO-R-CN-01" test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID" flag="fatal">
				[MO-R-CN-01] For credit note, the document MUST contain an invoice reference (cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID).
			</assert>
		</rule>
	</pattern>
	
	<!-- Pattern 19: Party Tax Scheme Validation -->
	<!-- 注释原因: 为了支持个人发票，税号不应强制要求必填 -->
	<!-- Commented out to support individual invoices where tax ID may not be available -->
	<!--
	<pattern id="MO-party-tax-scheme">
		<rule context="/ubl-invoice:Invoice | /cn:CreditNote">
			<!-- BR-CO-26: Supplier PartyTaxScheme -->
			<assert id="MO-BR-CO-26" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme)" flag="fatal">
				[MO-BR-CO-26] An Invoice shall contain the Supplier party tax scheme (BG-11).
			</assert>

			<!-- BR-CO-27: Customer PartyTaxScheme -->
			<assert id="MO-BR-CO-27" test="exists(cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme)" flag="fatal">
				[MO-BR-CO-27] An Invoice shall contain the Customer party tax scheme (BG-12).
			</assert>
		</rule>

		<rule context="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme">
			<!-- Supplier tax registration identifier -->
			<assert id="MO-R-TAX-05" test="normalize-space(cbc:CompanyID) != ''" flag="fatal">
				[MO-R-TAX-05] Supplier party tax scheme shall contain a Company ID (tax registration identifier).
			</assert>

			<!-- Supplier tax scheme ID must be 'TAX' -->
			<assert id="MO-R-TAX-06" test="normalize-space(cac:TaxScheme/cbc:ID) = 'TAX'" flag="fatal">
				[MO-R-TAX-06] Supplier party tax scheme ID shall be 'TAX'.
			</assert>
		</rule>

		<rule context="cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme">
			<!-- Customer tax registration identifier -->
			<assert id="MO-R-TAX-07" test="normalize-space(cbc:CompanyID) != ''" flag="fatal">
				[MO-R-TAX-07] Customer party tax scheme shall contain a Company ID (tax registration identifier).
			</assert>

			<!-- Customer tax scheme ID must be 'TAX' -->
			<assert id="MO-R-TAX-08" test="normalize-space(cac:TaxScheme/cbc:ID) = 'TAX'" flag="fatal">
				[MO-R-TAX-08] Customer party tax scheme ID shall be 'TAX'.
			</assert>
		</rule>
	</pattern>
	-->
	
</schema>
