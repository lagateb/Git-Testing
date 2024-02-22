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
    <map:entry/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="headline | subline">
    <xsl:call-template name="icml-paragraph" />
  </xsl:template>

  <xsl:template match="break">
    <xsl:call-template name="icml-break" />
  </xsl:template>

  <!-- Content -->
  <xsl:variable name="content">
    <content>
      <subline>Grundfähigkeitsversicherung</subline>
      <headline>Für <xsl:value-of select="$rootAsset/@name"/>:<xsl:text>&#xd;</xsl:text>Allianz KörperSchutzPolice (KSP)</headline>
    </content>
  </xsl:variable>
</xsl:stylesheet>
