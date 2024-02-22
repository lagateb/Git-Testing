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
    <map:entry element="paragraph" stylename="p_Copytext"/>
    <map:entry element="bullet_list" stylename="p_Aufzählung"/>
    <!--map:entry element="paragraph" stylename="Copy_10pt"/>
    <map:entry element="bullet_list" stylename="Copy_10pt_Bullets"/-->
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="paragraph_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="bullet_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="bold" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'highlight')}"/>
    <map:entry element="sup" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'hochgestellt')}"/>
    <map:entry element="sub" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'tiefgestellt')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph | bullet_list ">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="paragraph_style | bold | bullet_style | sup | sub">
    <xsl:call-template name="icml-inline"/>
  </xsl:template>

  <xsl:template match="break">
    <xsl:call-template name="icml-break"/>
  </xsl:template>

  <!-- Fussnoten extrahieren -->
  <xsl:variable name="groupedFootnotes">
    <xsl:copy-of select="svtx:groupedFootnotesFromLayout($targetAssetId)"/>
  </xsl:variable>

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="currentAsset" select="svtx:getCheckedOutAsset($rootAsset)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
      <xsl:variable name="transformedContentXml" select="svtx:getMergedFootnotes($contentXml)"/>
    <content>
      <xsl:apply-templates select="$transformedContentXml/article/content/body" mode="icml-content"/>
    </content>
  </xsl:variable>

    <xsl:template match="footnote" mode="icml-content" >
        <xsl:apply-templates mode="icml-content" select="svtx:getFootnoteNumber($groupedFootnotes,.)" />
        <xsl:if test="exists(following-sibling::node()[1][local-name()='footnote'])">
            <sup>,</sup>
        </xsl:if>
    </xsl:template>

  <xsl:template match="paragraph" mode="icml-content">
    <xsl:copy>
      <paragraph_style>
        <xsl:apply-templates mode="icml-content"/>
      </paragraph_style>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="bullet-list" mode="icml-content">
    <bullet_list>
      <xsl:apply-templates select="item/paragraph" mode="icml-content"/>
    </bullet_list>
  </xsl:template>

  <xsl:template match="item/paragraph" mode="icml-content">
    <bullet_style><xsl:apply-templates mode="icml-content"/></bullet_style><xsl:if test="not(position() = last())"><break/></xsl:if>
  </xsl:template>


    <xsl:template match="sup|bold|sub" mode="icml-content">
        <xsl:copy>
            <xsl:apply-templates mode="icml-content"/>
        </xsl:copy>
    </xsl:template>

    <!-- einfach nur das link-element entfernen -->
    <xsl:template match="linkjp">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
