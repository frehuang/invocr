<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:u="utils" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:ubl-creditnote="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:ubl-invoice="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" xmlns:udt="urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->

<param name="archiveDirParameter" />
  <param name="archiveNameParameter" />
  <param name="fileNameParameter" />
  <param name="fileDirParameter" />
  <variable name="document-uri">
    <value-of select="document-uri(/)" />
  </variable>

<!--PHASES-->


<!--PROLOG-->
<output indent="yes" method="xml" omit-xml-declaration="no" standalone="yes" />

<!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->
<function as="xs:boolean" name="u:gln">
    <param name="val" />
    <variable name="length" select="string-length($val) - 1" />
    <variable name="digits" select="reverse(for $i in string-to-codepoints(substring($val, 0, $length + 1)) return $i - 48)" />
    <variable name="weightedSum" select="sum(for $i in (0 to $length - 1) return $digits[$i + 1] * (1 + ((($i + 1) mod 2) * 2)))" />
    <value-of select="(10 - ($weightedSum mod 10)) mod 10 = number(substring($val, $length + 1, 1))" />
  </function>
  <function as="xs:boolean" name="u:slack">
    <param as="xs:decimal" name="exp" />
    <param as="xs:decimal" name="val" />
    <param as="xs:decimal" name="slack" />
    <value-of select="xs:decimal($exp + $slack) >= $val and xs:decimal($exp - $slack) &lt;= $val" />
  </function>
  <function as="xs:boolean" name="u:mod11">
    <param name="val" />
    <variable name="length" select="string-length($val) - 1" />
    <variable name="digits" select="reverse(for $i in string-to-codepoints(substring($val, 0, $length + 1)) return $i - 48)" />
    <variable name="weightedSum" select="sum(for $i in (0 to $length - 1) return $digits[$i + 1] * (($i mod 6) + 2))" />
    <value-of select="number($val) > 0 and (11 - ($weightedSum mod 11)) mod 11 = number(substring($val, $length + 1, 1))" />
  </function>
  <function as="xs:boolean" name="u:mod97-0208">
    <param name="val" />
    <variable name="checkdigits" select="substring($val,9,2)" />
    <variable name="calculated_digits" select="xs:string(97 - (xs:integer(substring($val,1,8)) mod 97))" />
    <value-of select="number($checkdigits) = number($calculated_digits)" />
  </function>
  <function as="xs:boolean" name="u:checkCodiceIPA">
    <param as="xs:string?" name="arg" />
    <variable name="allowed-characters">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789</variable>
    <sequence select="if ( (string-length(translate($arg, $allowed-characters, '')) = 0) and (string-length($arg) = 6) ) then true() else false()" />
  </function>
  <function as="xs:boolean" name="u:checkCF">
    <param as="xs:string?" name="arg" />
    <sequence select="   if ( (string-length($arg) = 16) or (string-length($arg) = 11) )      then    (    if ((string-length($arg) = 16))     then    (     if (u:checkCF16($arg))      then     (      true()     )     else     (      false()     )    )    else    (     if(($arg castable as xs:integer)) then true() else false()       )   )   else   (    false()   )   " />
  </function>
  <function as="xs:boolean" name="u:checkCF16">
    <param as="xs:string?" name="arg" />
    <variable name="allowed-characters">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz</variable>
    <sequence select="     if (  (string-length(translate(substring($arg,1,6), $allowed-characters, '')) = 0) and         (substring($arg,7,2) castable as xs:integer) and        (string-length(translate(substring($arg,9,1), $allowed-characters, '')) = 0) and        (substring($arg,10,2) castable as xs:integer) and         (substring($arg,12,3) castable as xs:string) and        (substring($arg,15,1) castable as xs:integer) and         (string-length(translate(substring($arg,16,1), $allowed-characters, '')) = 0)      )      then true()     else false()     " />
  </function>
  <function as="xs:boolean" name="u:checkPIVAseIT">
    <param as="xs:string" name="arg" />
    <variable name="paese" select="substring($arg,1,2)" />
    <variable name="codice" select="substring($arg,3)" />
    <sequence select="     if ( $paese = 'IT' or $paese = 'it' )    then    (     if ( ( string-length($codice) = 11 ) and ( if (u:checkPIVA($codice)!=0) then false() else true() ))     then     (      true()     )     else     (      false()     )    )    else    (     true()    )      " />
  </function>
  <function as="xs:integer" name="u:checkPIVA">
    <param as="xs:string?" name="arg" />
    <sequence select="     if (not($arg castable as xs:integer))       then 1      else ( u:addPIVA($arg,xs:integer(0)) mod 10 )" />
  </function>
  <function as="xs:integer" name="u:addPIVA">
    <param as="xs:string" name="arg" />
    <param as="xs:integer" name="pari" />
    <variable name="tappo" select="if (not($arg castable as xs:integer)) then 0 else 1" />
    <variable name="mapper" select="if ($tappo = 0) then 0 else                    ( if ($pari = 1)                     then ( xs:integer(substring('0246813579', ( xs:integer(substring($arg,1,1)) +1 ) ,1)) )                     else ( xs:integer(substring($arg,1,1) ) )                   )" />
    <sequence select="if ($tappo = 0) then $mapper else ( xs:integer($mapper) + u:addPIVA(substring(xs:string($arg),2), (if($pari=0) then 1 else 0) ) )" />
  </function>
  <function as="xs:boolean" name="u:abn">
    <param name="val" />
    <value-of select="( ((string-to-codepoints(substring($val,1,1)) - 49) * 10) + ((string-to-codepoints(substring($val,2,1)) - 48) * 1) + ((string-to-codepoints(substring($val,3,1)) - 48) * 3) + ((string-to-codepoints(substring($val,4,1)) - 48) * 5) + ((string-to-codepoints(substring($val,5,1)) - 48) * 7) + ((string-to-codepoints(substring($val,6,1)) - 48) * 9) + ((string-to-codepoints(substring($val,7,1)) - 48) * 11) + ((string-to-codepoints(substring($val,8,1)) - 48) * 13) + ((string-to-codepoints(substring($val,9,1)) - 48) * 15) + ((string-to-codepoints(substring($val,10,1)) - 48) * 17) + ((string-to-codepoints(substring($val,11,1)) - 48) * 19)) mod 89 = 0 " />
  </function>
  <function as="xs:boolean" name="u:TinVerification">
    <param as="xs:string" name="val" />
    <variable name="digits" select="    for $ch in string-to-codepoints($val)    return codepoints-to-string($ch)" />
    <variable name="checksum" select="    (number($digits[8])*2) +    (number($digits[7])*4) +    (number($digits[6])*8) +    (number($digits[5])*16) +    (number($digits[4])*32) +    (number($digits[3])*64) +    (number($digits[2])*128) +    (number($digits[1])*256) " />
    <value-of select="($checksum  mod 11) mod 10 = number($digits[9])" />
  </function>
  <function as="xs:boolean" name="u:checkSEOrgnr">
    <param as="xs:string" name="number" />
    <choose>
      
      <when test="not(matches($number, '^\d+$'))">
        <sequence select="false()" />
      </when>
      <otherwise>
        
        <variable name="mainPart" select="substring($number, 1, 9)" />
        <variable name="checkDigit" select="substring($number, 10, 1)" />
        <variable as="xs:integer" name="sum">
          <value-of select="sum(       for $pos in 1 to string-length($mainPart) return         if ($pos mod 2 = 1)         then (number(substring($mainPart, string-length($mainPart) - $pos + 1, 1)) * 2) mod 10 +           (number(substring($mainPart, string-length($mainPart) - $pos + 1, 1)) * 2) idiv 10         else number(substring($mainPart, string-length($mainPart) - $pos + 1, 1))      )" />
        </variable>
        <variable name="calculatedCheckDigit" select="(10 - $sum mod 10) mod 10" />
        <sequence select="$calculatedCheckDigit = number($checkDigit)" />
      </otherwise>
    </choose>
  </function>

<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<template match="*" mode="schematron-select-full-path">
    <apply-templates mode="schematron-get-full-path" select="." />
  </template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<template match="*" mode="schematron-get-full-path">
    <apply-templates mode="schematron-get-full-path" select="parent::*" />
    <text>/</text>
    <choose>
      <when test="namespace-uri()=''">
        <value-of select="name()" />
      </when>
      <otherwise>
        <text>*:</text>
        <value-of select="local-name()" />
        <text>[namespace-uri()='</text>
        <value-of select="namespace-uri()" />
        <text>']</text>
      </otherwise>
    </choose>
    <variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])" />
    <text>[</text>
    <value-of select="1+ $preceding" />
    <text>]</text>
  </template>
  <template match="@*" mode="schematron-get-full-path">
    <apply-templates mode="schematron-get-full-path" select="parent::*" />
    <text>/</text>
    <choose>
      <when test="namespace-uri()=''">@<value-of select="name()" />
