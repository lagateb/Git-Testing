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

  <!-- root match -->
  <xsl:template match="/asset[@type='profession.']">
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>
    <xsl:variable name="riskGroup" select="cs:feature-ref-reverse()[@key = $RISK_GROUP_REF_FEAT]" as="element(asset)?"/>
    <xsl:for-each select="distinct-values($riskGroup/asset_feature[@feature=$MONTHLY_RENT_FEAT]/asset_feature[@feature=$AGE_FEAT]/@value_long)">
      <xsl:variable name="age" select="." as="xs:long?"/>
      <!-- get calculation paramaters of risk group -->
      <xsl:variable name="calculationParams" as="element(param)*">
        <xsl:apply-templates select="$riskGroup/asset_feature[@feature=$MONTHLY_RENT_FEAT]">
          <xsl:sort select="@value_long" data-type="number" order="ascending" />
          <xsl:with-param name="age" select="$age"/>
        </xsl:apply-templates>
      </xsl:variable>
      <!-- need exactly 3! or more... but only taking 3 -->
      <xsl:if test="count($calculationParams) ge 3">
        <!-- render pdf with params age/calculations -->
        <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="pdfResult">
          <cs:param name="key" select="'svtx:flyer-generator.render-pdf'"/>
          <cs:param name="source" select="$rootAsset"/>
          <cs:param name="xsl-parameters">
            <cs:param name="age" select="$age"/>
            <cs:param name="calculations" select="$calculationParams"/>
          </cs:param>
        </cs:command>
        <xsl:variable name="newStorage" as="element(storage_item)">
          <storage_item key="master"
                        element_idx="0"
                        mimetype="application/pdf"
                        corpus:asset-temp-filepath="{$pdfResult/command/@corpus:asset-temp-filepath}"
                        corpus:asset-temp-filesystem="{$pdfResult/command/@corpus:asset-temp-filesystem}"/>
        </xsl:variable>
        <!-- check if pdf already existed and exchange Storage item, else create new -->
        <xsl:variable name="childPdfId" select="$rootAsset/child_asset_rel[@key='user.' and asset_rel_feature[@feature=$AGE_FEAT and @value_long=$age]]/@child_asset" as="xs:long?"/>
        <xsl:variable name="childPdfAsset" select="if (exists($childPdfId)) then cs:get-asset($childPdfId) else ()" as="element(asset)?"/>
        <xsl:variable name="assetName" select="concat($rootAsset/@name, ' - PDF - ', $age, ' Jahre')" as="xs:string?"/>
        <xsl:choose>
          <xsl:when test="exists($childPdfAsset)">
            <xsl:variable name="checkedOutAsset" select="svtx:checkOutAsset($childPdfAsset)" as="element(asset)?"/>
            <xsl:variable name="newAsset">
              <asset name="{$assetName}">
                <xsl:copy-of select="$checkedOutAsset/@* except $checkedOutAsset/@name"/>
                <xsl:copy-of select="$checkedOutAsset/node() except $checkedOutAsset/(storage_item, asset_element)"/>
                <asset_element idx="0" key="actual."/>
                <xsl:copy-of select="$newStorage"/>
              </asset>
            </xsl:variable>
            <xsl:variable name="checkedInAsset" select="svtx:checkInAsset($newAsset)" as="element(asset)?"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="newAsset">
              <asset name="{$assetName}" type="document." application="default" domain="{$FLYER_GENERATOR_DOMAIN}">
                <asset_element idx="0" key="actual."/>
                <xsl:copy-of select="$newStorage"/>
                <parent_asset_rel key="user." parent_asset="{$rootAsset/@id}">
                  <asset_rel_feature feature="{$AGE_FEAT}" value_long="{$age}" />
                </parent_asset_rel>
              </asset>
            </xsl:variable>
            <xsl:variable name="checkedInNew" select="svtx:checkInNew($newAsset)" as="element(asset)?"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
        <cs:param name="flush" select="true()"/>
      </cs:command>
    </xsl:for-each>
    <!-- job is done, remove feature "pdf rendering pending" or this will be called again by automation -->
    <xsl:variable name="checkedOutAsset" select="svtx:checkOutAsset($rootAsset)" as="element(asset)?"/>
    <xsl:variable name="updatedAsset">
      <asset>
        <xsl:copy-of select="$checkedOutAsset/@*"/>
        <xsl:copy-of select="$checkedOutAsset/node() except $checkedOutAsset/asset_feature[@feature=$PDF_RENDERING_PENDING]"/>
      </asset>
    </xsl:variable>
    <xsl:variable name="checkedInAsset" select="svtx:checkInAsset($updatedAsset)" as="element(asset)?"/>
  </xsl:template>

  <!-- 1. ebene -->
  <xsl:template match="asset_feature[@feature=$MONTHLY_RENT_FEAT]">
    <xsl:param name="age"/>
    <xsl:if test="asset_feature[@feature=$AGE_FEAT and @value_long=$age]">
      <param rent="{@value_long}" age="{$age}">
        <xsl:variable name="displayValue" select="concat(svtx:formatNumberInteger(@value_long), ' €')"/>
        <xsl:variable name="next">
          <xsl:apply-templates select="asset_feature[@feature='svtx:age' and @value_long=$age]"/>
        </xsl:variable>
        <xsl:value-of select="concat(concat('monthly-rent=', $displayValue), $next)"/>
      </param>
    </xsl:if>
  </xsl:template>

  <!-- 2. ebene -->
  <xsl:template match="asset_feature[@feature=$AGE_FEAT]">
    <xsl:variable name="displayValue" select="svtx:formatNumberInteger(@value_long)"/>
    <xsl:variable name="next">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="concat(concat(';age=', $displayValue), $next)"/>
  </xsl:template>

  <!-- 3. ebene -->
  <xsl:template match="asset_feature[@feature=$CAPITAL_PAYMENT_FEAT]">
    <xsl:variable name="displayValue" select="concat(svtx:formatNumberInteger(@value_long), ' €')"/>
    <xsl:value-of select="concat(';capital-payment=', $displayValue)"/>
  </xsl:template>

  <xsl:template match="asset_feature[@feature=$NET_CONTRIBUTION_FEAT]">
    <xsl:variable name="displayValue" select="concat(svtx:formatNumberDecimal(@value_double), ' €')"/>
    <xsl:value-of select="concat(';net-contribution=', $displayValue)"/>
  </xsl:template>

  <xsl:template match="asset_feature[@feature=$NET_CONTRIBUTION_WITH_PAYMENT_FEAT]">
    <xsl:variable name="displayValue" select="concat(svtx:formatNumberDecimal(@value_double), ' €')"/>
    <xsl:value-of select="concat(';net-contribution-with-capital-payment=', $displayValue)"/>
  </xsl:template>

  <xsl:template match="asset_feature[@feature=$NET_CONTRIBUTION_DIFFERENCE_FEAT]">
    <xsl:variable name="displayValue" select="concat(svtx:formatNumberDecimal(@value_double), ' €')"/>
    <xsl:value-of select="concat(';net-contribution-difference=', $displayValue)"/>
  </xsl:template>

</xsl:stylesheet>