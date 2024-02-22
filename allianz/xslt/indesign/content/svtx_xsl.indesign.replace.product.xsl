<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">


  <xsl:template match="/asset[@type = 'layout.']">
    <xsl:message>==== svtx:xsl.indesign.replace.product</xsl:message>
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>
    <xsl:variable name="targetGroup" select="$rootAsset/asset_feature[@feature='censhare:target-group'][1]/@value_asset_id" as="xs:long?"/>
    <xsl:variable name="originLayoutKey" select="$rootAsset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" as="xs:string?"/>
    <xsl:variable name="originLayoutAsset" select="cs:asset()[@censhare:resource-key=$originLayoutKey]" as="element(asset)?"/>
    <xsl:variable name="indesignStorageItem" select="$originLayoutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:variable name="product" as="element(asset)?">
      <xsl:choose>
        <xsl:when test="$targetGroup">
          <xsl:copy-of select="($rootAsset/cs:parent-rel()[@key='variant.*']/cs:asset()[@censhare:asset.type='layout.*']/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="($rootAsset/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="articleAssets" as="element(asset)*">
      <xsl:for-each select="($product/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']/.[not(exists(asset_feature[@feature='svtx:optional-component' and @value_long = 1]))])">
        <xsl:variable name="targetGroupVariant" select="if ($targetGroup) then (cs:child-rel()[@key='variant.*']/cs:asset()[@censhare:asset.type='article.*' and @censhare:target-group = $targetGroup])[1] else ()" as="element(asset)?"/>
        <xsl:copy-of select="if ($targetGroupVariant) then $targetGroupVariant else ."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="flexiModuleAsset" select="$articleAssets[starts-with(@type, 'article.flexi-module.')][1]" as="element(asset)?"/>

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
                <command method="open" asset_id="{ $rootAsset/@id }" document_ref_id="1"/>
                <command document_ref_id="1" method="correct-document" force-correction="true" force-conversion="true"/>
                <command document_ref_id="1" method="update-asset-element-structure" force="true" delete-target-elements="true"/>
                <!-- article to grp placement -->
                <xsl:copy-of select="$placementCommands"/>
                <!-- image crop edits -->
                <xsl:copy-of select="$editCommands"/>
                <xsl:if test="exists($flexiModuleAsset) and $originLayoutKey = 'svtx:indd.template.twopager.allianz'">
                  <xsl:variable name="layoutSnippet" select="$flexiModuleAsset/asset_feature[@feature='censhare:layout-snippet']/@value_asset_id" as="xs:long?"/>
                  <xsl:if test="$layoutSnippet">
                    <cs:command name="com.censhare.api.transformation.AssetTransformation">
                      <cs:param name="key" select="'svtx:xsl:indesign.render.snippet.cmd'"/>
                      <cs:param name="source" select="$rootAsset"/>
                      <cs:param name="xsl-parameters">
                        <cs:param name="snippetId" select="$layoutSnippet"/>
                        <cs:param name="placeAssetId" select="$flexiModuleAsset/@id"/>
                      </cs:param>
                    </cs:command>
                  </xsl:if>
                </xsl:if>

                <xsl:if test="$originLayoutKey = 'svtx:indd.template.bedarf_und_beratung.flyer.allianz'">
                  <command method="delete-boxes" document_ref_id="1">
                    <xsl:for-each select="svtx:getAssetElements($rootAsset, 'flyerSnippet')">
                      <box uid="{@id_extern}"/>
                    </xsl:for-each>
                  </command>
                </xsl:if>

                <xsl:if test="exists($flexiModuleAsset)">
                  <xsl:variable name="layoutSnippet" select="$flexiModuleAsset/asset_feature[@feature='censhare:layout-snippet']/@value_asset_id" as="xs:long?"/>
                  <xsl:choose>
                    <xsl:when test="$originLayoutKey = 'svtx:indd.template.twopager.allianz' and exists($layoutSnippet)">
                      <cs:command name="com.censhare.api.transformation.AssetTransformation">
                        <cs:param name="key" select="'svtx:xsl:indesign.render.snippet.cmd'"/>
                        <cs:param name="source" select="$rootAsset"/>
                        <cs:param name="xsl-parameters">
                          <cs:param name="snippetId" select="$layoutSnippet"/>
                          <cs:param name="placeAssetId" select="$flexiModuleAsset/@id"/>
                        </cs:param>
                      </cs:command>
                    </xsl:when>
                    <xsl:when test="$originLayoutKey = 'svtx:indd.template.bedarf_und_beratung.flyer.allianz' and exists($layoutSnippet)">
                      <command document_ref_id="1" method="place-snippet" parent_uid="p5" snippet_asset_element_id="0" snippet_asset_id="{$layoutSnippet}" place_asset_id="{$flexiModuleAsset/@id}" yoffset="{svtx:mm2pt(82.817)}" xoffset="0"/>
                      <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key='svtx:indesign.create-qr-code']" as="xs:long?"/>
                      <xsl:variable name="flexiModuleMainContent" select="$flexiModuleAsset/cs:child-rel()[@key='user.main-content.']" as="element(asset)?"/>
                      <xsl:variable name="siMainContent" select="$flexiModuleMainContent/storage_item[@key='master']" as="element(storage_item)?"/>
                      <xsl:variable name="content" select="if ($siMainContent/@url) then doc($siMainContent/@url) else ()"/>
                      <xsl:variable name="url" select="$content/article/content/calltoaction-link/@url" as="xs:string?"/>
                      <xsl:if test="$url and $scriptId">
                        <command document_ref_id="1" method="script" script_asset_id="{$scriptId}">
                          <param name="url" value="{$url}"/>
                        </command>
                      </xsl:if>
                    </xsl:when>
                  </xsl:choose>
                </xsl:if>

                <command document_ref_id="1" scale="1.0" method="preview"/>
                <command method="save" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <xsl:copy-of select="$rootAsset"/>
                <xsl:copy-of select="$articleAssets"/>
              </assets>
            </cmd>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:variable name="saveResult" select="$renderResult/cmd/renderer/command[@method = 'save']" as="element(command)?"/>
      <xsl:variable name="previewResult" select="$renderResult/cmd/renderer/command[@method = 'preview']" as="element(command)?"/>
      <xsl:variable name="layoutResult" select="$renderResult/cmd/assets/asset[1]" as="element(asset)?"/>

      <xsl:variable name="allTextAssets" select="$layoutResult/cs:child-rel()[@key='actual.']/cs:asset()[@censhare:asset.type='text.*']" as="element(asset)*"/>
      <xsl:variable name="allTextsAreReleased" select="every $text in $allTextAssets satisfies ($text/@wf_id = 10 and $text/@wf_step = 30)" as="xs:boolean?"/>
      <xsl:variable name="updated">
        <cs:command name="com.censhare.api.assetmanagement.Update">
          <cs:param name="source">
            <asset>
              <xsl:choose>
                <xsl:when test="$allTextsAreReleased">
                  <xsl:attribute name="wf_id" select="10"/>
                  <xsl:attribute name="wf_step" select="30"/>
                  <xsl:copy-of select="$layoutResult/@*[not(local-name() = ('wf_id', 'wf_step'))]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$layoutResult/@*"/>
                </xsl:otherwise>
              </xsl:choose>
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
      </xsl:variable>
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