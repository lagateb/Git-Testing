<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs csc">

    <!-- feature url  -->

    <!-- output -->
    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>

    <!-- asset match -->
    <xsl:template match="asset">
        <xsl:choose>
            <xsl:when test="./@type = 'layout.'">
                <xls:variable name="printnumber" select="./asset_feature[@feature='svtx:layout-print-number']/@value_string"/>
                <xsl:choose>
                    <xsl:when test="$printnumber">1</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>