<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:param name="transFormed"/>

    <xsl:variable name="debug" select="false()" as="xs:boolean"/>

    <!-- löscht die Sonderzeichen für Linebreak Flyer und Produktsteckbrief und setzt für PPTX das break-->


    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$storageContent"><xsl:apply-templates select="$content"  /></xsl:if>
    </xsl:template>





    <!-- kopiert alle elemente + attribute -->
    <xsl:template match="*|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()">
        <!-- löschen der anderen trenner -->
        <xsl:variable name="con" select="replace(., '&#xe001;|&#xe002;|&#xe003;', '')"/>
        <xsl:variable name="breakType" select="if (name(parent::*) = 'paragraph') then 'softbreak' else 'break'" />
        <xsl:call-template name="break" >
            <xsl:with-param name="text" select="$con" />
            <xsl:with-param name="breakType" select="$breakType" />
        </xsl:call-template>
    </xsl:template>


    <!-- einfach nur das link-element entfernen -->
    <xsl:template match="link">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="break">
        <xsl:param name="text" select="string(.)"/>
        <xsl:param name="breakType" />
        <xsl:choose>
            <xsl:when test="contains($text, '&#xe000;')">
                <xsl:variable name="before" select="substring-before($text, '&#xe000;')"/>
                <xsl:variable name="after" select="substring-after($text, '&#xe000;')"/>
                <xsl:variable name="add" select="not(ends-with($before,' ') or ends-with($before,'-') or starts-with($after,' ' ) or starts-with($after,'-' ) )"/>
                <xsl:value-of select="if ($add) then concat($before,'-') else $before"/><xsl:element name="{$breakType}"/>
                <xsl:call-template name="break">
                    <xsl:with-param
                            name="text"
                            select="substring-after($text, '&#xe000;')"
                    />
                    <xsl:with-param name="breakType" select="$breakType" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




</xsl:stylesheet>
