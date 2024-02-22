<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:variable name="debug" select="true()" as="xs:boolean"/>
    <xsl:param name="transFormed"/>
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$storageContent"><accompanying-2><headline><color value="#113388"><font-size value="10.5"><bold><xsl:apply-templates
                select="$content/article/content/accompanying-2/headline"/></bold></font-size></color></headline>
            <paragraph><break/><color value="#000000"><font-size value="9.0"><xsl:apply-templates select="$content/article/content/accompanying-2/paragraph"/></font-size></color>
            </paragraph>  </accompanying-2>


        </xsl:if>
    </xsl:template>
    <!--
    <xsl:template match="paragraph">... <xsl:value-of select="normalize-space(.)"/>&#x2028;</xsl:template>
    -->

</xsl:stylesheet>
