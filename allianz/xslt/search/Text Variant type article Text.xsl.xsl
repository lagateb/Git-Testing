<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <!-- Sucht alle Artikel, die noch nicht fertig sind und deren TextAsset eine Variante mit asset_rel_feature = sales,agent haben -->

    <!-- parameters -->
    <xsl:param name="context-id"/>

    <!-- root match -->
    <xsl:template match="asset">
        <xsl:variable name="assetIds" as="xs:string*">
            <xsl:for-each select="cs:child-rel()/cs:asset()[@censhare:asset.type='text.*']">
                <xsl:for-each select="child_asset_rel/asset_rel_feature[@feature='svtx:text-variant-type']">
                    <xsl:message>====
                        <xsl:copy-of select=".."/>
                    </xsl:message>
                    <xsl:value-of select="../@child_asset"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <query>
            <condition name="censhare:asset.id" op="IN" value="{string-join($assetIds, ',')}" sepchar=","/>
            <sortorders>
                <grouping mode="none"/>
                <order ascending="true" by="censhare:asset.name"/>
            </sortorders>
        </query>
    </xsl:template>

</xsl:stylesheet>
