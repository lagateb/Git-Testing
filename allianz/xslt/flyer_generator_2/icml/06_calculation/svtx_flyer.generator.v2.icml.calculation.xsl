<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.xml2icml/storage/master/file" />
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>

  <xsl:variable name="targetAssetId" select="$transform/@target-asset-id"/>
  <xsl:variable name="age" select="$transform/@age" as="xs:string?"/>
  <xsl:variable name="prices" select="$transform/@prices" as="xs:string?"/>
  <xsl:variable name="footnote-count" select="$transform/@footnote-count" as="xs:string?"/>
  <xsl:variable name="footnote-count-number" select="if ($footnote-count castable as xs:long) then xs:long($footnote-count) else 0"/>

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
    <map:entry element="paragraph_right" stylename="p_Copytext_rechts"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="bold" stylename="highlight"/>
    <map:entry element="sup" stylename="hochgestellt"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph | paragraph_right">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <xsl:template match="bold | sup">
    <xsl:call-template name="icml-inline"/>
  </xsl:template>

  <xsl:template match="table">
    <xsl:call-template name="icml-table">
      <xsl:with-param name="tablestyle-name" select="'TableStyle/$ID/[Basic Table]'"/>
      <xsl:with-param name="col-widths" select="(148.6417322833969, 108.24897637811452)"/>
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
      <xsl:with-param name="min-height" select="@MinimumHeight"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="cell">
    <xsl:variable name="isFirstCell" select="position() eq 1" as="xs:boolean" />
    <xsl:variable name="isFirstRow" select="(count(ancestor::row/preceding-sibling::row) + 1) eq 1" as="xs:boolean"/>
    <xsl:variable name="rowCount" select="count(ancestor::row/preceding-sibling::row) + 1" as="xs:long?"/>
    <xsl:call-template name="icml-tablecell">
      <xsl:with-param name="col-span" select="if (@colspan != '') then @colspan else 1"/>
      <xsl:with-param name="row-span" select="if (@rowspan != '') then @rowspan else 1"/>
      <xsl:with-param name="content">
        <xsl:apply-templates select="paragraph | paragraph_right"/>
      </xsl:with-param>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:copy-of select="@*"/>
        <xsl:attribute name="FillColor" select="'Color/C=15 M=0 Y=5 K=0'"/>
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

  <!-- Content -->
  <xsl:variable name="content">
    <xsl:variable name="tokenizedPrices" select="tokenize($prices, ',')" as="xs:string*"/>
    <xsl:variable name="basicSkills" select="$rootAsset/cs:child-rel()[@key='user.basic-skills.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
    <xsl:variable name="selectableProtection" select="$rootAsset/cs:child-rel()[@key='user.selectable-protection.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
    <content>
      <table>
        <row MinimumHeight="11.338582677165356"><!-- 0-->
          <cell colspan="2" TextTopInset="5.669291338582678" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="14.173228346456694" TopInset="5.669291338582678" RightInset="46.77165354330709" BottomInset="0">
            <paragraph><bold>Beitragsbeispiel für</bold></paragraph>
          </cell>
        </row>
        <row MinimumHeight="12"><!-- 1-->
          <cell colspan="2" TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="14.173228346456694" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph><bold><xsl:value-of select="$rootAsset/@name"/></bold></paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!-- 2-->
          <cell colspan="2" TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="14.173228346456694" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph><bold><xsl:value-of select="$age"/> Jahre</bold></paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!-- 3 -->
          <cell TextTopInset="5.669291338582678" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="14.173228346456694" LeftInset="14.173228346456694" TopInset="5.669291338582678" RightInset="14.173228346456694" BottomInset="0">
            <paragraph><bold>Beispiele und Leistung</bold></paragraph>
          </cell>
          <cell TextTopInset="5.669291338582678" TextLeftInset="2.834645669291339" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="2.834645669291339" TopInset="5.669291338582678" RightInset="46.77165354330709" BottomInset="0">
            <paragraph_right><bold>Beitrag mtl.<sup><xsl:value-of select="$footnote-count"/></sup></bold></paragraph_right>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!-- 4-->
          <cell colspan="2" TextTopInset="5.669291338582678" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="14.173228346456694" LeftInset="14.173228346456694" TopInset="5.669291338582678" RightInset="14.173228346456694" BottomInset="0">
            <paragraph><bold>Beispiele ohne Zuwahl:</bold></paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!-- 5-->
          <cell colspan="2" TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="14.173228346456694" LeftInset="14.173228346456694" TopInset="0" RightInset="14.173228346456694" BottomInset="0">
            <paragraph>Absicherung Grundfähigkeiten</paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!-- 6 -->
          <cell TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="8.503937007874017" LeftInset="14.173228346456694" TopInset="0" RightInset="8.503937007874017" BottomInset="0">
            <paragraph>– <xsl:processing-instruction name="ACE">7</xsl:processing-instruction>mit 1.000 € mtl. KSP-Rente</paragraph>
          </cell>
          <cell TextTopInset="0" TextLeftInset="8.503937007874017" TextBottomInset="0" TextRightInset="46.77165354330709" ClipContentToTextCell="false" AppliedCellStyle="CellStyle/$ID/[None]" AppliedCellStylePriority="0" LeftInset="8.503937007874017" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph_right><xsl:value-of select="svtx:formatNumber($tokenizedPrices[1])"/> €</paragraph_right>
          </cell>
        </row>
        <row MinimumHeight="27.77996763719534"><!--7 -->
          <cell TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="8.503937007874017" LeftInset="14.173228346456694" TopInset="0" RightInset="8.503937007874017" BottomInset="0">
            <paragraph>– <xsl:processing-instruction name="ACE">7</xsl:processing-instruction>mit 2.000 € mtl. KSP-Rente</paragraph>
          </cell>
          <cell TextTopInset="0" TextLeftInset="2.834645669291339" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="2.834645669291339" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph_right><xsl:value-of select="svtx:formatNumber($tokenizedPrices[2])"/> €</paragraph_right>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!-- 8-->
          <cell colspan="2" TextTopInset="5.669291338582678" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="14.173228346456694" TopInset="5.669291338582678" RightInset="46.77165354330709" BottomInset="0" >
            <paragraph><bold>Beispiele mit Zuwahl:</bold></paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!--9-->
          <cell colspan="2" TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="14.173228346456694" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph>Absicherung Grundfähigkeiten</paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!--10-->
          <cell colspan="2" TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="14.173228346456694" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph>mit 1.000 € mtl. KSP-Rente</paragraph>
          </cell>
        </row>
        <row MinimumHeight="14.078740157862313"><!--11-->
          <cell colspan="2" TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="8.503937007874017" LeftInset="14.173228346456694" TopInset="0" RightInset="8.503937007874017" BottomInset="0">
            <paragraph><bold>plus Zuwahl</bold></paragraph>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!--12-->
          <cell TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="0" TextRightInset="8.503937007874017" LeftInset="14.173228346456694" TopInset="0" RightInset="8.503937007874017" BottomInset="0">
            <paragraph>– Krankschreibung (KS)</paragraph>
          </cell>
          <cell TextTopInset="0" TextLeftInset="8.503937007874017" TextBottomInset="0" TextRightInset="46.77165354330709" LeftInset="8.503937007874017" TopInset="0" RightInset="46.77165354330709" BottomInset="0">
            <paragraph_right><xsl:value-of select="svtx:formatNumber($tokenizedPrices[3])"/> €<sup><xsl:value-of select="$footnote-count-number + 1"/></sup></paragraph_right>
          </cell>
        </row>
        <row MinimumHeight="11.338582677165356"><!--13-->
          <cell TextTopInset="0" TextLeftInset="14.173228346456694" TextBottomInset="14.173228346456694" TextRightInset="8.503937007874017" LeftInset="14.173228346456694" TopInset="0" RightInset="8.503937007874017" BottomInset="14.173228346456694">
            <paragraph>– KS und Psyche</paragraph>
          </cell>
          <cell TextTopInset="0" TextLeftInset="8.503937007874017" TextBottomInset="14.173228346456694" TextRightInset="46.77165354330709" LeftInset="8.503937007874017" TopInset="0" RightInset="46.77165354330709" BottomInset="14.173228346456694">
            <paragraph_right><xsl:value-of select="svtx:formatNumber($tokenizedPrices[4])"/> €<sup><xsl:value-of select="$footnote-count-number + 1"/></sup></paragraph_right>
          </cell>
        </row>
      </table>
    </content>
  </xsl:variable>

</xsl:stylesheet>
