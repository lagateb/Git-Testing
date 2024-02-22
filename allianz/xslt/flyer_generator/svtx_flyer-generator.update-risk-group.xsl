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
  <xsl:variable name="riskGroupAssets" select="svtx:getRiskGroupAssets($rootAsset)" as="element(asset)*"/>
  <xsl:variable name="cellIndexes" select="(0,3,4,6,7,9)" as="xs:long*"/>

  <!-- -->
  <xsl:template match="/asset[@type='product.']">
    <xsl:choose>
      <xsl:when test="svtx:hasExcelStorage($rootAsset) eq false()">
        <xsl:message>### SKIP UPDATE RISK GROUP ### REASON ### No Excel Storage on <xsl:value-of select="$rootAsset/@id"/></xsl:message>
      </xsl:when>
      <xsl:when test="exists($riskGroupAssets) eq false()">
        <xsl:message>### SKIP UPDATE RISK GROUP ### REASON ### No Related Risk Group Assets found for Product: <xsl:value-of select="$rootAsset/@id"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$riskGroupAssets"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset[@type=$RISKGROUP_ASSET_TYPE]">
    <xsl:variable name="sheetIndex" select="svtx:getExcelSheetIndex(.)" as="xs:long?"/>
    <xsl:variable name="assetFeatures" as="element(asset_feature)*">
      <xsl:choose>
        <xsl:when test="exists($sheetIndex) eq false()">
          <xsl:message>### SKIP UPDATE RISK GROUP ### REASON ### No Sheet Index Feature found on Risk Group Asset <xsl:value-of select="@id"/></xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            ### Prepare Update Risk Group ###
            Product: <xsl:value-of select="$rootAsset/@id"/>
            Risk Group: <xsl:value-of select="@id"/>
            Sheet Index: <xsl:value-of select="$sheetIndex"/>
          </xsl:message>
          <!-- should match row -->
          <xsl:apply-templates select="svtx:getExcelData($rootAsset, $sheetIndex)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="groupedAssetFeatures" as="element(asset_feature)*">
      <xsl:for-each-group select="$assetFeatures" group-by="@value_long">
        <xsl:copy>
          <xsl:copy-of select="current-group()/@*"/>
          <xsl:copy-of select="current-group()/node()"/>
        </xsl:copy>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="exists($groupedAssetFeatures)">
        <xsl:variable name="checkedOutAsset" select="svtx:checkOutAsset(.)" as="element(asset)?"/>
        <xsl:variable name="newAsset">
          <xsl:copy>
            <xsl:copy-of select="$checkedOutAsset/@*"/>
            <xsl:copy-of select="$checkedOutAsset/node() except $checkedOutAsset/asset_feature[@feature = $MONTHLY_RENT_FEAT]"/>
            <xsl:copy-of select="$groupedAssetFeatures"/>
          </xsl:copy>
        </xsl:variable>
        <xsl:copy-of select="svtx:checkInAsset($newAsset)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>### SKIP UPDATE ASSET ### REASON ### No New Features for Asset <xsl:value-of select="@id"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- -->
  <xsl:template match="row">
    <xsl:variable name="noEmptyCells" select="every $x in $cellIndexes satisfies exists(cell[@index=$x]/text())" as="xs:boolean"/>
    <!--<xsl:message>
      ### ROW
      <xsl:copy-of select="."/>
    </xsl:message>-->
    <xsl:variable name="cellData" as="xs:string*">
      <xsl:choose>
        <xsl:when test="@index le 8">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Row is Header </xsl:message>
        </xsl:when>
        <xsl:when test="$noEmptyCells eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Some Cells are empty, expected content for indexes: <xsl:value-of select="$cellIndexes"/></xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="decimal"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:message>
      <row-data><xsl:value-of select="string-join($cellData, ' # ')"/> </row-data>
    </xsl:message>


    <xsl:if test="exists($cellData)">
      <xsl:variable name="age" select="svtx:castToLong($cellData[1])" as="xs:long?"/>
      <xsl:variable name="netContribution" select="svtx:castToDouble($cellData[2])" as="xs:double?"/>
      <xsl:variable name="rent" select="svtx:castToLong($cellData[3])" as="xs:long?"/>
      <xsl:variable name="netContributionWithPayment" select="svtx:castToDouble($cellData[4])" as="xs:double?"/>
      <xsl:variable name="netDifference" select="svtx:castToDouble($cellData[5])" as="xs:double?"/>
      <xsl:variable name="capitalPayment" select="svtx:castToLong($cellData[6])" as="xs:long?"/>
      <xsl:choose>
        <xsl:when test="exists($age) eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Cannot cast Age to long: <xsl:copy-of select="."/></xsl:message>
        </xsl:when>
        <xsl:when test="exists($netContribution) eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Cannot cast Net Contribution to double: <xsl:copy-of select="."/></xsl:message>
        </xsl:when>
        <xsl:when test="exists($rent) eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Cannot cast Rent to long: <xsl:copy-of select="."/></xsl:message>
        </xsl:when>
        <xsl:when test="exists($netContributionWithPayment) eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Cannot cast Net Contribution With Payment to double: <xsl:copy-of select="."/></xsl:message>
        </xsl:when>
        <xsl:when test="exists($capitalPayment) eq false()">
          <xsl:message>### SKIP ROW <xsl:value-of select="@index"/> ### REASON ### Cannot cast Capital Payment to long: <xsl:copy-of select="."/></xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <asset_feature feature="{$MONTHLY_RENT_FEAT}" value_long="{$rent}">
            <asset_feature feature="{$AGE_FEAT}" value_long="{$age}">
              <asset_feature feature="{$NET_CONTRIBUTION_DIFFERENCE_FEAT}" value_double="{$netDifference}"/>
              <asset_feature feature="{$CAPITAL_PAYMENT_FEAT}" value_long="{$capitalPayment}"/>
              <asset_feature feature="{$NET_CONTRIBUTION_FEAT}" value_double="{$netContribution}"/>
              <asset_feature feature="{$NET_CONTRIBUTION_WITH_PAYMENT_FEAT}" value_double="{$netContributionWithPayment}"/>
            </asset_feature>
          </asset_feature>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- -->
  <xsl:template match="number-sep" mode="decimal"/>

  <!-- -->
  <xsl:template match="@*|node()" mode="decimal">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="decimal"/>
    </xsl:copy>
  </xsl:template>

  <!-- -->
  <xsl:template match="decimal-sep" mode="decimal">
    <xsl:value-of select="'.'"/><xsl:apply-templates mode="decimal"/>
  </xsl:template>

  <!-- -->
  <xsl:template match="cell" mode="decimal"/>

  <!-- -->
  <xsl:template match="cell[@index = $cellIndexes]" mode="decimal">
    <num><xsl:apply-templates mode="decimal"/></num>
  </xsl:template>
</xsl:stylesheet>