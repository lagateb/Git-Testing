<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

  <xsl:param name="selectedAssets"/><!-- list of <selectedAsset id="123456" self_versioned="asset/id/123456/version/21"/> -->

  <xsl:param name="transform"/>

  <!-- output -->
  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- global variables -->
  <xsl:variable name="language" select="csc:getLoggedInPartyLocale()"/>

  <!-- root match -->
  <xsl:template match="/">
    <xsl:variable name="asset" select="asset[1]"/>

    <result>
      <!-- config contains option parameters -->
      <config>
        <defaultValues>{"channel": "web", "outputChannel" :"root.web.aem.aem-azde.", "printItem":"psb", "textSize":null}</defaultValues>
      </config>
      <!-- content expects html snippet that is rendered in the widget -->
      <content>
        <div class="cs-toolbar csReportWidget__toolbar">
          <div class="cs-toolbar-slot-1">
            <div class="cs-toolbar-item">
              <xsl:variable name="channelOptions" as="element(opt)*">
                <opt value="web" display_value="Web"/>
                <opt value="print" display_value="Print"/>
                <opt value="pptx" display_value="PPT"/>
              </xsl:variable>
              <cs-select class="cs-is-small cs-is-alt" width="auto" ng-model="toolbarData.channel" unerasable="unerasable"
                         ng-options="item.value as item.name for item in [{string-join(( for $x in $channelOptions return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                         ng-change="onChange({{ channel: toolbarData.channel }}); toolbarData.textSize=null">
              </cs-select>
            </div>

            <!-- PRINT DROPDOWN -->
            <div class="cs-toolbar-item">
              <div ng-if="toolbarData.channel === 'print'">
                <xsl:variable name="printItems" as="element(opt)*">
                  <opt value="psb" display_value="PSB"/>
                  <opt value="flyer" display_value="Flyer"/>
                  <!--<opt value="pptx" display_value="PPT"/>-->
                </xsl:variable>
                <cs-select class="cs-is-small cs-is-alt" width="auto" ng-model="toolbarData.printItem" unerasable="unerasable"
                           ng-options="item.value as item.name for item in [{string-join(( for $x in $printItems return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                           ng-change="onChange({{ printItem: toolbarData.printItem }})">
                </cs-select>
              </div>
              <!-- WEB DROPDOWN -->
              <div ng-if="toolbarData.channel === 'web'">
                <xsl:variable name="outputChannel" as="element(opt)*">
                  <opt value="root.web.aem.aem-azde." display_value="Allianz.de"/>
                  <opt value="root.web.aem.aem-vp." display_value="Vertriebsportal"/>
                  <opt value="root.web.bs." display_value="Beratungssuite"/>
                </xsl:variable>
                <cs-select class="cs-is-small cs-is-alt" width="auto" ng-model="toolbarData.outputChannel" unerasable="unerasable"
                           ng-options="item.value as item.name for item in [{string-join(( for $x in $outputChannel return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                           ng-change="onChange({{ outputChannel: toolbarData.outputChannel }})">
                </cs-select>
              </div>
            </div>

            <div class="cs-toolbar-item" ng-if="toolbarData.channel === 'web'">
              <xsl:variable name="sizeOptions" as="element(opt)*">
                <opt value="size-s." display_value="Größe S"/>
                <opt value="size-m." display_value="Größe M"/>
                <opt value="size-l." display_value="Größe L"/>
                <opt value="size-xl." display_value="Größe XL"/>
              </xsl:variable>
              <cs-select label="Größe" class="cs-is-small cs-is-alt" width="auto" ng-model="toolbarData.textSize" placeholder="Alle"
                         ng-options="item.value as item.name for item in [{string-join(( for $x in $sizeOptions return concat ('{&quot;name&quot;: &quot;',  $x/@display_value, '&quot;, &quot;value&quot;: &quot;', $x/@value, '&quot;}')), ', ')}]"
                         ng-change="onChange({{ textSize: toolbarData.textSize }});">
              </cs-select>
            </div>

          </div>
          <div class="cs-toolbar-slot-2">

          </div>
        </div>
      </content>
    </result>
  </xsl:template>

</xsl:stylesheet>
