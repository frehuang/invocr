<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform"
            xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
            xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
            xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:OrderCancellation-2"
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
    <ns0:schematron-output xmlns:ns0="http://purl.oclc.org/dsdl/svrl" schemaVersion="iso" title="Rules for Peppol Order Cancellation transaction 3.0">
      <comment>
        <value-of select="$archiveDirParameter" />   
		 <value-of select="$archiveNameParameter" />  
		 <value-of select="$fileNameParameter" />  
		 <value-of select="$fileDirParameter" />
      </comment>
      <ns0:ns-prefix-in-attribute-values prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" />
      <ns0:ns-prefix-in-attribute-values prefix="cac" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" />
      <ns0:ns-prefix-in-attribute-values prefix="ubl" uri="urn:oasis:names:specification:ubl:schema:xsd:OrderCancellation-2" />
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
      <apply-templates mode="M18" select="/" />
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
    </ns0:schematron-output>
  </template>

<!--SCHEMATRON PATTERNS-->
<ns0:text xmlns:ns0="http://purl.oclc.org/dsdl/svrl">Rules for Peppol Order Cancellation transaction 3.0</ns0:text>

<!--PATTERN -->


	<!--RULE -->
<template match="//*[not(*) and not(normalize-space())]" mode="M18" priority="1000">
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
    <apply-templates mode="M18" select="@*|*" />
  </template>
  <template match="text()" mode="M18" priority="-1" />
  <template match="@*|node()" mode="M18" priority="-2">
    <apply-templates mode="M18" select="@*|*" />
  </template>

<!--PATTERN -->


	<!--RULE -->
<template match="/*" mode="M19" priority="1011">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:IssueDate | cbc:DueDate | cbc:TaxPointDate | cbc:StartDate | cbc:EndDate | cbc:ActualDeliveryDate" mode="M19" priority="1010">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0088'] | cac:PartyIdentification/cbc:ID[@schemeID = '0088'] | cbc:CompanyID[@schemeID = '0088']" mode="M19" priority="1009">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0192'] | cac:PartyIdentification/cbc:ID[@schemeID = '0192'] | cbc:CompanyID[@schemeID = '0192']" mode="M19" priority="1008">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0208'] | cac:PartyIdentification/cbc:ID[@schemeID = '0208'] | cbc:CompanyID[@schemeID = '0208']" mode="M19" priority="1007">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0201'] | cac:PartyIdentification/cbc:ID[@schemeID = '0201'] | cbc:CompanyID[@schemeID = '0201']" mode="M19" priority="1006">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0210'] | cac:PartyIdentification/cbc:ID[@schemeID = '0210'] | cbc:CompanyID[@schemeID = '0210']" mode="M19" priority="1005">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '9907']" mode="M19" priority="1004">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0211'] | cac:PartyIdentification/cbc:ID[@schemeID = '0211'] | cbc:CompanyID[@schemeID = '0211']" mode="M19" priority="1003">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '9906']" mode="M19" priority="1002">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0007'] | cac:PartyIdentification/cbc:ID[@schemeID = '0007'] | cbc:CompanyID[@schemeID = '0007']" mode="M19" priority="1001">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:EndpointID[@schemeID = '0151'] | cac:PartyIdentification/cbc:ID[@schemeID = '0151'] | cbc:CompanyID[@schemeID = '0151']" mode="M19" priority="1000">
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
    <apply-templates mode="M19" select="@*|*" />
  </template>
  <template match="text()" mode="M19" priority="-1" />
  <template match="@*|node()" mode="M19" priority="-2">
    <apply-templates mode="M19" select="@*|*" />
  </template>

