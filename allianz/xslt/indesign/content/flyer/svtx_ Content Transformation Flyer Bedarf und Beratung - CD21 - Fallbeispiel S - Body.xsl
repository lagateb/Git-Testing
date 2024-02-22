<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:func="http://ns.censhare.de/functions"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.xml2icml/storage/master/file" />
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <xsl:variable name="targetAssetId" select="$transform/@target-asset-id"/>

  <!-- ### MODUL KEY FACTS JETZT ### -->

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
    <map:entry element="paragraph" stylename="p_Tabelle_Aufzählung"/>
    <map:entry element="cell_headline" stylename="H3_Tabelle"/>
    <map:entry element="cell" stylename="p_Tabelle_Aufzählung"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="paragraph_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="ps" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="cell_headline_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="cell_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="bold" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'highlight')}"/>
    <map:entry element="sup" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'hochgestellt')}"/>
    <map:entry element="sub" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'tiefgestellt')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph | cell_headline | cell_left | cell_right">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <xsl:template match="table">
    <!--<xsl:variable name="col-count" select="(max($rows/Row/Cell/func:tablecell-colindex(.)) +1, 0)[1]" as="xs:integer?"/>-->
    <xsl:variable name="colWidth" select="(291.96850393700794)" as="xs:double*"/>
    <xsl:call-template name="icml-table">
      <xsl:with-param name="tablestyle-name" select="'TableStyle/$ID/[Basic Table]'"/>
      <xsl:with-param name="col-widths" select="$colWidth"/>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="AutoGrow" select="'true'"/>
        <xsl:attribute name="TextTopInset" select="4"/>
        <xsl:attribute name="TextLeftInset" select="4"/>
        <xsl:attribute name="TextBottomInset" select="4"/>
        <xsl:attribute name="TextRightInset" select="4"/>
        <xsl:attribute name="ClipContentToTextCell" select="'false'"/>
        <xsl:attribute name="StrokeColor" select="'Color/C=35 M=4 Y=10 K=0'"/>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:apply-templates select="row"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="row">
    <xsl:call-template name="icml-tablerow"/>
  </xsl:template>

  <xsl:variable name="callToActionLink" as="element(calltoaction-link)?">
    <xsl:copy-of select="$masterStorageXml/article/content/calltoaction-link"/>
  </xsl:variable>

  <xsl:template match="cell">
    <xsl:variable name="currentCell" select="." as="element(cell)?"/>
    <xsl:variable name="isFirstCell" select="position() eq 1" as="xs:boolean" />
    <xsl:variable name="isFirstRow" select="(count(ancestor::row/preceding-sibling::row) + 1) eq 1" as="xs:boolean"/>
    <xsl:variable name="isSecondRow" select="(count(ancestor::row/preceding-sibling::row) + 1) eq 2" as="xs:boolean"/>
    <xsl:variable name="isLastRow" select="not(exists(ancestor::row/following-sibling::row))" as="xs:boolean"/>
    <xsl:call-template name="icml-tablecell">
      <xsl:with-param name="col-span" select="if (@colspan != '') then @colspan else 1"/>
      <xsl:with-param name="row-span" select="if (@rowspan != '') then @rowspan else 1"/>
      <xsl:with-param name="content">
        <xsl:apply-templates select="paragraph | cell_headline | cell_left | cell_right | image"/>
      </xsl:with-param>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="TextTopInset" select="if ($isFirstRow) then 14.173228346456694 else 4.251968503937008"/>
        <xsl:attribute name="TextLeftInset" select="32.59842519685039"/>
        <xsl:attribute name="TextBottomInset" select="if ($isFirstRow) then 11.338582677165356 else if ($isLastRow) then 14.173228346456694 else 4.251968503937008"/>
        <xsl:attribute name="TextRightInset" select="24.094488188976378"/>
        <xsl:attribute name="LeftInset" select="32.59842519685039"/>
        <xsl:attribute name="TopInset" select="if ($isFirstRow) then 14.173228346456694 else 4.251968503937008"/>
        <xsl:attribute name="RightInset" select="24.094488188976378"/>
        <xsl:attribute name="BottomInset" select="if ($isFirstRow) then 11.338582677165356 else if ($isLastRow) then 14.173228346456694 else 4.251968503937008"/>
        <xsl:attribute name="CellType" select="'TextTypeCell'"/>
        <xsl:attribute name="BottomEdgeStrokePriority" select="if ($isFirstRow or $isLastRow) then 241 else 163"/>
        <xsl:attribute name="TopEdgeStrokePriority" select="if ($isFirstRow) then 143 else if ($isLastRow or $isSecondRow) then 161 else 241"/>
        <xsl:attribute name="RightEdgeStrokePriority" select="if ($isFirstRow) then 145 else if ($isLastRow or $isSecondRow) then 241 else 163"/>
        <xsl:attribute name="LeftEdgeStrokePriority" select="if ($isFirstRow) then 141 else if ($isLastRow or $isSecondRow) then 241 else 163"/>
        <xsl:attribute name="ClipContentToCell" select="'false'"/>
        <xsl:attribute name="BottomEdgeStrokeTint" select="100"/>
        <xsl:attribute name="TopEdgeStrokeTint" select="if ($isFirstRow) then 25 else 100"/>
        <xsl:attribute name="RightEdgeStrokeTint" select="100"/>
        <xsl:attribute name="LeftEdgeStrokeTint" select="if ($isFirstRow) then 25 else 100"/>
        <xsl:attribute name="FillColor" select="'Color/C=15 M=0 Y=5 K=0'"/>
        <xsl:attribute name="RightEdgeStrokeColor" select="if ($isFirstRow) then 'Color/Black' else 'Swatch/None'"/>
        <xsl:attribute name="VerticalJustification" select="if ($isFirstRow) then 'BottomAlign' else 'CenterAlign'"/>
        <xsl:attribute name="BottomEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="TopEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="LeftEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="RightEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="LeftEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="BottomEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="TopEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="RightEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="LeftEdgeStrokeWeight" select="0"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="bold | sup | sub | cell_style | cell_headline_style | paragraph_style">
    <xsl:call-template name="icml-inline" />
  </xsl:template>


  <!-- Fussnoten extrahieren $targetAssetId -->
  <xsl:variable name="groupedFootnotes">
    <xsl:copy-of select="svtx:groupedFootnotesFromLayoutFlyerBuBKeyfactsWhatIs($targetAssetId)"/>
  </xsl:variable>

  <xsl:variable name="contentXml" >
    <xsl:copy-of select="svtx:getContentXml($rootAsset)"/>
  </xsl:variable>

  <!--- Alle Elemente die auf einer Page sind   -->
  <xsl:variable name="contentToUseXml" >
    <xsl:copy-of select="svtx:defaultContent($contentXml)" />
  </xsl:variable>

  <!-- xml data -->
  <xsl:variable name="masterStorageXml">
    <xsl:variable name="currentAsset" select="svtx:getCheckedOutAsset($rootAsset)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:copy-of select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
  </xsl:variable>

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="transformedContentXml" select="svtx:getMergedFootnotes($masterStorageXml)"/>
    <content>
      <table>
        <row>
          <cell colspan="2">
            <cell_headline>
              <cell_headline_style><xsl:value-of select="$masterStorageXml/article/content/headline"/></cell_headline_style>
            </cell_headline>
          </cell>
        </row>
        <xsl:for-each select="$transformedContentXml/article/content/body/bullet-list/item">
          <row>
            <cell>
              <xsl:apply-templates mode="icml-content"/>
            </cell>
          </row>
        </xsl:for-each>
      </table>
    </content>
  </xsl:variable>

  <xsl:template match="paragraph" mode="icml-content">
    <xsl:copy>
      <paragraph_style>
        <xsl:apply-templates mode="icml-content"/>
      </paragraph_style>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="footnote" mode="icml-content" >
    <xsl:apply-templates mode="icml-content" select="svtx:getFootnoteNumber($groupedFootnotes,.)" />
    <xsl:if test="exists(following-sibling::node()[1][local-name()='footnote'])">
      <sup>,</sup>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sup|bold|sub|sup" mode="icml-content">
    <xsl:copy>
      <xsl:apply-templates mode="icml-content"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="icml-content">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="icml-content"/>
    </xsl:copy>
  </xsl:template>

  <!-- einfach nur das link-element entfernen -->
  <xsl:template match="linkjp">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
