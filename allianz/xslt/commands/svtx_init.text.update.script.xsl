<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
    xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svtx="http://www.savotex.com" 
    xmlns:csc="http://www.censhare.com/censhare-custom" 
    xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
    exclude-result-prefixes="#all">
    
    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>
    
    <xsl:variable name="debug" select="false()" as="xs:boolean"/>
    <xsl:variable name="debugLog" select="false()" as="xs:boolean"/>
    
    <xsl:template match="/asset[starts-with(@type, 'layout.')]">
        
        <xsl:if test="$debugLog">
            <xsl:message>############################## Start Init Text Update Script ################################</xsl:message>
        </xsl:if>
        
        <!-- current asset-->
        <xsl:variable name="asset" select="." as="element(asset)"/>
        
        <xsl:if test="$debugLog">
            <xsl:message>############################## asset: <xsl:value-of select="$asset/@id"/> - <xsl:value-of select="$asset/@name"/> </xsl:message>
        </xsl:if>
        
        <!--xsl:variable name="product" select="$asset/cs:parent-rel()[@key = 'user.'][1]" /-->
        <xsl:variable name="parent" select="($asset/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]" as="element(asset)?"/>
        
        <xsl:variable name="product" as="element(asset)?">
          <xsl:choose>
            <xsl:when test="$parent">
              <xsl:copy-of select="$parent"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="($asset/cs:parent-rel()[@key='variant.*'][1]/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$debugLog">
            <xsl:message>############################## product: <xsl:value-of select="$product/@id"/> - <xsl:value-of select="$product/@name"/> </xsl:message>
        </xsl:if>
        
        <xsl:variable name="articles" select="$product/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'article.*']" />
        
        <xsl:for-each select="$articles">
          <xsl:copy-of select="svtx:processArticle(.)" />
        </xsl:for-each>
        
        
        <xsl:if test="$debugLog">
            <xsl:message>############################## End Init Text Update Script ##################################</xsl:message>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:function name="svtx:processArticle">
      <xsl:param name="article" as="element(asset)"/>
      
      <xsl:if test="$debugLog">
            <xsl:message>############################## article: <xsl:value-of select="$article/@id"/> - <xsl:value-of select="$article/@name"/> </xsl:message>
        </xsl:if>
      
      <!-- Alle Texte zum Artikel -->
      <xsl:variable name="texts" select="$article/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.*']" />
      
      <xsl:for-each select="$texts">
        <xsl:copy-of select="svtx:processText(.)" />
      </xsl:for-each>
      
    </xsl:function>
    
    <xsl:function name="svtx:processText">
      <xsl:param name="text" as="element(asset)"/>
      
      <xsl:if test="$debugLog">
            <xsl:message>############################## text: <xsl:value-of select="$text/@id"/> - <xsl:value-of select="$text/@name"/> </xsl:message>
        </xsl:if>
      
      <cs:command name="com.censhare.api.event.Send">
        <cs:param name="source">
          <event target="CustomAssetEvent" param2="0" param1="1" param0="{$text/@id}" method="svtx-text-create-pdf"/>
        </cs:param>
      </cs:command>
      
    </xsl:function>
    
</xsl:stylesheet>
