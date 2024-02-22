<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">
    <xsl:param name="transParam"/>

    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />

  <xsl:variable name="debug" select="true()" as="xs:boolean"/>
    <xsl:param name="transFormed"/>
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$storageContent">
             <xsl:variable name="data" select="$content/article/content/seals/seal[$transParamInt]"/>
        <xsl:if test="$data">
            <seal><headline><color value="#113388"><font-size value="12.0"><bold><xsl:apply-templates
                select="$data/headline"/></bold></font-size></color></headline>
            <paragraph><break/><color value="#113388"><font-size value="12.0"><xsl:apply-templates select="$data/paragraph"/></font-size></color>
            </paragraph>  </seal>

        </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
    <xsl:template match="paragraph">... <xsl:value-of select="normalize-space(.)"/>&#x2028;</xsl:template>
    -->

</xsl:stylesheet>
