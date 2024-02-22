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

    <xsl:variable name="ASSET_WF" select="40"/>
    <xsl:variable name="ASSET_WF_STEP" select="20"/>

    <xsl:variable name="ASSET_MEDIUM_WF" select="80"/>
    <xsl:variable name="ASSET_MEDIUM_WF_STEP" select="20"/>

    <xsl:template match="/asset[starts-with(@type, 'article.')]">

        <xsl:if test="$debugLog">
            <xsl:message>############################## Start Media Workflow Update Script ################################</xsl:message>
        </xsl:if>

        <!-- current asset-->
        <xsl:variable name="asset" select="." as="element(asset)"/>

        <xsl:if test="(($asset/@wf_id = $ASSET_WF) and ($asset/@wf_step = $ASSET_WF_STEP))">
            <xsl:copy-of select="svtx:checkMedia($asset)"/>
        </xsl:if>

        <xsl:if test="$debugLog">
            <xsl:message>############################## End Media Workflow Update Script ##################################</xsl:message>
        </xsl:if>

    </xsl:template>

    <xsl:function name="svtx:checkMedia">
        <xsl:param name="asset" as="element(asset)"/>

        <!-- Alle Präsentations Slide Assets -->
        <xsl:variable name="presentationSlides" select="$asset/cs:parent-rel()[@key = 'target.']/cs:asset()[(@censhare:asset.type = 'presentation.slide.*')]" />

        <xsl:for-each select="$presentationSlides">
            <xsl:copy-of select="svtx:checkPesentationSlide(.)" />
        </xsl:for-each>

    </xsl:function>


    <xsl:function name="svtx:checkPesentationSlide">
        <xsl:param name="asset" as="element(asset)"/>

        <!--xsl:variable name="presentations" select="$asset/cs:parent-rel()[@key = 'target.']/cs:asset()[(@censhare:asset.type = 'presentation.issue.')]" /-->

        <xsl:variable name="presentations" select="svtx:findAllPresentationAssets($asset, 5)" />

        <xsl:for-each select="$presentations">
            <xsl:if test="@wf_id=$ASSET_MEDIUM_WF and not(@wf_step=$ASSET_MEDIUM_WF_STEP)">
                <xsl:copy-of select="svtx:checkPesentation(.)" />
            </xsl:if>
        </xsl:for-each>

    </xsl:function>

    <xsl:function name="svtx:findAllPresentationAssets">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="level" as="xs:integer"/>

        <xsl:if test="($level &gt; 0)">

            <xsl:variable name="children" select="$asset/cs:parent-rel()[not(@key = 'target.')]" />
            <xsl:for-each select="$children">

                <xsl:choose>
                    <xsl:when test="starts-with(@type, 'presentation.issue.')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="newLevel" select="$level - 1" as="xs:integer"/>
                        <xsl:copy-of select="svtx:findAllPresentationAssets(., $newLevel)" />
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>
        </xsl:if>

    </xsl:function>

    <xsl:function name="svtx:checkPesentation">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="articleAssets" select="svtx:findAllModuleAssets($asset, 5)"/>

        <xsl:variable name="notApprovedAssets" select="$articleAssets[@wf_id=$ASSET_WF and not(@wf_step=$ASSET_WF_STEP)]"/>

        <xsl:if test="not($notApprovedAssets)">
            <xsl:copy-of select="svtx:updateMedium($asset)" />
        </xsl:if>

    </xsl:function>

    <xsl:function name="svtx:findAllModuleAssets">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="level" as="xs:integer"/>

        <xsl:if test="($level &gt; 0)">

            <xsl:variable name="children" select="$asset/cs:child-rel()[not(@key = 'target.')]" />
            <xsl:for-each select="$children">

                <xsl:choose>
                    <xsl:when test="starts-with(@type, 'article.')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="newLevel" select="$level - 1" as="xs:integer"/>
                        <xsl:copy-of select="svtx:findAllModuleAssets(., $newLevel)" />
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>
        </xsl:if>

    </xsl:function>

    <xsl:function name="svtx:updateMedium">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:if test="$debugLog">
            <xsl:message>############################## check medium  <xsl:value-of select="$asset/@name"/> (<xsl:value-of select="$asset/@id"/>) </xsl:message>
            <medium><xsl:value-of select="$asset/@name"/> (<xsl:value-of select="$asset/@id"/>)</medium>
        </xsl:if>

        <xsl:if test="$asset">

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
                <asset wf_id="{$ASSET_MEDIUM_WF}" wf_step="{$ASSET_MEDIUM_WF_STEP}">
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

            <updated-medium><xsl:value-of select="$checkedInAsset/@id"/></updated-medium>

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