</when>
      <otherwise>
        <text>@*[local-name()='</text>
        <value-of select="local-name()" />
        <text>' and namespace-uri()='</text>
        <value-of select="namespace-uri()" />
        <text>']</text>
      </otherwise>
    </choose>
  </template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<template match="node() | @*" mode="schematron-get-full-path-2">
    <for-each select="ancestor-or-self::*">
      <text>/</text>
      <value-of select="name(.)" />
      <if test="preceding-sibling::*[name(.)=name(current())]">
        <text>[</text>
        <value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
        <text>]</text>
      </if>
    </for-each>
    <if test="not(self::*)">
      <text />/@<value-of select="name(.)" />
    </if>
  </template>
<!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->

<template match="node() | @*" mode="schematron-get-full-path-3">
    <for-each select="ancestor-or-self::*">
      <text>/</text>
      <value-of select="name(.)" />
      <if test="parent::*">
        <text>[</text>
        <value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
        <text>]</text>
      </if>
    </for-each>
    <if test="not(self::*)">
      <text />/@<value-of select="name(.)" />
    </if>
  </template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<template match="/" mode="generate-id-from-path" />
  <template match="text()" mode="generate-id-from-path">
    <apply-templates mode="generate-id-from-path" select="parent::*" />
    <value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')" />
  </template>
  <template match="comment()" mode="generate-id-from-path">
    <apply-templates mode="generate-id-from-path" select="parent::*" />
    <value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')" />
  </template>
  <template match="processing-instruction()" mode="generate-id-from-path">
    <apply-templates mode="generate-id-from-path" select="parent::*" />
    <value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')" />
  </template>
  <template match="@*" mode="generate-id-from-path">
    <apply-templates mode="generate-id-from-path" select="parent::*" />
    <value-of select="concat('.@', name())" />
  </template>
  <template match="*" mode="generate-id-from-path" priority="-0.5">
    <apply-templates mode="generate-id-from-path" select="parent::*" />
    <text>.</text>
    <value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')" />
  </template>

<!--MODE: GENERATE-ID-2 -->
<template match="/" mode="generate-id-2">U</template>
  <template match="*" mode="generate-id-2" priority="2">
    <text>U</text>
    <number count="*" level="multiple" />
  </template>
  <template match="node()" mode="generate-id-2">
    <text>U.</text>
    <number count="*" level="multiple" />
    <text>n</text>
    <number count="node()" />
  </template>
  <template match="@*" mode="generate-id-2">
    <text>U.</text>
    <number count="*" level="multiple" />
    <text>_</text>
    <value-of select="string-length(local-name(.))" />
    <text>_</text>
    <value-of select="translate(name(),':','.')" />
  </template>
<!--Strip characters-->  <template match="text()" priority="-1" />

<!--SCHEMA SETUP-->
<template match="/">
    <ns0:schematron-output xmlns:ns0="http://purl.oclc.org/dsdl/svrl" schemaVersion="iso" title="Rules for Peppol BIS 3.0 Billing">
      <comment>
        <value-of select="$archiveDirParameter" />   
		 <value-of select="$archiveNameParameter" />  
		 <value-of select="$fileNameParameter" />  
		 <value-of select="$fileDirParameter" />
      </comment>
      <ns0:ns-prefix-in-attribute-values prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" />
      <ns0:ns-prefix-in-attribute-values prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" />
      <ns0:ns-prefix-in-attribute-values prefix="ubl-creditnote" uri="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" />
      <ns0:ns-prefix-in-attribute-values prefix="ubl-invoice" uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" />
      <ns0:ns-prefix-in-attribute-values prefix="xs" uri="http://www.w3.org/2001/XMLSchema" />
      <ns0:ns-prefix-in-attribute-values prefix="u" uri="utils" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M26" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M27" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M28" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M29" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M30" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M31" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M32" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M37" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M38" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M39" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M40" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="id">german-rules</attribute>
        <attribute name="name">german-rules</attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M41" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M42" select="/" />
    </ns0:schematron-output>
  </template>

<!--SCHEMATRON PATTERNS-->
<ns0:text xmlns:ns0="http://purl.oclc.org/dsdl/svrl">Rules for Peppol BIS 3.0 Billing</ns0:text>
  <param name="profile" select="       if (/*/cbc:ProfileID and matches(normalize-space(/*/cbc:ProfileID), 'urn:fdc:peppol.eu:2017:poacc:billing:([0-9]{2}):1.0')) then         tokenize(normalize-space(/*/cbc:ProfileID), ':')[7]       else         'Unknown'" />
  <param name="supplierCountry" select="       if (/*/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)) then         upper-case(normalize-space(/*/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)))       else         if (/*/cac:TaxRepresentativeParty/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)) then           upper-case(normalize-space(/*/cac:TaxRepresentativeParty/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)))         else           if (/*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode) then             upper-case(normalize-space(/*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode))           else             'XX'" />
  <param name="customerCountry" select="   if (/*/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)) then   upper-case(normalize-space(/*/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)))   else   if (/*/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode) then   upper-case(normalize-space(/*/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode))   else   'XX'" />
  <param name="supplierCountryIsDE" select="(upper-case(normalize-space(/*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)) = 'DE')" />
  <param name="customerCountryIsDE" select="(upper-case(normalize-space(/*/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)) = 'DE')" />
  <param name="documentCurrencyCode" select="/*/cbc:DocumentCurrencyCode" />

<!--PATTERN -->


	<!--RULE -->
<template match="//*[not(*) and not(normalize-space())]" mode="M26" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//*[not(*) and not(normalize-space())]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-EN16931-R008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST not contain empty elements.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M26" select="@*|*" />
  </template>
  <template match="text()" mode="M26" priority="-1" />
  <template match="@*|node()" mode="M26" priority="-2">
    <apply-templates mode="M26" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="ubl-creditnote:CreditNote" mode="M27" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote" />

		<!--ASSERT -->
<choose>
      <when test="(count(cac:AdditionalDocumentReference[cbc:DocumentTypeCode='50']) &lt;= 1)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(count(cac:AdditionalDocumentReference[cbc:DocumentTypeCode='50']) &lt;= 1)">
          <attribute name="id">PEPPOL-EN16931-R080</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Only one project reference is allowed on document level</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M27" select="@*|*" />
  </template>
  <template match="text()" mode="M27" priority="-1" />
  <template match="@*|node()" mode="M27" priority="-2">
    <apply-templates mode="M27" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="ubl-creditnote:CreditNote | ubl-invoice:Invoice" mode="M28" priority="1023">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote | ubl-invoice:Invoice" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ProfileID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ProfileID">
          <attribute name="id">PEPPOL-EN16931-R001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Business process MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="$profile != 'Unknown'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$profile != 'Unknown'">
          <attribute name="id">PEPPOL-EN16931-R007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Business process MUST be in the format 'urn:fdc:peppol.eu:2017:poacc:billing:NN:1.0' where NN indicates the process number.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(cbc:Note) &lt;= 1 or ($supplierCountryIsDE and $customerCountryIsDE)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cbc:Note) &lt;= 1 or ($supplierCountryIsDE and $customerCountryIsDE)">
          <attribute name="id">PEPPOL-EN16931-R002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>No more than one note is allowed on document level, unless both the buyer and seller are German organizations.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:BuyerReference or cac:OrderReference/cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:BuyerReference or cac:OrderReference/cbc:ID">
          <attribute name="id">PEPPOL-EN16931-R003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>A buyer reference or purchase order reference MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="starts-with(normalize-space(cbc:CustomizationID/text()), 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="starts-with(normalize-space(cbc:CustomizationID/text()), 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0')">
          <attribute name="id">PEPPOL-EN16931-R004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Specification identifier MUST have the value 'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(cac:TaxTotal[cac:TaxSubtotal]) = 1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:TaxTotal[cac:TaxSubtotal]) = 1">
          <attribute name="id">PEPPOL-EN16931-R053</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Only one tax total with tax subtotals MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(cac:TaxTotal[not(cac:TaxSubtotal)]) = (if (cbc:TaxCurrencyCode) then 1 else 0)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:TaxTotal[not(cac:TaxSubtotal)]) = (if (cbc:TaxCurrencyCode) then 1 else 0)">
          <attribute name="id">PEPPOL-EN16931-R054</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Only one tax total without tax subtotals MUST be provided when tax currency code is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cbc:TaxCurrencyCode) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] &lt;= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] &lt;= 0) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] >= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] >= 0) " />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:TaxCurrencyCode) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] &lt;= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] &lt;= 0) or (cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:TaxCurrencyCode)] >= 0 and cac:TaxTotal/cbc:TaxAmount[@currencyID=normalize-space(../../cbc:DocumentCurrencyCode)] >= 0)">
          <attribute name="id">PEPPOL-EN16931-R055</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Invoice total VAT amount and Invoice total VAT amount in accounting currency MUST have the same operational sign</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:TaxCurrencyCode" mode="M28" priority="1022">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:TaxCurrencyCode" />

		<!--ASSERT -->
<choose>
      <when test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(normalize-space(text()) = normalize-space(../cbc:DocumentCurrencyCode/text()))">
          <attribute name="id">PEPPOL-EN16931-R005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>VAT accounting currency code MUST be different from invoice currency code when provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingCustomerParty/cac:Party" mode="M28" priority="1021">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndpointID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID">
          <attribute name="id">PEPPOL-EN16931-R010</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Buyer electronic address MUST be provided</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party" mode="M28" priority="1020">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndpointID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID">
          <attribute name="id">PEPPOL-EN16931-R020</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Seller electronic address MUST be provided</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-invoice:Invoice/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | ubl-invoice:Invoice/cac:InvoiceLine/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | ubl-creditnote:CreditNote/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | ubl-creditnote:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]" mode="M28" priority="1019">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-invoice:Invoice/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | ubl-invoice:Invoice/cac:InvoiceLine/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | ubl-creditnote:CreditNote/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | ubl-creditnote:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-EN16931-R041</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge base amount MUST be provided when allowance/charge percentage is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-invoice:Invoice/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | ubl-invoice:Invoice/cac:InvoiceLine/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | ubl-creditnote:CreditNote/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | ubl-creditnote:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]" mode="M28" priority="1018">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-invoice:Invoice/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | ubl-invoice:Invoice/cac:InvoiceLine/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | ubl-creditnote:CreditNote/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | ubl-creditnote:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-EN16931-R042</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge percentage MUST be provided when allowance/charge base amount is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-invoice:Invoice/cac:AllowanceCharge | ubl-invoice:Invoice/cac:InvoiceLine/cac:AllowanceCharge | ubl-creditnote:CreditNote/cac:AllowanceCharge | ubl-creditnote:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge" mode="M28" priority="1017">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-invoice:Invoice/cac:AllowanceCharge | ubl-invoice:Invoice/cac:InvoiceLine/cac:AllowanceCharge | ubl-creditnote:CreditNote/cac:AllowanceCharge | ubl-creditnote:CreditNote/cac:CreditNoteLine/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="           not(cbc:MultiplierFactorNumeric and cbc:BaseAmount) or u:slack(if (cbc:Amount) then             cbc:Amount           else             0, (xs:decimal(cbc:BaseAmount) * xs:decimal(cbc:MultiplierFactorNumeric)) div 100, 0.02)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:MultiplierFactorNumeric and cbc:BaseAmount) or u:slack(if (cbc:Amount) then cbc:Amount else 0, (xs:decimal(cbc:BaseAmount) * xs:decimal(cbc:MultiplierFactorNumeric)) div 100, 0.02)">
          <attribute name="id">PEPPOL-EN16931-R040</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge amount must equal base amount * percentage/100 if base amount and percentage exists</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ChargeIndicator/text()) = 'true' or normalize-space(cbc:ChargeIndicator/text()) = 'false'">
          <attribute name="id">PEPPOL-EN16931-R043</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge ChargeIndicator value MUST equal 'true' or 'false'</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="         cac:PaymentMeans[some $code in tokenize('49 59', '\s')           satisfies normalize-space(cbc:PaymentMeansCode) = $code]" mode="M28" priority="1016">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="         cac:PaymentMeans[some $code in tokenize('49 59', '\s')           satisfies normalize-space(cbc:PaymentMeansCode) = $code]" />

		<!--ASSERT -->
<choose>
      <when test="cac:PaymentMandate/cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PaymentMandate/cbc:ID">
          <attribute name="id">PEPPOL-EN16931-R061</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Mandate reference MUST be provided for direct debit.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cac:TaxTotal[cac:TaxSubtotal]/cbc:TaxAmount | cac:TaxSubtotal/cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount" mode="M28" priority="1015">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cac:TaxTotal[cac:TaxSubtotal]/cbc:TaxAmount | cac:TaxSubtotal/cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID = $documentCurrencyCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID = $documentCurrencyCode">
          <attribute name="id">PEPPOL-EN16931-R051</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>All currencyID attributes must have the same value as the invoice currency code (BT-5), except for the invoice total VAT amount in accounting currency (BT-111).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-invoice:Invoice[cac:InvoicePeriod/cbc:StartDate]/cac:InvoiceLine/cac:InvoicePeriod/cbc:StartDate | ubl-creditnote:CreditNote[cac:InvoicePeriod/cbc:StartDate]/cac:CreditNoteLine/cac:InvoicePeriod/cbc:StartDate" mode="M28" priority="1014">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-invoice:Invoice[cac:InvoicePeriod/cbc:StartDate]/cac:InvoiceLine/cac:InvoicePeriod/cbc:StartDate | ubl-creditnote:CreditNote[cac:InvoicePeriod/cbc:StartDate]/cac:CreditNoteLine/cac:InvoicePeriod/cbc:StartDate" />

		<!--ASSERT -->
<choose>
      <when test="xs:date(text()) >= xs:date(../../../cac:InvoicePeriod/cbc:StartDate)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="xs:date(text()) >= xs:date(../../../cac:InvoicePeriod/cbc:StartDate)">
          <attribute name="id">PEPPOL-EN16931-R110</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Start date of line period MUST be within invoice period.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-invoice:Invoice[cac:InvoicePeriod/cbc:EndDate]/cac:InvoiceLine/cac:InvoicePeriod/cbc:EndDate | ubl-creditnote:CreditNote[cac:InvoicePeriod/cbc:EndDate]/cac:CreditNoteLine/cac:InvoicePeriod/cbc:EndDate" mode="M28" priority="1013">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-invoice:Invoice[cac:InvoicePeriod/cbc:EndDate]/cac:InvoiceLine/cac:InvoicePeriod/cbc:EndDate | ubl-creditnote:CreditNote[cac:InvoicePeriod/cbc:EndDate]/cac:CreditNoteLine/cac:InvoicePeriod/cbc:EndDate" />

		<!--ASSERT -->
<choose>
      <when test="xs:date(text()) &lt;= xs:date(../../../cac:InvoicePeriod/cbc:EndDate)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="xs:date(text()) &lt;= xs:date(../../../cac:InvoicePeriod/cbc:EndDate)">
          <attribute name="id">PEPPOL-EN16931-R111</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>End date of line period MUST be within invoice period.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:InvoiceLine | cac:CreditNoteLine" mode="M28" priority="1012">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:InvoiceLine | cac:CreditNoteLine" />
    <variable name="lineExtensionAmount" select="           if (cbc:LineExtensionAmount) then             xs:decimal(cbc:LineExtensionAmount)           else             0" />
    <variable name="quantity" select="           if (/ubl-invoice:Invoice) then             (if (cbc:InvoicedQuantity) then               xs:decimal(cbc:InvoicedQuantity)             else               1)           else             (if (cbc:CreditedQuantity) then               xs:decimal(cbc:CreditedQuantity)             else               1)" />
    <variable name="priceAmount" select="           if (cac:Price/cbc:PriceAmount) then             xs:decimal(cac:Price/cbc:PriceAmount)           else             0" />
    <variable name="baseQuantity" select="           if (cac:Price/cbc:BaseQuantity and xs:decimal(cac:Price/cbc:BaseQuantity) != 0) then             xs:decimal(cac:Price/cbc:BaseQuantity)           else             1" />
    <variable name="allowancesTotal" select="           if (cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'false']) then             round(sum(cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'false']/cbc:Amount/xs:decimal(.)) * 10 * 10) div 100           else             0" />
    <variable name="chargesTotal" select="           if (cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'true']) then             round(sum(cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'true']/cbc:Amount/xs:decimal(.)) * 10 * 10) div 100           else             0" />

		<!--ASSERT -->
