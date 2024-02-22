<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">

    <xsl:param name="newsorting" />
    <xsl:param name="ids"  as="xs:string" select="'78825,78828'"/>
    <xsl:param name="sortings"  as="xs:string" select="'1,2'"/>
    <xsl:variable name="pptxFAQLayoutKey" select="'svtx:optional-modules.faq.slide'"/>

    <xsl:function name="svtx:getSort">
        <xsl:param name="ids" as="xs:string*"/>
        <xsl:param name="sorts" as="xs:string*"/>
        <sorting>
            <xsl:for-each select="$ids">
                <sort id="{.}"  />
            </xsl:for-each>
        </sorting>
    </xsl:function>


    <xsl:function name="svtx:updateSorting">
        <xsl:param name="textFaqID" as="xs:integer"/>
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="articleFaqID" as="xs:integer"/>

        <xsl:message> === sort <xsl:value-of select="$textFaqID"/> =  <xsl:value-of select="$position"/>  =  <xsl:value-of select="$articleFaqID"/>  </xsl:message>
        <xsl:variable name="textAsset" select="$textFaqID/cs:asset()"/>
        <!-- Ohne Ändrungshistorie, da sonst etliche unnötige Trigger gestartet werden -->
        <cs:command name="com.censhare.api.assetmanagement.Update">
            <cs:param name="source">
                <asset>
                    <xsl:copy-of select="$textAsset/@*"/>
                    <xsl:copy-of select="$textAsset/node() except($textAsset/(parent_asset_rel[@key='user.main-content.']),$textAsset/asset_element )"/>
                    <asset_element idx="0" key="actual."/>
                    <parent_asset_rel key="user.main-content." parent_asset="{$articleFaqID}" sorting="{$position}"/>
                </asset>
            </cs:param>
        </cs:command>
    </xsl:function>



    <xsl:function name="svtx:regeneratePPTX">
        <xsl:param name="changed" as="xs:string*"/>
        <xsl:for-each select="distinct-values($changed)">
            <xsl:variable name="pptxIssueID" select="." as="xs:string"/>
            <xsl:variable name="pptxFAQAsset"   select="(($pptxIssueID/cs:asset())/cs:child-rel()[@key='target.'])/asset_feature[@feature='svtx:layout-template-resource-key' and @value_asset_key_ref=$pptxFAQLayoutKey]/.." />


            <xsl:message>=== svtx:regeneratePPTX  <xsl:value-of select="$pptxIssueID"/>  <xsl:copy-of select="$pptxFAQAsset"/></xsl:message>

            <xsl:variable name="trans1"/>

            <xsl:if test="$pptxFAQAsset">

                <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans1">
                    <cs:param name="key" select="'svtx:regenerate.pptx.faq.slide.on.text.changed'"/>
                    <cs:param name="source" select="$pptxFAQAsset"/>
                </cs:command>

            </xsl:if>


        </xsl:for-each>

    </xsl:function>

    <xsl:template match="/asset[@type ='article.optional-module.faq.']">
        <xsl:message>==== article.optional-module.faq.</xsl:message>
        <xsl:variable name="asset" select="."/>
        <xsl:variable name="assetIds" select="tokenize($ids,',')"/>
        <xsl:variable name="assetSort" select="tokenize($sortings,',')"/>

        <xsl:message>====asset <xsl:value-of select="$asset/@id"/></xsl:message>
        <xsl:message>====assetIds <xsl:copy-of select="$assetIds"/></xsl:message>
        <xsl:message>==== <xsl:copy-of select="$assetSort"/></xsl:message>
        <xsl:variable name="changed" as="xs:string*">

            <xsl:for-each select="$assetIds" >
                <xsl:variable name="assetID" select="." as="xs:integer"/>
                <xsl:variable name="pos" select="position()"/>
                <xsl:variable name="faqAsset" select="cs:get-asset($assetID)"/>
                <xsl:if test="$faqAsset/parent_asset_rel[@key='user.main-content.']/@sorting != $pos">
                    <!--<pos value="{$pos}" id="{$assetID}"/>-->
                    <xsl:variable name="ret" select="svtx:updateSorting($assetID,$pos,$asset/@id)"/>
                    <xsl:for-each select="$faqAsset/asset_feature[@feature='svtx:faq.medium']/@value_asset_id">
                        <xsl:variable name="pptxAsset" select="."/>
                        <xsl:copy-of select="$pptxAsset"/>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>

        </xsl:variable>
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <xsl:message>=== changed <xsl:copy-of select="$changed"/></xsl:message>
        <xsl:variable name="ret" select="svtx:regeneratePPTX($changed)"/>
    </xsl:template>
</xsl:stylesheet>
