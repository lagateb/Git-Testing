<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- parameters -->
    <xsl:param name="context-id"/>



    <xsl:template match="/">
        <xsl:message>=== subquery</xsl:message>
        <xsl:variable name="my"  select="$context-id/cs:asset()"/>
        <xsl:variable name="myType"  select="$my/@type"/>
        <xsl:message>=== <xsl:value-of select="$my/@type"/> </xsl:message>
        <!-- query -->
        <query>
            <and>
                <condition name="censhare:asset.domain" op="!=" value="root.allianz-leben-ag.templates."/>
                <condition name="censhare:asset.domain" op="!=" value="root.flyer-generator."/>
                <relation direction="parent" >
                    <target>
                        <and>
                            <condition name="censhare:asset.id" op="=" value="{$context-id}"/>
                        </and>
                    </target>
                </relation>
            </and>
            <sortorders>
                <!--

                 WHEN (t0.type='article.eingeschlosseneleistungen.') THEN 570
                 WHEN (t0.type='article.garantieniveaus.') THEN 580
                 WHEN (t0.type='article.schichten.') THEN 590
                 WHEN (t0.type='article.sicherungsvermoegen.') THEN 600
                 WHEN (t0.type='article.steuervorteile.') THEN 610

                -->
                <xsl:choose>
                    <xsl:when test="$myType='product.'">
                        <order ascending="true" by="(CASE
                 WHEN (t0.type='article.header.') THEN 100
                 WHEN (t0.type='article.produktbeschreibung.') THEN 200
                 WHEN (t0.type='article.funktionsgrafik.') THEN 220
                 WHEN (t0.type='article.vorteile.') THEN 300
                 WHEN (t0.type='article.fallbeispiel.') THEN 400
                 WHEN (t0.type='article.nutzenversprechen.') THEN 500
                 WHEN (t0.type='article.zielgruppenmodul.') THEN 510
                 WHEN (t0.type='article.productdetails.') THEN 530
                 WHEN (t0.type='article.staerken.') THEN 560
                 WHEN (t0.type='article.flexi-module.') THEN 570
                 WHEN (t0.type='article.optional-module.') THEN 620
                 WHEN (t0.type='article.free-module.') THEN 630
                 WHEN (t0.type='layout.') THEN 700
                 WHEN (t0.type='presentation.issue.') THEN 800
                 ELSE 999
                                END)" />
                        <order by="censhare:asset.name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <grouping mode="none" />
                        <order by="censhare:asset.id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </sortorders>
        </query>
    </xsl:template>
</xsl:stylesheet>
