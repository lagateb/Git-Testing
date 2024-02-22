<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="cs csc">

    <!-- feature url  -->

    <!-- output -->
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>

    <!-- asset match -->
    <xsl:template match="asset" as="xs:string">
        <xsl:variable name="targetGroupAsset" select="cs:feature-ref-reverse()[@key = 'censhare:target-group'][1]" />
        <xsl:if test="$targetGroupAsset">
            <xsl:value-of select="$targetGroupAsset/@name"/>
        </xsl:if>
        <xsl:if test="not($targetGroupAsset)">-</xsl:if>

    </xsl:template>

</xsl:stylesheet>