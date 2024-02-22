<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">

    <!-- holt sich die ID des PowerPoint Asset, welches mit dem Artikel des Textest verknüpft ist -->
    <xsl:function name="svtx:getPowerPointId" as="xs:integer?">
        <xsl:param name="articleId"/>
        <xsl:variable name="article" select="cs:get-asset(xs:long($articleId))" as="element(asset)?"/>
        <!-- <parent_asset_rel   key="target." parent_asset="17675" /> -->
        <xsl:value-of  select="($article/parent_asset_rel[@key='target.']/@parent_asset)[1]"  />
    </xsl:function>

    <!-- überprüft, ob   der artikel das Template Flag hat -->
    <xsl:function name="svtx:isNotATemplate" as="xs:boolean?">
        <xsl:param name="articleId"/>
        <xsl:variable name="article" select="cs:get-asset(xs:long($articleId))" as="element(asset)?"/>
        <!-- <parent_asset_rel   key="target." parent_asset="17675" /> -->

        <xsl:value-of  select="not(exists($article/asset_feature[@feature='censhare:asset-flag' and @value_key='is-template']))"  />
    </xsl:function>





    <!-- <parent_asset_rel child_asset="17759"  key="target." parent_asset="17737" /> -->
    <!-- Updated ggf das Masterpowerpoint -->
    <xsl:function name="svtx:updateMasterPowerPoint">
        <xsl:param name="slideId"/>
        <xsl:variable name="pptxAsset" select="cs:get-asset(xs:long($slideId))" as="element(asset)?"/>
        <!-- <parent_asset_rel   key="target." parent_asset="17675" /> -->
        <xsl:variable name="assetId"  select="$pptxAsset/parent_asset_rel[@key='target.']/@parent_asset"  />
        <xsl:message>===Haben wir master pptx <xsl:value-of select="$assetId"/>  </xsl:message>
        <xsl:if test="$assetId">
            <xsl:message>===Bearbeiten Master </xsl:message>
            <xsl:variable name="asset" select="cs:get-asset(xs:long($assetId))" as="element(asset)?"/>
            <xsl:if test="exists($asset[@type='presentation.issue.'])">
                <xsl:message>===Bearbeiten Master merge </xsl:message>
                <xsl:value-of select="svtx:pptxFunctions($assetId,'merge','')"/>
            </xsl:if>

        </xsl:if>
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



    <xsl:function name="svtx:isSalesVariant" as="xs:boolean">
        <xsl:param name="textAsset"/>
        <xsl:value-of select="exists($textAsset/parent_asset_rel/asset_rel_feature[@feature='svtx:text-variant-type' and @value_key='sales' ])"/>
    </xsl:function>

    <xsl:function name="svtx:isAgentVariant" as="xs:boolean">
        <xsl:param name="textAsset"/>
        <xsl:value-of select="exists($textAsset/parent_asset_rel/asset_rel_feature[@feature='svtx:text-variant-type' and @value_key='agent' ])"/>
    </xsl:function>


    <xsl:function name="svtx:hasSalesVariant" as="xs:boolean">
        <xsl:param name="textAsset"/>
        <xsl:value-of select="exists($textAsset/child_asset_rel[@key='variant.1.']/asset_rel_feature[@feature='svtx:text-variant-type' and @value_key='sales' ])"/>
    </xsl:function>

    <xsl:function name="svtx:hasAgentVariant" as="xs:boolean">
        <xsl:param name="textAsset"/>
        <xsl:value-of select="exists($textAsset/child_asset_rel[@key='variant.1.']/asset_rel_feature[@feature='svtx:text-variant-type' and @value_key='agent' ])"/>
    </xsl:function>


    <xsl:function name="svtx:getArticleId" as="xs:integer">
        <xsl:param name="textAsset"/>
        <xsl:param name="isChild"/>
        <xsl:choose>
            <xsl:when test="$isChild">
                <xsl:variable name="asset" select="cs:get-asset(xs:long($textAsset/parent_asset_rel[@key='variant.1.']/@parent_asset[1]))" as="element(asset)?"/>
                <xsl:value-of select="$asset/parent_asset_rel[@key='user.main-content.']/@parent_asset[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$textAsset/parent_asset_rel[@key='user.main-content.']/@parent_asset[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- holt sich die parents des Artikels vom Typ target -->
    <xsl:function name="svtx:getTargetParents">
        <xsl:param name="articleId"/>
        <xsl:variable name="article" select="cs:get-asset(xs:long($articleId))" as="element(asset)?"/>
        <xsl:copy-of  select="$article/parent_asset_rel[@key='target.']"  />
    </xsl:function>

    <!-- Regeneriert die nötigen PowerPoint Dateien
         Wenn es eine Variante ist, dann die jeweilige Slide mit und Das
    -->
    <!-- ermittelt die zu regenerierenden  Slides -->
    <xsl:function name="svtx:regeneratePPTXs" as="xs:string">
        <xsl:param name="text"/>
        <xsl:param name="isSalesVariant"/>
        <xsl:param name="isAgentVariant"/>
        <xsl:choose>
            <xsl:when test="$isSalesVariant">
                <xsl:variable name="asset" select="cs:get-asset(xs:long($text/parent_asset_rel[@key='variant.1.']/@parent_asset))" as="element(asset)?"/>
                <xsl:choose>
                    <xsl:when test="svtx:hasAgentVariant($asset)">sales</xsl:when>
                    <xsl:otherwise>sales,agent</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$isAgentVariant">agent</xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="svtx:hasSalesVariant($text)">standard</xsl:when>
                    <xsl:otherwise>standard,sales,agent</xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:isPTTXToRegenerate" as="xs:boolean">
        <xsl:param name="assetId"/>
        <xsl:param name="compareString"/>
        <xsl:variable name="asset" select="cs:get-asset(xs:long($assetId))" as="element(asset)?"/>
        <xsl:value-of select="$asset/@type='presentation.slide.' and  exists($asset/asset_feature[@feature='svtx:text-variant-type'])and  contains($compareString,$asset/asset_feature[@feature='svtx:text-variant-type']/@value_key)  "/>
    </xsl:function>


    <xsl:function name="svtx:setAssetNameIfChanged">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:variable name="productAsset" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"  />
        <xsl:variable name="productName"  select="$productAsset/@name"   as="xs:string"/>

        <xsl:variable name="contentXml" select="if ($textAsset/storage_item[@key='master']) then doc($textAsset/storage_item[@key='master']/@url) else ()"/>
        <xsl:variable name="question" select="$contentXml/article/content/question" as="xs:string"/>
        <xsl:variable name="textAssetName" select="$textAsset/@name" as="xs:string"/>
        <xsl:variable name="newName"  select="concat($productName,' - ',$question)"/>

        <xsl:message>===== richtig newName <xsl:value-of select="$newName"/> </xsl:message>
        <xsl:if test="$newName != $textAssetName">
            <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAsset">
                <cs:param name="source">
                    <asset>
                        <xsl:copy-of select="$textAsset/@* except($textAsset/@name)"/>
                        <xsl:attribute name="name" select="$newName"/>
                        <xsl:copy-of select="$textAsset/node()"/>
                    </asset>
                </cs:param>
            </cs:command>
        </xsl:if>
    </xsl:function>




    <xsl:template match="asset[starts-with(@type, 'text.') and not(@type='text.faq.')]">
        <xsl:param name="slide-id" as="xs:long?"/>
        <xsl:message>=== Start svtx.regenerate.pptx.slide.on.text.changed.xsl<xsl:value-of select="@id"/></xsl:message>
        <xsl:variable name="currentVersion" select="@version"/>
        <xsl:message>=== currentVersion <xsl:value-of select="$currentVersion"/></xsl:message>
        <xsl:variable name="additionalData"><textAssetId value="{@id}"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="$currentVersion &gt; 1">
                <xsl:variable name="isSalesVariant" select="svtx:isSalesVariant(.)"/>
                <xsl:variable name="isAgentVariant" select="svtx:isAgentVariant(.)"/>
                <xsl:message>=== isSalesVariant <xsl:value-of select="$isSalesVariant"/> </xsl:message>
                <xsl:message>=== isAgentVariant <xsl:value-of select="$isAgentVariant"/>  </xsl:message>
                <xsl:variable name="articleId" select="svtx:getArticleId(.,$isAgentVariant or $isSalesVariant)"/>
                <xsl:message>=== articleId <xsl:value-of select="$articleId"/>  </xsl:message>
                <xsl:if test="svtx:isNotATemplate($articleId)">
                    <xsl:variable name="parents" select="svtx:getTargetParents($articleId)"/>
                    <xsl:message>=== parents <xsl:copy-of select="$parents"/>  </xsl:message>
                    <xsl:if test="$parents">
                        <xsl:message>=== regenerate</xsl:message>
                        <xsl:variable name="toRegenerate" select="svtx:regeneratePPTXs(.,$isSalesVariant,$isAgentVariant)"/>
                        <xsl:message>=== toRegenerate  <xsl:value-of select="$toRegenerate"/> </xsl:message>
                        <xsl:variable name="article" select="cs:get-asset(xs:long($articleId))" as="element(asset)?"/>
                        <xsl:variable name="slidesToUpdate" select="if ($slide-id) then $slide-id else $article/parent_asset_rel[@key='target.']/@parent_asset" as="xs:long*"/>
                        <xsl:for-each select="$slidesToUpdate">
                            <xsl:variable name="pId" select="."/>
                            <xsl:message>=== PPTXID <xsl:value-of select="$pId"/> </xsl:message>
                            <xsl:if test="svtx:isPTTXToRegenerate($pId,$toRegenerate)">
                                <xsl:message>=== OK PPTXID <xsl:value-of select="$pId"/> </xsl:message>
                                <xsl:value-of select="svtx:pptxFunctions($pId,'update',$additionalData)"/>
                                <xsl:value-of select="svtx:updateMasterPowerPoint($pId)"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>=== nicht notwendig</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="asset[starts-with(@type, 'text.faq')]">
        <xsl:message> ===== nur faq Event</xsl:message>
        <xsl:variable name="faqAsset" select="svtx:setAssetNameIfChanged(.)"/>
        <cs:command name="com.censhare.api.event.Send">
            <cs:param name="source">
                <event target="CustomAssetEvent" param2="0" param1="1" param0="{./@id}" method="svtx-regenerate-faq-slide"/>
            </cs:param>
        </cs:command>
    </xsl:template>

</xsl:stylesheet>
