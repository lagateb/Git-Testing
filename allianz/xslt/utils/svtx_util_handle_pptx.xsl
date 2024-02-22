<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">


    <!-- Funktionen, die in mehreren Transformationen genutzt werden -->

    <!-- überprüft, ob der Aartikel das Template Flag hat -->
    <xsl:function name="svtx:isNotATemplate" as="xs:boolean?">
        <xsl:param name="articleId"/>
        <xsl:variable name="article" select="cs:get-asset(xs:long($articleId))" as="element(asset)?"/>
        <!-- <parent_asset_rel   key="target." parent_asset="17675" /> -->

        <xsl:value-of  select="not(exists($article/asset_feature[@feature='censhare:asset-flag' and @value_key='is-template']))"  />
    </xsl:function>




    <!-- liefert einen Changehistory für das Text Asset zur davorigen Version

   -->
    <xsl:function name="svtx:getTextChanges" as="element(info)">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="before" select="$asset/@version - 1"/>
        <xsl:variable name="oldAsset" select="cs:get-asset($asset/@id,$before)"/>

        <info currentVersion="{$asset/@version}" oldVersion="{$oldAsset/@version}" >
            <workstep>
                <xsl:attribute name="has_change" select="$oldAsset/@wf_step != $asset/@wf_step"/>
                <xsl:attribute name="new" select="$asset/@wf_step"/>
                <xsl:attribute name="old" select="$oldAsset/@wf_step"/>
            </workstep>
            <content >
                <xsl:attribute name="has_change" select="$oldAsset/@content_version != $asset/@content_version"/>
                <xsl:attribute name="new" select="$asset/@content_version"/>
                <xsl:attribute name="old" select="$oldAsset/@content_version"/>

            </content>
            <sorting>
                <xsl:attribute name="has_change" select="$oldAsset/parent_asset_rel[@key='user.main-content.']/@sorting != $asset/parent_asset_rel[@key='user.main-content.']/@sorting "/>
                <xsl:attribute name="new" select="$asset/parent_asset_rel[@key='user.main-content.']/@sorting "/>
                <xsl:attribute name="old" select="$oldAsset/parent_asset_rel[@key='user.main-content.']/@sorting "/>
            </sorting>

            <!-- asset_feature[@feature='censhare:approval.history']/* -->
            <approvals>
                <xsl:attribute name="has_change" select="count($oldAsset/asset_feature[@feature='censhare:approval.history']/*)
                 != count($asset/asset_feature[@feature='censhare:approval.history']/*)"/>
                <xsl:attribute name="new" select="count($asset/asset_feature[@feature='censhare:approval.history']/*)"/>
                <xsl:attribute name="old" select="count($oldAsset/asset_feature[@feature='censhare:approval.history']/*)"/>
            </approvals>

            <approvaltypes>
                <xsl:attribute name="has_change" select="count($oldAsset/asset_feature[@feature='censhare:approval.type']/*)
                 != count($asset/asset_feature[@feature='censhare:approval.type']/*)"/>
                <xsl:attribute name="new" select="count($asset/asset_feature[@feature='censhare:approval.type']/*)"/>
                <xsl:attribute name="old" select="count($oldAsset/asset_feature[@feature='censhare:approval.type']/*)"/>
            </approvaltypes>


            <diversions>
                <xsl:variable name="changes" as="element(changes)">
                    <changes>
                        <!-- Neue -->
                        <xsl:for-each select="$asset/asset_feature[@feature='svtx:faq.medium']/@value_asset_id">
                            <xsl:variable name="searchId" select="."/>
                            <xsl:if test="not(exists($oldAsset/asset_feature[@feature='svtx:faq.medium' and  @value_asset_id=$searchId]))">
                                <pptx>
                                    <xsl:attribute name="id" select="$searchId"/>
                                </pptx>
                            </xsl:if>
                        </xsl:for-each>
                        <!-- gelöschte -->
                        <xsl:for-each select="$oldAsset/asset_feature[@feature='svtx:faq.medium']/@value_asset_id">
                            <xsl:variable name="searchId" select="."/>
                            <xsl:if test="not(exists($asset/asset_feature[@feature='svtx:faq.medium' and  @value_asset_id=$searchId]))">
                                <pptx>
                                    <xsl:attribute name="id" select="$searchId"/>
                                </pptx>
                            </xsl:if>
                        </xsl:for-each>
                    </changes>
                </xsl:variable>
                <xsl:attribute name="has_change" select="count($changes/pptx) > 0"/>
                <xsl:attribute name="new" select="count($asset/asset_feature[@feature='svtx:faq.medium'])"/>
                <xsl:attribute name="old" select="count($oldAsset/asset_feature[@feature='svtx:faq.medium'])"/>
                <xsl:copy-of select="$changes"/>


            </diversions>



        </info>
    </xsl:function>


    <xsl:function name="svtx:prepareTextAsset">
        <xsl:param name="textAsset"/>
        <!--

   String trResourceKey = "svtx:xsl.pptx.footnotes";
              String trReplaceSpcialBreak = "svtx:pptx.transform.linebreak";
        -->
        <xsl:variable name="trans1"/>
            <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans1">
                <cs:param name="key" select="'svtx:xsl.pptx.footnotes'"/>
                <cs:param name="source" select="$textAsset"/>
            </cs:command>

     <xsl:copy-of select="$trans1"/>
    </xsl:function>


    <!-- ruft unser Powerpoint Modul auf -->
    <xsl:function name="svtx:pptxFunctions">
        <xsl:param name="pptxId"/>
        <xsl:param name="command"/>
        <xsl:param name="additionalData"/>
        <xsl:message>===update pptx <xsl:value-of select="$pptxId"/> : <xsl:value-of select="$command"/> </xsl:message>
        <xsl:message>=== additionalData    <xsl:copy-of select="$additionalData"/></xsl:message>
        <xsl:variable name="command-xml">
            <cmd timeout="600">
                <xml-info title="{$command} PPTX " locale="__ALL">
                </xml-info>
                <cmd-info name="{$command} PPTX"/>
                <commands currentstep="command">
                    <command method="{$command}" scriptlet="modules.savotex.powerpoint.PPCapsulate"  target="ScriptletManager"/>
                </commands>
                <config>
                    <pptx>
                        <timeout value="600"/>
                        <xsl:copy-of select="$additionalData"/>
                    </pptx>
                </config>
                <content>
                </content>
                <assets>
                    <cs:param name="asset" select="cs:get-asset(xs:long($pptxId))"/>
                </assets>
            </cmd>

        </xsl:variable>
        <!-- setup the data -->
        <cs:command name="com.censhare.api.Command.execute">
            <cs:param name="source" select="$command-xml"/>
        </cs:command>

    </xsl:function>


</xsl:stylesheet>