<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:transform xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:ubl-invoice="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" xmlns:cn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" version="2.0">
	<!--Implementers: please note that overriding process-prolog or process-root is
        the preferred method for meta-stylesheets to use where possible. -->

	<xsl:param name="archiveDirParameter" />
	<xsl:param name="archiveNameParameter" />
	<xsl:param name="fileNameParameter" />
	<xsl:param name="fileDirParameter" />
	<xsl:variable name="document-uri">
		<xsl:value-of select="document-uri(/)" />
	</xsl:variable>

	<!--PHASES-->


	<!--PROLOG-->
	<xsl:output indent="yes" method="xml" omit-xml-declaration="no" standalone="yes" />

	<!--XSD TYPES FOR XSLT2-->


	<!--KEYS AND FUNCTIONS-->


	<!--DEFAULT RULES-->


	<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
	<!--This mode can be used to generate an ugly though full XPath for locators-->
	<xsl:template match="*" mode="schematron-select-full-path">
		<xsl:apply-templates mode="schematron-get-full-path" select="." />
	</xsl:template>

	<!--MODE: SCHEMATRON-FULL-PATH-->
	<!--This mode can be used to generate an ugly though full XPath for locators-->
	<xsl:template match="*" mode="schematron-get-full-path">
		<xsl:apply-templates mode="schematron-get-full-path" select="parent::*" />
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="namespace-uri()=''">
				<xsl:value-of select="name()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>*:</xsl:text>
				<xsl:value-of select="local-name()" />
				<xsl:text>[namespace-uri()='</xsl:text>
				<xsl:value-of select="namespace-uri()" />
				<xsl:text>']</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])" />
		<xsl:text>[</xsl:text>
		<xsl:value-of select="1+ $preceding" />
		<xsl:text>]</xsl:text>
	</xsl:template>
	<xsl:template match="@*" mode="schematron-get-full-path">
		<xsl:apply-templates mode="schematron-get-full-path" select="parent::*" />
		<xsl:text>/</xsl:text>
		<xsl:choose>
			<xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>@*[local-name()='</xsl:text>
				<xsl:value-of select="local-name()" />
				<xsl:text>' and namespace-uri()='</xsl:text>
				<xsl:value-of select="namespace-uri()" />
				<xsl:text>']</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--MODE: SCHEMATRON-FULL-PATH-2-->
	<!--This mode can be used to generate prefixed XPath for humans-->
	<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
		<xsl:for-each select="ancestor-or-self::*">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="name(.)" />
			<xsl:if test="preceding-sibling::*[name(.)=name(current())]">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="not(self::*)">
			<text />/@<xsl:value-of select="name(.)" />
		</xsl:if>
	</xsl:template>
	<!--MODE: SCHEMATRON-FULL-PATH-3-->
	<!--This mode can be used to generate prefixed XPath for humans
        (Top-level element has index)-->

	<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
		<xsl:for-each select="ancestor-or-self::*">
			<xsl:text>/</xsl:text>
			<xsl:value-of select="name(.)" />
			<xsl:if test="parent::*">
				<xsl:text>[</xsl:text>
				<xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="not(self::*)">
			<text />/@<xsl:value-of select="name(.)" />
		</xsl:if>
	</xsl:template>

	<!--MODE: GENERATE-ID-FROM-PATH -->
	<xsl:template match="/" mode="generate-id-from-path" />
	<xsl:template match="text()" mode="generate-id-from-path">
		<xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
		<xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')" />
	</xsl:template>
	<xsl:template match="comment()" mode="generate-id-from-path">
		<xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
		<xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')" />
	</xsl:template>
	<xsl:template match="processing-instruction()" mode="generate-id-from-path">
		<xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
		<xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')" />
	</xsl:template>
	<xsl:template match="@*" mode="generate-id-from-path">
		<xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
		<xsl:value-of select="concat('.@', name())" />
	</xsl:template>
	<xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
		<xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')" />
	</xsl:template>

	<!--MODE: GENERATE-ID-2 -->
	<xsl:template match="/" mode="generate-id-2">U</xsl:template>
	<xsl:template match="*" mode="generate-id-2" priority="2">
		<xsl:text>U</xsl:text>
		<xsl:number count="*" level="multiple" />
	</xsl:template>
	<xsl:template match="node()" mode="generate-id-2">
		<xsl:text>U.</xsl:text>
		<xsl:number count="*" level="multiple" />
		<xsl:text>n</xsl:text>
		<xsl:number count="node()" />
	</xsl:template>
	<xsl:template match="@*" mode="generate-id-2">
		<xsl:text>U.</xsl:text>
		<xsl:number count="*" level="multiple" />
		<xsl:text>_</xsl:text>
		<xsl:value-of select="string-length(local-name(.))" />
		<xsl:text>_</xsl:text>
		<xsl:value-of select="translate(name(),':','.')" />
	</xsl:template>
	<!--Strip characters-->  <xsl:template match="text()" priority="-1" />

	<!--SCHEMA SETUP-->
	<xsl:template match="/">
		<ns0:schematron-output xmlns:ns0="http://purl.oclc.org/dsdl/svrl" schemaVersion="iso" title="Hong Kong KDUBL Invoice Validation Rules (Based on EN16931)">
			<xsl:comment>
				<xsl:value-of select="$archiveDirParameter" />   
				<xsl:value-of select="$archiveNameParameter" />  
				<xsl:value-of select="$fileNameParameter" />  
				<xsl:value-of select="$fileDirParameter" />
			</xsl:comment>
			<ns0:ns-prefix-in-attribute-values prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" />
			<ns0:ns-prefix-in-attribute-values prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" />
			<ns0:ns-prefix-in-attribute-values prefix="cn" uri="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" />
			<ns0:ns-prefix-in-attribute-values prefix="ubl-invoice" uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" />
			<ns0:ns-prefix-in-attribute-values prefix="xs" uri="http://www.w3.org/2001/XMLSchema" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-document-level</xsl:attribute>
				<xsl:attribute name="name">HK-document-level</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M6" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-party-address</xsl:attribute>
				<xsl:attribute name="name">HK-party-address</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M7" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-monetary-total</xsl:attribute>
				<xsl:attribute name="name">HK-monetary-total</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M8" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-consistency-rules</xsl:attribute>
				<xsl:attribute name="name">HK-consistency-rules</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M9" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-document-allowances</xsl:attribute>
				<xsl:attribute name="name">HK-document-allowances</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M10" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-document-charges</xsl:attribute>
				<xsl:attribute name="name">HK-document-charges</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M11" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-additional-document</xsl:attribute>
				<xsl:attribute name="name">HK-additional-document</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M12" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-delivery</xsl:attribute>
				<xsl:attribute name="name">HK-delivery</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M13" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-invoice-line</xsl:attribute>
				<xsl:attribute name="name">HK-invoice-line</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M14" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-line-allowances</xsl:attribute>
				<xsl:attribute name="name">HK-line-allowances</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M15" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-line-charges</xsl:attribute>
				<xsl:attribute name="name">HK-line-charges</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M16" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-price-allowance</xsl:attribute>
				<xsl:attribute name="name">HK-price-allowance</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M17" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-tax-total</xsl:attribute>
				<xsl:attribute name="name">HK-tax-total</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M18" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-price-decimals</xsl:attribute>
				<xsl:attribute name="name">HK-price-decimals</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M19" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-tax-currency</xsl:attribute>
				<xsl:attribute name="name">HK-tax-currency</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M20" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-currency-consistency</xsl:attribute>
				<xsl:attribute name="name">HK-currency-consistency</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M21" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-allowance-charge-calculation</xsl:attribute>
				<xsl:attribute name="name">HK-allowance-charge-calculation</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M22" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-creditnote</xsl:attribute>
				<xsl:attribute name="name">HK-creditnote</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M23" select="/" />
			<ns0:active-pattern>
				<xsl:attribute name="document">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="documents">
					<xsl:value-of select="document-uri(/)" />
				</xsl:attribute>
				<xsl:attribute name="id">HK-party-legal-entity</xsl:attribute>
				<xsl:attribute name="name">HK-party-legal-entity</xsl:attribute>
				<xsl:apply-templates />
			</ns0:active-pattern>
			<xsl:apply-templates mode="M24" select="/" />
		</ns0:schematron-output>
	</xsl:template>

	<!--SCHEMATRON PATTERNS-->
	<ns0:text xmlns:ns0="http://purl.oclc.org/dsdl/svrl">Hong Kong KDUBL Invoice Validation Rules (Based on EN16931)</ns0:text>

	<!--PATTERN HK-document-level-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice | /cn:CreditNote" mode="M6" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice | /cn:CreditNote" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:CustomizationID) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:CustomizationID) != ''">
					<xsl:attribute name="id">HK-BR-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-01] An Invoice shall have a Specification identifier (BT-24).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:ID) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID) != ''">
					<xsl:attribute name="id">HK-BR-02</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-02] An Invoice shall have an Invoice number (BT-1).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:IssueDate) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:IssueDate) != ''">
					<xsl:attribute name="id">HK-BR-03</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-03] An Invoice shall have an Invoice issue date (BT-2).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:InvoiceTypeCode) != '' or normalize-space(cbc:CreditNoteTypeCode) !=''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:InvoiceTypeCode) != '' or normalize-space(cbc:CreditNoteTypeCode) !=''">
					<xsl:attribute name="id">HK-BR-04</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-04] An Invoice shall have an Invoice type code (BT-3).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:DocumentCurrencyCode) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:DocumentCurrencyCode) != ''">
					<xsl:attribute name="id">HK-BR-05</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-05] An Invoice shall have an Invoice currency code (BT-5).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName) != ''">
					<xsl:attribute name="id">HK-BR-06</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-06] An Invoice shall contain the Seller name (BT-27).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName) != ''">
					<xsl:attribute name="id">HK-BR-07</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-07] An Invoice shall contain the Buyer name (BT-44).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress)">
					<xsl:attribute name="id">HK-BR-08</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-08] An Invoice shall contain the Seller postal address.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress)">
					<xsl:attribute name="id">HK-BR-10</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-10] An Invoice shall contain the Buyer postal address (BG-8).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:InvoiceLine) or exists(cac:CreditNoteLine)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:InvoiceLine) or exists(cac:CreditNoteLine)">
					<xsl:attribute name="id">HK-BR-16</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-16] An Invoice shall have at least one Invoice line (BG-25).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M6" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M6" priority="-1" />
	<xsl:template match="@*|node()" mode="M6" priority="-2">
		<xsl:apply-templates mode="M6" select="*" />
	</xsl:template>

	<!--PATTERN HK-party-address-->


	<!--RULE -->
	<xsl:template match="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress" mode="M7" priority="1001">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cac:Country/cbc:IdentificationCode) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cac:Country/cbc:IdentificationCode) != ''">
					<xsl:attribute name="id">HK-BR-09</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-09] The Seller postal address shall contain a Seller country code (BT-40).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M7" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress" mode="M7" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cac:Country/cbc:IdentificationCode) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cac:Country/cbc:IdentificationCode) != ''">
					<xsl:attribute name="id">HK-BR-11</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-11] The Buyer postal address shall contain a Buyer country code (BT-55).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M7" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M7" priority="-1" />
	<xsl:template match="@*|node()" mode="M7" priority="-2">
		<xsl:apply-templates mode="M7" select="*" />
	</xsl:template>

	<!--PATTERN HK-monetary-total-->


	<!--RULE -->
	<xsl:template match="cac:LegalMonetaryTotal" mode="M8" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:LegalMonetaryTotal" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:LineExtensionAmount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:LineExtensionAmount)">
					<xsl:attribute name="id">HK-BR-12</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-12] An Invoice shall have the Sum of Invoice line net amount (BT-106).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:TaxExclusiveAmount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:TaxExclusiveAmount)">
					<xsl:attribute name="id">HK-BR-13</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-13] An Invoice shall have the Invoice total amount without VAT (BT-109).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:TaxInclusiveAmount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:TaxInclusiveAmount)">
					<xsl:attribute name="id">HK-BR-14</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-14] An Invoice shall have the Invoice total amount with VAT (BT-112).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:PayableAmount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:PayableAmount)">
					<xsl:attribute name="id">HK-BR-15</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-15] An Invoice shall have the Amount due for payment (BT-115).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:LineExtensionAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:LineExtensionAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-09</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-09] The allowed maximum number of decimals for the Sum of Invoice line net amount (BT-106) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:AllowanceTotalAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:AllowanceTotalAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-10</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-10] The allowed maximum number of decimals for the Sum of allowances on document level (BT-107) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:ChargeTotalAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:ChargeTotalAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-11</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-11] The allowed maximum number of decimals for the Sum of charges on document level (BT-108) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:TaxExclusiveAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:TaxExclusiveAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-12</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-12] The allowed maximum number of decimals for the Invoice total amount without VAT (BT-109) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:TaxInclusiveAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:TaxInclusiveAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-14</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-14] The allowed maximum number of decimals for the Invoice total amount with VAT (BT-112) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:PrepaidAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:PrepaidAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-16</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-16] The allowed maximum number of decimals for the Paid amount (BT-113) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:PayableRoundingAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:PayableRoundingAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-17</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-17] The allowed maximum number of decimals for the Rounding amount (BT-114) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:PayableAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:PayableAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-18</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-18] The allowed maximum number of decimals for the Amount due for payment (BT-115) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M8" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M8" priority="-1" />
	<xsl:template match="@*|node()" mode="M8" priority="-2">
		<xsl:apply-templates mode="M8" select="*" />
	</xsl:template>

	<!--PATTERN HK-consistency-rules-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice | /cn:CreditNote" mode="M9" priority="1001">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice | /cn:CreditNote" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) = xs:decimal(round(sum(//(cac:InvoiceLine|cac:CreditNoteLine)/xs:decimal(cbc:LineExtensionAmount)) * 10 * 10) div 100))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) = xs:decimal(round(sum(//(cac:InvoiceLine|cac:CreditNoteLine)/xs:decimal(cbc:LineExtensionAmount)) * 10 * 10) div 100))">
					<xsl:attribute name="id">HK-BR-CO-10</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-10] Sum of Invoice line net amount (BT-106) = Σ Invoice line net amount (BT-131).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) = (round(sum(cac:AllowanceCharge[cbc:ChargeIndicator=false()]/xs:decimal(cbc:Amount)) * 10 * 10) div 100) or (not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and not(cac:AllowanceCharge[cbc:ChargeIndicator=false()]))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) = (round(sum(cac:AllowanceCharge[cbc:ChargeIndicator=false()]/xs:decimal(cbc:Amount)) * 10 * 10) div 100) or (not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and not(cac:AllowanceCharge[cbc:ChargeIndicator=false()]))">
					<xsl:attribute name="id">HK-BR-CO-11</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-11] Sum of allowances on document level (BT-107) = Σ Document level allowance amount (BT-92).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) = (round(sum(cac:AllowanceCharge[cbc:ChargeIndicator=true()]/xs:decimal(cbc:Amount)) * 10 * 10) div 100) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:AllowanceCharge[cbc:ChargeIndicator=true()]))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) = (round(sum(cac:AllowanceCharge[cbc:ChargeIndicator=true()]/xs:decimal(cbc:Amount)) * 10 * 10) div 100) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:AllowanceCharge[cbc:ChargeIndicator=true()]))">
					<xsl:attribute name="id">HK-BR-CO-12</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-12] Sum of charges on document level (BT-108) = Σ Document level charge amount (BT-99).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="((cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and (cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) + xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount)) * 10 * 10) div 100 )) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and (cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount)) * 10 * 10 ) div 100)) or ((cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) + xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount)) * 10 * 10 ) div 100)) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount)))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="((cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and (cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) + xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount)) * 10 * 10) div 100 )) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and (cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount)) * 10 * 10 ) div 100)) or ((cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = round((xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount) + xs:decimal(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount)) * 10 * 10 ) div 100)) or (not(cac:LegalMonetaryTotal/cbc:ChargeTotalAmount) and not(cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount) and (xs:decimal(cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount) = xs:decimal(cac:LegalMonetaryTotal/cbc:LineExtensionAmount)))">
					<xsl:attribute name="id">HK-BR-CO-13</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-13] Invoice total amount without VAT (BT-109) = Σ Invoice line net amount (BT-131) - Sum of allowances on document level (BT-107) + Sum of charges on document level (BT-108).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="every $Currency in cbc:DocumentCurrencyCode satisfies (count(cac:TaxTotal/xs:decimal(cbc:TaxAmount[@currencyID=$Currency])) eq 1) and (cac:LegalMonetaryTotal/xs:decimal(cbc:TaxInclusiveAmount) = round( (cac:LegalMonetaryTotal/xs:decimal(cbc:TaxExclusiveAmount) + cac:TaxTotal/xs:decimal(cbc:TaxAmount[@currencyID=$Currency])) * 10 * 10) div 100)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="every $Currency in cbc:DocumentCurrencyCode satisfies (count(cac:TaxTotal/xs:decimal(cbc:TaxAmount[@currencyID=$Currency])) eq 1) and (cac:LegalMonetaryTotal/xs:decimal(cbc:TaxInclusiveAmount) = round( (cac:LegalMonetaryTotal/xs:decimal(cbc:TaxExclusiveAmount) + cac:TaxTotal/xs:decimal(cbc:TaxAmount[@currencyID=$Currency])) * 10 * 10) div 100)">
					<xsl:attribute name="id">HK-BR-CO-15</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-15] Invoice total amount with VAT (BT-112) = Invoice total amount without VAT (BT-109) + Invoice total VAT amount (BT-110).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount) and not(exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) and (xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) = (round((xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) * 10 * 10) div 100))) or (not(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) and not(exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) and xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) = xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount)) or (exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount) and exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount) and ((round((xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) * 10 * 10) div 100) = (round((xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) * 10 * 10) div 100))) or (not(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) and exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount) and ((round((xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) * 10 * 10) div 100) = xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount)))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount) and not(exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) and (xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) = (round((xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) * 10 * 10) div 100))) or (not(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) and not(exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) and xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) = xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount)) or (exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount) and exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount) and ((round((xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) * 10 * 10) div 100) = (round((xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) * 10 * 10) div 100))) or (not(exists(cac:LegalMonetaryTotal/cbc:PrepaidAmount)) and exists(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount) and ((round((xs:decimal(cac:LegalMonetaryTotal/cbc:PayableAmount) - xs:decimal(cac:LegalMonetaryTotal/cbc:PayableRoundingAmount)) * 10 * 10) div 100) = xs:decimal(cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount)))">
					<xsl:attribute name="id">HK-BR-CO-16</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-16] Amount due for payment (BT-115) = Invoice total amount with VAT (BT-112) - Paid amount (BT-113) + Rounding amount (BT-114).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:TaxTotal/cac:TaxSubtotal)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:TaxTotal/cac:TaxSubtotal)">
					<xsl:attribute name="id">HK-BR-CO-18</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-18] An Invoice shall at least have one VAT breakdown group (BG-23).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M9" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount | /cn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount" mode="M9" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount | /cn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="((. > 0) and (exists(//cbc:DueDate) or exists(//cac:PaymentTerms/cbc:Note))) or (. &lt;= 0)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="((. > 0) and (exists(//cbc:DueDate) or exists(//cac:PaymentTerms/cbc:Note))) or (. &lt;= 0)">
					<xsl:attribute name="id">HK-BR-CO-25</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-25] In case the Amount due for payment (BT-115) is positive, either the Payment due date (BT-9) or the Payment terms (BT-20) shall be present.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M9" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M9" priority="-1" />
	<xsl:template match="@*|node()" mode="M9" priority="-2">
		<xsl:apply-templates mode="M9" select="*" />
	</xsl:template>

	<!--PATTERN HK-document-allowances-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:ChargeIndicator = false()] | /cn:CreditNote/cac:AllowanceCharge[cbc:ChargeIndicator = false()]" mode="M10" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:ChargeIndicator = false()] | /cn:CreditNote/cac:AllowanceCharge[cbc:ChargeIndicator = false()]" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:Amount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:Amount)">
					<xsl:attribute name="id">HK-BR-31</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-31] Each Document level allowance (BG-20) shall have a Document level allowance amount (BT-92).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID)">
					<xsl:attribute name="id">HK-BR-32</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-32] Each Document level allowance (BG-20) shall have a Document level allowance VAT category code (BT-95).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)">
					<xsl:attribute name="id">HK-BR-33</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-33] Each Document level allowance (BG-20) shall have a Document level allowance reason (BT-97) or a Document level allowance reason code (BT-98).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-01] The allowed maximum number of decimals for the Document level allowance amount (BT-92) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-02</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-02] The allowed maximum number of decimals for the Document level allowance base amount (BT-93) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M10" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M10" priority="-1" />
	<xsl:template match="@*|node()" mode="M10" priority="-2">
		<xsl:apply-templates mode="M10" select="*" />
	</xsl:template>

	<!--PATTERN HK-document-charges-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:ChargeIndicator = true()] | /cn:CreditNote/cac:AllowanceCharge[cbc:ChargeIndicator = true()]" mode="M11" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:ChargeIndicator = true()] | /cn:CreditNote/cac:AllowanceCharge[cbc:ChargeIndicator = true()]" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:Amount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:Amount)">
					<xsl:attribute name="id">HK-BR-36</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-36] Each Document level charge (BG-21) shall have a Document level charge amount (BT-99).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:TaxCategory[cac:TaxScheme/normalize-space(upper-case(cbc:ID))='VAT']/cbc:ID)">
					<xsl:attribute name="id">HK-BR-37</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-37] Each Document level charge (BG-21) shall have a Document level charge VAT category code (BT-102).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)">
					<xsl:attribute name="id">HK-BR-38</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-38] Each Document level charge (BG-21) shall have a Document level charge reason (BT-104) or a Document level charge reason code (BT-105).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-05</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-05] The allowed maximum number of decimals for the Document level charge amount (BT-99) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-06</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-06] The allowed maximum number of decimals for the Document level charge base amount (BT-100) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M11" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M11" priority="-1" />
	<xsl:template match="@*|node()" mode="M11" priority="-2">
		<xsl:apply-templates mode="M11" select="*" />
	</xsl:template>

	<!--PATTERN HK-additional-document-->


	<!--RULE -->
	<xsl:template match="cac:AdditionalDocumentReference" mode="M12" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AdditionalDocumentReference" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:ID) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID) != ''">
					<xsl:attribute name="id">HK-BR-52</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-52] Each Additional supporting document (BG-24) shall contain a Supporting document reference (BT-122).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M12" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M12" priority="-1" />
	<xsl:template match="@*|node()" mode="M12" priority="-2">
		<xsl:apply-templates mode="M12" select="*" />
	</xsl:template>

	<!--PATTERN HK-delivery-->


	<!--RULE -->
	<xsl:template match="cac:Delivery/cac:DeliveryLocation/cac:Address" mode="M13" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:Delivery/cac:DeliveryLocation/cac:Address" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:Country/cbc:IdentificationCode)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:Country/cbc:IdentificationCode)">
					<xsl:attribute name="id">HK-BR-57</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-57] Each Deliver to address (BG-15) shall contain a Deliver to country code (BT-80).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M13" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M13" priority="-1" />
	<xsl:template match="@*|node()" mode="M13" priority="-2">
		<xsl:apply-templates mode="M13" select="*" />
	</xsl:template>

	<!--PATTERN HK-invoice-line-->


	<!--RULE -->
	<xsl:template match="cac:InvoiceLine | cac:CreditNoteLine" mode="M14" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:InvoiceLine | cac:CreditNoteLine" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:ID) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID) != ''">
					<xsl:attribute name="id">HK-BR-21</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-21] Each Invoice line (BG-25) shall have an Invoice line identifier (BT-126).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:InvoicedQuantity) or exists(cbc:CreditedQuantity)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:InvoicedQuantity) or exists(cbc:CreditedQuantity)">
					<xsl:attribute name="id">HK-BR-22</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-22] Each Invoice line (BG-25) shall have an Invoiced quantity (BT-129).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:InvoicedQuantity/@unitCode) or exists(cbc:CreditedQuantity/@unitCode)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:InvoicedQuantity/@unitCode) or exists(cbc:CreditedQuantity/@unitCode)">
					<xsl:attribute name="id">HK-BR-23</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-23] An Invoice line (BG-25) shall have an Invoiced quantity unit of measure code (BT-130).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:LineExtensionAmount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:LineExtensionAmount)">
					<xsl:attribute name="id">HK-BR-24</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-24] Each Invoice line (BG-25) shall have an Invoice line net amount (BT-131).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cac:Item/cbc:Name) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cac:Item/cbc:Name) != ''">
					<xsl:attribute name="id">HK-BR-25</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-25] Each Invoice line (BG-25) shall contain the Item name (BT-153).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:Price/cbc:PriceAmount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:Price/cbc:PriceAmount)">
					<xsl:attribute name="id">HK-BR-26</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-26] Each Invoice line (BG-25) shall contain the Item net price (BT-146).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(cac:Price/cbc:PriceAmount) >= 0" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(cac:Price/cbc:PriceAmount) >= 0">
					<xsl:attribute name="id">HK-BR-27</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-27] The Item net price (BT-146) shall NOT be negative.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(cac:Price/cac:AllowanceCharge/cbc:BaseAmount) >= 0 or not(exists(cac:Price/cac:AllowanceCharge/cbc:BaseAmount))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(cac:Price/cac:AllowanceCharge/cbc:BaseAmount) >= 0 or not(exists(cac:Price/cac:AllowanceCharge/cbc:BaseAmount))">
					<xsl:attribute name="id">HK-BR-28</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-28] The Item gross price (BT-148) shall NOT be negative.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(cac:Item/cac:ClassifiedTaxCategory[cac:TaxScheme/(normalize-space(upper-case(cbc:ID))='VAT')]/cbc:ID)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(cac:Item/cac:ClassifiedTaxCategory[cac:TaxScheme/(normalize-space(upper-case(cbc:ID))='VAT')]/cbc:ID)">
					<xsl:attribute name="id">HK-BR-CO-04</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-04] Each Invoice line (BG-25) shall be categorized with an Invoiced item VAT category code (BT-151).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:LineExtensionAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:LineExtensionAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-23</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-23] The allowed maximum number of decimals for the Invoice line net amount (BT-131) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M14" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M14" priority="-1" />
	<xsl:template match="@*|node()" mode="M14" priority="-2">
		<xsl:apply-templates mode="M14" select="*" />
	</xsl:template>

	<!--PATTERN HK-line-allowances-->


	<!--RULE -->
	<xsl:template match="//cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator = false()] | //cac:CreditNoteLine/cac:AllowanceCharge[cbc:ChargeIndicator = false()]" mode="M15" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator = false()] | //cac:CreditNoteLine/cac:AllowanceCharge[cbc:ChargeIndicator = false()]" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:Amount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:Amount)">
					<xsl:attribute name="id">HK-BR-41</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-41] Each Invoice line allowance (BG-27) shall have an Invoice line allowance amount (BT-136).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)">
					<xsl:attribute name="id">HK-BR-42</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-42] Each Invoice line allowance (BG-27) shall have an Invoice line allowance reason (BT-139) or an Invoice line allowance reason code (BT-140).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-24</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-24] The allowed maximum number of decimals for the Invoice line allowance amount (BT-136) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-25</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-25] The allowed maximum number of decimals for the Invoice line allowance base amount (BT-137) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M15" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M15" priority="-1" />
	<xsl:template match="@*|node()" mode="M15" priority="-2">
		<xsl:apply-templates mode="M15" select="*" />
	</xsl:template>

	<!--PATTERN HK-line-charges-->


	<!--RULE -->
	<xsl:template match="//cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator = true()] | //cac:CreditNoteLine/cac:AllowanceCharge[cbc:ChargeIndicator = true()]" mode="M16" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:InvoiceLine/cac:AllowanceCharge[cbc:ChargeIndicator = true()] | //cac:CreditNoteLine/cac:AllowanceCharge[cbc:ChargeIndicator = true()]" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:Amount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:Amount)">
					<xsl:attribute name="id">HK-BR-43</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-43] Each Invoice line charge (BG-28) shall have an Invoice line charge amount (BT-141).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)">
					<xsl:attribute name="id">HK-BR-44</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-44] Each Invoice line charge (BG-28) shall have an Invoice line charge reason (BT-144) or an Invoice line charge reason code (BT-145).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:Amount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:Amount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-27</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-27] The allowed maximum number of decimals for the Invoice line charge amount (BT-141) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(cbc:BaseAmount,'.'))&lt;=2">
					<xsl:attribute name="id">HK-BR-DEC-28</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-28] The allowed maximum number of decimals for the Invoice line charge base amount (BT-142) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M16" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M16" priority="-1" />
	<xsl:template match="@*|node()" mode="M16" priority="-2">
		<xsl:apply-templates mode="M16" select="*" />
	</xsl:template>

	<!--PATTERN HK-price-allowance-->


	<!--RULE -->
	<xsl:template match="cac:Price/cac:AllowanceCharge" mode="M17" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:Price/cac:AllowanceCharge" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)">
					<xsl:attribute name="id">HK-BR-46</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-46] Item net price MUST equal (Gross price - Allowance amount) when gross price is provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M17" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M17" priority="-1" />
	<xsl:template match="@*|node()" mode="M17" priority="-2">
		<xsl:apply-templates mode="M17" select="*" />
	</xsl:template>

	<!--PATTERN HK-tax-total-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice | /cn:CreditNote" mode="M18" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice | /cn:CreditNote" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode] and (string-length(substring-after(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode],'.'))&lt;=2)) or (not(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode]))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode] and (string-length(substring-after(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode],'.'))&lt;=2)) or (not(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:DocumentCurrencyCode]))">
					<xsl:attribute name="id">HK-BR-DEC-13</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-13] The allowed maximum number of decimals for the Invoice total VAT amount (BT-110) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode] and (string-length(substring-after(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode],'.'))&lt;=2)) or (not(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode]))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode] and (string-length(substring-after(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode],'.'))&lt;=2)) or (not(//cac:TaxTotal/cbc:TaxAmount[@currencyID = cbc:TaxCurrencyCode]))">
					<xsl:attribute name="id">HK-BR-DEC-15</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-15] The allowed maximum number of decimals for the Invoice total VAT amount in accounting currency (BT-111) is 2.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M18" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M18" priority="-1" />
	<xsl:template match="@*|node()" mode="M18" priority="-2">
		<xsl:apply-templates mode="M18" select="*" />
	</xsl:template>

	<!--PATTERN HK-price-decimals-->


	<!--RULE -->
	<xsl:template match="//cac:Price/cbc:PriceAmount" mode="M19" priority="1002">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:Price/cbc:PriceAmount" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(.,'.'))&lt;=4" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(.,'.'))&lt;=4">
					<xsl:attribute name="id">HK-BR-DEC-29</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-29] The allowed maximum number of decimals for the Item net price (BT-146) is 4.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M19" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="//cac:Price/cac:AllowanceCharge/cbc:BaseAmount" mode="M19" priority="1001">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:Price/cac:AllowanceCharge/cbc:BaseAmount" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(.,'.'))&lt;=4" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(.,'.'))&lt;=4">
					<xsl:attribute name="id">HK-BR-DEC-30</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-30] The allowed maximum number of decimals for the Item gross price (BT-148) is 4.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M19" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="//cac:Price/cac:AllowanceCharge/cbc:Amount" mode="M19" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:Price/cac:AllowanceCharge/cbc:Amount" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="string-length(substring-after(.,'.'))&lt;=4" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(substring-after(.,'.'))&lt;=4">
					<xsl:attribute name="id">HK-BR-DEC-31</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-DEC-31] The allowed maximum number of decimals for the Item price discount (BT-147) is 4.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M19" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M19" priority="-1" />
	<xsl:template match="@*|node()" mode="M19" priority="-2">
		<xsl:apply-templates mode="M19" select="*" />
	</xsl:template>

	<!--PATTERN HK-tax-currency-->


	<!--RULE -->
	<xsl:template match="cbc:TaxCurrencyCode" mode="M20" priority="1001">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:TaxCurrencyCode" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))">
					<xsl:attribute name="id">HK-R-TAX-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-TAX-01] VAT accounting currency code (cbc:TaxCurrencyCode) MUST be different from invoice currency code (cbc:DocumentCurrencyCode) when provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M20" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice | /cn:CreditNote" mode="M20" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice | /cn:CreditNote" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="every $taxcurrency in cbc:TaxCurrencyCode satisfies exists(//cac:TaxTotal/cbc:TaxAmount[@currencyID=$taxcurrency])" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="every $taxcurrency in cbc:TaxCurrencyCode satisfies exists(//cac:TaxTotal/cbc:TaxAmount[@currencyID=$taxcurrency])">
					<xsl:attribute name="id">HK-BR-53</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-53] If the VAT accounting currency code (BT-6) is present, then the Invoice total VAT amount in accounting currency (BT-111) shall be provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="count(cac:TaxTotal[cac:TaxSubtotal]) = 1" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:TaxTotal[cac:TaxSubtotal]) = 1">
					<xsl:attribute name="id">HK-R-TAX-02</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-TAX-02] Only one tax total with tax subtotals MUST be provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="count(cac:TaxTotal[not(cac:TaxSubtotal)]) = (if (cbc:TaxCurrencyCode) then 1 else 0)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:TaxTotal[not(cac:TaxSubtotal)]) = (if (cbc:TaxCurrencyCode) then 1 else 0)">
					<xsl:attribute name="id">HK-R-TAX-03</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-TAX-03] Only one tax total without tax subtotals MUST be provided when tax currency code is provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="not(cbc:TaxCurrencyCode) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] &lt;= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] &lt;= 0) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] >= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] >= 0)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:TaxCurrencyCode) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] &lt;= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] &lt;= 0) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] >= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] >= 0)">
					<xsl:attribute name="id">HK-R-TAX-04</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-TAX-04] Invoice total VAT amount and Invoice total VAT amount in accounting currency MUST have the same operational sign.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M20" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M20" priority="-1" />
	<xsl:template match="@*|node()" mode="M20" priority="-2">
		<xsl:apply-templates mode="M20" select="*" />
	</xsl:template>

	<!--PATTERN HK-currency-consistency-->


	<!--RULE -->
	<xsl:template match="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cac:TaxTotal[cac:TaxSubtotal]/cbc:TaxAmount | cac:TaxSubtotal/cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount" mode="M21" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cac:TaxTotal[cac:TaxSubtotal]/cbc:TaxAmount | cac:TaxSubtotal/cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="@currencyID = /*/cbc:DocumentCurrencyCode" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID = /*/cbc:DocumentCurrencyCode">
					<xsl:attribute name="id">HK-R-CURR-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-CURR-01] All currencyID attributes must have the same value as the invoice currency code (cbc:DocumentCurrencyCode), except for the invoice total VAT amount in accounting currency.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M21" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M21" priority="-1" />
	<xsl:template match="@*|node()" mode="M21" priority="-2">
		<xsl:apply-templates mode="M21" select="*" />
	</xsl:template>

	<!--PATTERN HK-allowance-charge-calculation-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | /cn:CreditNote/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]" mode="M22" priority="1002">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | /cn:CreditNote/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="false()" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
					<xsl:attribute name="id">HK-R-AC-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-AC-01] Allowance/charge base amount (cbc:BaseAmount) MUST be provided when allowance/charge percentage (cbc:MultiplierFactorNumeric) is provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M22" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | /cn:CreditNote/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]" mode="M22" priority="1001">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | /cn:CreditNote/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="false()" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
					<xsl:attribute name="id">HK-R-AC-02</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-AC-02] Allowance/charge percentage (cbc:MultiplierFactorNumeric) MUST be provided when allowance/charge base amount (cbc:BaseAmount) is provided.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M22" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice/cac:AllowanceCharge | /cn:CreditNote/cac:AllowanceCharge" mode="M22" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cac:AllowanceCharge | /cn:CreditNote/cac:AllowanceCharge" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'">
					<xsl:attribute name="id">HK-R-AC-03</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-AC-03] Allowance/charge ChargeIndicator value MUST equal 'true' or 'false'.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M22" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M22" priority="-1" />
	<xsl:template match="@*|node()" mode="M22" priority="-2">
		<xsl:apply-templates mode="M22" select="*" />
	</xsl:template>

	<!--PATTERN HK-creditnote-->


	<!--RULE -->
	<xsl:template match="cn:CreditNote" mode="M23" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cn:CreditNote" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID">
					<xsl:attribute name="id">HK-R-CN-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-CN-01] For credit note, the document MUST contain an invoice reference (cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M23" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M23" priority="-1" />
	<xsl:template match="@*|node()" mode="M23" priority="-2">
		<xsl:apply-templates mode="M23" select="*" />
	</xsl:template>

	<!--PATTERN HK-party-tax-scheme-->


	<!--RULE -->
	<xsl:template match="/ubl-invoice:Invoice | /cn:CreditNote" mode="M24" priority="1002">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice | /cn:CreditNote" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity)">
					<xsl:attribute name="id">HK-BR-CO-26</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-26] An Invoice shall contain the Supplier party legal entity (BG-11).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="exists(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity)" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity)">
					<xsl:attribute name="id">HK-BR-CO-27</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-BR-CO-27] An Invoice shall contain the Customer party legal entity (BG-12).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M24" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity" mode="M24" priority="1001">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:CompanyID) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:CompanyID) != ''">
					<xsl:attribute name="id">HK-R-LEG-01</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-LEG-01] Supplier party legal entity shall contain a Company ID (BRN).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:CompanyID/@schemeID) = 'BRN'" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:CompanyID/@schemeID) = 'BRN'">
					<xsl:attribute name="id">HK-R-LEG-02</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-LEG-02] Supplier party legal entity Company ID schemeID shall be 'BRN'.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M24" select="*" />
	</xsl:template>

	<!--RULE -->
	<xsl:template match="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity" mode="M24" priority="1000">
		<ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:CompanyID) != ''" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:CompanyID) != ''">
					<xsl:attribute name="id">HK-R-LEG-03</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-LEG-03] Customer party legal entity shall contain a Company ID (BRN).
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>

		<!--ASSERT -->
		<xsl:choose>
			<xsl:when test="normalize-space(cbc:CompanyID/@schemeID) = 'BRN'" />
			<xsl:otherwise>
				<ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:CompanyID/@schemeID) = 'BRN'">
					<xsl:attribute name="id">HK-R-LEG-04</xsl:attribute>
					<xsl:attribute name="flag">fatal</xsl:attribute>
					<xsl:attribute name="location">
						<xsl:apply-templates mode="schematron-select-full-path" select="." />
					</xsl:attribute>
					<ns0:text>
						[HK-R-LEG-04] Customer party legal entity Company ID schemeID shall be 'BRN'.
					</ns0:text>
				</ns0:failed-assert>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates mode="M24" select="*" />
	</xsl:template>
	<xsl:template match="text()" mode="M24" priority="-1" />
	<xsl:template match="@*|node()" mode="M24" priority="-2">
		<xsl:apply-templates mode="M24" select="*" />
	</xsl:template>
</xsl:transform>
