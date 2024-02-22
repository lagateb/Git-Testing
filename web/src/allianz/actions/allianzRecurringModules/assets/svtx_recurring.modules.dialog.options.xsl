<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

  <xsl:template match="/asset[starts-with(@type, 'product.')]">

    <!-- 1. All recurring modules in system -->
    <xsl:variable name="recurringModules" select="cs:asset()[@censhare:asset.type='article.*'and
                                                             @censhare:asset-flag = 'is-template' and
                                                             @censhare:template-hierarchy='root.content-building-block.recurring-modules.']" as="element(asset)*"/>
    <!-- 2. Can modules be exchanged? Does this product have already recurring modules? -->
    <xsl:variable name="productModules" select="cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
    <result>
      <options censhare:_annotation.arraygroup="true">
        <xsl:for-each select="$productModules[@type=$recurringModules/@type]">
          <xsl:variable name="currentModule" select="." as="element(asset)?"/>
          <xsl:variable name="recurringModule" select="$recurringModules[@type=$currentModule/@type][1]" as="element(asset)?"/>
          <xsl:variable name="name" select="cs:master-data('asset_typedef')[@asset_type=$currentModule/@type][1]/@name" as="xs:string?"/>
          <xsl:variable name="proceed" as="xs:boolean">
            <xsl:choose>
              <xsl:when test="@type eq 'article.optional-module.vsk.'">
                <xsl:variable name="recurringVskModuleTemplate" as="element(asset)?"
                              select="(cs:asset()[@censhare:asset.type='article.optional-module.vsk.' and
                                                  @censhare:asset-flag='is-template' and
                                                  @censhare:template-hierarchy='root.content-building-block.recurring-modules.'])[1]"/>
                <xsl:variable name="textAssets" select="$recurringVskModuleTemplate/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.*']" as="element(asset)*"/>
                <xsl:variable name="productRefIds" select="$textAssets/asset_feature[@feature='svtx:product-ref']/@value_asset_id" as="xs:long*"/>
                <xsl:value-of select="$productRefIds = $rootAsset/@id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="true()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="$proceed">
            <option>
              <product_module censhare:_annotation.datatype="number"><xsl:value-of select="$currentModule/@id"/></product_module>
              <recurring_module censhare:_annotation.datatype="number"><xsl:value-of select="$recurringModule/@id"/></recurring_module>
              <checked censhare:_annotation.datatype="boolean"><xsl:value-of select="exists($currentModule/asset_feature[@feature='svtx:recurring-module-of'])"/></checked>
              <is_recurring_module censhare:_annotation.datatype="boolean"><xsl:value-of select="exists($currentModule/asset_feature[@feature='svtx:recurring-module-of'])"/></is_recurring_module>
              <name censhare:_annotation.datatype="string"><xsl:value-of select="$name"/></name>
              <type censhare:_annotation.datatype="string"><xsl:value-of select="$recurringModule/@type"/></type>
              <article_type censhare:_annotation.datatype="string"><xsl:value-of select="if (contains($recurringModule/@type, 'optional')) then 'optional' else 'basic'"/></article_type>
            </option>
          </xsl:if>
        </xsl:for-each>
      </options>
    </result>
  </xsl:template>
</xsl:stylesheet>
