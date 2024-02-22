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
  <xsl:variable name="footnotes" select="$transform/@footnotes"/> <!-- fußnote1, fußnote2, fußnoteX-->
  <xsl:variable name="staticFootnotes" select="$transform/@static-footnotes"/> <!-- fußnote1, fußnote2, fußnoteX-->

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
    <map:entry element="footnote" stylegroup="Vorteile" stylename="Vorteile_Fußnote"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="footnote_style_super" stylename="Fußnote_hochgestellt"/>
    <map:entry element="footnote_style" stylename="Fußnote_grau"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="footnote">
    <xsl:call-template name="icml-paragraph" />
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="footnote_style | footnote_style_super">
    <xsl:call-template name="icml-inline" />
  </xsl:template>


  <xsl:variable name="space">
    <xsl:text> </xsl:text>
  </xsl:variable>

  <!-- Content -->
  <xsl:variable name="content">
    <content>
      <footnote>
        <xsl:for-each select="tokenize($staticFootnotes, 'savotex_footnote')">
          <footnote_style_super><xsl:copy-of select="if (not(position() = 1)) then $space else ()"/><xsl:value-of select="'*'"/><xsl:copy-of select="$space"/></footnote_style_super><footnote_style><xsl:value-of select="."/></footnote_style>
        </xsl:for-each>
        <xsl:copy-of select="$space"/>
        <xsl:for-each select="distinct-values(tokenize($footnotes, 'savotex_footnote'))">
          <footnote_style_super><xsl:copy-of select="if (not(position() = 1)) then $space else ()"/><xsl:value-of select="position()"/><xsl:copy-of select="$space"/></footnote_style_super><footnote_style><xsl:value-of select="."/></footnote_style>
        </xsl:for-each>
      </footnote>
    </content>
  </xsl:variable>
</xsl:stylesheet>
