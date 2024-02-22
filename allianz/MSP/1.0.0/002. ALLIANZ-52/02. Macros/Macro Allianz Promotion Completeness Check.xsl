<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  exclude-result-prefixes="cs csc">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

  <xsl:output indent="no" method="xhtml" omit-xml-declaration="no" encoding="UTF-8"/>

  <xsl:template match="/">
    <!-- collect checks -->
    <xsl:variable name="asset" select="asset"/>
    <xsl:variable name="checkAssets" select="csc:getResourceAssetsOfAssetType($asset, 'module.completeness-check.')"/>
    <xsl:variable name="checkResults">
      <xsl:for-each select="$checkAssets">
        <xsl:variable name="checkAsset" select="."/>
        <xsl:variable name="localizedAssetName" select="csc:getLocalizedAssetName($checkAsset)"/>
        <check name="{$localizedAssetName}" sortName="{csc:getSortingString($localizedAssetName)}" id="{$checkAsset/@id}" result="{csc:getCheckAssetResult($checkAsset, $asset)}" description="{csc:getLocalizedAssetDescription($checkAsset)}" importance="{if ($checkAsset/asset_feature[@feature='censhare:completeness-check.importance']) then $checkAsset/asset_feature[@feature='censhare:completeness-check.importance']/@value_key else 'optional'}"/>
      </xsl:for-each>
    </xsl:variable>
    <data>
      <xsl:if test="asset/@type='promotion.'">
      <xsl:choose>
          <xsl:when test="exists($checkResults/check)">
            <xsl:variable name="value" select="if ($checkResults/check[@importance='required' and @result='true']) then (count($checkResults/check[@importance='required' and @result='true']) * 100) div count($checkResults/check[@importance='required']) else (count($checkResults/check[@result='true']) * 100) div count($checkResults/check)"/>
            <xsl:variable name="complete" select="if ($checkResults/check[@importance='required' and @result='false']) then 'false' else 'true'"/>
            <xsl:choose>
              <xsl:when test="$complete='true'">
                <xsl:attribute name="color" select="'#00CC00'" />
                <xsl:attribute name="value" select="'erfüllt'" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="color" select="'#CC0000'" />
                <xsl:attribute name="value" select="'nicht erfüllt'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </data>
  </xsl:template>

  <!-- get macro value of given asset with the definition of given macroAsset -->
  <xsl:function name="csc:getCheckAssetResult">
    <xsl:param name="checkAsset" as="element(asset)"/>
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:variable name="xpathExpression" select="$checkAsset/asset_feature[@feature='censhare:completeness-check.expression.xpath']/@value_string"/>
    <xsl:choose>
      <!-- macro is defined by XPath expression -->
      <xsl:when test="$xpathExpression">
        <xsl:value-of select="$asset/cs:evaluate($xpathExpression)"/>
      </xsl:when>
      <!-- macro is defined by XSLT as master file -->
      <xsl:when test="$checkAsset/storage_item[@key='master']">
        <xsl:variable name="result">
          <cs:command name="com.censhare.api.transformation.XslTransformation">
           <cs:param name="stylesheet" select="$checkAsset/storage_item[@key='master'][1]"/>
           <cs:param name="source" select="$asset"/>
          </cs:command>
        </xsl:variable>
        <xsl:value-of select="$result"/>
      </xsl:when>
      <!-- XPath expression and XSLT do not exists -->
      <xsl:otherwise>
        <xsl:value-of select="'Definition (XPath or XSLT) does not exist'"/> <!-- add localization -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
