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
    <!-- Merged headline subline body jetzt auch bei der Nachhaltigkeit -->

    <!-- wird dann in der PPTX wie folgt eingebunden svtxtr:svtx:pptx.transform_sustainability_merge_headline_body[x]
     x => 1..3
     svtx:article/content/pos(x)/headline
     svtx:article/content/pos(x)/subline
     svtx:article/content/pos(x)/body
    -->

    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />


    <xsl:variable name="debug" select="true()" as="xs:boolean"/>

    <xsl:function name="svtx:getPos">
        <xsl:param name="content"/>
        <xsl:param name="pos"/>
        <xsl:choose>
            <xsl:when test="$pos=2">
                <xsl:copy-of select="$content/pos2"/>
            </xsl:when>
            <xsl:when test="$pos=3">
                <xsl:copy-of select="$content/pos3"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$content/pos1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$storageContent">

            <xsl:variable name="data" select="svtx:getPos($content/article/content,$transParamInt)"/>
            <xsl:if test="$data">
                <body><xsl:copy-of select="$data/headline/."/>
                    <xsl:if test="($data/body/*[1]/local-name()='paragraph') or $data/subline "><break/></xsl:if>
                    <xsl:copy-of select="$data/subline/."/>
                    <xsl:copy-of select="$data/body/."/>
                </body>

            </xsl:if>
        </xsl:if>
    </xsl:template>
    <!--
    <xsl:template match="paragraph">... <xsl:value-of select="normalize-space(.)"/>&#x2028;</xsl:template>
    -->

</xsl:stylesheet>
