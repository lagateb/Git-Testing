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



    <xsl:variable name="debug" select="false()" as="xs:boolean"/>
    <xsl:variable name="debugLog" select="false()" as="xs:boolean"/>

    <xsl:template match="/asset[starts-with(@type, 'text.') and @version gt 1]">

        <xsl:if test="$debugLog">
            <xsl:message>########################## Start WS meta information ##########################</xsl:message>
        </xsl:if>

        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>

        <!-- current asset -->
        <xsl:variable name="asset" select="cs:get-asset(@id)" as="element(asset)?"/>

        <xsl:variable name="hasPictures" select="count($asset/child_asset_rel[@key='user.media.']) gt 0" />

        <!-- read content xml -->
        <xsl:variable name="contentXml">
            <xsl:variable name="masterStorage" select="$asset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
            <xsl:variable name="xml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
            <xsl:if test="$xml">
                <xsl:copy-of select="$xml"/>
            </xsl:if>
        </xsl:variable>

        <xsl:if test="$debugLog">
            <xsl:copy-of select="$contentXml"/>
        </xsl:if>

        <xsl:variable name="pictureIds" as="xs:long*">
            <xsl:for-each select="$contentXml//@xlink:href">
                <xsl:variable name="id" select="substring-after(., 'censhare:///service/assets/asset/id/')" as="xs:string?"/>
                <xsl:variable name="pictureAsset" select="if ($id castable as xs:long) then cs:get-asset(xs:long($id)) else ()" as="element(asset)?"/>
                <xsl:if test="starts-with($pictureAsset/@type, 'picture.')">
                    <xsl:value-of select="$pictureAsset/@id"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$debugLog">
            <ids><xsl:value-of select="$pictureIds"/></ids>
        </xsl:if>


        <xsl:if test="($hasPictures or count($pictureIds) gt 0) and (exists($asset/parent_asset_rel[@key='user.main-content.'] or
        exists($asset/parent_asset_rel[@key='variant.1.']))) ">
            <cs:command name="com.censhare.api.assetmanagement.Update">
                <cs:param name="source">
                    <asset>
                        <xsl:copy-of select="$asset/@*"/>
                        <xsl:copy-of select="$asset/node() except($asset/child_asset_rel[@key='user.media.'])"/>
                        <xsl:for-each select="distinct-values($pictureIds)">
                            <child_asset_rel child_asset="{.}" key="user.media."/>
                        </xsl:for-each>
                    </asset>
                </cs:param>
            </cs:command>
        </xsl:if>

        <xsl:if test="$debugLog">
            <xsl:message>########################## End WS meta information ##########################</xsl:message>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
