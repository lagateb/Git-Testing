<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="../svtx_flyer.generator.v2.util.xsl" use-when="false()"/>

  <!-- match product with excel sheet -->
  <xsl:template match="/asset">
    <xsl:variable name="article" as="element(asset)?">
      <xsl:variable name="articleAsset" select="cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.']" as="element(asset)?"/>
      <xsl:choose>
        <xsl:when test="$articleAsset">
          <xsl:copy-of select="$articleAsset"/>
        </xsl:when>
        <xsl:otherwise>
          <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
              <asset type="article." name="Listungsbeschreibungen" domain="root.flyer-generator.v2.">
                <parent_asset_rel parent_asset="{@id}" key="user."/>
              </asset>
            </cs:param>
          </cs:command>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:apply-templates select="svtx:readExcel(storage_item[@key='master'], 6)">
      <xsl:with-param name="parentAsset" select="$article"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- -->
  <xsl:template match="text()"/>

  <!-- -->
  <xsl:template match="row[count(cell) gt 4]">
    <xsl:param name="parentAsset"/>
    <xsl:variable name="key" select="svtx:getCellData(cell[1])" as="xs:string?"/>
    <xsl:variable name="value" select="svtx:getCellData(cell[2])" as="xs:string?"/>

    <xsl:if test="$key and $value">
      <xsl:if test="not($parentAsset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='text.' and @svtx:leistungsbeschreibung=$key])">
        <xsl:variable name="out"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="dest" select="concat($out, 'content.xml')" as="xs:string?"/>
        <cs:command name="com.censhare.api.io.WriteXML">
          <cs:param name="source">
            <article><content><strapline/><headline><xsl:value-of select="$key"/></headline><body><paragraph><xsl:value-of select="$value"/></paragraph></body><picture/></content></article>
          </cs:param>
          <cs:param name="dest" select="$dest"/>
          <cs:param name="output">
            <output indent="no"/>
            <output method="xml"/>
            <output omit-xml-declaration="yes"/>
          </cs:param>
        </cs:command>
        <xsl:variable name="newAssetXml" as="element(asset)">
          <asset type="text." name="{$key}" domain="root.flyer-generator.v2.">
            <asset_element key="actual." idx="0"/>
            <storage_item corpus:asset-temp-file-url="{$dest}" element_idx="0" key="master" mimetype="text/xml" />
            <parent_asset_rel parent_asset="{$parentAsset/@id}" key="user."/>
            <asset_feature feature="svtx:leistungsbeschreibung" value_string="{$key}"/>
            <asset_feature feature="censhare:content-editor.config" value_asset_key_ref="svtx:content-editor-allianz-headline-body-image-text-v3"/>
          </asset>
        </xsl:variable>
        <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
          <cs:param name="source">
            <xsl:copy-of select="$newAssetXml"/>
          </cs:param>
        </cs:command>
      </xsl:if>
    </xsl:if>


  </xsl:template>

</xsl:stylesheet>