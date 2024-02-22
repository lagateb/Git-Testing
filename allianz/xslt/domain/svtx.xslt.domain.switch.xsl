<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:svtx="http://www.savotex.com/"
        exclude-result-prefixes="#all"
        version="2.0">

    <!-- params -->

    <xsl:param name="mode" select="'none'"/>
    <xsl:param name="domain" select="''"/>

    <!--
    <xsl:param name="mode" select="'switchToUnit'"/>
    <xsl:param name="domain" select="''"/>

    <xsl:param name="mode" select="'switchToAgency'"/>
    <xsl:param name="domain" select="'root.allianz-leben-ag.contenthub.l-mm-bb.cmf.'"/>
    -->


    <!-- variables -->
    <xsl:variable name="debug" select="false()" as="xs:boolean"/>
    <xsl:variable name="debugLog" select="true()" as="xs:boolean"/>

    <!-- Defines a search for the main content assets -->
    <xsl:template match="asset">

        <xsl:variable name="asset" select="." as="element(asset)?"/>

        <xsl:if test="$debugLog">
            <xsl:message>############################## svtx:xslt.domain.switch  ##################################### </xsl:message>
            <xsl:message>############################## update asset  <xsl:value-of select="$asset/@name"/> (<xsl:value-of select="$asset/@id"/>) </xsl:message>
            <xsl:message>############################## mode  <xsl:value-of select="$mode"/> </xsl:message>
            <xsl:message>############################## domain  <xsl:value-of select="$domain"/> </xsl:message>
        </xsl:if>

        <xsl:if test="$mode='switchToUnit' or $mode='switchToAgency'">

            <xsl:variable name="currentDomain" select="$asset/@domain"/>

            <xsl:variable name="newDomain">
                <xsl:choose>
                    <xsl:when test="$mode='switchToAgency'"><xsl:value-of select="$domain"/></xsl:when>
                    <xsl:when test="$mode='switchToUnit'"><xsl:value-of select="cs:master-data('domain')[@pathid=$currentDomain]/@parent"/></xsl:when>
                </xsl:choose>
            </xsl:variable>

            <current-domain><xsl:value-of select="$currentDomain"/></current-domain>
            <new-domain><xsl:value-of select="$newDomain"/></new-domain>

            <xsl:if test="starts-with($newDomain, 'root.allianz-leben-ag.contenthub.l-mm') or starts-with($newDomain, 'root.allianz-leben-ag.contenthub.playground')">
                <xsl:variable name="assetsIds">
                    <xsl:copy-of select="svtx:findAllAssets($asset, $currentDomain, '', 10)"/>
                </xsl:variable>

                <xsl:copy-of select="$assetsIds"/>

                <xsl:for-each select="distinct-values($assetsIds/id)">
                    <xsl:variable name="curentAsset" select="cs:get-asset(.)"/>
                    <xsl:copy-of select="svtx:updateDomain($curentAsset, $newDomain)" />
                </xsl:for-each>

            </xsl:if>

        </xsl:if>

    </xsl:template>

    <xsl:function name="svtx:findAllAssets">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="currentDomain" as="xs:string"/>
        <xsl:param name="alreadyProcessedIDs" as="xs:string"/>
        <xsl:param name="level" as="xs:integer"/>

        <!-- suche soll abgebrochen werden, wenn die ID in der Liste-"alreadyProcessedIDs" oder das level die 0 errecht  -->
        <!-- so soll ein unedliche Schleife vermiden werden. Da es theoretisch mit den verknüpfungen möglich wäre dies zu machen -->
        <xsl:if test="not(contains($alreadyProcessedIDs, $asset/@id)) and ($level &gt; 0)">
            <id><xsl:value-of select="$asset/@id"/></id>
            <xsl:variable name="children" select="$asset/cs:child-rel()[not(@key = 'user.responsible.')]/cs:asset()[@censhare:asset.domain = $currentDomain]" />
            <xsl:for-each select="$children">
                <xsl:if test="not(starts-with(@type,'person.'))">
                    <xsl:variable name="newLevel" select="$level - 1" as="xs:integer"/>
                    <xsl:copy-of select="svtx:findAllAssets(., $currentDomain, concat($alreadyProcessedIDs, ',', $asset/@id), $newLevel)" />
                </xsl:if>
            </xsl:for-each>
        </xsl:if>

    </xsl:function>

    <xsl:function name="svtx:updateDomain">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="newDomain" as="xs:string"/>

        <xsl:if test="$debugLog">
            <xsl:message>############################## update asset  <xsl:value-of select="$asset/@name"/> (<xsl:value-of select="$asset/@id"/>) </xsl:message>
        </xsl:if>

        <xsl:if test="string-length(normalize-space($newDomain)) > 0">

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
                <asset domain="{$newDomain}">
                    <xsl:copy-of select="$checkedOutAsset/@*[not(local-name() = ('domain'))]"/>
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

            <updated-asset><xsl:value-of select="$checkedInAsset/@id"/></updated-asset>

        </xsl:if>

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