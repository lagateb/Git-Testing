<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="2.0"
                 xmlns:my="http://www.censhare.com/xml/3.0.0/xpath-functions/my"
                 xmlns:xlink="http://www.w3.org/1999/xlink"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:fo="http://www.w3.org/1999/XSL/Format"
                 xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 xmlns:html="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

  <xsl:param name="transform"/>
  <xsl:param name="has-overset"/>
    <xsl:param name="withPPTXInfo" select="false()" as="xs:boolean"/>

  <!-- page sizes -->
  <xsl:variable name="page-width">210mm</xsl:variable>
  <xsl:variable name="page-height">297mm</xsl:variable>
  <xsl:variable name="page-margin-top">17mm</xsl:variable>
  <xsl:variable name="page-margin-bottom">17mm</xsl:variable>
  <xsl:variable name="page-margin-left">15mm</xsl:variable>
  <xsl:variable name="page-margin-right">15mm</xsl:variable>
  <xsl:variable name="column-count">2</xsl:variable>
  <xsl:variable name="column-gap">4mm</xsl:variable>
  <!--  text-align: justify | start  -->
  <xsl:variable name="text-align">justify</xsl:variable>
  <!--  hyphenate: true | false  -->
  <xsl:variable name="hyphenate">true</xsl:variable>

  <!-- global -->
  <xsl:variable name="column_content_width" select="my:get_column_width()"/>

  <!-- attriute sets -->
  <xsl:attribute-set name="p">
    <xsl:attribute name="font-size">10.5pt</xsl:attribute>
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="space-after">1em</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="h1">
    <xsl:attribute name="font-size">18pt</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="h2">
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <!--<xsl:attribute name="space-before">0.83em</xsl:attribute>
    <xsl:attribute name="space-after">0.83em</xsl:attribute>-->
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="h2">
    <xsl:attribute name="font-size">12pt</xsl:attribute>
    <xsl:attribute name="space-before">0.83em</xsl:attribute>
    <xsl:attribute name="space-after">0.83em</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="img">
    <!--<xsl:attribute name="space-before">2em</xsl:attribute>-->
    <xsl:attribute name="relative-position">relative</xsl:attribute>
    <xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
    <xsl:attribute name="content-height">scale-down-to-fit</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
    <xsl:attribute name="border-color">#000000</xsl:attribute>
    <xsl:attribute name="width">
      <xsl:value-of select="concat($column_content_width,'mm')"/></xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="img-small">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="relative-position">relative</xsl:attribute>
    <xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
    <xsl:attribute name="content-height">scale-down-to-fit</xsl:attribute>
    <xsl:attribute name="width">
      <xsl:value-of select="concat($column_content_width div 2,'mm')"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="img-description">
    <xsl:attribute name="font-size">8pt</xsl:attribute>
    <xsl:attribute name="space-before">0.1em</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="list-item">
    <xsl:attribute name="font-size">10.5pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="inside-table">
    <!--  prevent unwanted inheritance  -->
    <xsl:attribute name="start-indent">1pt</xsl:attribute>
    <xsl:attribute name="end-indent">1pt</xsl:attribute>
    <xsl:attribute name="text-indent">1pt</xsl:attribute>
    <xsl:attribute name="last-line-end-indent">1pt</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>
    <xsl:attribute name="text-align-last">relative</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="table-and-caption">
    <xsl:attribute name="display-align">center</xsl:attribute>
  </xsl:attribute-set>
  <!-- TABLE-->
  <xsl:attribute-set name="table">
    <xsl:attribute name="width">100%</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="table-caption" use-attribute-sets="inside-table">
    <xsl:attribute name="text-align">center</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="table-column"/>
  <xsl:attribute-set name="thead" use-attribute-sets="inside-table"/>
  <xsl:attribute-set name="tfoot" use-attribute-sets="inside-table"/>
  <xsl:attribute-set name="tbody" use-attribute-sets="inside-table"/>
  <xsl:attribute-set name="tr">
    <xsl:attribute name="space-after">20pt</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="th">
    <xsl:attribute name="font-family">SourceSansPro-Bold</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="border">1px</xsl:attribute>
    <xsl:attribute name="padding">1px</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="td">
    <xsl:attribute name="border">1pt</xsl:attribute>
    <xsl:attribute name="border-color">#000000</xsl:attribute>
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-left-style">solid</xsl:attribute>
    <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="padding">1px</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="rectangle">
    <xsl:attribute name="border">1pt</xsl:attribute>
    <xsl:attribute name="border-color">#000000</xsl:attribute>
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-left-style">solid</xsl:attribute>
    <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
    <xsl:attribute name="border-top-style">solid</xsl:attribute>
    <xsl:attribute name="background-color">#FF0000</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="absolute-position">fixed</xsl:attribute>
    <xsl:attribute name="top">10mm</xsl:attribute>
    <xsl:attribute name="left">170mm</xsl:attribute>
    <xsl:attribute name="width">30mm</xsl:attribute>
    <xsl:attribute name="height">10mm</xsl:attribute>
  </xsl:attribute-set>

  <!-- root match here -->
  <xsl:template match="/">
    <fo:root>
      <xsl:apply-templates/>
      <!--<xsl:apply-templates select="doc(asset[1]/storage_item[@key='master']/@url)/article"/>-->
    </fo:root>
  </xsl:template>

  <!-- match templates -->
  <xsl:template match="*"/>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="article">
    <xsl:call-template name="make-master-layout-set"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="content">
    <fo:page-sequence master-reference="A4-portrait">
      <fo:flow flow-name="xsl-region-body">
        <xsl:if test="$has-overset eq true()">
          <fo:block-container xsl:use-attribute-sets="rectangle">
            <fo:block xsl:use-attribute-sets="p" padding-top="8pt" color="#FFFFFF">
              Textübersatz
            </fo:block>
          </fo:block-container>
        </xsl:if>
        <fo:block font-size="22pt" text-align="center" space-after="16pt" font-weight="bold">
          <xsl:text>Textinhalt ohne Medienbezug</xsl:text>
        </fo:block>
        <xsl:if test="$withPPTXInfo">
            <fo:block font-size="12pt" text-align="center" space-after="16pt" font-weight="bold">
                <xsl:text>Übersatz in PowerPoint kontrollieren!</xsl:text>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates/>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="headline">
    <fo:block xsl:use-attribute-sets="h1">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="subline">
    <fo:block xsl:use-attribute-sets="h2">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="item/headline">
    <fo:block xsl:use-attribute-sets="list-item">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="paragraph">
    <fo:block xsl:use-attribute-sets="p">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="footnote[text()]">
    <xsl:variable name="super" select="count(preceding::footnote) + 1" as="xs:long?"/>
    <fo:footnote>
      <fo:inline font-size="70%" vertical-align="super">
        <xsl:value-of select="$super"/>
      </fo:inline>
      <fo:footnote-body>
        <fo:list-block provisional-distance-between-starts="3mm">
          <fo:list-item>
            <fo:list-item-label>
              <fo:block>
                <fo:inline font-size="70%" vertical-align="super">
                  <xsl:value-of select="$super"/>
                </fo:inline>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body>
              <fo:block margin-left="3mm">
                <xsl:apply-templates/>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
      </fo:footnote-body>
    </fo:footnote>
  </xsl:template>

  <xsl:template match="content/footnote" priority="1">
    <fo:block xsl:use-attribute-sets="p">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="description[text()]">
    <fo:block xsl:use-attribute-sets="p">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="item/paragraph">
    <fo:block xsl:use-attribute-sets="list-item">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="item">
    <fo:list-item>
      <fo:list-item-label end-indent="label-end()">
        <fo:block>&#x2022;</fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <xsl:element name="fo:block">
          <xsl:apply-templates/>
        </xsl:element>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>

  <xsl:template match="bullet-list">
    <fo:block>
      <fo:list-block>
        <xsl:apply-templates/>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <xsl:template match="table">
    <fo:table xsl:use-attribute-sets="table">
      <xsl:for-each select="colspec/col">
        <fo:table-column xsl:use-attribute-sets="table-column"/>
      </xsl:for-each>
      <fo:table-body>
        <xsl:apply-templates select="row"/>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <xsl:template match="row">
    <fo:table-row xsl:use-attribute-sets="tr">
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="cell">
    <fo:table-cell xsl:use-attribute-sets="td">
      <xsl:apply-templates/>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="bold">
    <fo:inline font-weight="bold">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="italic">
    <fo:inline font-style="italic">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="picture | picture-q | picture-l">
    <xsl:if test="@xlink:href">
      <fo:block space-before="1em">
        <fo:external-graphic  xsl:use-attribute-sets="img">
          <xsl:attribute name="src">
            <xsl:text>url('</xsl:text><xsl:value-of select="concat(@xlink:href, '/storage/preview/file')"/><xsl:text>')</xsl:text>
          </xsl:attribute>
        </fo:external-graphic>
        <xsl:variable name="pictureId" select="tokenize(@xlink:href, '/')[last()]" as="xs:long?"/>
        <xsl:variable name="pictureAsset" select="if($pictureId) then cs:get-asset($pictureId) else ()"/>
        <xsl:variable name="iptcFeature" select="$pictureAsset/asset_feature[@feature='censhare:iptc']" as="element(asset_feature)?"/>
        <xsl:variable name="iptcContent" select="$iptcFeature/asset_feature[@feature='censhare:iptc.content']" as="element(asset_feature)?"/>
        <xsl:variable name="iptcDescription" select="$iptcContent/asset_feature[@feature='censhare:iptc.description']/@value_string" as="xs:string?"/>
        <xsl:if test="$iptcDescription">
          <fo:block xsl:use-attribute-sets="img-description">
            <xsl:text>(</xsl:text><xsl:value-of select="$iptcDescription"/><xsl:text>)</xsl:text>
          </fo:block>
        </xsl:if>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item/picture | item/picture-q | item/picture-l">
    <xsl:if test="@xlink:href">
      <fo:block>
        <fo:external-graphic  xsl:use-attribute-sets="img-small">
          <xsl:attribute name="src">
            <xsl:text>url('</xsl:text><xsl:value-of select="concat(@xlink:href, '/storage/preview/file')"/><xsl:text>')</xsl:text>
          </xsl:attribute>
        </fo:external-graphic>
        <xsl:variable name="pictureId" select="tokenize(@xlink:href, '/')[last()]" as="xs:long?"/>
        <xsl:variable name="pictureAsset" select="if($pictureId) then cs:get-asset($pictureId) else ()"/>
        <xsl:variable name="iptcFeature" select="$pictureAsset/asset_feature[@feature='censhare:iptc']" as="element(asset_feature)?"/>
        <xsl:variable name="iptcContent" select="$iptcFeature/asset_feature[@feature='censhare:iptc.content']" as="element(asset_feature)?"/>
        <xsl:variable name="iptcDescription" select="$iptcContent/asset_feature[@feature='censhare:iptc.description']/@value_string" as="xs:string?"/>
        <xsl:if test="$iptcDescription">
          <fo:block xsl:use-attribute-sets="img-description">
            <xsl:text>(</xsl:text><xsl:value-of select="$iptcDescription"/><xsl:text>)</xsl:text>
          </fo:block>
        </xsl:if>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-master-layout-set">
    <fo:layout-master-set>
      <fo:simple-page-master master-name="A4-portrait" page-height="{$page-height}" page-width="{$page-width}">
        <fo:region-body margin-top="{$page-margin-top}" margin-right="{$page-margin-right}" margin-bottom="{$page-margin-bottom}" margin-left="{$page-margin-left}"/>
        <!-- column-count="{$column-count}" column-gap="{$column-gap}"-->
      </fo:simple-page-master>
    </fo:layout-master-set>
  </xsl:template>

  <xsl:function name="my:get_value_as_number">
    <xsl:param name="input"/>
    <xsl:value-of select="number(substring-before($input, 'mm'))"/>
  </xsl:function>

  <xsl:function name="my:get_column_width">
    <xsl:value-of select="(my:get_value_as_number($page-width) - my:get_value_as_number($page-margin-left) - my:get_value_as_number($page-margin-right) - ($column-count * my:get_value_as_number($column-gap))) div $column-count"/>
  </xsl:function>

</xsl:stylesheet>
