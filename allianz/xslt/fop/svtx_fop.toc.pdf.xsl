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
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:allianz.util.sorts/storage/master/file" />

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
    <xsl:param name="text-ids"  select="'28073,28079,28083'"/>
    <xsl:param name="document_type"  select="'abstimmungsdokument'"/>

    <!-- svtx:fop.toc.pdf
        erzeugt
      ein PDF-FOP Inhaltsverzeichnis der Abstimmunsdokumente mit Link zu den einzelnen
      Abstimmungsdokumenten
      <xsl:param name="text-ids"  select="'28073,28079,28083'"/>
    -->


    <xsl:attribute-set name="h">
        <xsl:attribute name="font-size">30pt</xsl:attribute>
        <xsl:attribute name="text-align">center</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="h2">
        <xsl:attribute name="font-size">25pt</xsl:attribute>
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



    <xsl:variable name="logoAssetId" select="cs:asset-id()[@censhare:resource-key = 'svtx:fop.abstimmungsdokument.logo']" as="xs:long?"/>


    <xsl:function name="svtx:sortValue">
        <xsl:param name="currentText"/>
        <xsl:variable name="article" select="($currentText/parent_asset_rel[@key='user.main-content.']/@parent_asset)/cs:asset()"/>
        <xsl:copy-of select="svtx:getSortValueForAsset($article)"/>

    </xsl:function>



    <xsl:template name="fopTOCAddRow" >
        <xsl:param name="modul"/>
        <xsl:param name="text"/>
        <xsl:param name="id"/>
        <xsl:param name="tocs"/>
        <fo:table-row >
            <fo:table-cell>
                <fo:block>
                    <text></text>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell  border-bottom="1pt solid grey" >
                <fo:block-container width="120mm" overflow="hidden" height="15pt">
                <fo:block font-size="12pt" >

                    <!---
                    <xsl:value-of select="concat(concat('$modul',' / '),$text)"/> -->
                    <xsl:value-of select="$text"/>
                    <!--
                    <fo:basic-link internal-destination="{$id}" color="blue">
                        <xsl:value-of select="$id" />
                    </fo:basic-link>
                    <fo:page-number-citation ref-id="{$id}" />
                    <fo:basic-link external-destination="http://www.data2type.de" text-decoration="underline" color="#0000FF">dsds</fo:basic-link>
                                        <xsl:text>  daslöäakdslaiods jkodsajkadsioadijs puiudsaiuasdiusdui uidsauiadsusu iuodasuio </xsl:text>
                    -->


                </fo:block>
                </fo:block-container>
            </fo:table-cell>
            <fo:table-cell  border-bottom="1pt solid grey" >
                <fo:block text-align="right">
                    <xsl:value-of select="format-number($tocs + 2,'##')"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell>
                <fo:block>
                    <text></text>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

    <xsl:template match="/">
        <xsl:message>====svtx:fop.toc.pdf: <xsl:value-of select="$text-ids"/> </xsl:message>
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4-portrait" page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="xsl-region-body" margin-bottom="2cm" margin-top="8cm"/>
                    <fo:region-before region-name="xsl-region-before"/>
                    <fo:region-after region-name="xsl-region-after"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="A4-portrait">
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
                    <fo:block  xsl:use-attribute-sets="h2" >Abstimmungsdokumente Inhaltsverzeichnis</fo:block>
                </fo:static-content>
                <fo:static-content flow-name="xsl-region-after">
                    <fo:block xsl:use-attribute-sets="ps" space-before="32pt">
                        <xsl:text>Dieses Dokument wurde automatisch generiert. Stand: </xsl:text><xsl:value-of select="format-date(current-date(),'[D01].[M01].[Y0001]')"/>
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block-container display-align="center">

                        <fo:table>
                            <fo:table-column column-width="10%" />
                            <fo:table-column column-width="70%" />
                            <fo:table-column column-width="10%" />
                            <fo:table-column column-width="10%" />
                            <fo:table-body>
                                <!--
                                <xsl:call-template name="fopTOCAddRow" >
                                    <xsl:with-param name="modul"><xsl:text>Produkt:</xsl:text></xsl:with-param>
                                    <xsl:with-param name="text" select = "'test me now'" />
                                    <xsl:with-param name="id" select = "'ohoh124'" />
                                </xsl:call-template>
                                -->

                                <xsl:variable name="pagecounts" as="element(pagecount)*">

                                    <xsl:for-each select="tokenize($text-ids, ',')/cs:asset()">
                                        <xsl:sort select="svtx:sortValue(.)"/>
                                        <xsl:variable name="cp" select="svtx:getPDFCountPages(.,$document_type)"/>
                                        <pagecount pos="{position()}"   count="{$cp}"><xsl:copy-of select="$cp"/></pagecount>
                                    </xsl:for-each>
                                </xsl:variable>


                                <xsl:for-each select="tokenize($text-ids, ',')/cs:asset()">
                                    <xsl:sort select="svtx:sortValue(.)"/>
                                    <xsl:variable name="currentAsset" select="."/>
                                    <xsl:variable name="cl" select="position()"/>
                                    <xsl:variable name="pc" select="sum($pagecounts[position() lt $cl]/@count)"/>
                                    <xsl:call-template name="fopTOCAddRow" >
                                        <xsl:with-param name="modul"><xsl:text>Produkt</xsl:text></xsl:with-param>
                                        <xsl:with-param name="text" select = "$currentAsset/@name" />
                                        <xsl:with-param name="id" select = "$currentAsset/@id" />
                                        <xsl:with-param name="tocs" select = "$pc" />
                                    </xsl:call-template>

                                </xsl:for-each>
                            </fo:table-body>
                        </fo:table>
                    </fo:block-container>

                </fo:flow>
            </fo:page-sequence>

        </fo:root>
    </xsl:template>

    <!-- holt sich die Seitenzahl des angehängten PDFs über PDFInfo -->


</xsl:stylesheet>
