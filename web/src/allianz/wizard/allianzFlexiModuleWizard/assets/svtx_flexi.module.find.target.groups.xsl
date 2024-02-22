<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                version="2.0"
                exclude-result-prefixes="#all">


  <xsl:template match="/asset[starts-with(@type, 'product.')]">
    <xsl:variable name="baseLayout" select="(cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'layout.' and @svtx:layout-template-resource-key = 'svtx:indd.template.twopager.allianz'])[1]" as="element(asset)?"/>
    <xsl:variable name="baseLayoutVariants" select="$baseLayout/cs:child-rel()[@key='variant.']/cs:asset()[@censhare:asset.type = 'layout.' and @censhare:target-group]" as="element(asset)*"/>
    <result>
      <xsl:for-each select="$baseLayoutVariants">
        <xsl:variable name="targetGroupId" select="asset_feature[@feature = 'censhare:target-group']/@value_asset_id" as="xs:long?"/>
        <xsl:variable name="collectionId" select="child_asset_element_rel[contains(@url, 'group-name=twoPagerSnippet')][1]/@child_collection_id"/>
        <xsl:variable name="collectionAsset" select="if ($collectionId) then cs:get-asset($collectionId) else ()" as="element(asset)?"/>
        <xsl:variable name="hasFlexi" select="$collectionAsset/asset_feature[@feature='censhare:target-group']/@value_asset_id = $targetGroupId" as="xs:boolean"/>
        <xsl:variable name="disabled" select="if ($hasFlexi) then true() else false()" as="xs:boolean"/>
        <entry>
          <layout censhare:_annotation.datatype="number"><xsl:value-of select="@id"/></layout>
          <target_group censhare:_annotation.datatype="number"><xsl:value-of select="$targetGroupId"/></target_group>
          <has_target_group_specific_flexi_module censhare:_annotation.datatype="boolean"><xsl:value-of select="$hasFlexi"/></has_target_group_specific_flexi_module>
          <target_group_name censhare:_annotation.datatype="string"><xsl:value-of select="cs:get-asset($targetGroupId)/@name"/></target_group_name>
          <disabled censhare:_annotation.datatype="boolean"><xsl:value-of select="$disabled"/></disabled>
          <selected censhare:_annotation.datatype="boolean"><xsl:value-of select="$hasFlexi"/></selected>
        </entry>
      </xsl:for-each>
    </result>
  </xsl:template>
</xsl:stylesheet>