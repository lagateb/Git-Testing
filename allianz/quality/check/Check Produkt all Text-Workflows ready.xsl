<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">
 <xsl:output method="text" omit-xml-declaration="no" indent="no"/>
<!-- sucht im Allianz Produkt all texte und kontrolliert,ob sie freigegeben sind wf=30 -->

    <xsl:template match="asset">
    <xsl:message>Check Text WF ==== </xsl:message>
        <xsl:variable name="retvals">
            <ret>
                <xsl:for-each select="cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']">
                    <xsl:copy-of select="svtx:searchInArticleAsset(.)"/>
                </xsl:for-each>
            </ret>
        </xsl:variable>
        <xsl:value-of select="count($retvals/ret/text[@wf!='ok'])=0"/>
    </xsl:template>

    <xsl:function name="svtx:wfEvaluation">
        <xsl:param name="wfValue"/>
        <xsl:choose>
            <xsl:when test="$wfValue and  ($wfValue!='30')"><text><xsl:attribute name="wf" select="@wf_step"></xsl:attribute></text></xsl:when>
            <xsl:when test="$wfValue and  ($wfValue='30')"><text wf="ok"/></xsl:when>
            <xsl:otherwise><text wf="nowf"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:searchInArticleAsset">
        <xsl:param name="articleAsset"  as="element(asset)" />
        <!-- alle Texte zu dem Artikel -->
        <xsl:for-each select="$articleAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*']">
            <xsl:copy-of select="svtx:wfEvaluation(@wf_step)"/>
            <!-- Alle Text-Varianten -->
            <xsl:for-each select="./cs:child-rel()[@key='variant.*']/cs:asset()[@censhare:asset.type='text.*']">
                <xsl:copy-of select="svtx:wfEvaluation(@wf_step)"/>
            </xsl:for-each>
        </xsl:for-each>
        <!-- Alle Varianten-Artikel -->
        <xsl:for-each select="$articleAsset/cs:child-rel()[@key='variant.']/cs:asset()[@censhare:asset.type='article.*']">
            <xsl:copy-of select="svtx:searchInArticleAsset(.)"/>
        </xsl:for-each>

    </xsl:function>


</xsl:stylesheet>




