<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <!-- search promotions -->
    <xsl:param name="myPromotions" select="'no'" />
    <xsl:param name="stateFilter" select="'Freigabe Reinzeichnung'" />
    <xsl:param name="startDate" select="string(current-date() - xs:dayTimeDuration('P12M'))" />
    <xsl:param name="endDate" select="string(current-date())" />
    <xsl:param name="sortBy" select="'promotionnr'" />
    <xsl:param name="sortOrder" select="'ascending'" />
    <xsl:param name="selection" select="''"/>

    <!-- root match -->
    <xsl:template match="/">

        <xsl:variable name="search">
        <query>
            <condition name="censhare:asset.type" op="=" value="promotion.*"/>
            <xsl:if test="$selection">
                <or>
                    <condition name="censhare:text.name" value="{$selection}"/>
                    <condition name="msp:alz-mmc.promotion-number.index" value="{$selection}"/>
                    <condition name="msp:alz-mmc.media-provider.index" value="{$selection}"/>
                    <xsl:choose>
                        <xsl:when test="contains($selection, '_')">
                            <xsl:variable name="selectionPt1" select="replace($selection, '_.+', '')"/>
                            <xsl:variable name="selectionPt2" select="replace($selection, '.+_', '')"/>
                            <and>
                                <condition name="msp:alz-mmc.promotion-article_version-number.index" value="{$selectionPt1}"/>
                                <condition name="msp:alz-mmc.promotion-article_version-number.index" value="{$selectionPt2}"/>
                            </and>
                        </xsl:when>
                        <xsl:otherwise>
                            <condition name="msp:alz-mmc.promotion-article_version-number.index" value="{$selection}"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </or>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$myPromotions = 'yes'">
                    <condition name="censhare:function.my-tasks" value="1" />
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$stateFilter = 'ausgeliefert'">
                    <condition name="msp:alz-mmc.promotion-status" op="=" value="54" />
                </xsl:when>
                <xsl:when test="$stateFilter = 'Freigabe Reinzeichnung'">
                    <condition name="msp:alz-mmc.promotion-status" op="=" value="36" />
                </xsl:when>
                <xsl:when test="$stateFilter = 'Freigabe Layout'">
                    <condition name="msp:alz-mmc.promotion-status" op="=" value="29" />
                </xsl:when>
                <xsl:when test="$stateFilter = 'geschlossen'">
                    <or>
                        <condition name="msp:alz-mmc.promotion-status" op="=" value="21" />
                        <condition name="msp:alz-mmc.promotion-status" op="=" value="184" />
                    </or>
                </xsl:when>
                <xsl:otherwise>
                    <condition name="msp:alz-mmc.promotion-status" op="=" value="36" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="string-length($startDate) &gt; 0">
                <condition name="msp:alz-mmc.promotion-creation-date" op="&gt;=" value="{xs:dateTime(xs:date($startDate))}Z" />
            </xsl:if>
            <xsl:if test="string-length($endDate) &gt; 0">
                <condition name="msp:alz-mmc.promotion-creation-date" op="&lt;=" value="{xs:dateTime(xs:date($endDate))}Z" />
            </xsl:if>
            <sortorders>
                <grouping mode="none"/>
                <xsl:variable name="orderFeatures" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="$sortBy = 'creation-date'">
                            <xsl:sequence select="'msp:alz-mmc.promotion-creation-date'" />
                        </xsl:when>
                        <xsl:when test="$sortBy = 'promotionnr'">
                            <xsl:sequence select="'msp:alz-mmc.promotion-number'" />
                        </xsl:when>
                        <xsl:when test="$sortBy = 'artnr-and-version'">
                            <xsl:sequence select="'msp:alz-mmc.promotion-article-number'" />
                            <xsl:sequence select="'msp:alz-mmc.promotion-version-number'" />
                        </xsl:when>
                        <xsl:when test="$sortBy = 'with-media'">
                            <!-- This will not work! -->
                            <xsl:sequence select="'censhare:asset.creation_date'" />
                        </xsl:when>
                        <xsl:when test="$sortBy = 'quality'">
                            <!-- This will not work! -->
                            <xsl:sequence select="'censhare:asset.creation_date'" />
                        </xsl:when>
                        <xsl:when test="$sortBy = 'name'">
                            <xsl:sequence select="'msp:alz-mmc.promotion-name'" />
                        </xsl:when>
                        <xsl:when test="$sortBy = 'mediaprovider'">
                            <xsl:sequence select="'msp:alz-mmc.media-provider'" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="'msp:alz-mmc.promotion-number'" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="$orderFeatures">
                    <order ascending="true">
                        <xsl:attribute name="by" select="current()" />
                        <xsl:attribute name="ascending" select="$sortOrder = 'ascending'" />
                    </order>
                </xsl:for-each>
            </sortorders>
        </query>
        </xsl:variable>
         <xsl:copy-of select="$search"/>
    </xsl:template>

</xsl:stylesheet>
