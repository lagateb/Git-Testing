<?xml version="1.0" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xe="http://www.censhare.com/xml/3.0.0/xmleditor"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:my="http://www.censhare.com">

    <!-- The XSLT creates a PDF of an Articles Main Content in the selected language to be displayed in the
         Artice or Content Editor -->

    <xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>

    <!-- parameter -->
    <xsl:param name="transform"/>
    <xsl:param name="version" select="asset[1]/@version"/>
    <xsl:param name="shortVersion" select="false()"/>

    <xsl:template match="/asset[starts-with(@type, 'text.') and $version &gt; 1]">
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <xsl:variable name="rootAsset" select="cs:get-asset(@id)" as="element(asset)?"/>
        <xsl:variable name="article" select="($rootAsset/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>
        <xsl:variable name="product" select="($article/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]" as="element(asset)?"/>
        <xsl:variable name="masterStorage" select="$rootAsset/storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="xmlContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="pptxSlide" select="($article/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.'])[1]" as="element(asset)?"/>
        <xsl:variable name="pptxPreview" select="exists($pptxSlide/storage_item[@key='preview'])" as="xs:boolean"/>

        <xsl:if test="$article and $xmlContent">
            <xsl:variable name="charCount" select="$rootAsset/parent_asset_element_rel/(@overset_charcount, @overset_linecount, @overset_wordcount)" as="xs:long*"/>
            <xsl:variable name="maxCharCount" select="if (exists($charCount)) then max($charCount) else 0" as="xs:long?"/>
            <xsl:variable name="textOverflows" select="$maxCharCount gt 0" as="xs:boolean"/>
            <!-- pdf pages -->
            <xsl:variable name="pdfCover" select="svtx:fop-renderer('svtx:fop.article.to.pdf', $rootAsset, (),false)" as="element(output)?"/>
            <xsl:variable name="pdfContent" select="svtx:fop-renderer('svtx:fop.text.to.pdf', $xmlContent, $textOverflows,$pptxPreview)" as="element(output)?"/>
            <xsl:variable name="pdfIndesign" select="svtx:call-transformation('svtx:fop.indesign.mark.text.boxes.and.create.pdf', $rootAsset)" as="element(output)*"/>
            <xsl:variable name="pdfPowerpoint" select="if ($pptxPreview) then svtx:fop-renderer('svtx:fop.preview.to.pdf', $pptxSlide, (),false) else ()" as="element(output)?"/>

            <!-- pdf pages combined -->
            <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>

            <xsl:variable name="dest" select="concat($out, 'temp-preview.pdf')"/>
            <cs:command name="com.censhare.api.pdf.CombinePDF" returning="combinedPdf">
                <cs:param name="dest" select="$dest"/>
                <cs:param name="sources">
                    <xsl:for-each select="($pdfCover, $pdfContent, $pdfIndesign, $pdfPowerpoint)[@href]">
                        <source href="{@href}"/>
                    </xsl:for-each>
                </cs:param>
            </cs:command>

            <!-- pdf pages combined without channels-->

            <xsl:variable name="destShort" select="concat($out, 'temp-preview-short.pdf')"/>
            <cs:command name="com.censhare.api.pdf.CombinePDF" returning="combinedPdf">
                <cs:param name="dest" select="$destShort"/>
                <cs:param name="sources">
                    <xsl:for-each select="($pdfCover, $pdfContent)[@href]">
                        <source href="{@href}"/>
                    </xsl:for-each>
                </cs:param>
            </cs:command>


            <!-- Fix for LIVE-System -->
            <xsl:variable name="textAsset" select="cs:get-asset(@id)" as="element(asset)?"/>

            <!-- UNVERSIONED -->
            <xsl:variable name="updatedAsset" as="element(asset)?">
                <cs:command name="com.censhare.api.assetmanagement.Update">
                    <cs:param name="source">
                        <asset>
                            <xsl:copy-of select="$textAsset/@*"/>
                            <xsl:copy-of select="$textAsset/node() except ($textAsset/storage_item[@key='abstimmungsdokument'],$textAsset/storage_item[@key='abstimmungsdokument_short'])"/>
                            <storage_item key="abstimmungsdokument" corpus:asset-temp-file-url="{$dest}" element_idx="0" mimetype="application/pdf"/>
                            <storage_item key="abstimmungsdokument_short" corpus:asset-temp-file-url="{$destShort}" element_idx="0" mimetype="application/pdf"/>
                        </asset>
                    </cs:param>
                </cs:command>
            </xsl:variable>

            <!--<xsl:if test="$product">
              <cs:command name="com.censhare.api.transformation.AssetTransformation">
                <cs:param name="key" select="'svtx:fop.product.collect.pdfs'"/>
                <cs:param name="source" select="$product"/>
              </cs:command>
            </xsl:if>-->

            <!-- return result for other trafos -->
            <xsl:if test="$shortVersion">
                <output href="{$updatedAsset/storage_item[@key='abstimmungsdokument_short']/@url}"/>
            </xsl:if>
            <xsl:if test="not($shortVersion)">
                <output href="{$updatedAsset/storage_item[@key='abstimmungsdokument']/@url}"/>
            </xsl:if>

        </xsl:if>
    </xsl:template>

    <xsl:function name="svtx:fop-renderer">
        <xsl:param name="resource-key"/>
        <xsl:param name="xml"/>
        <xsl:param name="has-overset"/>
        <xsl:param name="withPPTXInfo"/>

        <xsl:variable name="preUrl" select="'censhare:///service/assets/asset;censhare:resource-key='"/>
        <xsl:variable name="postUrl" select="'/storage/master/file'"/>
        <xsl:variable name="stylesheet" select="concat($preUrl, $resource-key, $postUrl)" as="xs:string"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="dest" select="concat($out, 'temp-preview.pdf')" as="xs:string?"/>
        <xsl:variable name="result" as="element(fop)?">
            <cs:command name="com.censhare.api.transformation.FopTransformation">
                <cs:param name="stylesheet" select="$stylesheet"/>
                <cs:param name="source" select="$xml"/>
                <cs:param name="dest" select="$dest"/>
                <cs:param name="xsl-parameters">
                    <cs:param name="has-overset" select="$has-overset"/>
                    <cs:param name="withPPTXInfo" select="$withPPTXInfo"/>
                </cs:param>
            </cs:command>
        </xsl:variable>
        <xsl:if test="$result">
            <output href="{$dest}">
                <xsl:copy-of select="$result/@*"/>
            </output>
        </xsl:if>
    </xsl:function>

    <xsl:function name="svtx:call-transformation">
        <xsl:param name="resource-key"/>
        <xsl:param name="xml"/>
        <xsl:variable name="result">
            <cs:command name="com.censhare.api.transformation.AssetTransformation">
                <cs:param name="key" select="$resource-key"/>
                <cs:param name="source" select="$xml"/>
            </cs:command>
        </xsl:variable>
        <xsl:if test="$result">
            <xsl:for-each select="$result/output">
                <output href="{@href}"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>







