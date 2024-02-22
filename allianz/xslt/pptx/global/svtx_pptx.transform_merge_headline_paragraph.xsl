<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:param name="transParam" select="1"/>
    <xsl:param name="transFormed"/>
    <!-- baut aus einer struktur headline mit paragraph zu einem Body um -->
    <!-- wird dann in der PPTX wie folgt eingebunden svtxtr:svtx:pptx.transform_merge_headline_paragrpah[x]
     x => 1..
    -->

    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />


    <xsl:variable name="debug" select="true()" as="xs:boolean"/>

    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$storageContent">
            <xsl:variable name="data" select="$content/article/content/body/bullet-list/item[$transParamInt]"/>
            <xsl:if test="$data">
                <body><xsl:copy-of select="$data/headline/."/><break/>
                    <xsl:copy-of select="$data/paragraph/."/>
                </body>

            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
    <xsl:template match="paragraph">... <xsl:value-of select="normalize-space(.)"/>&#x2028;</xsl:template>
    -->

</xsl:stylesheet>
