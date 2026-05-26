<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" 
            xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
            xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
            xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:Order-2"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:u="utils"
            version="2.0">
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
<key match="cac:LineItem" name="k_lineId" use="cbc:ID" />
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
  <function as="xs:boolean" name="u:checkCodiceIPA">
      <param as="xs:string?" name="arg" />
      <variable name="allowed-characters">ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789</variable>
      <sequence select="if ( (string-length(translate($arg, $allowed-characters, '')) = 0) and (string-length($arg) = 6) ) then true() else false()" />
  </function>
  <function as="xs:integer" name="u:addPIVA">
      <param as="xs:string" name="arg" />
      <param as="xs:integer" name="pari" />
      <variable name="tappo" select="if (not($arg castable as xs:integer)) then 0 else 1" />
      <variable name="mapper" select="if ($tappo = 0) then 0 else                    ( if ($pari = 1)                     then ( xs:integer(substring('0246813579', ( xs:integer(substring($arg,1,1)) +1 ) ,1)) )                     else ( xs:integer(substring($arg,1,1) ) )                   )" />
      <sequence select="if ($tappo = 0) then $mapper else ( xs:integer($mapper) + u:addPIVA(substring(xs:string($arg),2), (if($pari=0) then 1 else 0) ) )" />
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
  <function as="xs:integer" name="u:checkPIVA">
      <param as="xs:string?" name="arg" />
      <sequence select="     if (not($arg castable as xs:integer))       then 1      else ( u:addPIVA($arg,xs:integer(0)) mod 10 )" />
  </function>
  <function as="xs:boolean" name="u:checkPIVAseIT">
      <param as="xs:string" name="arg" />
      <variable name="paese" select="substring($arg,1,2)" />
      <variable name="codice" select="substring($arg,3)" />
      <sequence select="       if ( $paese = 'IT' or $paese = 'it' )    then    (     if ( ( string-length($codice) = 11 ) and ( if (u:checkPIVA($codice)!=0) then false() else true() ))     then      (      true()     )     else     (      false()     )    )    else    (     true()    )      " />
  </function>
  <function as="xs:boolean" name="u:mod97-0208">
      <param name="val" />
      <variable name="checkdigits" select="substring($val,9,2)" />
      <variable name="calculated_digits" select="xs:string(97 - (xs:integer(substring($val,1,8)) mod 97))" />
      <value-of select="number($checkdigits) = number($calculated_digits)" />
  </function>
  <function as="xs:boolean" name="u:abn">
      <param name="val" />
      <value-of select="( ((string-to-codepoints(substring($val,1,1)) - 49) * 10) + ((string-to-codepoints(substring($val,2,1)) - 48) * 1) + ((string-to-codepoints(substring($val,3,1)) - 48) * 3) + ((string-to-codepoints(substring($val,4,1)) - 48) * 5) + ((string-to-codepoints(substring($val,5,1)) - 48) * 7) + ((string-to-codepoints(substring($val,6,1)) - 48) * 9) + ((string-to-codepoints(substring($val,7,1)) - 48) * 11) + ((string-to-codepoints(substring($val,8,1)) - 48) * 13) + ((string-to-codepoints(substring($val,9,1)) - 48) * 15) + ((string-to-codepoints(substring($val,10,1)) - 48) * 17) + ((string-to-codepoints(substring($val,11,1)) - 48) * 19)) mod 89 = 0 " />
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
    <ns0:schematron-output xmlns:ns0="http://purl.oclc.org/dsdl/svrl" schemaVersion="iso" title="Rules for Peppol Order transaction 3.6">
      <comment>
        <value-of select="$archiveDirParameter" />   
		 <value-of select="$archiveNameParameter" />  
		 <value-of select="$fileNameParameter" />  
		 <value-of select="$fileDirParameter" />
      </comment>
      <ns0:ns-prefix-in-attribute-values prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" />
      <ns0:ns-prefix-in-attribute-values prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" />
      <ns0:ns-prefix-in-attribute-values prefix="ubl" uri="urn:oasis:names:specification:ubl:schema:xsd:Order-2" />
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
      <apply-templates mode="M19" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M20" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M21" select="/" />
      <ns0:active-pattern>
        <attribute name="document">
          <value-of select="document-uri(/)" />
        </attribute>
        <attribute name="documents">
          <value-of select="document-uri(/)" />
        </attribute>
        <apply-templates />
      </ns0:active-pattern>
      <apply-templates mode="M22" select="/" />
    </ns0:schematron-output>
  </template>

<!--SCHEMATRON PATTERNS-->
<ns0:text xmlns:ns0="http://purl.oclc.org/dsdl/svrl">Rules for Peppol Order transaction 3.6</ns0:text>

<!--PATTERN -->


	<!--RULE -->
