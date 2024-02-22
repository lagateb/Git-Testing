<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:param name="snippetId" select="24523"/>
  <xsl:param name="placeAssetId" select="24609"/>
  <xsl:param name="xOffset" select="-3"/>
  <!-- yOffset wird in einer Variable umgeschrieben -->
  <xsl:param name="yOffset" select="110"/>
  <!--xsl:param name="yOffset" select="114"/-->

  <xsl:param name="moveTargetGroup" select="'Stärken'"/>
  <xsl:param name="moveTargetGroupDummy" select="'StärkenDummy'"/>
  <xsl:param name="moveX" select="0.0"/>
  <!--xsl:param name="moveY" select="63.099"/-->
  <!-- moveY wird in einer Variable umgeschrieben -->
  <xsl:param name="moveY" select="58.95"/>
  <xsl:param name="deleteTargetGroup" select="('TwoPagerSnippet', 'TwoPagerSnipper', 'twoPagerSnippet', 'twoPagerSnipper')"/>

  <xsl:template match="/asset[@type = 'layout.']">
    <xsl:variable name="layoutAsset" select="."/>
    <xsl:message>### SNIPPET ### LAYOUT #### UPDATE</xsl:message>
    <!-- has flexi -->
    <xsl:variable name="existsConfigAssetWithCD21" select="$layoutAsset/asset_element/xmldata/group[contains(@configuration-asset, 'cd21')]/@configuration-asset"/>

    <xsl:variable name="moveY" select="if ($existsConfigAssetWithCD21) then 58.95 else 63.099"/>
    <xsl:variable name="yOffset" select="if ($existsConfigAssetWithCD21) then 110 else 114.000139"/>
    <xsl:variable name="footnoteBoxUid" select="if ($existsConfigAssetWithCD21) then 'b1823' else 'b1361'"/>


    <xsl:variable name="childAssetElementRels" select="child_asset_element_rel[contains(@url, 'group-name=twoPagerSnippet')]" as="element(child_asset_element_rel)*"/>
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

                <!-- no child asset element rels of two pager snippets yet. So the strength box is at default position, time to move it -->
                <xsl:if test="not($childAssetElementRels)">
                  <xsl:for-each select="svtx:getAssetElements(., $moveTargetGroup)">
                    <xsl:variable name="box" select="xmldata/box"/>
                    <xsl:variable name="x" select="$box/@page_x + svtx:mm2pt($moveX)"/>
                    <xsl:variable name="y" select="$box/@page_y + svtx:mm2pt($moveY)"/>
                    <!--  b1361 -->
                    <xsl:if test="not($box/@uid = 'b1361' or $box/@uid = 'b1823')">
                      <command document_ref_id="1" method="move-box" uid="{$box/@uid}" parent_uid="{$box/@page}" width="{$box/@width}" height="{$box/@height}" xoffset="{$x}" yoffset="{$y}"/>
                    </xsl:if>
                  </xsl:for-each>

                  <xsl:for-each select="svtx:getAssetElements(., $moveTargetGroupDummy)">
                    <xsl:variable name="box" select="xmldata/box"/>
                    <xsl:variable name="x" select="$box/@page_x + svtx:mm2pt($moveX)"/>
                    <xsl:variable name="y" select="$box/@page_y + svtx:mm2pt($moveY)"/>
                    <!--  b1361 -->
                    <xsl:if test="not($box/@uid = 'b1361' or $box/@uid = 'b1823')">
                      <command document_ref_id="1" method="move-box" uid="{$box/@uid}" parent_uid="{$box/@page}" width="{$box/@width}" height="{$box/@height}" xoffset="{$x}" yoffset="{$y}"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:if>

                <command method="delete-boxes" document_ref_id="1">
                  <xsl:for-each select="svtx:getAssetElements($layoutAsset, $deleteTargetGroup)">
                    <box uid="{@id_extern}"/>
                  </xsl:for-each>
                </command>

                <!--command document_ref_id="1"
                         method="place-snippet"
                         parent_uid="p1"
                         snippet_asset_element_id="0"
                         snippet_asset_id="{ $snippetId }"
                         place_asset_id="{ $placeAssetId }"
                         xoffset="{ svtx:mm2pt($xOffset) }"
                         yoffset="323.15"/-->
                <command document_ref_id="1"
                         method="place-snippet"
                         parent_uid="p1"
                         snippet_asset_element_id="0"
                         snippet_asset_id="{ $snippetId }"
                         place_asset_id="{ $placeAssetId }"
                         xoffset="{ svtx:mm2pt($xOffset) }"
                         yoffset="{ svtx:mm2pt($yOffset) }"/>

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
