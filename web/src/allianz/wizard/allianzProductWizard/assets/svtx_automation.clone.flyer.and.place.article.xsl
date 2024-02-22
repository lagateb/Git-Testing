<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">
  <!-- param -->
  <xsl:param name="transform"/>
  <xsl:param name="target-layout" select="if ($transform/@target-layout) then $transform/@target-layout else ()" as="xs:long?"/>
  <xsl:param name="target-channel" select="if ($transform/@target-channel) then $transform/@target-channel else ()" as="xs:long?"/>
  <xsl:param name="target-group" select="if ($transform/@target-group) then $transform/@target-group else ()" as="xs:long?"/>
  <xsl:param name="new-domain" select="if ($transform/@new-domain) then $transform/@new-domain else ()" as="xs:string?"/>

  <!-- root match -->
  <xsl:template match="/asset[starts-with(@type, 'product.')]">
    <xsl:variable name="layout" select="if ($target-layout) then cs:get-asset($target-layout) else ()" as="element(asset)?"/>
    <xsl:variable name="channel" select="cs:get-asset($target-channel)" as="element(asset)?"/>
    <xsl:variable name="product" select="." as="element(asset)?"/>

    <!-- Alle Bausteine unter dem Produkt, wenn es eine Zielgruppe als Parameter gibt, dann sollen ZG Varianten von Bausteinen platziert werden -->
    <xsl:variable name="articleAssets" as="element(asset)*">
      <xsl:for-each select="(cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']/.[not(exists(asset_feature[@feature='svtx:optional-component' and @value_long = 1]))])">
        <xsl:variable name="targetGroupVariant" select="if ($target-group) then (cs:child-rel()[@key='variant.']/cs:asset()[@censhare:asset.type='article.*' and @censhare:target-group = $target-group])[1] else ()" as="element(asset)?"/>
        <xsl:copy-of select="if ($targetGroupVariant) then $targetGroupVariant else ."/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="textAssets" select="$articleAssets/cs:child-rel()[@key='user.main-content.']" as="element(asset)*"/>
    <xsl:variable name="exludeFeatures" select="(
      'censhare:template-hierarchy',
      'censhare:resource-key',
      'censhare:resource-enabled',
      'censhare:resource-in-cached-tables',
      'censhare:resource-meta',
      'censhare:owner'
     )"/>

    <xsl:variable name="targetGroup" select="if ($target-group) then cs:get-asset(xs:long($target-group)) else ()" as="element(asset)?"/>
    <xsl:variable name="layoutName" select="concat(@name, ' - ', substring-before(concat($layout/@name, '('), '('))" as="xs:string"/>
    <xsl:variable name="layoutNameWithTargetGroup" select="concat($layoutName, ' - ', $targetGroup/@name)"/>

    <xsl:variable name="layoutName" as="xs:string?">
      <xsl:variable name="baseName" select="concat($product/@name, ' - ', $channel/@name)" as="xs:string"/>
      <xsl:value-of select="if ($targetGroup) then concat($baseName, ' - ', $targetGroup/@name) else $baseName"/>
    </xsl:variable>

    <!-- check In New Layout -->
    <xsl:variable name="existingLayoutForChannel" select="if ($target-channel) then (cs:child-rel()[@key='user.']/cs:asset()[@svtx:media-channel = $target-channel])[1] else ()" as="element(asset)?"/>
    <xsl:variable name="existingLayoutForTargetGroup" select="if ($target-group) then ($existingLayoutForChannel/cs:child-rel()[@key='variant.']/cs:asset()[@censhare:target-group = $target-group])[1] else ()" as="element(asset)?"/>

    <!-- -->
    <xsl:variable name="layoutResource" select="$layout/asset_feature[@feature='censhare:resource-key']/@value_string" as="xs:string?"/>

    <xsl:variable name="newLayout" as="element(asset)?">
      <xsl:choose>
        <xsl:when test="$existingLayoutForTargetGroup">
          <xsl:copy-of select="$existingLayoutForTargetGroup"/>
          <cs:command name="com.censhare.api.event.Send" returning="place-event">
            <cs:param name="source">
              <event target="CustomAssetEvent" param2="0" param1="1" param0="{$existingLayoutForTargetGroup/@id}" method="svtx-init-layout-placement"/>
            </cs:param>
          </cs:command>
        </xsl:when>
        <xsl:otherwise>
          <!-- duplicate layout XML -->
          <cs:command name="com.censhare.api.assetmanagement.cloneAndCleanAssetXml" returning="duplicateLayout">
            <cs:param name="source">
              <asset>
                <xsl:copy-of select="$layout/@* except $layout/@non_owner_access"/>
                <xsl:copy-of select="$layout/node() except $layout/(child_asset_rel[@key='variant.'], asset_feature[@feature=$exludeFeatures])"/>
              </asset>
            </cs:param>
          </cs:command>
            <xsl:message>==== duplicateLayout <xsl:value-of select="$duplicateLayout/@id"/> </xsl:message>
          <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
              <asset name="{ $layoutName }"  wf_id="80" wf_step="5">
                <xsl:attribute name="domain" select="if ($new-domain) then $new-domain else $product/@domain"/>
                <xsl:copy-of select="$duplicateLayout/@* except $duplicateLayout/(@name, @domain, @wf_step, @wf_id)"/>
                <xsl:copy-of select="$duplicateLayout/node() except $duplicateLayout/child_asset_rel[@key='variant.']"/>
                <asset_feature feature="svtx:layout-template-creation-date" value_timestamp="{$layout/@creation_date}"/>
                <asset_feature feature="svtx:layout-template-version" value_long="{$layout/@version}"/>
                <xsl:if test="not($duplicateLayout/asset_feature[@feature='svtx:layout-template'])">
                  <asset_feature feature="svtx:layout-template" value_asset_id="{$layout/@id}"/>
                </xsl:if>
                <xsl:if test="$layoutResource and not($targetGroup)">
                  <asset_feature feature="svtx:layout-template-resource-key" value_asset_key_ref="{ $layoutResource }"/>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="$target-group and $existingLayoutForChannel">
                    <parent_asset_rel key="variant." parent_asset="{$existingLayoutForChannel/@id}"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <parent_asset_rel key="user." parent_asset="{@id}"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="$target-channel">
                  <xsl:if test="not($duplicateLayout/asset_feature[@feature='svtx:media-channel'])">
                    <asset_feature feature="svtx:media-channel" value_asset_id="{$target-channel}"/>
                  </xsl:if>
                </xsl:if>
                <xsl:if test="$target-group">
                  <xsl:if test="not($duplicateLayout/asset_feature[@feature='censhare:target-group'])">
                    <asset_feature feature="censhare:target-group" value_asset_id="{$target-group}"/>
                  </xsl:if>
                </xsl:if>
              </asset>
            </cs:param>
          </cs:command>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy-of select="$newLayout"/>
      <xsl:message>==== die ID  <xsl:value-of select="$newLayout/@id"/> </xsl:message>
    <!-- handlet die platzierung der Bausteine, muss eine gesonderte automatione sein welche danach KEIN content update event sendet. Sonst gibt es eine Art rollback auf das asset -->
    <!--<cs:command name="com.censhare.api.event.Send">
      <cs:param name="source">
        <event target="CustomAssetEvent" param2="0" param1="1" param0="{$newLayout/@id}" method="svtx-layout-place-article"/>
      </cs:param>
    </cs:command>-->

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


  <!-- asset => article.* -->
  <xsl:function name="svtx:getLayoutGroup" as="xs:string?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:param name="template" as="xs:string?"/>
    <xsl:variable name="type" select="$asset/@type" as="xs:string?"/>
    <xsl:variable name="mapping">
      <entry type="article.vorteile." group="Vorteile"/>
      <entry type="article.header." group="Header"/>
      <entry type="article.produktbeschreibung." group="Produktbeschreibung"/>
      <entry type="article.funktionsgrafik." group="Funktionsgrafik"/>
      <entry type="article.staerken." group="Stärken"/>
      <xsl:choose>
        <xsl:when test="$template = 'svtx:indd.template.flyer.allianz'">
          <entry type="article.nutzenversprechen." group="Nutzenversprechen"/>
          <entry type="article.fallbeispiel." group="Fallbeispiel"/>
        </xsl:when>
        <xsl:when test="$template = 'svtx:indd.template.twopager.allianz'">
          <entry type="article.zielgruppenmodul." group="Zielgruppenmodul"/>
          <entry type="article.productdetails." group="Produktdetails"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$mapping/entry[@type = $type]/@group"/>
  </xsl:function>
</xsl:stylesheet>
