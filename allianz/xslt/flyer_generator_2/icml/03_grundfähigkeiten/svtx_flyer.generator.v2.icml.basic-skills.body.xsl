<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:func="http://ns.censhare.de/functions"
        xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.xml2icml/storage/master/file" />

  <xsl:param name="transform"/>
  <xsl:variable name="targetAssetId" select="$transform/@target-asset-id"/>
  <xsl:variable name="footnoteCount" select="$transform/@footnote-count"/>


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
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="bold" stylename="highlight"/>
    <map:entry element="sup" stylename="hochgestellt"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <xsl:template match="image">
    <xsl:call-template name="icml-image">
      <xsl:with-param name="asset-id" select="@id"/>
      <xsl:with-param name="image-width" select="func:mm2pt(18)" />
      <xsl:with-param name="image-height" select="func:mm2pt(18)" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="bold | sup">
    <xsl:call-template name="icml-inline"/>
  </xsl:template>

  <xsl:template match="table">
    <xsl:call-template name="icml-table">
      <xsl:with-param name="tablestyle-name" select="'TableStyle/$ID/[Basic Table]'"/>
      <xsl:with-param name="col-widths" select="(61.12204724416242, 231.56945058836203)"/>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="AutoGrow" select="'true'"/>
        <xsl:attribute name="TextTopInset" select="4"/>
        <xsl:attribute name="TextLeftInset" select="4"/>
        <xsl:attribute name="TextBottomInset" select="4"/>
        <xsl:attribute name="TextRightInset" select="4"/>
        <xsl:attribute name="ClipContentToTextCell" select="'false'"/>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:apply-templates select="row"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="row">
    <xsl:call-template name="icml-tablerow">
      <xsl:with-param name="min-height" select="@h"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="cell">
    <xsl:variable name="isFirstCell" select="position() eq 1" as="xs:boolean" />
    <xsl:variable name="isFirstRow" select="(count(ancestor::row/preceding-sibling::row) + 1) eq 1" as="xs:boolean"/>
    <xsl:variable name="colspan" select="if (@colspan != '') then @colspan else 1"/>
    <xsl:call-template name="icml-tablecell">
      <xsl:with-param name="col-span" select="$colspan"/>
      <xsl:with-param name="row-span" select="if (@rowspan != '') then @rowspan else 1"/>
      <xsl:with-param name="content">
        <xsl:apply-templates select="paragraph | image"/>
      </xsl:with-param>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="TextTopInset" select="0"/>
        <xsl:attribute name="TextLeftInset" select="0"/>
        <xsl:attribute name="LeftInset" select="0"/>
        <xsl:attribute name="TopInset" select="0"/>
        <xsl:attribute name="RightInset" select="0"/>
        <xsl:attribute name="BottomInset" select="if ($colspan=2) then 14.173228346456694 else if ($isFirstCell) then 0 else 14.173228346456694"/>
        <xsl:attribute name="CellType" select="'TextTypeCell'"/>
        <xsl:attribute name="BottomEdgeStrokePriority" select="1"/>
        <xsl:attribute name="TopEdgeStrokePriority" select="1"/>
        <xsl:attribute name="RightEdgeStrokePriority" select="1"/>
        <xsl:attribute name="LeftEdgeStrokePriority" select="1"/>
        <xsl:attribute name="ClipContentToCell" select="'false'"/>
        <xsl:attribute name="BottomEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="RightEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="TopEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="LeftEdgeStrokeColor" select="'Swatch/None'"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:variable name="basicSkills" select="$rootAsset/cs:child-rel()[@key='user.basic-skills.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
  <xsl:variable name="selectableProtection" select="$rootAsset/cs:child-rel()[@key='user.selectable-protection.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="tableContent" as="element(content)">
      <content>
        <table>
          <row h="11.338582677165356">
            <cell colspan="2"><paragraph><bold>Absicherung von Grundfähigkeiten:</bold> Hier nur als beispielhafte Auswahl aus vielen abgesicherten Grundfähigkeiten.</paragraph></cell>
          </row>
          <xsl:copy-of select="for $x in $basicSkills return svtx:buildRow($x)"/>
          <row h="11.338582677165356">
            <cell colspan="2">
              <paragraph><bold>Zuwählbarer Schutz:</bold> Individuelle Erweiterungsmöglichkeiten<sup>2</sup> nach Beruf und Bedarf (gegen Mehrbeitrag).</paragraph>
            </cell>
          </row>
          <xsl:copy-of select="for $x in $selectableProtection return svtx:buildRow($x)"/>
        </table>
      </content>
    </xsl:variable>
    <xsl:message><xsl:copy-of select="$tableContent"/></xsl:message>
    <!-- handle footnotes count for sups and merges them on same footnotes -->
    <xsl:apply-templates select="$tableContent" mode="sup"/>
  </xsl:variable>

  <xsl:function name="svtx:buildRow">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$asset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
    <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:variable name="paragraph" select="$contentXml/article/content/body/paragraph" as="element(paragraph)*"/>
    <xsl:variable name="imageRef" select="$contentXml/article/content/picture[1]/@xlink:href"/>
    <xsl:variable name="imageAssetId" select="substring-after($imageRef, 'censhare:///service/assets/asset/id/')" as="xs:string?"/>
    <xsl:if test="$paragraph">
      <row h="60.00000000000004">
        <cell colspan="1">
          <xsl:if test="$imageAssetId castable as xs:long">
            <image id="{$imageAssetId}"/>
          </xsl:if>
        </cell>
        <cell colspan="1"><xsl:apply-templates select="$paragraph" mode="custom"/></cell>
      </row>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:template match="paragraph" mode="custom">
    <xsl:copy><xsl:apply-templates mode="custom"/></xsl:copy>
  </xsl:template>

  <!-- -->
  <xsl:template match="footnote" mode="custom">
    <sup><xsl:apply-templates mode="custom"/></sup>
  </xsl:template>

  <!-- -->
  <xsl:template match="@*|node()" mode="sup">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="sup"/>
    </xsl:copy>
  </xsl:template>

  <!-- -->
  <xsl:template match="sup" mode="sup">
    <xsl:variable name="precedingRowSups" select="ancestor::row[1]/preceding-sibling::row//sup" as="element(sup)*"/>
    <xsl:variable name="currentRowSups" select="preceding-sibling::sup" as="element(sup)*"/>
    <xsl:variable name="footNoteParam" select="if ($footnoteCount castable as xs:long) then xs:long($footnoteCount) else 0" as="xs:long?"/>
    <xsl:variable name="allSups" as="element(sup)*">
      <xsl:for-each-group select="($precedingRowSups, $currentRowSups)" group-by="text()">
        <xsl:copy-of select="."/>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:variable name="current" select="." as="element(sup)?"/>
    <xsl:variable name="index" select="index-of($allSups, $current)" as="xs:long?"/>
    <xsl:variable name="indexFinal" select="if ($index) then $index else count($allSups) + 1"/>
    <xsl:copy><xsl:value-of select="$indexFinal + $footNoteParam"/><xsl:text> </xsl:text></xsl:copy>
  </xsl:template>

</xsl:stylesheet>
