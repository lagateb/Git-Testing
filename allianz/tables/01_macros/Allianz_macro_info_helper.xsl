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


    <!-- asset match -->
    <xsl:template match="asset">
        <xsl:variable name="asset" select="."/>
        <xsl:variable name="pos" select="$asset/parent_asset_rel[@key='user.main-content.']/@sorting"/>
        <xsl:variable name="relations" select="count($asset/asset_feature[@feature='svtx:faq.medium'])"/>
        <xsl:variable name="time" select="current-time()"/>
        <xsl:value-of select="concat($pos,'/',$relations,'/',$asset/@id,'/',$time)"/>
    </xsl:template>

</xsl:stylesheet>
