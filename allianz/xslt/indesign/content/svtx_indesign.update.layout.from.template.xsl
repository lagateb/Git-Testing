<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

  <!--

  ACHTUNG:

  wird vorerst nicht mehr benutzt. Abgelöst von der Transformation:

  svtx:xsl.indesign.copy.layout.and.replace.product
    -> svtx:xsl.indesign.replace.product

  -->

  <xsl:template match="/asset[@type = 'layout.']">
   <xsl:message>==== svtx:indesign.update.layout.from.template</xsl:message>
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>
    <xsl:variable name="originLayoutKey" select="$rootAsset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" as="xs:string?"/>
    <xsl:variable name="originLayoutAsset" select="cs:asset()[@censhare:resource-key=$originLayoutKey]" as="element(asset)?"/>
    <xsl:variable name="indesignStorageItem" select="$originLayoutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:variable name="product" select="($rootAsset/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type='product.*'])[1]" as="element(asset)?"/>
    <xsl:variable name="articleAssets" select="$product/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
    <xsl:variable name="flexiModuleAsset" select="$articleAssets[starts-with(@type, 'article.flexi-module.')][1]" as="element(asset)?"/>
    <!-- copy storage item from layout template -->
    <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
    <xsl:variable name="destFile" select="concat($out, 'template.indd')"/>
    <cs:command name="com.censhare.api.io.Copy">
      <cs:param name="source" select="$indesignStorageItem[1]"/>
      <cs:param name="dest" select="$destFile"/>
    </cs:command>

    <!-- replace copied storage item with current one -->
    <xsl:variable name="checkedOutAsset" select="svtx:checkOutAsset($rootAsset)"/>
    <xsl:variable name="newAsset" as="element(asset)?">
      <asset>
        <xsl:copy-of select="$checkedOutAsset/@*"/>
        <xsl:copy-of select="$checkedOutAsset/(asset_feature, parent_asset_rel)"/>
        <xsl:copy-of select="$originLayoutAsset/(asset_element, child_asset_rel, child_asset_element_rel)"/>
        <storage_item key="master" corpus:asset-temp-file-url="{ $destFile }" app_version="{ $indesignStorageItem/@app_version }" element_idx="0" mimetype="{ $indesignStorageItem/@mimetype }"/>
      </asset>
    </xsl:variable>
    <xsl:variable name="checkedInAsset" select="svtx:checkInAsset($newAsset)" as="element(asset)?"/>

    <!-- commands to place article into layout groups -->
    <xsl:variable name="placementCommands">
      <xsl:apply-templates select="$articleAssets" mode="place-cmd">
        <xsl:with-param name="key" select="$originLayoutKey"/>
      </xsl:apply-templates>
    </xsl:variable>

    <!-- commands to edit placed pictures by crop keys -->
    <xsl:variable name="editCommands">
      <xsl:apply-templates select="$articleAssets" mode="edit-cmd">
        <xsl:with-param name="layout" select="$rootAsset"/>
      </xsl:apply-templates>
    </xsl:variable>


    <xsl:if test="$indesignStorageItem">
      <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)" as="xs:string"/>
      <xsl:variable name="renderResult">
        <cs:command name="com.censhare.api.Renderer.Render">
          <cs:param name="facility" select="$appVersion"/>
          <cs:param name="instructions">
            <cmd>
              <renderer>
                <command method="open" asset_id="{ $checkedInAsset/@id }" document_ref_id="1"/>
                <command document_ref_id="1" method="correct-document" force-correction="true" force-conversion="true"/>
                <!-- article to grp placement -->
                <xsl:copy-of select="$placementCommands"/>
                <!-- image crop edits -->
                <xsl:copy-of select="$editCommands"/>
                <xsl:if test="exists($flexiModuleAsset) and $originLayoutKey = 'svtx:indd.template.twopager.allianz'">
                  <xsl:variable name="layoutSnippet" select="$flexiModuleAsset/asset_feature[@feature='censhare:layout-snippet']/@value_asset_id" as="xs:long?"/>
                  <xsl:if test="$layoutSnippet">
                    <cs:command name="com.censhare.api.transformation.AssetTransformation">
                      <cs:param name="key" select="'svtx:xsl:indesign.render.snippet.cmd'"/>
                      <cs:param name="source" select="$checkedInAsset"/>
                      <cs:param name="xsl-parameters">
                        <cs:param name="snippetId" select="$layoutSnippet"/>
                        <cs:param name="placeAssetId" select="$flexiModuleAsset/@id"/>
                      </cs:param>
                    </cs:command>
                  </xsl:if>
                </xsl:if>
                <command document_ref_id="1" scale="1.0" method="preview"/>
                <command method="save" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <xsl:copy-of select="$checkedInAsset"/>
                <xsl:copy-of select="$articleAssets"/>
              </assets>
            </cmd>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:variable name="saveResult" select="$renderResult/cmd/renderer/command[@method = 'save']" as="element(command)?"/>
      <xsl:variable name="previewResult" select="$renderResult/cmd/renderer/command[@method = 'preview']" as="element(command)?"/>
      <xsl:variable name="layoutResult" select="$renderResult/cmd/assets/asset[1]" as="element(asset)?"/>

      <xsl:copy-of select="$layoutResult"/>

      <cs:command name="com.censhare.api.assetmanagement.Update">
        <cs:param name="source">
          <asset>
            <xsl:copy-of select="$layoutResult/@*"/>
            <!--<xsl:copy-of select="$checkedInAsset/(asset_feature,parent_asset_rel)"/>-->
            <xsl:copy-of select="$layoutResult/node() except $layoutResult/storage_item"/>
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
          </asset>
        </cs:param>
      </cs:command>

    </xsl:if>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset" mode="place-cmd">
    <xsl:param name="key"/>
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:indesign.group.placement.cmd'"/>
      <cs:param name="source" select="."/>
      <cs:param name="xsl-parameters">
        <cs:param name="template-key" select="$key"/>
      </cs:param>
    </cs:command>
  </xsl:template>

  <!-- -->
  <xsl:template match="asset" mode="edit-cmd">
    <xsl:param name="layout"/>
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:indesign.pictures.edit.placement'"/>
      <cs:param name="source" select="$layout"/>
      <cs:param name="xsl-parameters">
        <cs:param name="placeAssetID" select="@id"/>
      </cs:param>
    </cs:command>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:checkOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <cs:command name="com.censhare.api.assetmanagement.CheckOut">
      <cs:param name="source">
        <xsl:copy-of select="$asset"/>
      </cs:param>
    </cs:command>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:checkInAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <cs:command name="com.censhare.api.assetmanagement.CheckIn">
      <cs:param name="source">
        <xsl:copy-of select="$asset"/>
      </cs:param>
    </cs:command>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getAssetElements" as="element(asset_element)*">
    <xsl:param name="layout" as="element(asset)?"/>
    <xsl:param name="group" as="xs:string?"/>
    <xsl:copy-of select="$layout/asset_element[xmldata/group[lower-case(@group-name) eq lower-case($group)]]"/>
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