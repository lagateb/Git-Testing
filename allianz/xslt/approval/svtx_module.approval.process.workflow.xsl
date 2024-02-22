<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all">

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

    <xsl:variable name="debug" select="false()" as="xs:boolean"/>
    <xsl:variable name="debugLog" select="true()" as="xs:boolean"/>

    <xsl:variable name="ASSET_WF" select="10"/>
    <xsl:variable name="ASSET_WF_STEP" select="30"/>

    <xsl:variable name="ASSET_MODULE_WF" select="40"/>
    <xsl:variable name="ASSET_MODULE_WF_STEP" select="10"/>
    <xsl:variable name="ASSET_MODULE_WF_STEP_NEW" select="20"/>

    <xsl:variable name="ASSET_MEDIUM_WF" select="80"/>
    <xsl:variable name="ASSET_MEDIUM_WF_STEP" select="20"/>

    <xsl:template match="/asset[starts-with(@type, 'text.')]">

        <xsl:if test="$debugLog">
            <xsl:message>############################## Start Module Workflow Update Script ################################</xsl:message>
        </xsl:if>

        <!-- current asset-->
        <xsl:variable name="asset" select="." as="element(asset)"/>

        <xsl:if test="(($asset/@wf_id = $ASSET_WF) and ($asset/@wf_step = $ASSET_WF_STEP))">

            <!-- Alle Module, die nicht im Status "Module fertiggestellt" sind -->
            <xsl:variable name="allModules" select="$asset/cs:parent-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'article.*' and not(@censhare:asset.wf_id=$ASSET_MODULE_WF and @censhare:asset.wf_step=$ASSET_MODULE_WF_STEP_NEW)]" />

            <xsl:for-each select="$allModules">
                <xsl:copy-of select="svtx:checkModule(., $asset)" />
            </xsl:for-each>

            <!--
            Vorerst auf inaktiv gestellt die Layouts zu updated aufgrund eines fehlers im ticket : https://youtrack.savotex.com/issue/ORTCONTENT-366
            Die Transformation welche nach einem Content Updated getriggert wird und das layout updated, kümmert sich nun auch darum den WF Status zu ändern
            -->

            <!-- Alle Layouts, die nicht im Status "Module fertiggestellt" sind -->
            <!--<xsl:variable name="allLayouts" select="$asset/cs:parent-rel()[@key = 'actual.']/cs:asset()[@censhare:asset.type = 'layout.*' and not(@censhare:asset.wf_id=$ASSET_MEDIUM_WF and @censhare:asset.wf_step=$ASSET_MEDIUM_WF_STEP)]" />
            <xsl:for-each select="$allLayouts">
                <xsl:copy-of select="svtx:checkLayout(., $asset)" />
            </xsl:for-each>-->

        </xsl:if>

        <xsl:if test="$debugLog">
            <xsl:message>############################## End Module Workflow Update Script ##################################</xsl:message>
        </xsl:if>

    </xsl:template>


    <xsl:function name="svtx:checkModule">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="currentTextAsset" as="element(asset)"/>

        <!-- Alle Text-Assets -->
        <xsl:variable name="allTexts" select="$asset/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.*' and @censhare:asset.wf_id=$ASSET_WF and not(@censhare:asset.wf_step=$ASSET_WF_STEP) and not(@censhare:asset.id = $currentTextAsset/@id)]" />
        <!-- wenn keins gefunden wurde, dann wird der Update dew Workflows durch geführt -->
        <xsl:if test="not($allTexts)">
            <xsl:copy-of select="svtx:updateModule($asset, $ASSET_MODULE_WF, $ASSET_MODULE_WF_STEP_NEW)" />
        </xsl:if>
    </xsl:function>

    <xsl:function name="svtx:checkLayout">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="currentTextAsset" as="element(asset)"/>

        <!-- Alle Text-Assets -->
        <xsl:variable name="allTexts" select="$asset/cs:child-rel()[@key = 'actual.']/cs:asset()[@censhare:asset.type = 'text.*' and @censhare:asset.wf_id=$ASSET_WF and not(@censhare:asset.wf_step=$ASSET_WF_STEP) and not(@censhare:asset.id = $currentTextAsset/@id)]" />
        <!-- wenn keins gefunden wurde, dann wird der Update dew Workflows durch geführt -->
        <xsl:if test="not($allTexts)">
            <xsl:copy-of select="svtx:updateModule($asset, $ASSET_MEDIUM_WF, $ASSET_MEDIUM_WF_STEP)" />
        </xsl:if>
    </xsl:function>

    <xsl:function name="svtx:updateModule">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="WF_ID" as="xs:integer"/>
        <xsl:param name="WF_STEP" as="xs:integer"/>

        <!-- Update asset -->
        <xsl:variable name="checkedOutAsset" as="element(asset)?">
            <xsl:choose>
                <xsl:when test="$debug">
                    <xsl:copy-of select="$asset"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="svtx:checkOutAsset($asset)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="newAsset" as="element(asset)?">
            <asset wf_id="{$WF_ID}" wf_step="{$WF_STEP}">
                <xsl:copy-of select="$checkedOutAsset/@*[not(local-name() = ('wf_step', 'wf_id'))]"/>
                <xsl:copy-of select="$checkedOutAsset/node()"/>
            </asset>
        </xsl:variable>

        <xsl:variable name="checkedInAsset" as="element(asset)?">
            <xsl:choose>
                <xsl:when test="$debug">
                    <xsl:copy-of select="$newAsset"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="svtx:checkInAsset($newAsset)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <updated-modul><xsl:value-of select="$checkedInAsset/@id"/></updated-modul>

    </xsl:function>

    <!-- -->
    <xsl:function name="svtx:checkOutAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:if test="svtx:isCheckedOutAsset($asset)">
            <xsl:variable name="abortAsset" select="svtx:checkOutAbortAsset($asset)"/>
        </xsl:if>
        <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

    <!-- -->
    <xsl:function name="svtx:isCheckedOutAsset" as="xs:boolean">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:value-of select="if ($asset/@checked_out_date) then true() else false()"/>
    </xsl:function>

    <!-- -->
    <xsl:function name="svtx:checkOutAbortAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckOutAbort" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

    <!-- -->
    <xsl:function name="svtx:checkInAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

</xsl:stylesheet>
