<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">



    <xsl:variable name="wfid" select="10" />

    <xsl:function name="svtx:getAllMedias" as="xs:string">
        <xsl:param name="faqAsset" as="element(asset)"/>

        <xsl:variable name="tmp" as="xs:string*">
            <xsl:for-each select="$faqAsset/asset_feature[@feature='svtx:faq.medium']/@value_asset_id">
                <xsl:variable name="selectedAsset" select="cs:get-asset(xs:integer(.))"/>
                <xsl:value-of select="$selectedAsset/@name"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="tmp2" select="string-join($tmp,' ')" />
        <xsl:choose>
            <xsl:when test="string-length($tmp2) > 0">PPTX</xsl:when>
            <xsl:otherwise><xsl:value-of select="' '"/></xsl:otherwise>

        </xsl:choose>
    </xsl:function>


    <xsl:function name="svtx:getAllChannelKeys" as="xs:string?">
        <xsl:param name="faqTextAsset" as="element(asset)"/>
        <xsl:variable name="tmp" as="xs:string*">
            <xsl:for-each select="$faqTextAsset/asset_feature[@feature='svtx:preselected-output-channel']/@value_string">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="tmp2" select="string-join($tmp,' ')" />
         <xsl:value-of select="$tmp2"/>
    </xsl:function>


    <xsl:function name="svtx:getStrapline" as="xs:string">
        <xsl:param name="textAsset"/>
        <xsl:variable name="masterStorage" select="$textAsset/storage_item[@key='master']"/>
        <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:value-of select="$contentXml/article/content/strapline"/>
    </xsl:function>

    <xsl:function name="svtx:getWorkFlowStepName" as="xs:string">
        <xsl:param name="stepId"/>
        <xsl:value-of select="cs:master-data('workflow_step')[@wf_id= $wfid and @wf_step = $stepId]/@name"/>
    </xsl:function>


    <xsl:function name="svtx:getWorkFlowStepColor" as="xs:string">
        <xsl:param name="stepId"/>
        <xsl:value-of select="cs:master-data('workflow_step')[@wf_id= $wfid and @wf_step = $stepId]/@color"/>
    </xsl:function>

    <xsl:template match="/asset[@type ='article.optional-module.faq.']">
        <xsl:variable name="asset" select="."/>
        <options>
            <xsl:for-each select="$asset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.*']">
                <xsl:sort select="./@sorting"/>
                <option value="{@id}"
                        display_value="{@name}"
                        sorting="{./parent_asset_rel[@key='user.main-content.']/@sorting}"
                        wf_step="{@wf_step}"
                        wf_step_name="{svtx:getWorkFlowStepName(@wf_step)}"
                        wf_step_color="{svtx:getWorkFlowStepColor(@wf_step)}"
                        medias="{svtx:getAllMedias(.)}"
                        channels = "{svtx:getAllChannelKeys(.)}"
                        strapline="{svtx:getStrapline(.)}"

                />
            </xsl:for-each>
        </options>
    </xsl:template>
</xsl:stylesheet>
