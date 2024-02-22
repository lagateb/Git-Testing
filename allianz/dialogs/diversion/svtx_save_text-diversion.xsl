<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>
    <!--
        <xsl:param name="diversions" select="'root.web.aem.aem-vp.,18.08.2021T22:00:00.000Z,18.08.2022T22:00:00.000Z|root.web.aem.aem-azde.,18.08.2021T22:00:00.000Z,18.08.2022T22:00:00.000Z'"  as="xs:string"/>
        -->
    <xsl:param name="diversions" select="''"  as="xs:string"/>
    <xsl:template match="/" >
        <xsl:variable name="textAsset" select="./asset"/>

        <!-- Update ohne Historyänderung -->
        <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAsset">
            <cs:param name="source">
                <asset>
                    <xsl:copy-of select="$textAsset/@*"/>
                    <xsl:copy-of select="$textAsset/node() except($textAsset/asset_feature[@feature='svtx:preselected-output-channel'] )"/>
                    <!--
                    <asset_feature  feature="svtx:preselected-output-channel"  value_string="root.web.aem"/>
                    -->
                    <xsl:for-each select="tokenize($diversions, '\|')">
                        <xsl:variable name="diversion" select="."/>
                        <xsl:variable name="channelKey" select="substring-before($diversion,',')"/>
                        <xsl:variable name="tmp" select="substring-after($diversion,',')"/>
                        <xsl:variable name="validFrom" select="substring-before($tmp,',')"/>
                        <xsl:variable name="validUntil" select="substring-after($tmp,',')"/>

                        <xsl:message>diversions ===  <xsl:value-of select="$channelKey"/>    <xsl:value-of select="$validFrom"/> <xsl:value-of select="$validUntil"/>   </xsl:message>

                        <asset_feature  feature="svtx:preselected-output-channel"   value_string="{$channelKey}" >
                            <xsl:if test="$validUntil">
                                <asset_feature   feature="svtx:media-valid-until"   value_timestamp="{$validUntil}"/>
                            </xsl:if>
                            <xsl:if test="$validFrom">
                                <asset_feature feature="svtx:media-valid-from"   value_timestamp="{$validFrom}"/>
                            </xsl:if>
                        </asset_feature>
                    </xsl:for-each>

                </asset>
            </cs:param>
        </cs:command>
        <xsl:message>====<xsl:copy-of select="$resultAsset"/></xsl:message>
    </xsl:template>

</xsl:stylesheet>