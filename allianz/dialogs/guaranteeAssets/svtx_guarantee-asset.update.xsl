<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        xmlns:my="http://www.censhare.com/my"
        exclude-result-prefixes="#all"
        version="2.0">

  <xsl:param name="name"/>
  <xsl:param name="date"/>
  <xsl:param name="total-volume"/>
  <xsl:param name="headline"/>
  <xsl:param name="copy"/>
  <xsl:param name="investments"/>
  <xsl:param name="regions"/>
  <xsl:param name="developments"/>
  <xsl:param name="update-asset"/>



  <xsl:template match="/asset">
    <xsl:variable name="arrSplit" select="tokenize($investments, ';')" as="xs:string*"/>
    <xsl:variable name="arrSplitRegions" select="tokenize($regions, ';')" as="xs:string*"/>
    <xsl:variable name="arrSplitDevelopments" select="tokenize($developments, ';')" as="xs:string*"/>
    <xsl:variable name="newAssetFeatures" as="element(asset_feature)*">
      <xsl:if test="$date and ($date castable as xs:dateTime or $date castable as xs:date)">
        <asset_feature feature="svtx:guarantee-asset.date" value_timestamp="{svtx:cast2dateTime($date)}"/>
      </xsl:if>
      <xsl:if test="$total-volume">
        <asset_feature feature="svtx:guarantee-asset.total-volume" value_string="{$total-volume}"/>
      </xsl:if>
      <xsl:if test="$headline">
        <asset_feature feature="svtx:guarantee-asset.headline" value_string="{$headline}"/>
      </xsl:if>
      <xsl:if test="$copy">
        <asset_feature feature="svtx:guarantee-asset.copy" value_string="{$copy}"/>
      </xsl:if>
      <xsl:for-each select="$arrSplit">
        <xsl:variable name="object" select="tokenize(., '\|')" as="xs:string*"/>
        <asset_feature feature="svtx:capital-investment.investment-classes">
          <xsl:if test="$object[1]">
            <asset_feature feature="svtx:capital-investment.name" value_string="{$object[1]}"/>
          </xsl:if>
          <xsl:if test="$object[2]">
            <asset_feature feature="svtx:capital-investment.percentage" value_double="{$object[2]}"/>
          </xsl:if>
          <xsl:if test="$object[3]">
            <asset_feature feature="svtx:capital-investment.description" value_string="{$object[3]}"/>
          </xsl:if>
          <xsl:if test="$object[4] and $object[4] != '#'">
            <xsl:variable name="hexColor" select="if ($object[4] castable as xs:integer) then concat('#',svtx:integerToHex(xs:integer($object[4]))) else $object[4]"/>
            <asset_feature feature="svtx:capital-investment.color" value_string="{$hexColor}"/>
          </xsl:if>
        </asset_feature>
      </xsl:for-each>

      <xsl:for-each select="$arrSplitRegions">
        <xsl:variable name="object" select="tokenize(., '\|')" as="xs:string*"/>
        <asset_feature feature="svtx:capital-investment.regions">
          <xsl:if test="$object[1]">
            <asset_feature feature="svtx:capital-investment.name" value_string="{$object[1]}"/>
          </xsl:if>
          <xsl:if test="$object[2]">
            <asset_feature feature="svtx:capital-investment.percentage" value_double="{$object[2]}"/>
          </xsl:if>
          <xsl:if test="$object[3]">
            <asset_feature feature="svtx:capital-investment.description" value_string="{$object[3]}"/>
          </xsl:if>
          <xsl:if test="$object[4] and $object[4] != '#'">
            <xsl:variable name="hexColor" select="if ($object[4] castable as xs:integer) then concat('#',svtx:integerToHex(xs:integer($object[4]))) else $object[4]"/>
            <asset_feature feature="svtx:capital-investment.color" value_string="{$hexColor}"/>
          </xsl:if>
        </asset_feature>
      </xsl:for-each>
      <xsl:for-each select="$arrSplitDevelopments">
        <xsl:variable name="object" select="tokenize(., '\|')" as="xs:string*"/>
        <asset_feature feature="svtx:capital-investment.development">
          <xsl:if test="($object[1] castable as xs:date or $object[1] castable as xs:dateTime)">
            <asset_feature feature="svtx:capital-investment.date" value_timestamp="{svtx:cast2dateTime($object[1])}"/>
          </xsl:if>
          <xsl:if test="$object[2]">
            <asset_feature feature="svtx:capital-investment.percentage" value_double="{$object[2]}"/>
          </xsl:if>
        </asset_feature>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="updatedAssetXml" as="element(asset)?">
      <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
      <xsl:variable name="filepath" select="concat($out, @id, 'temp.xml')"/>
      <cs:command name="com.censhare.api.io.WriteXML">
        <cs:param name="source">
          <dataModel>
            <asset name="{$name}" type="{@type}">
              <xsl:copy-of select="$newAssetFeatures"/>
            </asset>
          </dataModel>
        </cs:param>
        <cs:param name="dest" select="$filepath"/>
        <cs:param name="output">
          <output indent="yes"/>
        </cs:param>
      </cs:command>
      <xsl:choose>
        <xsl:when test="xs:boolean($update-asset) = true()">
          <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutAsset">
            <cs:param name="source" select="."/>
          </cs:command>
          <xsl:variable name="newAssetXml" as="element(asset)">
            <asset name="{ $name }">
              <xsl:copy-of select="$checkedOutAsset/@* except $checkedOutAsset/@name"/>
              <xsl:copy-of select="$checkedOutAsset/node() except $checkedOutAsset/(asset_feature[starts-with(@feature,'svtx:guarantee') or starts-with(@feature,'svtx:capital')], storage_item,asset_element)"/>
              <xsl:copy-of select="$newAssetFeatures"/>
              <asset_element key="actual." idx="0"/>
              <storage_item element_idx="0" key="xml-structure" mimetype="text/xml" corpus:asset-temp-file-url="{$filepath}"/>
            </asset>
          </xsl:variable>
          <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="checkedOutAsset">
            <cs:param name="source" select="$newAssetXml"/>
          </cs:command>
        </xsl:when>
        <xsl:otherwise>
          <cs:command name="com.censhare.api.assetmanagement.Update">
            <cs:param name="source">
              <asset>
                <xsl:copy-of select="@*"/>
                <xsl:copy-of select="node() except (storage_item, asset_element)"/>
                <asset_element key="actual." idx="0"/>
                <storage_item element_idx="0" key="xml-structure" mimetype="text/xml" corpus:asset-temp-file-url="{$filepath}"/>
              </asset>
            </cs:param>
          </cs:command>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  </xsl:template>

  <xsl:function name="svtx:cast2dateTime" as="xs:dateTime?">
    <xsl:param name="inputStr"/>
    <xsl:variable name="dateTime" as="xs:dateTime?">
      <xsl:choose>
        <xsl:when test="$inputStr castable as xs:date">
          <xsl:value-of select="xs:dateTime(xs:date($inputStr))"/>
        </xsl:when>
        <xsl:when test="$inputStr castable as xs:dateTime">
          <xsl:value-of select="xs:dateTime(xs:date(substring-before($inputStr,'T')))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="exists($dateTime)">
      <xsl:value-of select="format-dateTime($dateTime,'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="svtx:integerToHex" as="xs:string">
    <xsl:param name="in" as="xs:integer"/>
    <xsl:sequence select="if ($in eq 0) then '0' else concat(if ($in gt 16) then svtx:integerToHex($in idiv 16) else '', substring('0123456789ABCDEF', ($in mod 16) + 1, 1))"/>
  </xsl:function>
</xsl:stylesheet>
