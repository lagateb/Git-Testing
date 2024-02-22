<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:censhare="http://www.censhare.com"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        xmlns:my="http://www.censhare.com/my"
        exclude-result-prefixes="#all"
        version="2.0">

  <xsl:variable name="debug" select="false()"/>

  <xsl:template match="/asset">
    <xsl:variable name="si" select="storage_item[@key='xml-structure' and @mimetype='text/xml']" as="element(storage_item)?"/>
    <xsl:variable name="content" select="if ($si/@url) then doc($si/@url) else ()"/>
    <xsl:variable name="storageDataModel" as="element(dataModel)?">
      <xsl:apply-templates select="($content/dataModel/asset)[1]" mode="dataModel"/>
    </xsl:variable>
    <xsl:variable name="assetDataModel" as="element(dataModel)?">
      <xsl:apply-templates select="(.)[1]" mode="dataModel"/>
    </xsl:variable>
    <!-- return first result -->
    <result>
      <xsl:copy-of select="($storageDataModel, $assetDataModel)[1]"/>
      <isEqual censhare:_annotation.datatype="boolean"><xsl:value-of select="deep-equal($storageDataModel, $assetDataModel)"/> </isEqual>
      <assetModel>
        <xsl:copy-of select="$assetDataModel"/>
      </assetModel>
    </result>
  </xsl:template>

  <xsl:template match="asset" mode="dataModel">
    <dataModel type="{@type}">
      <name censhare:_annotation.datatype="string"><xsl:value-of select="@name"/></name>
      <date censhare:_annotation.datatype="string"><xsl:value-of select="svtx:cast2dateTime(asset_feature[@feature='svtx:guarantee-asset.date']/@value_timestamp)"/></date>
      <totalVolume censhare:_annotation.datatype="string"><xsl:value-of select="asset_feature[@feature='svtx:guarantee-asset.total-volume']/@value_string"/></totalVolume>
      <headline censhare:_annotation.datatype="string"><xsl:value-of select="asset_feature[@feature='svtx:guarantee-asset.headline']/@value_string"/></headline>
      <copy censhare:_annotation.datatype="string"><xsl:value-of select="asset_feature[@feature='svtx:guarantee-asset.copy']/@value_string"/></copy>
      <investments censhare:_annotation.arraygroup="true">
        <xsl:for-each select="asset_feature[@feature='svtx:capital-investment.investment-classes']">
          <investment>
            <xsl:variable name="name" select="asset_feature[@feature='svtx:capital-investment.name']/@value_string" as="xs:string?"/>
            <xsl:variable name="share" select="asset_feature[@feature='svtx:capital-investment.percentage']/@value_double" as="xs:double?"/>
            <xsl:variable name="desc" select="asset_feature[@feature='svtx:capital-investment.description']/@value_string" as="xs:string?"/>
            <xsl:variable name="color" select="asset_feature[@feature='svtx:capital-investment.color']/@value_string" as="xs:string?"/>
            <xsl:if test="$name">
              <name><xsl:value-of select="$name"/></name>
            </xsl:if>
            <xsl:if test="$share">
              <share><xsl:value-of select="cs:format-number($share)"/></share>
            </xsl:if>
            <xsl:if test="$desc">
              <description><xsl:value-of select="$desc"/></description>
            </xsl:if>
            <xsl:if test="$color">
              <color><xsl:value-of select="$color"/></color>
            </xsl:if>
          </investment>
        </xsl:for-each>
      </investments>

      <regions censhare:_annotation.arraygroup="true">
        <xsl:for-each select="asset_feature[@feature='svtx:capital-investment.regions']">
          <region>
            <xsl:variable name="name" select="asset_feature[@feature='svtx:capital-investment.name']/@value_string" as="xs:string?"/>
            <xsl:variable name="share" select="asset_feature[@feature='svtx:capital-investment.percentage']/@value_double" as="xs:double?"/>
            <xsl:variable name="color" select="asset_feature[@feature='svtx:capital-investment.color']/@value_string" as="xs:string?"/>
            <xsl:if test="$name">
              <name><xsl:value-of select="$name"/></name>
            </xsl:if>
            <xsl:if test="$share">
              <share><xsl:value-of select="cs:format-number($share)"/></share>
            </xsl:if>
            <xsl:if test="$color">
              <color><xsl:value-of select="$color"/></color>
            </xsl:if>
          </region>
        </xsl:for-each>
      </regions>

      <developments censhare:_annotation.arraygroup="true">
        <xsl:for-each select="asset_feature[@feature='svtx:capital-investment.development']">
          <development>
            <xsl:variable name="date" select="asset_feature[@feature='svtx:capital-investment.date']/@value_timestamp" as="xs:string?"/>
            <xsl:variable name="share" select="asset_feature[@feature='svtx:capital-investment.percentage']/@value_double" as="xs:double?"/>
            <xsl:if test="$date">
              <date><xsl:value-of select="svtx:cast2dateTime($date)"/></date>
            </xsl:if>
            <xsl:if test="$share">
              <share><xsl:value-of select="cs:format-number($share)"/></share>
            </xsl:if>
          </development>
        </xsl:for-each>
      </developments>
    </dataModel>
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
</xsl:stylesheet>
