<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="svtx_flyer.generator.v2.util.xsl" use-when="false()"/>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:template match="/asset[@type='profession.']">
    <xsl:variable name="profession" select="." as="element(asset)?"/>
    <xsl:variable name="professionGroup" select="($profession/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type='group.'])[1]" as="element(asset)?"/>
    <xsl:variable name="excelSheet" select="($professionGroup/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type='spreadsheet.'])[1]" as="element(asset)?"/>
    <xsl:variable name="product" select="($excelSheet/cs:child-rel()[@key='user.product.']/cs:asset()[@censhare:asset.type='product.*'])[1]" as="element(asset)?"/>
    <xsl:variable name="article" select="$product/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
    <xsl:variable name="layout" select="($excelSheet/cs:child-rel()[@key='user.layout.']/cs:asset()[@censhare:asset.type='layout.'])[1]" as="element(asset)?"/>
    <xsl:variable name="layoutStorageItem" select="$layout/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:variable name="mainPicture" select="($profession/cs:child-rel()[@key='user.main-picture.']/cs:asset()[@censhare:asset.type = 'picture.*'])[1]" as="element(asset)?"/>
    <xsl:variable name="riskGroup" select="$profession/asset_feature[@feature='svtx:flyer.generator.risk.group']/@value_string" as="xs:string?"/>
    <xsl:variable name="customerOffers" as="element(customer)*"/>
    <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="customerOffers">
      <cs:param name="key" select="'svtx:flyer.generator.v2.prices2xml'"/>
      <cs:param name="source" select="$excelSheet"/>
      <cs:param name="xsl-parameters">
        <cs:param name="risk-group" select="$riskGroup"/>
      </cs:param>
    </cs:command>
    <xsl:variable name="prices" as="element(prices)*">
      <xsl:for-each select="$customerOffers/customer">
        <xsl:variable name="p1" select="offer[@id=0 and @pension=1000]/@net"/>
        <xsl:variable name="p2" select="offer[@id=0 and @pension=2000]/@net"/>
        <xsl:variable name="p3" select="offer[@id=1 and @pension=1000]/@net"/>
        <xsl:variable name="p4" select="offer[@id=2 and @pension=1000]/@net"/>
        <xsl:if test="$p1 and $p2 and $p3 and $p4 and @age">
          <prices value="{string-join(($p1,$p2,$p3,$p4),',')}" age="{@age}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="$layoutStorageItem">
      <xsl:variable name="appVersion" select="concat('indesign-', $layoutStorageItem/@app_version)"/>
      <xsl:variable name="scriptCommand" as="element(command)">
        <command method="script" document_ref_id="1">
          <script language="javascript">
            try {
            var censhareTargetDocumentIndex = app.scriptArgs.getValue("censhareTargetDocumentIndex");
            var censhareTargetDocument = app.scriptArgs.getValue("censhareTargetDocument");
            var targetDocument;
            if (censhareTargetDocument != "") {
            targetDocument = app.documents.itemByID(parseInt(censhareTargetDocument));
            }
            else {
            targetDocument = app.documents.item(0);
            }
            var frame = targetDocument.pageItems.itemByID(479);
            if (frame.isValid) {
            var table = frame.tables[0];
            var rows = table.rows;
            while(frame.overflows) {
            var lastRow = rows.lastItem();
            lastRow.remove();
            }
            }
            }
            catch (err) {
            app.scriptArgs.setValue("censhareResult", err.description);
            }
          </script>
        </command>
      </xsl:variable>
      <xsl:variable name="staticCommands" as="element(command)*">
        <xsl:if test="$mainPicture">
          <command method="place" uid="b354" place_asset_id="{$mainPicture/@id}" is_manual_placement="false"  document_ref_id="1" >
            <xsl:attribute name="place_storage_key" select="'master'"/>
            <xsl:attribute name="place_asset_element_id" select="0"/>
          </command>
        </xsl:if>
        <!-- ### HEADER ###-->
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$profession/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.header'"/>
          <xsl:with-param name="uid" select="'b351'"/>
        </xsl:call-template>
        <!-- ### GRUNDFÄHIGKEITEN ###-->
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$profession/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.basic-skills.body'"/>
          <xsl:with-param name="uid" select="'b468'"/>
          <xsl:with-param name="params" select="'footnote-count=1'"/>
        </xsl:call-template>
        <!-- ### FUßNOTEN ###-->
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$profession/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.footnotes'"/>
          <xsl:with-param name="uid" select="'b490'"/>
        </xsl:call-template>
        <!-- ### PRODUKTBESCHREIBUNG ###-->
        <!--<xsl:variable name="productDescriptionTxt" select="svtx:getMainContentAsset($article[@type='article.produktbeschreibung.'])" as="element(asset)?"/>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productDescriptionTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-description.headline'"/>
          <xsl:with-param name="uid" select="'b409'"/>
        </xsl:call-template>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productDescriptionTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-description.body'"/>
          <xsl:with-param name="uid" select="'b431'"/>
        </xsl:call-template>-->
        <!-- ### PRODUKTDETAILS ###-->
        <!--<xsl:variable name="productDetailsTxt" select="svtx:getMainContentAsset($article[@type='article.productdetails.'])" as="element(asset)?"/>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productDetailsTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-details.headline'"/>
          <xsl:with-param name="uid" select="'b598'"/>
        </xsl:call-template>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productDetailsTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-details.body'"/>
          <xsl:with-param name="uid" select="'b620'"/>
        </xsl:call-template>-->
        <!-- ### STÄRKEN ###-->
        <!--<xsl:variable name="productStrengthenTxt" select="svtx:getMainContentAsset($article[@type='article.staerken.'])" as="element(asset)?"/>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productStrengthenTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-strengthen.headline'"/>
          <xsl:with-param name="uid" select="'b797'"/>
        </xsl:call-template>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productStrengthenTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-strengthen.body'"/>
          <xsl:with-param name="uid" select="'b819'"/>
        </xsl:call-template>
        <xsl:call-template name="build-place-command">
          <xsl:with-param name="placeAssetId" select="$productStrengthenTxt/@id"/>
          <xsl:with-param name="layoutId" select="$layout/@id"/>
          <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.product-strengthen.seal.body'"/>
          <xsl:with-param name="uid" select="'b841'"/>
        </xsl:call-template>
        <xsl:variable name="storage" select="$productStrengthenTxt/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
        <xsl:variable name="contentXml" select="if ($storage) then doc($storage/@url) else ()"/>
        <xsl:variable name="seal" select="$contentXml/article/content/seals/seal[1]/logo[1]" as="element(logo)?"/>
        <xsl:variable name="pictRef" select="$seal/@xlink:href" as="xs:string?"/>
        <xsl:variable name="pictId" select="tokenize($pictRef, '/')[last()]"/>
        <xsl:if test="$pictId and $pictId castable as xs:long">
          <command method="place" uid="b888" place_asset_id="{$pictId}" is_manual_placement="false"  document_ref_id="1" >
            <xsl:attribute name="place_storage_key" select="'master'"/>
            <xsl:attribute name="place_asset_element_id" select="$storage/@element_idx"/>
          </command>
        </xsl:if>-->
      </xsl:variable>
      <!-- todo: REPLACE -->
      <xsl:variable name="basicSkills" select="$rootAsset/cs:child-rel()[@key='user.basic-skills.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
      <xsl:variable name="selectableProtection" select="$rootAsset/cs:child-rel()[@key='user.selectable-protection.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
      <xsl:variable name="footnotes" as="element(footnote)*">
        <xsl:for-each select="($basicSkills, $selectableProtection)">
          <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
          <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
          <xsl:copy-of select="$contentXml/$contentXml/article/content/body//footnote"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="grouped" as="element(footnote)*">
        <xsl:for-each-group select="$footnotes" group-by="text()">
          <xsl:copy-of select="."/>
        </xsl:for-each-group>
      </xsl:variable>
      <xsl:for-each select="15 to 50">
        <xsl:variable name="age" select="." as="xs:long"/>
        <xsl:variable name="dynamicCommand" as="element(command)*">
          <xsl:call-template name="build-place-command">
            <xsl:with-param name="placeAssetId" select="$profession/@id"/>
            <xsl:with-param name="layoutId" select="$layout/@id"/>
            <xsl:with-param name="stylesheet" select="'svtx:flyer.generator.v2.icml.calculation'"/>
            <xsl:with-param name="uid" select="'b446'"/>
            <xsl:with-param name="params" select="concat('footnote-count=', (count($grouped)+3),';age=', $age, ';prices=', $prices[@age=$age][1]/@value)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="renderResult" as="element(cmd)">
          <cs:command name="com.censhare.api.Renderer.Render">
            <cs:param name="facility" select="$appVersion"/>
            <cs:param name="instructions">
              <cmd>
                <renderer>
                  <command method="open" asset_id="{$layout/@id}" document_ref_id="1"/>
                  <xsl:copy-of select="$staticCommands"/>
                  <xsl:copy-of select="$dynamicCommand"/>
                  <xsl:copy-of select="$scriptCommand"/>
                  <command method="pdf" spread="true" document_ref_id="1"/>
                  <command method="close" document_ref_id="1"/>
                </renderer>
                <assets>
                  <xsl:copy-of select="($layout, $profession)"/>
                  <xsl:for-each select="distinct-values(($staticCommands, $dynamicCommand)/@place_asset_id)">
                    <xsl:copy-of select="cs:get-asset(.)"/>
                  </xsl:for-each>
                </assets>
              </cmd>
            </cs:param>
          </cs:command>
        </xsl:variable>
        <xsl:variable name="pdfResult" select="$renderResult[@statename='completed all']/renderer/command[@method='pdf']" as="element(command)?"/>
        <xsl:if test="exists($pdfResult)">
          <xsl:variable name="childAssetRel" select="$rootAsset/child_asset_rel[@key='user.' and @sorting=$age][1]" as="element(child_asset_rel)?"/>
          <xsl:variable name="childAsset" select="if ($childAssetRel) then cs:get-asset($childAssetRel/@child_asset) else ()" as="element(asset)?"/>
          <xsl:choose>
            <xsl:when test="$childAsset and $childAsset/@type = 'document.'">
              <xsl:variable name="checkedOutAsset" select="svtx:checkOutAsset($childAsset)" as="element(asset)?"/>
              <xsl:variable name="newAssetXml">
                <asset>
                  <xsl:copy-of select="$checkedOutAsset/@*"/>
                  <xsl:copy-of select="$checkedOutAsset/node() except $checkedOutAsset/(asset_element, storage_item)"/>
                  <asset_element key="actual." idx="0"/>
                  <storage_item corpus:asset-temp-file-url="{svtx:getUrlOfRenderCmd($pdfResult)}" element_idx="0" key="master" mimetype="application/pdf" />
                </asset>
              </xsl:variable>
              <xsl:copy-of select="svtx:checkInAsset($newAssetXml)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="newAssetXml">
                <asset name="{$rootAsset/@name} - {$age} - PDF" type="document." domain="root.flyer-generator.v2.">
                  <asset_element key="actual." idx="0"/>
                  <parent_asset_rel key="user." parent_asset="{$rootAsset/@id}" sorting="{$age}"/>
                  <storage_item corpus:asset-temp-file-url="{svtx:getUrlOfRenderCmd($pdfResult)}" element_idx="0" key="master" mimetype="application/pdf" />
                </asset>
              </xsl:variable>
              <xsl:copy-of select="svtx:checkInNew($newAssetXml)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="position() mod 5 eq 0">
          <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
          </cs:command>
        </xsl:if>
      </xsl:for-each>
      <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
        <cs:param name="flush" select="true()"/>
      </cs:command>
      <xsl:variable name="freshProfession" select="cs:get-asset($profession/@id)" as="element(asset)?"/>
      <!-- update profession and delete render flag -->
      <xsl:variable name="assetXml" as="element(asset)">
        <asset>
          <xsl:copy-of select="$freshProfession/@*"/>
          <xsl:copy-of select="$freshProfession/* except $freshProfession/asset_feature[@feature='svtx:profession-pdf-rendering-pending']"/>
        </asset>
      </xsl:variable>
       <xsl:copy-of select="svtx:updateAsset($assetXml)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-place-command">
    <xsl:param name="placeAssetId" as="xs:long?"/>
    <xsl:param name="layoutId" as="xs:long?"/>
    <xsl:param name="uid" as="xs:string?"/>
    <xsl:param name="stylesheet" as="xs:string?"/>
    <xsl:param name="params" select="''" as="xs:string?"/>
    <xsl:if test="$placeAssetId and $layoutId and $uid and $stylesheet">
      <command method="place" place_asset_id="{$placeAssetId}" uid="{$uid}" is_manual_placement="false" document_ref_id="1">
        <transformation url="censhare:///service/assets/asset/id/{$placeAssetId}/transform;key={$stylesheet};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutId};time={current-dateTime()}{if ($params) then concat(';', $params) else ()}"/>
      </command>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>