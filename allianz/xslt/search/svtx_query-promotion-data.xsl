<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">


  <xsl:template match="/asset">
    <!-- todo query weiter einschränken -->
    <xsl:variable name="query" as="element(query)">
      <query type="asset">
        <condition name="censhare:asset.type" value="promotion."/>
        <condition name="msp:alz-mmc.promotion-article-number" op="NOTNULL"/>
        <condition name="msp:alz-mmc.promotion-id" op="NOTNULL"/>
        <condition name="msp:alz-mmc.promotion-version-number" op="NOTNULL"/>
      </query>
    </xsl:variable>
    <xsl:variable name="activePromotion" select="(cs:parent-rel()[@key='user.layout.']/cs:asset()[@censhare:asset.type='promotion.'])[1]" as="element(asset)?"/>
    <xsl:variable name="processAssets" as="element(asset)*">
      <xsl:for-each-group select="cs:asset($query)" group-by="asset_feature[@feature='msp:alz-mmc.promotion-article-number']/@value_string">
        <xsl:variable name="sortedByVersion" as="element(asset)*">
          <xsl:for-each select="current-group()">
            <xsl:sort select="asset_feature[@feature='msp:alz-mmc.promotion-version-number']/@value_string" data-type="text" order="descending"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$sortedByVersion[1]"/>
      </xsl:for-each-group>
    </xsl:variable>
    <result>
      <promotions censhare:_annotation.arraygroup="true">
        <xsl:apply-templates select="$processAssets">
        	<xsl:with-param name="activePromotionId" select="$activePromotion/@id"/>
        </xsl:apply-templates>
      </promotions>
    </result>
  </xsl:template>

  <xsl:template match="asset">
  	<xsl:param name="activePromotionId" as="xs:long?"/>
    <xsl:variable name="articleNumber" select="asset_feature[@feature='msp:alz-mmc.promotion-article-number']/@value_string" as="xs:string?"/>
    <xsl:variable name="promotionId" select="asset_feature[@feature='msp:alz-mmc.promotion-id']/@value_string" as="xs:string?"/>
    <xsl:variable name="promotionVersion" select="asset_feature[@feature='msp:alz-mmc.promotion-version-number']/@value_string" as="xs:string?"/>
    <!--<xsl:variable name="displayName" select="concat(@name,' [', $promotionId, '] [', $articleNumber,']')"/>-->
    <xsl:variable name="displayName" select="concat($articleNumber, ' (', $promotionVersion, ') ', @name)"/>
    <promotion>
      <display_value censhare:_annotation.datatype="string"><xsl:value-of select="$displayName"/></display_value>
      <value censhare:_annotation.datatype="number"><xsl:value-of select="@id"/></value>
      <article_number censhare:_annotation.datatype="string"><xsl:value-of select="$articleNumber"/></article_number>
      <promotion_id censhare:_annotation.datatype="string"><xsl:value-of select="$promotionId"/></promotion_id>
      <promotion_version censhare:_annotation.datatype="string"><xsl:value-of select="$promotionVersion"/></promotion_version>
      <print_number censhare:_annotation.datatype="string"><xsl:value-of select="concat($articleNumber, ' (', $promotionVersion,')')"/></print_number>
      <is_active censhare:_annotation.datatype="boolean"><xsl:value-of select="if (@id = $activePromotionId) then true() else false()"/></is_active>
    </promotion>
  </xsl:template>
</xsl:stylesheet>