<!--PATTERN -->
<variable name="clICD" select="tokenize('0002 0003 0004 0005 0006 0007 0008 0009 0010 0011 0012 0013 0014 0015 0016 0017 0018 0019 0020 0021 0022 0023 0024 0025 0026 0027 0028 0029 0030 0031 0032 0033 0034 0035 0036 0037 0038 0039 0040 0041 0042 0043 0044 0045 0046 0047 0048 0049 0050 0051 0052 0053 0054 0055 0056 0057 0058 0059 0060 0061 0062 0063 0064 0065 0066 0067 0068 0069 0070 0071 0072 0073 0074 0075 0076 0077 0078 0079 0080 0081 0082 0083 0084 0085 0086 0087 0088 0089 0090 0091 0093 0094 0095 0096 0097 0098 0099 0100 0101 0102 0104 0105 0106 0107 0108 0109 0110 0111 0112 0113 0114 0115 0116 0117 0118 0119 0120 0121 0122 0123 0124 0125 0126 0127 0128 0129 0130 0131 0132 0133 0134 0135 0136 0137 0138 0139 0140 0141 0142 0143 0144 0145 0146 0147 0148 0149 0150 0151 0152 0153 0154 0155 0156 0157 0158 0159 0160 0161 0162 0163 0164 0165 0166 0167 0168 0169 0170 0171 0172 0173 0174 0175 0176 0177 0178 0179 0180 0183 0184 0185 0186 0187 0188 0189 0190 0191 0192 0193 0194 0195 0196 0197 0198 0199 0200 0201 0202 0203 0204 0205 0206 0207 0208 0209 0210 0211 0212 0213 0214 0215 0216 0217 0218 0219 0220 0221 0222 0223 0224 0225 0226 0227 0228 0229 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 0240', '\s')" />
  <variable name="clMimeCode" select="tokenize('application/pdf image/png image/jpeg image/tiff application/acad application/dwg drawing/dwg application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.oasis.opendocument.spreadsheet', '\s')" />
  <variable name="clISO3166" select="tokenize('AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW 1A XI', '\s')" />
  <variable name="cleas" select="tokenize('0002 0007 0009 0060 0088 0096 0097 0106 0130 0135 0142 0151 0183 0184 0188 0190 0191 0192 0193 0195 0196 0198 0199 0200 0201 0204 0208 0209 0210 0211 0216 0218 0221 0230 0235 9910 9913 9914 9915 9918 9919 9920 9922 9923 9924 9925 9926 9927 9928 9929 9930 9931 9932 9933 9934 9935 9936 9937 9938 9939 9940 9941 9942 9943 9944 9945 9946 9947 9948 9949 9950 9951 9952 9953 9957 9959 0205 0225 0240', '\s')" />

	<!--RULE -->
<template match="/ubl:OrderCancellation" mode="M20" priority="1118">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CustomizationID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CustomizationID">
          <attribute name="id">PEPPOL-T115-B00101</attribute>
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
          <attribute name="id">PEPPOL-T115-B00102</attribute>
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
          <attribute name="id">PEPPOL-T115-B00103</attribute>
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
          <attribute name="id">PEPPOL-T115-B00104</attribute>
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
      <when test="cbc:CancellationNote" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CancellationNote">
          <attribute name="id">PEPPOL-T115-B00105</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:CancellationNote' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:OrderReference" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:OrderReference">
          <attribute name="id">PEPPOL-T115-B00106</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:OrderReference' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>

		<!--ASSERT -->
<choose>
      <when test="cac:BuyerCustomerParty" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:BuyerCustomerParty">
          <attribute name="id">PEPPOL-T115-B00107</attribute>
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
          <attribute name="id">PEPPOL-T115-B00108</attribute>
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
      <when test="not(@*:schemaLocation)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@*:schemaLocation)">
          <attribute name="id">PEPPOL-T115-B00109</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST not contain schema location.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:CustomizationID" mode="M20" priority="1117">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:CustomizationID" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(text()) = 'urn:fdc:peppol.eu:poacc:trns:order_cancellation:3'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(text()) = 'urn:fdc:peppol.eu:poacc:trns:order_cancellation:3'">
          <attribute name="id">PEPPOL-T115-B00201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:CustomizationID' MUST contain value 'urn:fdc:peppol.eu:poacc:trns:order_cancellation:3'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:ProfileID" mode="M20" priority="1116">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:ProfileID" />

		<!--ASSERT -->
