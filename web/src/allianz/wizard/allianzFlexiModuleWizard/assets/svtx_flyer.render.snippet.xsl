<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:param name="snippetId" select="24523"/>
  <xsl:param name="placeAssetId" select="24609"/>

  <xsl:param name="deleteTargetGroup" select="('flyerSnippet')"/>

  <xsl:template match="/asset[@type = 'layout.']">
    <xsl:variable name="layoutAsset" select="."/>
    <xsl:message>### SNIPPET ### LAYOUT #### UPDATE</xsl:message>
    <xsl:variable name="indesignStorageItem" select="$layoutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:if test="$indesignStorageItem">
      <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)" as="xs:string"/>
      <xsl:variable name="renderResult">
        <cs:command name="com.censhare.api.Renderer.Render">
          <cs:param name="facility" select="$appVersion"/>
          <cs:param name="instructions">
            <cmd>
              <renderer>
                <command method="open" asset_id="{ $layoutAsset/@id }" document_ref_id="1"/>
                <command document_ref_id="1" method="correct-document" force-correction="true" force-conversion="true"/>
								<command method="delete-boxes" document_ref_id="1">
                    <xsl:for-each select="svtx:getAssetElements($layoutAsset, 'flyerSnippet')">
                      <box uid="{@id_extern}"/>
                    </xsl:for-each>
                </command>
                <command document_ref_id="1" method="place-snippet" parent_uid="p5" snippet_asset_element_id="0" snippet_asset_id="{$snippetId}" place_asset_id="{$placeAssetId}" yoffset="{svtx:mm2pt(82.817)}" xoffset="0"/>
                <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key='svtx:indesign.create-qr-code']" as="xs:long?"/>
                <xsl:variable name="placeAsset" select="cs:get-asset($placeAssetId)" as="element(asset)?"/>
                <xsl:variable name="mainContent" select="($placeAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*'])" as="element(asset)?"/>
                <xsl:variable name="siMainContent" select="$mainContent/storage_item[@key='master']" as="element(storage_item)?"/>
                <xsl:variable name="content" select="if ($siMainContent/@url) then doc($siMainContent/@url) else ()"/>
                <xsl:variable name="url" select="$content/article/content/calltoaction-link/@url" as="xs:string?"/>
                <xsl:if test="$url and $scriptId">
                  <command document_ref_id="1" method="script" script_asset_id="{$scriptId}">
                    <param name="url" value="{$url}"/>
                  </command>
                </xsl:if>
                <command document_ref_id="1" scale="1.0" method="preview"/>
                <command method="save" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <!-- Add assets -->
                <!-- layout -->
                <xsl:copy-of select="$layoutAsset"/>
                <!-- place assets -->
                <xsl:copy-of select="cs:get-asset($placeAssetId)"/>
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
            <xsl:copy-of select="$layoutResult/* except $layoutResult/(storage_item, asset_feature, if (exists($layoutResult/asset_feature[@feature='censhare:target-group'])) then child_asset_rel[@key='variant.'] else ())"/>
            <xsl:copy-of select="$layoutResult/asset_feature[@feature=('svtx:layout-template', 'svtx:layout-template-resource-key', 'svtx:layout-template-creation-date', 'svtx:layout-template-version', 'svtx:media-channel', 'censhare:target-group', 'svtx:layout-print-number')]"/>
          </asset>
        </cs:param>
      </cs:command>
      <xsl:copy-of select="$renderResult"/>
    </xsl:if>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getAssetElements" as="element(asset_element)*">
    <xsl:param name="layout" as="element(asset)?"/>
    <xsl:param name="group" as="xs:string?"/>
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
