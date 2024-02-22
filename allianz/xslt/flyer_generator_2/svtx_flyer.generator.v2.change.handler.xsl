<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>
  <xsl:import href="svtx_flyer.generator.v2.util.xsl" use-when="false()"/>

  <xsl:variable name="domain" select="'root.flyer-generator.v2.'" as="xs:string"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>


  <xsl:template match="/asset[@type='spreadsheet.' and @domain=$domain]">
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:flyer.generator.v2.init.service.description'"/>
      <cs:param name="source" select="."/>
    </cs:command>
    <cs:command name="com.censhare.api.transformation.AssetTransformation">
      <cs:param name="key" select="'svtx:flyer.generator.v2.init.jobs'"/>
      <cs:param name="source" select="."/>
    </cs:command>
  </xsl:template>

  <xsl:template match="/asset[@type='text.' and @domain=$domain]" priority="1">
    <xsl:variable name="query" as="element(query)">
      <query type="asset">
        <condition name="censhare:asset.domain" partial-load-tree="true" value="root.flyer-generator.v2.*" expanded-nodes="root.|root.flyer-generator.|root.flyer-generator.v2."/>
        <condition name="censhare:asset.type" partial-load-tree="true" value="profession.*" expanded-nodes="profession."/>
        <or>
          <relation target="child" type="user.basic-skills.*">
            <target>
              <condition name="censhare:asset.id" value="{$rootAsset/@id}"/>
            </target>
          </relation>
          <relation target="child" type="user.selectable-protection.*">
            <target>
              <condition name="censhare:asset.id" value="{$rootAsset/@id}"/>
            </target>
          </relation>
        </or>
      </query>
    </xsl:variable>
    <xsl:apply-templates select="cs:asset($query)"/>
  </xsl:template>

  <xsl:template match="asset[@type='profession.']">
    <xsl:variable name="assetXml" as="element(asset)">
      <asset>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="* except asset_feature[@feature='svtx:profession-pdf-rendering-pending']"/>
        <asset_feature feature="svtx:profession-pdf-rendering-pending" value_long="1"/>
      </asset>
    </xsl:variable>
    <xsl:copy-of select="svtx:updateAsset($assetXml)"/>
  </xsl:template>

</xsl:stylesheet>



