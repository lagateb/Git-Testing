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
                <xls:variable name="printnumber" select="./asset_feature[@feature='svtx:layout-print-number']/@value_string"/>
                <xsl:value-of select="$printnumber"/>
    </xsl:template>

</xsl:stylesheet>