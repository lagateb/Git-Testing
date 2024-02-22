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
        <xsl:variable name="responsibleId" select="child_asset_rel[@key='user.responsible.']/@child_asset" />
        <xsl:if test="$responsibleId">
            <xsl:variable name="responsible" select="cs:get-asset(xs:long($responsibleId))" as="element(asset)?"/>
            <xsl:value-of select="$responsible/@name"/>
        </xsl:if>
        <!--
        name="[Savotex] Massenberg, Nico"
        <xsl:variable name="featureKey" select="'svtx:event-requirements'"/>
        <xsl:choose>
            <xsl:when test="asset_feature[@feature=$featureKey]">
                <xsl:value-of select="asset_feature[@feature=$featureKey]/@value_string"/>
            </xsl:when>
            <xsl:when test="$rootAsset and $rootAsset/asset_feature[@feature=$featureKey]">
                <xsl:value-of select="$rootAsset/asset_feature[@feature=$featureKey]/@value_string"/>
            </xsl:when>
        </xsl:choose>
        -->
    </xsl:template>

</xsl:stylesheet>