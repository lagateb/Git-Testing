<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:hn="https://www.hessnatur.com"
                version="2.0"
                exclude-result-prefixes="#all">

  <!-- output -->
  <xsl:output method="xhtml" encoding="UTF-8" omit-xml-declaration="yes" />

  <xsl:param name="filterAssetType" select="'all'"/>
  <xsl:param name="filterTargetGroup" select="'all'"/>

  <xsl:template match="/asset">
    <xsl:variable name="query" as="element(query)">
      <query type="asset">
        <condition name="censhare:asset.type" value="{if ($filterAssetType = 'all') then 'article.*' else $filterAssetType}"/>
        <condition name="censhare:asset-flag" op="ISNULL"/>
        <condition name="censhare:target-group">
          <xsl:choose>
            <xsl:when test="$filterTargetGroup = 'all'">
              <xsl:attribute name="op" select="'NOTNULL'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="value" select="$filterTargetGroup"/>
            </xsl:otherwise>
          </xsl:choose>
        </condition>
        <relation target="parent" type="variant.*">
          <target>
            <condition name="censhare:asset.type" value="article.*"/>
            <relation target="parent" type="user.*">
              <target>
                <condition name="censhare:asset.id" value="{ @id }"/>
              </target>
            </relation>
          </target>
        </relation>
      </query>
    </xsl:variable>
    <xsl:variable name="queryResult" select="cs:asset($query)" as="element(asset)*"/>
    <result>
      <content>
        <style>
          #t ul {
          padding-left:1.5rem;
          padding-right:1.5rem;
          }
        </style>
        <div id="t">
          <xsl:for-each select="$queryResult">
            <cs-report-asset-renderer ids="{ @id }" live="false" flavor="'csAssetListItemRendererWidgetmxn_2rows'"/>
          </xsl:for-each>
        </div>
      </content>
    </result>
  </xsl:template>
</xsl:stylesheet>
