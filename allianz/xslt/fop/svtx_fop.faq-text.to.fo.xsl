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
    Generiert die FAQ,s als XML Abstimmungdokuments als
    PDF-FO
    Eingabe ist ein FAQ-Artikel Textasset
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
        <xsl:attribute name="text-align">left</xsl:attribute>
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

    <xsl:template match="/asset[@type ='article.optional-module.faq.']">
        <xsl:message>=== Start fop.faq-text.to.fo</xsl:message>

        <xsl:variable name="asset" select="."/>
        <xsl:variable name="faqContent" select="svtx:generateFAQ($asset)"/>


        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4-portrait" page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body region-name="xsl-region-body" margin-bottom="2cm" margin-top="0cm"/>
                    <fo:region-before region-name="xsl-region-before"/>
                    <fo:region-after region-name="xsl-region-after"/>



                </fo:simple-page-master>
            </fo:layout-master-set>
            <xsl:message><xsl:copy-of select="$faqContent"/></xsl:message>
            <xsl:apply-templates select="$faqContent"/>

        </fo:root>


     </xsl:template>

     <xsl:function name="svtx:generateFAQ">
         <xsl:param name="article" as="element(asset)"/>
         <content name="{$article/@name}" >
             <body>
                 <bullet-list>
                     <xsl:for-each select="$article/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.*']">
                         <xsl:sort select="./@sorting"/>
                         <xsl:variable name="content" select="svtx:storage(.)"/>
                         <item>

                             <xsl:copy-of select="$content/article/content/strapline"/>
                             <xsl:copy-of select="$content/article/content/headline"/>
                             <question><xsl:copy-of select="$content/article/content/question/*"/></question>
                             <answer><xsl:copy-of select="$content/article/content/answer/*"/></answer>
                         </item>
                     </xsl:for-each>
                 </bullet-list>
             </body>
         </content>
     </xsl:function>

     <xsl:function name="svtx:storage">
         <xsl:param name="textasset" as="element(asset)"/>
         <xsl:variable name="contentXml">
             <xsl:variable name="masterStorage" select="$textasset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
             <xsl:variable name="xml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
             <xsl:if test="$xml">
                 <xsl:copy-of select="$xml"/>
             </xsl:if>
         </xsl:variable>
         <xsl:copy-of select="$contentXml"/>
     </xsl:function>

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



     <xsl:template match="ddddd">
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


    <xsl:param name="transform"/>

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
        <!--
        <xsl:attribute name="space-before">1em</xsl:attribute>
        <xsl:attribute name="space-after">1em</xsl:attribute>
        -->
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
        <xsl:attribute name="space-before">1em</xsl:attribute>
        <xsl:attribute name="relative-position">relative</xsl:attribute>
        <xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
        <xsl:attribute name="content-height">scale-down-to-fit</xsl:attribute>
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


    <!-- match templates -->
    <xsl:template match="*"/>

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="article">
        <xsl:call-template name="make-master-layout-set"/>
        <xsl:apply-templates  />
    </xsl:template>

    <xsl:template match="content">
        <fo:page-sequence master-reference="A4-portrait">
            <fo:static-content flow-name="xsl-region-after">
                <fo:block xsl:use-attribute-sets="ps" space-before="32pt">
                    <xsl:text>Dieses Dokument wurde automatisch generiert. Stand: </xsl:text><xsl:value-of select="format-date(current-date(),'[D01].[M01].[Y0001]')"/>
                </fo:block>
            </fo:static-content>

            <fo:flow flow-name="xsl-region-body">

                <fo:block font-size="22pt" text-align="center" space-after="16pt" font-weight="bold">
                    <xsl:text>Fragen und Antworten</xsl:text>
                </fo:block>

                <fo:block font-size="18pt" text-align="center" space-after="16pt" font-weight="bold">
                    <xsl:value-of select="@name"/>
                </fo:block>

                <xsl:apply-templates/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template match="body">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="headline">
        <fo:block font-weight="bold" margin-bottom="5mm">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="strapline">
        <fo:block >
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>



    <xsl:template match="subline">
        <fo:block xsl:use-attribute-sets="h2">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="item2/headline">
        <fo:block xsl:use-attribute-sets="list-item">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="question">
        <fo:block space-after="1em"  color="blue">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="paragraph">
        <fo:block xsl:use-attribute-sets="p">
        <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="answer">
        <xsl:apply-templates/>
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
        <fo:list-item margin-bottom="5mm">
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

    <xsl:template match="answer/bullet-list/item">
        <fo:list-item margin-bottom="2mm">
            <fo:list-item-label end-indent="label-end()">
                <fo:block>&#x2022;</fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="1.2cm">
                <xsl:element name="fo:block">
                    <xsl:apply-templates/>
                </xsl:element>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>



    <xsl:template match="answer/bullet-list">
        <fo:block margin-top="3mm">
            <fo:list-block>
                <xsl:apply-templates/>
            </fo:list-block>
        </fo:block>
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
            <fo:block>
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
