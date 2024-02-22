<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="cs csc">

    <!-- Standard/Marketing/Vertrieb  -->

    <!-- output -->
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>

    <!-- asset match -->
    <xsl:template match="asset">
        <xsl:choose>
            <xsl:when test="starts-with(@type,'text.')">
                <xsl:variable name="speech" select="parent_asset_rel[@key='variant.1.']/asset_rel_feature[@feature='svtx:text-variant-type']/@value_key"/>
                <xsl:variable name="speech1" select="if($speech) then $speech else 'standard'"/>
                <xsl:value-of select="cs:master-data('feature_value')[@feature='svtx:text-variant-type' and @value_key=$speech1]/@name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="speech" select="asset_feature[@feature='svtx:text-variant-type']/@value_key"/>
                <xsl:if test="$speech">
                <xsl:value-of select="cs:master-data('feature_value')[@feature='svtx:text-variant-type' and @value_key=$speech]/@name"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>