<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="xs cs csc">

  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

  <!-- parameters -->
  <xsl:param name="selectedAssets"/>                           <!-- list of <selectedAsset id="123456" self_versioned="asset/id/123456/version/21"/> -->
  <xsl:param name="dataModelMode" select="'separated'"/>       <!-- "separated" or "combined" -->
  <xsl:param name="featureGroup" select="'all'"/>              <!-- "all" or resource key from feature group -->
  <xsl:param name="dataAxesOrientation" select="'vertical'"/>  <!-- "horizontal" or "vertical" -->
  <xsl:param name="viewInheritanceInfo" select="true()"/>     <!-- "true" or "false" -->

  <xsl:param name="channel"/>
  <xsl:param name="outputChannel"/>
  <xsl:param name="printItem"/>
  <xsl:param name="textSize"/>

  <!-- global variables -->
  <xsl:variable name="urlPrefix" select="'/censhare5/client/rest/service/'"/>
  <xsl:variable name="language" select="csc:getLoggedInPartyLocale()"/>
  <xsl:variable name="searchFeatureGroupIDs" select="('censhare:product')"/>
  <xsl:variable name="skipFeatureGroupIDs" select="('censhare:product')"/>
  <xsl:variable name="isDataModelCombinedMode" select="$dataModelMode='combined'"/>
  <xsl:variable name="isDataVerticalOrientation" select="$dataAxesOrientation='vertical'"/>
  <xsl:variable name="assetIDs" select="if ($selectedAssets/@id) then $selectedAssets/@id else asset/@id"/>  <!-- workaround to test this transformation also in the xslt test window -->
  <xsl:variable name="assets" select="for $x in $assetIDs return cs:get-asset(xs:integer($x))"/>
  <xsl:variable name="productFeatureIDs" select="cs:master-data('feature_category')[@feature_group=$searchFeatureGroupIDs]/@feature"/>
  <xsl:variable name="features" select="csc:getFeaturesOfFeatureKeys($productFeatureIDs)"/>
  <xsl:variable name="dialogGroupResourceKey" select="if (string-length($featureGroup) gt 0 and $featureGroup != 'all') then $featureGroup else ()"/>
  <xsl:variable name="dataModel" select="csc:getDataModel($assets, $features, $dialogGroupResourceKey)"/>

  <!-- root match -->
  <xsl:template match="/">
    <!-- debug outputs-->
    <!--features><xsl:copy-of select="$features"/></features-->
    <!--xsl:copy-of select="$dataModel"/-->

    <!-- report template content node -->
    <content>
      <xsl:call-template name="csc:outputProductHtml"/>
    </content>

    <!-- report template config node -->
    <config censhare:_annotation.target_format="json">
      <xsl:call-template name="csc:outputProductTraits"/>
    </config>
  </xsl:template>

  <!-- output product HTML -->
  <xsl:template name="csc:outputProductHtml">
    <html>
      <body>
        <div id="svtx_content" style="padding:1.5rem">
          <xsl:if test="$assets">
            <xsl:variable name="options" select="concat('{&quot;id&quot;:',$assets[1]/@id,'}')"/>
            <div style="padding-bottom: 1rem;">
              <cs-include-dialog key="'svtx:metadata.guarantee_assets'" svtx-custom-param="{$options}"></cs-include-dialog>
            </div>
          </xsl:if>
        </div>
      </body>
    </html>
  </xsl:template>

  <!-- output product traits -->
  <xsl:template name="csc:outputProductTraits">
    <traits censhare:_annotation.arraygroup="true">
      <xsl:for-each select="distinct-values($dataModel//feature/@trait)">
        <trait><xsl:value-of select="."/></trait>
      </xsl:for-each>
    </traits>
  </xsl:template>

  <!-- get data model (tabs, groups, features and values) -->
  <xsl:function name="csc:getDataModel">
    <xsl:param name="valueAssets" as="element(asset)*"/>
    <xsl:param name="features" as="element(feature)*"/>
    <xsl:param name="dialogGroupResourceKey" as="xs:string?"/>
    <xsl:variable name="assetsLookupRules">
      <xsl:for-each select="$valueAssets">
        <asset id="{@id}" name="{@name}">
          <xsl:copy-of select="csc:getAssetFeatureLookupRules(., $features)"/>
        </asset>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="dialogAsset" select="csc:getResourceAsset('censhare:metadata.product.dialog')"/>
    <xsl:variable name="dialogChildGroups" select="if ($dialogAsset) then $dialogAsset/asset_feature[@feature='censhare:dialog.tab' or @feature='censhare:dialog.group'] else ()"/>
    <dataModel>
      <xsl:choose>
        <!-- grouping defined by dialogGroupResourceKey -->
        <xsl:when test="string-length($dialogGroupResourceKey) gt 0">
          <xsl:variable name="groupAsset" select="csc:getResourceAsset($dialogGroupResourceKey)"/>
          <group name="{csc:getLocalizedAssetName($groupAsset)}" type="{if ($groupAsset/@type='module.dialog.tab.') then 'tab' else 'group'}">
            <xsl:sequence select="csc:getDisplayProductChildGroups($valueAssets, $groupAsset, $features, $assetsLookupRules, 1)"/>
          </group>
        </xsl:when>
        <!-- grouping defined by assets -->
        <xsl:when test="$dialogChildGroups">
          <xsl:choose>
            <!-- tabs -->
            <xsl:when test="$dialogChildGroups/@feature='censhare:dialog.tab'">
              <xsl:for-each select="$dialogChildGroups[@feature='censhare:dialog.tab']">
                <xsl:sort select="@sorting" data-type="number"/>
                <xsl:sort select="if (@label) then @label else @name"/>
                <xsl:variable name="groupAsset" select="csc:getResourceAsset(@value_asset_key_ref)"/>
                <xsl:if test="$groupAsset">
                  <group name="{csc:getLocalizedAssetName($groupAsset)}" type="tab">
                    <xsl:sequence select="csc:getDisplayProductChildGroups($valueAssets, $groupAsset, $features, $assetsLookupRules, 1)"/>
                  </group>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <!-- groups -->
            <xsl:otherwise>
              <xsl:sequence select="csc:getDisplayProductChildGroups($valueAssets, $dialogAsset, $features, $assetsLookupRules, 1)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- grouping defined by feature group assignment -->
        <xsl:otherwise>
          <!-- get assigned groups -->
          <xsl:variable name="allFeatureCategories" select="cs:master-data('feature_category')"/>
          <xsl:variable name="featureGroupIDs" select="$allFeatureCategories[@feature=$features/@key and not(@feature_group=$skipFeatureGroupIDs)]/@feature_group"/>
          <xsl:variable name="allFeatureGroups" select="cs:master-data('feature_group')"/>
          <xsl:variable name="featureGroups" select="$allFeatureGroups[@key=$featureGroupIDs]"/>
          <xsl:for-each select="$featureGroups">
            <xsl:sort select="@sorting" data-type="number"/>
            <xsl:sort select="if (@label) then @label else @name"/>
            <xsl:variable name="featureGroup" select="."/>
            <xsl:variable name="groupXml">
              <group name="{if (@label) then @label else @name}" type="group">
                <xsl:variable name="groupfeatureIDs" select="$allFeatureCategories[@feature_group=$featureGroup/@key]/@feature"/>
                <xsl:variable name="groupFeatures" select="$features[@key=$groupfeatureIDs]"/>
                <xsl:for-each select="$groupFeatures">
                  <xsl:sort select="@sorting" data-type="number"/>
                  <xsl:sort select="if (@label) then @label else @name"/>
                  <xsl:copy-of select="csc:checkFeature(.)"/>
                </xsl:for-each>
              </group>
            </xsl:variable>
            <xsl:if test="$groupXml/group/feature">
              <xsl:copy-of select="$groupXml"/>
            </xsl:if>
          </xsl:for-each>
          <!-- add features which are not assigned to a group -->
          <xsl:variable name="assignedGroupfeatureIDs" select="$allFeatureCategories[@feature_group=$featureGroups/@key]/@feature"/>
          <xsl:variable name="groupFeatures" select="$features[not(@key=$assignedGroupfeatureIDs)]"/>
          <xsl:if test="$groupFeatures">
            <group name="{{{{'csCommonTranslations.others' | csTranslate}}}}" type="group">
              <xsl:for-each select="$groupFeatures">
                <xsl:sort select="@sorting" data-type="number"/>
                <xsl:sort select="if (@label) then @label else @name"/>
                <xsl:copy-of select="csc:checkFeature(.)"/>
              </xsl:for-each>
            </group>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </dataModel>
  </xsl:function>

  <!--
       Returns the given feature if it is enabled and if it is stored as "classical" asset_feature and this is present on
       at least one of the selected assets or if it is not stored as asset_feature (e.g. asset attribute, function, etc.).
  -->
  <xsl:function name="csc:checkFeature" as="element(feature)?">
    <xsl:param name="feature" as="element(feature)"/>
    <xsl:if test="boolean($feature/@enabled) and (not($feature/@storage = (0, 1)) or $feature/@target_object_type != 'asset' or $assets/asset_feature[@feature=$feature/@key])">
      <xsl:copy-of select="$feature"/>
    </xsl:if>
  </xsl:function>

  <!-- get display product child groups of given asset -->
  <xsl:function name="csc:getDisplayProductChildGroups">
    <xsl:param name="valueAssets" as="element(asset)*"/>
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="features" as="element(feature)*"/>
    <xsl:param name="assetsLookupRules" as="element(asset)*"/>
    <xsl:param name="groupLevel" as="xs:integer"/>
    <!-- add groups -->
    <xsl:for-each select="$asset/asset_feature[@feature='censhare:dialog.group']">
      <xsl:sort select="@sorting" data-type="number"/>
      <xsl:sort select="if (@label) then @label else @name"/>
      <xsl:variable name="groupAsset" select="csc:getResourceAsset(@value_asset_key_ref)"/>
      <group name="{csc:getLocalizedAssetName($groupAsset)}" type="group" level="$groupLevel">
        <xsl:sequence select="csc:getDisplayProductChildGroups($valueAssets, $groupAsset, $features, $assetsLookupRules, $groupLevel + 1)"/>
      </group>
    </xsl:for-each>
    <!-- add features -->
    <xsl:for-each select="$asset/asset_feature[@feature='censhare:module.feature']">
      <xsl:sort select="@sorting" data-type="number"/>
      <xsl:sort select="if (@label) then @label else @name"/>
      <xsl:variable name="resourceKey" select="@value_asset_key_ref"/>
      <xsl:copy-of select="csc:checkFeature($features[@asset_resource_key=$resourceKey])"/>
    </xsl:for-each>
  </xsl:function>

  <!-- output group row -->
  <xsl:template name="csc:outputGroupRow">
    <xsl:param name="group" as="element(group)"/>
    <xsl:param name="columnCount" as="xs:integer"/>
    <xsl:if test="$group//feature">
      <!-- group header -->
      <tr style="background: none;">
        <td colspan="{1 + $columnCount}">
          <h6 class="cs-line-01"><xsl:value-of select="$group/@name"/></h6>
        </td>
      </tr>
      <!-- groups -->
      <xsl:for-each select="$group/group">
        <xsl:call-template name="csc:outputGroupRow">
          <xsl:with-param name="group" select="."/>
          <xsl:with-param name="columnCount" select="$columnCount"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="$group/feature">
        <xsl:call-template name="csc:outputFeatureRow">
          <xsl:with-param name="feature" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!-- output feature row -->
  <xsl:template name="csc:outputFeatureRow">
    <xsl:param name="feature" as="element(feature)"/>
    <tr style="height: 1.2rem; background: none;">
      <td style="color: #b2b2b2; text-align: right; vertical-align: middle; height: 1.2rem;"><xsl:value-of select="if ($feature/@label) then $feature/@label else $feature/@name"/></td>
      <xsl:for-each select="$assets">
        <xsl:variable name="assetId" select="./@id"/>
        <td style="vertical-align: middle; height: 1.2rem; ">
          <cs-inline-editing no-label="true" asset-id="{$assetId}" property="$ctrl.assets[{$assetId}].traits.{$feature/@trait}.{$feature/@trait_property}"
                             class="cs-is-small"></cs-inline-editing>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <!-- output header groups -->
  <xsl:template name="csc:outputHeaderGroups">
    <xsl:param name="groups" as="element(group)"/>
    <tr>
      <th style="height: 1.2rem;"></th>
      <xsl:for-each select="$groups">
        <xsl:variable name="group" select="."/>
        <th style="font-weight: bold; vertical-align: text-top; height: 1.2rem;" colspan="{count(.//feature)}">
          <xsl:value-of select="$group/@name"/>
        </th>
      </xsl:for-each>
    </tr>
    <!-- draw child groups -->
    <xsl:variable name="childGroups" select="$groups/group[.//feature]"/>
    <xsl:choose>
      <xsl:when test="$childGroups">
        <xsl:call-template name="csc:outputHeaderGroups">
          <xsl:with-param name="groups" select="$childGroups"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="childFeatures" select="$groups/feature"/>
        <xsl:if test="$childFeatures">
          <tr>
            <th style="height: 1.2rem;"></th>
            <xsl:for-each select="$childFeatures">
              <xsl:variable name="feature" select="."/>
              <th style="font-weight: bold; vertical-align: text-top; height: 1.2rem;">
                <xsl:value-of select="if ($feature/@label) then ($feature/@label) else $feature/@name"/>
              </th>
            </xsl:for-each>
          </tr>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- output product row -->
  <xsl:template name="csc:outputProductRow">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="assetId" select="$asset/@id"/>
    <tr style="height: 1.2rem;">
      <td style="font-weight: bold; vertical-align: text-top; height: 1.2rem;"><xsl:value-of select="if ($asset) then $asset/@name else concat(count($assets), ' assets selected')"/></td>
      <xsl:variable name="features" select="$dataModel/group/feature"/>
      <xsl:for-each select="$features">
        <xsl:variable name="feature" select="."/>
        <td style="vertical-align: middle; height: 1.2rem;">
          <cs-inline-editing no-label="true" asset-id="{$assetId}" property="$ctrl.assets[{$assetId}].traits.{$feature/@trait}.{$feature/@trait_property}"
                             class="cs-is-small"></cs-inline-editing>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <!-- get product thumbnail storage item of given asset-->
  <xsl:function name="csc:getProductThumbnailStorageItem" as="element(storage_item)?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:choose>
      <!-- thumbnail of given asset -->
      <xsl:when test="$asset/storage_item[@key='thumbnail']">
        <xsl:sequence select="$asset/storage_item[@key='thumbnail'][1]"/>
      </xsl:when>
      <!-- check media related assets -->
      <xsl:otherwise>
        <xsl:variable name="mediaChildRels" select="csc:getSortedChildAssetRels($asset, 'user.media.')"/>
        <xsl:variable name="mediaAsset" select="if ($mediaChildRels) then cs:get-asset($mediaChildRels[1]/@child_asset) else ()"/>
        <xsl:if test="$mediaAsset">
          <xsl:sequence select="$mediaAsset/storage_item[@key='thumbnail'][1]"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- get sorted child asset relations of given asset and relation type -->
  <xsl:function name="csc:getSortedChildAssetRels" as="element(child_asset_rel)*">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="relationType" as="xs:string"/>
    <xsl:for-each select="$asset/child_asset_rel[@key=$relationType]">
      <xsl:sort select="@sorting" data-type="number"/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="csc:getImageElementOfAsset" as="element(img)*">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="storageKey" as="xs:string"/>

    <xsl:variable name="assetID" select="$asset/@id"/>
    <xsl:variable name="storageItems" select="$asset/storage_item[@key=$storageKey]"/>
    <xsl:for-each select="$storageItems">
      <img src="{concat($urlPrefix, 'assets/asset/id/', @asset_id, '/storage/', $storageKey, '/file/', tokenize(@relpath,'/')[last()])}" width="50%" />
    </xsl:for-each>
  </xsl:function>


</xsl:stylesheet>
