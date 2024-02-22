<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>

    <!-- liest die gewählten Kanalauswertungen und deren Gültigkeit
        und baut options/option
    -->

    <xsl:template match="/" >
        <xsl:variable name="textAsset" select="./asset"/>
        <options>
            <xsl:for-each select="$textAsset/asset_feature[@feature='svtx:preselected-output-channel']">
                <xsl:variable name="key" select="./@value_string" as="xs:string"/>
                <xsl:variable name="from" select="./asset_feature[@feature='svtx:media-valid-from']/@value_timestamp" as="xs:string?"/>
                <xsl:variable name="until" select="./asset_feature[@feature='svtx:media-valid-until']/@value_timestamp" as="xs:string?"/>
                <option>
                    <xsl:attribute name="key" select="$key"/>
                    <xsl:attribute name="validFrom" select="$from"/>
                    <xsl:attribute name="validUntil" select="$until"/>
                </option>
            </xsl:for-each>
        </options>
    </xsl:template>

</xsl:stylesheet>