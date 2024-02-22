<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        xmlns:func="http://ns.censhare.de/functions"
        exclude-result-prefixes="xs map"
        version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.xml2icml/storage/master/file" />
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <xsl:variable name="targetAssetId" select="$transform/@target-asset-id"/>
  <xsl:variable name="maxCol" select="4" as="xs:long"/> <!-- max limit atm -->

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
    <map:entry element="paragraph" stylename="p_Tabelle"/>
    <map:entry element="bullet-list" stylename="p_Aufzählung"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="paragraph_style" stylename="{svtx:getCSMappingStyleCD21($rootAsset, '')}"/>
    <map:entry element="bold" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'highlight')}"/>
    <map:entry element="sup" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'hochgestellt')}"/>
    <map:entry element="sub" stylename="{svtx:getCSMappingStyleCD21($rootAsset, 'tiefgestellt')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph | bullet-list">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <xsl:template match="paragraph[ancestor::cell[@colspan gt 1]]">
    <xsl:call-template name="icml-paragraph">
      <xsl:with-param name="force-style-name" select="'p_Tabelle_zentriert'" as="xs:string?"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="table">

    <xsl:variable name="rows">
      <xsl:apply-templates select="row"/>
    </xsl:variable>

    <xsl:variable name="col-count" select="(max($rows/Row/Cell/func:tablecell-colindex(.)) +1, 0)[1]" as="xs:integer?"/>
    <xsl:variable name="colWidth" select="if ($col-count = 2)
                                            then ((145.98425196850394, 372.755905511811))
                                          else if ($col-count = 3)
                                            then (145.98425196850394, 186.37795275590554, 186.37795275590554)
                                          else
                                            (145.98425196850394, 124.25196850393702, 124.25196850393702, 124.25196850393702)" as="xs:double*"/>

    <xsl:call-template name="icml-table">
      <xsl:with-param name="tablestyle-name" select="'TableStyle/$ID/[Basic Table]'"/>
      <xsl:with-param name="col-widths" select="$colWidth"/>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="AutoGrow" select="'true'"/>
        <xsl:attribute name="TextTopInset" select="5.669291338582678"/>
        <xsl:attribute name="TextLeftInset" select="0"/>
        <xsl:attribute name="TextBottomInset" select="5.669291338582678"/>
        <xsl:attribute name="TextRightInset" select="5.669291338582678"/>
        <xsl:attribute name="ClipContentToTextCell" select="'false'"/>
        <xsl:attribute name="StrokeColor" select="'Color/C=0 M=0 Y=0 K=88'"/>
      </xsl:with-param>
      <xsl:with-param name="content" select="$rows"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="row">
    <xsl:call-template name="icml-tablerow"/>
  </xsl:template>

  <xsl:template match="cell">
    <xsl:variable name="currentCell" select="." as="element(cell)?"/>
    <xsl:variable name="isFirstCell" select="position() eq 1" as="xs:boolean" />
    <xsl:variable name="isFirstRow" select="(count(ancestor::row/preceding-sibling::row) + 1) eq 1" as="xs:boolean"/>
    <xsl:call-template name="icml-tablecell">
      <xsl:with-param name="col-span" select="if (@colspan != '') then @colspan else 1"/>
      <xsl:with-param name="row-span" select="if (@rowspan != '') then @rowspan else 1"/>
      <xsl:with-param name="content">
        <xsl:apply-templates select="paragraph"/>
      </xsl:with-param>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="TextTopInset" select="5.669291338582678"/>
        <xsl:attribute name="TextLeftInset" select="if ($isFirstCell) then 0 else 8.503937007874017"/>
        <xsl:attribute name="LeftInset" select="if ($isFirstCell) then 0 else 8.503937007874017"/>
        <xsl:attribute name="TopInset" select="5.669291338582678"/>
        <xsl:attribute name="RightInset" select="5.669291338582678"/>
        <xsl:attribute name="BottomInset" select="5.669291338582678"/>
        <xsl:attribute name="CellType" select="'TextTypeCell'"/>
        <xsl:attribute name="BottomEdgeStrokePriority" select="258"/>
        <xsl:attribute name="TopEdgeStrokePriority" select="258"/>
        <xsl:attribute name="RightEdgeStrokePriority" select="if ($isFirstCell) then 246 else 247"/>
        <xsl:attribute name="LeftEdgeStrokePriority" select="if ($isFirstCell) then 247 else 246"/>
        <xsl:attribute name="ClipContentToCell" select="'false'"/>
        <xsl:attribute name="BottomEdgeStrokeTint" select="50"/>
        <xsl:attribute name="TopEdgeStrokeTint" select="50"/>
        <xsl:attribute name="RightEdgeStrokeTint" select="if ($isFirstCell) then 100 else 25"/>
        <xsl:attribute name="LeftEdgeStrokeTint" select="if ($isFirstCell) then 25 else 100"/>
        <xsl:attribute name="VerticalJustification" select="'CenterAlign'"/>
        <xsl:attribute name="BottomEdgeStrokeColor" select="'Color/C=0 M=0 Y=0 K=88'"/>
        <xsl:attribute name="TopEdgeStrokeColor" select="'Color/C=0 M=0 Y=0 K=88'"/>
        <xsl:attribute name="BottomEdgeStrokeWeight" select="0.3"/>
        <xsl:attribute name="TopEdgeStrokeWeight" select="if ($isFirstRow and $isFirstCell and not($currentCell//text())) then 0 else 0.3"/>
        <xsl:attribute name="RightEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="LeftEdgeStrokeWeight" select="0"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="paragraph_style | bold | sup | sub">
    <xsl:call-template name="icml-inline" />
  </xsl:template>


  <!-- Fussnoten extrahieren -->
  <xsl:variable name="groupedFootnotes">
    <xsl:copy-of select="svtx:groupedFootnotesFromP2($targetAssetId)"/>
  </xsl:variable>

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="transformedContentXml" select="svtx:getContentXMLWithMergedFootnotes($rootAsset)"/>
    <content>
      <xsl:apply-templates select="$transformedContentXml/article/content/table" mode="icml-content"/>
    </content>
  </xsl:variable>

  <xsl:template match="text()" mode="icml-content" priority="2">
    <!-- clean from 2pager + pptx linebreaks -->
    <xsl:variable name="cleanerText" select="svtx:cleanForPSB(.)"/>
    <xsl:variable name="tokenized" select="tokenize($cleanerText, $TWO_PAGER_LINE_BREAK)"/>
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

  <xsl:template match="@*|node()" mode="icml-content">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="icml-content"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="bullet-list" mode="icml-content">
    <xsl:apply-templates select="item/paragraph" mode="icml-content"/>
  </xsl:template>

  <xsl:template match="sup" mode="icml-content">
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

  <xsl:template match="cell" mode="icml-content">
    <xsl:if test="not(preceding-sibling::cell[1]/*[@style='merge-cell-right']) and position() le $maxCol">
      <xsl:copy>
        <xsl:variable name="paragraphs">
          <xsl:apply-templates mode="icml-content"/>
          <xsl:if test="node()[@style='merge-cell-right']">
            <xsl:apply-templates select="following-sibling::cell[1]" mode="merge"/>
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="colCount" select="count($paragraphs/paragraph)"/>
        <xsl:attribute name="colspan" select="$colCount"/>
        <paragraph>
          <paragraph_style>
            <xsl:for-each select="$paragraphs/paragraph/paragraph_style">
              <xsl:copy-of select="node()"/>
              <xsl:if test="not(position()=last())">
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </paragraph_style>
        </paragraph>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="cell" mode="merge">
    <xsl:if test="count(preceding-sibling::cell) lt $maxCol">
      <xsl:apply-templates mode="icml-content"/>
      <xsl:if test="*[@style='merge-cell-right']">
        <xsl:apply-templates select="following-sibling::cell[1]" mode="merge"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="row" mode="icml-content">
    <xsl:copy>
      <xsl:apply-templates mode="icml-content"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="paragraph" mode="icml-content">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <paragraph_style>
        <xsl:apply-templates mode="icml-content"/>
      </paragraph_style>
    </xsl:copy>
  </xsl:template>



  <!-- einfach nur das link-element entfernen -->
  <xsl:template match="linkjp">
    <xsl:apply-templates/>
  </xsl:template>


</xsl:stylesheet>
