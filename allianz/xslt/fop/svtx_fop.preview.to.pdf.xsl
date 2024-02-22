<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="2.0"
                 xmlns:my="http://www.censhare.com/xml/3.0.0/xpath-functions/my"
                 xmlns:xlink="http://www.w3.org/1999/xlink"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:fo="http://www.w3.org/1999/XSL/Format"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                 xmlns:html="http://www.w3.org/1999/xhtml">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>


  <!-- erzeugt aus einer Preview (PPTX) ein PDF -->

  <xsl:param name="transform"/>
  <xsl:param name="preview-url"/>

  <!-- page sizes -->
  <xsl:variable name="page-width">297mm</xsl:variable>
  <xsl:variable name="page-height">210mm</xsl:variable>
  <xsl:variable name="page-margin-top">17mm</xsl:variable>
  <xsl:variable name="page-margin-bottom">160mm</xsl:variable>
  <xsl:variable name="page-margin-left">15mm</xsl:variable>
  <xsl:variable name="page-margin-right">15mm</xsl:variable>
  <xsl:variable name="column-count">1</xsl:variable>
  <xsl:variable name="column-gap">4mm</xsl:variable>
  <!--  text-align: justify | start  -->
  <xsl:variable name="text-align">justify</xsl:variable>
  <!--  hyphenate: true | false  -->
  <xsl:variable name="hyphenate">true</xsl:variable>

  <!-- global -->
  <xsl:variable name="column_content_width" select="my:get_column_width()"/>
  <xsl:attribute-set name="img">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="relative-position">relative</xsl:attribute>
    <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="scaling">uniform</xsl:attribute>
    <xsl:attribute name="width">80%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="previewStorage" select="$rootAsset/storage_item[@key='preview']" as="element(storage_item)?"/>
  <xsl:variable name="url" select="if ($preview-url) then $preview-url else $previewStorage/@url" as="xs:string?"/>
  <xsl:template match="/">
    <xsl:if test="$url">
      <fo:root>
        <xsl:call-template name="make-master-layout-set"/>
        <fo:page-sequence master-reference="A4-portrait">



          <fo:static-content flow-name="xsl-region-before">


              <fo:block-container absolute-position="fixed"  top="5mm" left="15mm" height="10mm" width="200mm" text-align="left">
                  <fo:block font-size="14pt" text-align="left" >Übersatz in PowerPoint kontrollieren!</fo:block>
              </fo:block-container>

            <fo:block font-size="18pt" text-align="center" font-weight="bold">
              <xsl:value-of select="$rootAsset/@name"/></fo:block>
          </fo:static-content>
          <fo:flow flow-name="xsl-region-body">
            <fo:block-container display-align="center">
              <fo:block text-align="center">
                <fo:external-graphic xsl:use-attribute-sets="img">
                  <xsl:attribute name="src">
                    <xsl:text>url('</xsl:text><xsl:value-of select="$url"/><xsl:text>')</xsl:text>
                  </xsl:attribute>
                </fo:external-graphic>
              </fo:block>

            </fo:block-container>

          </fo:flow>
        </fo:page-sequence>
      </fo:root>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-master-layout-set">
    <fo:layout-master-set>
      <fo:simple-page-master master-name="A4-portrait"  margin="2cm" page-height="{$page-height}" page-width="{$page-width}">
        <fo:region-body margin-top="{$page-margin-top}" margin-right="{$page-margin-right}" margin-bottom="{$page-margin-bottom}" margin-left="{$page-margin-left}"/>
        <fo:region-before region-name="xsl-region-before"/>
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
