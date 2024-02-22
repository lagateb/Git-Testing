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

    <!-- Erzeugt ein FAQ-TextAsset aus der Vorlage und verbindet es mit dem Artikel  -->

    <xsl:template match="asset[starts-with(@type, 'article.optional-module.faq.')]">
        <xsl:variable name="faqArticleAsset" select="."/>
        <xsl:variable name="resourceKey" select="'svtx:optional-modules.faq'"/>
        <xsl:variable name="faqTextAsset" select="(cs:asset()[@censhare:resource-key=$resourceKey]/cs:child-rel()[@key='user.main-content.'])[1]" as="element(asset)?"/>
        <xsl:variable name="res" select="svtx:cloneFAQAsset($faqArticleAsset,$faqTextAsset)"/>
        <result><xsl:copy-of select="$res"/></result>
    </xsl:template>

    <xsl:function name="svtx:cloneFAQAsset" as="element(asset)?">
        <xsl:param name="parentAsset" as="element(asset)?"/>
        <xsl:param name="template" as="element(asset)?"/>


        <xsl:variable name="newName" select="concat($parentAsset/@name,' ',$template/@name)"/>
        <xsl:variable name="position" select="count($parentAsset/cs:child-rel()[@key='user.main-content.'])+1" as="xs:integer"/>

        <xsl:variable name="clone"/>
        <cs:command name="com.censhare.api.assetmanagement.CloneAndCleanAssetXml" returning="clone">
            <cs:param name="source" select="$template"/>
        </cs:command>
        <!-- Erzeugen einer Kopie ohne Kinder
             was ist mir der Preview ?
        -->

        <xsl:variable name="newTextAsset">
            <asset type="{$clone/@type}" name="{$newName}" wf_id="10" wf_step="10">
                <xsl:copy-of select="$clone/node() except $clone/( asset_element[@idx=0],child_asset_rel)"/>
                <asset_element idx="0" key="actual."/>
                <parent_asset_rel key="user.main-content." parent_asset="{$parentAsset/@id}" sorting="{$position}">
                </parent_asset_rel>
            </asset>
        </xsl:variable>

        <xsl:copy-of select="svtx:checkInNewAsset($newTextAsset)"/>
    </xsl:function>


    <xsl:function name="svtx:checkInNewAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>



</xsl:stylesheet>

