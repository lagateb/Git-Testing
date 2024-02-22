<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" xmlns:svtx="http://www.savotex.com" exclude-result-prefixes="#all" version="2.0">

  <xsl:variable name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="force" select="false()" as="xs:boolean"/>

  <xsl:template match="/asset[starts-with(@type,'picture.')]">
    <!-- === new asset features === -->
    <xsl:variable name="newAssetFeatures" as="element(asset_feature)*">
      <!-- handle creator if not exist -->
      <xsl:call-template name="asset-creator"/>
      <!-- handle iptc if not exist -->
      <xsl:call-template name="asset-iptc-translation"/>
    </xsl:variable>
    <xsl:if test="$debug">
      <debug var="newAssetFeatures">
        <xsl:copy-of select="$newAssetFeatures"/>
      </debug>
    </xsl:if>
    <!-- === update asset === -->
    <xsl:if test="count($newAssetFeatures) gt 0">
      <xsl:variable name="updatedAssetXml" as="element(asset)">
        <asset>
          <xsl:copy-of select="@*"/>
          <xsl:copy-of select="node() except asset_feature[@feature=$newAssetFeatures/@feature]"/>
          <xsl:copy-of select="$newAssetFeatures"/>
        </asset>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$debug">
          <xsl:copy-of select="$updatedAssetXml"/>
        </xsl:when>
        <xsl:otherwise>
          <cs:command name="com.censhare.api.assetmanagement.Update">
            <cs:param name="source" select="$updatedAssetXml"/>
          </cs:command>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="asset-creator">
    <xsl:if test="not(exists(asset_feature[@feature='svtx:asset.creator'])) or $force=true()">
      <xsl:variable name="createdBy" select="@created_by" as="xs:long?"/>
      <xsl:variable name="party" select="cs:master-data('party')[@id=$createdBy]" as="element(party)?"/>
      <xsl:variable name="firstName" select="$party/@firstname" as="xs:string?"/>
      <xsl:variable name="name" select="$party/@name" as="xs:string?"/>
      <xsl:variable name="email" select="$party/@email" as="xs:string?"/>
      <xsl:if test="$firstName or $name or $email">
        <asset_feature feature="svtx:asset.creator">
          <xsl:if test="$firstName">
            <asset_feature feature="censhare:address.first-name" value_string="{$firstName}"/>
          </xsl:if>
          <xsl:if test="$name">
            <asset_feature feature="censhare:address.last-name" value_string="{$name}"/>
          </xsl:if>
          <xsl:if test="$email">
            <asset_feature feature="censhare:address.uri-mailto" value_string="{$email}"/>
          </xsl:if>
        </asset_feature>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="asset-iptc-translation">
    <xsl:variable name="altTextEn" select="asset_feature[@feature='svtx:alt-text' and @language='en']/@value_string"/>
    <xsl:variable name="altTextDe" select="asset_feature[@feature='svtx:alt-text' and @language='de']/@value_string"/>
    <xsl:variable name="iptcDescription" select="asset_feature[@feature='censhare:iptc']/asset_feature[@feature='censhare:iptc.content']/asset_feature[@feature='censhare:iptc.description']/@value_string"/>
    <xsl:if test="((not(exists($altTextEn)) or not(exists($altTextDe))) and exists($iptcDescription)) or $force=true()">
      <xsl:variable name="translatedIptc" select="svtx:translateText('en','de',$iptcDescription)"/>
      <!-- iptc feature -->
      <xsl:apply-templates select="asset_feature[@feature='censhare:iptc']" mode="iptc">
        <xsl:with-param name="description" select="$translatedIptc"/>
      </xsl:apply-templates>
      <asset_feature feature="svtx:alt-text" language="en" value_string="{$iptcDescription}"/>
      <asset_feature feature="svtx:alt-text" language="de" value_string="{$translatedIptc}"/>
    </xsl:if>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset_feature" mode="iptc">
    <xsl:param name="description"/>
    <asset_feature>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="iptc">
        <xsl:with-param name="description" select="$description"/>
      </xsl:apply-templates>
    </asset_feature>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset_feature[@feature=&apos;censhare:iptc.content&apos;]/asset_feature[@feature=&apos;censhare:iptc.description&apos;]" mode="iptc">
    <xsl:param name="description"/>
    <asset_feature>
      <xsl:attribute name="feature" select="&apos;censhare:iptc.description&apos;"/>
      <xsl:attribute name="value_string" select="$description"/>
    </asset_feature>
  </xsl:template>

  <!-- Auruf der svtx-Translate Funktion -->
  <xsl:function name="svtx:translateText" as="xs:string">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:param name="text"/>
    <xsl:variable name="translatedtext">
      <cs:command name="modules.com.savotex.translator.Translate.get">
        <cs:param name="to" select="$to"/>
        <cs:param name="write_to_buffer">true</cs:param>
        <cs:param name="only_buffer">false</cs:param>
        <cs:param name="text" select="$text"/>
      </cs:command>
    </xsl:variable>
    <xsl:copy-of select="$translatedtext"/>
  </xsl:function>

</xsl:stylesheet>