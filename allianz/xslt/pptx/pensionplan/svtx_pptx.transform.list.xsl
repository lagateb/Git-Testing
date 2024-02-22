<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">
    <!-- Welches List in List -->
    <xsl:param name="transParam"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>
    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />
    <!-- zum Test
    <xsl:variable name="transParam" select="1" as="xs:integer"/>
    -->
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageConent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$storageConent">
            <body> <xsl:apply-templates select="$storageConent/article/content/body/bullet-list/item[$transParamInt]/*"/></body>
        </xsl:if>
    </xsl:template>

    <xsl:template match="paragraph" mode="#all"> <xsl:copy-of  select="."/></xsl:template>

    <xsl:template match="bullet-list">
        <bullet-list level="1" bullet-char="•" >
            <xsl:apply-templates  select="./item"  />
        </bullet-list>
    </xsl:template>

    <xsl:template match="headline" />

    <xsl:template match="item" >
        <item>
            <xsl:apply-templates  select="./paragraph|bullet-list" mode="level2" />
        </item>
    </xsl:template>


    <xsl:template match="bullet-list" mode="level2" >
        <bullet-list level="2" bullet-char="-" ident-val="-28.5750" margin-left-val="54.9275" >
            <xsl:copy-of  select="./*"/>
        </bullet-list>
    </xsl:template>

</xsl:stylesheet>
