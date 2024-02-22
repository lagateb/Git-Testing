<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:variable name="userId" select="system-property('censhare:party-id')" as="xs:long?"/>
  <!--<xsl:variable name="userId" select="172" as="xs:long?"/>-->
  <xsl:variable name="referenceDomains" select="(
    'root.allianz-leben-ag.contenthub.l-mm-bb.',
    'root.allianz-leben-ag.contenthub.l-mm-av.',
    'root.allianz-leben-ag.contenthub.l-mm-kbml.',
    'root.allianz-leben-ag.contenthub.l-mm-puk.',
    'root.allianz-leben-ag.contenthub.playground.',
    'root.allianz-leben-ag.contenthub.playground-sach.'
    )" as="xs:string*"/>

  <!-- system-property('censhare:party-id') -->
  <!-- cs:user-domains(140) -->
  <xsl:template match="/">
    <xsl:variable name="allUser" select="cs:master-data('party')[@issystem = 0 and @isvisible = 1]"/>
    <xsl:variable name="currentUser" select="cs:master-data('party')[@id=$userId]" as="element(party)?"/>
    <xsl:variable name="isAdmin" select="$currentUser/@main_role='admin'"/>
    <xsl:variable name="allDomains" select="cs:master-data('domain')"/>
    <xsl:variable name="userRolesWithWritePermission" select="cs:master-data('party_role')[@party_id=$userId and (@role='agency_write' or @role='marketing_manager' or @role='power_user')]"/>
    <xsl:variable name="userWritableDomains" select="($currentUser/@main_domain, $userRolesWithWritePermission/@domain)"/>
    <xsl:variable name="marketingManagerRoles" select="cs:master-data('party_role')[@role='marketing_manager']"/>
    <result>
      <domains censhare:_annotation.arraygroup="true">
        <xsl:choose>
          <xsl:when test="$isAdmin">
            <xsl:for-each select="$referenceDomains">
              <xsl:variable name="domain" select="."/>
              <domain reference="{$domain}" write="{$domain}">
                <xsl:copy-of select="$allDomains[@pathid=$domain]/(@name)"/>
                <xsl:variable name="responsibleMarketingManager" select="$marketingManagerRoles[@domain = $domain]"/>
                <manager censhare:_annotation.arraygroup="true">
                  <xsl:for-each select="$allUser[@id=$responsibleMarketingManager/@party_id and @party_asset_id]">
                    <xsl:copy-of select="."/>
                  </xsl:for-each>
                </manager>
              </domain>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="distinct-values($userWritableDomains)">
              <xsl:variable name="domain" select="."/>
              <xsl:variable name="referenceDomain" select="for $x in $referenceDomains return if (contains($domain,$x)) then $x else ()"/>
              <xsl:if test="$referenceDomain">
                <domain reference="{$referenceDomain}" write="{$domain}">
                  <xsl:copy-of select="$allDomains[@pathid=$referenceDomain]/(@name)"/>
                  <xsl:variable name="responsibleMarketingManager" select="$marketingManagerRoles[@domain = $referenceDomain]"/>
                  <manager censhare:_annotation.arraygroup="true">
                    <xsl:for-each select="$allUser[@id=$responsibleMarketingManager/@party_id and @party_asset_id]">
                      <xsl:copy-of select="."/>
                    </xsl:for-each>
                  </manager>
                </domain>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </domains>
    </result>
  </xsl:template>
</xsl:stylesheet>
