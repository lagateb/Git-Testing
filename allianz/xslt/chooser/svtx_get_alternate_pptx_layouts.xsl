<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom" >

    <!-- svtx_get_alternate_pptx_layouts
      Liefert von der übergebenen ID eines Text Assets die PPTX Layouts, die möglich sind
      text => Article => user.
      <asset_feature  feature="svtx:text-size" value_key="size-s"/>
       <xsl:variable name="size" select="$pptx/asset_feature[@feature='svtx:text-size']/@value_key"/>
                <xsl:value-of select="if (($size) and contains($textAsset/@type,$size)) then true() else false()"/>
                type="text.size-s.
     -->

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

    <!-- parameters -->
    <xsl:param name="textAsset" select="asset"/>

    <!--
    svtx:text-size vergleich mit textsize Vorgabe
    svtx:layout-template-resource-key
    -->
    <xsl:function name="svtx:sortOrder" as="xs:integer">
        <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$type='standard'">1</xsl:when>
            <xsl:when test="$type='sales'">2</xsl:when>
            <xsl:when test="$type='agent'">3</xsl:when>
            <xsl:otherwise>4</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:getOptionElement">
        <xsl:param name="pptxAsset" as="element(asset)"/>
        <xsl:param name="position" />
        <option value="{$pptxAsset/@id}" display_value="{$pptxAsset/@name}" position="{$position}">
            <value censhare:_annotation.datatype="number"><xsl:value-of select="$pptxAsset/@id"/></value>
            <display_value censhare:_annotation.datatype="string"><xsl:value-of select="$pptxAsset/@name"/></display_value>
            <position censhare:_annotation.datatype="number"><xsl:value-of select="$position"/></position>
        </option>
    </xsl:function>

    <!-- root match TODO type='text.*'-->
    <xsl:template match="/">
        <xsl:message>===== svtx_get_alternate_pptx_layouts = <xsl:value-of select="$textAsset/@id"></xsl:value-of> </xsl:message>
        <xsl:variable name="textType" select="$textAsset/@type" as="xs:string"/>

        <xsl:variable name="articleAsset" select="$textAsset/cs:parent-rel()[@key='user.main-content.']"/>

        <xsl:variable name="currentPPTX"  as="element()?">
            <xsl:choose>
                <xsl:when test="starts-with($textAsset/@type, 'text.faq')"><xsl:copy-of  select="$textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:child-rel()[@key = 'target.']"/></xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="tmpPPTX">
                        <xsl:copy-of  select="($articleAsset/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='standard']/..)[1]"/>
                    </xsl:variable>
                    <!-- Wenn die PPTX zur Textsize passt -->
                    <xsl:variable name="pptxTextSize" select="$tmpPPTX//asset_feature[@feature='svtx:text-size']/@value_key" as="xs:string?"/>
                    <xsl:if test="$tmpPPTX and contains($textType,$pptxTextSize)">
                        <xsl:copy-of  select="($articleAsset/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='standard']/..)[1]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="pptxMasterResourceKey" select="($currentPPTX/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref)[1]"/>
        <options>
            <xsl:if test="$pptxMasterResourceKey">
                <xsl:variable name="currentLayoutPPTX" select="cs:asset()[@censhare:resource-key=$pptxMasterResourceKey]" as="element(asset)?"/>
                <xsl:variable name="articleTemplate"
                              select="$currentLayoutPPTX/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'article.*']/asset_feature[@feature='censhare:asset-flag' and @value_key='is-template']/.."/>

                <xsl:if test="$articleTemplate and $articleTemplate/child_asset_rel[@key='user.alternate-pptx-layout.']">
                    <xsl:for-each select="$articleTemplate/cs:child-rel()[@key='user.alternate-pptx-layout.']">
                        <xsl:sort data-type="number" order="descending" select="./parent_asset_rel[@key='user.alternate-pptx-layout.']/@sorting"/>
                        <xsl:variable name="al" select="."/>
                        <xsl:variable name="toPso" select="$al/parent_asset_rel[@key='user.alternate-pptx-layout.']/@sorting"/>

                        <xsl:variable name="pos" select="$toPso"/>
                        <xsl:if test="$currentLayoutPPTX/@id  != $al/@id  ">
                            <xsl:copy-of select="svtx:getOptionElement($al,$pos)"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                <xsl:copy-of select="svtx:getOptionElement($currentPPTX,0)"/>
            </xsl:if>
        </options>
    </xsl:template>

</xsl:stylesheet>
