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
    <map:entry element="footnote" stylename="p_Fußnote"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="bold" stylename="highlight"/>
    <map:entry element="sup" stylename="hochgestellt"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="footnote">
    <xsl:call-template name="icml-paragraph" />
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="sup">
    <xsl:call-template name="icml-inline" />
  </xsl:template>

  <xsl:variable name="basicSkills" select="$rootAsset/cs:child-rel()[@key='user.basic-skills.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
  <xsl:variable name="selectableProtection" select="$rootAsset/cs:child-rel()[@key='user.selectable-protection.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="footnotes" as="element(footnote)*">
      <footnote>Nähere Informationen zu Leistungsvoraussetzungen etc. sind in den Versicherungsbedingungen enthalten. Ihr Vermittler berät Sie gern. </footnote>
      <!-- basic skills -->
      <xsl:apply-templates select="$basicSkills" mode="custom"/>
      <footnote>Erweiterung über zusätzliche Leistungsauslöser für die KSP-Rente und auch als zusätzliche Leistung (einmalige Kapitalzahlung bei schwerer Krankheit, Pflegerente bei Pflegebedürftigkeit). </footnote>
      <!-- additional skills  -->
      <xsl:apply-templates select="$selectableProtection" mode="custom"/>
      <!-- calc -->
      <footnote>Annahmen: Endalter 67, monatlicher Zahlbeitrag nach Verrechnung der Überschussanteile (Überschussanteile sind nur für das erste Versicherungsjahr garantiert und können sich in den Folgejahren ändern), Stand 01.01.2022. Die Beispielswerte dienen nur der Orientierung – sie sind unverbindlich und kein Angebot. </footnote>
      <footnote>Gesamtbeitrag für KSP-Rente (1.000 € mtl.) und jeweilige Zuwahl; zuwählbar ist Schutz einzeln oder in Kombination;  den jeweiligen Beitrag kann Ihnen auf Wunsch gern der Vermittler mitteilen.</footnote>
    </xsl:variable>
    <content>
      <footnote>
      <xsl:for-each-group select="$footnotes" group-by="text()">
        <sup><xsl:value-of select="position()"/></sup><xsl:value-of select="text()"/><xsl:text> </xsl:text>
      </xsl:for-each-group>
      </footnote>
    </content>
    <xsl:message>
      <content>
        <footnote>
          <xsl:for-each-group select="$footnotes" group-by="text()">
            <sup><xsl:value-of select="position()"/></sup><xsl:value-of select="text()"/><xsl:text> </xsl:text>
          </xsl:for-each-group>
        </footnote>
      </content>
    </xsl:message>
  </xsl:variable>

  <xsl:template match="asset" mode="custom">
    <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:copy-of select="$contentXml/$contentXml/article/content/body//footnote"/>
  </xsl:template>
</xsl:stylesheet>
