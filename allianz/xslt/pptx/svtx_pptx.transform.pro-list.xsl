<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

    <xsl:variable name="debug" select="true()" as="xs:boolean"/>
    <xsl:param name="transFormed"/>


    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageConent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageConent"/>
        <xsl:if test="$content">
           <!-- <paragraph><xsl:apply-templates select="$transFormed/article/content/body/pro/bullet-list/item"/></paragraph>-->
            <bullet-list ident-val="-25" margin-left-val="25" bullet-height="90" bullet-char="…">
            <xsl:copy-of select="$content/article/content/body/pro/bullet-list/node()"/>
            </bullet-list>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
