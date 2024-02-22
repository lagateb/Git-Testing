<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">
  <!-- ========== Imports ========== -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer-generator.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="../svtx_flyer-generator.util.xsl" use-when="false()"/>

  <!-- global -->
  <xsl:variable name="debug" select="false()" as="xs:boolean"/>

  <!-- root -->
  <xsl:template match="/asset[starts-with(@type, 'picture.')]">
    <xsl:message>### NEW MAIN PICTURE ATTACHED ### <xsl:value-of select="@id"/></xsl:message>
    <xsl:for-each select="cs:parent-rel()[@key='user.main-picture.']/cs:asset()[@censhare:asset.type=$PROFESSION_ASSET_TYPE and @censhare:asset.domain=$FLYER_GENERATOR_DOMAIN]">
      <xsl:copy-of select="svtx:setRenderFlagIfNotExist(.)"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>