<template match="//*[not(*) and not(normalize-space())]" mode="M19" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="//*[not(*) and not(normalize-space())]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-COMMON-R001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST not contain empty elements.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M19" select="@*|*" />
  </template>
  <template match="text()" mode="M19" priority="-1" />
  <template match="@*|node()" mode="M19" priority="-2">
    <apply-templates mode="M19" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="/*" mode="M20" priority="1011">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/*" />

		<!--ASSERT -->
<choose>
      <when test="not(@*:schemaLocation)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@*:schemaLocation)">
          <attribute name="id">PEPPOL-COMMON-R003</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document SHOULD not contain schema location.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate" mode="M20" priority="1010">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate" />

		<!--ASSERT -->
<choose>
      <when test="(string(.) castable as xs:date) and (string-length(.) = 10)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(string(.) castable as xs:date) and (string-length(.) = 10)">
          <attribute name="id">PEPPOL-COMMON-R030</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>A date must be formatted YYYY-MM-DD.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']" mode="M20" priority="1009">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0192'] | cac:PartyIdentification/cbc:ID[@schemeID = '0192'] | cbc:CompanyID[@schemeID = '0192']" mode="M20" priority="1008">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0208'] | cac:PartyIdentification/cbc:ID[@schemeID = '0208'] | cbc:CompanyID[@schemeID = '0208']" mode="M20" priority="1007">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0201'] | cac:PartyIdentification/cbc:ID[@schemeID = '0201'] | cbc:CompanyID[@schemeID = '0201']" mode="M20" priority="1006">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0210'] | cac:PartyIdentification/cbc:ID[@schemeID = '0210'] | cbc:CompanyID[@schemeID = '0210']" mode="M20" priority="1005">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '9907']" mode="M20" priority="1004">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0211'] | cac:PartyIdentification/cbc:ID[@schemeID = '0211'] | cbc:CompanyID[@schemeID = '0211']" mode="M20" priority="1003">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '9906']" mode="M20" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:EndpointID[@schemeID = '9906']" />

		<!--ASSERT -->
<choose>
      <when test="u:checkPIVAseIT(normalize-space())" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:checkPIVAseIT(normalize-space())">
          <attribute name="id">PEPPOL-COMMON-R048</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Italian VAT Code (Partita Iva) must be stated in the correct format</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0007'] | cac:PartyIdentification/cbc:ID[@schemeID = '0007'] | cbc:CompanyID[@schemeID = '0007']" mode="M20" priority="1001">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0151'] | cac:PartyIdentification/cbc:ID[@schemeID = '0151'] | cbc:CompanyID[@schemeID = '0151']" mode="M20" priority="1000">
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
    <apply-templates mode="M20" select="@*|*" />
  </template>
  <template match="text()" mode="M20" priority="-1" />
  <template match="@*|node()" mode="M20" priority="-2">
    <apply-templates mode="M20" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="clISO4217" select="tokenize('AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD BND BOB BOV BRL BSD BTN BWP BYN BZD CAD CDF CHE CHF CHW CLF CLP CNY COP COU CRC CUP CVE CZK DJF DKK DOP DZD EGP ERN ETB EUR FJD FKP GBP GEL GHS GIP GMD GNF GTQ GYD HKD HNL HTG HUF IDR ILS INR IQD IRR ISK JMD JOD JPY KES KGS KHR KMF KPW KRW KWD KYD KZT LAK LBP LKR LRD LSL LYD MAD MDL MGA MKD MMK MNT MOP MRU MUR MVR MWK MXN MXV MYR MZN NAD NGN NIO NOK NPR NZD OMR PAB PEN PGK PHP PKR PLN PYG QAR RON RSD RUB RWF SAR SBD SCR SDG SEK SGD SHP SLE SOS SRD SSP STN SVC SYP SZL THB TJS TMT TND TOP TRY TTD TWD TZS UAH UGX USD USN UYI UYU UYW UZS VED VES VND VUV WST XAF XAG XAU XBA XBB XBC XBD XCD XDR XOF XPD XPF XPT XSU XTS XUA YER ZAR ZMW ZWG XXX', '\s')" />
  <variable name="clICD" select="tokenize('0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025 0026 0027 0028 0029 0030 0031 0032 0033 0034 0035 0036 0037 0038 0039 0040 0041 0042 0043 0044 0045 0046 0047 0048 0049 0050 0051 0052 0053 0054 0055 0056 0057 0058 0059 0060 0061 0062 0063 0064 0065 0066 0067 0068 0069 0070 0071 0072 0073 0074 0075 0076 0077 0078 0079 0080 0081 0082 0083 0084 0085 0086 0087 0088 0089 0090 0091 0093 0094 0095 0096 0097 0098 0099 0100 0101 0102 0104 0105 0106 0107 0108 0109 0110 0111 0112 0113 0114 0115 0116 0117 0118 0119 0120 0121 0122 0123 0124 0125 0126 0127 0128 0129 0130 0131 0132 0133 0134 0135 0136 0137 0138 0139 0140 0141 0142 0143 0144 0145 0146 0147 0148 0149 0150 0151 0152 0153 0154 0155 0156 0157 0158 0159 0160 0161 0162 0163 0164 0165 0166 0167 0168 0169 0170 0171 0172 0173 0174 0175 0176 0177 0178 0179 0180 0183 0184 0185 0186 0187 0188 0189 0190 0191 0192 0193 0194 0195 0196 0197 0198 0199 0200 0201 0202 0203 0204 0205 0206 0207 0208 0209 0210 0211 0212 0213 0214 0215 0216 0217 0218 0219 0220 0221 0222 0223 0224 0225 0226 0227 0228 0229 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 0240', '\s')" />
  <variable name="clTrueFalse" select="tokenize('true false', '\s')" />
  <variable name="clUNCL5189" select="tokenize('41 42 60 62 63 64 65 66 67 68 70 71 88 95 100 102 103 104 105', '\s')" />
  <variable name="clUNECERec20" select="tokenize('10 11 13 14 15 20 21 22 23 24 25 27 28 33 34 35 37 38 40 41 56 57 58 59 60 61 74 77 80 81 85 87 89 91 1I 2A 2B 2C 2G 2H 2I 2J 2K 2L 2M 2N 2P 2Q 2R 2U 2X 2Y 2Z 3B 3C 4C 4G 4H 4K 4L 4M 4N 4O 4P 4Q 4R 4T 4U 4W 4X 5A 5B 5E 5J A10 A11 A12 A13 A14 A15 A16 A17 A18 A19 A2 A20 A21 A22 A23 A24 A26 A27 A28 A29 A3 A30 A31 A32 A33 A34 A35 A36 A37 A38 A39 A4 A40 A41 A42 A43 A44 A45 A47 A48 A49 A5 A53 A54 A55 A56 A59 A6 A68 A69 A7 A70 A71 A73 A74 A75 A76 A8 A84 A85 A86 A87 A88 A89 A9 A90 A91 A93 A94 A95 A96 A97 A98 A99 AA AB ACR ACT AD AE AH AI AK AL AMH AMP ANN APZ AQ AS ASM ASU ATM AWG AY AZ B1 B10 B11 B12 B13 B14 B15 B16 B17 B18 B19 B20 B21 B22 B23 B24 B25 B26 B27 B28 B29 B3 B30 B31 B32 B33 B34 B35 B4 B41 B42 B43 B44 B45 B46 B47 B48 B49 B50 B52 B53 B54 B55 B56 B57 B58 B59 B60 B61 B62 B63 B64 B66 B67 B68 B69 B7 B70 B71 B72 B73 B74 B75 B76 B77 B78 B79 B8 B80 B81 B82 B83 B84 B85 B86 B87 B88 B89 B90 B91 B92 B93 B94 B95 B96 B97 B98 B99 BAR BB BFT BHP BIL BLD BLL BP BPM BQL BTU BUA BUI C0 C10 C11 C12 C13 C14 C15 C16 C17 C18 C19 C20 C21 C22 C23 C24 C25 C26 C27 C28 C29 C3 C30 C31 C32 C33 C34 C35 C36 C37 C38 C39 C40 C41 C42 C43 C44 C45 C46 C47 C48 C49 C50 C51 C52 C53 C54 C55 C56 C57 C58 C59 C60 C61 C62 C63 C64 C65 C66 C67 C68 C69 C7 C70 C71 C72 C73 C74 C75 C76 C78 C79 C8 C80 C81 C82 C83 C84 C85 C86 C87 C88 C89 C9 C90 C91 C92 C93 C94 C95 C96 C97 C99 CCT CDL CEL CEN CG CGM CKG CLF CLT CMK CMQ CMT CNP CNT COU CTG CTM CTN CUR CWA CWI D03 D04 D1 D10 D11 D12 D13 D15 D16 D17 D18 D19 D2 D20 D21 D22 D23 D24 D25 D26 D27 D29 D30 D31 D32 D33 D34 D36 D41 D42 D43 D44 D45 D46 D47 D48 D49 D5 D50 D51 D52 D53 D54 D55 D56 D57 D58 D59 D6 D60 D61 D62 D63 D65 D68 D69 D73 D74 D77 D78 D80 D81 D82 D83 D85 D86 D87 D88 D89 D91 D93 D94 D95 DAA DAD DAY DB DBM DBW DD DEC DG DJ DLT DMA DMK DMO DMQ DMT DN DPC DPR DPT DRA DRI DRL DT DTN DWT DZN DZP E01 E07 E08 E09 E10 E12 E14 E15 E16 E17 E18 E19 E20 E21 E22 E23 E25 E27 E28 E30 E31 E32 E33 E34 E35 E36 E37 E38 E39 E4 E40 E41 E42 E43 E44 E45 E46 E47 E48 E49 E50 E51 E52 E53 E54 E55 E56 E57 E58 E59 E60 E61 E62 E63 E64 E65 E66 E67 E68 E69 E70 E71 E72 E73 E74 E75 E76 E77 E78 E79 E80 E81 E82 E83 E84 E85 E86 E87 E88 E89 E90 E91 E92 E93 E94 E95 E96 E97 E98 E99 EA EB EQ F01 F02 F03 F04 F05 F06 F07 F08 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24 F25 F26 F27 F28 F29 F30 F31 F32 F33 F34 F35 F36 F37 F38 F39 F40 F41 F42 F43 F44 F45 F46 F47 F48 F49 F50 F51 F52 F53 F54 F55 F56 F57 F58 F59 F60 F61 F62 F63 F64 F65 F66 F67 F68 F69 F70 F71 F72 F73 F74 F75 F76 F77 F78 F79 F80 F81 F82 F83 F84 F85 F86 F87 F88 F89 F90 F91 F92 F93 F94 F95 F96 F97 F98 F99 FAH FAR FBM FC FF FH FIT FL FNU FOT FP FR FS FTK FTQ G01 G04 G05 G06 G08 G09 G10 G11 G12 G13 G14 G15 G16 G17 G18 G19 G2 G20 G21 G23 G24 G25 G26 G27 G28 G29 G3 G30 G31 G32 G33 G34 G35 G36 G37 G38 G39 G40 G41 G42 G43 G44 G45 G46 G47 G48 G49 G50 G51 G52 G53 G54 G55 G56 G57 G58 G59 G60 G61 G62 G63 G64 G65 G66 G67 G68 G69 G70 G71 G72 G73 G74 G75 G76 G77 G78 G79 G80 G81 G82 G83 G84 G85 G86 G87 G88 G89 G90 G91 G92 G93 G94 G95 G96 G97 G98 G99 GB GBQ GDW GE GF GFI GGR GIA GIC GII GIP GJ GL GLD GLI GLL GM GO GP GQ GRM GRN GRO GV GWH H03 H04 H05 H06 H07 H08 H09 H10 H11 H12 H13 H14 H15 H16 H18 H19 H20 H21 H22 H23 H24 H25 H26 H27 H28 H29 H30 H31 H32 H33 H34 H35 H36 H37 H38 H39 H40 H41 H42 H43 H44 H45 H46 H47 H48 H49 H50 H51 H52 H53 H54 H55 H56 H57 H58 H59 H60 H61 H62 H63 H64 H65 H66 H67 H68 H69 H70 H71 H72 H73 H74 H75 H76 H77 H79 H80 H81 H82 H83 H84 H85 H87 H88 H89 H90 H91 H92 H93 H94 H95 H96 H98 H99 HA HAD HBA HBX HC HDW HEA HGM HH HIU HKM HLT HM HMO HMQ HMT HPA HTZ HUR HWE IA IE INH INK INQ ISD IU IUG IV J10 J12 J13 J14 J15 J16 J17 J18 J19 J2 J20 J21 J22 J23 J24 J25 J26 J27 J28 J29 J30 J31 J32 J33 J34 J35 J36 J38 J39 J40 J41 J42 J43 J44 J45 J46 J47 J48 J49 J50 J51 J52 J53 J54 J55 J56 J57 J58 J59 J60 J61 J62 J63 J64 J65 J66 J67 J68 J69 J70 J71 J72 J73 J74 J75 J76 J78 J79 J81 J82 J83 J84 J85 J87 J90 J91 J92 J93 J95 J96 J97 J98 J99 JE JK JM JNT JOU JPS JWL K1 K10 K11 K12 K13 K14 K15 K16 K17 K18 K19 K2 K20 K21 K22 K23 K26 K27 K28 K3 K30 K31 K32 K33 K34 K35 K36 K37 K38 K39 K40 K41 K42 K43 K45 K46 K47 K48 K49 K50 K51 K52 K53 K54 K55 K58 K59 K6 K60 K61 K62 K63 K64 K65 K66 K67 K68 K69 K70 K71 K73 K74 K75 K76 K77 K78 K79 K80 K81 K82 K83 K84 K85 K86 K87 K88 K89 K90 K91 K92 K93 K94 K95 K96 K97 K98 K99 KA KAT KB KBA KCC KDW KEL KGM KGS KHY KHZ KI KIC KIP KJ KJO KL KLK KLX KMA KMH KMK KMQ KMT KNI KNM KNS KNT KO KPA KPH KPO KPP KR KSD KSH KT KTN KUR KVA KVR KVT KW KWH KWN KWO KWS KWT KWY KX L10 L11 L12 L13 L14 L15 L16 L17 L18 L19 L2 L20 L21 L23 L24 L25 L26 L27 L28 L29 L30 L31 L32 L33 L34 L35 L36 L37 L38 L39 L40 L41 L42 L43 L44 L45 L46 L47 L48 L49 L50 L51 L52 L53 L54 L55 L56 L57 L58 L59 L60 L63 L64 L65 L66 L67 L68 L69 L70 L71 L72 L73 L74 L75 L76 L77 L78 L79 L80 L81 L82 L83 L84 L85 L86 L87 L88 L89 L90 L91 L92 L93 L94 L95 L96 L98 L99 LA LAC LBR LBT LD LEF LF LH LK LM LN LO LP LPA LR LS LTN LTR LUB LUM LUX LY M1 M10 M11 M12 M13 M14 M15 M16 M17 M18 M19 M20 M21 M22 M23 M24 M25 M26 M27 M29 M30 M31 M32 M33 M34 M35 M36 M37 M38 M39 M4 M40 M41 M42 M43 M44 M45 M46 M47 M48 M49 M5 M50 M51 M52 M53 M55 M56 M57 M58 M59 M60 M61 M62 M63 M64 M65 M66 M67 M68 M69 M7 M70 M71 M72 M73 M74 M75 M76 M77 M78 M79 M80 M81 M82 M83 M84 M85 M86 M87 M88 M89 M9 M90 M91 M92 M93 M94 M95 M96 M97 M98 M99 MAH MAL MAM MAR MAW MBE MBF MBR MC MCU MD MGM MHZ MIK MIL MIN MIO MIU MKD MKM MKW MLD MLT MMK MMQ MMT MND MNJ MON MPA MQD MQH MQM MQS MQW MRD MRM MRW MSK MTK MTQ MTR MTS MTZ MVA MWH N1 N10 N11 N12 N13 N14 N15 N16 N17 N18 N19 N20 N21 N22 N23 N24 N25 N26 N27 N28 N29 N3 N30 N31 N32 N33 N34 N35 N36 N37 N38 N39 N40 N41 N42 N43 N44 N45 N46 N47 N48 N49 N50 N51 N52 N53 N54 N55 N56 N57 N58 N59 N60 N61 N62 N63 N64 N65 N66 N67 N68 N69 N70 N71 N72 N73 N74 N75 N76 N77 N78 N79 N80 N81 N82 N83 N84 N85 N86 N87 N88 N89 N90 N91 N92 N93 N94 N95 N96 N97 N98 N99 NA NAR NCL NEW NF NIL NIU NL NM3 NMI NMP NPT NT NTU NU NX OA ODE ODG ODK ODM OHM ON ONZ OPM OT OZA OZI P1 P10 P11 P12 P13 P14 P15 P16 P17 P18 P19 P2 P20 P21 P22 P23 P24 P25 P26 P27 P28 P29 P30 P31 P32 P33 P34 P35 P36 P37 P38 P39 P40 P41 P42 P43 P44 P45 P46 P47 P48 P49 P5 P50 P51 P52 P53 P54 P55 P56 P57 P58 P59 P60 P61 P62 P63 P64 P65 P66 P67 P68 P69 P70 P71 P72 P73 P74 P75 P76 P77 P78 P79 P80 P81 P82 P83 P84 P85 P86 P87 P88 P89 P90 P91 P92 P93 P94 P95 P96 P97 P98 P99 PAL PD PFL PGL PI PLA PO PQ PR PS PTD PTI PTL PTN Q10 Q11 Q12 Q13 Q14 Q15 Q16 Q17 Q18 Q19 Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q29 Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q37 Q38 Q39 Q40 Q41 Q42 Q3 QA QAN QB QR QTD QTI QTL QTR R1 R9 RH RM ROM RP RPM RPS RT S3 S4 SAN SCO SCR SEC SET SG SIE SM3 SMI SQ SQR SR STC STI STK STL STN STW SW SX SYR T0 T3 TAH TAN TI TIC TIP TKM TMS TNE TP TPI TPR TQD TRL TST TTS U1 U2 UB UC VA VLT VP W2 WA WB WCD WE WEB WEE WG WHR WM WSD WTT X1 YDK YDQ YRD Z11 Z9 ZP ZZ X1A X1B X1D X1F X1G X1W X2C X3A X3H X43 X44 X4A X4B X4C X4D X4F X4G X4H X5H X5L X5M X6H X6P X7A X7B X8A X8B X8C XAA XAB XAC XAD XAE XAF XAG XAH XAI XAJ XAL XAM XAP XAT XAV XB4 XBA XBB XBC XBD XBE XBF XBG XBH XBI XBJ XBK XBL XBM XBN XBO XBP XBQ XBR XBS XBT XBU XBV XBW XBX XBY XBZ XCA XCB XCC XCD XCE XCF XCG XCH XCI XCJ XCK XCL XCM XCN XCO XCP XCQ XCR XCS XCT XCU XCV XCW XCX XCY XCZ XDA XDB XDC XDG XDH XDI XDJ XDK XDL XDM XDN XDP XDR XDS XDT XDU XDV XDW XDX XDY XEC XED XEE XEF XEG XEH XEI XEN XFB XFC XFD XFE XFI XFL XFO XFP XFR XFT XFW XFX XGB XGI XGL XGR XGU XGY XGZ XHA XHB XHC XHG XHN XHR XIA XIB XIC XID XIE XIF XIG XIH XIK XIL XIN XIZ XJB XJC XJG XJR XJT XJY XKG XKI XLE XLG XLT XLU XLV XLZ XMA XMB XMC XME XMR XMS XMT XMW XMX XNA XNE XNF XNG XNS XNT XNU XNV XO1 XO2 XO3 XO4 XO5 XO6 XO7 XO8 XO9 XOA XOB XOC XOD XOE XOF XOG XOH XOI XOK XOJ XOL XOM XON XOP XOQ XOR XOS XOV XOW XOT XOU XOX XOY XOZ XP1 XP2 XP3 XP4 XPA XPB XPC XPD XPE XPF XPG XPH XPI XPJ XPK XPL XPN XPO XPP XPR XPT XPU XPV XPX XPY XPZ XQA XQB XQC XQD XQF XQG XQH XQJ XQK XQL XQM XQN XQP XQQ XQR XQS XRD XRG XRJ XRK XRL XRO XRT XRZ XSA XSB XSC XSD XSE XSH XSI XSK XSL XSM XSO XSP XSS XST XSU XSV XSW XSX XSY XSZ XT1 XTB XTC XTD XTE XTG XTI XTK XTL XTN XTO XTR XTS XTT XTU XTV XTW XTY XTZ XUC XUN XVA XVG XVI XVK XVL XVO XVP XVQ XVN XVR XVS XVY XWA XWB XWC XWD XWF XWG XWH XWJ XWK XWL XWM XWN XWP XWQ XWR XWS XWT XWU XWV XWW XWX XWY XWZ XXA XXB XXC XXD XXF XXG XXH XXJ XXK XYA XYB XYC XYD XYF XYG XYH XYJ XYK XYL XYM XYN XYP XYQ XYR XYS XYT XYV XYW XYX XYY XYZ XZA XZB XZC XZD XZF XZG XZH XZJ XZK XZL XZM XZN XZP XZQ XZR XZS XZT XZU XZV XZW XZX XZY XZZ', '\s')" />
  <variable name="clMimeCode" select="tokenize('application/pdf image/png image/jpeg image/tiff application/acad application/dwg drawing/dwg application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.oasis.opendocument.spreadsheet', '\s')" />
  <variable name="clUNCL1001_T01" select="tokenize('105 220 221 226 227 402', '\s')" />
  <variable name="clUNCL7143" select="tokenize('AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CC CG CL CR CV DR DW EC EF EMD EN FS GB GMN GN GS HS IB IN IS IT IZ MA MF MN MP NB ON PD PL PO PV QS RC RN RU RY SA SG SK SN SRS SRT SRU SRV SRW SRX SRY SRZ SS SSA SSB SSC SSD SSE SSF SSG SSH SSI SSJ SSK SSL SSM SSN SSO SSP SSQ SSR SSS SST SSU SSV SSW SSX SSY SSZ ST STA STB STC STD STE STF STG STH STI STJ STK STL STM STN STO STP STQ STR STS STT STU STV STW STX STY STZ SUA SUB SUC SUD SUE SUF SUG SUH SUI SUJ SUK SUL SUM TG TSN TSO TSP TSQ TSR TSS TST TSU UA UP VN VP VS VX ZZZ PPI', '\s')" />
  <variable name="clUNCL4219" select="tokenize('1 2 3 4', '\s')" />
  <variable name="clISO3166" select="tokenize('AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW 1A XI', '\s')" />
  <variable name="cleas" select="tokenize('0002 0007 0009 0060 0088 0096 0097 0106 0130 0135 0142 0151 0183 0184 0188 0190 0191 0192 0193 0195 0196 0198 0199 0200 0201 0204 0208 0209 0210 0211 0216 0218 0221 0230 0235 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9957 9959 0205 0225 0240', '\s')" />
  <variable name="clUNCL7161" select="tokenize('AA AAA AAC AAD AAE AAF AAH AAI AAS AAT AAV AAY AAZ ABA ABB ABC ABD ABF ABK ABL ABN ABR ABS ABT ABU ACF ACG ACH ACI ACJ ACK ACL ACM ACS ADC ADE ADJ ADK ADL ADM ADN ADO ADP ADQ ADR ADT ADW ADY ADZ AEA AEB AEC AED AEF AEH AEI AEJ AEK AEL AEM AEN AEO AEP AES AET AEU AEV AEW AEX AEY AEZ AJ AU CA CAB CAD CAE CAF CAI CAJ CAK CAL CAM CAN CAO CAP CAQ CAR CAS CAT CAU CAV CAW CD CG CS CT DAB DAD DL EG EP ER FAA FAB FAC FC FH FI GAA HAA HD HH IAA IAB ID IF IR IS KO L1 LA LAA LAB LF MAE MI ML NAA OA PA PAA PC PL RAB RAC RAD RAF RE RF RH RV SA SAA SAD SAE SAI SG SH SM SU TAB TAC TT TV V1 V2 WH XAA YY ZZZ', '\s')" />

	<!--RULE -->
<template match="/ubl:Order" mode="M21" priority="1357">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CustomizationID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CustomizationID">
          <attribute name="id">PEPPOL-T01-B00101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:CustomizationID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:ProfileID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ProfileID">
          <attribute name="id">PEPPOL-T01-B00102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ProfileID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B00103</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:IssueDate" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IssueDate">
          <attribute name="id">PEPPOL-T01-B00104</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IssueDate' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:DocumentCurrencyCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:DocumentCurrencyCode">
          <attribute name="id">PEPPOL-T01-B00105</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:DocumentCurrencyCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:BuyerCustomerParty" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:BuyerCustomerParty">
          <attribute name="id">PEPPOL-T01-B00106</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:BuyerCustomerParty' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:SellerSupplierParty" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:SellerSupplierParty">
          <attribute name="id">PEPPOL-T01-B00107</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:SellerSupplierParty' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:OrderLine" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:OrderLine">
          <attribute name="id">PEPPOL-T01-B00108</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:OrderLine' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@*:schemaLocation)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@*:schemaLocation)">
          <attribute name="id">PEPPOL-T01-B00109</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST not contain schema location.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:CustomizationID" mode="M21" priority="1356">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:CustomizationID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:ProfileID" mode="M21" priority="1355">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:ProfileID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:ID" mode="M21" priority="1354">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:SalesOrderID" mode="M21" priority="1353">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:SalesOrderID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:IssueDate" mode="M21" priority="1352">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:IssueDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:IssueTime" mode="M21" priority="1351">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:IssueTime" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:OrderTypeCode" mode="M21" priority="1350">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:OrderTypeCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clUNCL1001_T01 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clUNCL1001_T01 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B00801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Order type code (UNCL1001 subset)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:Note" mode="M21" priority="1349">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:Note" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:DocumentCurrencyCode" mode="M21" priority="1348">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:DocumentCurrencyCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO4217 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO4217 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B01001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:CustomerReference" mode="M21" priority="1347">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:CustomerReference" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cbc:AccountingCost" mode="M21" priority="1346">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cbc:AccountingCost" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:ValidityPeriod" mode="M21" priority="1345">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:ValidityPeriod" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndDate" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndDate">
          <attribute name="id">PEPPOL-T01-B01301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:EndDate' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:ValidityPeriod/cbc:EndDate" mode="M21" priority="1344">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:ValidityPeriod/cbc:EndDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:ValidityPeriod/*" mode="M21" priority="1343">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:ValidityPeriod/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B01302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:QuotationDocumentReference" mode="M21" priority="1342">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:QuotationDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B01501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:QuotationDocumentReference/cbc:ID" mode="M21" priority="1341">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:QuotationDocumentReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:QuotationDocumentReference/*" mode="M21" priority="1340">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:QuotationDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B01502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderDocumentReference" mode="M21" priority="1339">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B01701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderDocumentReference/cbc:ID" mode="M21" priority="1338">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderDocumentReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderDocumentReference/*" mode="M21" priority="1337">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B01702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorDocumentReference" mode="M21" priority="1336">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B01901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorDocumentReference/cbc:ID" mode="M21" priority="1335">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorDocumentReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorDocumentReference/*" mode="M21" priority="1334">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B01902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:CatalogueReference" mode="M21" priority="1333">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:CatalogueReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B02101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:CatalogueReference/cbc:ID" mode="M21" priority="1332">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:CatalogueReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:CatalogueReference/*" mode="M21" priority="1331">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:CatalogueReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B02102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference" mode="M21" priority="1330">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B02301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cbc:ID" mode="M21" priority="1329">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cbc:DocumentType" mode="M21" priority="1328">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cbc:DocumentType" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment" mode="M21" priority="1327">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject" mode="M21" priority="1326">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject" />

		<!--ASSERT -->
<choose>
      <when test="@mimeCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@mimeCode">
          <attribute name="id">PEPPOL-T01-B02701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'mimeCode' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@mimeCode) or (some $code in $clMimeCode satisfies $code = @mimeCode)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@mimeCode) or (some $code in $clMimeCode satisfies $code = @mimeCode)">
          <attribute name="id">PEPPOL-T01-B02702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Mime code (IANA Subset)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="@filename" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@filename">
          <attribute name="id">PEPPOL-T01-B02703</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'filename' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference" mode="M21" priority="1325">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:URI" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:URI">
          <attribute name="id">PEPPOL-T01-B03001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:URI' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/cbc:URI" mode="M21" priority="1324">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/cbc:URI" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/*" mode="M21" priority="1323">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B03002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/*" mode="M21" priority="1322">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/cac:Attachment/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B02601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AdditionalDocumentReference/*" mode="M21" priority="1321">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AdditionalDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B02302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Contract" mode="M21" priority="1320">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Contract" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B03201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Contract/cbc:ID" mode="M21" priority="1319">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Contract/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Contract/*" mode="M21" priority="1318">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Contract/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B03202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:ProjectReference" mode="M21" priority="1317">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:ProjectReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B03401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:ProjectReference/cbc:ID" mode="M21" priority="1316">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:ProjectReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:ProjectReference/*" mode="M21" priority="1315">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:ProjectReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B03402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty" mode="M21" priority="1314">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T01-B03601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party" mode="M21" priority="1313">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndpointID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID">
          <attribute name="id">PEPPOL-T01-B03701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:EndpointID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PartyLegalEntity" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PartyLegalEntity">
          <attribute name="id">PEPPOL-T01-B03702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PartyLegalEntity' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cbc:EndpointID" mode="M21" priority="1312">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="@schemeID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@schemeID">
          <attribute name="id">PEPPOL-T01-B03801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'schemeID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B03802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Electronic Address Scheme (EAS)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification" mode="M21" priority="1311">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B04001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M21" priority="1310">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B04101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyName" mode="M21" priority="1309">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B04301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyName/cbc:Name" mode="M21" priority="1308">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress" mode="M21" priority="1307">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B04501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" mode="M21" priority="1306">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" mode="M21" priority="1305">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" mode="M21" priority="1304">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" mode="M21" priority="1303">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" mode="M21" priority="1302">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine" mode="M21" priority="1301">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" mode="M21" priority="1300">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country" mode="M21" priority="1299">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B05301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1298">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B05401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/*" mode="M21" priority="1297">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B05302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/*" mode="M21" priority="1296">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B04502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme" mode="M21" priority="1295">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CompanyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CompanyID">
          <attribute name="id">PEPPOL-T01-B05501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:CompanyID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:TaxScheme" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:TaxScheme">
          <attribute name="id">PEPPOL-T01-B05502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:TaxScheme' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" mode="M21" priority="1294">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme" mode="M21" priority="1293">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B05701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID" mode="M21" priority="1292">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/*" mode="M21" priority="1291">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B05702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/*" mode="M21" priority="1290">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B05503</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity" mode="M21" priority="1289">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
<choose>
      <when test="cbc:RegistrationName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:RegistrationName">
          <attribute name="id">PEPPOL-T01-B05901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:RegistrationName' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" mode="M21" priority="1288">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" mode="M21" priority="1287">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B06101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" mode="M21" priority="1286">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B06301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" mode="M21" priority="1285">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" mode="M21" priority="1284">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B06501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1283">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B06601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" mode="M21" priority="1282">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B06502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" mode="M21" priority="1281">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B06302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/*" mode="M21" priority="1280">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B05902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact" mode="M21" priority="1279">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Name" mode="M21" priority="1278">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Telephone" mode="M21" priority="1277">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M21" priority="1276">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/*" mode="M21" priority="1275">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B06701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/cac:Party/*" mode="M21" priority="1274">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B03703</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:BuyerCustomerParty/*" mode="M21" priority="1273">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:BuyerCustomerParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B03602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty" mode="M21" priority="1272">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T01-B07101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party" mode="M21" priority="1271">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndpointID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID">
          <attribute name="id">PEPPOL-T01-B07201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:EndpointID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PostalAddress" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PostalAddress">
          <attribute name="id">PEPPOL-T01-B07202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PostalAddress' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PartyLegalEntity" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PartyLegalEntity">
          <attribute name="id">PEPPOL-T01-B07203</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PartyLegalEntity' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cbc:EndpointID" mode="M21" priority="1270">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="@schemeID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@schemeID">
          <attribute name="id">PEPPOL-T01-B07301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'schemeID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B07302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Electronic Address Scheme (EAS)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification" mode="M21" priority="1269">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B07501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M21" priority="1268">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B07601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyName" mode="M21" priority="1267">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B07801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyName/cbc:Name" mode="M21" priority="1266">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress" mode="M21" priority="1265">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B08001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName" mode="M21" priority="1264">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" mode="M21" priority="1263">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName" mode="M21" priority="1262">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone" mode="M21" priority="1261">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" mode="M21" priority="1260">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine" mode="M21" priority="1259">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" mode="M21" priority="1258">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country" mode="M21" priority="1257">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B08801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1256">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B08901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/*" mode="M21" priority="1255">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B08802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/*" mode="M21" priority="1254">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B08002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity" mode="M21" priority="1253">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
<choose>
      <when test="cbc:RegistrationName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:RegistrationName">
          <attribute name="id">PEPPOL-T01-B09001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:RegistrationName' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" mode="M21" priority="1252">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" mode="M21" priority="1251">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B09201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" mode="M21" priority="1250">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B09401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" mode="M21" priority="1249">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" mode="M21" priority="1248">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B09601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1247">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B09701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" mode="M21" priority="1246">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B09602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" mode="M21" priority="1245">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B09402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/*" mode="M21" priority="1244">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B09002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact" mode="M21" priority="1243">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Name" mode="M21" priority="1242">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Telephone" mode="M21" priority="1241">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M21" priority="1240">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/*" mode="M21" priority="1239">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B09801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/cac:Party/*" mode="M21" priority="1238">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B07204</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:SellerSupplierParty/*" mode="M21" priority="1237">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:SellerSupplierParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B07102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty" mode="M21" priority="1236">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T01-B10201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party" mode="M21" priority="1235">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification" mode="M21" priority="1234">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B10401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M21" priority="1233">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B10501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyName" mode="M21" priority="1232">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B10701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyName/cbc:Name" mode="M21" priority="1231">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact" mode="M21" priority="1230">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Name" mode="M21" priority="1229">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Telephone" mode="M21" priority="1228">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M21" priority="1227">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/*" mode="M21" priority="1226">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B10901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/*" mode="M21" priority="1225">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B10301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OriginatorCustomerParty/*" mode="M21" priority="1224">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OriginatorCustomerParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B10202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty" mode="M21" priority="1223">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T01-B11301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party" mode="M21" priority="1222">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cac:PostalAddress" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PostalAddress">
          <attribute name="id">PEPPOL-T01-B11401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PostalAddress' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:PartyLegalEntity" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PartyLegalEntity">
          <attribute name="id">PEPPOL-T01-B11402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PartyLegalEntity' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID" mode="M21" priority="1221">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="@schemeID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@schemeID">
          <attribute name="id">PEPPOL-T01-B11501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'schemeID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $cleas satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B11502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Electronic Address Scheme (EAS)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification" mode="M21" priority="1220">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B11701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M21" priority="1219">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B11801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyName" mode="M21" priority="1218">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B12001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name" mode="M21" priority="1217">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress" mode="M21" priority="1216">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B12201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" mode="M21" priority="1215">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" mode="M21" priority="1214">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" mode="M21" priority="1213">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" mode="M21" priority="1212">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" mode="M21" priority="1211">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine" mode="M21" priority="1210">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" mode="M21" priority="1209">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country" mode="M21" priority="1208">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B13001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1207">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B13101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/*" mode="M21" priority="1206">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B13002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/*" mode="M21" priority="1205">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B12202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme" mode="M21" priority="1204">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CompanyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CompanyID">
          <attribute name="id">PEPPOL-T01-B13201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:CompanyID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:TaxScheme" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:TaxScheme">
          <attribute name="id">PEPPOL-T01-B13202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:TaxScheme' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" mode="M21" priority="1203">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme" mode="M21" priority="1202">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B13401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID" mode="M21" priority="1201">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/*" mode="M21" priority="1200">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B13402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/*" mode="M21" priority="1199">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B13203</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity" mode="M21" priority="1198">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
<choose>
      <when test="cbc:RegistrationName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:RegistrationName">
          <attribute name="id">PEPPOL-T01-B13601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:RegistrationName' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" mode="M21" priority="1197">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" mode="M21" priority="1196">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B13801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" mode="M21" priority="1195">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B14001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" mode="M21" priority="1194">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" mode="M21" priority="1193">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B14201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1192">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B14301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" mode="M21" priority="1191">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B14202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" mode="M21" priority="1190">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B14002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/*" mode="M21" priority="1189">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B13602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact" mode="M21" priority="1188">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name" mode="M21" priority="1187">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone" mode="M21" priority="1186">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M21" priority="1185">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/*" mode="M21" priority="1184">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B14401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/cac:Party/*" mode="M21" priority="1183">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B11403</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AccountingCustomerParty/*" mode="M21" priority="1182">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AccountingCustomerParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B11302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery" mode="M21" priority="1181">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation" mode="M21" priority="1180">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation" />

		<!--ASSERT -->
<choose>
      <when test="cac:Address" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Address">
          <attribute name="id">PEPPOL-T01-B14901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Address' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cbc:ID" mode="M21" priority="1179">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B15001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cbc:Name" mode="M21" priority="1178">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address" mode="M21" priority="1177">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B15301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:StreetName" mode="M21" priority="1176">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:StreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:AdditionalStreetName" mode="M21" priority="1175">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:AdditionalStreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:CityName" mode="M21" priority="1174">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:PostalZone" mode="M21" priority="1173">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:PostalZone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:CountrySubentity" mode="M21" priority="1172">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cbc:CountrySubentity" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:AddressLine" mode="M21" priority="1171">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:AddressLine" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Line" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Line">
          <attribute name="id">PEPPOL-T01-B15901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Line' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:AddressLine/cbc:Line" mode="M21" priority="1170">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country" mode="M21" priority="1169">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B16101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode" mode="M21" priority="1168">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B16201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country/*" mode="M21" priority="1167">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B16102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/*" mode="M21" priority="1166">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/cac:Address/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B15302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryLocation/*" mode="M21" priority="1165">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryLocation/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B14902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod" mode="M21" priority="1164">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartDate" mode="M21" priority="1163">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartTime" mode="M21" priority="1162">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartTime" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndDate" mode="M21" priority="1161">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndTime" mode="M21" priority="1160">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndTime" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/*" mode="M21" priority="1159">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:RequestedDeliveryPeriod/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B16301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty" mode="M21" priority="1158">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:PartyName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:PartyName">
          <attribute name="id">PEPPOL-T01-B16801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PartyName' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyIdentification" mode="M21" priority="1157">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B16901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyIdentification/cbc:ID" mode="M21" priority="1156">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B17001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyName" mode="M21" priority="1155">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B17201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyName/cbc:Name" mode="M21" priority="1154">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PartyName/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress" mode="M21" priority="1153">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T01-B17401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:StreetName" mode="M21" priority="1152">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:StreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:AdditionalStreetName" mode="M21" priority="1151">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:AdditionalStreetName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:CityName" mode="M21" priority="1150">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:CityName" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:PostalZone" mode="M21" priority="1149">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:PostalZone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:CountrySubentity" mode="M21" priority="1148">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cbc:CountrySubentity" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:AddressLine" mode="M21" priority="1147">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:AddressLine" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Line" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Line">
          <attribute name="id">PEPPOL-T01-B18001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Line' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:AddressLine/cbc:Line" mode="M21" priority="1146">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:Country" mode="M21" priority="1145">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T01-B18201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode" mode="M21" priority="1144">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B18301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:Country/*" mode="M21" priority="1143">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B18202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/*" mode="M21" priority="1142">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:PostalAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B17402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact" mode="M21" priority="1141">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/cbc:Name" mode="M21" priority="1140">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/cbc:Telephone" mode="M21" priority="1139">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/cbc:ElectronicMail" mode="M21" priority="1138">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/*" mode="M21" priority="1137">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B18401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:DeliveryParty/*" mode="M21" priority="1136">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:DeliveryParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B16802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Despatch" mode="M21" priority="1135">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Despatch" />

		<!--ASSERT -->
<choose>
      <when test="cbc:RequestedDespatchDate" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:RequestedDespatchDate">
          <attribute name="id">PEPPOL-T01-B18801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:RequestedDespatchDate' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Despatch/cbc:RequestedDespatchDate" mode="M21" priority="1134">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Despatch/cbc:RequestedDespatchDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Despatch/cbc:RequestedDespatchTime" mode="M21" priority="1133">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Despatch/cbc:RequestedDespatchTime" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Despatch/*" mode="M21" priority="1132">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Despatch/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B18802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment" mode="M21" priority="1131">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B19101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment/cbc:ID" mode="M21" priority="1130">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment/cbc:ShippingPriorityLevelCode" mode="M21" priority="1129">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment/cbc:ShippingPriorityLevelCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clUNCL4219 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clUNCL4219 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B19301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Transport service priority code (UNCL4219)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment/cac:TransportHandlingUnit" mode="M21" priority="1128">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment/cac:TransportHandlingUnit" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment/cac:TransportHandlingUnit/cbc:ShippingMarks" mode="M21" priority="1127">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment/cac:TransportHandlingUnit/cbc:ShippingMarks" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment/cac:TransportHandlingUnit/*" mode="M21" priority="1126">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment/cac:TransportHandlingUnit/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B19401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/cac:Shipment/*" mode="M21" priority="1125">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/cac:Shipment/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B19102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:Delivery/*" mode="M21" priority="1124">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:Delivery/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B14801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms" mode="M21" priority="1123">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms/cbc:ID" mode="M21" priority="1122">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms/cbc:SpecialTerms" mode="M21" priority="1121">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms/cbc:SpecialTerms" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms/cac:DeliveryLocation" mode="M21" priority="1120">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms/cac:DeliveryLocation" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B19901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms/cac:DeliveryLocation/cbc:ID" mode="M21" priority="1119">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms/cac:DeliveryLocation/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms/cac:DeliveryLocation/*" mode="M21" priority="1118">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms/cac:DeliveryLocation/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B19902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:DeliveryTerms/*" mode="M21" priority="1117">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:DeliveryTerms/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B19601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:PaymentTerms" mode="M21" priority="1116">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:PaymentTerms" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Note" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Note">
          <attribute name="id">PEPPOL-T01-B20101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Note' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:PaymentTerms/cbc:Note" mode="M21" priority="1115">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:PaymentTerms/cbc:Note" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:PaymentTerms/*" mode="M21" priority="1114">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:PaymentTerms/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B20102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge" mode="M21" priority="1113">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ChargeIndicator" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ChargeIndicator">
          <attribute name="id">PEPPOL-T01-B20301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ChargeIndicator' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:AllowanceChargeReason" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:AllowanceChargeReason">
          <attribute name="id">PEPPOL-T01-B20302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:AllowanceChargeReason' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Amount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Amount">
          <attribute name="id">PEPPOL-T01-B20303</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Amount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cbc:ChargeIndicator" mode="M21" priority="1112">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cbc:ChargeIndicator" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clTrueFalse satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clTrueFalse satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B20401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Boolean indicator (OpenPeppol)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cbc:AllowanceChargeReasonCode" mode="M21" priority="1111">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cbc:AllowanceChargeReasonCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clUNCL5189 satisfies $code = normalize-space(text())) or (some $code in $clUNCL7161 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clUNCL5189 satisfies $code = normalize-space(text())) or (some $code in $clUNCL7161 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B20501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Allowance reason codes (UNCL5189 subset)' or 'Charge reason code (UNCL7161)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cbc:AllowanceChargeReason" mode="M21" priority="1110">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cbc:AllowanceChargeReason" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cbc:MultiplierFactorNumeric" mode="M21" priority="1109">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cbc:MultiplierFactorNumeric" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cbc:Amount" mode="M21" priority="1108">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cbc:Amount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B20801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B20802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cbc:BaseAmount" mode="M21" priority="1107">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cbc:BaseAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B21001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B21002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory" mode="M21" priority="1106">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B21201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:TaxScheme" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:TaxScheme">
          <attribute name="id">PEPPOL-T01-B21202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:TaxScheme' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cbc:ID" mode="M21" priority="1105">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cbc:Percent" mode="M21" priority="1104">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cbc:Percent" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme" mode="M21" priority="1103">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B21501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme/cbc:ID" mode="M21" priority="1102">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme/*" mode="M21" priority="1101">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/cac:TaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B21502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/*" mode="M21" priority="1100">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/cac:TaxCategory/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B21203</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge/*" mode="M21" priority="1099">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B20304</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:TaxTotal" mode="M21" priority="1098">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:TaxTotal" />

		<!--ASSERT -->
<choose>
      <when test="cbc:TaxAmount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:TaxAmount">
          <attribute name="id">PEPPOL-T01-B21701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:TaxAmount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:TaxTotal/cbc:TaxAmount" mode="M21" priority="1097">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:TaxTotal/cbc:TaxAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B21801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B21802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:TaxTotal/*" mode="M21" priority="1096">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:TaxTotal/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B21702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal" mode="M21" priority="1095">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal" />

		<!--ASSERT -->
<choose>
      <when test="cbc:LineExtensionAmount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:LineExtensionAmount">
          <attribute name="id">PEPPOL-T01-B22001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:LineExtensionAmount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:PayableAmount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:PayableAmount">
          <attribute name="id">PEPPOL-T01-B22002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:PayableAmount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:LineExtensionAmount" mode="M21" priority="1094">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:LineExtensionAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B22101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B22102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:TaxExclusiveAmount" mode="M21" priority="1093">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:TaxExclusiveAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B22301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B22302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:TaxInclusiveAmount" mode="M21" priority="1092">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:TaxInclusiveAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B22501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B22502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:AllowanceTotalAmount" mode="M21" priority="1091">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:AllowanceTotalAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B22701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B22702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:ChargeTotalAmount" mode="M21" priority="1090">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:ChargeTotalAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B22901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B22902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:PrepaidAmount" mode="M21" priority="1089">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:PrepaidAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B23101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B23102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:PayableRoundingAmount" mode="M21" priority="1088">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:PayableRoundingAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B23301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B23302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:PayableAmount" mode="M21" priority="1087">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/cbc:PayableAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B23501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B23502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AnticipatedMonetaryTotal/*" mode="M21" priority="1086">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AnticipatedMonetaryTotal/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B22003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine" mode="M21" priority="1085">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine" />

		<!--ASSERT -->
<choose>
      <when test="cac:LineItem" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:LineItem">
          <attribute name="id">PEPPOL-T01-B23701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:LineItem' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cbc:Note" mode="M21" priority="1084">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cbc:Note" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem" mode="M21" priority="1083">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B23901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Quantity" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Quantity">
          <attribute name="id">PEPPOL-T01-B23902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Quantity' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:Item" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Item">
          <attribute name="id">PEPPOL-T01-B23903</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Item' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:ID" mode="M21" priority="1082">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:Quantity" mode="M21" priority="1081">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:Quantity" />

		<!--ASSERT -->
<choose>
      <when test="@unitCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@unitCode">
          <attribute name="id">PEPPOL-T01-B24101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'unitCode' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@unitCode) or (some $code in $clUNECERec20 satisfies $code = @unitCode)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@unitCode) or (some $code in $clUNECERec20 satisfies $code = @unitCode)">
          <attribute name="id">PEPPOL-T01-B24102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Recommendation 20, including Recommendation 21 codes - prefixed with X (UN/ECE)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:LineExtensionAmount" mode="M21" priority="1080">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:LineExtensionAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B24301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B24302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:PartialDeliveryIndicator" mode="M21" priority="1079">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:PartialDeliveryIndicator" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clTrueFalse satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clTrueFalse satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B24501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Boolean indicator (OpenPeppol)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:AccountingCost" mode="M21" priority="1078">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cbc:AccountingCost" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery" mode="M21" priority="1077">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery" />

		<!--ASSERT -->
<choose>
      <when test="cac:RequestedDeliveryPeriod" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:RequestedDeliveryPeriod">
          <attribute name="id">PEPPOL-T01-B24701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:RequestedDeliveryPeriod' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cbc:ID" mode="M21" priority="1076">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B24801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod" mode="M21" priority="1075">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartDate" mode="M21" priority="1074">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartTime" mode="M21" priority="1073">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:StartTime" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndDate" mode="M21" priority="1072">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndDate" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndTime" mode="M21" priority="1071">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/cbc:EndTime" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/*" mode="M21" priority="1070">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/cac:RequestedDeliveryPeriod/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B25001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/*" mode="M21" priority="1069">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Delivery/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B24702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty" mode="M21" priority="1068">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyIdentification" mode="M21" priority="1067">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B25601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyIdentification/cbc:ID" mode="M21" priority="1066">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B25701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyName" mode="M21" priority="1065">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B25901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyName/cbc:Name" mode="M21" priority="1064">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/cac:PartyName/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/*" mode="M21" priority="1063">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:OriginatorParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B25501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge" mode="M21" priority="1062">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ChargeIndicator" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ChargeIndicator">
          <attribute name="id">PEPPOL-T01-B26101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ChargeIndicator' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Amount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Amount">
          <attribute name="id">PEPPOL-T01-B26102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Amount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:ChargeIndicator" mode="M21" priority="1061">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:ChargeIndicator" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:AllowanceChargeReasonCode" mode="M21" priority="1060">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:AllowanceChargeReasonCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clUNCL5189 satisfies $code = normalize-space(text())) or (some $code in $clUNCL7161 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clUNCL5189 satisfies $code = normalize-space(text())) or (some $code in $clUNCL7161 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T01-B26301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Allowance reason codes (UNCL5189 subset)' or 'Charge reason code (UNCL7161)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:AllowanceChargeReason" mode="M21" priority="1059">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:AllowanceChargeReason" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:MultiplierFactorNumeric" mode="M21" priority="1058">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:MultiplierFactorNumeric" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:Amount" mode="M21" priority="1057">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:Amount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B26601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B26602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:BaseAmount" mode="M21" priority="1056">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/cbc:BaseAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B26801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B26802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/*" mode="M21" priority="1055">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B26103</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price" mode="M21" priority="1054">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price" />

		<!--ASSERT -->
<choose>
      <when test="cbc:PriceAmount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:PriceAmount">
          <attribute name="id">PEPPOL-T01-B27001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:PriceAmount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cbc:PriceAmount" mode="M21" priority="1053">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cbc:PriceAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B27101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B27102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cbc:BaseQuantity" mode="M21" priority="1052">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cbc:BaseQuantity" />

		<!--ASSERT -->
<choose>
      <when test="not(@unitCode) or (some $code in $clUNECERec20 satisfies $code = @unitCode)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@unitCode) or (some $code in $clUNECERec20 satisfies $code = @unitCode)">
          <attribute name="id">PEPPOL-T01-B27301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Recommendation 20, including Recommendation 21 codes - prefixed with X (UN/ECE)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge" mode="M21" priority="1051">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ChargeIndicator" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ChargeIndicator">
          <attribute name="id">PEPPOL-T01-B27501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ChargeIndicator' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Amount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Amount">
          <attribute name="id">PEPPOL-T01-B27502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Amount' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/cbc:ChargeIndicator" mode="M21" priority="1050">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/cbc:ChargeIndicator" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(text()) = 'false'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(text()) = 'false'">
          <attribute name="id">PEPPOL-T01-B27601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ChargeIndicator' MUST contain value 'false'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/cbc:Amount" mode="M21" priority="1049">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/cbc:Amount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B27701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B27702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/cbc:BaseAmount" mode="M21" priority="1048">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/cbc:BaseAmount" />

		<!--ASSERT -->
<choose>
      <when test="@currencyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@currencyID">
          <attribute name="id">PEPPOL-T01-B27901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'currencyID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or (some $code in $clISO4217 satisfies $code = @currencyID)">
          <attribute name="id">PEPPOL-T01-B27902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 4217 Currency codes'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/*" mode="M21" priority="1047">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/cac:AllowanceCharge/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B27503</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/*" mode="M21" priority="1046">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Price/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B27002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item" mode="M21" priority="1045">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B28101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cbc:Description" mode="M21" priority="1044">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cbc:Description" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cbc:Name" mode="M21" priority="1043">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:BuyersItemIdentification" mode="M21" priority="1042">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:BuyersItemIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B28401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:BuyersItemIdentification/cbc:ID" mode="M21" priority="1041">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:BuyersItemIdentification/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:BuyersItemIdentification/*" mode="M21" priority="1040">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:BuyersItemIdentification/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B28402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:SellersItemIdentification" mode="M21" priority="1039">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:SellersItemIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B28601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:SellersItemIdentification/cbc:ID" mode="M21" priority="1038">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:SellersItemIdentification/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:SellersItemIdentification/*" mode="M21" priority="1037">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:SellersItemIdentification/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B28602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ManufacturersItemIdentification" mode="M21" priority="1036">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ManufacturersItemIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B28801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ManufacturersItemIdentification/cbc:ID" mode="M21" priority="1035">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ManufacturersItemIdentification/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ManufacturersItemIdentification/*" mode="M21" priority="1034">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ManufacturersItemIdentification/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B28802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:StandardItemIdentification" mode="M21" priority="1033">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:StandardItemIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B29001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:StandardItemIdentification/cbc:ID" mode="M21" priority="1032">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:StandardItemIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="@schemeID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@schemeID">
          <attribute name="id">PEPPOL-T01-B29101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'schemeID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T01-B29102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:StandardItemIdentification/*" mode="M21" priority="1031">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:StandardItemIdentification/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B29002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemSpecificationDocumentReference" mode="M21" priority="1030">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemSpecificationDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B29301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemSpecificationDocumentReference/cbc:ID" mode="M21" priority="1029">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemSpecificationDocumentReference/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemSpecificationDocumentReference/*" mode="M21" priority="1028">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemSpecificationDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B29302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:CommodityClassification" mode="M21" priority="1027">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:CommodityClassification" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode" mode="M21" priority="1026">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode" />

		<!--ASSERT -->
<choose>
      <when test="@listID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@listID">
          <attribute name="id">PEPPOL-T01-B29601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'listID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@listID) or (some $code in $clUNCL7143 satisfies $code = @listID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@listID) or (some $code in $clUNCL7143 satisfies $code = @listID)">
          <attribute name="id">PEPPOL-T01-B29602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Item type identification code (UNCL7143)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:CommodityClassification/*" mode="M21" priority="1025">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:CommodityClassification/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B29501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory" mode="M21" priority="1024">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B30001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:TaxScheme" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:TaxScheme">
          <attribute name="id">PEPPOL-T01-B30002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:TaxScheme' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cbc:ID" mode="M21" priority="1023">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent" mode="M21" priority="1022">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme" mode="M21" priority="1021">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T01-B30301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID" mode="M21" priority="1020">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/*" mode="M21" priority="1019">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B30302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/*" mode="M21" priority="1018">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ClassifiedTaxCategory/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B30003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty" mode="M21" priority="1017">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T01-B30501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Value" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Value">
          <attribute name="id">PEPPOL-T01-B30502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Value' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:ID" mode="M21" priority="1016">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:ID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:Name" mode="M21" priority="1015">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:Name" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:NameCode" mode="M21" priority="1014">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:NameCode" />

		<!--ASSERT -->
<choose>
      <when test="@listID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@listID">
          <attribute name="id">PEPPOL-T01-B31101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'listID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:Value" mode="M21" priority="1013">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:Value" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:ValueQuantity" mode="M21" priority="1012">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:ValueQuantity" />

		<!--ASSERT -->
<choose>
      <when test="@unitCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@unitCode">
          <attribute name="id">PEPPOL-T01-B31401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'unitCode' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(@unitCode) or (some $code in $clUNECERec20 satisfies $code = @unitCode)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@unitCode) or (some $code in $clUNECERec20 satisfies $code = @unitCode)">
          <attribute name="id">PEPPOL-T01-B31402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Recommendation 20, including Recommendation 21 codes - prefixed with X (UN/ECE)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:ValueQualifier" mode="M21" priority="1011">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/cbc:ValueQualifier" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/*" mode="M21" priority="1010">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:AdditionalItemProperty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B30503</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance" mode="M21" priority="1009">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cbc:SerialID" mode="M21" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cbc:SerialID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cac:LotIdentification" mode="M21" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cac:LotIdentification" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cac:LotIdentification/cbc:LotNumberID" mode="M21" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cac:LotIdentification/cbc:LotNumberID" />
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cac:LotIdentification/*" mode="M21" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/cac:LotIdentification/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B31901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/*" mode="M21" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/cac:ItemInstance/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B31701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/*" mode="M21" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/cac:Item/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B28102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/cac:LineItem/*" mode="M21" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/cac:LineItem/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B23904</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:OrderLine/*" mode="M21" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:OrderLine/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B23702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/*" mode="M21" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-B00110</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>
  <template match="text()" mode="M21" priority="-1" />
  <template match="@*|node()" mode="M21" priority="-2">
    <apply-templates mode="M21" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="documentCurrencyCode" select="/ubl:Order/cbc:DocumentCurrencyCode" />
  <variable name="sumLineExtensionAmount" select="if (/ubl:Order/cac:OrderLine/cac:LineItem/cbc:LineExtensionAmount) then round(sum(/ubl:Order/cac:OrderLine/cac:LineItem/cbc:LineExtensionAmount/xs:decimal(.)) * 10 * 10) div 100 else 0" />
  <variable name="sumAllowance" select="if (/ubl:Order/cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'false']) then round(sum(/ubl:Order/cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'false']/cbc:Amount/xs:decimal(.)) * 10 * 10) div 100 else 0" />
  <variable name="sumCharge" select="if (/ubl:Order/cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'true']) then round(sum(/ubl:Order/cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'true']/cbc:Amount/xs:decimal(.)) * 10 * 10) div 100 else 0" />
  <variable name="TAXamount" select="if(/ubl:Order/cac:TaxTotal/cbc:TaxAmount) then xs:decimal(/ubl:Order/cac:TaxTotal/cbc:TaxAmount) else 0" />

	<!--RULE -->
<template match="cbc:ProfileID" mode="M22" priority="1015">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:ProfileID" />

		<!--ASSERT -->
<choose>
      <when test="some $p in tokenize('urn:fdc:peppol.eu:poacc:bis:order_only:3 urn:fdc:peppol.eu:poacc:bis:ordering:3 urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3', '\s') satisfies $p = normalize-space(.)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $p in tokenize('urn:fdc:peppol.eu:poacc:bis:order_only:3 urn:fdc:peppol.eu:poacc:bis:ordering:3 urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3', '\s') satisfies $p = normalize-space(.)">
          <attribute name="id">PEPPOL-T01-R031</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>An order transaction SHALL use profile order only, ordering or advanced_ordering.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:CustomizationID" mode="M22" priority="1014">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:CustomizationID" />

		<!--ASSERT -->
<choose>
      <when test="starts-with(normalize-space(.), 'urn:fdc:peppol.eu:poacc:trns:order:3')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="starts-with(normalize-space(.), 'urn:fdc:peppol.eu:poacc:trns:order:3')">
          <attribute name="id">PEPPOL-T01-R034</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Specification identifier SHALL start with the value 'urn:fdc:peppol.eu:poacc:trns:order:3'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:Amount | cbc:TaxAmount | cbc:LineExtensionAmount | cbc:PriceAmount | cbc:BaseAmount | cac:AnticipatedMonetaryTotal/cbc:*" mode="M22" priority="1013">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:Amount | cbc:TaxAmount | cbc:LineExtensionAmount | cbc:PriceAmount | cbc:BaseAmount | cac:AnticipatedMonetaryTotal/cbc:*" />

		<!--ASSERT -->
<choose>
      <when test="not(@currencyID) or @currencyID = $documentCurrencyCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@currencyID) or @currencyID = $documentCurrencyCode">
          <attribute name="id">PEPPOL-T01-R003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>An order SHALL be stated in a single currency</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="ancestor::node()/local-name() = 'Price' or string-length(substring-after(., '.')) &lt;= 2" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="ancestor::node()/local-name() = 'Price' or string-length(substring-after(., '.')) &lt;= 2">
          <attribute name="id">PEPPOL-T01-R028</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Elements of data type amount cannot have more than 2 decimals (I.e. all amounts except unit price amounts)</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="ubl:Order" mode="M22" priority="1012">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="ubl:Order" />

		<!--ASSERT -->
<choose>
      <when test="cac:ValidityPeriod/cbc:EndDate" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:ValidityPeriod/cbc:EndDate">
          <attribute name="id">PEPPOL-T01-R002</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>An order SHOULD provide information about its validity end date.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:OriginatorCustomerParty" mode="M22" priority="1011">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:OriginatorCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party/cac:PartyName/cbc:Name or cac:Party/cac:PartyIdentification/cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party/cac:PartyName/cbc:Name or cac:Party/cac:PartyIdentification/cbc:ID">
          <attribute name="id">PEPPOL-T01-R014</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>An order SHALL have the originator party name or an identifier</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:PartyTaxScheme[cac:TaxScheme/cbc:ID='VAT']" mode="M22" priority="1010">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:PartyTaxScheme[cac:TaxScheme/cbc:ID='VAT']" />

		<!--ASSERT -->
<choose>
      <when test="( contains( 'AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BL BJ BM BN BO BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CX CY CZ DE DJ DK DM DO DZ EC EE EG EH EL ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR ST SV SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW',substring(cbc:CompanyID,1,2) ) )" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="( contains( 'AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BL BJ BM BN BO BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CX CY CZ DE DJ DK DM DO DZ EC EE EG EH EL ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR ST SV SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW',substring(cbc:CompanyID,1,2) ) )">
          <attribute name="id">PEPPOL-T01-R026</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When TAX is VAT then Party VAT identifiers SHALL have a prefix in accordance with ISO code ISO 3166-1 alpha-2 by which the country of issue may be identified. Nevertheless, Greece may use the prefix ‘EL’.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AnticipatedMonetaryTotal" mode="M22" priority="1009">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AnticipatedMonetaryTotal" />
    <variable name="payableAmount" select="xs:decimal(cbc:PayableAmount)" />
    <variable name="lineEtensionAmount" select="xs:decimal(cbc:LineExtensionAmount)" />
    <variable name="prepaidAmount" select="if (cbc:PrepaidAmount) then xs:decimal(cbc:PrepaidAmount) else 0" />
    <variable name="roundingAmount" select="if (cbc:PayableRoundingAmount) then xs:decimal(cbc:PayableRoundingAmount) else 0" />
    <variable name="taxinclusiveAmount" select="xs:decimal(cbc:TaxInclusiveAmount)" />
    <variable name="allowanceTotalAmount" select="if (cbc:AllowanceTotalAmount) then xs:decimal(cbc:AllowanceTotalAmount) else 0" />
    <variable name="chargeTotalAmount" select="if (cbc:ChargeTotalAmount) then xs:decimal(cbc:ChargeTotalAmount) else 0" />
    <variable name="taxexclusiveAmount" select="if(cbc:TaxExclusiveAmount) then xs:decimal(cbc:TaxExclusiveAmount) else ($lineEtensionAmount - $allowanceTotalAmount + $chargeTotalAmount)" />

		<!--ASSERT -->
<choose>
      <when test="$payableAmount >=0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$payableAmount >=0">
          <attribute name="id">PEPPOL-T01-R006</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total amount for payment SHALL NOT be negative</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="$lineEtensionAmount >=0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$lineEtensionAmount >=0">
          <attribute name="id">PEPPOL-T01-R007</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total sum of line amounts SHALL NOT be negative</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="$lineEtensionAmount = $sumLineExtensionAmount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$lineEtensionAmount = $sumLineExtensionAmount">
          <attribute name="id">PEPPOL-T01-R008</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total sum of line amounts SHALL equal the sum of the order line amounts at order line level</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="$allowanceTotalAmount = $sumAllowance" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$allowanceTotalAmount = $sumAllowance">
          <attribute name="id">PEPPOL-T01-R009</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total sum of allowance at document level SHALL be equal to the sum of allowance amounts at document level</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="$chargeTotalAmount= $sumCharge" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$chargeTotalAmount= $sumCharge">
          <attribute name="id">PEPPOL-T01-R010</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total sum of charges at document level SHALL be equal to the sum of charge amounts at document level</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="$taxexclusiveAmount = $lineEtensionAmount - $allowanceTotalAmount + $chargeTotalAmount" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="$taxexclusiveAmount = $lineEtensionAmount - $allowanceTotalAmount + $chargeTotalAmount">
          <attribute name="id">PEPPOL-T01-R011</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total amount without TAX = Expected total sum of line amounts - Sum of allowances on document level + Sum of charges on document level</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="if ($taxinclusiveAmount) then ($payableAmount = $taxinclusiveAmount - $prepaidAmount + $roundingAmount) else 1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="if ($taxinclusiveAmount) then ($payableAmount = $taxinclusiveAmount - $prepaidAmount + $roundingAmount) else 1">
          <attribute name="id">PEPPOL-T01-R016</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Amount due for payment = Invoice total amount with TAX - Paid amount + Rounding amount.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="if($taxinclusiveAmount and /ubl:Order/cac:TaxTotal) then ($taxinclusiveAmount = $taxexclusiveAmount + $TAXamount) else 1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="if($taxinclusiveAmount and /ubl:Order/cac:TaxTotal) then ($taxinclusiveAmount = $taxexclusiveAmount + $TAXamount) else 1">
          <attribute name="id">PEPPOL-T01-R017</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Expected total amount with TAX = Expected total amount without TAX + Order total TAX amount.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | /ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]" mode="M22" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)] | /ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge[cbc:MultiplierFactorNumeric and not(cbc:BaseAmount)]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-R020</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge base amount SHALL be provided when allowance/charge percentage is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | /ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]" mode="M22" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount] | /ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge[not(cbc:MultiplierFactorNumeric) and cbc:BaseAmount]" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T01-R021</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge percentage SHALL be provided when allowance/charge base amount is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:Order/cac:AllowanceCharge |/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge" mode="M22" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:Order/cac:AllowanceCharge |/ubl:Order/cac:OrderLine/cac:LineItem/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="not(cbc:MultiplierFactorNumeric and cbc:BaseAmount) or u:slack(if (cbc:Amount) then cbc:Amount else 0, (xs:decimal(cbc:BaseAmount) * xs:decimal(cbc:MultiplierFactorNumeric)) div 100, 0.02)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:MultiplierFactorNumeric and cbc:BaseAmount) or u:slack(if (cbc:Amount) then cbc:Amount else 0, (xs:decimal(cbc:BaseAmount) * xs:decimal(cbc:MultiplierFactorNumeric)) div 100, 0.02)">
          <attribute name="id">PEPPOL-T01-R022</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance/charge amount SHALL equal base amount * percentage/100 if base amount and percentage exists</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:AllowanceChargeReason) or exists(cbc:AllowanceChargeReasonCode)">
          <attribute name="id">PEPPOL-T01-R023</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Each document or line level allowance SHALL have an allowance reason text or an allowance reason code.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="number(cbc:Amount) >= 0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="number(cbc:Amount) >= 0">
          <attribute name="id">PEPPOL-T01-R032</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance or charge amounts SHALL NOT be negative.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:TaxCategory | cac:ClassifiedTaxCategory" mode="M22" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:TaxCategory | cac:ClassifiedTaxCategory" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Percent or (normalize-space(cbc:ID)='O')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Percent or (normalize-space(cbc:ID)='O')">
          <attribute name="id">PEPPOL-T01-R029</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Each Tax Category SHALL have a TAX category rate, except if the order is not subject to TAX.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(normalize-space(cbc:ID)='S') or (cbc:Percent) > 0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(normalize-space(cbc:ID)='S') or (cbc:Percent) > 0">
          <attribute name="id">PEPPOL-T01-R030</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>When TAX category code is "Standard rated" (S) the TAX rate SHALL be greater than zero.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:OrderLine/cac:LineItem" mode="M22" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:OrderLine/cac:LineItem" />
    <variable name="lineExtensionAmount" select="if (cbc:LineExtensionAmount) then xs:decimal(cbc:LineExtensionAmount) else 0" />
    <variable name="quantity" select="if (cbc:Quantity) then xs:decimal(cbc:Quantity) else 1" />
    <variable name="priceAmount" select="if (cac:Price/cbc:PriceAmount) then xs:decimal(cac:Price/cbc:PriceAmount) else 0" />
    <variable name="baseQuantity" select="if (cac:Price/cbc:BaseQuantity and xs:decimal(cac:Price/cbc:BaseQuantity) != 0) then xs:decimal(cac:Price/cbc:BaseQuantity) else 1" />
    <variable name="allowancesTotal" select="if (cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'false']) then round(sum(cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'false']/cbc:Amount/xs:decimal(.)) * 10 * 10) div 100 else 0" />
    <variable name="chargesTotal" select="if (cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'true']) then round(sum(cac:AllowanceCharge[normalize-space(cbc:ChargeIndicator) = 'true']/cbc:Amount/xs:decimal(.)) * 10 * 10) div 100 else 0" />

		<!--ASSERT -->
<choose>
      <when test="u:slack($lineExtensionAmount, ($quantity * ($priceAmount div $baseQuantity)) + $chargesTotal - $allowancesTotal, 0.02)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="u:slack($lineExtensionAmount, ($quantity * ($priceAmount div $baseQuantity)) + $chargesTotal - $allowancesTotal, 0.02)">
          <attribute name="id">PEPPOL-T01-R024</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Order line net amount SHALL equal (Ordered quantity * (Item net price/item price base quantity) + Order line charge amount - Order line allowance amount</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="not(cac:Price/cbc:BaseQuantity) or xs:decimal(cac:Price/cbc:BaseQuantity) > 0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cac:Price/cbc:BaseQuantity) or xs:decimal(cac:Price/cbc:BaseQuantity) > 0">
          <attribute name="id">PEPPOL-T01-R025</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Base quantity SHALL be a positive number above zero.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="count(key('k_lineId',cbc:ID)) = 1" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="count(key('k_lineId',cbc:ID)) = 1">
          <attribute name="id">PEPPOL-T01-R001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Each order line SHALL have a document line identifier that is unique within the order.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="number(cbc:Quantity) >=0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="number(cbc:Quantity) >=0">
          <attribute name="id">PEPPOL-T01-R004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Each order line ordered quantity SHALL not be negative</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cbc:Quantity" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Quantity">
          <attribute name="id">PEPPOL-T01-R013</attribute>
          <attribute name="flag">warning</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Each order line SHOULD have an ordered quantity</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:Price/cac:AllowanceCharge" mode="M22" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:Price/cac:AllowanceCharge" />

		<!--ASSERT -->
<choose>
      <when test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(cbc:BaseAmount) or xs:decimal(../cbc:PriceAmount) = xs:decimal(cbc:BaseAmount) - xs:decimal(cbc:Amount)">
          <attribute name="id">PEPPOL-T01-R019</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Item net price SHALL equal (Gross price - Allowance amount) when gross price is provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:Price" mode="M22" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:Price" />

		<!--ASSERT -->
<choose>
      <when test="number(cbc:PriceAmount) >=0" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="number(cbc:PriceAmount) >=0">
          <attribute name="id">PEPPOL-T01-R005</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Each order line item net price SHALL not be negative
        </ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="(cac:AllowanceCharge/cbc:BaseAmount) >= 0 or not(exists(cac:AllowanceCharge/cbc:BaseAmount))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(cac:AllowanceCharge/cbc:BaseAmount) >= 0 or not(exists(cac:AllowanceCharge/cbc:BaseAmount))">
          <attribute name="id">PEPPOL-T01-R027</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>The Item gross price SHALL NOT be negative.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="number(cac:AllowanceCharge/cbc:Amount) >= 0 or not(exists(cac:AllowanceCharge/cbc:Amount))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="number(cac:AllowanceCharge/cbc:Amount) >= 0 or not(exists(cac:AllowanceCharge/cbc:Amount))">
          <attribute name="id">PEPPOL-T01-R033</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Allowance or charge amounts SHALL NOT be negative.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AllowanceCharge[cbc:ChargeIndicator = 'false']/cbc:AllowanceChargeReasonCode" mode="M22" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AllowanceCharge[cbc:ChargeIndicator = 'false']/cbc:AllowanceChargeReasonCode" />

		<!--ASSERT -->
<choose>
      <when test="                         some $code in $clUNCL5189                         satisfies normalize-space(text()) = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $clUNCL5189 satisfies normalize-space(text()) = $code">
          <attribute name="id">PEPPOL-T01-CL001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Reason code MUST be according to subset of UNCL 5189 D.16B.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cac:AllowanceCharge[cbc:ChargeIndicator = 'true']/cbc:AllowanceChargeReasonCode" mode="M22" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cac:AllowanceCharge[cbc:ChargeIndicator = 'true']/cbc:AllowanceChargeReasonCode" />

		<!--ASSERT -->
<choose>
      <when test="                         some $code in $clUNCL7161                         satisfies normalize-space(text()) = $code" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $code in $clUNCL7161 satisfies normalize-space(text()) = $code">
          <attribute name="id">PEPPOL-T01-CL002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Reason code MUST be according to UNCL 7161 D.16B.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M22" select="@*|*" />
  </template>
  <template match="text()" mode="M22" priority="-1" />
  <template match="@*|node()" mode="M22" priority="-2">
    <apply-templates mode="M22" select="@*|*" />
  </template>
</stylesheet>
