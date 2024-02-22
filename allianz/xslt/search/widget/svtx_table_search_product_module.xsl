<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <xsl:param name="context-id"/>

    <xsl:param name="filterAssetName" select="''"/>

    <xsl:param name="assetType" select="'all'"/>
    <xsl:param name="workflowStepID" select="'all'"/>
    <!-- root match -->
    <xsl:template match="/">
        <query type="asset" >
            <and>
                <relation direction="parent" >
                    <target>
                        <and>
                            <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
                        </and>
                    </target>
                </relation>
                <condition name="censhare:asset.type" value="article.*" />
                <!-- TODO like -->
                <xsl:if test="$filterAssetName">
                    <condition name="censhare:text.name" op="=" value="{$filterAssetName}"/>
                </xsl:if>
                <xsl:if test="$assetType !=  'all'">
                    <condition name="censhare:asset.type" op="=" value="{$assetType}"/>

                </xsl:if>
                <xsl:if test="not($workflowStepID='all')">
                    <condition name="censhare:asset.wf_step" op="=" value="{$workflowStepID}"/>
                </xsl:if>
                <condition name="censhare:asset-flag" op="!=" value="s-template"/>
            </and>
            <sortorders>
              <order ascending="true" by="(CASE
                 WHEN (t0.type='article.header.') THEN 100
                 WHEN (t0.type='article.requirement-field-title.') THEN 105
                 WHEN (t0.type='article.produktbeschreibung.') THEN 200
                 WHEN (t0.type='article.what-is.') THEN 205
                 WHEN (t0.type='article.funktionsgrafik.') THEN 220
                 WHEN (t0.type='article.vorteile.') THEN 300
                 WHEN (t0.type='article.solution-overview.') THEN 305
                 WHEN (t0.type='article.fallbeispiel.') THEN 400
                 WHEN (t0.type='article.key-facts.') THEN 405
                 WHEN (t0.type='article.nutzenversprechen.') THEN 500
                 WHEN (t0.type='article.reasons.') THEN 505
                 WHEN (t0.type='article.zielgruppenmodul.') THEN 510
                 WHEN (t0.type='article.productdetails.') THEN 530
                 WHEN (t0.type='article.staerken.') THEN 560
                 WHEN (t0.type='article.flexi-module.') THEN 570
                 WHEN (t0.type='article.optional-module.') THEN 620
                 WHEN (t0.type='article.free-module.') THEN 630
                 WHEN (t0.type='layout.') THEN 700
                 WHEN (t0.type='presentation.issue.') THEN 800
                 ELSE 999 END)"/>
                <order by="censhare:asset.name"/>
            </sortorders>
        </query>
    </xsl:template>
</xsl:stylesheet>
