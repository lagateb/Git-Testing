<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com">

    <xsl:param name="filterProductName" select="'all'" as="xs:string"/>
    <xsl:param name="assetType" select="'all'"/>


    <xsl:function name="svtx:getIds">
        <xsl:param name="productName"  as="xs:string"/>
        <xsl:variable name="ids" select="(cs:asset()[@censhare:asset.domain='root.allianz-leben-ag.archive.' and  (@censhare:asset.type = 'presentation.*' or @censhare:asset.type = 'document.flyer.*' or @censhare:asset.type = 'document.psb.*')])
       /asset_feature[@feature='svtx:product-name' and @value_string=$productName ]/@asset_id"/>
        <xsl:copy-of select="$ids"/>
    </xsl:function>



    <xsl:template match="/" name="archived-media">
        <xsl:message>==== filterProductName #<xsl:value-of select="$filterProductName"/># </xsl:message>
        <xsl:message>==== assetType <xsl:value-of select="$assetType"/> </xsl:message>

    <query>
        <and>
          <or>
              <condition name="censhare:asset.type" value="document.flyer.*"/>
              <condition name="censhare:asset.type" value="document.psb.*"/>
              <condition name="censhare:asset.type" value="presentation.*"/>
          </or>
            <xsl:if test="$assetType !=  'all'">
                <condition name="censhare:asset.type" op="=" value="{$assetType}"/>
            </xsl:if>

            <xsl:if test="$filterProductName !=  'all'">
                <xsl:variable name="ids" select="svtx:getIds($filterProductName)"/>
                <xsl:message>==== ids <xsl:value-of select="$ids"/> </xsl:message>
                <condition name="censhare:asset.id" op="IN"  value="{string-join($ids, ' ')}" sepchar=" "/>
            </xsl:if>

            <condition name="censhare:asset.domain" op="=" value="root.allianz-leben-ag.archive."/>
        </and>
      <sortorders>
        <grouping mode="none"/>
        <order ascending="true" by="censhare:asset.type"/>
        <order ascending="true" by="censhare:asset.name"/>
      </sortorders>
    </query>
  </xsl:template>
</xsl:stylesheet>
