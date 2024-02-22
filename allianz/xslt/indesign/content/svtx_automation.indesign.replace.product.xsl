<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

    <xsl:param name="censhare:command-xml"/>

    <!-- root match -->
    <xsl:template match="/asset[starts-with(@type, 'layout.')]">
        <xsl:message>==== svtx:automation.indesign.replace.product</xsl:message>
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <xsl:variable name="layoutAsset" select="cs:get-asset(@id)" as="element(asset)"/>
        <xsl:variable name="targetGroup" select="asset_feature[@feature='censhare:target-group'][1]/@value_asset_id" as="xs:long?"/>
        <xsl:variable name="product" as="element(asset)?">
            <xsl:choose>
                <xsl:when test="$targetGroup">
                    <xsl:copy-of select="(cs:parent-rel()[@key='variant.*']/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="(cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="articleAssets" as="element(asset)*">
            <xsl:for-each select="($product/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']/.[not(exists(asset_feature[@feature='svtx:optional-component' and @value_long = 1]))])">
                <xsl:variable name="targetGroupVariant" select="if ($targetGroup) then (cs:child-rel()[@key='variant.*']/cs:asset()[@censhare:asset.type='article.*' and @censhare:target-group = $targetGroup])[1] else ()" as="element(asset)?"/>
                <xsl:copy-of select="if ($targetGroupVariant) then $targetGroupVariant else ."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="originLayoutKey" as="xs:string?">
            <xsl:choose>
                <xsl:when test="exists($layoutAsset/asset_feature[@feature = 'svtx:layout-template-resource-key'])">
                    <xsl:value-of select="$layoutAsset/asset_feature[@feature = 'svtx:layout-template-resource-key']/@value_asset_key_ref"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- fallback -->
                    <xsl:value-of select="($layoutAsset/cs:feature-ref-reverse()[@key='svtx:layout-template'])[1]/asset_feature[@feature='censhare:resource-key']/@value_string"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- commands to place article into layout groups -->
        <xsl:variable name="placementCommands">
            <xsl:apply-templates select="$articleAssets" mode="place-cmd">
                <xsl:with-param name="key" select="$originLayoutKey"/>
            </xsl:apply-templates>
        </xsl:variable>

        <!-- commands to edit placed pictures by crop keys -->
        <xsl:variable name="editCommands">
            <xsl:apply-templates select="$articleAssets" mode="edit-cmd">
                <xsl:with-param name="layout" select="$layoutAsset"/>
            </xsl:apply-templates>
        </xsl:variable>

        <!--<xsl:variable name="checkedOutLayout" select="svtx:checkOutAsset($layoutAsset)" as="element(asset)?"/>-->
        <!-- start asset placement renderer -->
        <xsl:variable name="indesignStorageItem" select="$layoutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
        <xsl:if test="$indesignStorageItem">
            <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)" as="xs:string"/>
            <xsl:variable name="strengthAsset"  select="svtx:getMainContent($layoutAsset, $articleAssets[@type='article.staerken.'][1])"/>
            <xsl:variable name="fallbeispielContent" select="svtx:getMainContent($layoutAsset, $articleAssets[@type='article.fallbeispiel.'][1])"/>
            <xsl:variable name="callToAction" select="$fallbeispielContent//calltoaction-link[1]"/>
            <xsl:variable name="qrCodeAsset" select="if ($callToAction/@url != '') then svtx:createOrGetQRAsset($callToAction/@url) else ()"/>
            <xsl:variable name="showHideRenderCommand" select="svtx:hideShowStrengthPictureRenderCommand($strengthAsset)"/>
            <xsl:variable name="flexiModuleAsset" select="$articleAssets[starts-with(@type, 'article.flexi-module.')][1]" as="element(asset)?"/>
            <xsl:variable name="solutionOverview" select="$articleAssets[starts-with(@type, 'article.solution-overview.')][1]" as="element(asset)?"/>
            <xsl:variable name="renderResult">
                <cs:command name="com.censhare.api.Renderer.Render">
                    <cs:param name="facility" select="$appVersion"/>
                    <cs:param name="instructions">
                        <cmd>
                            <renderer>
                                <command method="open" asset_id="{ $layoutAsset/@id }" document_ref_id="1"/>
                                <command document_ref_id="1" method="correct-document"/>
                                <command document_ref_id="1" method="update-asset-element-structure"/>
                                <!-- show the right layer(s) for "Stärken" -->
                                <xsl:if test="$showHideRenderCommand/command[@method='script' and @script_asset_id castable as xs:long]">
                                    <xsl:copy-of select="$showHideRenderCommand"/>
                                </xsl:if>

                                <!-- place article -->
                                <xsl:copy-of select="$placementCommands"/>
                                <!-- edit picture crops -->
                                <xsl:copy-of select="$editCommands"/>

                                <xsl:if test="not($flexiModuleAsset)">
                                    <command method="delete-boxes" document_ref_id="1">
                                        <xsl:for-each select="svtx:getAssetElements($layoutAsset, 'flyerSnippet')">
                                            <box uid="{@id_extern}"/>
                                        </xsl:for-each>
                                    </command>
                                </xsl:if>

                                <xsl:if test="$flexiModuleAsset and $originLayoutKey = 'svtx:indd.template.bedarf_und_beratung.flyer.allianz'">
                                    <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key='svtx:indesign.create-qr-code']" as="xs:long?"/>
                                    <xsl:variable name="url" select="svtx:getURLofMainContent($flexiModuleAsset)" as="xs:string?"/>
                                    <xsl:if test="$url and $scriptId">
                                        <command document_ref_id="1" method="script" script_asset_id="{$scriptId}">
                                            <param name="url" value="{$url}"/>
                                        </command>
                                    </xsl:if>
                                </xsl:if>

                                <!-- Lösungsübersicht -->
                                <xsl:if test="$solutionOverview and $originLayoutKey = 'svtx:indd.template.bedarf_und_beratung.flyer.allianz'">
                                    <xsl:copy-of select="svtx:qrCodeSolutionOverviewCmd($solutionOverview)"/>
                                </xsl:if>

                                <command document_ref_id="1" scale="1.0" method="preview"/>
                                <command method="save" document_ref_id="1"/>
                                <command method="close" document_ref_id="1"/>
                            </renderer>
                            <assets>
                                <xsl:copy-of select="$layoutAsset"/>
                                <xsl:copy-of select="$articleAssets"/>
                                <xsl:copy-of select="$qrCodeAsset"/>
                            </assets>
                        </cmd>
                    </cs:param>
                </cs:command>
            </xsl:variable>
            <xsl:variable name="saveResult" select="$renderResult/cmd/renderer/command[@method = 'save']" as="element(command)?"/>
            <xsl:variable name="previewResult" select="$renderResult/cmd/renderer/command[@method = 'preview']" as="element(command)?"/>
            <xsl:variable name="layoutResult" select="$renderResult/cmd/assets/asset[1]" as="element(asset)?"/>

            <xsl:variable name="allTextAssets" select="$layoutResult/cs:child-rel()[@key='actual.']/cs:asset()[@censhare:asset.type='text.*']" as="element(asset)*"/>
            <xsl:variable name="allTextsAreReleased" select="every $text in $allTextAssets satisfies ($text/@wf_id = 10 and $text/@wf_step = 30)" as="xs:boolean?"/>
            <xsl:message>==== Update </xsl:message>
            <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAssetXml">
                <cs:param name="source">
                    <asset>
                        <xsl:choose>
                            <xsl:when test="count($allTextAssets) gt 0 and $allTextsAreReleased">
                                <xsl:attribute name="wf_id" select="80"/>
                                <xsl:attribute name="wf_step" select="20"/>
                                <xsl:copy-of select="$layoutResult/@*[not(local-name() = ('wf_id', 'wf_step'))]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="wf_id" select="80"/>
                                <xsl:attribute name="wf_step" select="10"/>
                                <xsl:copy-of select="$layoutResult/@*[not(local-name() = ('wf_id', 'wf_step'))]"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="$layoutResult/node() except $layoutResult/(storage_item, child_asset_rel[@key='user.'])"/>
                        <storage_item app_version="{$saveResult/@corpus:app_version}"
                                      key="master" element_idx="0" mimetype="application/indesign"
                                      corpus:asset-temp-filepath="{$saveResult/@corpus:asset-temp-filepath}"
                                      corpus:asset-temp-filesystem="{$saveResult/@corpus:asset-temp-filesystem}"/>
                        <xsl:for-each select="$previewResult/file">
                            <xsl:variable name="fileSystem" select="@corpus:asset-temp-filesystem"/>
                            <xsl:variable name="filePath" select="@corpus:asset-temp-filepath"/>
                            <xsl:variable name="currentPath" select="concat('censhare:///service/filesystem/', $fileSystem, '/', tokenize($filePath, ':')[2])"/>
                            <storage_item key="preview" mimetype="image/jpeg" element_idx="{@element_idx}">
                                <xsl:attribute name="corpus:asset-temp-file-url" select="$currentPath"/>
                            </storage_item>
                        </xsl:for-each>
                    </asset>
                </cs:param>
            </cs:command>
            <xsl:message>==== Update ID => <xsl:value-of select="$resultAssetXml/@id" />  </xsl:message>
            <xsl:if test="$censhare:command-xml/cmd-info[@type='server-action']">
                <cs:command name="com.censhare.api.event.Send">
                    <cs:param name="source">
                        <event target="CustomAssetEvent" param2="0" param1="1" param0="{$resultAssetXml/@id}" method="svtx-content-update"/>
                    </cs:param>
                </cs:command>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- -->
    <xsl:template match="asset" mode="place-cmd">
        <xsl:param name="key"/>
        <cs:command name="com.censhare.api.transformation.AssetTransformation">
            <cs:param name="key" select="'svtx:indesign.group.placement.cmd'"/>
            <cs:param name="source" select="."/>
            <cs:param name="xsl-parameters">
                <cs:param name="template-key" select="$key"/>
            </cs:param>
        </cs:command>
    </xsl:template>

    <!-- -->
    <xsl:template match="asset" mode="edit-cmd">
        <xsl:param name="layout"/>
        <cs:command name="com.censhare.api.transformation.AssetTransformation">
            <cs:param name="key" select="'svtx:indesign.pictures.edit.placement'"/>
            <cs:param name="source" select="$layout"/>
            <cs:param name="xsl-parameters">
                <cs:param name="placeAssetID" select="@id"/>
            </cs:param>
        </cs:command>
    </xsl:template>



    <xsl:function name="svtx:getMainContent">
        <xsl:param name="layout" as="element(asset)?"/>
        <xsl:param name="article" as="element(asset)?"/>
        <xsl:if test="$layout and $article">
            <xsl:variable name="searchResult">
                <cs:command name="com.censhare.api.transformation.AssetTransformation">
                    <cs:param name="key" select="'svtx:indesign.dynamic.search.main-content'"/>
                    <cs:param name="source" select="$article"/>
                    <cs:param name="xsl-parameters">
                        <cs:param name="target-asset-id" select="$layout/@id"/>
                    </cs:param>
                </cs:command>
            </xsl:variable>
            <xsl:variable name="mainContentAsset" select="$searchResult/assets/asset[1]" as="element(asset)?"/>
            <xsl:variable name="masterStorage" select="$mainContentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
            <xsl:copy-of select="if ($masterStorage) then doc($masterStorage/@url) else ()" />
        </xsl:if>
    </xsl:function>

    <xsl:function name="svtx:getStaerkenAsset">
        <xsl:param name="layoutAsset"/>
        <xsl:variable name="idExtern"
                      select="$layoutAsset/asset_element[xmldata/group[@group-name='Stärken']][1]/@id_extern"
                      as="xs:string?"/>
        <xsl:message>==== getStaerkenAssetXml idExtern <xsl:value-of select="$idExtern"/>   </xsl:message>
        <xsl:variable name="id"
                      select="$layoutAsset/child_asset_element_rel[@id_extern eq $idExtern]/@child_collection_id"
                      as="xs:long?"/>
        <xsl:message>==== Hiervon brauchen wir das ChildAsset Text? masterFile <xsl:value-of select="$id"/> </xsl:message>
        <xsl:variable name="asset" select="cs:get-asset($id)"/>
        <xsl:variable name="textType" select="'text.size-s.'"/>

        <xsl:variable name="mainContent">
            <xsl:choose>
                <xsl:when test="starts-with($asset/@type, 'article.')">
                    <xsl:variable name="masterAsset" select="($asset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type=$textType])[1]"/>
                    <xsl:if test="$masterAsset">
                        <xsl:variable name="masterStorage" select="$masterAsset/storage_item[@key='master']" as="element(storage_item)?"/>
                        <xsl:copy-of select="if ($masterStorage) then doc($masterStorage/@url) else ()" />
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>====copy-ofs <xsl:copy-of select="$mainContent"/> </xsl:message>
        <xsl:copy-of select="$mainContent"/>
    </xsl:function>

    <xsl:function name="svtx:getAssetElements" as="element(asset_element)*">
        <xsl:param name="layout" as="element(asset)?"/>
        <xsl:param name="group" as="xs:string?"/>
        <xsl:copy-of select="$layout/asset_element[xmldata/group[@group-name = $group]]"/>
    </xsl:function>




</xsl:stylesheet>
