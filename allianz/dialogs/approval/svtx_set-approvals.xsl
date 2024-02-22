<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:my="http://www.censhare.com/my" 
  exclude-result-prefixes="#all"
  >
  
  <!-- 
          Created by Tomas Martini 
     ***********************************************************
        Description:
          Set approvals and history for approvals   
      Todo:
              
      History:
          2019-08-02 Tomas Martini - Created
          
      ***********************************************************    
  -->
  
  <xsl:param name="featureItemKey" select="'cenahare:feature-item.approval.pm'"/><!-- cenahare:feature-item.approval.rc, cenahare:feature-item.approval.editorial, cenahare:feature-item.approval.pm -->
  <xsl:param name="approvalStatus" select="'approved'"/>
  <xsl:param name="comment" select="''"/>
  
  <xsl:variable name="loggedInUser" as="xs:long" select="system-property('censhare:party-id')"/>
  <xsl:variable name="loggedInUserAssetId" select="cs:master-data('party')[@id=$loggedInUser]/@party_asset_id"/>
  
  
  <xsl:variable name="approvalsContainerFeatureId" select="'censhare:approvals'"/>
  <xsl:variable name="approvalFeatureId" select="'censhare:approval.type'"/>
  
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

    <xsl:variable name="newApprovalFeature" as="element(asset_feature)">
      <asset_feature  feature="{$approvalFeatureId}" value_string2="censhare:resource-key" value_asset_key_ref="{$featureItemKey}">
        <asset_feature  feature="censhare:approval.status" value_key="{$approvalStatus}"/>
        <asset_feature  feature="censhare:approval.person" value_long="0" value_long2="0" value_asset_id="{$loggedInUserAssetId}"/>
        <asset_feature  feature="censhare:approval.asset-version" value_long="{xs:integer(number(current()/@version) + 1)}"/>
        <xsl:choose>
          <xsl:when test="string-length($comment) gt 0">
            <asset_feature feature="censhare:approval.comment" value_string="{$comment}"/>    
          </xsl:when>
        </xsl:choose>
        <asset_feature  feature="censhare:approval.date" value_timestamp="{current-dateTime()}"/>
      </asset_feature>
    </xsl:variable>
    
    <xsl:variable name="historyFeature" as="element(asset_feature)">
      <asset_feature  feature="censhare:approval.history" >
        <xsl:copy-of select="$checkedOutAsset/asset_feature[@feature='censhare:approval.history']/@*"/>
        <xsl:copy-of 
            select="$checkedOutAsset/asset_feature[@feature='censhare:approval.history']/asset_feature[@feature=$approvalFeatureId]"/>
        <!-- Add newely created -->
        <xsl:copy-of select="$newApprovalFeature" />
      </asset_feature>
    </xsl:variable>
    <!--<DEBUG>
      <xsl:copy-of select="$newApprovalFeature, $historyFeature"/>
    </DEBUG>-->
    <xsl:variable name="updatedAsset" as="element(asset)">
      <cs:command name="com.censhare.api.assetmanagement.Update">
        <cs:param name="source">
          <asset>
            <xsl:copy-of select="$checkedOutAsset/@*"/>
            <xsl:copy-of select="$checkedOutAsset/node() 
              except($checkedOutAsset/asset_feature[@feature=($historyFeature/@feature)], 
              $checkedOutAsset/asset_feature[@feature=$newApprovalFeature/@feature and @value_asset_key_ref=$newApprovalFeature/@value_asset_key_ref])"/>
            <xsl:copy-of select="$newApprovalFeature, $historyFeature"/>
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
