<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  exclude-result-prefixes="#all">
  
  <!-- output -->
  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- possible dropdown options -->
  <xsl:variable name="selectOptions" as="element(entry)*">
    <entry name="One Size" type="text."/>
    <entry name="Größe S" type="text.size-s."/>
    <entry name="Größe M" type="text.size-m."/>
    <entry name="Größe L" type="text.size-l."/>
    <entry name="Größe XL" type="text.size-xl."/>
  </xsl:variable>

  <!-- root match -->
  <xsl:template match="asset">
    <xsl:variable name="contentAssets" select="cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type = 'text.*']" as="element(asset)*"/>
    <xsl:variable name="types" select="distinct-values($contentAssets/@type)" as="xs:string*"/>
    <!-- only use options for available text assets -->
    <xsl:variable name="options" select="$selectOptions[@type=$types]" as="element(entry)*"/>
    <result>
      <!-- config contains option parameters -->
      <config>
        <defaultValues>
          <xsl:value-of select="concat('{&quot;size&quot;: &quot;', '', '&quot;}')"/>
        </defaultValues>
      </config>
      <!-- content expects html snippet that is rendered in the widget -->
      <content>
        <div class="cs-toolbar csReportWidget__toolbar">
          <div class="cs-toolbar-slot-1">
            <!-- size -->
            <div class="cs-toolbar-item">
              <label class="cs-label cs-is-small">${size}</label>
              <cs-select class="cs-is-small cs-is-alt"
                         width="auto"
                         ng-model="toolbarData.size"
                         ng-options="item.value as item.name for item in [{string-join(for $x in $options return concat('{&quot;name&quot;: &quot;', $x/@name, '&quot;, &quot;value&quot;: &quot;', $x/@type, '&quot;}'), ', ')}]"
                         ng-change="onChange({{ size: toolbarData.size }})"
                         cs-option-init="toolbarData.size[0]">
              </cs-select>
            </div>
          </div>
          <div class="cs-toolbar-slot-2"></div>
        </div>
      </content>
    </result>
  </xsl:template>
</xsl:stylesheet>
