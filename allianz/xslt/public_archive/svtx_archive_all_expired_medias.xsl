<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:variable name="searchDomain" select="'root.allianz-leben-ag.contenthub.public.'"/>
    <xsl:variable name="newdomain" select="'root.allianz-leben-ag.archive.'"/>

    <xsl:variable name="endDate" select="current-dateTime()"/>

    <xsl:function name="svtx:setToArchive">
        <xsl:param name="assetID" as="xs:string"/>
        <!-- auschecken -->
        <xsl:variable name="checkedOutAsset"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutAsset">
            <cs:param name="source" select="$assetID"/>
        </cs:command>

        <!-- neue Domain -->
        <xsl:variable name="changedAsset" as="element(asset)">
            <cs:command name="com.censhare.api.assetmanagement.Update">
                <cs:param name="source">
                    <asset>
                        <xsl:copy-of select="$checkedOutAsset/@* except($checkedOutAsset/@domain) "/>
                        <xsl:attribute name="domain" select="$newdomain"/>
                        <xsl:copy-of select="$checkedOutAsset/node() "/>
                    </asset>
                </cs:param>
            </cs:command>
        </xsl:variable>

        <!-- und checkin -->
        <cs:command name="com.censhare.api.assetmanagement.CheckIn"  returning="result">
            <cs:param name="source" select="$changedAsset"/>
        </cs:command>

    </xsl:function>


    <xsl:template match="/">

        <!-- alle abgelaufenen Publics -->
        <xsl:for-each select="cs:asset()[(@censhare:asset.domain = $searchDomain)]/asset_feature[@feature='svtx:media-valid-until' and xs:date(@value_timestamp) lt current-date() ]">
            <xsl:variable  name="assetId" select="./@asset_id" as="xs:string"/>
            <xsl:variable name="ret" select="svtx:setToArchive($assetId)"/>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>