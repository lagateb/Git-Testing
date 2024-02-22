<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:corpus="http://www.censhare.com/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="xs cs csc corpus">

  <!--
     Generiert die Date für das Workflow Step Widget
        Text Asset
        Media Asset

          Created by Tomas Martini 
     ***********************************************************
        Description:
          Render html to widget for approval   
      Todo:
              
      History:
          2019-08-02 Tomas Martini - Created
          
      ***********************************************************    
  -->
  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

  <!-- global variables -->
  <xsl:variable name="approvalFeatureId" select="'censhare:approval.type'"/>
  <xsl:variable name="approvalStatusFeatureId" select="'censhare:approval.status'"/>
  <xsl:variable name="approvalPersonFeatureId" select="'censhare:approval.person'"/>
  <xsl:variable name="approvalDateFeatureId" select="'censhare:approval.date'"/>
  <xsl:variable name="approvalCommentFeatureId" select="'censhare:approval.comment'"/>
  <xsl:variable name="approvalVersionFeatureId" select="'censhare:approval.asset-version'"/>

  <!-- Get approval status alternatives, used to determine approval functionallity (Disable reject value key if reject button should not be present) -->
  <xsl:variable name="approvalStatuses" as="element(feature_value)*" select="cs:master-data('feature_value')[@feature=$approvalStatusFeatureId]"/>

  <xsl:template match="/asset">

    <xsl:variable name="asset" as="element(asset)" select="current()"/>

    <xsl:variable name="userId" select="csc:getLoggedInPartyID()"/>
    <xsl:variable name="userAsetId" select="cs:master-data('party')[@id=$userId]/@party_asset_id"/>

    <!-- Get all system roles for current user -->
    <xsl:variable name="userRoleKeys" as="xs:string*" select="cs:master-data('party_role')[@party_id=$userId and @enabled='1']/@role"/>
    <xsl:variable name="userRoles" as="element(role)*" select="for $x in $userRoleKeys return cs:master-data('role')[@role=$x and @enabled='1']"/>

    <!-- Also get all team roles from asset -->
    <xsl:variable name="userTeamRolesKeys" as="xs:string*"
                  select="distinct-values($asset/asset_feature[@feature='censhare:team-member' and @value_asset_id=$userAsetId]/asset_feature[@feature='censhare:team-member.role']/@value_asset_key_ref)"/>
    <!-- Not needed for now  -->
    <!--xsl:variable name="userTeamRoles" as="element(asset)*" select="for $x in $userTeamRolesKeys return cs:get-resource-asset($x)"/-->

    <xsl:variable name="approvalFeatureDef" as="element(feature)*" select="cs:master-data('feature')[@key=$approvalFeatureId]"/>
    <xsl:variable name="featureAsset" select=" csc:getFeatureAsset($approvalFeatureDef)"/>

    <!-- Get asset approvals -->
    <xsl:variable name="assetApprovals" as="element(asset_feature)*"
                  select="$asset/asset_feature[@feature=$approvalFeatureId]"/>

    <xsl:variable name="stateID" select="cs:master-data('workflow_step')[@wf_id= $asset/@wf_id and @wf_step = $asset/@wf_step]/@wf_state_id"/>

    <!-- Get approvals featureItems sorted -->
    <approvals>
      <!-- metadata -->
      <metadata>
        <xsl:attribute name="userId" select="$userId"/>
        <xsl:attribute name="userAsetId" select="$userAsetId"/>
        <!-- Create a data model for status feature  -->
        <approvalStatus>
          <xsl:for-each select="$approvalStatuses">
            <xsl:element name="{@value_key}">
              <valueKey><xsl:value-of select="@value_key"/></valueKey>
              <enabled censhare:_annotation.datatype="boolean"><xsl:value-of select="@enabled='1'"/></enabled>
              <displayName censhare:_annotation.datatype="string"><xsl:value-of select="@name"/></displayName>
            </xsl:element>
          </xsl:for-each>
        </approvalStatus>
        <userRoles>
          <systemRoles>
            <xsl:copy-of select="$userRoles"/>
          </systemRoles>
          <teamRoles>
            <xsl:sequence select="$userTeamRolesKeys"/>
          </teamRoles>
        </userRoles>

        <!-- workflow -->
        <workflow censhare:_annotation.datatype="string"><xsl:value-of select="cs:master-data('workflow')[@id=$asset/@wf_id]/@name"/></workflow>
        <workflowID censhare:_annotation.datatype="number"><xsl:value-of select="$asset/@wf_id"/></workflowID>
        <workflowStep censhare:_annotation.datatype="string"><xsl:value-of select="cs:master-data('workflow_step')[@wf_id= $asset/@wf_id and @wf_step = $asset/@wf_step]/@name"/></workflowStep>
        <workflowStepID censhare:_annotation.datatype="number"><xsl:value-of select="$asset/@wf_step"/></workflowStepID>
        <workflowStepColor censhare:_annotation.datatype="number"><xsl:value-of select="cs:master-data('workflow_step')[@wf_id= $asset/@wf_id and @wf_step = $asset/@wf_step]/@color"/></workflowStepColor>
        <workflowState censhare:_annotation.datatype="string"><xsl:value-of select="cs:master-data('workflow_state')[@id=$stateID]/@name"/></workflowState>
        <workflowStateColor censhare:_annotation.datatype="number"><xsl:value-of select="cs:master-data('workflow_state')[@id=$stateID]/@color"/></workflowStateColor>
        <assigned censhare:_annotation.datatype="string"><xsl:value-of select="cs:master-data('party')[@id=$asset/@wf_target]/@display_name"/></assigned>
        <assignedID censhare:_annotation.datatype="string"><xsl:value-of select="cs:master-data('party')[@id=$asset/@wf_target]/@id"/></assignedID>
        <deadline censhare:_annotation.datatype="string"><xsl:value-of select="format-date($asset/@deadline,'[M01]/[D01]/[Y0001]')"/></deadline>
        <annotation censhare:_annotation.datatype="string"><xsl:value-of select="$asset/@annotation"/></annotation>
        <noworkflow censhare:_annotation.datatype="string">${noworkflowAssigned}</noworkflow>
        <additionalComment censhare:_annotation.datatype="string"><xsl:value-of select="$asset/asset_feature[@feature='svtx:approval.additional.comment']/@value_string"/></additionalComment>
      </metadata>

      <xsl:message>=== set new WF V2</xsl:message>
      <xsl:variable name="currentStep" select="$asset/@wf_step" as="xs:integer"/>
      <workflowInfo>
        <xsl:choose>
            <xsl:when test="$asset/@wf_id = 80"><xsl:copy-of select="svtx:getMediaWFSteps($asset,$currentStep)"/></xsl:when>
            <xsl:otherwise><xsl:copy-of select="svtx:getTextWFSteps($asset,$currentStep)"/></xsl:otherwise>
        </xsl:choose>

          <!-- was ist das ? -->
        <currentstep>
          <xsl:attribute name="name" select="concat('step-', $currentStep)"/>
          <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id= $asset/@wf_id and @wf_step = $currentStep]/@name"/>
          <xsl:choose>
            <xsl:when test="$currentStep=10">
              <xsl:attribute name="progress" select="33"/>
              <xsl:attribute name="progressclass" select="'cs-progress-01'"/>
            </xsl:when>
            <xsl:when test="$currentStep=20">
              <xsl:attribute name="progress" select="50"/>
              <xsl:attribute name="progressclass" select="'cs-progress-01'"/>
            </xsl:when>
            <xsl:when test="$currentStep=30">
              <xsl:attribute name="progress" select="100"/>
              <xsl:attribute name="progressclass" select="'cs-progress-01'"/>
            </xsl:when>
            <xsl:when test="$currentStep=55">
              <xsl:attribute name="progress" select="60"/>
              <xsl:attribute name="progressclass" select="'cs-progress-01'"/>
            </xsl:when>
            <xsl:when test="$currentStep=60">
              <xsl:attribute name="progress" select="70"/>
              <xsl:attribute name="progressclass" select="'cs-progress-01'"/>
            </xsl:when>
            <xsl:when test="$currentStep=40"> <!-- Abgeleht Text -->
              <xsl:attribute name="progress" select="100"/>
              <xsl:attribute name="progressclass" select="'cs-progress-02'"/>
            </xsl:when>
            <xsl:when test="$currentStep=50"> <!-- Abgeleht Madium -->
              <xsl:attribute name="progress" select="100"/>
              <xsl:attribute name="progressclass" select="'cs-progress-02'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="progress" select="100"/>
              <xsl:attribute name="progressclass" select="'cs-progress-01'"/>
            </xsl:otherwise>
          </xsl:choose>
        </currentstep>
      </workflowInfo>

      <xsl:for-each select="$featureAsset/asset_feature[@feature='censhare:module.feature-item']">
        <xsl:sort select="@sorting" data-type="number" />
        <!-- get asset and check if asset match asset type filer -->
        <xsl:variable name="featureItemResourceKey" select="@value_asset_key_ref"/>
        <xsl:variable name="featureItemAsset" as="element(asset)" select="csc:getResourceAsset($featureItemResourceKey)"/>

        <!-- Valid for asset type? -->
        <xsl:if test="csc:getMatchAssetTypeFilter($asset, $featureItemAsset, true())">
          <approval     censhare:_annotation.multi="true">
            <xsl:attribute name="key" select="$featureItemResourceKey"/>
            <xsl:attribute name="name" select="csc:getLocalizedAssetName($featureItemAsset)"/>
            <xsl:attribute name="description" select="csc:getLocalizedAssetDescription($featureItemAsset)"/>
            <xsl:copy-of select="@sorting"/>

            <!-- Check roles for feature Item  -->
            <xsl:variable name="roles" as="element(role)*">
              <xsl:for-each select="$featureItemAsset/asset_feature[@feature='censhare:resource-role' and string-length(@value_string) gt 0]">
                <xsl:variable name="role" as="element(role)?" select="cs:master-data('role')[@role=current()/@value_string and @enabled='1']"/>
                <xsl:if test="$role">
                  <role type="system-role">
                    <xsl:copy-of select="$role/@role, $role/@name, $role/@enabled, $role/@description"/>
                    <userInRole censhare:_annotation.datatype="boolean">
                      <xsl:value-of select="exists($userRoles[@role=$role/@role])"/>
                    </userInRole>
                  </role>
                </xsl:if>
              </xsl:for-each>

              <xsl:for-each select="$featureItemAsset/asset_feature[@feature='censhare:team-member.role']/@value_asset_key_ref">
                <xsl:variable name="teamRoleKey" as="xs:string" select="current()"/>
                <xsl:variable name="teamRole" as="element(asset)" select="cs:get-resource-asset($teamRoleKey)"/>
                <role type="team-role">
                  <xsl:attribute name="reaource-key" select="$teamRoleKey"/>
                  <xsl:attribute name="name" select="$teamRole/@name"/>
                  <xsl:attribute name="description" select="$teamRole/@description"/>
                  <userInRole censhare:_annotation.datatype="boolean">
                    <xsl:value-of select="$userTeamRolesKeys=$teamRoleKey"/>
                  </userInRole>
                </role>
              </xsl:for-each>
            </xsl:variable>
            <roleShowApproval censhare:_annotation.datatype="boolean">
              <xsl:value-of select="if(empty($roles) or exists($roles[userInRole='true'])) then true() else false()"/>
            </roleShowApproval>
            <roles censhare:_annotation.arraygroup="true">
              <xsl:copy-of select="$roles"/>
            </roles>
            <!-- Get asset approval -->
            <xsl:variable name="assetApproval" as="element(asset_feature)*" select="($assetApprovals[@value_asset_key_ref=$featureItemResourceKey])[1]"/>
            <asset-approval>
              <xsl:choose>
                <xsl:when test="$assetApproval">
                  <!-- Status key as attribute -->
                  <xsl:variable name="statusKey" select="($assetApproval/asset_feature[@feature=$approvalStatusFeatureId]/@value_key, 'unknown')[1]"/>
                  <xsl:attribute name="status-key" select="$statusKey"/>

                  <!-- Date attribute -->
                  <xsl:variable name="dateValue" as="xs:dateTime?" select="$assetApproval/asset_feature[@feature=$approvalDateFeatureId]/@value_timestamp"/>
                  <xsl:attribute name="date" select="if(exists($dateValue)) then cs:format-date($dateValue, 'relative-short', 'short') else ''"/>

                  <!-- Status metadata for presentation -->
                  <status>
                    <xsl:attribute name="key" select="$statusKey"/>
                    <xsl:attribute name="name" select="$approvalStatuses[@value_key=$statusKey]/@name"/>
                    <!-- Color and icon  -->
                    <xsl:choose>
                      <xsl:when test="$statusKey='started'">
                        <xsl:attribute name="css-icon" select="'cs-icon-no-progress'"/>
                        <xsl:attribute name="css-color" select="'cs-color-36'"/>
                      </xsl:when>
                      <xsl:when test="$statusKey='approved'">
                        <xsl:attribute name="css-icon" select="'cs-icon-circle-ok'"/>
                        <xsl:attribute name="css-color" select="'cs-color-30'"/>
                      </xsl:when>
                      <xsl:when test="$statusKey='rejected'">
                        <xsl:attribute name="css-icon" select="'cs-icon-circle-remove'"/>
                        <xsl:attribute name="css-color" select="'cs-color-38'"/>
                      </xsl:when>
                      <xsl:when test="$statusKey='ignored'">
                        <xsl:attribute name="css-icon" select="'cs-icon-circle'"/>
                        <xsl:attribute name="css-color" select="'cs-color-05'"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="css-icon" select="'cs-icon-close-cross'"/>
                        <xsl:attribute name="css-color" select="'cs-color-00'"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </status>

                  <xsl:variable name="approvalUserAssetId" select="$assetApproval/asset_feature[@feature=$approvalPersonFeatureId]/@value_asset_id"/>
                  <approver>
                    <xsl:attribute name="asset-id" select="$approvalUserAssetId"/>
                    <xsl:attribute name="user-id" select="cs:master-data('party')[@party_asset_id=$approvalUserAssetId]/@id"/>
                    <xsl:attribute name="display-name" select="if($approvalUserAssetId) then cs:master-data('party')[@party_asset_id=$approvalUserAssetId]/@display_name else ''"/>
                  </approver>
                  <comment><xsl:value-of  select="$assetApproval/asset_feature[@feature=$approvalCommentFeatureId]/@value_string"/></comment>

                  <xsl:copy-of select="$assetApproval"/>

                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="statusKey" select="'missing'"/>
                  <xsl:attribute name="status-key" select="$statusKey"/>
                  <status>
                    <xsl:attribute name="key" select="$statusKey"/>
                    <xsl:attribute name="name" select="'Missing'"/>
                    <xsl:attribute name="css-icon" select="'cs-icon-close-cross'"/>
                    <xsl:attribute name="css-color" select="'cs-color-00'"/>
                  </status>
                </xsl:otherwise>
              </xsl:choose>
            </asset-approval>
          </approval>

        </xsl:if>

      </xsl:for-each>
    </approvals>

  </xsl:template>


    <!-- liefert die StepInfo des Text Workflows 10 -->
    <xsl:function name="svtx:getTextWFSteps">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="currentStep" as="xs:integer"/>

        <steps>
            <step name="step-10">
                <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=10 and @wf_step = 10]/@name"/>
                <xsl:attribute name="state" select="if($currentStep >= 10) then 'DONE' else ''"/>
            </step>
            <step name="step-20">
                <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=10 and @wf_step = 20]/@name"/>
                <xsl:attribute name="state" select="if($currentStep >= 20) then 'DONE' else ''"/>
            </step>
            <xsl:choose>
                <xsl:when test="$currentStep=40"> <!-- Abgelehnt -->
                    <step name="step-40">
                        <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=10 and @wf_step = 40]/@name"/>
                        <xsl:attribute name="state" select="if($currentStep >= 40) then 'DONE' else ''"/>
                    </step>
                </xsl:when>
                <xsl:otherwise>
                    <step name="step-30">
                        <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id= $asset/@wf_id and @wf_step = 30]/@name"/>
                        <xsl:attribute name="state" select="if($currentStep >= 30) then 'DONE' else ''"/>
                    </step>
                </xsl:otherwise>
            </xsl:choose>
            <!--<step name="step-35">
                <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=10 and @wf_step = 35]/@name"/>
                <xsl:attribute name="state" select="if($currentStep >= 35) then 'DONE' else ''"/>
            </step>-->
        </steps>
    </xsl:function>

    <!-- liefert die StepInfo der Medien Layout/Präsentation Workflows 80 -->
    <xsl:function name="svtx:getMediaWFSteps">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="currentStep" as="xs:integer"/>
        <steps>
            <step name="step-10">
                <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=80 and @wf_step = 10]/@name"/>
                <xsl:attribute name="state" select="if($currentStep >= 10) then 'DONE' else ''"/>
            </step>
            <step name="step-20">
                <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=80 and @wf_step = 20]/@name"/>
                <xsl:attribute name="state" select="if($currentStep >= 20) then 'DONE' else ''"/>
            </step>
            <xsl:choose>

                <xsl:when test="$currentStep=50"> <!-- Abgeleht Medium -->
                    <step name="step-50">
                        <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id= 80 and @wf_step = 50]/@name"/>
                        <xsl:attribute name="state" select="if($currentStep >= 50) then 'DONE' else ''"/>
                    </step>
                </xsl:when>
                <xsl:otherwise>
                    <step name="step-30">
                        <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=80 and @wf_step = 30]/@name"/>
                        <xsl:attribute name="state" select="if($currentStep >= 30) then 'DONE' else ''"/>
                    </step>
                </xsl:otherwise>
            </xsl:choose>
          <step name="step-55">
            <!--<xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=80 and @wf_step = 55]/@name"/>-->
            <xsl:attribute name="title" select="'Medium wird aufbereitet (Systemprozess)'"/>
            <xsl:attribute name="state" select="if($currentStep >= 55) then 'DONE' else ''"/>
          </step>
          <step name="step-60">
            <!--<xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=80 and @wf_step = 60]/@name"/>-->
            <xsl:attribute name="title" select="'Medium zur Nutzung bereit'"/>
            <xsl:attribute name="state" select="if($currentStep >= 60) then 'DONE' else ''"/>
          </step>
            <!-- Medium Step  Medium Publiziert  -->
                <step name="step-90">
                    <xsl:attribute name="title" select="cs:master-data('workflow_step')[@wf_id=80 and @wf_step = 90]/@name"/>
                    <xsl:attribute name="state" select="if($currentStep >= 90) then 'DONE' else ''"/>
                </step>
        </steps>
    </xsl:function>


</xsl:stylesheet>
