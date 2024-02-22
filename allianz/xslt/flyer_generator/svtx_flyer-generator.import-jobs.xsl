<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">

  <!-- ========== Imports ========== -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer-generator.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="svtx_flyer-generator.util.xsl" use-when="false()"/>

  <!-- ========== Globals ========== -->
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="professionGroupAsset" select="($rootAsset/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type='group.'])[1]" as="element(asset)?"/>
  <xsl:variable name="professionAssets" select="$professionGroupAsset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='profession.']" as="element(asset)*"/>
  <xsl:variable name="professionDescriptionAsset" select="($rootAsset/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type='article.'])[1]" as="element(asset)?"/>
  <xsl:variable name="professionDscriptionTextAssets" select="$professionDescriptionAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.']" as="element(asset)*"/>
  <xsl:variable name="riskGroupAssets" select="svtx:getRiskGroupAssets($rootAsset)" as="element(asset)*"/>
  <xsl:variable name="sheetIndex" select="svtx:getExcelSheetIndex($professionGroupAsset)" as="xs:long?"/>
  <xsl:variable name="cellIndexes" select="(0,1,2,5,6,7)" as="xs:long*"/><!-- need those cells in each row -->

  <!-- -->
  <xsl:template match="/asset[@type='product.']">
    <xsl:choose>
      <xsl:when test="svtx:hasExcelStorage($rootAsset) eq false()">
        <xsl:message>### SKIP UPDATE PROFESSION ### REASON ### No Excel Storage on <xsl:value-of select="$rootAsset/@id"/></xsl:message>
      </xsl:when>
      <xsl:when test="exists($professionGroupAsset) eq false()">
        <xsl:message>### SKIP UPDATE PROFESSION ### REASON ### No Job Group Asset found for <xsl:value-of select="$rootAsset/@id"/></xsl:message>
      </xsl:when>
      <xsl:when test="exists($professionDescriptionAsset) eq false()">
        <xsl:message>### SKIP UPDATE PROFESSION ### REASON ### No Profession Description Asset found for <xsl:value-of select="$rootAsset/@id"/></xsl:message>
      </xsl:when>
      <xsl:when test="exists($sheetIndex) eq false()">
        <xsl:message>### SKIP UPDATE PROFESSION ### REASON ### No Sheet Index found on Asset <xsl:value-of select="$rootAsset/@id"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          ### Prepare Update Jobs ###
          Product:<xsl:value-of select="$rootAsset/@id"/>
          Sheet Index: <xsl:value-of select="$sheetIndex"/>
          Profession Group: <xsl:value-of select="$professionGroupAsset/@id"/>
        </xsl:message>
        <xsl:apply-templates select="svtx:getExcelData($rootAsset, $sheetIndex)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- -->
  <xsl:template match="row">
    <!-- every row for given index needs content -->
    <xsl:variable name="hasValidCells" select="every $x in $cellIndexes satisfies exists(cell[@index=$x]/text())" as="xs:boolean"/>
    <!-- extract cell values to sequence of strings -->
    <xsl:variable name="content" as="xs:string*">
      <xsl:choose>
        <xsl:when test="@index le 2">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Row is Header </xsl:message>
        </xsl:when>
        <xsl:when test="$hasValidCells eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Some Cells are empty, expected content for indexes: <xsl:value-of select="$cellIndexes"/></xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="exists($content)">
      <xsl:variable name="id" select="$content[1]" as="xs:long?"/>
      <xsl:variable name="professionName" select="$content[2]" as="xs:string?"/>
      <xsl:variable name="riskGroupKey" select="$content[3]" as="xs:string?"/>
      <xsl:variable name="text1" select="$content[4]" as="xs:string?"/>
      <xsl:variable name="text2" select="$content[5]" as="xs:string?"/>
      <xsl:variable name="text3" select="$content[6]" as="xs:string?"/>
      <xsl:variable name="existingProfessionAsset" select="svtx:getProfessionAssetById($professionAssets, $id)" as="element(asset)?"/>
      <xsl:variable name="riskGroupAsset" select="svtx:findRiskGroupByKey($riskGroupAssets, $riskGroupKey)" as="element(asset)?"/>
      <xsl:variable name="textPositionAssets" select="svtx:getTextPositions($professionDscriptionTextAssets, $text1, $text2, $text3)" as="element(asset)*"/>
      <xsl:variable name="textPositionChildFeatures" as="element(child_asset_rel)*">
        <xsl:for-each select="$textPositionAssets">
          <child_asset_rel child_asset="{@id}" key="user.article-pos-{position()}."/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="exists($riskGroupAssets) eq false()">
          <xsl:message>### SKIP Creating Asset for Row <xsl:value-of select="@index"/> ### REASON ### Did not found Risk Group Asset for key: <xsl:value-of select="$riskGroupKey"/></xsl:message>
        </xsl:when>
        <xsl:when test="not(count($textPositionAssets) eq 3)">
          <xsl:message>### SKIP Creating Asset for Row <xsl:value-of select="@index"/> ### REASON ### Expected 3 Text Positons. Found <xsl:value-of select="count($textPositionAssets)"/></xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="exists($existingProfessionAsset)">
              <!-- update profession asset, if needed
                1. name changed
                2. text position Changed
                3. Risk Group Changed
              -->
              <xsl:variable name="nameIsEqual" select="$existingProfessionAsset/@name eq $professionName" as="xs:boolean"/>
              <xsl:variable name="textPositionsAreEqual" select="every $x in $textPositionChildFeatures satisfies ($x/@child_asset eq $existingProfessionAsset/child_asset_rel[@key eq $x/@key]/@child_asset)" as="xs:boolean"/>
              <xsl:variable name="riskGroupIsEqual" select="$existingProfessionAsset/asset_feature[@feature=$RISK_GROUP_REF_FEAT]/@value_asset_id = $riskGroupAsset/@id" as="xs:boolean"/>
              <xsl:if test="($nameIsEqual = false()) or ($textPositionsAreEqual = false()) or ($riskGroupIsEqual = false())">
                <xsl:message>
                  ### Asset <xsl:value-of select="$existingProfessionAsset/@id"/> needs Update!
                  ### Reason
                  Name is equal : <xsl:value-of select="$nameIsEqual"/>
                  Text-Positions are equal : <xsl:value-of select="$textPositionsAreEqual"/>
                  Rrisk Group is equal : <xsl:value-of select="$riskGroupIsEqual"/>
                </xsl:message>
                <xsl:variable name="checkedOutAsset" select="svtx:checkOutAsset($existingProfessionAsset)"/>
                <xsl:variable name="updatedAsset" as="element(asset)?">
                  <asset name="{$professionName}">
                    <xsl:copy-of select="$checkedOutAsset/@* except $checkedOutAsset/(@name)"/>
                    <xsl:copy-of select="$checkedOutAsset/node() except $checkedOutAsset/(child_asset_rel[starts-with(@key,'user.article-pos-')], asset_feature[@feature=($RISK_GROUP_REF_FEAT, $PDF_RENDERING_PENDING)])"/>
                    <xsl:copy-of select="$textPositionChildFeatures"/>
                    <xsl:if test="$riskGroupAsset">
                      <asset_feature feature="{$RISK_GROUP_REF_FEAT}" value_asset_id="{$riskGroupAsset/@id}"/>
                    </xsl:if>
                    <asset_feature feature="{$PDF_RENDERING_PENDING}" value_long="1"/>
                  </asset>
                </xsl:variable>
                <xsl:copy-of select="svtx:checkInAsset($updatedAsset)"/>
              </xsl:if>
            </xsl:when>
            <!-- check in new profession asset -->
            <xsl:otherwise>
              <xsl:variable name="newAsset" as="element(asset)?">
                <asset name="{$professionName}" domain="{$FLYER_GENERATOR_DOMAIN}" type="{$PROFESSION_ASSET_TYPE}">
                  <asset_feature feature="{$PROFESSION_ID_FEAT}" value_long="{$id}"/>
                  <asset_feature feature="{$PDF_RENDERING_PENDING}" value_long="1"/>
                  <parent_asset_rel key="{$PROFESSION_GROUP_REL}" parent_asset="{$professionGroupAsset/@id}"/>
                  <xsl:if test="$riskGroupAsset">
                    <asset_feature feature="{$RISK_GROUP_REF_FEAT}" value_asset_id="{$riskGroupAsset/@id}"/>
                  </xsl:if>
                  <xsl:copy-of select="$textPositionChildFeatures"/>
                </asset>
              </xsl:variable>
              <xsl:copy-of select="svtx:checkInNew($newAsset)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- ignore cells, which dont have wanted index -->
  <xsl:template match="cell"/>

  <!-- -->
  <xsl:template match="cell[@index = $cellIndexes]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>