<choose>
      <when test="u:slack($lineExtensionAmount, ($quantity * ($priceAmount div $baseQuantity)) + $chargesTotal - $allowancesTotal, 0.02)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:slack($lineExtensionAmount, ($quantity * ($priceAmount div $baseQuantity)) + $chargesTotal - $allowancesTotal, 0.02)">
          <attribute name="id">PEPPOL-EN16931-R120</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Invoice line net amount MUST equal (Invoiced quantity * (Item net price/item price base quantity) + Sum of invoice line charge amount - sum of invoice line allowance amount</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:Price/cbc:BaseQuantity) or xs:decimal(cac:Price/cbc:BaseQuantity) > 0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:Price/cbc:BaseQuantity) or xs:decimal(cac:Price/cbc:BaseQuantity) > 0">
          <attribute name="id">PEPPOL-EN16931-R121</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Base quantity MUST be a positive number above zero.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(count(cac:DocumentReference) &lt;= 1)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(count(cac:DocumentReference) &lt;= 1)">
          <attribute name="id">PEPPOL-EN16931-R100</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Only one invoiced object is allowed pr line</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(not(cac:DocumentReference) or (cac:DocumentReference/cbc:DocumentTypeCode='130'))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(not(cac:DocumentReference) or (cac:DocumentReference/cbc:DocumentTypeCode='130'))">
          <attribute name="id">PEPPOL-EN16931-R101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element Document reference can only be used for Invoice line object</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:Price/cac:AllowanceCharge" mode="M28" priority="1011">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:Price/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ChargeIndicator) = 'false'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ChargeIndicator) = 'false'">
          <attribute name="id">PEPPOL-EN16931-R044</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Charge on price level is NOT allowed. Only value 'false' allowed.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)">
          <attribute name="id">PEPPOL-EN16931-R046</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Item net price MUST equal (Gross price - Allowance amount) when gross price is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:Price/cbc:BaseQuantity[@unitCode]" mode="M28" priority="1010">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:Price/cbc:BaseQuantity[@unitCode]" />
    <variable name="hasQuantity" select="../../cbc:InvoicedQuantity or ../../cbc:CreditedQuantity" />
    <variable name="quantity" select="           if (/ubl-invoice:Invoice) then             ../../cbc:InvoicedQuantity           else             ../../cbc:CreditedQuantity" />

		<!--ASSERT -->
<choose>
      <when test="not($hasQuantity) or @unitCode = $quantity/@unitCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not($hasQuantity) or @unitCode = $quantity/@unitCode">
          <attribute name="id">PEPPOL-EN16931-R130</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Unit code of price base quantity MUST be same as invoiced quantity.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']" mode="M28" priority="1009">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']" />

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(), '^[0-9]+$') and u:gln(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(), '^[0-9]+$') and u:gln(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R040</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>GLN must have a valid format according to GS1 rules.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0192'] | cac:PartyIdentification/cbc:ID[@schemeID = '0192'] | cbc:CompanyID[@schemeID = '0192']" mode="M28" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0192'] | cac:PartyIdentification/cbc:ID[@schemeID = '0192'] | cbc:CompanyID[@schemeID = '0192']" />

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(), '^[0-9]{9}$') and u:mod11(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(), '^[0-9]{9}$') and u:mod11(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R041</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Norwegian organization number MUST be stated in the correct format.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0184'] | cac:PartyIdentification/cbc:ID[@schemeID = '0184'] | cbc:CompanyID[@schemeID = '0184']" mode="M28" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0184'] | cac:PartyIdentification/cbc:ID[@schemeID = '0184'] | cbc:CompanyID[@schemeID = '0184']" />

		<!--ASSERT -->
<choose>
      <when test="(string-length(string()) = 10 and substring(string(), 1, 2) = 'DK' and string-length(translate(substring(string(), 3, 8), '1234567890', '')) = 0)                or               (string-length(string()) = 8) and (string-length(translate(substring(string(), 1, 8),'1234567890', '')) = 0)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(string-length(string()) = 10 and substring(string(), 1, 2) = 'DK' and string-length(translate(substring(string(), 3, 8), '1234567890', '')) = 0) or (string-length(string()) = 8) and (string-length(translate(substring(string(), 1, 8),'1234567890', '')) = 0)">
          <attribute name="id">PEPPOL-COMMON-R042</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Danish organization number (CVR) MUST be stated in the correct format.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0208'] | cac:PartyIdentification/cbc:ID[@schemeID = '0208'] | cbc:CompanyID[@schemeID = '0208']" mode="M28" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0208'] | cac:PartyIdentification/cbc:ID[@schemeID = '0208'] | cbc:CompanyID[@schemeID = '0208']" />

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(), '^[0-9]{10}$') and u:mod97-0208(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(), '^[0-9]{10}$') and u:mod97-0208(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R043</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Belgian enterprise number MUST be stated in the correct format.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0201'] | cac:PartyIdentification/cbc:ID[@schemeID = '0201'] | cbc:CompanyID[@schemeID = '0201']" mode="M28" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0201'] | cac:PartyIdentification/cbc:ID[@schemeID = '0201'] | cbc:CompanyID[@schemeID = '0201']" />

		<!--ASSERT -->
<choose>
      <when test="u:checkCodiceIPA(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:checkCodiceIPA(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R044</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>IPA Code (Codice Univoco Unità Organizzativa) must be stated in the correct format</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0210'] | cac:PartyIdentification/cbc:ID[@schemeID = '0210'] | cbc:CompanyID[@schemeID = '0210']" mode="M28" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0210'] | cac:PartyIdentification/cbc:ID[@schemeID = '0210'] | cbc:CompanyID[@schemeID = '0210']" />

		<!--ASSERT -->
<choose>
      <when test="u:checkCF(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:checkCF(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R045</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Code (Codice Fiscale) must be stated in the correct format</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '9907']" mode="M28" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '9907']" />

		<!--ASSERT -->
<choose>
      <when test="u:checkCF(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:checkCF(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R046</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Code (Codice Fiscale) must be stated in the correct format</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0211'] | cac:PartyIdentification/cbc:ID[@schemeID = '0211'] | cbc:CompanyID[@schemeID = '0211']" mode="M28" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0211'] | cac:PartyIdentification/cbc:ID[@schemeID = '0211'] | cbc:CompanyID[@schemeID = '0211']" />

		<!--ASSERT -->
<choose>
      <when test="u:checkPIVAseIT(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:checkPIVAseIT(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R047</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Italian VAT Code (Partita Iva) must be stated in the correct format</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0007'] | cac:PartyIdentification/cbc:ID[@schemeID = '0007'] | cbc:CompanyID[@schemeID = '0007']" mode="M28" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0007'] | cac:PartyIdentification/cbc:ID[@schemeID = '0007'] | cbc:CompanyID[@schemeID = '0007']" />

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space()) = 10 and string(number(normalize-space())) != 'NaN' and u:checkSEOrgnr(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space()) = 10 and string(number(normalize-space())) != 'NaN' and u:checkSEOrgnr(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R049</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Swedish organization number MUST be stated in the correct format.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0151'] | cac:PartyIdentification/cbc:ID[@schemeID = '0151'] | cbc:CompanyID[@schemeID = '0151']" mode="M28" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '0151'] | cac:PartyIdentification/cbc:ID[@schemeID = '0151'] | cbc:CompanyID[@schemeID = '0151']" />

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(), '^[0-9]{11}$') and u:abn(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(), '^[0-9]{11}$') and u:abn(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R050</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Australian Business Number (ABN) MUST be stated in the correct format.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M28" select="@*|*" />
  </template>
  <template match="text()" mode="M28" priority="-1" />
  <template match="@*|node()" mode="M28" priority="-2">
    <apply-templates mode="M28" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party[$supplierCountry = 'NO']" mode="M29" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party[$supplierCountry = 'NO']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'TAX']/cbc:CompanyID) = 'Foretaksregisteret'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'TAX']/cbc:CompanyID) = 'Foretaksregisteret'">
          <attribute name="id">NO-R-002</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Norwegian suppliers, most invoice issuers are required to append "Foretaksregisteret" to their invoice. "Dersom selger er aksjeselskap, allmennaksjeselskap eller filial av utenlandsk selskap skal også ordet «Foretaksregisteret» fremgå av salgsdokumentet, jf. foretaksregisterloven § 10-2."</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/substring(cbc:CompanyID, 1, 2)='NO' and matches(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/substring(cbc:CompanyID,3), '^[0-9]{9}MVA$')           and u:mod11(substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID, 3, 9)) or not(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/substring(cbc:CompanyID, 1, 2)='NO')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/substring(cbc:CompanyID, 1, 2)='NO' and matches(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/substring(cbc:CompanyID,3), '^[0-9]{9}MVA$') and u:mod11(substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID, 3, 9)) or not(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/substring(cbc:CompanyID, 1, 2)='NO')">
          <attribute name="id">NO-R-001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Norwegian suppliers, a VAT number MUST be the country code prefix NO followed by a valid Norwegian organization number (nine numbers) followed by the letters MVA.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M29" select="@*|*" />
  </template>
  <template match="text()" mode="M29" priority="-1" />
  <template match="@*|node()" mode="M29" priority="-2">
    <apply-templates mode="M29" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="DKSupplierCountry" select="concat(ubl-creditnote:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode, ubl-invoice:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)" />
  <variable name="DKCustomerCountry" select="concat(ubl-creditnote:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode, ubl-invoice:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)" />

	<!--RULE -->
<template match="ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK'] | ubl-invoice:Invoice[$DKSupplierCountry = 'DK']" mode="M30" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK'] | ubl-invoice:Invoice[$DKSupplierCountry = 'DK']" />

		<!--ASSERT -->
