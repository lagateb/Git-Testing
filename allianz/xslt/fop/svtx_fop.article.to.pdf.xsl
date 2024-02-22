<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet  version="2.0"
                 xmlns:my="http://www.censhare.com/xml/3.0.0/xpath-functions/my"
                 xmlns:xlink="http://www.w3.org/1999/xlink"
                 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 xmlns:xi="http://www.w3.org/2001/XInclude"
                 xmlns:fo="http://www.w3.org/1999/XSL/Format"
                 xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                 xmlns:svtx="http://www.savotex.com"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 xmlns:html="http://www.w3.org/1999/xhtml">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

<!--
Generiert die Startseite ein Abstimmungdokuments als
PDF-FO
Eingabe ist ein Textasset
-->

  <xsl:attribute-set name="h">
    <xsl:attribute name="font-size">30pt</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="ps">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="p">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="font-size">18pt</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="img">
    <xsl:attribute name="space-before">1em</xsl:attribute>
    <xsl:attribute name="relative-position">relative</xsl:attribute>
    <xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
    <xsl:attribute name="content-height">scale-down-to-fit</xsl:attribute>
    <xsl:attribute name="width">
      <xsl:value-of select="concat(50,'mm')"/>
    </xsl:attribute>
  </xsl:attribute-set>


  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="article" select="($rootAsset/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>
  <xsl:variable name="product" select="($article/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type='product.*'])[1]" as="element(asset)?"/>
  <xsl:variable name="marketingManager" select="($product/cs:child-rel()[@key='user.responsible.']/cs:asset()[@censhare:asset.type='person.'])[1]" as="element(asset)?"/>
  <xsl:variable name="logoAssetId" select="cs:asset-id()[@censhare:resource-key = 'svtx:fop.abstimmungsdokument.logo']" as="xs:long?"/>



  <xsl:template name="addRow">
      <xsl:param name="title"/>
      <xsl:param name="value"/>
      <fo:table-row  border-bottom="1pt solid grey">
          <fo:table-cell>
              <fo:block>
                  <xsl:value-of select="$title"/>
              </fo:block>
          </fo:table-cell>
          <fo:table-cell >
              <fo:block>
                  <xsl:value-of select="$value"/>
              </fo:block>
          </fo:table-cell>
      </fo:table-row>
  </xsl:template>

  <xsl:template match="/">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="A4-portrait" page-height="29.7cm" page-width="21.0cm" margin="2cm">
          <fo:region-body region-name="xsl-region-body" margin-bottom="2cm" margin-top="8cm"/>
          <fo:region-before region-name="xsl-region-before"/>
          <fo:region-after region-name="xsl-region-after"/>
        </fo:simple-page-master>
      </fo:layout-master-set>
        <!-- setzen der ID auf die wir uns im Inhaltsverzeichnis beziehen  können "{$rootAsset/@id}

        -->
      <fo:page-sequence master-reference="A4-portrait" id="{$rootAsset/@id}" >
        <fo:static-content flow-name="xsl-region-before">
          <xsl:if test="$logoAssetId">
            <fo:block text-align="left" margin-bottom="6em">
              <fo:external-graphic xsl:use-attribute-sets="img">
                <xsl:attribute name="src">
                  <xsl:text>url('</xsl:text><xsl:value-of select="concat('censhare:///service/assets/asset/id/', $logoAssetId, '/storage/preview/file')"/><xsl:text>')</xsl:text>
                </xsl:attribute>
              </fo:external-graphic>
            </fo:block>
          </xsl:if>

          <fo:block  xsl:use-attribute-sets="h" >Abstimmungsdokument</fo:block>
        </fo:static-content>
        <fo:static-content flow-name="xsl-region-after">
          <fo:block xsl:use-attribute-sets="ps" space-before="32pt">
            <xsl:text>Dieses Dokument wurde automatisch generiert. Stand: </xsl:text><xsl:value-of select="format-date(current-date(),'[D01].[M01].[Y0001]')"/>
          </fo:block>
        </fo:static-content>
        <fo:flow flow-name="xsl-region-body">
          <fo:block-container display-align="center">
              <fo:table>
                  <fo:table-column column-width="33%" />
                  <fo:table-column column-width="67%" />
                  <fo:table-body>

                      <xsl:if test="$product">
                      <xsl:call-template name="addRow">
                          <xsl:with-param name="title"><xsl:text>Produkt:</xsl:text></xsl:with-param>
                          <xsl:with-param name="value" select = "$product/@name" />
                      </xsl:call-template>
                      </xsl:if>
                      <xsl:if test="$article">
                      <xsl:call-template name="addRow">
                          <xsl:with-param name="title"><xsl:text>Modul:</xsl:text></xsl:with-param>
                          <xsl:with-param name="value" select = "cs:master-data('asset_typedef')[@asset_type=$article/@type]/@name" />
                      </xsl:call-template>
                      </xsl:if>
                      <xsl:call-template name="addRow">
                          <xsl:with-param name="title" select = "'Größe:'" />
                          <xsl:with-param name="value" select = "cs:master-data('asset_typedef')[@asset_type=$rootAsset/@type]/@name" />
                      </xsl:call-template>
                      <xsl:if test="$marketingManager">
                      <xsl:call-template name="addRow">
                          <xsl:with-param name="title" select = "'Marketing Manager:'" />
                          <xsl:with-param name="value" select = "$marketingManager/@name" />
                      </xsl:call-template>
                      </xsl:if>
                      <xsl:call-template name="addRow">
                          <xsl:with-param name="title" select = "'Content Hub ID:'" />
                          <xsl:with-param name="value" select = "$rootAsset/@id" />
                      </xsl:call-template>

                    </fo:table-body>
              </fo:table>
          </fo:block-container>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

</xsl:stylesheet>
