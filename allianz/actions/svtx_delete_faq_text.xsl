<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:ns1="http://www.w3.org/1999/ns1"
        xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
        xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
        version="2.0" xmlns:xsL="http://www.w3.org/1999/XSL/Transform">



    <xsl:variable name="pptxFAQLayoutKey" select="'svtx:optional-modules.faq.slide'"/>

    <!-- Löscht ein FAQ-TextAsset und regeneriert alle abhängigen PPTX-Assets -->
    <!-- Liste der abhängigen PPTX-Asset -->
    <!-- löschen des Asset -->
    <!-- renumber der anderen Asset -->
    <!-- Regenerieren der FAQ-PPTX-Asset -->

    <xsl:template match="asset[starts-with(@type, 'text.faq.')]">
        <xsl:variable name="faqTextAsset" select="."/>
        <xsl:variable name="faqArticelAssetId" select="$faqTextAsset/parent_asset_rel[@key = 'user.main-content.']/@parent_asset"/>

        <xsl:variable name="pptxIssueIDs" select="$faqTextAsset/asset_feature[@feature='svtx:faq.medium']/@value_asset_id" />

        <xsl:variable name="tmp" select="svtx:deleteAsset($faqTextAsset/@id)"/>
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <xsl:variable name="tmp1" select="svtx:normalizeSorting(cs:get-asset($faqArticelAssetId))"/>
        <xsl:variable name="tmp2" select="svtx:regeneratePPTX($pptxIssueIDs)"/>

    </xsl:template>




    <xsl:function name="svtx:regeneratePPTX">
        <xsl:param name="changed" as="xs:string*"/>
        <xsl:for-each select="distinct-values($changed)">
            <xsl:variable name="pptxIssueID" select="." as="xs:string"/>
            <xsl:variable name="pptxFAQAsset"   select="(($pptxIssueID/cs:asset())/cs:child-rel()[@key='target.'])/asset_feature[@feature='svtx:layout-template-resource-key' and @value_asset_key_ref=$pptxFAQLayoutKey]/.." />
            <xsl:message>=== svtx:regeneratePPTX  <xsl:value-of select="$pptxIssueID"/>  <xsl:copy-of select="$pptxFAQAsset"/></xsl:message>
            <xsl:variable name="trans1"/>
            <xsl:if test="$pptxFAQAsset">
                <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans1">
                    <cs:param name="key" select="'svtx:regenerate.pptx.faq.slide.on.text.changed'"/>
                    <cs:param name="source" select="$pptxFAQAsset"/>
                </cs:command>
            </xsl:if>
        </xsl:for-each>

    </xsl:function>


    <!-- Normaliesiert die Sortierreihenfolge der TextAsset wenn nötig und gibt die Anzahl zurück -->
    <xsl:function name="svtx:normalizeSorting" as="xs:integer">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:for-each select="$articleAsset/child_asset_rel[@key='user.main-content.']">
            <xsl:sort select="./@sorting"/>
            <xsl:if test="position()!=./@sorting">
                <xsl:variable name="ret" select="svtx:updateSorting(./@child_asset,position(),$articleAsset/@id)"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="count($articleAsset/cs:child-rel()[@key='user.main-content.'])"/>
    </xsl:function>


    <xsl:function name="svtx:updateSorting">
        <xsl:param name="textFaqID" as="xs:integer"/>
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="articleFaqID" as="xs:integer"/>

        <xsl:message> === sort <xsl:value-of select="$textFaqID"/> =  <xsl:value-of select="$position"/>  =  <xsl:value-of select="$articleFaqID"/>  </xsl:message>
        <xsl:variable name="textAsset" select="$textFaqID/cs:asset()"/>
        <!-- Ohne Ändrungshistorie, da sonst etliche unnötige Trigger gestartet werden -->
        <cs:command name="com.censhare.api.assetmanagement.Update">
            <cs:param name="source">
                <asset>
                    <xsl:copy-of select="$textAsset/@*"/>
                    <xsl:copy-of select="$textAsset/node() except($textAsset/(parent_asset_rel[@key='user.main-content.']),$textAsset/asset_element )"/>
                    <asset_element idx="0" key="actual."/>

                    <parent_asset_rel key="user.main-content." parent_asset="{$articleFaqID}" sorting="{$position}"/>
                </asset>
            </cs:param>
        </cs:command>
    </xsl:function>

    <xsl:function name="svtx:deleteAsset">
        <xsl:param name="assetId"/>
        <cs:command name="com.censhare.api.assetmanagement.Delete">
            <cs:param name="source" select="$assetId"/>
            <cs:param name="state" select="'physical'"/>
        </cs:command>
    </xsl:function>


</xsl:stylesheet>

