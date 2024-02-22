<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        xmlns:map="http://ns.censhare.de/mapping" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
        xmlns:xal="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="#all"
        version="2.0">



  <!-- konstante variablen -->
  <xsl:variable name="TWO_PAGER_LINE_BREAK" select="'&#xe001;'" as="xs:string"/>
  <xsl:variable name="PPTX_LINE_BREAK" select="'&#xe000;'" as="xs:string"/>
  <xsl:variable name="FLYER_LINE_BREAK" select="'&#xe002;'" as="xs:string"/>
  <xsl:variable name="BS_LINE_BREAK" select="'&#xe003;'" as="xs:string"/>

  <xsl:variable name="NEW_LINE">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <xsl:variable name="NEW_LINE_CARRIAGE_RETURN">
    <xsl:text>&#xd;</xsl:text>
  </xsl:variable>


    <!-- löscht alle Sonder-Breaks ausser für Flyer -->
    <xsl:function name="svtx:cleanForFlyer" as="xs:string">
       <xsl:param name="textToClean" as="xs:string"/>
       <xsl:value-of select="replace(replace(replace($textToClean, $PPTX_LINE_BREAK, ''), $TWO_PAGER_LINE_BREAK, ''),$BS_LINE_BREAK,'')"/>
    </xsl:function>

    <!-- löscht alle Sonder-Breaks ausser für PSB -->
    <xsl:function name="svtx:cleanForPSB" as="xs:string">
        <xsl:param name="textToClean" as="xs:string"/>
        <xsl:value-of select="replace(replace(replace($textToClean, $PPTX_LINE_BREAK, ''), $FLYER_LINE_BREAK, ''),$BS_LINE_BREAK,'')"/>
    </xsl:function>


    <!-- löscht alle Sonder-Breaks -->
    <xsl:function name="svtx:cleanAllSpecialBreaks" as="xs:string">
        <xsl:param name="textToClean" as="xs:string"/>
        <xsl:value-of select="replace(replace(replace(replace(., $TWO_PAGER_LINE_BREAK, ''), $PPTX_LINE_BREAK, ''), $FLYER_LINE_BREAK, ''),$BS_LINE_BREAK,'')"/>
    </xsl:function>





  <!-- Funktionen extrahieren nur die genutzten Elemente einer Page für Footnote incl. Fussnotenmerge -->

  <xsl:function name="svtx:nutzenversprechenContent">
    <xsl:param name="content"/>
    <xsl:variable name="tempData">
    <article>
      <content>
        <xsl:copy-of select="$content/article/content/headline"/>
          <xsl:copy-of select="$content/article/content/body/bullet-list"/>
        <xsl:copy-of select="$content/article/content/calltoaction"/>
      </content>
    </article>
    </xsl:variable>
      <xsl:variable name="tempData2">
          <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
      </xsl:variable>
      <xsl:message>nutzenversprechenContentb ====<xsl:copy-of select="$tempData"/></xsl:message>
      <xsl:message>nutzenversprechenContent ====<xsl:copy-of select="$tempData2"/></xsl:message>
      <xsl:copy-of select="$tempData2"/>
  </xsl:function>

  <xsl:function name="svtx:defaultContent">
    <xsl:param name="content"/>
    <xsl:variable name="tempData">
      <article>
        <content>
          <xsl:copy-of select="$content/article/content/headline"/>
          <xsl:copy-of select="$content/article/content/body"/>
          <xsl:copy-of select="$content/article/content/bullet-list"/>
        </content>
      </article>
    </xsl:variable>
    <xsl:variable name="tempData2">
      <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
    </xsl:variable>
    <xsl:copy-of select="$tempData2"/>
  </xsl:function>

  <xsl:function name="svtx:vorteileContent">
    <xsl:param name="content"/>
    <xsl:variable name="tempData">
    <article>
      <content>
        <xsl:copy-of select="$content/article/content/headline"/>
        <xsl:copy-of select="$content/article/content/body/bullet-list"/>
      </content>
    </article>
      </xsl:variable>
      <xsl:variable name="tempData2">
          <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
      </xsl:variable>
      <xsl:message>vorteileContentb ====<xsl:copy-of select="$content"/></xsl:message>
      <xsl:message>vorteileContent ====<xsl:copy-of select="$tempData2"/></xsl:message>
      <xsl:copy-of select="$tempData2"/>
  </xsl:function>


  <!-- holt den Content des Root-Assets -->
  <xsl:function name="svtx:getContentXml">
    <xsl:param name="rootAsset"/>
    <xsl:variable name="currentAsset" select="svtx:getCheckedOutAsset($rootAsset)" as="element(asset)?"/>
    <xsl:variable name="masterStorage" select="$currentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <!-- <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/> -->
    <xsl:copy-of select="if ($masterStorage) then doc($masterStorage/@url) else ()" />
  </xsl:function>

  <xsl:function name="svtx:createOrGetQRAsset" as="element(asset)?">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:if test="$url">
      <xsl:variable name="hashedUrl" select="cs:hash($url)" as="xs:string"/>
      <xsl:variable name="existingQrCode" select="(cs:asset()[@censhare:asset.id_extern = $hashedUrl and @censhare:asset.type = 'picture.'])[1]" as="element(asset)?"/>
      <xsl:choose>
        <xsl:when test="$existingQrCode">
          <xsl:copy-of select="$existingQrCode"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="out"/>
          <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
          <xsl:variable name="resultFile" select="concat($out, @id, '.png')"/>
          <cs:command name="com.censhare.api.transformation.BarcodeTransformation">
            <cs:param name="source" select="$url"/>
            <cs:param name="dest" select="$resultFile"/>
            <cs:param name="barcode-transformation">
              <barcode-transformation type="qr" file-format="png"
                                      height="20" module-width="50" margin="0"
                                      orientation="0" font="Courier" font-size="10"
                                      dpi="72" antialias="true"/>
            </cs:param>
          </cs:command>
          <!-- new asset -->
          <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
              <asset name="QR Code - Fallbeispiel - {$url}" type="picture." domain="root.common-resources.">
                <asset_element key="actual." idx="0"/>
                <asset_feature feature="censhare:asset.id_extern" value_string="{$hashedUrl}"/>
                <storage_item corpus:asset-temp-file-url="{$resultFile}" element_idx="0" key="master" mimetype="image/png"/>
              </asset>
            </cs:param>
          </cs:command>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
      <cs:param name="flush" select="true()"/>
    </cs:command>
  </xsl:function>

  <!-- sucht im XML alle Fussnoten ausser die direkt am Kontent und liefert diese mit Position
 <footnotes>
    <footnote no="1">
       bla bla
    </footnote>
 ...
 </footnotes>
 -->

  <xsl:function name="svtx:groupedFootnotes">
    <xsl:param name="content"/>
    <xsl:element name="footnotes" >
      <xsl:for-each-group select="$content//footnote/." group-by=".">
        <xsl:if test="name(parent::node()) != 'content'">
          <footnote no="{position()}">
              <xsl:copy-of  select="." />
          </footnote>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:function>

    <xsl:function name="svtx:getXmlDataFromLayout">
        <xsl:param name="layoutId"/>
        <xsl:variable name="currentAsset" select="cs:get-asset(xs:long($layoutId))" as="element(asset)?"/>
        <!-- Alle Child Elements -->
        <xsl:variable name="child_asset_element_rel" select="$currentAsset/child_asset_element_rel"
                      as="element(child_asset_element_rel)*"/>
        <xsl:variable name="productId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Produktbeschreibung')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="casestudyId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Fallbeispiel')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="product">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($productId))"/>
        </xsl:variable>
        <xsl:variable name="casestudy">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($casestudyId))"/>
        </xsl:variable>

        <xsl:variable name="tempData">
            <content>
                <xsl:copy-of select="$product/article/content/headline"/>
                <xsl:copy-of select="$product/article/content/body"/>
                <xsl:copy-of select="$casestudy/article/content/headline"/>
                <!-- fallbeispiel content xml hat sich geändert, es wird eine tabelle nun benutzt. Body lasse ich vorerst drin-->
                <xsl:copy-of select="$casestudy/article/content/body"/>
                <xsl:copy-of select="$casestudy/article/content/table"/>
                <globalfootnotes>
                    <xsl:if test="$product/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($product/article/content/footnote,' ')"/>
                    </xsl:if>
                    <xsl:if test="$casestudy/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($casestudy/article/content/footnote,' ')"/>
                    </xsl:if>
                </globalfootnotes>
            </content>
        </xsl:variable>
        <xsl:variable name="tempData2">
            <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
        </xsl:variable>
        <!--<xsl:message>getXmlDataFromLayout ====<xsl:copy-of select="$tempData2"/></xsl:message>-->
        <xsl:copy-of select="$tempData2"/>
    </xsl:function>

    <xsl:function name="svtx:getXmlDataFromP1">
        <xsl:param name="layoutId"/>
        <xsl:message>getXmlDataFromP1 layoutId ====<xsl:value-of select="$layoutId"/>====
        </xsl:message>
        <xsl:variable name="currentAsset" select="cs:get-asset(xs:long($layoutId))" as="element(asset)?"/>
        <!-- Alle Child Elements -->
        <xsl:variable name="child_asset_element_rel" select="$currentAsset/child_asset_element_rel"
                      as="element(child_asset_element_rel)*"/>
        <!--
        <xsl:message>getXmlDataFromLayout layoutId====<xsl:copy-of  select="$child_asset_element_rel"/>====</xsl:message>
        -->

        <xsl:variable name="productId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Produktbeschreibung')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="benefitsId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Vorteile')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="functionGraphId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Funktionsgrafik')])[1]/@child_asset"
                      as="xs:long?"/>
        <!--    <xsl:message>getXmlDataFromLayout productId ====<xsl:value-of select="$productId"/>====</xsl:message>
            <xsl:message>getXmlDataFromLayout benefistId ====<xsl:value-of select="$benefitsId"/>====</xsl:message>
            <xsl:message>getXmlDataFromLayout functionGraphId ====<xsl:value-of select="$functionGraphId"/>====</xsl:message>-->
        <xsl:variable name="product">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($productId))"/>
        </xsl:variable>
        <xsl:variable name="benefits">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($benefitsId))"/>
        </xsl:variable>
        <xsl:variable name="functionGraph">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($functionGraphId))"/>
        </xsl:variable>
        <xsl:variable name="tempData">
            <content>
                <xsl:copy-of select="$product/article/content/headline"/>
                <xsl:copy-of select="$product/article/content/body"/>
                <xsl:copy-of select="$benefits/article/content/headline"/>
                <xsl:copy-of select="$benefits/article/content/body"/>
                <globalfootnotes>
                    <xsl:if test="$product/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($product/article/content/footnote,' ')"/>
                    </xsl:if>
                    <xsl:if test="$benefits/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($benefits/article/content/footnote,' ')"/>
                    </xsl:if>
                    <xsl:if test="$functionGraph/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($functionGraph/article/content/footnote,' ')"/>
                    </xsl:if>
                </globalfootnotes>
            </content>
        </xsl:variable>
        <xsl:variable name="tempData2">
            <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
        </xsl:variable>
        <xsl:message>getXmlDataFromP1 ====
            <xsl:copy-of select="$tempData2"/>
        </xsl:message>
        <xsl:copy-of select="$tempData2"/>
    </xsl:function>


    <xsl:function name="svtx:getXmlDataFromP2">
        <xsl:param name="layoutId"/>
        <xsl:message>getXmlDataFromP2 layoutId ====<xsl:value-of select="$layoutId"/>====
        </xsl:message>
        <xsl:variable name="currentAsset" select="cs:get-asset(xs:long($layoutId))" as="element(asset)?"/>
        <!-- Alle Child Elements -->
        <xsl:variable name="child_asset_element_rel" select="$currentAsset/child_asset_element_rel"
                      as="element(child_asset_element_rel)*"/>


        <xsl:variable name="productDetailsId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Produktdetails')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="targetGroupId"
                      select="($child_asset_element_rel[contains(@url,';group-name=Zielgruppenmodul')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="flexiGroupId"
                      select="($child_asset_element_rel[contains(@url,';group-name=twoPagerSnippet')])[1]/@child_asset"
                      as="xs:long?"/>
        <xsl:variable name="strengthsId"
                      select="($child_asset_element_rel[contains(@url,';group-name=St%C3%A4rken')])[1]/@child_asset"
                      as="xs:long?"/>

        <!--    <xsl:message>getXmlDataFromP2 productDetailsId ====<xsl:value-of select="$productDetailsId"/>====</xsl:message>
            <xsl:message>getXmlDataFromP2 targetGroupId ====<xsl:value-of select="$targetGroupId"/>====</xsl:message>
            <xsl:message>getXmlDataFromP2 strengthsId ====<xsl:value-of select="$strengthsId"/>====</xsl:message>
            <xsl:message>getXmlDataFromP2 FLEXI ====<xsl:value-of select="$flexiGroupId"/>====</xsl:message>-->

        <xsl:variable name="productDetails">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($productDetailsId))"/>
        </xsl:variable>
        <xsl:variable name="targetGroup">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($targetGroupId))"/>
        </xsl:variable>
        <xsl:variable name="flexi">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($flexiGroupId))"/>
        </xsl:variable>
        <xsl:variable name="strengths">
            <xsl:copy-of select="svtx:getContentXml(cs:get-asset($strengthsId))"/>
        </xsl:variable>
        <xsl:variable name="tempData">
            <content>
                <xsl:copy-of select="$productDetails/article/content/headline"/>
                <xsl:copy-of select="$productDetails/article/content/table"/>
                <xsl:copy-of select="$targetGroup/article/content/headline"/>
                <xsl:copy-of select="$targetGroup/article/content/body"/>
                <xsl:copy-of select="$flexi/article/content/headline"/>
                <xsl:copy-of select="$flexi/article/content/body"/>
                <xsl:copy-of select="$strengths/article/content/headline"/>
                <xsl:copy-of select="$strengths/article/content/body"/>
                <!--<xsl:copy-of select="$strengths/article/content/body"/>-->
                <xsl:copy-of select="$strengths/article/content/seals/seal[1]"/>
                <xsl:copy-of select="$strengths/article/content/seals/seal[2]"/>

                <globalfootnotes>
                    <xsl:if test="$productDetails/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($productDetails/article/content/footnote,' ')"/>
                    </xsl:if>
                    <xsl:if test="$targetGroup/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($targetGroup/article/content/footnote,' ')"/>
                    </xsl:if>
                    <xsl:if test="$strengths/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($strengths/article/content/footnote,' ')"/>
                    </xsl:if>
                    <xsl:if test="$flexi/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($flexi/article/content/footnote,' ')"/>
                    </xsl:if>
                    <!--- Entfällt, das ja ein eigenes Feld
                    <xsl:if test="$strengths/article/content/footnote[text()]">
                        <xsl:copy-of select="concat($strengths/article/content/footnote,' ')"/>
                    </xsl:if>
                    -->
                </globalfootnotes>
            </content>
        </xsl:variable>
        <xsl:variable name="tempData2">
            <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
        </xsl:variable>
        <xsl:message>getXmlDataFromP2 ====<xsl:copy-of select="$tempData2"/></xsl:message>
        <xsl:copy-of select="$tempData2"/>
    </xsl:function>


  <xsl:function name="svtx:getXmlDataFromLayoutFlyerBuB">
    <xsl:param name="layoutId"/>
    <xsl:variable name="currentAsset" select="cs:get-asset(xs:long($layoutId))" as="element(asset)?"/>
    <!-- Alle Child Elements -->
    <xsl:variable name="child_asset_element_rel" select="$currentAsset/child_asset_element_rel"
                  as="element(child_asset_element_rel)*"/>
    <xsl:variable name="productId"
                  select="($child_asset_element_rel[contains(@url,';group-name=WasIst')])[1]/@child_asset"
                  as="xs:long?"/>
    <xsl:variable name="casestudyId"
                  select="($child_asset_element_rel[contains(@url,';group-name=Keyfacts')])[1]/@child_asset"
                  as="xs:long?"/>
    <xsl:variable name="product">
      <xsl:copy-of select="svtx:getContentXml(cs:get-asset($productId))"/>
    </xsl:variable>
    <xsl:variable name="casestudy">
      <xsl:copy-of select="svtx:getContentXml(cs:get-asset($casestudyId))"/>
    </xsl:variable>

    <xsl:variable name="tempData">
      <content>
        <xsl:copy-of select="$product/article/content/headline"/>
        <xsl:copy-of select="$product/article/content/body"/>
        <xsl:copy-of select="$casestudy/article/content/headline"/>
        <!-- fallbeispiel content xml hat sich geändert, es wird eine tabelle nun benutzt. Body lasse ich vorerst drin-->
        <xsl:copy-of select="$casestudy/article/content/body/bullet-list"/>

        <globalfootnotes>
          <xsl:if test="$product/article/content/footnote[text()]">
            <xsl:copy-of select="concat($product/article/content/footnote,' ')"/>
          </xsl:if>
          <xsl:if test="$casestudy/article/content/footnote[text()]">
            <xsl:copy-of select="concat($casestudy/article/content/footnote,' ')"/>
          </xsl:if>
        </globalfootnotes>
      </content>
    </xsl:variable>
    <xsl:variable name="tempData2">
      <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
    </xsl:variable>
    <xsl:copy-of select="$tempData2"/>
  </xsl:function>


  <xsl:function name="svtx:getXmlDataFromReasonsFlexiModule">
    <xsl:param name="layoutId"/>
    <xsl:variable name="currentAsset" select="cs:get-asset(xs:long($layoutId))" as="element(asset)?"/>
    <!-- Alle Child Elements -->
    <xsl:variable name="child_asset_element_rel" select="$currentAsset/child_asset_element_rel"
                  as="element(child_asset_element_rel)*"/>
    <xsl:variable name="gründeId"
                  select="($child_asset_element_rel[contains(@url,';group-name=Gr%C3%BCnde')])[1]/@child_asset"
                  as="xs:long?"/>
    <xsl:variable name="flyerSnippetId"
                  select="($child_asset_element_rel[contains(@url,';group-name=flyerSnippet')])[1]/@child_asset"
                  as="xs:long?"/>
    <xsl:variable name="gründe">
      <xsl:copy-of select="svtx:getContentXml(cs:get-asset($gründeId))"/>
    </xsl:variable>
    <xsl:variable name="flexiModule">
      <xsl:copy-of select="svtx:getContentXml(cs:get-asset($flyerSnippetId))"/>
    </xsl:variable>

    <xsl:variable name="tempData">
      <content>
        <!--<xsl:copy-of select="$gründe/article/content/headline"/>-->
        <xsl:copy-of select="$gründe/article/content/body"/>
        <xsl:copy-of select="$flexiModule/article/content/headline"/>
        <!-- fallbeispiel content xml hat sich geändert, es wird eine tabelle nun benutzt. Body lasse ich vorerst drin-->
        <xsl:copy-of select="$flexiModule/article/content/body"/>

        <globalfootnotes>
          <xsl:if test="$gründe/article/content/footnote[text()]">
            <xsl:copy-of select="concat($gründe/article/content/footnote,' ')"/>
          </xsl:if>
          <xsl:if test="$flexiModule/article/content/footnote[text()]">
            <xsl:copy-of select="concat($flexiModule/article/content/footnote,' ')"/>
          </xsl:if>
        </globalfootnotes>
      </content>
    </xsl:variable>

    <xsl:message>
      TEMP
      <xsl:copy-of select="$gründe"/>
    </xsl:message>
    <xsl:variable name="tempData2">
      <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
    </xsl:variable>
    <xsl:copy-of select="$tempData2"/>
  </xsl:function>


  <xsl:function name="svtx:groupedFootnotesFlyerBub">
    <xsl:param name="layoutId"/>
    <xsl:variable name="tmpContent"  select="svtx:getXmlDataFromLayoutFlyerBuB($layoutId)" />
    <xsl:copy-of select="svtx:groupedFootnotes($tmpContent)" copy-namespaces="no"/>
  </xsl:function>

  <xsl:function name="svtx:groupedFootnotesFromLayout">
    <xsl:param name="layoutId"/>
    <xsl:variable name="tmpContent"  select="svtx:getXmlDataFromLayout($layoutId)" />
    <xsl:copy-of select="svtx:groupedFootnotes($tmpContent)" copy-namespaces="no"/>
  </xsl:function>

  <xsl:function name="svtx:groupedFootnotesFromLayoutFlyerBuBKeyfactsWhatIs">
    <xsl:param name="layoutId"/>
    <xsl:variable name="tmpContent"  select="svtx:getXmlDataFromLayoutFlyerBuB($layoutId)" />
    <xsl:copy-of select="svtx:groupedFootnotes($tmpContent)" copy-namespaces="no"/>
  </xsl:function>

  <xsl:function name="svtx:groupedFootnotesFromLayoutFlyerBuBReasonsFlexiModule">
    <xsl:param name="layoutId"/>
    <xsl:variable name="tmpContent"  select="svtx:getXmlDataFromReasonsFlexiModule($layoutId)" />
    <xsl:copy-of select="svtx:groupedFootnotes($tmpContent)" copy-namespaces="no"/>
  </xsl:function>


  <xsl:function name="svtx:groupedFootnotesFromP2">
    <xsl:param name="layoutId"/>
    <xsl:variable name="tmpContent"  select="svtx:getXmlDataFromP2($layoutId)" />
    <xsl:copy-of select="svtx:groupedFootnotes($tmpContent)" copy-namespaces="no"/>
  </xsl:function>

  <xsl:function name="svtx:groupedFootnotesFromP1">
    <xsl:param name="layoutId"/>
    <xsl:variable name="tmpContent"  select="svtx:getXmlDataFromP1($layoutId)" />
    <xsl:copy-of select="svtx:groupedFootnotes($tmpContent)" copy-namespaces="no"/>
  </xsl:function>

  <!-- Liefert für den Fussnotentext die Nummer -->
  <xsl:function name="svtx:getFootnoteNumber">
    <xsl:param name="groupedFootnotes"/>
    <xsl:param name="toSearch"/><!--<sup><xsl:value-of  select="if ($groupedFootnotes/footnotes/footnote[text()=$toSearch]) then $groupedFootnotes/footnotes/footnote[text()=$toSearch]/@no else 'nada'" /></sup>-->
      <xsl:variable name="tempData">
      <xsl:for-each select="$groupedFootnotes/footnotes/footnote"><xsl:if test=". = $toSearch"><sup><xsl:value-of  select="./@no"/></sup></xsl:if></xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="$tempData"/>
  </xsl:function>


  <!-- todo: maybe restrict, if its currently checked out by a system user -->
  <xsl:function name="svtx:getCheckedOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="if (exists($asset) and $asset/@checked_out_by) then cs:get-asset($asset/@id, 0, -2) else $asset"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:isSystemUser" as="xs:boolean">
    <xsl:param name="id" as="xs:long?"/>
    <xsl:value-of select="cs:master-data('party')[@id=$id]/@issystem = 1"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getAssetIdFromCenshareUrl" as="xs:string?">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:value-of select="substring-after($url, 'censhare:///service/assets/asset/id/')"/>
  </xsl:function>

  <!-- -->
  <xsl:template name="svtx:getMainContentAsset" as="element(asset)?">
    <xsl:param name="size" select="()" as="xs:string?"/> <!-- s = text.si,m,l  default: none-->
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="textType" select="svtx:getTextTypeBySize($size)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="starts-with($asset/@type, 'article.')">
        <xsl:copy-of select="($asset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type=$textType])[1]"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getTextTypeBySize" as="xs:string">
    <xsl:param name="size" as="xs:string?"/> <!-- s,m,l,xl -->
    <xsl:variable name="lcs" select="lower-case($size)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$lcs eq 's'">
        <xsl:value-of select="'text.size-s.'"/>
      </xsl:when>
      <xsl:when test="$lcs eq 'm'">
        <xsl:value-of select="'text.size-m.'"/>
      </xsl:when>
      <xsl:when test="$lcs eq 'l'">
        <xsl:value-of select="'text.size-l.'"/>
      </xsl:when>
      <xsl:when test="$lcs eq 'xl'">
        <xsl:value-of select="'text.size-xl.'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'text.'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="svtx:getCSMappingStyle">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="style"/>
    <xsl:choose>
      <xsl:when test="$asset/@wf_id = 10 and $asset/@wf_step and not($asset/@wf_step = 30)"><xsl:value-of select="concat($style, '_Platzhalter')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$style"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

    <xsl:function name="svtx:getCSMappingStyleCD21">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="style"/>
        <xsl:choose>
            <xsl:when test="$asset/@wf_id = 10 and $asset/@wf_step and not($asset/@wf_step = (30,35)) and $style=''"><xsl:value-of select="'Platzhalter'"/></xsl:when>
            <xsl:when test="$asset/@wf_id = 10 and $asset/@wf_step and not($asset/@wf_step = (30,35)) and not($style='')"><xsl:value-of select="concat('Platzhalter_', $style)"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$style"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- -->
    <xsl:function name="svtx:checkOutAsset" as="element(asset)?">
        <xsl:param name="asset" as="element(asset)?"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckOut">
            <cs:param name="source">
                <xsl:copy-of select="$asset"/>
            </cs:param>
        </cs:command>
    </xsl:function>

    <!-- -->
    <xsl:function name="svtx:checkInAsset" as="element(asset)?">
        <xsl:param name="asset" as="element(asset)?"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckIn">
            <cs:param name="source">
                <xsl:copy-of select="$asset"/>
            </cs:param>
        </cs:command>
    </xsl:function>

    <!-- Alles für show/hide Layer -->


    <!-- Setzt schau nach, welche Layer sichtbar oder verdeckt sind und erzeugt das Rendercommand dafür
    -->

    <xsl:function name="svtx:hideShowStrengthPictureRenderCommand">
        <xsl:param name="strengthAsset"/>
        <!-- Bestimmung der Layerzustände -->
        <xsl:variable name="g1" select="if ($strengthAsset/article/content/seals/seal[1]/logo/@xlink:href) then true() else false()" />
        <xsl:variable name="g2" select="if ($strengthAsset/article/content/seals/seal[2]/logo/@xlink:href) then true() else false()" />
        <xsl:variable name="g3" select="if ($strengthAsset/article/content/picture/@xlink:href) then true() else false()" />
        <xsl:variable name="visibleLayerNames">
            <xsl:choose>
                <xsl:when test="$g2 and $g1">strengths_seal_1;strengths_seal_2</xsl:when>
                <xsl:when test="$g1">strengths_seal_1</xsl:when>
                <xsl:when test="$g3">strength_picture</xsl:when>
                <xsl:otherwise>strengths_default_picture</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="hiddenLayerNames">
            <xsl:choose>
                <xsl:when test="$g2 and $g1">strength_picture;strengths_default_picture</xsl:when>
                <xsl:when test="$g1">strengths_seal_2;strength_picture;strengths_default_picture</xsl:when>
                <xsl:when test="$g3">strengths_seal_1;strengths_seal_2;strengths_default_picture</xsl:when>
                <xsl:otherwise>strengths_seal_1;strengths_seal_2;strength_picture</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>showLayer====<xsl:value-of  select="$visibleLayerNames"/></xsl:message>
        <xsl:message>hideLayer====<xsl:value-of  select="$hiddenLayerNames"/></xsl:message>
        <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key = 'svtx:indesign.switch-more-layers']" as="xs:long?"/>

        <xsl:variable name="showHideRendercommand">
            <command document_ref_id="1" method="script" script_asset_id="{ $scriptId }">
                <param name="visibleLayerNames" value="{$visibleLayerNames}"/>
                <param name="hiddenLayerNames" value="{$hiddenLayerNames}"/>
            </command>
        </xsl:variable>
      <xls:copy-of select="$showHideRendercommand"/>
    </xsl:function>



    <xsl:function name="svtx:getMainContentMasterStorageXML">
        <xsl:param name="size"/> <!-- s = text.si,m,l  default: none-->
        <xsl:param name="asset"/>
        <xsl:variable name="textType" select="svtx:getTextTypeBySize($size)" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="starts-with($asset/@type, 'article.')">
                <xsl:variable name="masterAsset" select="($asset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type=$textType])[1]"/>
                 <xsl:if test="$masterAsset">
                     <!--
                      <xsl:variable name="masterStorage" select="$masterAsset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
                      <xsl:variable name="contentXml" select="svtx:getCheckedOutAsset($masterStorage)"/>
                      <xsl:copy-of select="$contentXml"/>
                      -->
                     <xsl:variable name="contentXml" select=" svtx:getContentXml($masterAsset)"/>
                     <xsl:copy-of select="$contentXml"/>
                 </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:function>

    <!-- Routinen um die Fussnoten zusammenzusetzen, die der Censhare Editor zerteilt -->

    <xsl:function name="svtx:getMergedFootnotes">
        <xsl:param name="xmlContent"/>
        <xsl:apply-templates select="$xmlContent" mode="mergefootnotes"/>
    </xsl:function>


    <!-- holt sich vom Text-Asset das ausgecheckte oder letze Text-Storage und merged die Fussnoten  -->
    <xsl:function name="svtx:getContentXMLWithMergedFootnotes">
        <xsl:param name="rootAsset"/>
        <xsl:variable name="currentAsset" select="svtx:getCheckedOutAsset($rootAsset)" as="element(asset)?"/>
        <xsl:variable name="masterStorage" select="$currentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:copy-of select="svtx:getMergedFootnotes($contentXml)"/>
    </xsl:function>



    <xsl:template match="footnote" mode="mergefootnotes" priority="1">
      <xsl:variable name="hasSub" select="svtx:hasSubEl(.)" as="xs:boolean"/>
      <xsl:variable name="prevEl" select="preceding-sibling::node()[1]"/>
      <xsl:variable name="nextEl" select="following-sibling::node()[1]"/>
      <xsl:if test="svtx:isFootEl($prevEl) = false() or (svtx:isFootEl($prevEl) = true() and svtx:hasSubEl($prevEl) = $hasSub )">
        <footnote>
          <xsl:copy-of select="node()"/>
          <xsl:if test="(svtx:isFootEl($nextEl) = true()  and svtx:hasSubEl($nextEl) != $hasSub)">
            <xsl:apply-templates select="following-sibling::node()[1]" mode="custom"/>
          </xsl:if>
        </footnote>
      </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()" mode="mergefootnotes" priority="0.1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="mergefootnotes"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="footnote" mode="custom">
      <xsl:variable name="hasSub" select="svtx:hasSubEl(.)" as="xs:boolean"/>
      <xsl:variable name="nextEl" select="following-sibling::node()[1]"/>
      <xsl:copy-of select="node()"/>
      <xsl:if test="(svtx:isFootEl($nextEl) = true()  and svtx:hasSubEl($nextEl) != $hasSub)">
        <xsl:apply-templates select="following-sibling::node()[1]" mode="custom"/>
      </xsl:if>
    </xsl:template>

    <xsl:function name="svtx:hasSubEl" as="xs:boolean*">
        <xsl:param name="el"/>
        <xsl:value-of select="exists($el/sub)"/>
    </xsl:function>

  <xsl:function name="svtx:isFootEl" as="xs:boolean">
    <xsl:param name="el"/>
    <xsl:value-of select="lower-case(local-name($el)) = 'footnote'"/>
  </xsl:function>

  <xsl:function name="svtx:stärkenContent">
    <xsl:param name="content"/>
    <xsl:variable name="tempData">
      <article>
        <content>
          <xsl:copy-of select="$content/article/content/headline"/>
          <xsl:copy-of select="$content/article/content/body"/>
          <seals>
            <xsl:copy-of select="$content/article/content/seals/seal[1]"/>
          </seals>
        </content>
      </article>
    </xsl:variable>
    <xsl:variable name="tempData2">
      <xsl:apply-templates select="$tempData" mode="mergefootnotes"/>
    </xsl:variable>
    <xsl:message>vorteileContentb ====<xsl:copy-of select="$content"/></xsl:message>
    <xsl:message>vorteileContent ====<xsl:copy-of select="$tempData2"/></xsl:message>
    <xsl:copy-of select="$tempData2"/>
  </xsl:function>

  <xsl:function name="svtx:getMainContentAsset">
    <xsl:param name="article" as="element(asset)?"/>
    <xsl:variable name="mainContent" select="$article/cs:child-rel()[@key='user.main-content.']" as="element(asset)?"/>
    <xsl:variable name="siMainContent" select="$mainContent/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:copy-of select="if ($siMainContent/@url) then doc($siMainContent/@url) else ()"/>
  </xsl:function>

  <xsl:function name="svtx:getURLofMainContent" as="xs:string?">
    <xsl:param name="article" as="element(asset)?"/>
    <xsl:variable name="content" select="svtx:getMainContentAsset($article)"/>
    <xsl:variable name="url" select="$content/article/content/calltoaction-link/@url" as="xs:string?"/>
    <xsl:value-of select="$url"/>
  </xsl:function>

  <xsl:function name="svtx:qrCodeSolutionOverviewCmd" as="element(command)?">
    <xsl:param name="article" as="element(asset)?"/>

    <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key='svtx:indesign.create-qr-code']" as="xs:long?"/>
    <xsl:variable name="content" select="svtx:getMainContentAsset($article)"/>
    <xsl:variable name="url" select="$content/article/content/calltoaction-link/@url" as="xs:string?"/>
    <xsl:variable name="headline" select="$content/article/content/calltoaction-link" as="xs:string?"/>
    <xsl:if test="$url and $scriptId and $headline">
      <command document_ref_id="1" method="script" script_asset_id="{$scriptId}">
        <param name="url" value="{$url}"/>
        <param name="boxName" value="lösungsübersicht_qrcode_bub"/>
      </command>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>




