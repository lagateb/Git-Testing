<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:my="http://www.censhare.com/my" 
  exclude-result-prefixes="#all"
  >
  
  <xsl:param name="featureKey" select="'svtx:approval.additional.comment'"/>
  <xsl:param name="comment" select="''"/>
  
  <xsl:variable name="loggedInUser" as="xs:long" select="system-property('censhare:party-id')"/>
  <xsl:variable name="loggedInUserAssetId" select="cs:master-data('party')[@id=$loggedInUser]/@party_asset_id"/>
  
  <!-- DEBUG TEMPLATE -->
  <xsl:template match="/asset">
    <xsl:variable name="doCheckout" as="xs:boolean" select="current()/@state='0'"/>
    <!-- Check out asset but only of not alread checked out -->
    <xsl:variable name="checkedOutAsset" as="element(asset)">
      <xsl:choose>
        <xsl:when test="$doCheckout">
          <cs:command name="com.censhare.api.assetmanagement.CheckOut">
            <cs:param name="source" select="current()/@id"/>
          </cs:command>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="current()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="updatedAsset" as="element(asset)">
      <cs:command name="com.censhare.api.assetmanagement.Update">
        <cs:param name="source">
          <asset>
            <xsl:copy-of select="$checkedOutAsset/@*"/>
            <xsl:copy-of select="$checkedOutAsset/node() except($checkedOutAsset/asset_feature[@feature=$featureKey])"/>
            <asset_feature feature="{$featureKey}" value_string="{$comment}"/>
          </asset>
        </cs:param>
      </cs:command>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$doCheckout">
        <cs:command name="com.censhare.api.assetmanagement.CheckIn">
          <cs:param name="source" select="$updatedAsset/@id"/>
        </cs:command>
      </xsl:when>
      <xsl:otherwise>
        <cs:command name="com.censhare.api.assetmanagement.CheckIn">
          <cs:param name="source" select="$updatedAsset/@id"/>
        </cs:command>
        <cs:command name="com.censhare.api.assetmanagement.CheckOut">
          <cs:param name="source" select="$updatedAsset/@id"/>
        </cs:command>
        
      </xsl:otherwise>
    </xsl:choose>
    
    
  </xsl:template>
  
  
  
</xsl:stylesheet>
