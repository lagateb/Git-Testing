<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">


    <xsl:param name="relation" />
    <xsl:param name="addName" />

    <xsl:function name="svtx:checkInNewAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

    <xsl:function name="svtx:cloneTextAsset" as="element(asset)?">
        <xsl:param name="parentAsset" as="element(asset)?"/>
        <xsl:param name="addName" as="xs:string?"/>
        <xsl:param name="relationName" as="xs:string?"/>

        <xsl:variable name="newName" select="concat($parentAsset/@name,' ',$addName)"/>

        <xsl:variable name="relationFeature" select="if (contains($relationName,'sales')) then 'sales' else 'agent'" />
        <cs:command name="com.censhare.api.assetmanagement.CloneAndCleanAssetXml" returning="clone">
            <cs:param name="source" select="$parentAsset"/>
        </cs:command>
       <!-- Erzeugen einer Kopie ohne Kinder
            was ist mir der Preview ?
       -->

        <xsl:variable name="newTextAsset">

            <asset type="{$clone/@type}" name="{$newName}" wf_id="10" wf_step="10">
                <xsl:copy-of select="$clone/node() except $clone/( asset_element[@idx=0],child_asset_rel)"/>
                <asset_element idx="0" key="actual."/>
                <parent_asset_rel key="variant.1." parent_asset="{$parentAsset/@id}">
                    <asset_rel_feature  feature="svtx:text-variant-type"  value_key="{$relationFeature}"/>
                </parent_asset_rel>

                <!--
                <parent_asset_rel key="{$relationName}" parent_asset="{$parentAsset/@id}"/>
                <xsl:if test="exists($parentId) and  $parentId gt 0">
                    <parent_asset_rel key="user." parent_asset="{$parentId}"/>
                </xsl:if>
                -->
            </asset>
        </xsl:variable>

        <xsl:copy-of select="svtx:checkInNewAsset($newTextAsset)"/>
    </xsl:function>


    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:message>=== <xsl:value-of select="$addName"/> # <xsl:value-of select="$relation"/> </xsl:message>
        <xsl:variable name="clone" select="svtx:cloneTextAsset(.,$addName,$relation)"  />
        <xsl:message>===b <xsl:value-of select="$clone/@id" /></xsl:message>
        <!-- <xsl:value-of select="$clone/@id" /> -->
        <xsl:copy-of select="$clone"/>
    </xsl:template>

</xsl:stylesheet>
