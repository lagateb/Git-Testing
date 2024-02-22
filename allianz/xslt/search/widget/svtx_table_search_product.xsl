<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <xsl:param name="filterAssetName" select="''"/>
    <xsl:param name="filterCreatedBy" select="'all'"/>
    <xsl:param name="assetType" select="'all'"/>
    <xsl:param name="filterDomain"  select="'all'"/>
    <xsl:param name="playgroundFilter"  select="'both'"/> <!-- both, only_playground, only_live-->

    <!-- root match -->
    <xsl:template match="/">

        <xsl:variable name="partyID" select="system-property('censhare:party-id')"/>

        <query type="asset" >
            <and>
                <condition name="censhare:asset.type" value="product.*" />
                <xsl:if test="$filterCreatedBy != 'all'">
                    <condition name="censhare:asset.created_by" value="{$partyID}"/>
                    <xsl:message>===party <xsl:value-of select="$partyID"/> </xsl:message>
                </xsl:if>
                <!-- TODO like -->
                <xsl:if test="$filterAssetName">
                    <condition name="censhare:text.name" op="=" value="{$filterAssetName}"/>
                    <xsl:message>===name <xsl:value-of select="$filterAssetName"/> </xsl:message>
                </xsl:if>
                <xsl:if test="$assetType !=  'all'">
                    <condition name="censhare:asset.type" op="=" value="{$assetType}"/>
                    <xsl:message>===assetType <xsl:value-of select="$assetType"/> </xsl:message>
                </xsl:if>

                <xsl:if test="$filterDomain !=  'all'">
                    <condition name="censhare:asset.domain" op="=" value="{$filterDomain}*"/>
                    <xsl:message>===filterDomain <xsl:value-of select="$filterDomain"/> </xsl:message>>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$playgroundFilter = 'only_playground'">
                        <or>
                            <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground.*"/>
                            <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground-sach.*"/>
                        </or>
                    </xsl:when>
                    <xsl:when test="$playgroundFilter = 'only_live'">
                        <not>
                            <or>
                                <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground.*"/>
                                <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.contenthub.playground-sach.*"/>
                            </or>
                        </not>
                    </xsl:when>
                    <xsl:when test="$playgroundFilter = 'both'">
                        <!-- do nothing ? -->
                    </xsl:when>
                </xsl:choose>

                <condition name="censhare:asset.domain" op="!=" value="root.allianz-leben-ag.templates."/>
                <condition name="censhare:asset.domain" op="!=" value="root.flyer-generator."/>
                <condition name="censhare:asset-flag" op="!=" value="s-template"/>

            </and>

            <not>
                <or>
                    <condition name="censhare:asset.type" value="product.capital-investment.*"/>
                    <condition name="censhare:asset.type" value="product.item.*"/>
                </or>
            </not>

            <sortorders>
                <grouping mode="none"/>
                <order  ascending="false"  by="censhare:asset.id"/>
            </sortorders>
        </query>
    </xsl:template>
</xsl:stylesheet>
