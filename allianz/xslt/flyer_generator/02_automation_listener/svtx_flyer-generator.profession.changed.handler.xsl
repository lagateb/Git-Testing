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
  <xsl:import href="../svtx_flyer-generator.util.xsl" use-when="false()"/>
  <!-- global -->
  <xsl:variable name="debug" select="false()" as="xs:boolean"/>

  <!-- root match -->
  <xsl:template match="/asset">
    <xsl:message>### Automation Profession Changed Handler Called on <xsl:value-of select="@id"/> ###</xsl:message>
    <!--
      1. Asset Name Changed ?
      3. Risk Group Changed ?
      4. Profession Id changed ?
    -->
    <xsl:variable name="currentAsset" select="." as="element(asset)?"/>
    <xsl:variable name="previousAsset" select="svtx:getPreviousAsset($currentAsset)" as="element(asset)?"/>

    <xsl:variable name="currentRiskGroup" select="$currentAsset/asset_feature[@feature=$RISK_GROUP_REF_FEAT]/@value_asset_id" as="xs:long?"/>
    <xsl:variable name="previousRiskGroup" select="$previousAsset/asset_feature[@feature=$RISK_GROUP_REF_FEAT]/@value_asset_id" as="xs:long?"/>

    <xsl:variable name="currentJobId" select="$currentAsset/asset_feature[@feature=$PROFESSION_ID_FEAT]/@value_long" as="xs:long?"/>
    <xsl:variable name="previousJobId" select="$previousAsset/asset_feature[@feature=$PROFESSION_ID_FEAT]/@value_long" as="xs:long?"/>

    <xsl:variable name="needsUpdate" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="$currentAsset/asset_feature[@feature=$PDF_RENDERING_PENDING]/@value_long = 1">
          <xsl:message>### Profession Already has an Update Flag!</xsl:message>
          <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:when test="not($currentAsset/@name = $previousAsset/@name)">
          <xsl:message>### Profession Name Changed ### FROM <xsl:value-of select="$previousAsset/@name"/> TO <xsl:value-of select="$currentAsset/@name"/></xsl:message>
          <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:when test="not($currentRiskGroup = $previousRiskGroup)">
          <xsl:message>### Profession RiskGroupChanged Changed ### FROM <xsl:value-of select="$previousRiskGroup"/> TO <xsl:value-of select="$currentRiskGroup"/></xsl:message>
          <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:when test="not($currentJobId = $previousJobId)">
          <xsl:message>### Profession Job Id Changed ### FROM <xsl:value-of select="$previousJobId"/> TO <xsl:value-of select="$currentJobId"/></xsl:message>
          <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>### Profession Job didnt Change!</xsl:message>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$needsUpdate = true()">
      <cs:command name="com.censhare.api.assetmanagement.UpdateWithLock">
        <cs:param name="source">
          <asset>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node() except asset_feature[@feature=$PDF_RENDERING_PENDING]"/>
            <asset_feature feature="{$PDF_RENDERING_PENDING}" value_long="1"/>
          </asset>
        </cs:param>
      </cs:command>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>