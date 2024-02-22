<?xml version="1.0" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">

  <xsl:variable name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="deletionTypes" select="('article.', 'text.', 'layout.', 'presentation.', 'extended-media.')" as="xs:string*"/>
  <xsl:variable name="maxDepth" select="5" as="xs:long"/>
  <!-- proposed (mark as proposed for deletion), none (no/unmark deletion state), marked (mark for deletion), physical (immediately delete)-->
  <xsl:variable name="deletionMode" select="'physical'" as="xs:string"/>

  <!-- root match -->
  <xsl:template match="/asset[starts-with(@type, 'product.') and @domain ne 'root.flyer-generator.']">
    <xsl:if test="svtx:hasAssetFlag(.) = false()">
      <!-- find assets for deletion -->
      <xsl:variable name="deletables" as="element(delete)*">
        <xsl:call-template name="markAsDeletion"/>
        <xsl:apply-templates select="cs:child-rel()" mode="recursive-search">
          <xsl:with-param name="depth" select="1"/>
        </xsl:apply-templates>
      </xsl:variable>
      <!-- delete assets -->
      <xsl:for-each-group select="$deletables" group-by="@id">
        <xsl:choose>
          <xsl:when test="$debug">
            <xsl:copy-of select="."/>
          </xsl:when>
          <xsl:otherwise>
            <cs:command name="com.censhare.api.assetmanagement.Delete">
              <cs:param name="source" select="@id"/>
              <cs:param name="state" select="$deletionMode"/>
            </cs:command>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
      <result id="{@id}" deleted="true"/>
    </xsl:if>
  </xsl:template>

  <!-- match asset by deletion types, stop if max depth is exceeded -->
  <xsl:template match="asset[some $x in $deletionTypes satisfies starts-with(@type, $x)]" mode="recursive-search">
    <xsl:param name="depth"/>
    <xsl:if test="svtx:hasAssetFlag(.) = false() and $depth le $maxDepth">
      <xsl:call-template name="markAsDeletion"/>
      <xsl:apply-templates select="cs:child-rel()" mode="recursive-search">
        <xsl:with-param name="depth" select="$depth + 1"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <!-- -->
  <xsl:template name="markAsDeletion" as="element(delete)">
    <delete id="{@id}" type="{@type}"/>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:hasAssetFlag" as="xs:boolean">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:value-of select="exists($asset/asset_feature[@feature='censhare:asset-flag'])"/>
  </xsl:function>

</xsl:stylesheet>
