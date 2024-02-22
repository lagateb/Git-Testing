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

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="mainArticle" select="($rootAsset/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*'])[1]" as="element(asset)?"/>
  <xsl:variable name="textAssets" select="$mainArticle/cs:child-rel()[@key='user.main-content.']" as="element(asset)*"/>

  <!-- match text -->
  <xsl:template match="/asset">
    <!-- ref modules -->
    <xsl:variable name="updatedTextAssets" as="element(asset)*">
      <xsl:apply-templates select="$mainArticle/cs:feature-ref()[@key = 'svtx:recurring-module-of']" mode="module"/>
    </xsl:variable>
    <!-- reset media workflow for indd and pptx assets-->
    <xsl:variable name="article" select="$updatedTextAssets/cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
    <xsl:variable name="pptx" select="$article/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type='presentation.slide.*']" as="element(asset)*"/>
    <xsl:for-each select="$pptx">
      <cs:command name="com.censhare.api.assetmanagement.Update" returning="updatedAssetXml">
        <cs:param name="source">
          <asset wf_id="80" wf_step="10">
            <xsl:copy-of select="@* except (@wf_id, @wf_step)"/>
            <xsl:copy-of select="node()"/>
          </asset>
        </cs:param>
      </cs:command>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="asset" mode="module">
    <xsl:apply-templates select="cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type=$rootAsset/@type]" mode="txt"/>
  </xsl:template>

  <xsl:template match="asset[starts-with(@type, 'text.')]" mode="txt">
    <xsl:variable name="currentAsset" select="." as="element(asset)?"/>
    <xsl:variable name="textToCopy" select="$textAssets[@type=$currentAsset/@type][1]" as="element(asset)?"/>
    <xsl:variable name="storage" select="$textAssets[@type=$currentAsset/@type][1]/storage_item[@key='master']" as="element(storage_item)?"/>
    <!--and not($storage/@hashcode = $currentAsset/storage_item[@key='master'][1]/@hashcode)-->
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
      <xsl:variable name="newTextAsset" as="element(asset)">
        <asset non_owner_access="1">
          <xsl:if test="$textToCopy/@wf_id">
            <xsl:attribute name="wf_id" select="$textToCopy/@wf_id"/>
          </xsl:if>
          <xsl:if test="$textToCopy/@wf_step">
            <xsl:attribute name="wf_step" select="$textToCopy/@wf_step"/>
          </xsl:if>
          <xsl:copy-of select="$checkedOutText/@* except $checkedOutText/(@non_owner_access, @wf_id, @wf_step)"/>
          <xsl:copy-of select="$checkedOutText/* except $checkedOutText/storage_item"/>
          <storage_item key="master" corpus:asset-temp-file-url="{ $destFile }" element_idx="0" mimetype="text/xml"/>
        </asset>
      </xsl:variable>
      <cs:command name="com.censhare.api.assetmanagement.CheckIn">
        <cs:param name="source" select="$newTextAsset"/>
      </cs:command>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
