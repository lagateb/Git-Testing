<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="cs csc">



    <!-- output -->
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>

    <!-- asset match -->
    <xsl:template match="asset" as="xs:string">
        <xsl:variable name="map" as="element(channel)*">
            <channel key="root.web.aem.aem-vp.">VP</channel>
            <channel key="root.web.bs.">BS</channel>
            <channel key="root.web.aem.aem-azde.">AZ</channel>
        </xsl:variable>
        <xsl:variable name="keys" select="asset_feature[@feature='censhare:output-channel']/@value_key"/>
        <xsl:value-of select="string-join($map[@key=$keys]/text(),', ')"/>
    </xsl:template>

</xsl:stylesheet>
