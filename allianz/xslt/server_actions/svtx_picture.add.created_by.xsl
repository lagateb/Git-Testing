<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:template match="/asset[starts-with(@type, 'picture.')]">
    <xsl:variable name="createdBy" select="@created_by" as="xs:long?"/>
    <xsl:variable name="party" select="cs:master-data('party')[@id=$createdBy]" as="element(party)?"/>
    <xsl:variable name="firstName" select="$party/@firstname" as="xs:string?"/>
    <xsl:variable name="name" select="$party/@name" as="xs:string?"/>
    <xsl:variable name="email" select="$party/@email" as="xs:string?"/>
    <xsl:if test="$firstName or $name or $email">
      <xsl:variable name="newAssetXml" as="element(asset)">
        <asset>
          <xsl:copy-of select="@*"/>
          <xsl:copy-of select="* except asset_feature[@feature='svtx:asset.creator']"/>
          <asset_feature feature="svtx:asset.creator">
            <xsl:if test="$firstName">
              <asset_feature feature="censhare:address.first-name" value_string="{$firstName}"/>
            </xsl:if>
            <xsl:if test="$name">
              <asset_feature feature="censhare:address.last-name" value_string="{$name}"/>
            </xsl:if>
            <xsl:if test="$email">
              <asset_feature feature="censhare:address.uri-mailto" value_string="{$email}"/>
            </xsl:if>
          </asset_feature>
        </asset>
      </xsl:variable>
      <cs:command name="com.censhare.api.assetmanagement.UpdateWithLock">
        <cs:param name="source" select="$newAssetXml"/>
      </cs:command>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
