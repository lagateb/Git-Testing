<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <xsl:import
            href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>

    <xsl:param name="context-id"/>

    <xsl:param name="filterAssetName" select="''"/>

    <xsl:param name="assetType" select="'all'"/>
    <xsl:param name="workflowStepID" select="'all'"/>
    <!-- root match -->
    <xsl:template match="/">
        <message>==== svtx:table_search_product_module_childs</message>
        <xsl:variable name="partyID" select="system-property('censhare:party-id')"/>

        <query type="asset">
            <and>

                <condition name="censhare:asset.domain" op="!=" value="{$publicDomain}"/>
                <condition name="censhare:asset.domain" op="!=" value="{$archivedDomain}"/>

                <or>
                    <condition name="censhare:asset.type" value="text.*"/>
                    <condition name="censhare:asset.type" value="article.*"/>
                </or>
                <relation direction="parent">
                    <target>
                        <and>

                            <condition name="censhare:asset.id" op="=" value="{$context-id}"/>

                        </and>
                    </target>
                </relation>

                <!-- TODO like -->
                <xsl:if test="$filterAssetName">
                    <condition name="censhare:text.name" op="=" value="{$filterAssetName}"/>
                    <xsl:message>===name
                        <xsl:value-of select="$filterAssetName"/>
                    </xsl:message>
                </xsl:if>
                <xsl:if test="$assetType !=  'all'">
                    <condition name="censhare:asset.type" op="=" value="{$assetType}"/>
                    <xsl:message>===assetType
                        <xsl:value-of select="$assetType"/>
                    </xsl:message>
                </xsl:if>
                <xsl:if test="not($workflowStepID='all')">
                    <condition name="censhare:asset.wf_step" op="=" value="{$workflowStepID}"/>
                </xsl:if>


                <condition name="censhare:asset-flag" op="!=" value="s-template"/>

            </and>
            <sortorders>
                <grouping mode="none"/>
                <!--
                 <order by="censhare:asset.id"/>
                <order by="censhare:asset.type"/>
                -->
            </sortorders>
        </query>

    </xsl:template>
</xsl:stylesheet>
