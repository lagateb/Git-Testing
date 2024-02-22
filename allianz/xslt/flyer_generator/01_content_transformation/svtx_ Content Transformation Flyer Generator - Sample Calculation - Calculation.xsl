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
  <xsl:variable name="monthlyRent" select="$transform/@monthly-rent"/>
  <xsl:variable name="capitalPayment" select="$transform/@capital-payment"/>
  <xsl:variable name="netContribution" select="$transform/@net-contribution"/>
  <xsl:variable name="netContributionWithCapitalPayment" select="$transform/@net-contribution-with-capital-payment"/>
  <xsl:variable name="netContributionDifference" select="$transform/@net-contribution-difference"/>

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
    <map:entry element="paragraph" stylegroup="Rechenbeispiel" stylename="Rechenbeispiel_copy"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="gray" stylegroup="Copy/Grau" stylename="Copy_grau"/>
    <map:entry element="gray_bold" stylegroup="Copy/Grau" stylename="Copy_grau_Highlight"/>
    <map:entry element="orange_small_space" stylegroup="Copy/Orange" stylename="Copy_orange_kl.Abstand"/>
    <map:entry element="orange_bold" stylegroup="Copy/Orange" stylename="Copy_orange_highlight"/>
    <map:entry element="orange" stylegroup="Copy/Orange" stylename="Copy_orange"/>
    <map:entry element="superscript" stylegroup="Copy" stylename="Copy_hochgestellt"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph">
    <xsl:call-template name="icml-paragraph" />
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="gray | orange | orange_bold | superscript | gray_bold | orange_small_space">
    <xsl:call-template name="icml-inline" />
  </xsl:template>

  <!-- Content -->
  <xsl:variable name="content">
    <content>
      <paragraph>
        <orange><orange_bold>Monatliche Rente:<xsl:text>&#9;</xsl:text></orange_bold><xsl:value-of select="$monthlyRent"/></orange><xsl:text>&#xd;</xsl:text>
        <gray>Monatlicher Zahlbetrag*:<xsl:text>&#9;</xsl:text><xsl:value-of select="$netContribution"/></gray><xsl:text>&#xd;</xsl:text>
        <gray><orange_bold>plus Kapital bei<xsl:text>&#13;</xsl:text></orange_bold></gray>
        <orange_small_space>schwerer Krankheit<xsl:text>&#9;</xsl:text><orange><xsl:value-of select="$capitalPayment"/><xsl:text> </xsl:text></orange></orange_small_space>
        <gray>Monatlicher Zahlbetrag*:<xsl:text>&#9;</xsl:text><xsl:value-of select="$netContributionDifference"/><xsl:text> </xsl:text></gray>
        <gray_bold>Monatlicher Zahlbeitrag gesamt:<xsl:text>&#9;</xsl:text><xsl:value-of select="$netContributionWithCapitalPayment"/></gray_bold>
      </paragraph>
    </content>
  </xsl:variable>
</xsl:stylesheet>
