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
  <xsl:variable name="placementPart" select="$transform/@placement-part"/> <!-- headline or body, accompanying is mandatory -->
  <!--<xsl:variable name="footNoteCount" select="if ($transform/@footnote-count and $transform/@footnote-count castable as xs:long) then $transform/@footnote-count else 0"/>-->
  <xsl:variable name="preFootnotes" select="$transform/@pre-footnotes"/>

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
    <map:entry element="headline" stylegroup="Fleximodul" stylename="Fleximodul_Headline"/>
    <map:entry element="paragraph" stylegroup="Fleximodul" stylename="Fleximodul_Copy"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="headline_style" stylegroup="Head+Subline" stylename="Headline_Versal_orange"/>
    <map:entry element="paragraph_style" stylegroup="Copy/Schwarz" stylename="Copy_schwarz"/>
    <map:entry element="bold" stylegroup="Copy/Schwarz" stylename="Copy_schwarz_Highlight"/>
    <map:entry element="footnote_style" stylename="Fußnote_hochgestellt"/>
    <map:entry element="sup" stylegroup="Copy" stylename="Copy_schwarz_hochgestellt"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="headline | paragraph">
    <xsl:call-template name="icml-paragraph" />
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="headline_style | paragraph_style | bold | footnote_style | sup">
    <xsl:call-template name="icml-inline" />
  </xsl:template>

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="masterStorage" select="$rootAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <content>
      <xsl:choose>
        <xsl:when test="lower-case($placementPart) = 'headline'">
          <xsl:apply-templates select="$contentXml/article/content/headline[1]" mode="icml-headline"/>
        </xsl:when>
        <xsl:when test="lower-case($placementPart) = 'body'">
          <xsl:apply-templates select="$contentXml/article/content/body[1]" mode="icml-body"/>
        </xsl:when>
      </xsl:choose>
    </content>
  </xsl:variable>

  <!-- headline, paragraph templates -->
  <xsl:template match="text()" mode="icml-body icml-headline">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- headline templates -->
  <xsl:template match="headline" mode="icml-headline">
    <xsl:copy>
      <headline_style>
        <xsl:apply-templates mode="icml-headline"/>
      </headline_style>
    </xsl:copy>
  </xsl:template>

  <!-- body templates -->
  <xsl:template match="paragraph" mode="icml-body">
    <xsl:copy>
      <paragraph_style>
        <xsl:apply-templates mode="icml-body"/>
      </paragraph_style>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="bold" mode="icml-body">
    <xsl:copy>
      <xsl:apply-templates mode="icml-body"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sup" mode="icml-body">
    <xsl:copy>
      <xsl:apply-templates mode="icml-body"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="footnote" mode="icml-body">
    <!-- previous footnotes from placed texts, e.g. product description -->
    <xsl:variable name="previousPlacedContentFootnotes" select="tokenize($preFootnotes, 'savotex_footnote')" as="xs:string*"/>
    <!-- previous footnotes from this context-->
    <xsl:variable name="previousContentFootnotes" select="preceding::footnote//text()" as="xs:string*"/>
    <!-- merge footnotes together-->
    <xsl:variable name="footnotes" select="($previousPlacedContentFootnotes, $previousContentFootnotes)" as="xs:string*"/>
    <xsl:variable name="value" select="text()"/>
    <!-- take a look if current footnote value was already used before, if yes take the index of it -->
    <xsl:variable name="index" select="index-of($footnotes, $value)[1]"/>
    <xsl:variable name="firstFollowingNode" select="following-sibling::node()[1]"/>
    <xsl:variable name="secondFollowingNode" select="following-sibling::node()[2]"/>
    <footnote_style><xsl:value-of select="if ($index) then $index else count(distinct-values($footnotes)) + 1 "/>
      <xsl:if test="$firstFollowingNode[local-name()='footnote'] or (normalize-space($firstFollowingNode) = '' and $secondFollowingNode[local-name()='footnote'])">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </footnote_style>
  </xsl:template>

  <!-- TODO: implement -->
  <xsl:template match="bullet-list" mode="icml-body"/>

</xsl:stylesheet>
