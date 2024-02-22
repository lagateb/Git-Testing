<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">
    <xsl:param name="transParam"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>


    <!-- zum Test $transParam
    <xsl:variable name="transParam" select="1" as="xs:integer"/>
    -->
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$storageContent">
            <xsl:choose>
                <xsl:when test="$storageContent/article/content/calltoaction-link/text()"><group action="show"/></xsl:when>
                <xsl:otherwise><group action="hide"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>