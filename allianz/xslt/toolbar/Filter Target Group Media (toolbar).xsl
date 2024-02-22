<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

  <!-- toolbar for articles table -->

  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

  <!-- output -->
  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- root match -->
  <xsl:template match="/asset">

    <xsl:variable name="query" as="element(query)">
      <query type="asset">
        <condition name="svtx:media-channel" op="NOTNULL"/>
        <condition name="censhare:target-group" op="NOTNULL"/>
        <relation target="parent" type="variant.*">
          <target>
            <condition name="svtx:media-channel" op="NOTNULL"/>
            <relation target="parent" type="user.*">
              <target>
                <condition name="censhare:asset.id" op="=" value="{ @id }"/>
              </target>
            </relation>
          </target>
        </relation>
        <sortorders>
          <grouping mode="none"/>
          <order ascending="true" by="censhare:asset.name"/>
        </sortorders>
      </query>
    </xsl:variable>
    <xsl:variable name="assetMedia" select="cs:asset($query)" as="element(asset)*"/>

    <xsl:variable name="mediaTargetGroups" as="element(option)*">
      <xsl:for-each select="distinct-values($assetMedia/asset_feature[@feature='censhare:target-group']/@value_asset_id)">
        <xsl:variable name="assetId" select="." as="xs:long?"/>
        <xsl:variable name="assetTargetGroup" select="cs:get-asset($assetId)" as="element(asset)?"/>
        <option value="{$assetTargetGroup/@id}" name="{$assetTargetGroup/@name}"/>
      </xsl:for-each>
    </xsl:variable>

    <result>
      <!-- config contains default values -->
      <config>
        <defaultValues>{"filterTargetGroup": "all"}</defaultValues>
      </config>
      <!-- content expects html snippet that is rendered in the widget -->
      <content>
        <div class="cs-toolbar">
          <div class="cs-toolbar-slot-1">
            <!-- filter target groups -->
            <div class="cs-toolbar-item">
              <cs-select class="cs-is-small cs-is-alt" label="Zielgruppe" width="auto" ng-model="toolbarData.filterTargetGroup" unerasable="unerasable"
                         ng-options="item.value as item.name for item in [{string-join(('{&quot;name&quot;: &quot;${all}&quot;, value: &quot;all&quot;}', for $x in $mediaTargetGroups return concat ('{&quot;name&quot;: &quot;',  $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                         ng-change="onChange({{ filterTargetGroup: toolbarData.filterTargetGroup }})">
              </cs-select>
            </div>
          </div>
        </div>
      </content>
    </result>
  </xsl:template>

</xsl:stylesheet>
