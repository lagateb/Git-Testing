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

  <xsl:variable name="article" select="($rootAsset/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>

  <!-- Paragraph mappings -->
  <xsl:variable name="PSMapping">
    <map:entry element="paragraph" stylename="p_Copytext"/>
    <map:entry element="headline" stylename="{if ($article/@type='article.solution-overview.') then 'H3_Abschnittsheadline' else 'H3_Tabelle'}"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="paragraph_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="headline_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="bold" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'highlight')}"/>
    <map:entry element="sup" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'hochgestellt')}"/>
    <map:entry element="sub" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'tiefgestellt')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph | headline ">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="paragraph_style | bold | headline_style | sup | sub">
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
    <xsl:variable name="headline" select="$transformedContentXml/article/content/calltoaction-link/text()" as="xs:string?"/>
    <xsl:variable name="url" select="$transformedContentXml/article/content/calltoaction-link/@url" as="xs:string?"/>
    <!-- only place it, if url and headline is available -->
    <content>
      <xsl:if test="$url and $headline">
        <xsl:apply-templates select="$transformedContentXml/article/content/calltoaction-link" mode="icml-content"/>
      </xsl:if>
    </content>
  </xsl:variable>

  <xsl:template match="calltoaction-link" mode="icml-content">
    <xsl:variable name="headline">
      <headline><xsl:copy-of select="node()"/></headline>
    </xsl:variable>
    <xsl:apply-templates select="$headline" mode="icml-content"/>
  </xsl:template>

  <xsl:template match="text()" mode="icml-content">
    <!-- clean from 2pager + pptx linebreaks -->
    <xsl:variable name="cleanerText" select="svtx:cleanForFlyer(.)"/>
    <xsl:variable name="tokenized" select="tokenize($cleanerText, $FLYER_LINE_BREAK)"/>
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

  <xsl:template match="headline" mode="icml-content">
    <xsl:copy>
      <headline_style>
        <xsl:apply-templates mode="icml-content"/>
      </headline_style>
    </xsl:copy>
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
