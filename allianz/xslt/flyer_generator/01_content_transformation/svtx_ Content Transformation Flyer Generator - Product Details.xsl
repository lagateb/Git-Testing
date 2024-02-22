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
  <xsl:variable name="placementPart" select="$transform/@placement-part"/> <!-- headline or body, is mandatory -->
  <!--<xsl:variable name="footNoteCount" select="if ($transform/@footnote-count and $transform/@footnote-count castable as xs:long) then $transform/@footnote-count else 0"/>-->

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
    <map:entry element="headline" stylegroup="Produktdetails" stylename="Produktdetails_Headline"/>
    <map:entry element="paragraph" stylegroup="Produktdetails" stylename="Produktdetails_Tabelle"/>
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

  <xsl:template match="table">
    <xsl:call-template name="icml-table">
      <xsl:with-param name="tablestyle-name" select="'TableStyle/$ID/[Basic Table]'"/>
      <xsl:with-param name="col-widths" select="(145.98425196850394, 372.755905511811)"/>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="AutoGrow" select="'true'"/>
        <xsl:attribute name="TextTopInset" select="5.669291338582678"/>
        <xsl:attribute name="TextLeftInset" select="4.251968503937008"/>
        <xsl:attribute name="TextBottomInset" select="5.669291338582678"/>
        <xsl:attribute name="TextRightInset" select="5.669291338582678"/>
        <xsl:attribute name="ClipContentToTextCell" select="'false'"/>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:apply-templates select="row"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="row">
    <xsl:call-template name="icml-tablerow"/>
  </xsl:template>

  <xsl:template match="cell">
    <xsl:variable name="isFirstCell" select="position() eq 1" as="xs:boolean" />
    <xsl:call-template name="icml-tablecell">
      <xsl:with-param name="col-span" select="if (@colspan != '') then @colspan else 1"/>
      <xsl:with-param name="row-span" select="if (@rowspan != '') then @rowspan else 1"/>
      <xsl:with-param name="content">
        <xsl:apply-templates select="paragraph"/>
      </xsl:with-param>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="TextTopInset" select="5.669291338582678"/>
        <xsl:attribute name="TextLeftInset" select="if ($isFirstCell) then 4.251968503937008 else 8.503937007874017"/>
        <xsl:attribute name="LeftInset" select="if ($isFirstCell) then 4.251968503937008 else 8.503937007874017"/>
        <xsl:attribute name="TopInset" select="5.669291338582678"/>
        <xsl:attribute name="RightInset" select="5.669291338582678"/>
        <xsl:attribute name="BottomInset" select="5.669291338582678"/>
        <xsl:attribute name="CellType" select="'TextTypeCell'"/>
        <xsl:attribute name="BottomEdgeStrokePriority" select="13"/>
        <xsl:attribute name="TopEdgeStrokePriority" select="13"/>
        <xsl:attribute name="RightEdgeStrokePriority" select="if ($isFirstCell) then 13 else 7"/>
        <xsl:attribute name="LeftEdgeStrokePriority" select="if ($isFirstCell) then 7 else 13"/>
        <xsl:attribute name="ClipContentToCell" select="'false'"/>
        <xsl:attribute name="BottomEdgeStrokeTint" select="100"/>
        <xsl:attribute name="TopEdgeStrokeTint" select="100"/>
        <xsl:attribute name="RightEdgeStrokeTint" select="100"/>
        <xsl:attribute name="LeftEdgeStrokeTint" select="100"/>
        <xsl:attribute name="VerticalJustification" select="'centerAlign'"/>
        <xsl:attribute name="BottomEdgeStrokeColor" select="'Color/Paper'"/>
        <xsl:attribute name="RightEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="TopEdgeStrokeColor" select="'Color/Paper'"/>
        <xsl:attribute name="LeftEdgeStrokeColor" select="'Color/Paper'"/>
        <xsl:attribute name="BottomEdgeStrokeWeight" select="0.75"/>
        <xsl:attribute name="VerticalJustification" select="'CenterAlign'"/>
        <xsl:attribute name="TopEdgeStrokeWeight" select="0.75"/>
        <xsl:attribute name="RightEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="LeftEdgeStrokeWeight" select="if ($isFirstCell) then 0 else 0.75"/>
      </xsl:with-param>
    </xsl:call-template>
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
          <xsl:apply-templates select="$contentXml/article/content/table[1]" mode="icml-body"/>
        </xsl:when>
      </xsl:choose>
    </content>
  </xsl:variable>

  <!-- headline, paragraph templates -->
  <xsl:template match="text()" mode="icml-headline">
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


  <xsl:template match="paragraph" mode="icml-body">
    <xsl:param name="isFirstCell"/>
    <xsl:copy>
      <paragraph_style>
        <xsl:choose>
          <xsl:when test="$isFirstCell">
            <bold>
              <xsl:apply-templates mode="icml-body"/>
            </bold>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="icml-body"/>
          </xsl:otherwise>
        </xsl:choose>
      </paragraph_style>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="cell" mode="icml-body">
    <xsl:if test="position() le 2">
      <xsl:copy>
        <xsl:apply-templates mode="icml-body">
          <xsl:with-param name="isFirstCell" select="position() eq 1"/>
        </xsl:apply-templates>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|node()" mode="icml-body">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="icml-body"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="footnote" mode="icml-body">
    <xsl:variable name="previousContentFootnotes" select="preceding::footnote//text()" as="xs:string*"/>
    <xsl:variable name="value" select="text()"/>
    <xsl:variable name="index" select="index-of($previousContentFootnotes, $value)[1]"/>
    <xsl:variable name="firstFollowingNode" select="following-sibling::node()[1]"/>
    <xsl:variable name="secondFollowingNode" select="following-sibling::node()[2]"/>
    <footnote_style><xsl:value-of select="if ($index) then $index else count(distinct-values($previousContentFootnotes)) + 1 "/>
      <xsl:if test="$firstFollowingNode[local-name()='footnote'] or (normalize-space($firstFollowingNode) = '' and $secondFollowingNode[local-name()='footnote'])">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </footnote_style>
  </xsl:template>


</xsl:stylesheet>
