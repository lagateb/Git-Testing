<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>

    <!-- schaut nach, ob alle FAQ-Texte, die eine Webausleitung haben auch Feigegeben (30) sind -->

    <xsl:template match="/" >
        <xsl:variable name="articleAsset" select="./asset"/>
        <xsl:variable name="data">
            <data>
                <xsl:for-each select="$articleAsset/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.']">
                    <xsl:variable name="textAsset" select="."/>
                    <xsl:copy-of select ="svtx:checkApprovedforUse($textAsset)" />
                </xsl:for-each>
            </data>
        </xsl:variable>
        <xsl:variable name="result" select="count($data/data/retValue[@val='1'])"/>
        <xsl:message>==== count =  <xsl:value-of select="$result" /> </xsl:message>
        <result><value val="{$result}"/></result>
    </xsl:template>


    <xsl:function name="svtx:checkApprovedforUse">
        <xsl:param name="textAsset" as="element(asset)"/>
        <retValue>
            <xsl:choose>
                <!-- or  count($textAsset/asset_feature[@feature='svtx:preselected-output-channel'])>0 -->
                <xsl:when test="$textAsset/@wf_step lt 30 ">
                    <xsl:attribute name="val" select="'0'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="val" select="'1'"/>
                </xsl:otherwise>
            </xsl:choose>
        </retValue>
    </xsl:function>


</xsl:stylesheet>
