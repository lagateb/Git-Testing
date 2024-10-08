<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.xml2icml/storage/master/file" />
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <xsl:variable name="targetAssetId" select="$transform/@target-asset-id"/>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- basic configuration          -->
  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- ressource-key of an XSLT which returns page-references of an issue asset (for crossreferences across layouts) -->
  <xsl:param name="transform-key-referencetargets" />
  <!-- use mapping ($PSMapping for paragraphs, $CSMapping for inline elements) as default -->
  <xsl:param name="default-use-mapping" select="true()" />
  <!-- don’t create auto styles for elements without matching mapping -->
  <xsl:param name="default-use-autostyle" select="false()" />
  <!-- only needed for auto styles -->
  <xsl:variable name="autostyle-path-strip">
    <map:entry />
  </xsl:variable>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

  <!-- RegExp replacements -->
  <xsl:variable name="Replacements">
    <map:entry />
  </xsl:variable>

  <!-- Paragraph mappings -->
  <xsl:variable name="PSMapping">
    <map:entry element="headline" stylename="H1_Titel"/>
    <map:entry element="subline" stylename="H2_Subline"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="headline_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="subline_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="headline | subline">
    <xsl:call-template name="icml-paragraph" />
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="headline_style | subline_style">
    <xsl:call-template name="icml-inline" />
  </xsl:template>

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="currentAsset" select="svtx:getCheckedOutAsset($rootAsset)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <content>
      <xsl:apply-templates select="$contentXml/article/content" mode="icml-content"/>
    </content>
  </xsl:variable>

  <xsl:template match="headline" mode="icml-content">
    <xsl:copy>
      <headline_style><xsl:apply-templates mode="icml-content"/></headline_style>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="subline" mode="icml-content">
    <xsl:copy>
      <subline_style><xsl:apply-templates mode="icml-content"/></subline_style>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="break">
    <xsl:call-template name="icml-break"/>
  </xsl:template>

  <!-- -->
  <xsl:template match="text()" mode="icml-content">
    <!-- clean from 2pager + pptx linebreaks -->
    <xsl:variable name="cleanerText" select="svtx:cleanForPSB(.)"/>
    <xsl:variable name="tokenized" select="tokenize($cleanerText, $TWO_PAGER_LINE_BREAK)"/>
    <xsl:for-each select="$tokenized">
      <xsl:variable name="nextIdx" select="position()+1"/>
      <xsl:choose>
        <xsl:when test="ends-with(., ' ') or starts-with($tokenized[$nextIdx], ' ')">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="if (position() ne last()) then replace(concat(normalize-space(.), '-'), '--', '-') else ."/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() ne last()">
        <xsl:text>&#xd;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- einfach nur das link-element entfernen -->
  <xsl:template match="link" mode="icml-content">
    <xsl:apply-templates mode="icml-content"/>
  </xsl:template>

</xsl:stylesheet>
