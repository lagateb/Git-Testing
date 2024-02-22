<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs censhare svtx xs">

  <xsl:function name="svtx:get-template-asset">
    <xsl:param name="mediaAsset"/>

    <!-- Check for the resource key of the referenced template -->
    <xsl:variable name="templateAsset" as="element(asset)*">
      <xsl:choose>
        <xsl:when test="$mediaAsset/asset_feature[@feature = 'svtx:layout-template-resource-key']">
          <xsl:copy-of select="cs:get-resource-asset($mediaAsset/asset_feature[@feature = 'svtx:layout-template-resource-key']/@value_asset_key_ref)"/>
        </xsl:when>
        <xsl:when test="$mediaAsset/asset_feature[@feature = 'svtx:layout-template']">
          <xsl:copy-of select="($mediaAsset/cs:feature-ref-reverse()[@key='svtx:layout-template'])[1]"/>
        </xsl:when>
        <xsl:when test="$mediaAsset/asset_feature[@feature='censhare:resource-key']">
          <xsl:copy-of select="$mediaAsset"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:copy-of select="$templateAsset"/>
  </xsl:function>

  <xsl:function name="svtx:get-template-state-of-asset">
    <xsl:param name="asset"/>

    <!-- If we have a presentation, we need the attached slides, in case one of the layouts of one slide has changed -->
    <xsl:variable name="childMediaAssets">
      <xsl:choose>
        <xsl:when test="$asset/@type='presentation.issue.'">
          <xsl:copy-of select="$asset/cs:child-rel()[@key='target.']"/>
        </xsl:when>
        <xsl:when test="starts-with($asset/@type, 'layout.')">
          <xsl:copy-of select="$asset"/>
        </xsl:when>
        <xsl:when test="starts-with($asset/@type, 'presentation.slide.')">
          <xsl:copy-of select="$asset"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- not supported media, therefore ignore -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- get information of layouts for every media -->
    <xsl:variable name="result">
      <xsl:for-each select="$childMediaAssets/*">
        <xsl:variable name="mediaAsset" select="." as="element(asset)"/>

        <xsl:variable name="currentTemplate" select="svtx:get-template-asset($mediaAsset)"/>

        <xsl:if test="exists($currentTemplate) ">
          <!-- only if the layout has a template attached, sometimes it hasn't, don't know why -->
          <xsl:variable name="originalTemplateDate" select="$mediaAsset/asset_feature[@feature = 'svtx:layout-template-creation-date']/@value_timestamp"/>
          <xsl:variable name="currentTemplateDate" select="$currentTemplate/@creation_date"/>
          <xsl:variable name="originalTemplateVersion" select="$mediaAsset/asset_feature[@feature = 'svtx:layout-template-version']/@value_long"/>
          <xsl:variable name="currentTemplateVersion" select="$currentTemplate/@version"/>
          <xsl:variable name="modificationDate" select="cs:localized-format-date('de', $currentTemplate/@modified_date, 'short', 'short')"/>

          <xsl:variable name="templateState">
            <xsl:choose>
              <xsl:when test="not($currentTemplateDate = $originalTemplateDate)">
                <xsl:value-of select="'new-template'"/>
              </xsl:when>
              <xsl:when test="not($currentTemplateVersion = $originalTemplateVersion)">
                <xsl:value-of select="'updated-template'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'ok'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="templateHistory">
            <xsl:copy-of select="svtx:get-change-history($mediaAsset)"/>
          </xsl:variable>

          <media id="{$mediaAsset/@id}" name="{$mediaAsset/@name}" type="{$mediaAsset/@type}" state="{$templateState}" originaldate="{$originalTemplateDate}" originalversion="{$originalTemplateVersion}">
            <template id="{$currentTemplate/@id}" name="{$currentTemplate/@name}" type="{$currentTemplate/@type}" currentdate="{$currentTemplateDate}" currentversion="{$currentTemplateVersion}" modificationdate="{$modificationDate}" history="{$templateHistory/result/summary/text()}">
            </template>
            <history>
              <xsl:copy-of select="$templateHistory/result/history/*"/>
            </history>
          </media>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:copy-of select="$result"/>
  </xsl:function>

  <xsl:function name="svtx:get-change-history">
    <xsl:param name="mediaAsset" as="element(asset)"/>

    <xsl:variable name="templateAsset" select="svtx:get-template-asset($mediaAsset)"/>
    <xsl:variable name="templateAssetResourceKey" select="$templateAsset/asset_feature[@feature='censhare:resource-key']/@value_string"/>

    <xsl:variable name="histories-after">
      <xsl:choose>
        <xsl:when test="$mediaAsset/asset_feature[@feature = 'svtx:layout-template-resource-key']">
          <xsl:value-of select="($mediaAsset/asset_feature[@feature='svtx:layout-template-creation-date']/@value_timestamp)[1]"/>
        </xsl:when>
        <xsl:when test="$mediaAsset/asset_feature[@feature = 'svtx:layout-template-resource-key']">
          <xsl:value-of select="($mediaAsset/asset_feature[@feature='svtx:layout-template-creation-date']/@value_timestamp)[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Get the one and only change-history-container-->
    <xsl:variable name="historyAsset" select="cs:get-resource-asset('svtx:module.change.history')" as="element(asset)?"/>
    <xsl:variable name="historyForTemplate" select="$historyAsset/asset_feature[@feature='svtx:change-history' and @value_string=$templateAssetResourceKey]"/>

    <xsl:variable name="historyEntries">
      <xsl:for-each select="$historyForTemplate/asset_feature[@feature='svtx:change-history-date']">
        <xsl:sort select="@value_timestamp" order="descending"/>
        <xsl:if test="not($histories-after) or $histories-after &lt;= @value_timestamp">
          <historyEntry>
            <date><xsl:value-of select="cs:localized-format-date('de', @value_timestamp, 'dd.MM.yyyy HH:mm:ss')"/></date>
            <note><xsl:value-of select="asset_feature[@feature='svtx:change-history-note']/@value_string"/></note>
          </historyEntry>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="summary">
      <xsl:for-each select="$historyEntries/historyEntry">
        <v><xsl:value-of select="concat(./date/text(), ': ', ./note/text())"/></v>
      </xsl:for-each>
    </xsl:variable>

    <result template="{$templateAssetResourceKey}" templateName="{$templateAsset/@name}">
      <history>
        <xsl:copy-of select="$historyEntries/historyEntry"/>
      </history>
      <summary>
        <xsl:value-of select="string-join($summary/v, ', &#10;&#13;')"/>
      </summary>
    </result>
  </xsl:function>

  <xsl:function name="svtx:add-change-history">
    <xsl:param name="mediaAsset" as="element(asset)"/>
    <xsl:param name="change-note"/>

    <xsl:variable name="templateAssetResourceKey" select="$mediaAsset/asset_feature[@feature='censhare:resource-key']/@value_string"/>

    <xsl:if test="$templateAssetResourceKey">
      <xsl:variable name="historyAsset" select="cs:get-resource-asset('svtx:module.change.history')" as="element(asset)?"/>
      <xsl:variable name="checkedOutHistoryAsset" as="element(asset)">
        <xsl:choose>
          <xsl:when test="exists($historyAsset)">
            <xsl:copy-of select="svtx:checkOutAsset($historyAsset)"/>
          </xsl:when>
          <xsl:otherwise>
              <asset application="metadata" domain="root." domain2="root." name="Change History" type="module.history." z_icon-set-key="assettype-module.">
                <asset_feature feature="censhare:resource-enabled" value_long="1"/>
                <asset_feature feature="censhare:resource-in-cached-tables" value_long="1"/>
                <asset_feature feature="censhare:resource-key" value_asset_key="svtx:module.change.history" value_asset_key_feature="censhare:resource-key" value_string="svtx:module.change.history"/>
              </asset>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="updatedHistoryAsset">
        <asset>
          <xsl:copy-of select="$checkedOutHistoryAsset/@*"/>
          <xsl:copy-of select="$checkedOutHistoryAsset/node() except ($checkedOutHistoryAsset/asset_feature[@feature='svtx:change-history' and @value_string=$templateAssetResourceKey])"/>

          <asset_feature feature="svtx:change-history" value_string="{$templateAssetResourceKey}">
            <xsl:copy-of select="$checkedOutHistoryAsset/asset_feature[@feature='svtx:change-history' and @value_string=$templateAssetResourceKey]/@* except(@feature, @value_string)"/>
            <asset_feature feature="svtx:change-history-date" value_timestamp="{current-dateTime()}">
              <asset_feature feature="svtx:change-history-note" value_string="{$change-note}"/>
            </asset_feature>

            <xsl:copy-of select="$checkedOutHistoryAsset/asset_feature[@feature='svtx:change-history' and @value_string=$templateAssetResourceKey]/*"/>
          </asset_feature>
        </asset>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$updatedHistoryAsset/asset/@id &gt; 0">
          <xsl:copy-of select="svtx:checkInAsset($updatedHistoryAsset)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="svtx:checkInNewAsset($updatedHistoryAsset)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

  </xsl:function>

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

  <xsl:function name="svtx:checkInNewAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>

    <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
      <cs:param name="source">
        <xsl:copy-of select="$asset" />
      </cs:param>
    </cs:command>
  </xsl:function>


</xsl:stylesheet>
