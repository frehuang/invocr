<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
               xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
               xmlns:ubl-invoice="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- Main template -->
    <xsl:template match="/">
        <svrl:schematron-output title="Malaysia MyInvois PINT-MY Validation Rules" schemaVersion="iso">
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" prefix="cbc"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" prefix="cac"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" prefix="ubl-invoice"/>

            <svrl:active-pattern id="MY-all-patterns" name="MY-all-patterns"/>
            <xsl:apply-templates select="/" mode="M1"/>
        </svrl:schematron-output>
    </xsl:template>

    <!-- Mode M1: Document level validation -->
    <xsl:template match="ubl-invoice:Invoice" priority="1000" mode="M1">
        <svrl:fired-rule context="ubl-invoice:Invoice"/>

        <!-- ==================== -->
        <!-- 基础字段验证 -->
        <!-- ==================== -->

        <!-- MY-R-001: Invoice ID必填 -->
        <xsl:choose>
            <xsl:when test="cbc:ID and string-length(cbc:ID) &lt;= 50"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:ID and string-length(cbc:ID) &lt;= 50" flag="fatal" id="MY-R-001">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-001] e-Invoice code/number is mandatory (max 50 chars).</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-002: InvoiceTypeCode必填 -->
        <xsl:choose>
            <xsl:when test="cbc:InvoiceTypeCode"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:InvoiceTypeCode" flag="fatal" id="MY-R-002">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-002] e-Invoice type code is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-003: InvoiceTypeCode必须有listVersionID属性 -->
        <xsl:choose>
            <xsl:when test="cbc:InvoiceTypeCode/@listVersionID = '1.0'"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:InvoiceTypeCode/@listVersionID = '1.0'" flag="fatal" id="MY-R-003">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-003] e-Invoice type code must have listVersionID='1.0'.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-004: IssueDate必填 -->
        <xsl:choose>
            <xsl:when test="cbc:IssueDate"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:IssueDate" flag="fatal" id="MY-R-004">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-004] e-Invoice date is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-005: IssueTime必填（策略3b） -->
        <xsl:choose>
            <xsl:when test="cbc:IssueTime"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:IssueTime" flag="fatal" id="MY-R-005">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-005] e-Invoice time is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-006: IssueTime必须UTC格式（以Z结尾） -->
        <xsl:choose>
            <xsl:when test="not(cbc:IssueTime) or ends-with(cbc:IssueTime, 'Z')"/>
            <xsl:otherwise>
                <svrl:failed-assert test="ends-with(cbc:IssueTime, 'Z')" flag="fatal" id="MY-R-006">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-006] e-Invoice time must be in UTC format (end with 'Z').</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-007: DocumentCurrencyCode必填 -->
        <xsl:choose>
            <xsl:when test="cbc:DocumentCurrencyCode"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:DocumentCurrencyCode" flag="fatal" id="MY-R-007">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-007] Invoice currency code is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- ==================== -->
        <!-- 供应商字段验证 -->
        <!-- ==================== -->

        <!-- MY-R-010: 供应商信息必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty" flag="fatal" id="MY-R-010">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-010] Supplier information is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-011: 供应商名称必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" flag="fatal" id="MY-R-011">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-011] Supplier's name is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-012: 供应商TIN必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='TIN']"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='TIN']" flag="fatal" id="MY-R-012">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-012] Supplier's TIN is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-013: 供应商地址必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress" flag="fatal" id="MY-R-013">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-013] Supplier's address is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-014: 供应商地址至少一行 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" flag="fatal" id="MY-R-014">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-014] Supplier's address line 0 is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-015: 供应商城市名称必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName" flag="fatal" id="MY-R-015">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-015] Supplier's city name is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-016: 供应商州代码必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentityCode"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentityCode" flag="fatal" id="MY-R-016">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-016] Supplier's state code is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-017: 国家代码必填且为MYS（根据发票类型验证供应商或购买方） -->
        <!-- 反向开票(Self-billed)时验证购买方，正常发票时验证供应商 -->
        <xsl:choose>
            <!-- 反向开票发票类型: 11=Self-billed Invoice, 12=Self-billed Credit Note, 13=Self-billed Debit Note, 14=Self-billed Refund Note -->
            <xsl:when test="cbc:InvoiceTypeCode = '11' or cbc:InvoiceTypeCode = '12' or cbc:InvoiceTypeCode = '13' or cbc:InvoiceTypeCode = '14'">
                <xsl:choose>
                    <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'MYS'"/>
                    <xsl:otherwise>
                        <svrl:failed-assert test="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'MYS'" flag="fatal" id="MY-R-017">
                            <xsl:attribute name="location">
                                <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                            </xsl:attribute>
                            <svrl:text>[MY-R-017] For self-billed invoice, buyer's country code must be 'MYS' for Malaysia.</svrl:text>
                        </svrl:failed-assert>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- 正常发票类型: 01=Invoice, 02=Credit Note, 03=Debit Note, 04=Refund Note -->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'MYS'"/>
                    <xsl:otherwise>
                        <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'MYS'" flag="fatal" id="MY-R-017">
                            <xsl:attribute name="location">
                                <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                            </xsl:attribute>
                            <svrl:text>[MY-R-017] Supplier's country code must be 'MYS' for Malaysia.</svrl:text>
                        </svrl:failed-assert>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-018: 供应商联系电话必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telephone"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telephone" flag="fatal" id="MY-R-018">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-018] Supplier's contact telephone is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- ==================== -->
        <!-- 买方字段验证 -->
        <!-- ==================== -->

        <!-- MY-R-020: 买方信息必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingCustomerParty"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingCustomerParty" flag="fatal" id="MY-R-020">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-020] Buyer information is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-021: 买方名称必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName or cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName or cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name" flag="fatal" id="MY-R-021">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-021] Buyer's name is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-022: 买方TIN必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='TIN']"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='TIN']" flag="fatal" id="MY-R-022">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-022] Buyer's TIN is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-023: 买方地址必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress" flag="fatal" id="MY-R-023">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-023] Buyer's address is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-024: 买方联系电话必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone" flag="fatal" id="MY-R-024">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-024] Buyer's contact telephone is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- ==================== -->
        <!-- 外币处理严格验证（策略1a、2b） -->
        <!-- ==================== -->

        <!-- MY-R-030: 外币时TaxCurrencyCode必填（策略2b） -->
        <xsl:choose>
            <xsl:when test="cbc:DocumentCurrencyCode = 'MYR' or cbc:TaxCurrencyCode"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:DocumentCurrencyCode = 'MYR' or cbc:TaxCurrencyCode" flag="fatal" id="MY-R-030">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-030] Tax currency code is mandatory when invoice currency is not MYR.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-031: TaxCurrencyCode必须为MYR（如果指定） -->
        <xsl:choose>
            <xsl:when test="not(cbc:TaxCurrencyCode) or cbc:TaxCurrencyCode = 'MYR'"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:TaxCurrencyCode = 'MYR'" flag="fatal" id="MY-R-031">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-031] Tax currency code must be MYR when specified.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-032: 外币时TaxExchangeRate必填（策略1a） -->
        <xsl:choose>
            <xsl:when test="cbc:DocumentCurrencyCode = 'MYR' or cac:TaxExchangeRate/cbc:CalculationRate"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:DocumentCurrencyCode = 'MYR' or cac:TaxExchangeRate/cbc:CalculationRate" flag="fatal" id="MY-R-032">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-032] Tax exchange rate is mandatory when invoice currency is not MYR.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-033: 汇率结构完整性验证 -->
        <xsl:choose>
            <xsl:when test="not(cac:TaxExchangeRate) or 
                          (cac:TaxExchangeRate/cbc:SourceCurrencyCode = cbc:DocumentCurrencyCode and
                           cac:TaxExchangeRate/cbc:TargetCurrencyCode = 'MYR')"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:TaxExchangeRate/cbc:SourceCurrencyCode = cbc:DocumentCurrencyCode and
                                         cac:TaxExchangeRate/cbc:TargetCurrencyCode = 'MYR'" flag="fatal" id="MY-R-033">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-033] Exchange rate source must match document currency and target must be MYR.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- ==================== -->
        <!-- 特殊规则 -->
        <!-- ==================== -->

        <!-- MY-R-040: Credit Note必须有BillingReference -->
        <xsl:if test="cbc:InvoiceTypeCode = '02' or cbc:InvoiceTypeCode = '12'">
            <xsl:choose>
                <xsl:when test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID"/>
                <xsl:otherwise>
                    <svrl:failed-assert test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID" flag="fatal" id="MY-R-040">
                        <xsl:attribute name="location">
                            <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                        </xsl:attribute>
                        <svrl:text>[MY-R-040] Credit note (type 02 or 12) must contain billing reference.</svrl:text>
                    </svrl:failed-assert>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- MY-R-050: 税务总计必填 -->
        <xsl:choose>
            <xsl:when test="cac:TaxTotal"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:TaxTotal" flag="fatal" id="MY-R-050">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-050] Tax total is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-051: 货币总计必填 -->
        <xsl:choose>
            <xsl:when test="cac:LegalMonetaryTotal"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:LegalMonetaryTotal" flag="fatal" id="MY-R-051">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-051] Legal monetary total is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- MY-R-052: 至少一个发票行 -->
        <xsl:choose>
            <xsl:when test="cac:InvoiceLine"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:InvoiceLine" flag="fatal" id="MY-R-052">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[MY-R-052] At least one invoice line is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Mode M1: Default template (no validation) -->
    <xsl:template match="text()" priority="-1" mode="M1"/>
    <xsl:template match="@*|node()" priority="-2" mode="M1">
        <xsl:apply-templates select="@*|node()" mode="M1"/>
    </xsl:template>

    <!-- Generate XPath for location -->
    <xsl:template match="*" mode="schematron-select-full-path">
        <xsl:apply-templates select="." mode="schematron-get-full-path"/>
    </xsl:template>

    <xsl:template match="*" mode="schematron-get-full-path">
        <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>*:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>[namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                    and namespace-uri() = namespace-uri(current())])"/>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="1+ $preceding"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="@*" mode="schematron-get-full-path">
        <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <xsl:text>/@</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>*:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>[namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:transform>
