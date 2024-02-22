<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">
    <!-- Welches Seite -->
    <xsl:param name="transParam"/>

    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageConent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$storageConent">
            <xsl:apply-templates select="$storageConent/article/content/headline"/>
        </xsl:if>
    </xsl:template>
    <!--   <xsl:value-of select="number(replace($input, 'pt', ''))"/> -->
    <xsl:template match="headline" >
        <headline><xsl:copy-of  select="replace(.,'\$no',$transParam)"/></headline>
    </xsl:template>
</xsl:stylesheet>
