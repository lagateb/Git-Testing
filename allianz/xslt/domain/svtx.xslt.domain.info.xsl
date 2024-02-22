<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:svtx="http://www.savotex.com/"
        exclude-result-prefixes="#all"
        version="2.0">

    <!-- variables -->
    <xsl:variable name="debug" as="xs:boolean" select="false()"/>

    <!-- Defines a search for the main content assets -->
    <xsl:template match="asset">
        <xsl:variable name="asset" as="element(asset)?" select="."/>

        <xsl:variable name="domain" select="cs:master-data('domain')[@pathid=$asset/@domain]"/>
        <xsl:variable name="subDomains" select="cs:master-data('domain')[@parent=$domain/@pathid]"/>

        <result>
            <currentDomain>
                <key><xsl:value-of select="$domain/@pathid"/></key>
                <name><xsl:value-of select="$domain/@name"/></name>
            </currentDomain>
            <subDomains>
                <xsl:for-each select="$subDomains">
                    <domain>
                        <key><xsl:value-of select="@pathid"/></key>
                        <name><xsl:value-of select="@name"/></name>
                    </domain>
                </xsl:for-each>
            </subDomains>
            <permission><xsl:value-of select="cs:has-asset-permission($asset, ('product_domain_switch'))"/></permission>
        </result>

    </xsl:template>


</xsl:stylesheet>