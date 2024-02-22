<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:param name="ids"/>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="admin" select="2" as="xs:long?"/>

  <xsl:template match="/">
    <xsl:for-each select="tokenize($ids, ',')">
      <xsl:variable name="id" select="."/>
      <xsl:if test="$id castable as xs:long">
        <xsl:variable name="moduleAsset" select="cs:get-asset(xs:long($id))" as="element(asset)?"/>
        <!-- enable or disable recurring module? -->
        <xsl:variable name="isRecurringModule" select="exists($moduleAsset/asset_feature[@feature='svtx:recurring-module-of'])" as="xs:boolean?"/>
        <xsl:choose>
          <xsl:when test="$isRecurringModule">
            <!-- if is already recurring module then 1. delete feature, 2. unlock asset so it can be edited again -->
            <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutAsset">
              <cs:param name="source" select="$moduleAsset"/>
            </cs:command>
            <xsl:variable name="newAsset" as="element(asset)">
              <asset>
                <xsl:copy-of select="$checkedOutAsset/@*"/>
                <xsl:copy-of select="$checkedOutAsset/* except $checkedOutAsset/asset_feature[@feature='svtx:recurring-module-of']"/>
              </asset>
            </xsl:variable>
            <cs:command name="com.censhare.api.assetmanagement.CheckIn">
              <cs:param name="source" select="$newAsset"/>
            </cs:command>
            <xsl:for-each select="$moduleAsset/cs:child-rel()[@key='user.main-content.']">
              <xsl:variable name="currentText" select="." as="element(asset)?"/>
              <xsl:variable name="newTextAsset" as="element(asset)">
                <asset non_owner_access="0">
                  <xsl:copy-of select="$currentText/@* except $currentText/@non_owner_access"/>
                  <xsl:copy-of select="$currentText/* except $currentText/asset_feature[@feature='censhare:owner']"/>
                </asset>
              </xsl:variable>
              <cs:command name="com.censhare.api.assetmanagement.Update">
                <cs:param name="source" select="$newTextAsset"/>
              </cs:command>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <!-- if is NOT a recurring module then 1. add feature asset ref to recurring module, 2. lock asset so it cant be edited anymore -->
            <xsl:variable name="recurringModule" select="svtx:findRecurringModule($moduleAsset/@type)" as="element(asset)?"/>
            <xsl:variable name="recurringModuleTexts" select="$recurringModule/cs:child-rel()[@key='user.main-content.']" as="element(asset)*"/>
            <xsl:for-each select="$moduleAsset/cs:child-rel()[@key='user.main-content.']">
              <xsl:variable name="currentTxt" select="." as="element(asset)?"/>
              <xsl:variable name="textToCopy" select="$recurringModuleTexts[@type=$currentTxt/@type][1]" as="element(asset)?"/>
              <xsl:variable name="storage" select="$textToCopy/storage_item[@key='master']" as="element(storage_item)?"/>

              <xsl:if test="$storage">
                <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
                <xsl:variable name="destFile" select="concat($out, 'text.xml')"/>
                <cs:command name="com.censhare.api.io.Copy">
                  <cs:param name="source" select="$storage[1]"/>
                  <cs:param name="dest" select="$destFile"/>
                </cs:command>
                <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutText">
                  <cs:param name="source" select="."/>
                </cs:command>
                <!-- todo: CHANGE WF from context module or text ? -->
                <xsl:variable name="newTextAsset" as="element(asset)">
                  <asset non_owner_access="1">
                    <!-- -->
                    <xsl:if test="$textToCopy/@wf_id">
                      <xsl:attribute name="wf_id" select="$textToCopy/@wf_id"/>
                    </xsl:if>
                    <xsl:if test="$textToCopy/@wf_step">
                      <xsl:attribute name="wf_step" select="$textToCopy/@wf_step"/>
                    </xsl:if>
                    <!-- -->
                    <xsl:copy-of select="$checkedOutText/@* except $checkedOutText/(@non_owner_access, @wf_id, @wf_step)"/>
                    <xsl:copy-of select="$checkedOutText/* except $checkedOutText/(storage_item, asset_feature[@feature='censhare:owner'])"/>
                    <asset_feature feature="censhare:owner" value_long="{$admin}"/>
                    <storage_item key="master" corpus:asset-temp-file-url="{ $destFile }" element_idx="0" mimetype="text/xml"/>
                  </asset>
                </xsl:variable>
                <cs:command name="com.censhare.api.assetmanagement.CheckIn">
                  <cs:param name="source" select="$newTextAsset"/>
                </cs:command>
              </xsl:if>
            </xsl:for-each>
            <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutAsset">
              <cs:param name="source" select="$moduleAsset"/>
            </cs:command>
            <xsl:variable name="newAsset" as="element(asset)">
              <asset>
                <xsl:copy-of select="$checkedOutAsset/@*"/>
                <xsl:copy-of select="$checkedOutAsset/*"/>
                <asset_feature feature="svtx:recurring-module-of" value_asset_id="{$recurringModule/@id}"/>
              </asset>
            </xsl:variable>
            <cs:command name="com.censhare.api.assetmanagement.CheckIn">
              <cs:param name="source" select="$newAsset"/>
            </cs:command>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:findRecurringModule" as="element(asset)?">
    <xsl:param name="type" as="xs:string?"/>
    <xsl:if test="$type">
      <xsl:copy-of select="(cs:asset()[@censhare:asset.type=$type and @censhare:asset-flag = 'is-template' and @censhare:template-hierarchy='root.content-building-block.recurring-modules.'])[1]"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
