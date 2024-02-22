<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <xsl:variable name="inputAsset" select="asset[1]" as="element(asset)?"/>

  <xsl:template match="/asset[@type = 'layout.']">
    <xsl:message>==== svtx:xsl.indesign.copy.layout.and.replace.product</xsl:message>
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>
    <xsl:variable name="originLayoutKey" select="$rootAsset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" as="xs:string?"/>
    <xsl:variable name="originLayoutAsset" select="cs:asset()[@censhare:resource-key=$originLayoutKey]" as="element(asset)?"/>
    <xsl:variable name="indesignStorageItem" select="$originLayoutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>

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
        <xsl:copy-of select="$checkedOutAsset/(asset_feature[not( @feature='svtx:layout-template-creation-date' or @feature='svtx:layout-template-version')], parent_asset_rel, child_asset_rel[starts-with(@key, 'variant.')])"/>
        <xsl:copy-of select="$originLayoutAsset/(asset_element, child_asset_rel, child_asset_element_rel)"/>
        <asset_feature feature="svtx:layout-template-creation-date" value_timestamp="{$originLayoutAsset/@creation_date}"/>
        <asset_feature feature="svtx:layout-template-version" value_long="{$originLayoutAsset/@version}"/>
        <storage_item key="master" corpus:asset-temp-file-url="{ $destFile }" app_version="{ $indesignStorageItem/@app_version }" element_idx="0" mimetype="{ $indesignStorageItem/@mimetype }"/>
      </asset>
    </xsl:variable>
    <xsl:variable name="checkedInAsset" select="svtx:checkInAsset($newAsset)" as="element(asset)?"/>
    <cs:command name="com.censhare.api.event.Send">
      <cs:param name="source">
        <event target="CustomAssetEvent" param2="0" param1="1" param0="{@id}" method="svtx-init-layout-placement"/>
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
</xsl:stylesheet>
