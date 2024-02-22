<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  exclude-result-prefixes="#all" >
  
  <xsl:param name="workflowID" select="10"/>
  <xsl:param name="workflowStepID" select="10"/>
  <xsl:param name="historyReset" select="'no'"/>
  <xsl:param name="versioned" select="'false'"/>
  
  <xsl:variable name="loggedInUser" as="xs:long" select="system-property('censhare:party-id')"/>
  <xsl:variable name="loggedInUserAssetId" select="cs:master-data('party')[@id=$loggedInUser]/@party_asset_id"/>
  
  <!-- DEBUG TEMPLATE -->
  <xsl:template match="/asset">
    <xsl:variable name="updatedAsset" as="element(asset)">
      <cs:command name="com.censhare.api.assetmanagement.Update">
        <cs:param name="source">
          <asset wf_id="{$workflowID}" wf_step="{$workflowStepID}">
            <xsl:copy-of select="@*[not(local-name() = ('wf_step', 'wf_id'))]"/>
            <xsl:copy-of select="node() except(asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type' ] ,
               storage_item[@key='abstimmungsdokument_short' or @key='abstimmungsdokument'])"/>
            <xsl:if test="$historyReset='no'">
              <xsl:copy-of select="asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type' ]"/>
            </xsl:if>
          </asset>
        </cs:param>
      </cs:command>
    </xsl:variable>

    <xsl:if test="$versioned and $versioned eq 'true'">
      <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOut">
        <cs:param name="source" select="$updatedAsset"/>
      </cs:command>
      <cs:command name="com.censhare.api.assetmanagement.CheckIn">
        <cs:param name="source" select="$checkedOut"/>
      </cs:command>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
