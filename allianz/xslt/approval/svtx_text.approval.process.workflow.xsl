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
    <xsl:variable name="ASSET_WF_STEP" select="20"/>
    <xsl:variable name="ASSET_WF_STEP_NEW" select="30"/>

    <xsl:variable name="ASSET_MODULE_WF" select="40"/>
    <xsl:variable name="ASSET_MODULE_WF_STEP" select="10"/>
    <xsl:variable name="ASSET_MODULE_WF_STEP_NEW" select="20"/>


    <!-- global variables -->
    <xsl:variable name="approvalFeatureId" select="'censhare:approval.type'"/>
    <xsl:variable name="approvalStatusFeatureId" select="'censhare:approval.status'"/>
    <xsl:variable name="approvalPersonFeatureId" select="'censhare:approval.person'"/>
    <xsl:variable name="approvalDateFeatureId" select="'censhare:approval.date'"/>
    <xsl:variable name="approvalCommentFeatureId" select="'censhare:approval.comment'"/>
    <xsl:variable name="approvalVersionFeatureId" select="'censhare:approval.asset-version'"/>

    <!-- Get approval status alternatives, used to determine approval functionallity (Disable reject value key if reject button should not be present) -->
    <xsl:variable name="approvalStatuses" as="element(feature_value)*" select="cs:master-data('feature_value')[@feature=$approvalStatusFeatureId]"/>

    <xsl:template match="/asset[starts-with(@type, 'text.')]">

        <xsl:if test="$debugLog">
            <xsl:message>############################## Start Approval Process Script ################################</xsl:message>
        </xsl:if>

        <!-- current asset-->
        <xsl:variable name="asset" select="." as="element(asset)"/>

        <xsl:if test="(($asset/@wf_id = $ASSET_WF) and ($asset/@wf_step = $ASSET_WF_STEP))">

            <xsl:variable name="approvals" select="svtx:getApprovals($asset)"/>

            <xsl:variable name="notApproved" select="$approvals/approval/asset-approval[@status-key!='approved' and @status-key!='ignored']"/>

            <xsl:variable name="notApprovedCount" select="count($notApproved)" as="xs:integer"/>

            <xsl:choose>
                <xsl:when test="($notApprovedCount=200)">

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
                        <asset wf_id="{$ASSET_WF}" wf_step="{$ASSET_WF_STEP_NEW}">
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

                    <updated-text><xsl:value-of select="$checkedInAsset/@id"/></updated-text>

                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$debugLog">
                        <xsl:value-of select="'Not all approvals have been granted yet. Scip Workflow update'"/>
                        <xsl:message>############################## Not all approvals have been granted yet. Scip Workflow update </xsl:message>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <xsl:if test="$debugLog">
            <xsl:message>############################## End Approval Process Script ##################################</xsl:message>
        </xsl:if>

    </xsl:template>


    <xsl:function name="svtx:getApprovals">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="approvalFeatureDef" as="element(feature)*" select="cs:master-data('feature')[@key=$approvalFeatureId]"/>
        <xsl:variable name="featureAsset" select=" csc:getFeatureAsset($approvalFeatureDef)"/>


        <!-- Get asset approvals -->
        <xsl:variable name="assetApprovals" as="element(asset_feature)*" select="$asset/asset_feature[@feature=$approvalFeatureId]"/>

        <!-- Get approvals featureItems sorted -->
        <approvals>

            <xsl:for-each select="$featureAsset/asset_feature[@feature='censhare:module.feature-item']">
                <xsl:sort select="@sorting" data-type="number" />
                <!-- get asset and check if asset match asset type filer -->
                <xsl:variable name="featureItemResourceKey" select="@value_asset_key_ref"/>
                <xsl:variable name="featureItemAsset" as="element(asset)" select="csc:getResourceAsset($featureItemResourceKey)"/>

                <!-- Valid for asset type? -->
                <xsl:if test="csc:getMatchAssetTypeFilter($asset, $featureItemAsset, true())">
                    <approval censhare:_annotation.multi="true">
                        <xsl:attribute name="key" select="$featureItemResourceKey"/>
                        <xsl:attribute name="name" select="csc:getLocalizedAssetName($featureItemAsset)"/>
                        <xsl:attribute name="description" select="csc:getLocalizedAssetDescription($featureItemAsset)"/>
                        <xsl:copy-of select="@sorting"/>

                        <!-- Get asset approval -->
                        <xsl:variable name="assetApproval" as="element(asset_feature)*" select="($assetApprovals[@value_asset_key_ref=$featureItemResourceKey])[1]"/>
                        <asset-approval>
                            <xsl:choose>
                                <xsl:when test="$assetApproval">
                                    <!-- Status key as attribute -->
                                    <xsl:variable name="statusKey" select="($assetApproval/asset_feature[@feature=$approvalStatusFeatureId]/@value_key, 'unknown')[1]"/>
                                    <xsl:attribute name="status-key" select="$statusKey"/>

                                    <!-- Date attribute -->
                                    <xsl:variable name="dateValue" as="xs:dateTime?" select="$assetApproval/asset_feature[@feature=$approvalDateFeatureId]/@value_timestamp"/>
                                    <xsl:attribute name="date" select="if(exists($dateValue)) then cs:format-date($dateValue, 'relative-short', 'short') else ''"/>

                                    <!-- Status metadata for presentation -->
                                    <status>
                                        <xsl:attribute name="key" select="$statusKey"/>
                                        <xsl:attribute name="name" select="$approvalStatuses[@value_key=$statusKey]/@name"/>
                                    </status>

                                    <xsl:variable name="approvalUserAssetId" select="$assetApproval/asset_feature[@feature=$approvalPersonFeatureId]/@value_asset_id"/>
                                    <approver>
                                        <xsl:attribute name="asset-id" select="$approvalUserAssetId"/>
                                        <xsl:attribute name="user-id" select="cs:master-data('party')[@party_asset_id=$approvalUserAssetId]/@id"/>
                                        <xsl:attribute name="display-name" select="if($approvalUserAssetId) then cs:master-data('party')[@party_asset_id=$approvalUserAssetId]/@display_name else ''"/>
                                    </approver>
                                    <comment><xsl:value-of  select="$assetApproval/asset_feature[@feature=$approvalCommentFeatureId]/@value_string"/></comment>

                                    <xsl:copy-of select="$assetApproval"/>

                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="statusKey" select="'none'"/>
                                    <xsl:attribute name="status-key" select="$statusKey"/>
                                    <status>
                                        <xsl:attribute name="key" select="$statusKey"/>
                                        <xsl:attribute name="name" select="'NONE'"/>
                                        <xsl:attribute name="css-icon" select="'cs-icon-close-cross'"/>
                                        <xsl:attribute name="css-color" select="'cs-color-00'"/>
                                    </status>
                                </xsl:otherwise>
                            </xsl:choose>
                        </asset-approval>
                    </approval>
                </xsl:if>

            </xsl:for-each>
        </approvals>

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