<choose>
      <when test="(normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/text()) != '')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/text()) != '')">
          <attribute name="id">DK-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Danish suppliers MUST provide legal entity (CVR-number)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(((boolean(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID))           and (normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID) != '0184'))       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(((boolean(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)) and (normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID) != '0184')) )">
          <attribute name="id">DK-R-014</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers it is mandatory to specify schemeID as "0184" (DK CVR-number) when PartyLegalEntity/CompanyID is used for AccountingSupplierParty</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not((boolean(/ubl-creditnote:CreditNote) and ($DKCustomerCountry = 'DK'))       and (number(cac:LegalMonetaryTotal/cbc:PayableAmount/text()) &lt; 0)       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((boolean(/ubl-creditnote:CreditNote) and ($DKCustomerCountry = 'DK')) and (number(cac:LegalMonetaryTotal/cbc:PayableAmount/text()) &lt; 0) )">
          <attribute name="id">DK-R-016</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers, a Credit note cannot have a negative total (PayableAmount)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M30" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification | ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification | ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification | ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification" mode="M30" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification | ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification | ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification | ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="not((boolean(cbc:ID))        and (normalize-space(cbc:ID/@schemeID) = '')       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((boolean(cbc:ID)) and (normalize-space(cbc:ID/@schemeID) = '') )">
          <attribute name="id">DK-R-013</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers it is mandatory to use schemeID when PartyIdentification/ID is used for AccountingCustomerParty or AccountingSupplierParty</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M30" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:PaymentMeans" mode="M30" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:PaymentMeans" />

		<!--ASSERT -->
<choose>
      <when test="contains(' 1 10 31 42 48 49 50 58 59 93 97 ', concat(' ', cbc:PaymentMeansCode, ' '))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="contains(' 1 10 31 42 48 49 50 58 59 93 97 ', concat(' ', cbc:PaymentMeansCode, ' '))">
          <attribute name="id">DK-R-005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish suppliers the following Payment means codes are allowed: 1, 10, 31, 42, 48, 49, 50, 58, 59, 93 and 97</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(((cbc:PaymentMeansCode = '31') or (cbc:PaymentMeansCode = '42'))       and not((normalize-space(cac:PayeeFinancialAccount/cbc:ID/text()) != '') and (normalize-space(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID/text()) != ''))       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(((cbc:PaymentMeansCode = '31') or (cbc:PaymentMeansCode = '42')) and not((normalize-space(cac:PayeeFinancialAccount/cbc:ID/text()) != '') and (normalize-space(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID/text()) != '')) )">
          <attribute name="id">DK-R-006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish suppliers bank account and registration account is mandatory if payment means is 31 or 42</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not((cbc:PaymentMeansCode = '49')       and not((normalize-space(cac:PaymentMandate/cbc:ID/text()) != '')           and (normalize-space(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID/text()) != ''))       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cbc:PaymentMeansCode = '49') and not((normalize-space(cac:PaymentMandate/cbc:ID/text()) != '') and (normalize-space(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID/text()) != '')) )">
          <attribute name="id">DK-R-007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish suppliers PaymentMandate/ID and PayerFinancialAccount/ID are mandatory when payment means is 49</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not((cbc:PaymentMeansCode = '50')       and not(((substring(cbc:PaymentID, 1, 3) = '01#')           or (substring(cbc:PaymentID, 1, 3) = '04#')           or (substring(cbc:PaymentID, 1, 3) = '15#'))         and matches(cac:PayeeFinancialAccount/cbc:ID, '^[0-9]{7,8}$')         )       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cbc:PaymentMeansCode = '50') and not(((substring(cbc:PaymentID, 1, 3) = '01#') or (substring(cbc:PaymentID, 1, 3) = '04#') or (substring(cbc:PaymentID, 1, 3) = '15#')) and matches(cac:PayeeFinancialAccount/cbc:ID, '^[0-9]{7,8}$') ) )">
          <attribute name="id">DK-R-008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers PaymentID is mandatory and MUST start with 01#, 04# or 15# (kortartkode), and PayeeFinancialAccount/ID (Giro kontonummer) is mandatory and must be 7 or 8 numerical characters long, when payment means equals 50 (Giro)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not((cbc:PaymentMeansCode = '50')       and ((substring(cbc:PaymentID, 1, 3) = '04#')          or (substring(cbc:PaymentID, 1, 3)  = '15#'))       and not(string-length(cbc:PaymentID) = 19)       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cbc:PaymentMeansCode = '50') and ((substring(cbc:PaymentID, 1, 3) = '04#') or (substring(cbc:PaymentID, 1, 3) = '15#')) and not(string-length(cbc:PaymentID) = 19) )">
          <attribute name="id">DK-R-009</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers if the PaymentID is prefixed with 04# or 15# the 16 digits instruction Id must be added to the PaymentID eg. "04#1234567890123456" when Payment means equals 50 (Giro)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not((cbc:PaymentMeansCode = '93')       and not(((substring(cbc:PaymentID, 1, 3) = '71#')           or (substring(cbc:PaymentID, 1, 3) = '73#')           or (substring(cbc:PaymentID, 1, 3) = '75#'))         and (string-length(cac:PayeeFinancialAccount/cbc:ID/text()) = 8)         )       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cbc:PaymentMeansCode = '93') and not(((substring(cbc:PaymentID, 1, 3) = '71#') or (substring(cbc:PaymentID, 1, 3) = '73#') or (substring(cbc:PaymentID, 1, 3) = '75#')) and (string-length(cac:PayeeFinancialAccount/cbc:ID/text()) = 8) ) )">
          <attribute name="id">DK-R-010</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers the PaymentID is mandatory and MUST start with 71#, 73# or 75# (kortartkode) and CreditAccount/AccountID (Kreditornummer) is mandatory and MUST be exactly 8 characters long, when Payment means equals 93 (FIK)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not((cbc:PaymentMeansCode = '93')       and ((substring(cbc:PaymentID, 1, 3) = '71#')          or (substring(cbc:PaymentID, 1, 3)  = '75#'))       and not((string-length(cbc:PaymentID) = 18)          or (string-length(cbc:PaymentID) = 19))       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cbc:PaymentMeansCode = '93') and ((substring(cbc:PaymentID, 1, 3) = '71#') or (substring(cbc:PaymentID, 1, 3) = '75#')) and not((string-length(cbc:PaymentID) = 18) or (string-length(cbc:PaymentID) = 19)) )">
          <attribute name="id">DK-R-011</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Danish Suppliers if the PaymentID is prefixed with 71# or 75# the 15-16 digits instruction Id must be added to the PaymentID eg. "71#1234567890123456" when payment Method equals 93 (FIK)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M30" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:CreditNoteLine | ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:InvoiceLine" mode="M30" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:CreditNoteLine | ubl-invoice:Invoice[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']/cac:InvoiceLine" />

		<!--ASSERT -->
<choose>
      <when test="not((cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listID = 'TST')       and not((cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '19.05.01')           or (cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '19.0501')                                or (cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '26.08.01')                                or (cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '26.0801')           )       )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listID = 'TST') and not((cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '19.05.01') or (cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '19.0501') or (cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '26.08.01') or (cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID = '26.0801') ) )">
          <attribute name="id">DK-R-003</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If ItemClassification is provided from Danish suppliers, UNSPSC version 19.05.01 or 26.08.01 should be used.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M30" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AllowanceCharge[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']" mode="M30" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AllowanceCharge[$DKSupplierCountry = 'DK' and $DKCustomerCountry = 'DK']" />

		<!--ASSERT -->
<choose>
      <when test="not((cbc:AllowanceChargeReasonCode = 'ZZZ')       and not(((string-length(normalize-space(cbc:AllowanceChargeReason/text())) = 4)         and (number(cbc:AllowanceChargeReason) >= 0)         and (number(cbc:AllowanceChargeReason) &lt;= 9999)) or         (((cbc:AllowanceChargeReason and contains(cbc:AllowanceChargeReason, '#')                                   and not(starts-with(cbc:AllowanceChargeReason, '#'))                                   and not(ends-with(cbc:AllowanceChargeReason, '#')))) )                                )      )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not((cbc:AllowanceChargeReasonCode = 'ZZZ') and not(((string-length(normalize-space(cbc:AllowanceChargeReason/text())) = 4) and (number(cbc:AllowanceChargeReason) >= 0) and (number(cbc:AllowanceChargeReason) &lt;= 9999)) or (((cbc:AllowanceChargeReason and contains(cbc:AllowanceChargeReason, '#') and not(starts-with(cbc:AllowanceChargeReason, '#')) and not(ends-with(cbc:AllowanceChargeReason, '#')))) ) ) )">
          <attribute name="id">DK-R-004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When specifying non-VAT Taxes for Danish customers, Danish suppliers MUST use the AllowanceChargeReasonCode="ZZZ" and MUST be specified in AllowanceChargeReason; Either as the 4-digit Tax category or must include a #, but the # is not allowed as first and last character</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M30" select="@*|*" />
  </template>
  <template match="text()" mode="M30" priority="-1" />
  <template match="@*|node()" mode="M30" priority="-2">
    <apply-templates mode="M30" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party[$supplierCountry = 'IT']/cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) != 'VAT']" mode="M31" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party[$supplierCountry = 'IT']/cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) != 'VAT']" />

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(cbc:CompanyID),'^[A-Z0-9]{11,16}$')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(cbc:CompanyID),'^[A-Z0-9]{11,16}$')">
          <attribute name="id">IT-R-001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IT-R-001] BT-32 (Seller tax registration identifier) - For Italian suppliers BT-32 minimum length 11 and maximum length shall be 16. Per i fornitori italiani il BT-32 deve avere una lunghezza tra 11 e 16 caratteri</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M31" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party[$supplierCountry = 'IT']" mode="M31" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party[$supplierCountry = 'IT']" />

		<!--ASSERT -->
<choose>
      <when test="cac:PostalAddress/cbc:StreetName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PostalAddress/cbc:StreetName">
          <attribute name="id">IT-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IT-R-002] BT-35 (Seller address line 1) - Italian suppliers MUST provide the postal address line 1 - I fornitori italiani devono indicare l'indirizzo postale.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PostalAddress/cbc:CityName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PostalAddress/cbc:CityName">
          <attribute name="id">IT-R-003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IT-R-003] BT-37 (Seller city) - Italian suppliers MUST provide the postal address city - I fornitori italiani devono indicare la città di residenza.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PostalAddress/cbc:PostalZone" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PostalAddress/cbc:PostalZone">
          <attribute name="id">IT-R-004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>"&gt;[IT-R-004] BT-38 (Seller post code) - Italian suppliers MUST provide the postal address post code - I fornitori italiani devono indicare il CAP di residenza.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M31" select="@*|*" />
  </template>
  <template match="text()" mode="M31" priority="-1" />
  <template match="@*|node()" mode="M31" priority="-2">
    <apply-templates mode="M31" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2) = 'SE']" mode="M32" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2) = 'SE']" />

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/cbc:CompanyID)) = 14" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/cbc:CompanyID)) = 14">
          <attribute name="id">SE-R-001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers, Swedish VAT-numbers must consist of 14 characters.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string(number(substring(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/cbc:CompanyID, 3, 12))) != 'NaN'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string(number(substring(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/cbc:CompanyID, 3, 12))) != 'NaN'">
          <attribute name="id">SE-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers, the Swedish VAT-numbers must have the trailing 12 characters in numeric form</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity[../cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cbc:CompanyID]" mode="M32" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity[../cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cbc:CompanyID]" />

		<!--ASSERT -->
<choose>
      <when test="string(number(cbc:CompanyID)) != 'NaN'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string(number(cbc:CompanyID)) != 'NaN'">
          <attribute name="id">SE-R-003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Swedish organisation numbers should be numeric.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space(cbc:CompanyID)) = 10" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space(cbc:CompanyID)) = 10">
          <attribute name="id">SE-R-004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Swedish organisation numbers consist of 10 characters.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="u:checkSEOrgnr(normalize-space(cbc:CompanyID))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:checkSEOrgnr(normalize-space(cbc:CompanyID))">
          <attribute name="id">SE-R-013</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The last digit of a Swedish organization number must be valid according to the Luhn algorithm.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and exists(cac:PartyLegalEntity/cbc:CompanyID)]/cac:PartyTaxScheme[normalize-space(upper-case(cac:TaxScheme/cbc:ID)) != 'VAT']/cbc:CompanyID" mode="M32" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and exists(cac:PartyLegalEntity/cbc:CompanyID)]/cac:PartyTaxScheme[normalize-space(upper-case(cac:TaxScheme/cbc:ID)) != 'VAT']/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(upper-case(.)) = 'GODKÄND FÖR F-SKATT'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(upper-case(.)) = 'GODKÄND FÖR F-SKATT'">
          <attribute name="id">SE-R-005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers, when using Seller tax registration identifier, 'Godkänd för F-skatt' must be stated</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:TaxCategory[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2) = 'SE'] and cbc:ID = 'S'] | //cac:ClassifiedTaxCategory[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2) = 'SE'] and cbc:ID = 'S']" mode="M32" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:TaxCategory[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2) = 'SE'] and cbc:ID = 'S'] | //cac:ClassifiedTaxCategory[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE' and cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2) = 'SE'] and cbc:ID = 'S']" />

		<!--ASSERT -->
<choose>
      <when test="number(cbc:Percent) = 25 or number(cbc:Percent) = 12 or number(cbc:Percent) = 6" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="number(cbc:Percent) = 25 or number(cbc:Percent) = 12 or number(cbc:Percent) = 6">
          <attribute name="id">SE-R-006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers, only standard VAT rate of 6, 12 or 25 are used</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and normalize-space(cbc:PaymentMeansCode) = '30' and normalize-space(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID) = 'SE:PLUSGIRO']/cac:PayeeFinancialAccount/cbc:ID" mode="M32" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and normalize-space(cbc:PaymentMeansCode) = '30' and normalize-space(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID) = 'SE:PLUSGIRO']/cac:PayeeFinancialAccount/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="string(number(normalize-space(.))) != 'NaN'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string(number(normalize-space(.))) != 'NaN'">
          <attribute name="id">SE-R-007</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers using Plusgiro, the Account ID must be numeric </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space(.)) >= 2 and string-length(normalize-space(.)) &lt;= 8" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space(.)) >= 2 and string-length(normalize-space(.)) &lt;= 8">
          <attribute name="id">SE-R-010</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers using Plusgiro, the Account ID must have 2-8 characters</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and normalize-space(cbc:PaymentMeansCode) = '30' and normalize-space(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID) = 'SE:BANKGIRO']/cac:PayeeFinancialAccount/cbc:ID" mode="M32" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and normalize-space(cbc:PaymentMeansCode) = '30' and normalize-space(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID) = 'SE:BANKGIRO']/cac:PayeeFinancialAccount/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="string(number(normalize-space(.))) != 'NaN'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string(number(normalize-space(.))) != 'NaN'">
          <attribute name="id">SE-R-008</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers using Bankgiro, the Account ID must be numeric </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space(.)) = 7 or string-length(normalize-space(.)) = 8" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space(.)) = 7 or string-length(normalize-space(.)) = 8">
          <attribute name="id">SE-R-009</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers using Bankgiro, the Account ID must have 7-8 characters</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and (cbc:PaymentMeansCode = normalize-space('50') or cbc:PaymentMeansCode = normalize-space('56'))]" mode="M32" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and (cbc:PaymentMeansCode = normalize-space('50') or cbc:PaymentMeansCode = normalize-space('56'))]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">SE-R-011</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For Swedish suppliers using Swedish Bankgiro or Plusgiro, the proper way to indicate this is to use Code 30 for PaymentMeans and FinancialInstitutionBranch ID with code SE:BANKGIRO or SE:PLUSGIRO</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>

	<!--RULE -->
