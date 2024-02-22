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



    <xsl:template match="/asset[@type ='article.optional-module.faq.']">

        <xsl:message>====start svtx:fop.create.faq-pdf</xsl:message>
        <xsl:variable name="rootAsset" select="."  />
        <!--
        <xsl:variable name="foContent" select="svtx:call-transformation('svtx:fop.faq-text.to.fo', $rootAsset)" as="element(output)*"/>
        -->
        <xsl:variable name="pdfContent" select="svtx:fop-renderer('svtx:fop.faq-text.to.fo', $rootAsset, false(),false())" as="element(output)?"/>

        <xsl:message>==== pdfContent <xsl:copy-of select="$pdfContent"/></xsl:message>

        <xsl:message>=== pdfContent  <xsl:value-of select="$pdfContent/@href"/> </xsl:message>
        <!-- Fix for komisch -->

        <xsl:variable name="reloadAsset" select="cs:get-asset($rootAsset/@id)" as="element(asset)"/>
        <!-- UNVERSIONED -->
        <xsl:variable name="destFile" select="$pdfContent/@href"/>

        <xsl:variable name="testAsset">
            <asset>
                <xsl:copy-of select="$reloadAsset/@*"/>
                <xsl:copy-of select="$reloadAsset/node() except ($reloadAsset/storage_item[@key='abstimmungsdokument'],$reloadAsset/storage_item[@key='abstimmungsdokument_short'],$reloadAsset/asset_element[key='actual.'])"/>

                <storage_item key="abstimmungsdokument" corpus:asset-temp-file-url="{$destFile}" element_idx="0" mimetype="application/pdf"/>
            </asset>
        </xsl:variable>

        <xsl:if test="$destFile">

            <xsl:message>==== das hier  <xsl:copy-of select="$testAsset"/> </xsl:message>

            <xsl:variable name="updatedAsset" as="element(asset)?">
                <cs:command name="com.censhare.api.assetmanagement.Update">
                    <cs:param name="source">
                        <asset>
                            <xsl:copy-of select="$reloadAsset/@*"/>
                            <xsl:copy-of select="$reloadAsset/node() except ($reloadAsset/storage_item[@key='abstimmungsdokument'])"/>
                            <xsl:if test="not($reloadAsset/storage_item[@key='abstimmungsdokument'])">
                                <asset_element key="actual." idx="0"/>
                            </xsl:if>
                            <storage_item key="abstimmungsdokument" corpus:asset-temp-file-url="{$destFile}" element_idx="0" mimetype="application/pdf"/>
                        </asset>
                    </cs:param>
                </cs:command>
            </xsl:variable>
            <output href="{$updatedAsset/storage_item[@key='abstimmungsdokument']/@url}"/>
        </xsl:if>


        <!-- return result for other trafos -->


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







