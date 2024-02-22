<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
>


    <xsl:param name="mediaAssignmentsIDs" select="'32330,32304'"/>
    <xsl:param name="webAssignments" select="''"/>

    <xsl:template match="/asset[@type ='text.faq.']">
        <xsl:message>====l===svtx:media: <xsl:value-of select="$mediaAssignmentsIDs"/> </xsl:message>
        <xsl:variable name="asset" select="."/>

        <xsl:variable name="checkedOutAsset" as="element(asset)">
            <cs:command name="com.censhare.api.assetmanagement.CheckOut">
                <cs:param name="source" select="$asset"/>
            </cs:command>
        </xsl:variable>

        <xsl:variable name="newAsset">
            <asset>
                <xsl:copy-of select="$checkedOutAsset/@*"/>
                <xsl:copy-of select="$checkedOutAsset/node() except($checkedOutAsset/asset_feature[@feature='svtx:faq.medium'],
                 $checkedOutAsset/asset_feature[@feature='svtx:preselected-output-channel'])" />

                <xsl:for-each select="tokenize($mediaAssignmentsIDs, ',')">
                    <xsl:variable name="assetID" select="." as="xs:string"/>
                    <asset_feature feature="svtx:faq.medium"  value_asset_id="{$assetID}" />
                </xsl:for-each>

                <xsl:for-each select="tokenize($webAssignments, '\|')">
                    <xsl:variable name="channelKey" select="."/>

                    <asset_feature  feature="svtx:preselected-output-channel"   value_string="{$channelKey}" >

                    </asset_feature>
                </xsl:for-each>
            </asset>
        </xsl:variable>

        <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="result">
            <cs:param name="source" select="$newAsset" />
        </cs:command>

    </xsl:template>

</xsl:stylesheet>
