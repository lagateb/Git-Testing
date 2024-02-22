<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

    <!-- toolbar for articles table -->

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

    <!-- output -->
    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

    <xsl:variable name="language" select="csc:getLoggedInPartyLocale()"/>


    <!-- root match -->
    <xsl:template match="/">
        <xsl:variable name="query">
            <query>
                <relation type="censhare:asset.category" target="feature-reverse">
                    <target>
                        <or>
                            <condition name="censhare:asset.type" value="article.*"/>
                        </or>
                    </target>
                </relation>
            </query>
        </xsl:variable>
        <xsl:variable name="assetCategories" select="cs:asset($query)"/>
        <result>
            <!-- config contains default values -->
            <config>
                <defaultValues>{"filterAssetName": "", "filterCreatedBy": "me", "assetType": "all"}</defaultValues>
            </config>
            <!-- content expects html snippet that is rendered in the widget -->
            <content>

                <!-- asset type -->
                <xsl:variable name="assetTypes" as="element(asset_typedef)*">
                    <xsl:for-each select="('product.', 'product.vsk.')">
                        <xsl:sequence select="cs:master-data('asset_typedef')[@asset_type=.]"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="assetTypeString">
                    <xsl:for-each select="$assetTypes">
                        <xsl:sort select="@name"/>
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="domains" select="cs:master-data('domain')"/>

                <!-- nur diese Domains werden in der obersten Ebene von den Produkten genutzt -->
                <!-- replace(replace(./@domain,'.cmf.','.'),'.port-neo.','.')) -->

                <xsl:variable name="domains2" select="distinct-values( cs:asset()[@censhare:asset.type = 'product.*']/replace(replace(@domain,'.cmf.','.'),'.port-neo.','.'))" as="xs:string*"/>
                <xsl:variable name="domainsSorted">
                    <xsl:for-each select="$domains[@pathid=$domains2 and not(contains(@pathid,'root.flyer-generator')) and  not(contains(@pathid,'root.allianz-leben-ag.templates')) and ((string-length(@pathid) - string-length(translate(@pathid, '.', '')))  &lt; 6)]">
                        <xsl:sort select="@sorting"/>
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:variable>
                <div class="cs-toolbar">
                    <div class="cs-toolbar-slot-1">
                        <!-- filter created by -->
                        <div class="cs-toolbar-item">
                            <cs-select class="cs-is-small cs-is-alt" label="${createdBy}" width="auto" ng-model="toolbarData.filterCreatedBy" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{{name: &quot;${all}&quot;, value: &quot;all&quot;}}, {{name: &quot;${me}&quot;, value: &quot;me&quot;}}]"
                                       ng-change="onChange({{ filterCreatedBy: toolbarData.filterCreatedBy }})">
                            </cs-select>
                        </div>
                        <div class="cs-toolbar-item">
                            <cs-select class="cs-is-small cs-is-alt" label="${type}" width="auto" ng-model="toolbarData.assetType" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(('{&quot;name&quot;: &quot;${all}&quot;, value: &quot;all&quot;}', for $x in $assetTypeString/asset_typedef return concat ('{&quot;name&quot;: &quot;',  $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@asset_type, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ assetType: toolbarData.assetType }})" ng-init="toolbarData.assetType = 'all'">
                            </cs-select>
                        </div>
                        <div class="cs-toolbar-item">
                            <cs-select class="cs-is-small cs-is-alt" label="Referat" width="auto" ng-model="toolbarData.filterDomain" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(('{&quot;name&quot;: &quot;${all}&quot;, value: &quot;all&quot;}', for $x in $domainsSorted/domain return concat ('{&quot;name&quot;: &quot;',  $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@pathid, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ filterDomain: toolbarData.filterDomain }})">
                            </cs-select>
                        </div>
                        <div class="cs-toolbar-item">
                            <xsl:variable name="optionsPlayground" as="element(opt)*">
                                <opt value="only_playground" display_value="nur Playground"/>
                                <opt value="only_live" display_value="nur Live-Produkte"/>
                                <opt value="both" display_value="beides"/>
                            </xsl:variable>
                            <cs-select style="" label="Produkte" class="cs-is-small cs-is-alt jp-long" width="auto" ng-model="toolbarData.playgroundFilter" unerasable="unerasable"
                                       ng-options="item.value as item.name for item in [{string-join(( for $x in $optionsPlayground return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                                       ng-change="onChange({{ playgroundFilter: toolbarData.playgroundFilter }})"   ng-init="toolbarData.playgroundFilter = 'both'"  >
                            </cs-select>
                        </div>
                        <span class="cs-toolbar-separator"></span>
                        <div class="cs-toolbar-item">
                            <cs-input class="cs-is-small cs-is-alt" placeholder="${filterResults}" ng-model="toolbarData.filterAssetName" ng-change="onChange({{ filterAssetName: toolbarData.filterAssetName }})"></cs-input>
                        </div>
                    </div>
                    <div class="cs-toolbar-slot-2">
                        <!-- filter asset name -->



                        <div class="cs-toolbar-item cs-m-r-m">
                            <cs-include-dialog key="'svtx:actions.open.allianz.product.wizard'"></cs-include-dialog>
                        </div>

                        <!--<div class="cs-toolbar-item cs-m-r-m">
                            <cs-widget-action type="wizard" param="'allianzProductWizard'">
                                <span class="cs-button-cta">Objekt anlegen</span>
                            </cs-widget-action>
                        </div>

                        <div class="cs-toolbar-item cs-m-r-m">
                            <cs-widget-action type="action" param="'allianzProductWizardCreateBehavior'">
                                <button class="cs-button-cta" role="button">Objekt anlegen 1 (Test)</button>
                            </cs-widget-action>
                        </div>-->

                    </div>
                </div>
            </content>
        </result>
    </xsl:template>

</xsl:stylesheet>
