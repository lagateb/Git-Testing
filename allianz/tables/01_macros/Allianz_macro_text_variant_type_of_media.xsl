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
    <xsl:template match="asset">
        <xsl:variable name="textVariantType" select="asset_feature[@feature='svtx:text-variant-type']/@value_key" />

        <xsl:variable name="textVariantTypeName">
            <xsl:choose>
                <xsl:when test="$textVariantType = 'standard2'">

                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="cs:master-data('feature_value')[@feature='svtx:text-variant-type' and @value_key=$textVariantType]/@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$textVariantTypeName"/>
    </xsl:template>

</xsl:stylesheet>