<choose>
      <when test="normalize-space(text()) = 'urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3'" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="normalize-space(text()) = 'urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3'">
          <attribute name="id">PEPPOL-T115-B00301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ProfileID' MUST contain value 'urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:ID" mode="M20" priority="1115">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:ID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:IssueDate" mode="M20" priority="1114">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:IssueDate" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:IssueTime" mode="M20" priority="1113">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:IssueTime" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:Note" mode="M20" priority="1112">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:Note" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cbc:CancellationNote" mode="M20" priority="1111">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cbc:CancellationNote" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OrderReference" mode="M20" priority="1110">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OrderReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B00901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OrderReference/cbc:ID" mode="M20" priority="1109">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OrderReference/cbc:ID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OrderReference/*" mode="M20" priority="1108">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OrderReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B00902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorDocumentReference" mode="M20" priority="1107">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B01101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorDocumentReference/cbc:ID" mode="M20" priority="1106">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorDocumentReference/cbc:ID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorDocumentReference/*" mode="M20" priority="1105">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B01102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference" mode="M20" priority="1104">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B01301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cbc:ID" mode="M20" priority="1103">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cbc:ID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cbc:DocumentType" mode="M20" priority="1102">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cbc:DocumentType" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment" mode="M20" priority="1101">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject" mode="M20" priority="1100">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject" />

		<!--ASSERT -->
<choose>
      <when test="@mimeCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@mimeCode">
          <attribute name="id">PEPPOL-T115-B01701</attribute>
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
          <attribute name="id">PEPPOL-T115-B01702</attribute>
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
          <attribute name="id">PEPPOL-T115-B01703</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'filename' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference" mode="M20" priority="1099">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference" />

		<!--ASSERT -->
<choose>
      <when test="cbc:URI" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:URI">
          <attribute name="id">PEPPOL-T115-B02001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:URI' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/cbc:URI" mode="M20" priority="1098">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/cbc:URI" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/*" mode="M20" priority="1097">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/cac:ExternalReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B02002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/*" mode="M20" priority="1096">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/cac:Attachment/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B01601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:AdditionalDocumentReference/*" mode="M20" priority="1095">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:AdditionalDocumentReference/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B01302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:Contract" mode="M20" priority="1094">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:Contract" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B02201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:Contract/cbc:ID" mode="M20" priority="1093">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:Contract/cbc:ID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:Contract/*" mode="M20" priority="1092">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:Contract/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B02202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty" mode="M20" priority="1091">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T115-B02401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party" mode="M20" priority="1090">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndpointID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID">
          <attribute name="id">PEPPOL-T115-B02501</attribute>
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
          <attribute name="id">PEPPOL-T115-B02502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PartyLegalEntity' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cbc:EndpointID" mode="M20" priority="1089">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="@schemeID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@schemeID">
          <attribute name="id">PEPPOL-T115-B02601</attribute>
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
          <attribute name="id">PEPPOL-T115-B02602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Electronic Address Scheme (EAS)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification" mode="M20" priority="1088">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B02801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M20" priority="1087">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T115-B02901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyName" mode="M20" priority="1086">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T115-B03101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyName/cbc:Name" mode="M20" priority="1085">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress" mode="M20" priority="1084">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T115-B03301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" mode="M20" priority="1083">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" mode="M20" priority="1082">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" mode="M20" priority="1081">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" mode="M20" priority="1080">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" mode="M20" priority="1079">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine" mode="M20" priority="1078">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" mode="M20" priority="1077">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country" mode="M20" priority="1076">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T115-B04101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" mode="M20" priority="1075">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T115-B04201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/*" mode="M20" priority="1074">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B04102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/*" mode="M20" priority="1073">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PostalAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B03302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme" mode="M20" priority="1072">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:CompanyID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:CompanyID">
          <attribute name="id">PEPPOL-T115-B04301</attribute>
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
          <attribute name="id">PEPPOL-T115-B04302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:TaxScheme' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" mode="M20" priority="1071">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme" mode="M20" priority="1070">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B04501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID" mode="M20" priority="1069">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:ID" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/*" mode="M20" priority="1068">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B04502</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/*" mode="M20" priority="1067">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyTaxScheme/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B04303</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity" mode="M20" priority="1066">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
<choose>
      <when test="cbc:RegistrationName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:RegistrationName">
          <attribute name="id">PEPPOL-T115-B04701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:RegistrationName' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" mode="M20" priority="1065">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" mode="M20" priority="1064">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T115-B04901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" mode="M20" priority="1063">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T115-B05101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" mode="M20" priority="1062">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" mode="M20" priority="1061">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T115-B05301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" mode="M20" priority="1060">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T115-B05401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" mode="M20" priority="1059">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B05302</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" mode="M20" priority="1058">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B05102</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/*" mode="M20" priority="1057">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:PartyLegalEntity/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B04702</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact" mode="M20" priority="1056">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Name" mode="M20" priority="1055">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Telephone" mode="M20" priority="1054">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M20" priority="1053">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/*" mode="M20" priority="1052">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B05501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/*" mode="M20" priority="1051">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B02503</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:BuyerCustomerParty/*" mode="M20" priority="1050">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:BuyerCustomerParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B02402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty" mode="M20" priority="1049">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T115-B05901</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party" mode="M20" priority="1048">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party" />

		<!--ASSERT -->
<choose>
      <when test="cbc:EndpointID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID">
          <attribute name="id">PEPPOL-T115-B06001</attribute>
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
          <attribute name="id">PEPPOL-T115-B06002</attribute>
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
          <attribute name="id">PEPPOL-T115-B06003</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:PartyLegalEntity' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cbc:EndpointID" mode="M20" priority="1047">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cbc:EndpointID" />

		<!--ASSERT -->
<choose>
      <when test="@schemeID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="@schemeID">
          <attribute name="id">PEPPOL-T115-B06101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Attribute 'schemeID' MUST be present.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification" mode="M20" priority="1046">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B06301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M20" priority="1045">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T115-B06401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyName" mode="M20" priority="1044">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T115-B06601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyName/cbc:Name" mode="M20" priority="1043">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress" mode="M20" priority="1042">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T115-B06801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName" mode="M20" priority="1041">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" mode="M20" priority="1040">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName" mode="M20" priority="1039">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone" mode="M20" priority="1038">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" mode="M20" priority="1037">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CountrySubentity" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine" mode="M20" priority="1036">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" mode="M20" priority="1035">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country" mode="M20" priority="1034">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T115-B07601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" mode="M20" priority="1033">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T115-B07701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/*" mode="M20" priority="1032">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B07602</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/*" mode="M20" priority="1031">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PostalAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B06802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity" mode="M20" priority="1030">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity" />

		<!--ASSERT -->
<choose>
      <when test="cbc:RegistrationName" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:RegistrationName">
          <attribute name="id">PEPPOL-T115-B07801</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:RegistrationName' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" mode="M20" priority="1029">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" mode="M20" priority="1028">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T115-B08001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" mode="M20" priority="1027">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress" />

		<!--ASSERT -->
<choose>
      <when test="cac:Country" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Country">
          <attribute name="id">PEPPOL-T115-B08201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Country' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" mode="M20" priority="1026">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" mode="M20" priority="1025">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country" />

		<!--ASSERT -->
<choose>
      <when test="cbc:IdentificationCode" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:IdentificationCode">
          <attribute name="id">PEPPOL-T115-B08401</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:IdentificationCode' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" mode="M20" priority="1024">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/cbc:IdentificationCode" />

		<!--ASSERT -->
<choose>
      <when test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="(some $code in $clISO3166 satisfies $code = normalize-space(text()))">
          <attribute name="id">PEPPOL-T115-B08501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'Country codes (ISO 3166-1:Alpha2)'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" mode="M20" priority="1023">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:Country/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B08402</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" mode="M20" priority="1022">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B08202</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/*" mode="M20" priority="1021">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:PartyLegalEntity/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B07802</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact" mode="M20" priority="1020">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Name" mode="M20" priority="1019">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Telephone" mode="M20" priority="1018">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M20" priority="1017">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/*" mode="M20" priority="1016">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B08601</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/*" mode="M20" priority="1015">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B06004</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:SellerSupplierParty/*" mode="M20" priority="1014">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:SellerSupplierParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B05902</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty" mode="M20" priority="1013">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty" />

		<!--ASSERT -->
<choose>
      <when test="cac:Party" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cac:Party">
          <attribute name="id">PEPPOL-T115-B09001</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cac:Party' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party" mode="M20" priority="1012">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification" mode="M20" priority="1011">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification" />

		<!--ASSERT -->
<choose>
      <when test="cbc:ID" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:ID">
          <attribute name="id">PEPPOL-T115-B09201</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:ID' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="M20" priority="1010">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" />

		<!--ASSERT -->
<choose>
      <when test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="not(@schemeID) or (some $code in $clICD satisfies $code = @schemeID)">
          <attribute name="id">PEPPOL-T115-B09301</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Value MUST be part of code list 'ISO 6523 ICD list'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyName" mode="M20" priority="1009">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyName" />

		<!--ASSERT -->
<choose>
      <when test="cbc:Name" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="cbc:Name">
          <attribute name="id">PEPPOL-T115-B09501</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Element 'cbc:Name' MUST be provided.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyName/cbc:Name" mode="M20" priority="1008">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:PartyName/cbc:Name" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact" mode="M20" priority="1007">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Name" mode="M20" priority="1006">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Name" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Telephone" mode="M20" priority="1005">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:Telephone" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" mode="M20" priority="1004">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail" />
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/*" mode="M20" priority="1003">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/cac:Contact/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B09701</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/*" mode="M20" priority="1002">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/cac:Party/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B09101</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/cac:OriginatorCustomerParty/*" mode="M20" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/cac:OriginatorCustomerParty/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B09002</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M20" select="@*|*" />
  </template>

	<!--RULE -->
<template match="/ubl:OrderCancellation/*" mode="M20" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="/ubl:OrderCancellation/*" />

		<!--ASSERT -->
<choose>
      <when test="false()" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="false()">
          <attribute name="id">PEPPOL-T115-B00110</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Document MUST NOT contain elements not part of the data model.</ns0:text>
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


	<!--RULE -->
<template match="cbc:ProfileID" mode="M21" priority="1001">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:ProfileID" />

		<!--ASSERT -->
<choose>
      <when test="some $p in tokenize('urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3', '\s') satisfies $p = normalize-space(.)" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="some $p in tokenize('urn:fdc:peppol.eu:poacc:bis:advanced_ordering:3', '\s') satisfies $p = normalize-space(.)">
          <attribute name="id">PEPPOL-T115-R031</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>An order cancellation transaction MUST use profile advanced_ordering.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>

	<!--RULE -->
<template match="cbc:CustomizationID" mode="M21" priority="1000">
    <ns0:fired-rule xmlns:ns0="http://purl.oclc.org/dsdl/svrl" context="cbc:CustomizationID" />

		<!--ASSERT -->
<choose>
      <when test="starts-with(normalize-space(.), 'urn:fdc:peppol.eu:poacc:trns:order_cancellation:3')" />
      <otherwise>
        <ns0:failed-assert xmlns:ns0="http://purl.oclc.org/dsdl/svrl" test="starts-with(normalize-space(.), 'urn:fdc:peppol.eu:poacc:trns:order_cancellation:3')">
          <attribute name="id">PEPPOL-T115-R034</attribute>
          <attribute name="flag">fatal</attribute>
          <attribute name="location">
            <apply-templates mode="schematron-select-full-path" select="." />
          </attribute>
          <ns0:text>Specification identifier MUST start with the value 'urn:fdc:peppol.eu:poacc:trns:order_cancellation:3'.</ns0:text>
        </ns0:failed-assert>
      </otherwise>
    </choose>
    <apply-templates mode="M21" select="@*|*" />
  </template>
  <template match="text()" mode="M21" priority="-1" />
  <template match="@*|node()" mode="M21" priority="-2">
    <apply-templates mode="M21" select="@*|*" />
  </template>
</stylesheet>
