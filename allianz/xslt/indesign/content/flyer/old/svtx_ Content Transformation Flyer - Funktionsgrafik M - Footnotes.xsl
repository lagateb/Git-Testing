<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
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
        <map:entry element="footnotes" stylename="Fußnote_6pt"/>
    </xsl:variable>

    <!-- Character mappings -->
    <xsl:variable name="CSMapping">
        <map:entry element="footnotes_style" stylename="{svtx:getCSMappingStyle($rootAsset, 'Fußnote_grau')}"/>
        <map:entry element="footnotes_style_sup" stylename="{svtx:getCSMappingStyle($rootAsset, 'Fußnote_hochgestellt')}"/>
    </xsl:variable>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- InDesign-Text-Struktur -->

    <!-- Block-Elemente, bilden einen Absatz und bekommen ein Absatzformat aus dem Mapping -->
    <xsl:template match="footnotes">
        <xsl:call-template name="icml-paragraph" />
    </xsl:template>

    <!-- Inline-Elemente, können bei Bedarf Zeichenformat erhalten -->
    <xsl:template match="footnotes_style | footnotes_style_sup">
        <xsl:call-template name="icml-inline" />
    </xsl:template>

    <xsl:variable name="contentXml" >
        <xsl:copy-of select="svtx:getContentXml($rootAsset)"/>
    </xsl:variable>

    <!--- Alle Elemente die auf einer Page sind   -->
    <xsl:variable name="contentToUseXml" >
        <xsl:copy-of select="$contentXml/article/content/headline"/>
    </xsl:variable>

    <!-- Fussnoten extrahieren -->
    <xsl:variable name="groupedFootnotes">
        <xsl:copy-of select="svtx:groupedFootnotes($contentToUseXml)"/>
    </xsl:variable>


    <!-- Content -->
    <xsl:variable name="content">
        <content>
            <footnotes>
            <footnotes_style>
                <xsl:apply-templates select="$contentXml/article/content/footnote" mode="icml-content"/>
            </footnotes_style>
            </footnotes>
        </content>
    </xsl:variable>

    <xsl:template match="footnote" mode="icml-content">
        <xsl:apply-templates mode="icml-content"/>
        <!--
        <xsl:copy><xsl:value-of select="./@no"/>)<xsl:value-of select="normalize-space(text())"/></xsl:copy>
        -->
    </xsl:template>

</xsl:stylesheet>
