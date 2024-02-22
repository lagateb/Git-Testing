<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

  <!-- ====================================== -->
  <!-- ============== Constants ============= -->
  <!-- ====================================== -->
  <!-- Domains -->
  <xsl:variable name="FLYER_GENERATOR_DOMAIN" select="'root.flyer-generator.'" as="xs:string"/>
  <!-- Types -->
  <xsl:variable name="PROFESSION_ASSET_TYPE" select="'profession.'" as="xs:string"/>
  <xsl:variable name="RISKGROUP_ASSET_TYPE" select="'spreadsheet.riskgroup.'" as="xs:string"/>
  <xsl:variable name="TEXT_ASSET_TYPE" select="'text.'" as="xs:string"/>
  <xsl:variable name="PICTURE_ASSET_TYPE" select="'picture.'" as="xs:string"/>

  <xsl:variable name="ARTICLE_PRODUCT_DESCRIPTION_ASSET_TYPE" select="'article.produktbeschreibung.'" as="xs:string"/>
  <xsl:variable name="ARTICLE_PRODUCT_BENEFIT_ASSET_TYPE" select="'article.vorteile.'" as="xs:string"/>
  <xsl:variable name="ARTICLE_PRODUCT_DETAILS_ASSET_TYPE" select="'article.productdetails.'" as="xs:string"/>
  <xsl:variable name="ARTICLE_PRODUCT_STRENGTHEN_ASSET_TYPE" select="'article.staerken.'" as="xs:string"/>
  <xsl:variable name="ARTICLE_PRODUCT_FLEXI_ASSET_TYPE" select="'article.flexi-module.'" as="xs:string"/>


  <xsl:variable name="TEXT_ONE_SIZE_ASSET_TYPE" select="'text.'" as="xs:string"/>
  <xsl:variable name="TEXT_S_ASSET_TYPE" select="'text.size-s.'" as="xs:string"/>
  <xsl:variable name="TEXT_M_ASSET_TYPE" select="'text.size-m.'" as="xs:string"/>

  <!-- Features -->
  <xsl:variable name="EXCEL_SHEET_INDEX_FEAT" select="'svtx:sheet-index'" as="xs:string"/>
  <xsl:variable name="PROFESSION_ID_FEAT" select="'svtx:job-id'" as="xs:string"/>
  <xsl:variable name="RISK_GROUP_REF_FEAT" select="'svtx:riskgroup-ref'" as="xs:string"/>
  <xsl:variable name="RISK_GROUP_CATEGORY_FEAT" select="'svtx:riskgroup-category'" as="xs:string"/>
  <xsl:variable name="TEXT_POSITION_FEAT" select="'svtx:leistungsbeschreibung'" as="xs:string"/>
  <xsl:variable name="MONTHLY_RENT_FEAT" select="'svtx:protection-police'" as="xs:string"/>
  <xsl:variable name="AGE_FEAT" select="'svtx:age'" as="xs:string"/>
  <xsl:variable name="CAPITAL_PAYMENT_FEAT" select="'svtx:capital-payment'" as="xs:string"/>
  <xsl:variable name="NET_CONTRIBUTION_FEAT" select="'svtx:net-contribution'" as="xs:string"/>
  <xsl:variable name="NET_CONTRIBUTION_WITH_PAYMENT_FEAT" select="'svtx:net-contribution-with-capital-payment'" as="xs:string"/>
  <xsl:variable name="NET_CONTRIBUTION_DIFFERENCE_FEAT" select="'svtx:net-contribution-difference'" as="xs:string"/>
  <xsl:variable name="PDF_RENDERING_PENDING" select="'svtx:profession-pdf-rendering-pending'" as="xs:string"/>

  <!-- Relations -->
  <xsl:variable name="PROFESSION_GROUP_REL" select="'user.'" as="xs:string"/>
  <!-- Mimetypes -->
  <xsl:variable name="EXCEL_MIME_TYPE" select="'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'" as="xs:string"/>
  <xsl:variable name="PDF_MIME_TYPE" select="'application/pdf'" as="xs:string"/>
  <!-- Assets -->
  <xsl:variable name="LAYOUT_RESOURCE_KEY" select="'svtx:flyer-generator.layout.ksp'" as="xs:string"/>
  <!-- Indesign Transformation -->
  <xsl:variable name="ICML_TRANSFORMATION" as="element(entry)*">
    <entry name="Header" key="svtx:xsl.indesign.flyer-generator.header.text.icml" uid="b550"/>
    <entry name="Text1" key="svtx:xsl.indesign.flyer-generator.textposition.text.icml" uid="b861"/>
    <entry name="Text2" key="svtx:xsl.indesign.flyer-generator.textposition.text.icml" uid="b883"/>
    <entry name="Text3" key="svtx:xsl.indesign.flyer-generator.textposition.text.icml" uid="b905"/>
    <entry name="Text1Picture" uid="b810"/>
    <entry name="Text2Picture" uid="b799"/>
    <entry name="Text3Picture" uid="b786"/>
    <entry name="HeaderPicture" uid="b553"/>
    <entry name="SampleCalculationHeader" key="svtx:xsl.indesign.flyer-generator.sample-calculation.header.text.icml" uid="b783"/>
    <entry name="SampleCalculation1" key="svtx:xsl.indesign.flyer-generator.sample-calculation.calculation.text.icml" uid="b717"/>
    <entry name="SampleCalculation2" key="svtx:xsl.indesign.flyer-generator.sample-calculation.calculation.text.icml" uid="b739"/>
    <entry name="SampleCalculation3" key="svtx:xsl.indesign.flyer-generator.sample-calculation.calculation.text.icml" uid="b761"/>
    <entry name="ProductDescriptionHeader" key="svtx:xsl.indesign.flyer-generator.product-description.text.icml" uid="b629"/>
    <entry name="ProductDescriptionBody" key="svtx:xsl.indesign.flyer-generator.product-description.text.icml" uid="b839"/>
    <entry name="ProductBenefitHeader" key="svtx:xsl.indesign.flyer-generator.product-benefits.text.icml" uid="b695"/>
    <entry name="ProductBenefitBody" key="svtx:xsl.indesign.flyer-generator.product-benefits.text.icml" uid="b651"/>
    <entry name="ProductDetailsHeader" key="svtx:xsl.indesign.flyer-generator.product-details.text.icml" uid="b1083"/>
    <entry name="ProductDetailsBody" key="svtx:xsl.indesign.flyer-generator.product-details.text.icml" uid="b1105"/>
    <entry name="ProductStrengthenHeader" key="svtx:xsl.indesign.flyer-generator.product-strengthen.text.icml" uid="b1060"/>
    <entry name="ProductStrengthenBody" key="svtx:xsl.indesign.flyer-generator.product-strengthen.text.icml" uid="b1038"/>
    <entry name="ProductStrengthenAccompanying" key="svtx:xsl.indesign.flyer-generator.product-strengthen.text.icml" uid="b1016"/>
    <entry name="ProductStrengthenLogo" uid="b986"/>
    <entry name="ProductFlexiHeader" key="svtx:xsl.indesign.flyer-generator.product-flexi.text.icml" uid="b1149"/>
    <entry name="ProductFlexiBody" key="svtx:xsl.indesign.flyer-generator.product-flexi.text.icml" uid="b1171"/>
    <entry name="ProductFlexiPicture" key="svtx:xsl.indesign.flyer-generator.product-flexi.text.icml" uid="b1174"/>
    <entry name="FootnotesPage1" key="svtx:xsl.indesign.flyer-generator.footnotes.text.icml" uid="b1350"/>
    <entry name="FootnotesPage2" key="svtx:xsl.indesign.flyer-generator.footnotes.text.icml" uid="b1296"/>
  </xsl:variable>


  <!-- ====================================== -->
  <!-- ============== Functions ============= -->
  <!-- ====================================== -->

  <!-- -->
  <xsl:function name="svtx:rendererIsAvailable" as="xs:boolean">
    <xsl:variable name="execute-result" as="element(result)?">
      <cs:command name="com.censhare.api.Command.execute" returning="cmd">
        <cs:param name="source">
          <cmd timeout="1000">
            <cmd-info name="renderer.check-renderer-available"/>
            <commands currentstep="0">
              <command target="ScriptletManager" scriptlet="modules.renderer.RendererAvailabilityCheck" method="check"/>
            </commands>
            <result rendererAvailable="false"/>
          </cmd>
        </cs:param>
        <cs:param name="timeout" select="1000"/>
      </cs:command>
      <xsl:copy-of select="$cmd/result"/>
    </xsl:variable>
    <xsl:value-of select="if (exists($execute-result/@rendererAvailable)) then $execute-result/@rendererAvailable else false()"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getContentFootnotes" as="element(footnote)*">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:variable name="footnotes" as="element(footnote)*">
      <xsl:for-each select="$asset">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$contentXml">
          <xsl:copy-of select="$contentXml/article/content/*[local-name()=('table', 'body')]//footnote"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$footnotes">
      <xsl:copy>
        <xsl:value-of select="//text()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getContentFootnotes" as="element(footnote)*">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:param name="xml-node" as="xs:string?"/> <!-- table, body, etc -->
    <xsl:variable name="footnotes" as="element(footnote)*">
      <xsl:for-each select="$asset">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$contentXml">
          <xsl:copy-of select="$contentXml/article/content/*[local-name()=$xml-node]//footnote"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$footnotes">
      <xsl:copy>
        <xsl:value-of select="//text()"/>
      </xsl:copy>
    </xsl:for-each>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getStaticContentFootnotes" as="element(footnote)*">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:variable name="footnotes" as="element(footnote)*">
      <xsl:for-each select="$asset">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$contentXml">
          <xsl:copy-of select="$contentXml/article/content/footnote"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$footnotes">
      <xsl:variable name="textContent" select="//text()"/>
      <xsl:if test="$textContent">
        <xsl:copy>
          <xsl:value-of select="$textContent"/>
        </xsl:copy>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>



  <!-- -->
  <xsl:function name="svtx:countContentFootnotes" as="xs:long?">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:variable name="footnotes" as="xs:integer*">
      <xsl:for-each select="$asset">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$contentXml">
          <xsl:value-of select="count($contentXml/article/content/*[local-name()=('table', 'body')]//footnote)"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="if (exists($footnotes)) then xs:long(sum($footnotes)) else 0"/>
  </xsl:function>

  <!-- param asset = profession.-->
  <xsl:function name="svtx:findPlacementProduct">
    <xsl:param name="asset"/>
    <xsl:if test="$asset/@id">
      <xsl:variable name="query" as="element(query)">
        <query type="asset" limit="1">
          <condition name="censhare:asset.type" value="product.*"/>
          <relation target="parent" type="user.product.*">
            <target>
              <condition name="censhare:asset.type" value="product.*"/>
              <relation target="child" type="target.*">
                <target>
                  <condition name="censhare:asset.type" value="group.*"/>
                  <relation target="child" type="user.*">
                    <target>
                      <condition name="censhare:asset.id" value="{$asset/@id}"/>
                      <condition name="censhare:asset.type" value="profession."/>
                    </target>
                  </relation>
                </target>
              </relation>
            </target>
          </relation>
        </query>
      </xsl:variable>
      <xsl:copy-of select="cs:asset($query)[1]"/>
    </xsl:if>
  </xsl:function>

  <!-- param asset = product. -->
  <xsl:function name="svtx:findMainText">
    <xsl:param name="asset"/>
    <xsl:param name="articleType"/> <!-- article.produktbeschreibung. -->
    <xsl:param name="textType"/> <!--text.-->

    <xsl:if test="$asset/@id and $textType castable as xs:string">
      <xsl:variable name="query" as="element(query)">
        <query type="asset" limit="1">
          <condition name="censhare:asset.type" value="{$textType}"/>
          <relation target="parent" type="user.main-content.">
            <target>
              <condition name="censhare:asset.type" value="{$articleType}"/>
              <relation target="parent" type="user.">
                <target>
                  <condition name="censhare:asset.type" value="product.*"/>
                  <condition name="censhare:asset.id" value="{$asset/@id}"/>
                </target>
              </relation>
            </target>
          </relation>
        </query>
      </xsl:variable>
      <xsl:copy-of select="cs:asset($query)[1]"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:setRenderFlagIfNotExist">
    <xsl:param name="asset"/>
    <xsl:if test="not($asset/asset_feature[@feature=$PDF_RENDERING_PENDING]/@value_long = 1)">
      <cs:command name="com.censhare.api.assetmanagement.UpdateWithLock">
        <cs:param name="source">
          <asset>
            <xsl:copy-of select="$asset/@*"/>
            <xsl:copy-of select="$asset/node() except $asset/asset_feature[@feature=$PDF_RENDERING_PENDING]"/>
            <asset_feature feature="{$PDF_RENDERING_PENDING}" value_long="1"/>
          </asset>
        </cs:param>
      </cs:command>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getPreviousAsset">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:variable name="version" select="$asset/@version" as="xs:long?"/>
    <xsl:if test="$asset and $version">
      <xsl:copy-of select="cs:get-asset($asset/@id, $version - 1)"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:formatNumberInteger">
    <xsl:param name="num"/>
    <xsl:value-of select="cs:localized-format-number('de', $num, '#,##0')"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:formatNumberDecimal">
    <xsl:param name="num"/>
    <xsl:value-of select="cs:localized-format-number('de', $num, '#,##0.00')"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getElementIdx" as="xs:long?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:param name="key" as="xs:string?"/>
    <xsl:variable name="storage" select="$asset/storage_item[@key=$key]" as="element(storage_item)?"/>
    <xsl:if test="exists($storage)">
      <xsl:value-of select="$storage/@element_idx"/>
    </xsl:if>
  </xsl:function>


  <!-- -->
  <xsl:function name="svtx:getContentPicture" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:param name="type" as="xs:string?"/> <!-- picture or logo, mandatory-->
    <xsl:variable name="masterStorage" select="$asset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
    <xsl:variable name="xmlContent" select="if ($masterStorage/@url) then doc($masterStorage/@url) else ()"/>
    <xsl:if test="exists($xmlContent)">
      <xsl:variable name="ref" as="xs:string?">
        <xsl:choose>
          <xsl:when test="lower-case($type) eq 'picture'">
            <xsl:value-of select="$xmlContent/article/content/picture[1]/@xlink:href"/>
          </xsl:when>
          <xsl:when test="lower-case($type) eq 'logo'">
            <xsl:value-of select="$xmlContent/article/content/logo-1[1]/@xlink:href"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="id" select="substring-after($ref, 'censhare:///service/assets/asset/id/')"/>
      <xsl:if test="exists($id) and $id castable as xs:long">
        <xsl:copy-of select="cs:get-asset(xs:long($id))"/>
      </xsl:if>
    </xsl:if>
  </xsl:function>

  <!-- -->

  <!-- -->
  <xsl:function name="svtx:getCheckedOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="if (exists($asset) and $asset/@checked_out_by) then cs:get-asset($asset/@id, 0, -2) else $asset"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getTransformation" as="xs:string?">
    <xsl:param name="name" as="xs:string?"/>
    <xsl:value-of select="$ICML_TRANSFORMATION[lower-case(@name) eq lower-case($name)]/@key"/>
  </xsl:function>

  <!---->
  <xsl:function name="svtx:getBoxUid" as="xs:string?">
    <xsl:param name="name" as="xs:string?"/>
    <xsl:value-of select="$ICML_TRANSFORMATION[lower-case(@name) eq lower-case($name)]/@uid"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:castToDouble" as="xs:double?">
    <xsl:param name="anything"/>
    <xsl:if test="$anything castable as xs:double">
      <xsl:value-of select="xs:double($anything)"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:castToLong" as="xs:long?">
    <xsl:param name="anything"/>
    <xsl:variable name="double" select="svtx:castToDouble($anything)" as="xs:double?"/>
    <xsl:if test="$double castable as xs:long">
      <xsl:value-of select="xs:long($double)"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getExcelSheetIndex" as="xs:long?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="index" select="$asset/asset_feature[@feature eq $EXCEL_SHEET_INDEX_FEAT]/@value_long" as="xs:long?"/>
    <xsl:if test="exists($index)">
      <xsl:value-of select="$index"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:hasExcelStorage" as="xs:boolean">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="si" select="$asset/storage_item[@key='master' and @mimetype=$EXCEL_MIME_TYPE]" as="element(storage_item)?"/>
    <xsl:value-of select="exists($si)"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getExcelData">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:param name="idx" as="xs:long?"/>
    <xsl:variable name="si" select="$asset/storage_item[@key='master' and @mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']" as="element(storage_item)?"/>
    <xsl:if test="$si and $idx castable as xs:long">
      <cs:command name="com.censhare.api.Office.ReadExcel">
        <cs:param name="source" select="$si"/>
        <cs:param name="sheet-index" select="xs:string($idx)"/>
      </cs:command>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:checkInNew" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
      <cs:param name="source">
        <xsl:copy-of select="$asset"/>
      </cs:param>
    </cs:command>
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

  <!-- param asset: product -->
  <xsl:function name="svtx:getRiskGroupAssets" as="element(asset)*">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="$asset/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type=$RISKGROUP_ASSET_TYPE]"/>
  </xsl:function>

  <!-- param asset: risk group -->
  <xsl:function name="svtx:findRiskGroupByKey" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:param name="riskGroup" as="xs:string?"/>
    <xsl:if test="$riskGroup">
      <xsl:copy-of select="$asset[asset_feature[@feature=$RISK_GROUP_CATEGORY_FEAT and @value_key=lower-case($riskGroup)]][1]"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getTextPosition" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:param name="text" as="xs:string?"/>
    <xsl:if test="$text">
      <xsl:copy-of select="$asset[asset_feature[@feature=$TEXT_POSITION_FEAT and @value_string=$text]][1]"/>
    </xsl:if>
  </xsl:function>

  <!-- param asset: texts -->
  <xsl:function name="svtx:getTextPositions" as="element(asset)*">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:param name="text1" as="xs:string?"/>
    <xsl:param name="text2" as="xs:string?"/>
    <xsl:param name="text3" as="xs:string?"/>
    <xsl:copy-of select="(svtx:getTextPosition($asset, $text1), svtx:getTextPosition($asset, $text2), svtx:getTextPosition($asset, $text3))"/>
  </xsl:function>

  <!-- parm asset: professions -->
  <xsl:function name="svtx:getProfessionAssetById" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)*"/>
    <xsl:param name="id" as="xs:long?"/>
    <xsl:copy-of select="$asset[asset_feature[@feature=$PROFESSION_ID_FEAT and @value_long=$id]][1]"/>
  </xsl:function>

</xsl:stylesheet>
