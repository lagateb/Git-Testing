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
        <!--
        <xsl:message>arcicle Table === <xsl:copy-of select="count(asset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*'])"/> </xsl:message>
        -->
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
                <defaultValues>{"filterAssetName": "", "assetType": "all","speech":"all","targetGroup"}</defaultValues>
            </config>
            <!-- content expects html snippet that is rendered in the widget -->
            <content>

                <!-- asset type text.* -->
                <xsl:variable name="assetTypes" as="element(asset_typedef)*">
                    <xsl:sequence select="cs:master-data('asset_typedef')[starts-with(@asset_type,'article.')]"/>
                </xsl:variable>

                <!-- nur die AssetTypen anzeigen, die vorhanden sind-->
                <xsl:variable name="assetTypesOk" select="(asset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*'])/./@type" as="xs:string*"/>
                <xsl:message>=== assetTypesOk <xsl:copy-of select="$assetTypesOk"/> </xsl:message>

                <xsl:variable name="assetTypeString">
                    <xsl:for-each select="$assetTypes[@asset_type=$assetTypesOk]">
                        <xsl:sort select="@name"/>
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:if test="asset">
                    <div class="cs-toolbar">
                        <div class="cs-toolbar-slot-1">
                            <!-- filter created by -->

                            <div class="cs-toolbar-item">
                                <cs-select class="cs-is-small cs-is-alt" label="${type}" width="auto" ng-model="toolbarData.assetType" unerasable="unerasable"
                                           ng-options="item.value as item.name for item in [{string-join(('{&quot;name&quot;: &quot;${all}&quot;, value: &quot;all&quot;}', for $x in $assetTypeString/asset_typedef return concat ('{&quot;name&quot;: &quot;',  $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@asset_type, '&quot;}')), ', ')}]"
                                           ng-change="onChange({{ assetType: toolbarData.assetType }})" ng-init="toolbarData.assetType = 'all'">
                                </cs-select>
                            </div>

                            <div class="cs-toolbar-item cs-m-r-m">
                                <cs-input class="cs-is-small cs-is-alt" placeholder="${filterResults}" ng-model="toolbarData.filterAssetName" ng-change="onChange({{ filterAssetName: toolbarData.filterAssetName }})"></cs-input>
                            </div>

                        </div>
                        <div class="cs-toolbar-slot-2">
                            <div class="cs-toolbar-item">
                                <cs-widget-action type="action" param="'allianzRecurringModulesBehavior'">
                                    <!--<span>CANCEL THIS</span>-->
                                    <!--<span cs-tooltip="Wiederverwendbare Module Tooltip" class="csActionsWidget__background-image cs-icon cs-icon-change-template" style="font-size:1.7em !important"></span>-->
                                    <cs-button class="cs-button-cta">Wiederverwendbare Module auswählen</cs-button>
                                </cs-widget-action>
                            </div>

                            <div class="cs-toolbar-item">

                                <cs-include-dialog key="'svtx:actions.allianz.open.flexi-module.wizard'"></cs-include-dialog>
                                <!--<cs-widget-action type="action" param="'allianzFlexiModuleWizardAssetCreateBehavior'">
                                    &lt;!&ndash;<span>CANCEL THIS</span>&ndash;&gt;
                                    &lt;!&ndash;<span cs-tooltip="Wiederverwendbare Module Tooltip" class="csActionsWidget__background-image cs-icon cs-icon-change-template" style="font-size:1.7em !important"></span>&ndash;&gt;
                                    <button class="cs-button-alt" role="button"><span class="cs-icon cs-icon-pencil cs-color-22 cs-m-r-s"></span>Web2Print Wizard</button>
                                </cs-widget-action>-->
                            </div>

                            <!-- filter asset name -->

                        </div>
                    </div>
                </xsl:if>


            </content>
        </result>
    </xsl:template>

</xsl:stylesheet>
