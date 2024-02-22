<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <!-- ========== Imports ========== -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer-generator.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="svtx_flyer-generator.util.xsl" use-when="false()"/>

  <!-- ========== Param ========== -->
  <xsl:param name="age" select="21"/> <!-- mandatory -->
  <xsl:param name="calculations"> <!-- mandatory -->
    <!--<param>monthly-rent=1.000 €;age=20;capital-payment=12.000 €;net-contribution=39,29 €;net-contribution-difference=7,45 €;net-contribution-with-capital-payment=46,74 €</param>
    <param>monthly-rent=1.500 €;age=20;capital-payment=18.000 €;net-contribution=58,40 €;net-contribution-difference=11,18 €;net-contribution-with-capital-payment=69,58 €</param>
    <param>monthly-rent=2.000 €;age=20;capital-payment=24.000 €;net-contribution=77,51 €;net-contribution-difference=14,90 €;net-contribution-with-capital-payment=92,41 €</param>-->
  </xsl:param>

  <!-- ========== Globals ========== -->
  <xsl:variable name="layoutAsset" select="cs:asset()[@censhare:resource-key=$LAYOUT_RESOURCE_KEY]" as="element(asset)?"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="placeProduct" select="true()" as="xs:boolean"/>
  <xsl:variable name="debug" select="false()"/>

  <xsl:template match="/asset">
    <xsl:variable name="text1" select="(cs:child-rel()[@key='user.article-pos-1.']/cs:asset()[@censhare:asset.type='text.'])[1]" as="element(asset)?"/>
    <xsl:variable name="text1Picture" select="svtx:getContentPicture($text1, 'picture')" as="element(asset)?"/>
    <xsl:variable name="text2" select="(cs:child-rel()[@key='user.article-pos-2.']/cs:asset()[@censhare:asset.type='text.'])[1]" as="element(asset)?"/>
    <xsl:variable name="text2Picture" select="svtx:getContentPicture($text2, 'picture')" as="element(asset)?"/>
    <xsl:variable name="text3" select="(cs:child-rel()[@key='user.article-pos-3.']/cs:asset()[@censhare:asset.type='text.'])[1]" as="element(asset)?"/>
    <xsl:variable name="text3Picture" select="svtx:getContentPicture($text3, 'picture')" as="element(asset)?"/>
    <xsl:variable name="mainContentPicture" select="(cs:child-rel()[@key='user.main-picture.'])[1]" as="element(asset)?"/>

    <!-- product placement -->
    <xsl:variable name="mainProduct" select="svtx:findPlacementProduct($rootAsset)" as="element(asset)?"/>
    <xsl:variable name="productDescriptionText" select="svtx:findMainText($mainProduct, $ARTICLE_PRODUCT_DESCRIPTION_ASSET_TYPE, $TEXT_S_ASSET_TYPE)" as="element(asset)?"/>
    <xsl:variable name="productBenefitText" select="svtx:findMainText($mainProduct, $ARTICLE_PRODUCT_BENEFIT_ASSET_TYPE, $TEXT_S_ASSET_TYPE)" as="element(asset)?"/>
    <xsl:variable name="productDetailsText" select="svtx:findMainText($mainProduct, $ARTICLE_PRODUCT_DETAILS_ASSET_TYPE, $TEXT_S_ASSET_TYPE)" as="element(asset)?"/>
    <xsl:variable name="productStrengthenText" select="svtx:findMainText($mainProduct, $ARTICLE_PRODUCT_STRENGTHEN_ASSET_TYPE, $TEXT_S_ASSET_TYPE)" as="element(asset)?"/>
    <xsl:variable name="productStrengthenLogo" select="svtx:getContentPicture($productStrengthenText, 'logo')" as="element(asset)?"/>
    <xsl:variable name="productFlexiText" select="svtx:findMainText($mainProduct, $ARTICLE_PRODUCT_FLEXI_ASSET_TYPE, $TEXT_S_ASSET_TYPE)" as="element(asset)?"/>
    <xsl:variable name="productFlexiPicture" select="svtx:getContentPicture($productFlexiText, 'picture')" as="element(asset)?"/>


    <xsl:variable name="indesignStorageItem" select="$layoutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:if test="$indesignStorageItem and $debug = false()">
      <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)"/>
      <xsl:variable name="renderResult" as="element(cmd)">
        <cs:command name="com.censhare.api.Renderer.Render">
          <cs:param name="facility" select="$appVersion"/>
          <cs:param name="instructions">
            <cmd>
              <renderer>
                <command method="open" asset_id="{$layoutAsset/@id}" document_ref_id="1"/>

                <!-- ==================== -->
                <!-- JOB PLACEMENT        -->
                <!-- ==================== -->

                <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('Header')}" is_manual_placement="false" document_ref_id="1">
                  <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('Header')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()}"/>
                </command>


                <command method="place" place_asset_id="{$text1/@id}" uid="{svtx:getBoxUid('Text1')}" is_manual_placement="false" document_ref_id="1">
                  <xsl:variable name="preFootnotes" select="svtx:getContentFootnotes($productDescriptionText)"/>
                  <transformation url="censhare:///service/assets/asset/id/{$text1/@id}/transform;key={svtx:getTransformation('Text1')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};pre-footnotes={string-join($preFootnotes/text(), 'savotex_footnote')}"/>
                </command>

                <command method="place" place_asset_id="{$text2/@id}" uid="{svtx:getBoxUid('Text2')}" is_manual_placement="false" document_ref_id="1">
                  <xsl:variable name="preFootnotes" select="svtx:getContentFootnotes(($productDescriptionText, $text1))"/>
                  <transformation url="censhare:///service/assets/asset/id/{$text2/@id}/transform;key={svtx:getTransformation('Text2')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};pre-footnotes={string-join($preFootnotes/text(), 'savotex_footnote')}"/>
                </command>

                <command method="place" place_asset_id="{$text3/@id}" uid="{svtx:getBoxUid('Text3')}" is_manual_placement="false" document_ref_id="1">
                  <xsl:variable name="preFootnotes" select="svtx:getContentFootnotes(($productDescriptionText, $text1, $text2))"/>
                  <transformation url="censhare:///service/assets/asset/id/{$text3/@id}/transform;key={svtx:getTransformation('Text3')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};pre-footnotes={string-join($preFootnotes/text(), 'savotex_footnote')}"/>
                </command>

                <command method="place" uid="{svtx:getBoxUid('Text1Picture')}" place_asset_id="{$text1Picture/@id}" is_manual_placement="false"  document_ref_id="1" >
                  <xsl:attribute name="place_storage_key" select="'master'"/>
                  <xsl:attribute name="place_asset_element_id" select="svtx:getElementIdx($text1Picture, 'master')"/>
                </command>

                <command method="place" uid="{svtx:getBoxUid('Text2Picture')}" place_asset_id="{$text2Picture/@id}" is_manual_placement="false"  document_ref_id="1" >
                  <xsl:attribute name="place_storage_key" select="'master'"/>
                  <xsl:attribute name="place_asset_element_id" select="svtx:getElementIdx($text2Picture, 'master')"/>
                </command>

                <command method="place" uid="{svtx:getBoxUid('Text3Picture')}" place_asset_id="{$text3Picture/@id}" is_manual_placement="false"  document_ref_id="1" >
                  <xsl:attribute name="place_storage_key" select="'master'"/>
                  <xsl:attribute name="place_asset_element_id" select="svtx:getElementIdx($text3Picture, 'master')"/>
                </command>

                <xsl:if test="exists($mainContentPicture)">
                  <command method="place" uid="{svtx:getBoxUid('HeaderPicture')}" place_asset_id="{$mainContentPicture/@id}" is_manual_placement="false"  document_ref_id="1" >
                    <xsl:attribute name="place_storage_key" select="'master'"/>
                    <xsl:attribute name="place_asset_element_id" select="svtx:getElementIdx($mainContentPicture, 'master')"/>
                  </command>
                </xsl:if>

                <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('SampleCalculationHeader')}" is_manual_placement="false" document_ref_id="1">
                  <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('SampleCalculationHeader')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};age={$age}"/>
                </command>

                <xsl:if test="$calculations/param[1]/text()">
                  <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('SampleCalculation1')}" is_manual_placement="false" document_ref_id="1">
                    <!--<xsl:variable name="params" select="'monthly-rent=1.000 €;capital-payment=12.000 €;net-contribution=46,22 €;net-contribution-with-capital-payment=54,99 €;net-contribution-difference=8,77 €'"/>-->
                    <xsl:variable name="params" select="$calculations/param[1]/text()" as="xs:string?"/>
                    <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('SampleCalculation1')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$params}"/>
                  </command>
                </xsl:if>

                <xsl:if test="$calculations/param[2]/text()">
                  <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('SampleCalculation2')}" is_manual_placement="false" document_ref_id="1">
                    <!--<xsl:variable name="params" select="'monthly-rent=1.500 €;capital-payment=12.000 €;net-contribution=46,22 €;net-contribution-with-capital-payment=54,99 €;net-contribution-difference=8,77 €'"/>-->
                    <xsl:variable name="params" select="$calculations/param[2]/text()" as="xs:string?"/>
                    <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('SampleCalculation2')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$params}"/>
                  </command>
                </xsl:if>

                <xsl:if test="$calculations/param[3]/text()">
                  <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('SampleCalculation3')}" is_manual_placement="false" document_ref_id="1">
                    <!--<xsl:variable name="params" select="'monthly-rent=2.000 €;capital-payment=12.000 €;net-contribution=46,22 €;net-contribution-with-capital-payment=54,99 €;net-contribution-difference=8,77 €'"/>-->
                    <xsl:variable name="params" select="$calculations/param[3]/text()" as="xs:string?"/>
                    <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('SampleCalculation3')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$params}"/>
                  </command>
                </xsl:if>

                <!-- footnotes page 1 -->
                <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('FootnotesPage1')}" is_manual_placement="false" document_ref_id="1">
                  <xsl:variable name="staticFootnotes" select="svtx:getStaticContentFootnotes(($productDescriptionText, $text1, $text2, $text3, $productBenefitText))" as="element(footnote)*"/>
                  <xsl:variable name="footnotes" select="svtx:getContentFootnotes(($productDescriptionText, $text1, $text2, $text3, $productBenefitText))" as="element(footnote)*"/>
                  <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('FootnotesPage1')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};footnotes={string-join($footnotes/text(), 'savotex_footnote')};static-footnotes={string-join($staticFootnotes/text(), 'savotex_footnote')}"/>
                </command>

                <!-- footnotes page 2 -->
                <command method="place" place_asset_id="{$rootAsset/@id}" uid="{svtx:getBoxUid('FootnotesPage2')}" is_manual_placement="false" document_ref_id="1">
                  <xsl:variable name="staticFootnotes" select="svtx:getStaticContentFootnotes(($productDetailsText, $productFlexiText, $productStrengthenText))" as="element(footnote)*"/>
                  <xsl:variable name="footnotes" select="(svtx:getContentFootnotes(($productDetailsText, $productFlexiText, $productStrengthenText)), svtx:getContentFootnotes($productStrengthenText, 'accompanying-1'))" as="element(footnote)*"/>
                  <transformation url="censhare:///service/assets/asset/id/{$rootAsset/@id}/transform;key={svtx:getTransformation('FootnotesPage2')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};footnotes={string-join($footnotes/text(), 'savotex_footnote')};static-footnotes={string-join($staticFootnotes/text(), 'savotex_footnote')}"/>
                </command>

                <!-- ==================== -->
                <!-- PRODUCT PLACEMENT    -->
                <!-- ==================== -->
                <xsl:if test="$placeProduct">
                  <xsl:variable name="placeHeaderParam" select="'placement-part=headline'" as="xs:string"/>
                  <xsl:variable name="placeBodyParam" select="'placement-part=body'" as="xs:string"/>
                  <xsl:variable name="placeAccompanyingPart" select="'placement-part=accompanying'" as="xs:string"/>

                  <!-- product description part -->
                  <xsl:if test="exists($productDescriptionText)">
                    <!-- product description headline -->
                    <command method="place" place_asset_id="{$productDescriptionText/@id}" uid="{svtx:getBoxUid('ProductDescriptionHeader')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productDescriptionText/@id}/transform;key={svtx:getTransformation('ProductDescriptionHeader')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeHeaderParam}"/>
                    </command>
                    <!-- product description body -->
                    <command method="place" place_asset_id="{$productDescriptionText/@id}" uid="{svtx:getBoxUid('ProductDescriptionBody')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productDescriptionText/@id}/transform;key={svtx:getTransformation('ProductDescriptionBody')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeBodyParam}"/>
                    </command>
                  </xsl:if>

                  <!-- product benefit part -->
                  <xsl:if test="exists($productBenefitText)">
                    <!-- header -->
                    <command method="place" place_asset_id="{$productBenefitText/@id}" uid="{svtx:getBoxUid('ProductBenefitHeader')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productBenefitText/@id}/transform;key={svtx:getTransformation('ProductBenefitHeader')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeHeaderParam}"/>
                    </command>

                    <!-- body -->
                    <xsl:variable name="preFootnotes" select="svtx:getContentFootnotes(($productDescriptionText, $text1, $text2, $text3))"/>
                    <command method="place" place_asset_id="{$productBenefitText/@id}" uid="{svtx:getBoxUid('ProductBenefitBody')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productBenefitText/@id}/transform;key={svtx:getTransformation('ProductBenefitBody')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeBodyParam};pre-footnotes={string-join($preFootnotes/text(), 'savotex_footnote')}"/>"/>
                    </command>
                  </xsl:if>

                  <!-- product details part -->
                  <xsl:if test="exists($productDetailsText)">
                    <!-- header-->
                    <command method="place" place_asset_id="{$productDetailsText/@id}" uid="{svtx:getBoxUid('ProductDetailsHeader')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productDetailsText/@id}/transform;key={svtx:getTransformation('ProductDetailsHeader')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeHeaderParam}"/>
                    </command>
                    <!-- body -->
                    <command method="place" place_asset_id="{$productDetailsText/@id}" uid="{svtx:getBoxUid('ProductDetailsBody')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productDetailsText/@id}/transform;key={svtx:getTransformation('ProductDetailsBody')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeBodyParam}"/>
                    </command>
                  </xsl:if>

                  <!-- product flexi part -->
                  <xsl:if test="exists($productFlexiText)">
                    <!-- header -->
                    <command method="place" place_asset_id="{$productFlexiText/@id}" uid="{svtx:getBoxUid('ProductFlexiHeader')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productFlexiText/@id}/transform;key={svtx:getTransformation('ProductFlexiHeader')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeHeaderParam}"/>
                    </command>

                    <!-- body -->
                    <xsl:variable name="preFootnotes" select="svtx:getContentFootnotes($productDetailsText)"/>
                    <command method="place" place_asset_id="{$productFlexiText/@id}" uid="{svtx:getBoxUid('ProductFlexiBody')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productFlexiText/@id}/transform;key={svtx:getTransformation('ProductFlexiBody')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeBodyParam};pre-footnotes={string-join($preFootnotes/text(), 'savotex_footnote')}"/>
                    </command>

                    <!-- picture -->
                    <xsl:if test="exists($productFlexiPicture)">
                      <command method="place" uid="{svtx:getBoxUid('ProductFlexiPicture')}" place_asset_id="{$productFlexiPicture/@id}" is_manual_placement="false"  document_ref_id="1" >
                        <xsl:attribute name="place_storage_key" select="'master'"/>
                        <xsl:attribute name="place_asset_element_id" select="svtx:getElementIdx($productFlexiPicture, 'master')"/>
                      </command>
                    </xsl:if>
                  </xsl:if>

                  <!-- product strengthen part -->
                  <xsl:if test="exists($productStrengthenText)">
                    <!-- header -->
                    <command method="place" place_asset_id="{$productStrengthenText/@id}" uid="{svtx:getBoxUid('ProductStrengthenHeader')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productStrengthenText/@id}/transform;key={svtx:getTransformation('ProductStrengthenHeader')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeHeaderParam}"/>
                    </command>

                    <!-- body -->
                    <xsl:variable name="preFootnotes" select="svtx:getContentFootnotes(($productDetailsText, $productFlexiText))"/>
                    <command method="place" place_asset_id="{$productStrengthenText/@id}" uid="{svtx:getBoxUid('ProductStrengthenBody')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productStrengthenText/@id}/transform;key={svtx:getTransformation('ProductStrengthenBody')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeBodyParam};pre-footnotes={string-join($preFootnotes/text(), 'savotex_footnote')}"/>
                    </command>

                    <!-- Accompying-->
                    <xsl:variable name="preFootnotes2" select="svtx:getContentFootnotes(($productDetailsText, $productFlexiText, $productStrengthenText))"/>
                    <command method="place" place_asset_id="{$productStrengthenText/@id}" uid="{svtx:getBoxUid('ProductStrengthenAccompanying')}" is_manual_placement="false" document_ref_id="1">
                      <transformation url="censhare:///service/assets/asset/id/{$productStrengthenText/@id}/transform;key={svtx:getTransformation('ProductStrengthenAccompanying')};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()};{$placeAccompanyingPart};pre-footnotes={string-join($preFootnotes2/text(), 'savotex_footnote')}"/>
                    </command>

                    <!-- logo -->
                    <xsl:if test="exists($productStrengthenLogo)">
                      <command method="place" uid="{svtx:getBoxUid('ProductStrengthenLogo')}" place_asset_id="{$productStrengthenLogo/@id}" is_manual_placement="false"  document_ref_id="1" >
                        <xsl:attribute name="place_storage_key" select="'master'"/>
                        <xsl:attribute name="place_asset_element_id" select="svtx:getElementIdx($productStrengthenLogo, 'master')"/>
                      </command>
                    </xsl:if>
                  </xsl:if>
                </xsl:if>

                <command method="pdf" spread="true" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <xsl:copy-of select="$layoutAsset"/>
                <xsl:copy-of select="$rootAsset"/>
                <xsl:copy-of select="($text1, $text2, $text3)"/>
                <xsl:copy-of select="($text1Picture, $text2Picture, $text3Picture)"/>
                <xsl:copy-of select="$mainContentPicture"/>
                <xsl:if test="$placeProduct">
                  <xsl:copy-of select="($productDescriptionText, $productBenefitText, $productDetailsText, $productStrengthenText, $productStrengthenLogo, $productFlexiText, $productFlexiPicture)"/>
                </xsl:if>
              </assets>
            </cmd>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:variable name="pdfResult" select="$renderResult/renderer/command[@method eq 'pdf']" as="element(command)"/>

      <!-- RETURN RESULT -->
      <xsl:copy-of select="$pdfResult"/>

    </xsl:if>
  </xsl:template>

</xsl:stylesheet>