<template match="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE']  and //cac:AccountingCustomerParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and (cbc:PaymentMeansCode = normalize-space('31'))]" mode="M32" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//cac:PaymentMeans[//cac:AccountingSupplierParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE']  and //cac:AccountingCustomerParty/cac:Party[cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'SE'] and (cbc:PaymentMeansCode = normalize-space('31'))]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">SE-R-012</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For domestic transactions between Swedish trading partners, credit transfer should be indicated by PaymentMeansCode="30"</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M32" select="@*|*" />
  </template>
  <template match="text()" mode="M32" priority="-1" />
  <template match="@*|node()" mode="M32" priority="-2">
    <apply-templates mode="M32" select="@*|*" />
  </template>
  <param name="isGreekSender" select="($supplierCountry ='GR') or ($supplierCountry ='EL')" />
  <param name="isGreekReceiver" select="($customerCountry ='GR') or ($customerCountry ='EL')" />
  <param name="isGreekSenderandReceiver" select="$isGreekSender and $isGreekReceiver" />
  <param name="accountingSupplierCountry" select="     if (/*/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)) then     upper-case(normalize-space(/*/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 1, 2)))     else     if (/*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode) then     upper-case(normalize-space(/*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode))     else     'XX'" />

<!--PATTERN -->
<variable name="dateRegExp" select="'^(0?[1-9]|[12][0-9]|3[01])[-\\/ ]?(0?[1-9]|1[0-2])[-\\/ ]?(19|20)[0-9]{2}'" />
  <variable name="greekDocumentType" select="tokenize('1.1 1.6 2.1 2.4 5.1 5.2 ','\s')" />
  <variable name="tokenizedUblIssueDate" select="tokenize(/*/cbc:IssueDate,'-')" />

	<!--RULE -->
<template match="/ubl-invoice:Invoice/cbc:ID[$isGreekSender] | /ubl-creditnote:CreditNote/cbc:ID[$isGreekSender]" mode="M37" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice/cbc:ID[$isGreekSender] | /ubl-creditnote:CreditNote/cbc:ID[$isGreekSender]" />
    <variable name="IdSegments" select="tokenize(.,'\|')" />

		<!--ASSERT -->
<choose>
      <when test="count($IdSegments) = 6" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count($IdSegments) = 6">
          <attribute name="id">GR-R-001-1</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text> When the Supplier is Greek, the Invoice Id should consist of 6 segments</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space($IdSegments[1])) = 9                                   and u:TinVerification($IdSegments[1])                                  and ($IdSegments[1] = /*/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 3, 9)                                  or $IdSegments[1] = /*/cac:TaxRepresentativeParty/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 3, 9) )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space($IdSegments[1])) = 9 and u:TinVerification($IdSegments[1]) and ($IdSegments[1] = /*/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 3, 9) or $IdSegments[1] = /*/cac:TaxRepresentativeParty/cac:PartyTaxScheme[cac:TaxScheme/cbc:ID = 'VAT']/substring(cbc:CompanyID, 3, 9) )">
          <attribute name="id">GR-R-001-2</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When the Supplier is Greek, the Invoice Id first segment must be a valid TIN Number and match either the Supplier's or the Tax Representative's Tin Number</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <variable name="tokenizedIdDate" select="tokenize($IdSegments[2],'/')" />

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space($IdSegments[2]))>0                                   and matches($IdSegments[2],$dateRegExp)                                  and ($tokenizedIdDate[1] = $tokenizedUblIssueDate[3]                                     and $tokenizedIdDate[2] = $tokenizedUblIssueDate[2]                                    and $tokenizedIdDate[3] = $tokenizedUblIssueDate[1])" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space($IdSegments[2]))>0 and matches($IdSegments[2],$dateRegExp) and ($tokenizedIdDate[1] = $tokenizedUblIssueDate[3] and $tokenizedIdDate[2] = $tokenizedUblIssueDate[2] and $tokenizedIdDate[3] = $tokenizedUblIssueDate[1])">
          <attribute name="id">GR-R-001-3</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When the Supplier is Greek, the Invoice Id second segment must be a valid Date that matches the invoice Issue Date</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space($IdSegments[3]))>0 and string(number($IdSegments[3])) != 'NaN' and xs:integer($IdSegments[3]) >= 0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space($IdSegments[3]))>0 and string(number($IdSegments[3])) != 'NaN' and xs:integer($IdSegments[3]) >= 0">
          <attribute name="id">GR-R-001-4</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, the Invoice Id third segment must be a positive integer</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space($IdSegments[4]))>0 and (some $c in $greekDocumentType satisfies $IdSegments[4] = $c)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space($IdSegments[4]))>0 and (some $c in $greekDocumentType satisfies $IdSegments[4] = $c)">
          <attribute name="id">GR-R-001-5</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, the Invoice Id in the fourth segment must be a valid greek document type</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length($IdSegments[5]) > 0 " />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length($IdSegments[5]) > 0">
          <attribute name="id">GR-R-001-6</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, the Invoice Id fifth segment must not be empty</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="string-length($IdSegments[6]) > 0 " />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length($IdSegments[6]) > 0">
          <attribute name="id">GR-R-001-7</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, the Invoice Id sixth segment must not be empty</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty[$isGreekSender]/cac:Party" mode="M37" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty[$isGreekSender]/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="string-length(./cac:PartyName/cbc:Name)>0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(./cac:PartyName/cbc:Name)>0">
          <attribute name="id">GR-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Greek Suppliers must provide their full name as they are registered in the Greek Business Registry (G.E.MH.) as a legal entity or in the Tax Registry as a natural person </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID)=1 and                             substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,1,2) = 'EL' and                             u:TinVerification(substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,3))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID)=1 and substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,1,2) = 'EL' and u:TinVerification(substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,3))">
          <attribute name="id">GR-S-011</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Greek suppliers must provide their Seller Tax Registration Number, prefixed by the country code</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty[$isGreekSender]/cac:Party/cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID" mode="M37" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty[$isGreekSender]/cac:Party/cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="substring(.,1,2) = 'EL' and u:TinVerification(substring(.,3))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="substring(.,1,2) = 'EL' and u:TinVerification(substring(.,3))">
          <attribute name="id">GR-R-003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>For the Greek Suppliers, the VAT must start with 'EL' and must be a valid TIN number</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl-invoice:Invoice[$isGreekSender and ( /*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'GR')] | /ubl-creditnote:CreditNote[$isGreekSender and ( /*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'GR')]" mode="M37" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl-invoice:Invoice[$isGreekSender and ( /*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'GR')] | /ubl-creditnote:CreditNote[$isGreekSender and ( /*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'GR')]" />

		<!--ASSERT -->
<choose>
      <when test="count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##M.AR.K##'])=1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##M.AR.K##'])=1">
          <attribute name="id">GR-R-004-1</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text> When Supplier is Greek, there must be one MARK Number</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##INVOICE|URL##'])=1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##INVOICE|URL##'])=1">
          <attribute name="id">GR-S-008-1</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, there should be one invoice url</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##INVOICE|URL##']) = 0 ) or (count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##INVOICE|URL##']) = 1 )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##INVOICE|URL##']) = 0 ) or (count(cac:AdditionalDocumentReference[cbc:DocumentDescription = '##INVOICE|URL##']) = 1 )">
          <attribute name="id">GR-R-008-2</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, there should be no more than one invoice url</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AdditionalDocumentReference[$isGreekSender and ( /*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'GR') and cbc:DocumentDescription = '##M.AR.K##']/cbc:ID" mode="M37" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AdditionalDocumentReference[$isGreekSender and ( /*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode = 'GR') and cbc:DocumentDescription = '##M.AR.K##']/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="matches(.,'^[1-9]([0-9]*)')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(.,'^[1-9]([0-9]*)')">
          <attribute name="id">GR-R-004-2</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek, the MARK Number must be a positive integer</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AdditionalDocumentReference[$isGreekSender and cbc:DocumentDescription = '##INVOICE|URL##']" mode="M37" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AdditionalDocumentReference[$isGreekSender and cbc:DocumentDescription = '##INVOICE|URL##']" />

		<!--ASSERT -->
<choose>
      <when test="string-length(normalize-space(cac:Attachment/cac:ExternalReference/cbc:URI))>0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(normalize-space(cac:Attachment/cac:ExternalReference/cbc:URI))>0">
          <attribute name="id">GR-R-008-3</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When Supplier is Greek and the INVOICE URL Document reference exists, the External Reference URI should be present</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingCustomerParty[$isGreekSender]/cac:Party" mode="M37" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty[$isGreekSender]/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="string-length(./cac:PartyName/cbc:Name)>0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(./cac:PartyName/cbc:Name)>0">
          <attribute name="id">GR-R-005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Greek Suppliers must provide the full name of the buyer</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party[$accountingSupplierCountry='GR' or $accountingSupplierCountry='EL']/cbc:EndpointID" mode="M37" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party[$accountingSupplierCountry='GR' or $accountingSupplierCountry='EL']/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="./@schemeID='9933' and u:TinVerification(.)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="./@schemeID='9933' and u:TinVerification(.)">
          <attribute name="id">GR-R-009</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Greek suppliers that send an invoice through the PEPPOL network must use a correct TIN number as an electronic address according to PEPPOL Electronic Address Identifier scheme (schemeID 9933).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M37" select="@*|*" />
  </template>
  <template match="text()" mode="M37" priority="-1" />
  <template match="@*|node()" mode="M37" priority="-2">
    <apply-templates mode="M37" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="cac:AccountingCustomerParty[$isGreekSenderandReceiver]/cac:Party" mode="M38" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty[$isGreekSenderandReceiver]/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="count(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID)=1 and                             substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,1,2) = 'EL' and                             u:TinVerification(substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,3))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID)=1 and substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,1,2) = 'EL' and u:TinVerification(substring(cac:PartyTaxScheme[normalize-space(cac:TaxScheme/cbc:ID) = 'VAT']/cbc:CompanyID,3))">
          <attribute name="id">GR-R-006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Greek Suppliers must provide the VAT number of the buyer, if the buyer is Greek </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M38" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingCustomerParty[$isGreekSenderandReceiver]/cac:Party/cbc:EndpointID" mode="M38" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty[$isGreekSenderandReceiver]/cac:Party/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="./@schemeID='9933' and u:TinVerification(.)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="./@schemeID='9933' and u:TinVerification(.)">
          <attribute name="id">GR-R-010</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Greek Suppliers that send an invoice through the PEPPOL network to a greek buyer must use a correct TIN number as an electronic address according to PEPPOL Electronic Address Identifier scheme (SchemeID 9933)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M38" select="@*|*" />
  </template>
  <template match="text()" mode="M38" priority="-1" />
  <template match="@*|node()" mode="M38" priority="-2">
    <apply-templates mode="M38" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="SupplierCountry" select="concat(ubl-creditnote:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode, ubl-invoice:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)" />
  <variable name="CustomerCountry" select="concat(ubl-creditnote:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode, ubl-invoice:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)" />

	<!--RULE -->
<template match="ubl-creditnote:CreditNote[$SupplierCountry = 'IS'] | ubl-invoice:Invoice[$SupplierCountry = 'IS']" mode="M39" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote[$SupplierCountry = 'IS'] | ubl-invoice:Invoice[$SupplierCountry = 'IS']" />

		<!--ASSERT -->
<choose>
      <when test="( ( not(contains(normalize-space(cbc:InvoiceTypeCode),' ')) and contains( ' 380 381 ',concat(' ',normalize-space(cbc:InvoiceTypeCode),' ') ) ) ) or ( ( not(contains(normalize-space(cbc:CreditNoteTypeCode),' ')) and contains( ' 380 381 ',concat(' ',normalize-space(cbc:CreditNoteTypeCode),' ') ) ) )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="( ( not(contains(normalize-space(cbc:InvoiceTypeCode),' ')) and contains( ' 380 381 ',concat(' ',normalize-space(cbc:InvoiceTypeCode),' ') ) ) ) or ( ( not(contains(normalize-space(cbc:CreditNoteTypeCode),' ')) and contains( ' 380 381 ',concat(' ',normalize-space(cbc:CreditNoteTypeCode),' ') ) ) )">
          <attribute name="id">IS-R-001</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-001]-If seller is icelandic then invoice type should be 380 or 381 — Ef seljandi er íslenskur þá ætti gerð reiknings (BT-3) að vera sölureikningur (380) eða kreditreikningur (381).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="exists(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID) and cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID = '0196'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID) and cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID = '0196'">
          <attribute name="id">IS-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-002]-If seller is icelandic then it shall contain sellers legal id — Ef seljandi er íslenskur þá skal reikningur innihalda íslenska kennitölu seljanda (BT-30).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName) and exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName) and exists(cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone)">
          <attribute name="id">IS-R-003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-003]-If seller is icelandic then it shall contain his address with street name and zip code — Ef seljandi er íslenskur þá skal heimilisfang seljanda innihalda götuheiti og póstnúmer (BT-35 og BT-38).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="exists(cac:PaymentMeans[cbc:PaymentMeansCode = '9']/cac:PayeeFinancialAccount/cbc:ID)         and string-length(normalize-space(cac:PaymentMeans[cbc:PaymentMeansCode = '9']/cac:PayeeFinancialAccount/cbc:ID)) = 12        or not(exists(cac:PaymentMeans[cbc:PaymentMeansCode = '9']))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:PaymentMeans[cbc:PaymentMeansCode = '9']/cac:PayeeFinancialAccount/cbc:ID) and string-length(normalize-space(cac:PaymentMeans[cbc:PaymentMeansCode = '9']/cac:PayeeFinancialAccount/cbc:ID)) = 12 or not(exists(cac:PaymentMeans[cbc:PaymentMeansCode = '9']))">
          <attribute name="id">IS-R-006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-006]-If seller is icelandic and payment means code is 9 then a 12 digit account id must exist — Ef seljandi er íslenskur og greiðslumáti (BT-81) er krafa (kóti 9) þá skal koma fram 12 stafa númer (bankanúmer, höfuðbók 66 og reikningsnúmer) (BT-84)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="exists(cac:PaymentMeans[cbc:PaymentMeansCode = '42']/cac:PayeeFinancialAccount/cbc:ID)         and string-length(normalize-space(cac:PaymentMeans[cbc:PaymentMeansCode = '42']/cac:PayeeFinancialAccount/cbc:ID)) = 12        or not(exists(cac:PaymentMeans[cbc:PaymentMeansCode = '42']))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:PaymentMeans[cbc:PaymentMeansCode = '42']/cac:PayeeFinancialAccount/cbc:ID) and string-length(normalize-space(cac:PaymentMeans[cbc:PaymentMeansCode = '42']/cac:PayeeFinancialAccount/cbc:ID)) = 12 or not(exists(cac:PaymentMeans[cbc:PaymentMeansCode = '42']))">
          <attribute name="id">IS-R-007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-007]-If seller is icelandic and payment means code is 42 then a 12 digit account id must exist — Ef seljandi er íslenskur og greiðslumáti (BT-81) er millifærsla (kóti 42) þá skal koma fram 12 stafa reikningnúmer (BT-84)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']) and string-length(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']/cbc:ID) = 10 and (string(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']/cbc:ID) castable as xs:date)) or not(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']) and string-length(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']/cbc:ID) = 10 and (string(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']/cbc:ID) castable as xs:date)) or not(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']))">
          <attribute name="id">IS-R-008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-008]-If seller is icelandic and invoice contains supporting description EINDAGI then the id form must be YYYY-MM-DD — Ef seljandi er íslenskur þá skal eindagi (BT-122, DocumentDescription = EINDAGI) vera á forminu YYYY-MM-DD.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']) and exists(cbc:DueDate)) or not(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']) and exists(cbc:DueDate)) or not(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']))">
          <attribute name="id">IS-R-009</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-009]-If seller is icelandic and invoice contains supporting description EINDAGI invoice must have due date — Ef seljandi er íslenskur þá skal reikningur sem inniheldur eindaga (BT-122, DocumentDescription = EINDAGI) einnig hafa gjalddaga (BT-9).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']) and (cbc:DueDate) &lt;= (cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']/cbc:ID)) or not(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']) and (cbc:DueDate) &lt;= (cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']/cbc:ID)) or not(exists(cac:AdditionalDocumentReference[cbc:DocumentDescription = 'EINDAGI']))">
          <attribute name="id">IS-R-010</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-010]-If seller is icelandic and invoice contains supporting description EINDAGI the id date must be same or later than due date — Ef seljandi er íslenskur þá skal eindagi (BT-122, DocumentDescription = EINDAGI) skal vera sami eða síðar en gjalddagi (BT-9) ef eindagi er til staðar.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M39" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl-creditnote:CreditNote[$SupplierCountry = 'IS' and $CustomerCountry = 'IS']/cac:AccountingCustomerParty | ubl-invoice:Invoice[$SupplierCountry = 'IS' and $CustomerCountry = 'IS']/cac:AccountingCustomerParty" mode="M39" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl-creditnote:CreditNote[$SupplierCountry = 'IS' and $CustomerCountry = 'IS']/cac:AccountingCustomerParty | ubl-invoice:Invoice[$SupplierCountry = 'IS' and $CustomerCountry = 'IS']/cac:AccountingCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="exists(cac:Party/cac:PartyLegalEntity/cbc:CompanyID) and cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID = '0196'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:Party/cac:PartyLegalEntity/cbc:CompanyID) and cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID = '0196'">
          <attribute name="id">IS-R-004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-004]-If seller and buyer are icelandic then the invoice shall contain the buyers icelandic legal identifier — Ef seljandi og kaupandi eru íslenskir þá skal reikningurinn innihalda íslenska kennitölu kaupanda (BT-47).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="exists(cac:Party/cac:PostalAddress/cbc:StreetName) and exists(cac:Party/cac:PostalAddress/cbc:PostalZone)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cac:Party/cac:PostalAddress/cbc:StreetName) and exists(cac:Party/cac:PostalAddress/cbc:PostalZone)">
          <attribute name="id">IS-R-005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[IS-R-005]-If seller and buyer are icelandic then the invoice shall contain the buyers address with street name and zip code — Ef seljandi og kaupandi eru íslenskir þá skal heimilisfang kaupanda innihalda götuheiti og póstnúmer (BT-50 og BT-53)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M39" select="@*|*" />
  </template>
  <template match="text()" mode="M39" priority="-1" />
  <template match="@*|node()" mode="M39" priority="-2">
    <apply-templates mode="M39" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="supplierCountryIsNL" select="(upper-case(normalize-space(/*/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)) = 'NL')" />
  <variable name="customerCountryIsNL" select="(upper-case(normalize-space(/*/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)) = 'NL')" />
  <variable name="taxRepresentativeCountryIsNL" select="(upper-case(normalize-space(/*/cac:TaxRepresentativeParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode)) = 'NL')" />

	<!--RULE -->
