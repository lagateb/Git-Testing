<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:util.handle.pptx/storage/master/file" />

  <xsl:param name="deleteTargetGroup" select="('TwoPagerSnippet', 'TwoPagerSnipper', 'twoPagerSnippet', 'twoPagerSnipper')"/>
  <xsl:param name="moveTargetGroup" select="'Stärken'"/>
  <xsl:param name="moveTargetGroupDummy" select="'StärkenDummy'"/>
  <xsl:param name="moveX" select="0.0"/>
  <xsl:param name="moveY" select="-63.099"/>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <!-- -->
  <xsl:template match="/asset[starts-with(@type, 'article.flexi-module.') or starts-with(@type, 'article.optional-module.') or starts-with(@type, 'article.free-module.')]">
    <xsl:variable name="isFlexiModule" select="$rootAsset/@type = 'article.flexi-module.'" as="xs:boolean"/>
    <xsl:variable name="hasTargetGroup" select="exists($rootAsset/asset_feature[@feature = 'censhare:target-group'])" as="xs:boolean"/>
    <xsl:variable name="isVariant" select="exists((cs:parent-rel()[@key='variant.*']/cs:asset()[@censhare:asset.type = 'article.*'])[1])" as="xs:boolean"/>
    <xsl:variable name="textAssets" select="$rootAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.*']" as="element(asset)*"/>
    <xsl:variable name="layouts" select="$textAssets/cs:parent-rel()[@key='actual.']/cs:asset()[@censhare:asset.type = 'layout.*']" as="element(asset)*"/>
    <xsl:variable name="pptxSlides" select="$rootAsset/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.*']" as="element(asset)*"/>
    <xsl:variable name="pptxIssues" select="$pptxSlides/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type='presentation.issue.']" as="element(asset)*"/>

    <xsl:if test="$isFlexiModule">
      <xsl:apply-templates select="$layouts" mode="delete-snippet"/>
    </xsl:if>

    <xsl:apply-templates select="$pptxSlides" mode="delete"/>
    <xsl:apply-templates select="$textAssets" mode="delete"/>
    <xsl:apply-templates select="$rootAsset" mode="delete"/>

    <xsl:for-each select="$pptxIssues">
      <cs:command name="com.censhare.api.event.Send">
        <cs:param name="source">
          <event target="CustomAssetEvent" param2="0" param1="1" param0="{@id}" method="svtx-pptx-merge"/>
        </cs:param>
      </cs:command>
    </xsl:for-each>
  </xsl:template>



  <!-- -->
  <xsl:template match="asset[starts-with(@type, 'layout.')]" mode="delete-snippet">
    <xsl:message>### Delete Snippet for Layout: <xsl:value-of select="(@name, @id)" separator=" - "/> </xsl:message>
    <xsl:variable name="layout" select="." as="element(asset)"/>
    <xsl:variable name="indesignStorageItem" select="storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:variable name="snippetIsPlaced" select="exists(asset_element[xmldata/group[@group-name='twoPagerSnippet']])" as="xs:boolean"/>

    <xsl:variable name="existsConfigAssetWithCD21" select="$layout/asset_element/xmldata/group[contains(@configuration-asset, 'cd21')]/@configuration-asset"/>
    <xsl:variable name="moveY" select="if ($existsConfigAssetWithCD21) then -58.95 else -63.099"/>
    <xsl:variable name="footnoteBoxUid" select="if ($existsConfigAssetWithCD21) then 'b1823' else 'b1361'"/>

    <xsl:if test="$indesignStorageItem and $snippetIsPlaced">
      <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)" as="xs:string"/>
      <xsl:variable name="renderResult">
        <cs:command name="com.censhare.api.Renderer.Render">
          <cs:param name="facility" select="$appVersion"/>
          <cs:param name="instructions">
            <cmd>
              <renderer>
                <command method="open" asset_id="{ $layout/@id }" document_ref_id="1"/>
                <command document_ref_id="1" method="correct-document" force-correction="true" force-conversion="true"/>
                <command method="delete-boxes" document_ref_id="1">
                  <xsl:for-each select="svtx:getAssetElements($layout, $deleteTargetGroup)">
                    <box uid="{@id_extern}"/>
                  </xsl:for-each>
                </command>
                <xsl:for-each select="svtx:getAssetElements($layout, $moveTargetGroup)">
                  <xsl:variable name="box" select="xmldata/box"/>
                  <xsl:variable name="x" select="$box/@page_x + svtx:mm2pt($moveX)"/>
                  <xsl:variable name="y" select="$box/@page_y + svtx:mm2pt($moveY)"/>
                  <xsl:if test="not($box/@uid = 'b1361' or $box/@uid = 'b1823')">
                    <command document_ref_id="1" method="move-box" uid="{$box/@uid}" parent_uid="{$box/@page}" width="{$box/@width}" height="{$box/@height}" xoffset="{$x}" yoffset="{$y}"/>
                  </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="svtx:getAssetElements($layout, $moveTargetGroupDummy)">
                  <xsl:variable name="box" select="xmldata/box"/>
                  <xsl:variable name="x" select="$box/@page_x + svtx:mm2pt($moveX)"/>
                  <xsl:variable name="y" select="$box/@page_y + svtx:mm2pt($moveY)"/>
                  <xsl:if test="not($box/@uid = 'b1361' or $box/@uid = 'b1823')">
                    <command document_ref_id="1" method="move-box" uid="{$box/@uid}" parent_uid="{$box/@page}" width="{$box/@width}" height="{$box/@height}" xoffset="{$x}" yoffset="{$y}"/>
                  </xsl:if>
                </xsl:for-each>
                <command document_ref_id="1" method="update-placeholder"/>
                <command delete-target-elements="false" document_ref_id="1" force="true" method="update-asset-element-structure" sync-target-elements="false"/>
                <command document_ref_id="1" scale="1.0" method="preview"/>
                <command method="save" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <!-- Add assets -->
                <!-- layout -->
                <xsl:copy-of select="$layout"/>
              </assets>
            </cmd>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:variable name="saveResult" select="$renderResult/cmd/renderer/command[@method = 'save']" as="element(command)?"/>
      <xsl:variable name="previewResult" select="$renderResult/cmd/renderer/command[@method = 'preview']" as="element(command)?"/>
      <xsl:variable name="layoutResult" select="$renderResult/cmd/assets/asset[1]" as="element(asset)?"/>
      <cs:command name="com.censhare.api.assetmanagement.Update">
        <cs:param name="source">
          <asset type="layout." application="indesign">
            <xsl:copy-of select="$layoutResult/@*"/>
            <storage_item app_version="{$saveResult/@corpus:app_version}"
                          key="master" element_idx="0" mimetype="application/indesign"
                          corpus:asset-temp-filepath="{$saveResult/@corpus:asset-temp-filepath}"
                          corpus:asset-temp-filesystem="{$saveResult/@corpus:asset-temp-filesystem}"/>
            <xsl:for-each select="$previewResult/file">
              <storage_item key="preview" mimetype="image/jpeg" element_idx="{@element_idx}">
                <xsl:variable name="fileSystem" select="@corpus:asset-temp-filesystem"/>
                <xsl:variable name="filePath" select="@corpus:asset-temp-filepath"/>
                <xsl:variable name="currentPath" select="concat('censhare:///service/filesystem/', $fileSystem, '/', tokenize($filePath, ':')[2])"/>
                <xsl:attribute name="corpus:asset-temp-file-url" select="$currentPath"/>
              </storage_item>
            </xsl:for-each>
            <xsl:copy-of select="$layoutResult/* except $layoutResult/(storage_item, asset_feature)"/>
            <xsl:copy-of select="$layoutResult/asset_feature[@feature=('svtx:layout-template', 'svtx:layout-template-resource-key', 'svtx:media-channel', 'censhare:target-group', 'svtx:layout-print-number')]"/>
          </asset>
        </cs:param>
      </cs:command>
    </xsl:if>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset" mode="delete">
    <cs:command name="com.censhare.api.assetmanagement.Delete">
      <cs:param name="source" select="@id"/>
      <cs:param name="state" select="'physical'"/>
    </cs:command>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getAssetElements" as="element(asset_element)*">
    <xsl:param name="layout" as="element(asset)?"/>
    <xsl:param name="group" as="xs:string*"/>
    <xsl:copy-of select="$layout/asset_element[xmldata/group[@group-name = $group]]"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:mm2pt" as="xs:double">
    <xsl:param name="mm" as="xs:double"/>
    <xsl:sequence select="$mm div 0.3527777778"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:pt2mm" as="xs:double">
    <xsl:param name="pt" as="xs:double"/>
    <xsl:sequence select="$pt * 0.3527777778"/>
  </xsl:function>

</xsl:stylesheet>
