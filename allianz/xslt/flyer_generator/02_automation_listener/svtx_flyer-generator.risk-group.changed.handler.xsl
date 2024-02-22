<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer-generator.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="../svtx_flyer-generator.util.xsl" use-when="false()"/>

  <xsl:template match="/asset[@type=$RISKGROUP_ASSET_TYPE]">
    <xsl:message>### AUTOMATION ### Compare Risk Group Features on Asset <xsl:value-of select="@id"/></xsl:message>
    <xsl:variable name="currentAsset" select="." as="element(asset)?"/>
    <xsl:variable name="previousAsset" select="svtx:getPreviousAsset($currentAsset)" as="element(asset)?"/>
    <xsl:if test="exists($previousAsset)">
      <xsl:variable name="currentFeatures">
        <xsl:apply-templates select="$currentAsset/asset_feature">
          <xsl:sort select="@value_long" data-type="number" order="ascending"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="previousFeatures">
        <xsl:apply-templates select="$previousAsset/asset_feature">
          <xsl:sort select="@value_long" data-type="number" order="ascending"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="isEqual" select="deep-equal($currentFeatures, $previousFeatures)" as="xs:boolean"/>
      <xsl:if test="not($isEqual)">
        <xsl:message>### Risk Group Changed ### Updating PDF Flag on Professions</xsl:message>
        <xsl:variable name="query" as="element(query)">
          <query type="asset">
            <condition name="censhare:asset.domain" value="{$FLYER_GENERATOR_DOMAIN}"/>
            <condition name="censhare:asset.type" value="{$PROFESSION_ASSET_TYPE}"/>
            <condition name="{$RISK_GROUP_REF_FEAT}" value="{$currentAsset/@id}"/>
            <or>
              <condition name="{$PDF_RENDERING_PENDING}" op="ISNULL"/>
              <condition name="{$PDF_RENDERING_PENDING}" value="0"/>
            </or>
          </query>
        </xsl:variable>
        <xsl:for-each select="cs:asset($query)">
          <xsl:copy-of select="svtx:setRenderFlagIfNotExist(.)"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- 1. ebene -->
  <xsl:template match="asset_feature[@feature=$MONTHLY_RENT_FEAT]">
    <xsl:copy>
      <xsl:copy-of select="(@feature, @value_long, @value_double)"/>
      <xsl:apply-templates>
        <xsl:sort select="@value_long" data-type="number" order="ascending"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- 2. ebene -->
  <xsl:template match="asset_feature[@feature=$AGE_FEAT]">
    <xsl:copy>
      <xsl:copy-of select="(@feature, @value_long, @value_double)"/>
      <xsl:apply-templates>
        <xsl:sort select="@feature" data-type="text" order="ascending"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- 3. ebene  -->
  <xsl:template match="asset_feature[@feature=($NET_CONTRIBUTION_FEAT, $NET_CONTRIBUTION_WITH_PAYMENT_FEAT, $NET_CONTRIBUTION_DIFFERENCE_FEAT, $CAPITAL_PAYMENT_FEAT)]">
    <xsl:copy>
      <xsl:copy-of select="(@feature, @value_long, @value_double)"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>