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
    <map:entry element="paragraph" stylename="StärkenAllianz_Body"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="paragraph_style" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau')}"/>
    <map:entry element="bold" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau_Highlight')}"/>
    <map:entry element="sup" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau_hochgestellt')}"/>
      <map:entry element="sub" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau_tiefgestellt')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="paragraph_style | bold | sup | sub">
    <xsl:call-template name="icml-inline"/>
  </xsl:template>

    <!-- Fussnoten extrahieren -->
    <xsl:variable name="groupedFootnotes">
        <xsl:copy-of select="svtx:groupedFootnotesFromP2($targetAssetId)"/>
    </xsl:variable>

  <!-- Content -->
  <xsl:variable name="content">
      <xsl:variable name="transformedContentXml" select="svtx:getContentXMLWithMergedFootnotes($rootAsset)"/>
    <content>
      <xsl:apply-templates select="$transformedContentXml/article/content/body" mode="icml-content"/>
    </content>
  </xsl:variable>

  <xsl:template match="paragraph" mode="icml-content">
    <paragraph><paragraph_style><xsl:apply-templates mode="icml-content"/></paragraph_style></paragraph>
  </xsl:template>

    <xsl:template match="sup|sub" mode="icml-content">
        <xsl:copy>
            <xsl:apply-templates mode="icml-content"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="footnote" mode="icml-content" >
        <xsl:apply-templates mode="icml-content" select="svtx:getFootnoteNumber($groupedFootnotes,.)" />
        <xsl:if test="exists(following-sibling::node()[1][local-name()='footnote'])">
            <sup>,</sup>
        </xsl:if>
    </xsl:template>

  <xsl:template match="bold" mode="icml-content">
    <xsl:copy><xsl:apply-templates mode="icml-content"/></xsl:copy>
  </xsl:template>

</xsl:stylesheet>