<template match="cbc:CreditNoteTypeCode[$supplierCountryIsNL]" mode="M40" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:CreditNoteTypeCode[$supplierCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="/*/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="/*/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID">
          <attribute name="id">NL-R-001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-001] For suppliers in the Netherlands, if the document is a creditnote, the document MUST contain an invoice reference (cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress[$supplierCountryIsNL]" mode="M40" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party/cac:PostalAddress[$supplierCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:StreetName and cbc:CityName and cbc:PostalZone" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:StreetName and cbc:CityName and cbc:PostalZone">
          <attribute name="id">NL-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-002] For suppliers in the Netherlands the supplier's address (cac:AccountingSupplierParty/cac:Party/cac:PostalAddress) MUST contain street name (cbc:StreetName), city (cbc:CityName) and post code (cbc:PostalZone)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[$supplierCountryIsNL]" mode="M40" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[$supplierCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="(contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0106 ') or contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0190 ')) and (normalize-space(.) != '')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0106 ') or contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0190 ')) and (normalize-space(.) != '')">
          <attribute name="id">NL-R-003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-003] For suppliers in the Netherlands, the legal entity identifier MUST be either a KVK or OIN number (schemeID 0106 or 0190)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress[$supplierCountryIsNL and $customerCountryIsNL]" mode="M40" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty/cac:Party/cac:PostalAddress[$supplierCountryIsNL and $customerCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:StreetName and cbc:CityName and cbc:PostalZone" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:StreetName and cbc:CityName and cbc:PostalZone">
          <attribute name="id">NL-R-004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-004] For suppliers in the Netherlands, if the customer is in the Netherlands, the customer address (cac:AccountingCustomerParty/cac:Party/cac:PostalAddress) MUST contain the street name (cbc:StreetName), the city (cbc:CityName) and post code (cbc:PostalZone)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[$supplierCountryIsNL and $customerCountryIsNL]" mode="M40" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[$supplierCountryIsNL and $customerCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="(contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0106 ') or contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0190 ')) and (normalize-space(.) != '')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0106 ') or contains(concat(' ', string-join(@schemeID, ' '), ' '), ' 0190 ')) and (normalize-space(.) != '')">
          <attribute name="id">NL-R-005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-005] For suppliers in the Netherlands, if the customer is in the Netherlands, the customer's legal entity identifier MUST be either a KVK or OIN number (schemeID 0106 or 0190)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxRepresentativeParty/cac:PostalAddress[$supplierCountryIsNL and $taxRepresentativeCountryIsNL]" mode="M40" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxRepresentativeParty/cac:PostalAddress[$supplierCountryIsNL and $taxRepresentativeCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:StreetName and cbc:CityName and cbc:PostalZone" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:StreetName and cbc:CityName and cbc:PostalZone">
          <attribute name="id">NL-R-006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-006] For suppliers in the Netherlands, if the fiscal representative is in the Netherlands, the representative's address (cac:TaxRepresentativeParty/cac:PostalAddress) MUST contain street name (cbc:StreetName), city (cbc:CityName) and post code (cbc:PostalZone)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:LegalMonetaryTotal[$supplierCountryIsNL]" mode="M40" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:LegalMonetaryTotal[$supplierCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="(/ubl-invoice:Invoice and xs:decimal(cbc:PayableAmount) &lt;= 0.0) or (/ubl-creditnote:CreditNote and xs:decimal(cbc:PayableAmount) >= 0.0) or (//cac:PaymentMeans)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(/ubl-invoice:Invoice and xs:decimal(cbc:PayableAmount) &lt;= 0.0) or (/ubl-creditnote:CreditNote and xs:decimal(cbc:PayableAmount) >= 0.0) or (//cac:PaymentMeans)">
          <attribute name="id">NL-R-007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-007] For suppliers in the Netherlands, the supplier MUST provide a means of payment (cac:PaymentMeans) if the payment is from customer to supplier</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:PaymentMeans[$supplierCountryIsNL and $customerCountryIsNL]" mode="M40" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:PaymentMeans[$supplierCountryIsNL and $customerCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:PaymentMeansCode) = '30' or         normalize-space(cbc:PaymentMeansCode) = '48' or         normalize-space(cbc:PaymentMeansCode) = '49' or         normalize-space(cbc:PaymentMeansCode) = '57' or         normalize-space(cbc:PaymentMeansCode) = '58' or         normalize-space(cbc:PaymentMeansCode) = '59'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:PaymentMeansCode) = '30' or normalize-space(cbc:PaymentMeansCode) = '48' or normalize-space(cbc:PaymentMeansCode) = '49' or normalize-space(cbc:PaymentMeansCode) = '57' or normalize-space(cbc:PaymentMeansCode) = '58' or normalize-space(cbc:PaymentMeansCode) = '59'">
          <attribute name="id">NL-R-008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-008] For suppliers in the Netherlands, if the customer is in the Netherlands, the payment means code (cac:PaymentMeans/cbc:PaymentMeansCode) MUST be one of 30, 48, 49, 57, 58 or 59</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:OrderLineReference/cbc:LineID[$supplierCountryIsNL]" mode="M40" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:OrderLineReference/cbc:LineID[$supplierCountryIsNL]" />

		<!--ASSERT -->
<choose>
      <when test="exists(/*/cac:OrderReference/cbc:ID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(/*/cac:OrderReference/cbc:ID)">
          <attribute name="id">NL-R-009</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>[NL-R-009] For suppliers in the Netherlands, if an order line reference (cac:OrderLineReference/cbc:LineID) is used, there must be an order reference on the document level (cac:OrderReference/cbc:ID)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M40" select="@*|*" />
  </template>
  <template match="text()" mode="M40" priority="-1" />
  <template match="@*|node()" mode="M40" priority="-2">
    <apply-templates mode="M40" select="@*|*" />
  </template>

<!--PATTERN german-rules-->
<variable name="XR-SKONTO-REGEX" select="'#(SKONTO)#TAGE=([0-9]+#PROZENT=[0-9]+\.[0-9]{2})(#BASISBETRAG=-?[0-9]+\.[0-9]{2})?#$'" />
  <variable name="XR-EMAIL-REGEX" select="'^[a-zA-Z0-9!#\$%&amp;&quot;*+/=?^_`{|}~-]+(\.[a-zA-Z0-9!#\$%&amp;&quot;*+/=?^_`{|}~-]+)*@([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$'" />
  <variable name="XR-TELEPHONE-REGEX" select="'.*([0-9].*){3,}.*'" />

	<!--RULE -->
<template match="(/ubl-invoice:Invoice | /ubl-creditnote:CreditNote)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1009">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice | /ubl-creditnote:CreditNote)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cac:PaymentMeans" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PaymentMeans">
          <attribute name="id">DE-R-001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>An invoice shall contain information on "PAYMENT INSTRUCTIONS" (BG-16).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:BuyerReference[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:BuyerReference[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-015</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Buyer reference" (BT-10) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <variable name="supportedVATCodes" select="('S', 'Z', 'E', 'AE', 'K', 'G', 'L', 'M')" />
    <variable name="BT-31orBT-32Path" select="cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID[boolean(normalize-space(.))]" />
    <variable name="BT-95-UBL-Inv" select="cac:AllowanceCharge/cac:TaxCategory/cbc:ID[ancestor::cac:AllowanceCharge/cbc:ChargeIndicator = 'false' and         following-sibling::cac:TaxScheme/cbc:ID = 'VAT']" />
    <variable name="BT-95-UBL-CN" select="cac:AllowanceCharge/cac:TaxCategory/cbc:ID[ancestor::cac:AllowanceCharge/cbc:ChargeIndicator = 'false']" />
    <variable name="BT-102" select="cac:AllowanceCharge/cac:TaxCategory/cbc:ID[ancestor::cac:AllowanceCharge/cbc:ChargeIndicator = 'true']" />
    <variable name="BT-151" select="(cac:InvoiceLine | cac:CreditNoteLine)/cac:Item/cac:ClassifiedTaxCategory/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="         (not(           ($BT-95-UBL-Inv = $supportedVATCodes or $BT-95-UBL-CN = $supportedVATCodes) or           ($BT-102 = $supportedVATCodes) or           ($BT-151 = $supportedVATCodes)         ) or         (cac:TaxRepresentativeParty, $BT-31orBT-32Path))         " />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(not( ($BT-95-UBL-Inv = $supportedVATCodes or $BT-95-UBL-CN = $supportedVATCodes) or ($BT-102 = $supportedVATCodes) or ($BT-151 = $supportedVATCodes) ) or (cac:TaxRepresentativeParty, $BT-31orBT-32Path))">
          <attribute name="id">DE-R-016</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If one of the VAT codes S, Z, E, AE, K, G, L, or M is used, an invoice shall contain at least one of the following elements: "Seller VAT identifier" (BT-31) or "Seller tax registration identifier" (BT-32) or "SELLER TAX REPRESENTATIVE PARTY" (BG-11).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <variable name="supportedInvAndCNTypeCodes" select="('326', '380', '384', '389', '381', '875', '876', '877')" />

		<!--ASSERT -->
<choose>
      <when test="cbc:InvoiceTypeCode = $supportedInvAndCNTypeCodes         or cbc:CreditNoteTypeCode = $supportedInvAndCNTypeCodes" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:InvoiceTypeCode = $supportedInvAndCNTypeCodes or cbc:CreditNoteTypeCode = $supportedInvAndCNTypeCodes">
          <attribute name="id">DE-R-017</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Invoice type code" (BT-3) should only contain the following values from code list UNTDID 1001: 326 (Partial invoice), 380 (Commercial invoice), 384 (Corrected invoice), 389 (Self-billed invoice), 381 (Credit note), 875 (Partial construction invoice), 876 (Partial final construction invoice), 877 (Final construction invoice).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="every $line in             cac:PaymentTerms/cbc:Note[1]/tokenize(. , '(\r?\n)')[starts-with( normalize-space(.) , '#')]              satisfies matches ( normalize-space ($line), $XR-SKONTO-REGEX)                                  and                                 matches( cac:PaymentTerms/cbc:Note[1]/tokenize(. ,  '#.+#')[last()], '^\s*\n' )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="every $line in cac:PaymentTerms/cbc:Note[1]/tokenize(. , '(\r?\n)')[starts-with( normalize-space(.) , '#')] satisfies matches ( normalize-space ($line), $XR-SKONTO-REGEX) and matches( cac:PaymentTerms/cbc:Note[1]/tokenize(. , '#.+#')[last()], '^\s*\n' )">
          <attribute name="id">DE-R-018</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Information on cash discounts for prompt payment (Skonto) shall be provided within the element "Payment terms" BT-20 in the following way: First segment "SKONTO", second segment amount of days ("TAGE=N"), third segment percentage ("PROZENT=N"). Percentage must be separated by dot with two decimal places. In case the base value of the invoiced amount is not provided in BT-115 but as a partial amount, the base value shall be provided as fourth segment "BASISBETRAG=N" as semantic data type amount. Each entry shall start with a #, the segments must be separated by # and a row shall end with a #. A complete statement on cash discount for prompt payment shall end with a XML-conformant line break. All statements on cash discount for prompt payment shall be given in capital letters. Additional whitespaces (blanks, tabulators or line breaks) are not allowed. Other characters or texts than defined above are not allowed.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(cac:AdditionalDocumentReference) =                      count(cac:AdditionalDocumentReference[not(./cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename = preceding-sibling::cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename)])" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(cac:AdditionalDocumentReference) = count(cac:AdditionalDocumentReference[not(./cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename = preceding-sibling::cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename)])">
          <attribute name="id">DE-R-022</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attached documents provided with an invoice in "ADDITIONAL SUPPORTING DOCUMENTS" (BG-24) shall have a unique filename (non case-sensitive) within the element ″Attached document″ (BT-125).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="((not(cbc:InvoiceTypeCode = 384 or cbc:CreditNoteTypeCode = 384) or                     (cac:BillingReference/cac:InvoiceDocumentReference)))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="((not(cbc:InvoiceTypeCode = 384 or cbc:CreditNoteTypeCode = 384) or (cac:BillingReference/cac:InvoiceDocumentReference)))">
          <attribute name="id">DE-R-026</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Invoice type code" (BT-3) contains the code 384 (Corrected invoice), "PRECEDING INVOICE REFERENCE" (BG-3) should be provided at least once.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:PaymentMeans/cac:PaymentMandate)                        or (cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='SEPA']                          | cac:PayeeParty/cac:PartyIdentification/cbc:ID[@schemeID='SEPA'])" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:PaymentMeans/cac:PaymentMandate) or (cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID='SEPA'] | cac:PayeeParty/cac:PartyIdentification/cbc:ID[@schemeID='SEPA'])">
          <attribute name="id">DE-R-030</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If the group "DIRECT DEBIT" (BG-19) is delivered, the element "Bank assigned creditor identifier" (BT-90) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:PaymentMeans/cac:PaymentMandate) or (cac:PaymentMeans/cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:PaymentMeans/cac:PaymentMandate) or (cac:PaymentMeans/cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID)">
          <attribute name="id">DE-R-031</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If the group "DIRECT DEBIT" (BG-19) is delivered, the element "Debited account identifier" (BT-91) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:AccountingSupplierParty | /ubl-creditnote:CreditNote/cac:AccountingSupplierParty)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:AccountingSupplierParty | /ubl-creditnote:CreditNote/cac:AccountingSupplierParty)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party/cac:Contact" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party/cac:Contact">
          <attribute name="id">DE-R-002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The group "SELLER CONTACT" (BG-6) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress | /ubl-creditnote:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress | /ubl-creditnote:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CityName[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CityName[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Seller city" (BT-37) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:PostalZone[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:PostalZone[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Seller post code" (BT-38) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact | /ubl-creditnote:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact | /ubl-creditnote:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:Contact)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Seller contact point" (BT-41) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Telephone[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Telephone[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Seller contact telephone number" (BT-42) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:ElectronicMail[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ElectronicMail[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Seller contact email address" (BT-43) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(cbc:Telephone), $XR-TELEPHONE-REGEX)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(cbc:Telephone), $XR-TELEPHONE-REGEX)">
          <attribute name="id">DE-R-027</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>"Seller contact telephone number" (BT-42) should contain a valid telephone number. A valid telephone should consist of 3 digits minimum.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="matches(normalize-space(cbc:ElectronicMail), $XR-EMAIL-REGEX)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="matches(normalize-space(cbc:ElectronicMail), $XR-EMAIL-REGEX)">
          <attribute name="id">DE-R-028</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>"Seller contact email address" (BT-43) should contain exactly one @-sign, which should not be framed by a whitespace or a dot but by at least two characters on each side. A dot should not be the first or last character.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress | /ubl-creditnote:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress | /ubl-creditnote:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CityName[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CityName[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Buyer city" (BT-52) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:PostalZone[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:PostalZone[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-009</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Buyer post code" (BT-53) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:Delivery/cac:DeliveryLocation/cac:Address | /ubl-creditnote:CreditNote/cac:Delivery/cac:DeliveryLocation/cac:Address)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:Delivery/cac:DeliveryLocation/cac:Address | /ubl-creditnote:CreditNote/cac:Delivery/cac:DeliveryLocation/cac:Address)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CityName[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CityName[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-010</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Deliver to city" (BT-77) shall be provided if the group "DELIVER TO ADDRESS" (BG-15) is delivered.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:PostalZone[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:PostalZone[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-011</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Deliver to post code" (BT-78) shall be provided if the group "DELIVER TO ADDRESS" (BG-15) is delivered.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:PaymentMeans[cbc:PaymentMeansCode = (30,58)] | /ubl-creditnote:CreditNote/cac:PaymentMeans[cbc:PaymentMeansCode = (30,58)])[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:PaymentMeans[cbc:PaymentMeansCode = (30,58)] | /ubl-creditnote:CreditNote/cac:PaymentMeans[cbc:PaymentMeansCode = (30,58)])[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="not(cbc:PaymentMeansCode = '58') or                     matches(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')), '^[A-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}$') and                     xs:integer(string-join(for $cp in string-to-codepoints(concat(substring(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),5),upper-case(substring(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),1,2)),substring(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),3,2))) return  (if($cp > 64) then string($cp - 55) else  string($cp - 48)),'')) mod 97 = 1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:PaymentMeansCode = '58') or matches(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')), '^[A-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}$') and xs:integer(string-join(for $cp in string-to-codepoints(concat(substring(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),5),upper-case(substring(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),1,2)),substring(normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),3,2))) return (if($cp > 64) then string($cp - 55) else string($cp - 48)),'')) mod 97 = 1">
          <attribute name="id">DE-R-019</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Payment account identifier" (BT-84) should contain a valid IBAN if code 58 SEPA is provided in "Payment means type code" (BT-81).</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PayeeFinancialAccount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PayeeFinancialAccount">
          <attribute name="id">DE-R-023-1</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Payment means type code" (BT-81) contains a code for credit transfer (30, 58), "CREDIT TRANSFER" (BG-17) shall
        be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:CardAccount) and                     not(cac:PaymentMandate)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:CardAccount) and not(cac:PaymentMandate)">
          <attribute name="id">DE-R-023-2</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Payment means type code" (BT-81) contains a code for credit transfer (30, 58), BG-18 and BG-19 shall not be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:PaymentMeans[cbc:PaymentMeansCode = (48,54,55)] |/ubl-creditnote:CreditNote/cac:PaymentMeans[cbc:PaymentMeansCode = (48,54,55)])[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:PaymentMeans[cbc:PaymentMeansCode = (48,54,55)] |/ubl-creditnote:CreditNote/cac:PaymentMeans[cbc:PaymentMeansCode = (48,54,55)])[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cac:CardAccount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:CardAccount">
          <attribute name="id">DE-R-024-1</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Payment means type code" (BT-81) contains a code for payment card (48, 54, 55), "PAYMENT CARD INFORMATION" (BG-18) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:PayeeFinancialAccount) and                     not(cac:PaymentMandate)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:PayeeFinancialAccount) and not(cac:PaymentMandate)">
          <attribute name="id">DE-R-024-2</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Payment means type code" (BT-81) contains a code for payment card (48, 54, 55), BG-17 and BG-19 shall not be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:PaymentMeans[cbc:PaymentMeansCode = 59] | /ubl-creditnote:CreditNote/cac:PaymentMeans[cbc:PaymentMeansCode = 59])[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:PaymentMeans[cbc:PaymentMeansCode = 59] | /ubl-creditnote:CreditNote/cac:PaymentMeans[cbc:PaymentMeansCode = 59])[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="not(cbc:PaymentMeansCode = '59') or                     matches(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')), '^[A-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}$') and                     xs:decimal(string-join(for $cp in string-to-codepoints(concat(substring(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),5),upper-case(substring(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),1,2)),substring(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),3,2))) return  (if($cp > 64) then string($cp - 55) else  string($cp - 48)),'')) mod 97 = 1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:PaymentMeansCode = '59') or matches(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')), '^[A-Z]{2}[0-9]{2}[a-zA-Z0-9]{0,30}$') and xs:decimal(string-join(for $cp in string-to-codepoints(concat(substring(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),5),upper-case(substring(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),1,2)),substring(normalize-space(replace(cac:PaymentMandate/cac:PayerFinancialAccount/cbc:ID, '([ \n\r\t\s])', '')),3,2))) return (if($cp > 64) then string($cp - 55) else string($cp - 48)),'')) mod 97 = 1">
          <attribute name="id">DE-R-020</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "Debited account identifier" (BT-91) should contain a valid IBAN if code 59 SEPA is provided in "Payment means type code" (BT-81). </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PaymentMandate" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PaymentMandate">
          <attribute name="id">DE-R-025-1</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Payment means type code" (BT-81) contains a code for direct debit (59), "DIRECT DEBIT" (BG-19) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:PayeeFinancialAccount) and                     not(cac:CardAccount)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:PayeeFinancialAccount) and not(cac:CardAccount)">
          <attribute name="id">DE-R-025-2</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>If "Payment means type code" (BT-81) contains a code for direct debit (59), BG-17 and BG-18 shall not be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>

	<!--RULE -->
<template match="(/ubl-invoice:Invoice/cac:TaxTotal/cac:TaxSubtotal | /ubl-creditnote:CreditNote/cac:TaxTotal/cac:TaxSubtotal)[$supplierCountryIsDE and $customerCountryIsDE]" mode="M41" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="(/ubl-invoice:Invoice/cac:TaxTotal/cac:TaxSubtotal | /ubl-creditnote:CreditNote/cac:TaxTotal/cac:TaxSubtotal)[$supplierCountryIsDE and $customerCountryIsDE]" />

		<!--ASSERT -->
<choose>
      <when test="cac:TaxCategory/cbc:Percent[boolean(normalize-space(.))]" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:TaxCategory/cbc:Percent[boolean(normalize-space(.))]">
          <attribute name="id">DE-R-014</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The element "VAT category rate" (BT-119) shall be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M41" select="@*|*" />
  </template>
  <template match="text()" mode="M41" priority="-1" />
  <template match="@*|node()" mode="M41" priority="-2">
    <apply-templates mode="M41" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="ISO3166" select="tokenize('AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW 1A XI', '\s')" />
  <variable name="ISO4217" select="tokenize('AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD BND BOB BOV BRL BSD BTN BWP BYN BZD CAD CDF CHE CHF CHW CLF CLP CNY COP COU CRC CUP CVE CZK DJF DKK DOP DZD EGP ERN ETB EUR FJD FKP GBP GEL GHS GIP GMD GNF GTQ GYD HKD HNL HTG HUF IDR ILS INR IQD IRR ISK JMD JOD JPY KES KGS KHR KMF KPW KRW KWD KYD KZT LAK LBP LKR LRD LSL LYD MAD MDL MGA MKD MMK MNT MOP MRU MUR MVR MWK MXN MXV MYR MZN NAD NGN NIO NOK NPR NZD OMR PAB PEN PGK PHP PKR PLN PYG QAR RON RSD RUB RWF SAR SBD SCR SDG SEK SGD SHP SLE SOS SRD SSP STN SVC SYP SZL THB TJS TMT TND TOP TRY TTD TWD TZS UAH UGX USD USN UYI UYU UYW UZS VED VES VND VUV WST XAF XAG XAU XBA XBB XBC XBD XCD XDR XOF XPD XPF XPT XSU XTS XUA YER ZAR ZMW ZWG XXX', '\s')" />
  <variable name="MIMECODE" select="tokenize('application/pdf image/png image/jpeg text/csv application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.oasis.opendocument.spreadsheet', '\s')" />
  <variable name="UNCL2005" select="tokenize('3 35 432', '\s')" />
  <variable name="UNCL5189" select="tokenize('41 42 60 62 63 64 65 66 67 68 70 71 88 95 100 102 103 104 105', '\s')" />
  <variable name="UNCL7161" select="tokenize('AA AAA AAC AAD AAE AAF AAH AAI AAS AAT AAV AAY AAZ ABA ABB ABC ABD ABF ABK ABL ABN ABR ABS ABT ABU ACF ACG ACH ACI ACJ ACK ACL ACM ACS ADC ADE ADJ ADK ADL ADM ADN ADO ADP ADQ ADR ADT ADW ADY ADZ AEA AEB AEC AED AEF AEH AEI AEJ AEK AEL AEM AEN AEO AEP AES AET AEU AEV AEW AEX AEY AEZ AJ AU CA CAB CAD CAE CAF CAI CAJ CAK CAL CAM CAN CAO CAP CAQ CAR CAS CAT CAU CAV CAW CAX CAY CAZ CD CG CS CT DAB DAC DAD DAF DAG DAH DAI DAJ DAK DAL DAM DAN DAO DAP DAQ DL EG EP ER FAA FAB FAC FC FH FI GAA HAA HD HH IAA IAB ID IF IR IS KO L1 LA LAA LAB LF MAE MI ML NAA OA PA PAA PC PL PRV RAB RAC RAD RAF RE RF RH RV SA SAA SAD SAE SAI SG SH SM SU TAB TAC TT TV V1 V2 WH XAA YY ZZZ', '\s')" />
  <variable name="UNCL5305" select="tokenize('AE E S Z G O K L M B', '\s')" />
  <variable name="eaid" select="tokenize('0002 0007 0009 0037 0060 0088 0096 0097 0106 0130 0135 0142 0151 0177 0183 0184 0188 0190 0191 0192 0193 0195 0196 0198 0199 0200 0201 0202 0204 0208 0209 0210 0211 0212 0213 0215 0216 0218 0221 0230 0235 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9957 9959 0147 0154 0158 0170 0194 0203 0205 0217 0225 0240', '\s')" />

	<!--RULE -->
<template match="cbc:EmbeddedDocumentBinaryObject[@mimeCode]" mode="M42" priority="1016">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EmbeddedDocumentBinaryObject[@mimeCode]" />

		<!--ASSERT -->
<choose>
      <when test="           some $code in $MIMECODE             satisfies @mimeCode = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $MIMECODE satisfies @mimeCode = $code">
          <attribute name="id">PEPPOL-EN16931-CL001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Mime code must be according to subset of IANA code list.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AllowanceCharge[cbc:ChargeIndicator = 'false']/cbc:AllowanceChargeReasonCode" mode="M42" priority="1015">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AllowanceCharge[cbc:ChargeIndicator = 'false']/cbc:AllowanceChargeReasonCode" />

		<!--ASSERT -->
<choose>
      <when test="           some $code in $UNCL5189             satisfies normalize-space(text()) = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $UNCL5189 satisfies normalize-space(text()) = $code">
          <attribute name="id">PEPPOL-EN16931-CL002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Reason code MUST be according to subset of UNCL 5189 D.16B.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AllowanceCharge[cbc:ChargeIndicator = 'true']/cbc:AllowanceChargeReasonCode" mode="M42" priority="1014">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AllowanceCharge[cbc:ChargeIndicator = 'true']/cbc:AllowanceChargeReasonCode" />

		<!--ASSERT -->
<choose>
      <when test="           some $code in $UNCL7161             satisfies normalize-space(text()) = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $UNCL7161 satisfies normalize-space(text()) = $code">
          <attribute name="id">PEPPOL-EN16931-CL003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Reason code MUST be according to UNCL 7161 D.16B.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:InvoicePeriod/cbc:DescriptionCode" mode="M42" priority="1013">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:InvoicePeriod/cbc:DescriptionCode" />

		<!--ASSERT -->
<choose>
      <when test="           some $code in $UNCL2005             satisfies normalize-space(text()) = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $UNCL2005 satisfies normalize-space(text()) = $code">
          <attribute name="id">PEPPOL-EN16931-CL006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Invoice period description code must be according to UNCL 2005 D.16B.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount" mode="M42" priority="1012">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:Amount | cbc:BaseAmount | cbc:PriceAmount | cbc:TaxAmount | cbc:TaxableAmount | cbc:LineExtensionAmount | cbc:TaxExclusiveAmount | cbc:TaxInclusiveAmount | cbc:AllowanceTotalAmount | cbc:ChargeTotalAmount | cbc:PrepaidAmount | cbc:PayableRoundingAmount | cbc:PayableAmount" />

		<!--ASSERT -->
<choose>
      <when test="           some $code in $ISO4217             satisfies @currencyID = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $ISO4217 satisfies @currencyID = $code">
          <attribute name="id">PEPPOL-EN16931-CL007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Currency code must be according to ISO 4217:2005</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:InvoiceTypeCode" mode="M42" priority="1011">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:InvoiceTypeCode" />

		<!--ASSERT -->
<choose>
      <when test="           $profile != '01' or (some $code in tokenize('71 80 82 84 102 218 219 326 331 380 382 383 384 386 388 393 395 553 575 623 780 817 870 875 876 877', '\s')             satisfies normalize-space(text()) = $code)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$profile != '01' or (some $code in tokenize('71 80 82 84 102 218 219 326 331 380 382 383 384 386 388 393 395 553 575 623 780 817 870 875 876 877', '\s') satisfies normalize-space(text()) = $code)">
          <attribute name="id">PEPPOL-EN16931-P0100</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Invoice type code MUST be set according to the profile.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(normalize-space(.) = '326' or normalize-space(.) = '384') or ($supplierCountryIsDE and $customerCountryIsDE)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(normalize-space(.) = '326' or normalize-space(.) = '384') or ($supplierCountryIsDE and $customerCountryIsDE)">
          <attribute name="id">PEPPOL-EN16931-P0112</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Invoice type code 326 or 384 are only allowed when both buyer and seller are German organizations </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:CreditNoteTypeCode" mode="M42" priority="1010">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:CreditNoteTypeCode" />

		<!--ASSERT -->
<choose>
      <when test="           $profile != '01' or (some $code in tokenize('381 396 81 83 532', '\s')             satisfies normalize-space(text()) = $code)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$profile != '01' or (some $code in tokenize('381 396 81 83 532', '\s') satisfies normalize-space(text()) = $code)">
          <attribute name="id">PEPPOL-EN16931-P0101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Credit note type code MUST be set according to the profile.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate" mode="M42" priority="1009">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate" />

		<!--ASSERT -->
<choose>
      <when test="string-length(text()) = 10 and (string(.) castable as xs:date)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="string-length(text()) = 10 and (string(.) castable as xs:date)">
          <attribute name="id">PEPPOL-EN16931-F001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>A date MUST be formatted YYYY-MM-DD.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID]" mode="M42" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID]" />

		<!--ASSERT -->
<choose>
      <when test="         some $code in $eaid         satisfies @schemeID = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $eaid satisfies @schemeID = $code">
          <attribute name="id">PEPPOL-EN16931-CL008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Electronic address identifier scheme must be from the codelist "Electronic Address Identifier Scheme"</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-G']" mode="M42" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-G']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='G'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='G'">
          <attribute name="id">PEPPOL-EN16931-P0104</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category G MUST be used when exemption reason code is VATEX-EU-G</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-O']" mode="M42" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-O']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='O'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='O'">
          <attribute name="id">PEPPOL-EN16931-P0105</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category O MUST be used when exemption reason code is VATEX-EU-O</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-IC']" mode="M42" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-IC']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='K'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='K'">
          <attribute name="id">PEPPOL-EN16931-P0106</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category K MUST be used when exemption reason code is VATEX-EU-IC</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-AE']" mode="M42" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-AE']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='AE'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='AE'">
          <attribute name="id">PEPPOL-EN16931-P0107</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category AE MUST be used when exemption reason code is VATEX-EU-AE</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-D']" mode="M42" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-D']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='E'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='E'">
          <attribute name="id">PEPPOL-EN16931-P0108</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category E MUST be used when exemption reason code is VATEX-EU-D</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-F']" mode="M42" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-F']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='E'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='E'">
          <attribute name="id">PEPPOL-EN16931-P0109</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category E MUST be used when exemption reason code is VATEX-EU-F</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-I']" mode="M42" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-I']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='E'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='E'">
          <attribute name="id">PEPPOL-EN16931-P0110</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category E MUST be used when exemption reason code is VATEX-EU-I</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-J']" mode="M42" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory[upper-case(cbc:TaxExemptionReasonCode)='VATEX-EU-J']" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(cbc:ID)='E'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(cbc:ID)='E'">
          <attribute name="id">PEPPOL-EN16931-P0111</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Tax Category E MUST be used when exemption reason code is VATEX-EU-J</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M42" select="@*|*" />
  </template>
  <template match="text()" mode="M42" priority="-1" />
  <template match="@*|node()" mode="M42" priority="-2">
    <apply-templates mode="M42" select="@*|*" />
  </template>
</stylesheet>
