<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">

    <!-- toolbar for articles table -->

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>
    <!-- output -->
    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>
    <xsl:variable name="language" select="csc:getLoggedInPartyLocale()"/>





    <!-- root match -->
    <xsl:template match="/">


        <xsl:variable name="products" as="element(opt)*">
            <xsl:for-each select="cs:asset(svtx:getProductQuery())">
                <xsl:sort select="upper-case(@name)"/>
                <xsl:variable name="playground" select="if (contains(@domain, 'playground')) then 'only_playground' else 'only_live'"/>
                <opt value="{@name}" display_value="{@name}" domain="{@domain}" playground_type="{$playground}" id="{@id}"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="usage" as="element(opt)*">
            <opt value="bs" display_value="BS"/>
            <opt value="vp" display_value="VP"/>
            <opt value="az" display_value="AZ.de"/>
            <opt value="pptx" display_value="PPTX"/>
            <opt value="flyer" display_value="Flyer"/>
            <opt value="psb" display_value="PSB"/>
        </xsl:variable>

        <!--<xsl:variable name="productNames" select="svtx:getProductNames()"/>-->

        <xsl:variable name="domains">
            <xsl:for-each select="($publicDomain, $archivedDomain)">
                <xsl:sequence select="cs:master-data('domain')[@pathid=.]"/>
            </xsl:for-each>
        </xsl:variable>

        <!-- asset type -->
        <xsl:variable name="assetTypes" as="element(asset_typedef)*">
            <xsl:for-each select="('document.flyer.','document.psb.', 'presentation.issue.','text.public.')">
                <xsl:choose>
                    <xsl:when test=".='text.public.'">
                        <asset_typedef asset_type="text.public.*" name="Text" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="cs:master-data('asset_typedef')[@asset_type=.]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>

        <result>
            <!-- config contains default values -->
            <config>
                <defaultValues>{"playgroundFilter": "both","filterOnlyPlayground" : 0,   "filterProductName": "all", "assetUsage": "all","filterDomain:"<xsl:value-of select="$publicDomain"/>" }</defaultValues>
            </config>
            <content>
                <xsl:variable name="assetTypeString">
                    <xsl:for-each select="$assetTypes">
                        <xsl:sort select="@name"/>
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:variable>
                <style>
                    .jp-long {
                    min-width: 250px;
                    }
                </style>
                <div class="cs-toolbar">
                    <div class="cs-toolbar-slot-1">
                        <!-- filter created by -->
                        <div class="cs-toolbar-item">
                            <div>
                                <cs-select class="cs-is-small cs-is-alt" label="Produkt" width="auto" ng-model="toolbarData.filterProductName" placeholder="Alle"
                                           ng-options="item.value as item.name for item in [{string-join((for $x in $products return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;', ',&quot;playground_type&quot;:&quot;'  , $x/@playground_type ,'&quot;,&quot;id&quot;: &quot;',$x/@id,'&quot;}')), ', ')}] | filter:(toolbarData.playgroundFilter!=='both' ?{concat('{&quot;playground_type&quot;:', 'toolbarData.playgroundFilter}')}: '') track by item.value"
                                           ng-change="onChange({{ filterProductName: toolbarData.filterProductName}})" ng-init="toolbarData.filterProductName = 'all'">
                                </cs-select>
                            </div>
                        </div>
                        <div class="cs-toolbar-item">
                            <!--<cs-select class="cs-is-small cs-is-alt" label="${type}" width="auto" ng-model="toolbarData.assetType" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(('{&quot;name&quot;: &quot;${all}&quot;, value: &quot;all&quot;}', for $x in $assetTypeString/asset_typedef return concat ('{&quot;name&quot;: &quot;',  $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@asset_type, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ assetType: toolbarData.assetType }})" ng-init="toolbarData.assetType = 'all'">
                            </cs-select>-->
                            <cs-select class="cs-is-small cs-is-alt" label="Mediennutzung" width="auto" ng-model="toolbarData.assetUsage" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(('{&quot;name&quot;: &quot;${all}&quot;, value: &quot;all&quot;}', for $x in $usage return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ assetUsage: toolbarData.assetUsage }})" ng-init="toolbarData.assetUsage = 'all'">
                            </cs-select>
                        </div>

                        <!--<div class="cs-toolbar-item">
                            <cs-select style="" class="cs-is-small cs-is-alt jp-long" label="Status" width="auto" ng-model="toolbarData.filterDomain" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(( for $x in $domains/domain return concat ('{&quot;name&quot;: &quot;',  $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@pathid, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ filterDomain: toolbarData.filterDomain }})"   ng-init="toolbarData.filterDomain = 'root.allianz-leben-ag.contenthub.public.'"  >
                            </cs-select>
                        </div>-->

                        <!--<div class="cs-toolbar-item">
                            <xsl:variable name="optionsPlayground" as="element(opt)*">
                                <opt value="only_playground" display_value="nur Playground"/>
                                <opt value="only_live" display_value="nur Live-Produkte"/>
                                <opt value="both" display_value="beides"/>
                            </xsl:variable>
                            <cs-select style="" label="Produkte" class="cs-is-small cs-is-alt jp-long" width="auto" ng-model="toolbarData.playgroundFilter" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(( for $x in $optionsPlayground return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ playgroundFilter: toolbarData.playgroundFilter}})"   ng-init="toolbarData.playgroundFilter = 'both'"  >
                            </cs-select>
                        </div>-->
                    </div>
                </div>
            </content>
        </result>
    </xsl:template>




    <xsl:function name="svtx:getProductQuery" as="element(query)?">
        <query>
            <and>
                <condition name="censhare:asset.type" value="product.*"/>
                <condition name="censhare:asset-flag" op="ISNULL"/>
                <relation direction="child">
                    <target>
                        <condition name="censhare:asset.type" value="article.*"/>
                        <condition name="censhare:asset-flag" op="ISNULL"/>
                        <or>
                            <!-- texts -->
                            <relation direction="child" type="user.web-usage.">
                                <target>
                                    <and>
                                        <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.public."/>
                                        <condition name="censhare:output-channel" op="NOTNULL"/>
                                    </and>
                                </target>
                            </relation>
                            <!-- layout -->
                            <relation direction="child" type="user.main-content.">
                                <target>
                                    <condition name="censhare:asset.type" op="=" value="text.*"/>
                                    <relation direction="parent">
                                        <target>
                                            <condition name="censhare:asset.type" op="=" value="layout.*"/>
                                            <condition name="censhare:asset.wf_id" value="80"/>
                                            <or>
                                                <condition name="censhare:function.workflow-step" value="30"/>
                                                <condition name="censhare:function.workflow-step" value="60"/>
                                                <condition name="censhare:function.workflow-step" value="55"/>
                                                <condition name="censhare:function.workflow-step" value="90"/>
                                            </or>
                                        </target>
                                    </relation>
                                </target>
                            </relation>
                            <!-- PPTX SLIDE -->
                            <relation direction="parent" type="target.">
                                <target>
                                    <condition name="censhare:asset.type" op="=" value="presentation.slide.*"/>
                                    <relation direction="parent" type="target.">
                                        <target>
                                            <condition name="censhare:asset.type" op="=" value="presentation.issue.*"/>
                                            <condition name="censhare:asset.wf_id" value="80"/>
                                            <or>
                                                <condition name="censhare:function.workflow-step" value="30"/>
                                                <condition name="censhare:function.workflow-step" value="60"/>
                                                <condition name="censhare:function.workflow-step" value="55"/>
                                                <condition name="censhare:function.workflow-step" value="90"/>
                                            </or>
                                        </target>
                                    </relation>
                                </target>
                            </relation>
                        </or>
                    </target>
                </relation>
            </and>
            <sortorders>
                <grouping mode="none"/>
                <order ascending="true" by="censhare:asset.name"/>
                <order ascending="true" by="censhare:asset.type"/>
            </sortorders>
        </query>
    </xsl:function>


</xsl:stylesheet>
