<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

    <!--
      Liefert für den Text die Mediennutzung
      bzw. bei einem Artikel alle Nutzung in den Texten
      -->

    <!-- output -->
    <!-- TODO wieder zulassen
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
-->
    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>
    <!--
    26929  => mediaChannel PSB
    26895 => mediChannel Flyer
    -->
    <!-- text für bestimmtes Medium -->

    <xsl:function name="svtx:isForPSB" as="xs:boolean" >
        <xsl:param name="textAsset" as="element(asset)" />
        <xsl:variable name="hasLayout" select="(($textAsset/parent_asset_rel[@key='actual.']/@parent_asset/cs:asset())/asset_feature[@feature='svtx:layout-template-resource-key' and contains(@value_asset_key_ref,'twopager') ])" />
        <xsl:value-of select="if($hasLayout) then true() else false()"/>
    </xsl:function>

    <xsl:function name="svtx:isForFlyer" as="xs:boolean">
        <xsl:param name="textAsset" as="element(asset)" />
        <xsl:variable name="hasLayout" select="(($textAsset/parent_asset_rel[@key='actual.']/@parent_asset/cs:asset())/asset_feature[@feature='svtx:layout-template-resource-key' and contains(@value_asset_key_ref,'flyer') ])" />
        <xsl:value-of select="if($hasLayout) then true() else false()"/>
    </xsl:function>

    <xsl:function name="svtx:isForPPTX" as="xs:boolean">
        <xsl:param name="textAsset" as="element(asset)" />
        <xsl:variable name="article" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'article.*'])[1]" as="element(asset)?"/>
        <xsl:variable name="pptx" select="($article/cs:parent-rel()[@key = 'target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.'])[1]" as="element(asset)?"/>
        <xsl:variable name="textCount" select="count($article/child_asset_rel[@key='user.main-content.'])"/>
        <!-- asset_feature  feature="svtx:text-size" value_key="size-s"      type="text.size-s." -->
        <xsl:choose>
            <xsl:when test="not($pptx)"><xsl:value-of select="false()"/></xsl:when>
            <xsl:when test="$textCount=1"><xsl:value-of select="true()"/></xsl:when>
            <xsl:otherwise>
                <xsl:variable name="size" select="$pptx/asset_feature[@feature='svtx:text-size']/@value_key"/>
                <xsl:value-of select="if (($size) and contains($textAsset/@type,$size)) then true() else false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="svtx:hasPPTXMedia" as="xs:boolean">
        <xsl:param name="textAsset" as="element(asset)" />
        <xsl:value-of select="count($textAsset/asset_feature[@feature='svtx:faq.medium']) > 0"/>
    </xsl:function>


    <!-- Artikel hat für bestimmtes Medium  einen Text-->

    <xsl:function name="svtx:articleHasPSB" as="xs:boolean">
        <xsl:param name="article" as="element(asset)" />
        <xsl:variable name="layout" select="($article/cs:child-rel()[@key='user.main-content.'])/cs:parent-rel()[@key='actual.']/asset_feature[@feature='svtx:layout-template-resource-key' and contains(@value_asset_key_ref,'twopager') ]"/>
        <xsl:value-of select="if($layout) then true() else false()"/>
    </xsl:function>


    <xsl:function name="svtx:articleHasFlyer" as="xs:boolean">
        <xsl:param name="article" as="element(asset)" />
        <xsl:variable name="layout" select="($article/cs:child-rel()[@key='user.main-content.'])/cs:parent-rel()[@key='actual.']/asset_feature[@feature='svtx:layout-template-resource-key' and contains(@value_asset_key_ref,'flyer') ]"/>
        <xsl:value-of select="if($layout) then true() else false()"/>
    </xsl:function>

    <xsl:function name="svtx:articleHasPPTX" as="xs:boolean">
        <xsl:param name="article" as="element(asset)" />
        <!-- wenn Artikel auf Medium zeigt, dann ok -->
        <xsl:variable name="pptx" select="($article/cs:parent-rel()[@key = 'target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.'])[1]" as="element(asset)?"/>
        <xsl:value-of select="if($pptx) then true() else false()"/>
    </xsl:function>


    <xsl:function name="svtx:faqArticleHasTextWithPPTX" as="xs:boolean">
        <xsl:param name="article" as="element(asset)" />
        <!-- wenn Artikel auf Medium zeigt, dann ok -->
        <xsl:message>===== <xsl:copy-of select="$article/cs:child-rel()[@key = 'user.main-content.']/asset_feature[@feature='svtx:faq.medium']"/></xsl:message>
        <xsl:variable name="pptx" select="count($article/cs:child-rel()[@key = 'user.main-content.']/asset_feature[@feature='svtx:faq.medium'])>0"/>
        <xsl:value-of select="$pptx"/>
    </xsl:function>


    <xsl:function name="svtx:generateText">
        <xsl:param name="hasPSB"/>
        <xsl:param name="hasFlyer"/>
        <xsl:param name="hasPPTX"/>
        <xsl:param name="webChannels"/>
        <xsl:variable name="result" >
            <xsl:if test="$hasFlyer">Flyer, </xsl:if>
            <xsl:if test="$hasPSB">PSB, </xsl:if>
            <xsl:if test="$hasPPTX">PPTX, </xsl:if>
            <xsl:if test="$webChannels"><xsl:value-of select="$webChannels"/>, </xsl:if>
        </xsl:variable>
        <xsl:value-of select="if (string-length($result)>2) then substring($result,-1) else ''"/>
    </xsl:function>

    <xsl:function name="svtx:generateText2">
        <xsl:param name="hasPPTX"/>
        <xsl:param name="webChannels"/>
        <xsl:variable name="result" >
         <xsl:if test="$hasPPTX">PPTX, </xsl:if>
         <xsl:if test="$webChannels"><xsl:value-of select="$webChannels"/>, </xsl:if>

        </xsl:variable>
        <xsl:value-of select="if (string-length($result)>2) then substring($result,-1) else ''"/>
    </xsl:function>



    <xsl:function name="svtx:getUserNameForChannel" as="xs:string?">
        <xsl:param name="channelName" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$channelName eq 'root.web.aem.aem-vp.'">VP</xsl:when>
            <xsl:when test="$channelName eq 'root.web.aem.aem-azde.'">AZ.de</xsl:when>
            <xsl:when test="$channelName eq 'root.web.bs.'">BS</xsl:when>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:getChannels" as="xs:string">
        <xsl:param name="text" as="element(asset)" />
        <xsl:variable name="webChannels" as="xs:string*">
            <xsl:for-each select="$text/asset_feature[@feature='svtx:preselected-output-channel']/@value_string">
                <xsl:variable name="channel" select="svtx:getUserNameForChannel(.)"/>
                <xsl:if test="$channel">
                    <xsl:value-of select="$channel"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($webChannels, ', ')"/>
    </xsl:function>

    <xsl:function name="svtx:getArticleChannels" as="xs:string">
        <xsl:param name="article" as="element(asset)" />
        <xsl:variable name="allChannels" select="($article/cs:child-rel()[@key='user.main-content.']/
        cs:asset()[@censhare:asset.type = 'text.*' and not(@censhare:asset.type = 'text.public.*')])/asset_feature[@feature='svtx:preselected-output-channel']/@value_string"/>

        <xsl:variable name="webChannels" as="xs:string*">
            <xsl:for-each select="distinct-values($allChannels)">
                <xsl:variable name="channel" select="svtx:getUserNameForChannel(.)"/>
                <xsl:if test="$channel">
                    <xsl:value-of select="$channel"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($webChannels, ', ')"/>
    </xsl:function>

    <!-- asset match -->
    <xsl:template match="asset">
        <xsl:choose>
            <xsl:when test=".[starts-with(@type, 'text.faq')]">
                <xsl:variable name="pttx" select="svtx:hasPPTXMedia(.)"/>
                <xsl:variable name="webChannels" select="svtx:getChannels(.)"/>
                <xsl:value-of select="svtx:generateText2($pttx,$webChannels)"/>
            </xsl:when>
            <xsl:when test=".[starts-with(@type, 'text.')]">
                <xsl:variable name="psb" select="svtx:isForPSB(.)"/>
                <xsl:variable name="flyer" select="svtx:isForFlyer(.)"/>
                <xsl:variable name="pttx" select="svtx:isForPPTX(.)"/>
                <xsl:variable name="webChannels" select="svtx:getChannels(.)"/>
                <xsl:value-of select="svtx:generateText($psb,$flyer,$pttx,$webChannels)"/>
            </xsl:when>

            <xsl:when test=".[starts-with(@type, 'article.optional-module.faq')]">
                <xsl:variable name="pttx" select="svtx:faqArticleHasTextWithPPTX(.)"/>
                <xsl:variable name="webChannels" select="svtx:getArticleChannels(.)"/>
                <xsl:value-of select="svtx:generateText2($pttx,$webChannels)"/>
            </xsl:when>
            <xsl:when test=".[starts-with(@type, 'article.')]">
                <xsl:variable name="psb" select="svtx:articleHasPSB(.)"/>
                <xsl:variable name="flyer" select="svtx:articleHasFlyer(.)"/>
                <xsl:variable name="pttx" select="svtx:articleHasPPTX(.)"/>
                <xsl:variable name="webChannels" select="svtx:getArticleChannels(.)"/>
                <xsl:value-of select="svtx:generateText($psb,$flyer,$pttx,$webChannels)"/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>