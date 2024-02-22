<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">


    <!--
       Setzt  das Produkt, die Medien PPTX und Layout, die das Textasset nutzen wieder zurück auf in Bearbeitung
       Setzt die history zurück
       Text
       Medien

       TODO Medien nur zurücksetzen, NUR wenn noch nicht zurückgesetzt? Bring das was?
    -->

    <xsl:variable name="WF_TEXT" select="'10'"/>
    <xsl:variable name="WF_OBJECT" select="'30'"/> <!-- ist für Produkt -->
    <xsl:variable name="WF_MODULE" select="'40'"/> <!-- ist für Artikel -->
    
    <xsl:variable name="WF_MEDIUM" select="'80'"/> <!-- ist für LAyout/pptx -->
    
    
    <xsl:variable name="WF_TEXT_STEP_TO_CREATION" select="'10'"/>
    <xsl:variable name="WF_TEXT_STEP_TO_APPROVE" select="'20'"/>

    <xsl:variable name="WF_MODULE_STEP_TO_CREATION" select="'10'"/>
    
    <xsl:variable name="WF_OBJECT_TO_CREATION" select="'20'"/>

    <xsl:variable name="WF_MEDIUM_TO_CREATION" select="'10'"/>
    

    

     




    <xsl:template match="/">
        <xsl:variable name="textAsset" select="./asset"/>
        <xsl:choose>
            <xsl:when test="$textAsset[@type ='text.faq.']">
                <xsl:variable name="ret2" select="svtx:setWFStepTo($textAsset,$WF_TEXT_STEP_TO_CREATION)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="productAsset" select="svtx:getProductFromText($textAsset)"/>
                <xsl:variable name="articleAsset" select="svtx:getArticleFromText($textAsset)"/>
                <xsl:variable name="ret1" select="svtx:resetTextAsset($textAsset)"/>
                <xsl:variable name="ret2" select="svtx:setWFStepTo($articleAsset,$WF_MODULE_STEP_TO_CREATION)"/>
                <xsl:variable name="ret2" select="svtx:setWFStepTo($productAsset,$WF_OBJECT_TO_CREATION)"/>
                <xsl:variable name="ret3" select="svtx:setLayoutsToCreation($textAsset)"/>
                <xsl:variable name="ret4" select="svtx:setPPTXToCreation($textAsset)"/>

            </xsl:otherwise>
        </xsl:choose>


        <!-- if textAssetisForPPTX -->
    </xsl:template>



    <xsl:function name="svtx:update" as="element(asset)">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="ret"/>
        <cs:command name="com.censhare.api.assetmanagement.Update" returning="ret">
            <cs:param name="source" select="$asset"/>
        </cs:command>
        <xsl:copy-of select="$ret"/>
    </xsl:function>

    <!-- liefert den Artikel zum Main oder Varianten Text -->
    <xsl:function name="svtx:getArticleFromText"  as="element(asset)">
        <xsl:param name="textAsset" as="element(asset)"/>

        <xsl:variable name="mainText" as="element(asset)?">
            <xsl:choose>
                <xsl:when test="$textAsset/parent_asset_rel[@key='variant.1.']">
                    <xsl:copy-of select="($textAsset/cs:parent-rel()[@key = 'variant.1.']/cs:asset()[@censhare:asset.type = 'text.*'])[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$textAsset"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:variable name="article"
                      select="($mainText/cs:parent-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'article.*'])[1]"/>

        <xsl:copy-of select="$article"/>
    </xsl:function>

    <!-- liefert das Produkt(Object)-Asset des übergebnen TextAssets -->
    <xsl:function name="svtx:getProductFromText"  as="element(asset)">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:variable name="articleAsset" select="svtx:getArticleFromText($textAsset)"/>

        <xsl:variable name="product" select="($articleAsset/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $articleAsset/cs:parent-rel()[@key='variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'])[1]"/>

        <xsl:copy-of select="$product"/>
    </xsl:function>

    <!-- set den WF Step zurück und löscht Approvals/History

    -->
    <xsl:function name="svtx:resetTextAsset">
        <xsl:param name="textAsset" as="element(asset)"/>

       <xsl:variable name="copyReject" select="$textAsset/@wf_step = $WF_TEXT_STEP_TO_APPROVE"/>

        <xsl:variable name="newAsset" as="element(asset)?">
            <asset  wf_step="{$WF_TEXT_STEP_TO_CREATION}">
                <xsl:copy-of select="$textAsset/@*[not(local-name() = ('wf_step'))]"/>

                <xsl:copy-of select="$textAsset/node() except( $textAsset/asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type' ] ,
               $textAsset/storage_item[@key='abstimmungsdokument_short' or @key='abstimmungsdokument'])"/>
                <xsl:if test="$copyReject">
                    <xsl:copy-of select="$textAsset/asset_feature[@feature='censhare:approval.type']/asset_feature[@feature='censhare:approval.status' and @value_key='rejected']/.."/>
                </xsl:if>
            </asset>

        </xsl:variable>
        <xsl:copy-of select="svtx:update($newAsset)"/>
    </xsl:function>

  <!--
      Neue Version für mehrere Assets
      Setz den WF_Step zurück auf Erstellung und löscht Aprrovals/History
  -->

    <xsl:function name="svtx:resetMediaAsset">
        <xsl:param name="mediaAssets" as="element(asset)*"/>
        <xsl:if test="$mediaAssets">
            <xsl:for-each select="$mediaAssets">
                <xsl:variable name="mediaAsset" select="."/>
            <xsl:variable name="newAsset" as="element(asset)?">
                <asset  wf_step="{$WF_MEDIUM_TO_CREATION}">
                    <xsl:copy-of select="$mediaAsset/@*[not(local-name() = ('wf_step'))]"/>
                    <xsl:copy-of select="$mediaAsset/node() except( $mediaAsset/asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type' ] ,
               $mediaAsset/storage_item[@key='abstimmungsdokument_short' or @key='abstimmungsdokument'])"/>
                </asset>
            </xsl:variable>
            <xsl:copy-of select="svtx:update($newAsset)"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

  <xsl:function name="svtx:resetMediaAssetOld">
      <xsl:param name="mediaAsset" as="element(asset)?"/>
      <xsl:if test="$mediaAsset">
      <xsl:variable name="newAsset" as="element(asset)?">
          <asset  wf_step="{$WF_MEDIUM_TO_CREATION}">
              <xsl:copy-of select="$mediaAsset/@*[not(local-name() = ('wf_step'))]"/>
              <xsl:copy-of select="$mediaAsset/node() except( $mediaAsset/asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type' ] ,
               $mediaAsset/storage_item[@key='abstimmungsdokument_short' or @key='abstimmungsdokument'])"/>
          </asset>
      </xsl:variable>
      <xsl:copy-of select="svtx:update($newAsset)"/>
      </xsl:if>
  </xsl:function>

    <!-- setzt den WorkFlowStep des Asset und Updated(saved) es -->
    <xsl:function name="svtx:setWFStepTo" as="element(asset)">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="newStep" as="xs:string"/>
        <xsl:variable name="newAsset" as="element(asset)?">
            <asset  wf_step="{$newStep}">
                <xsl:copy-of select="$asset/@*[not(local-name() = ('wf_step'))]"/>
                <xsl:copy-of select="$asset/node()"/>
            </asset>
        </xsl:variable>
        <xsl:copy-of select="svtx:update($newAsset)"/>
    </xsl:function>

    <!-- Setzt alle Layouts, die den Text nutzen im Workflow zurück -->
    <xsl:function name="svtx:setLayoutsToCreation">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:for-each select="$textAsset/cs:parent-rel()[@key = 'actual.']/cs:asset()[@censhare:asset.type = 'layout.*']">
            <xsl:variable name="layoutAsset" select="."/>
            <xsl:variable name="ret" select="svtx:resetMediaAsset($layoutAsset)"/>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="svtx:textAssetIsForPPTX">
        <xsl:param name="textAsset" as="element(asset)"/>
    </xsl:function>


    <xsl:function name="svtx:setPPTXPresentationWFStep">
        <xsl:param name="slideAssets" as="element(asset)*"/>
        <xsl:param name="newStep" as="xs:string"/>
        <xsl:message>==== wir sind hier</xsl:message>
        <xsl:for-each select="$slideAssets">
            <xsl:variable name="slideAsset" select="."/>
            <xsl:variable name="pptxAsset" select="$slideAsset/cs:parent-rel()[@key='target.']"/>
            <xsl:message>==== setPPTXPresentationWFStep
                <xsl:value-of select="$pptxAsset/@id"/>
            </xsl:message>
            <xsl:copy-of select="svtx:setWFStepTo($pptxAsset,$newStep)"/>
        </xsl:for-each>
    </xsl:function>

    <!-- Setzt alle PPTX, die den Text nutzen im Workflow zurück -->
    <xsl:function name="svtx:setPPTXToCreation">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:choose>
            <xsl:when test="svtx:isAgentVariant($textAsset)">
                <xsl:variable name="pptx" select="$textAsset/cs:parent-rel()[@key='user.main-content.']/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='agent']/.."/>
                <xsl:variable name="ret1" select="svtx:setPPTXPresentationWFStep($pptx,$WF_MEDIUM_TO_CREATION)"/>
            </xsl:when>
            <xsl:when test="svtx:isSalesVariant($textAsset)">
                <xsl:variable name="pptx" select="$textAsset/cs:parent-rel()[@key='user.main-content.']/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='sales']/.."/>
                <xsl:variable name="ret1" select="svtx:setPPTXPresentationWFStep($pptx,$WF_MEDIUM_TO_CREATION)"/>
            </xsl:when>
            <xsl:otherwise>
                <!--
                asset_feature asset_id="38852" asset_version="1" corpus:dto_flags="pt" feature="svtx:text-variant-type" isversioned="1" party="10" rowid="2476902" sid="3788762" timestamp="2021-09-01T07:53:32Z" value_key="standard"/>
                -->
                <xsl:message>==== wir sind hier </xsl:message>
                <xsl:variable name="pptx" select="$textAsset/cs:parent-rel()[@key='user.main-content.']/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='standard']/.."/>
                <xsl:message>==== wir sind hier2 <xsl:value-of select="$pptx/@id"/> </xsl:message>
                <xsl:variable name="ret1" select="svtx:setPPTXPresentationWFStep($pptx,$WF_MEDIUM_TO_CREATION)"/>
                <xsl:message>==== wir sind hier3 </xsl:message>
                <xsl:if test="not(svtx:hasAgentVariant($textAsset))">
                    <xsl:message>==== wir sind hier4 </xsl:message>
                    <xsl:variable name="pptx" select="$textAsset/cs:parent-rel()[@key='user.main-content.']/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='agent']/.."/>
                    <xsl:message>==== wir sind hier5 <xsl:value-of select="$pptx/@id"/> </xsl:message>
                    <xsl:variable name="ret1" select="svtx:setPPTXPresentationWFStep($pptx,$WF_MEDIUM_TO_CREATION)"/>
                    <xsl:message>==== wir sind hier6 </xsl:message>
                </xsl:if>
                <xsl:if test="not(svtx:hasSalesVariant($textAsset))">
                    <xsl:message>==== wir sind hier7 </xsl:message>
                    <xsl:variable name="pptx" select="$textAsset/cs:parent-rel()[@key='user.main-content.']/cs:parent-rel()[@key='target.']/asset_feature[@feature='svtx:text-variant-type' and @value_key='sales']/.."/>
                    <xsl:message>==== wir sind hier8 </xsl:message>
                    <xsl:variable name="ret1" select="svtx:setPPTXPresentationWFStep($pptx,$WF_MEDIUM_TO_CREATION)"/>
                    <xsl:message>==== wir sind hier9 </xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
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




</xsl:stylesheet>