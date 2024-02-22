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
    <!--<map:entry element="paragraph" stylename="Fallbeispiel_Headline"/>-->
    <map:entry element="cell_headline" stylename="Fallbeispiel_Headline"/>
    <map:entry element="cell_left" stylename="Fallbeispiel_Body"/>
    <map:entry element="cell_right" stylename="Fallbeispiel_Body_rechts"/>
  </xsl:variable>

  <!-- Character mappings -->
  <xsl:variable name="CSMapping">
    <map:entry element="ps" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau')}"/>
    <map:entry element="cell_headline_style" stylename="{svtx:getCSMappingStyle($rootAsset, 'Headline_Content_Blau')}"/>
    <map:entry element="cell_style" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau')}"/>
    <map:entry element="bold" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau_highlight')}"/>
    <map:entry element="sup" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau_hochgestellt')}"/>
    <map:entry element="sub" stylename="{svtx:getCSMappingStyle($rootAsset, 'Copy_grau_tiefgestellt')}"/>
  </xsl:variable>

  <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
  <!-- InDesign-Text-Struktur -->

  <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
  <xsl:template match="paragraph | cell_headline | cell_left | cell_right">
    <xsl:call-template name="icml-paragraph"/>
  </xsl:template>

  <xsl:template match="table">
    <!--<xsl:variable name="col-count" select="(max($rows/Row/Cell/func:tablecell-colindex(.)) +1, 0)[1]" as="xs:integer?"/>-->
    <xsl:variable name="colWidth" select="(142.44094488189, 93.14349902929345)" as="xs:double*"/>
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
    <xsl:variable name="isLastRow" select="not(exists(ancestor::row/following-sibling::row))" as="xs:boolean"/>
    <xsl:call-template name="icml-tablecell">
      <xsl:with-param name="col-span" select="if (@colspan != '') then @colspan else 1"/>
      <xsl:with-param name="row-span" select="if (@rowspan != '') then @rowspan else 1"/>
      <xsl:with-param name="content">
        <xsl:apply-templates select="paragraph | cell_headline | cell_left | cell_right | image"/>
      </xsl:with-param>
      <xsl:with-param name="add-attributes" as="attribute()*">
        <xsl:attribute name="TextTopInset" select="if ($isFirstRow) then 14.173228346456694 else 4.251968503937008"/>
        <xsl:attribute name="TextLeftInset" select="14.173228346456694"/>
        <xsl:attribute name="TextBottomInset" select="if ($isFirstRow) then 11.338582677165356 else if ($isLastRow) then (if (exists($callToActionLink)) then 14.173228346456694 else 19.84251968503937) else 4.251968503937008"/>
        <xsl:attribute name="TextRightInset" select="14.173228346456694"/>
        <xsl:attribute name="LeftInset" select="14.173228346456694"/>
        <xsl:attribute name="TopInset" select="if ($isFirstRow) then 14.173228346456694 else 4.251968503937008"/>
        <xsl:attribute name="RightInset" select="14.173228346456694"/>
        <xsl:attribute name="BottomInset" select="if ($isFirstRow) then 11.338582677165356 else if ($isLastRow) then (if (exists($callToActionLink)) then 14.173228346456694 else 19.84251968503937) else 4.251968503937008"/>
        <xsl:attribute name="CellType" select="'TextTypeCell'"/>
        <xsl:attribute name="BottomEdgeStrokePriority" select="241"/>
        <xsl:attribute name="TopEdgeStrokePriority" select="241"/>
        <xsl:attribute name="RightEdgeStrokePriority" select="241"/>
        <xsl:attribute name="LeftEdgeStrokePriority" select="241"/>
        <xsl:attribute name="ClipContentToCell" select="'false'"/>
        <xsl:attribute name="BottomEdgeStrokeTint" select="100"/>
        <xsl:attribute name="TopEdgeStrokeTint" select="100"/>
        <xsl:attribute name="FillColor" select="'Color/C=10 M=0 Y=4 K=0 (50%25)'"/>
        <xsl:attribute name="RightEdgeStrokeTint" select="100"/>
        <xsl:attribute name="LeftEdgeStrokeTint" select="100"/>
        <xsl:attribute name="VerticalJustification" select="if ($isFirstRow) then 'BottomAlign' else 'CenterAlign'"/>
        <xsl:attribute name="BottomEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="RightEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="TopEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="LeftEdgeStrokeColor" select="'Swatch/None'"/>
        <xsl:attribute name="BottomEdgeStrokeWeight" select="0.75"/>
        <xsl:attribute name="TopEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="RightEdgeStrokeWeight" select="0"/>
        <xsl:attribute name="LeftEdgeStrokeWeight" select="0"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
  <xsl:template match="bold | sup | sub | cell_style | cell_headline_style">
    <xsl:call-template name="icml-inline" />
  </xsl:template>

  <xsl:template match="image">
    <xsl:call-template name="icml-image">
      <xsl:with-param name="asset-id" select="@id"/>
      <xsl:with-param name="image-width" select="41.808"/>
      <xsl:with-param name="image-height" select="41.808"/>
      <xsl:with-param name="objectstyle-name" select="'[Einfacher Grafikrahmen]'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Fussnoten extrahieren $targetAssetId -->
  <xsl:variable name="groupedFootnotes">
    <xsl:copy-of select="svtx:groupedFootnotesFromLayout($targetAssetId)"/>
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
      <xsl:apply-templates select="$transformedContentXml/article/content/table" mode="icml-content"/>
    </content>
  </xsl:variable>



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

  <!-- -->
  <xsl:template match="row" mode="icml-content">
    <xsl:variable name="isFirstRow" select="not(exists(preceding-sibling::row[1]))" as="xs:boolean"/>
    <xsl:variable name="isLastRow" select="not(exists(following-sibling::row[1]))" as="xs:boolean"/>
    <xsl:variable name="firstCell" select="cell[1]" as="element(cell)?"/>
    <xsl:variable name="secondCell" select="cell[2]" as="element(cell)?"/>
    <!--<xsl:variable name="mergeCells" select="if ($isFirstRow) then true() else exists($firstCell/paragraph[@style= 'merge-cell-right'])"/>-->
    <xsl:variable name="mergeCells" select="exists($firstCell/paragraph[@style= 'merge-cell-right'])" as="xs:boolean"/>
    <xsl:if test="$isFirstRow">
      <xsl:copy>
        <cell colspan="2">
          <cell_headline>
            <cell_headline_style><xsl:value-of select="$masterStorageXml/article/content/headline"/></cell_headline_style>
          </cell_headline>
        </cell>
      </xsl:copy>
    </xsl:if>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$mergeCells">
          <cell colspan="2">
            <cell_left>
              <cell_style>
                <xsl:for-each select="($firstCell, $secondCell)">
                  <xsl:apply-templates select="paragraph/node()" mode="icml-content"/>
                  <xsl:if test="not(position() = last())">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </cell_style>
            </cell_left>
          </cell>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="($firstCell, $secondCell)">
            <cell>
              <xsl:element name="{if (position() = 1) then 'cell_left' else 'cell_right'}">
                <cell_style>
                  <xsl:apply-templates select="paragraph/node()" mode="icml-content"/>
                </cell_style>
              </xsl:element>
            </cell>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
    <!-- test if last row and create a new row with call to action -->
    <xsl:if test="$isLastRow">
      <xsl:if test="exists($callToActionLink/text()) and exists($callToActionLink/@url)">
        <row>
          <cell>
            <cell_left>
              <cell_style><xsl:apply-templates select="$callToActionLink" mode="icml-content"/><xsl:text> </xsl:text><xsl:value-of select="$callToActionLink/@url"/></cell_style>
            </cell_left>
          </cell>
          <cell>
            <cell_right>
              <!--<xsl:variable name="placeAsset" select="($rootAsset/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>-->
              <xsl:variable name="hashedUrl" select="cs:hash($callToActionLink/@url)" as="xs:string?"/>
              <xsl:variable name="existingQrCode" select="(cs:asset()[@censhare:asset.id_extern = $hashedUrl and @censhare:asset.type = 'picture.'])[1]" as="element(asset)?"/>
              <xsl:if test="$existingQrCode">
                <image id="{$existingQrCode/@id}"/>
              </xsl:if>
            </cell_right>
          </cell>
        </row>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
