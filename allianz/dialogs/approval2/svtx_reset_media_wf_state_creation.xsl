<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">


    <!--
       Setz den Text wieder von 20 Auf 10
       und löscht dei approval History bis auf rejects
    -->

    <xsl:variable name="WF_CREATION" select="'10'"/>



    <xsl:template match="/">
        <xsl:variable name="asset" select="./asset"/>

        <xsl:variable name="ret1" select="svtx:resetAsset($asset)"/>

        <!-- if textAssetisForPPTX -->
    </xsl:template>



    <xsl:function name="svtx:update" as="element(asset)">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="ret"/>
        <cs:command name="com.censhare.api.assetmanagement.Update" returning="ret">
            <cs:param name="source" select="$asset"/>
        </cs:command>
        <xsl:copy-of select="$ret"/>
    </xsl:function>

    <!-- liefert den Artikel zum Main oder Varianten Text -->
    <xsl:function name="svtx:getArticleFromText"  as="element(asset)">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:variable name="article" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'article.*'])[1]"/>

        <xsl:copy-of select="$article"/>
    </xsl:function>

    <!-- set den WF Step zurück und löscht Approvals/History bis auf Reject

    -->
    <xsl:function name="svtx:resetAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="newAsset" as="element(asset)?">
            <asset  wf_step="{$WF_CREATION}">
                <xsl:copy-of select="$asset/@*[not(local-name() = ('wf_step'))]"/>

                <xsl:copy-of select="$asset/node() except( $asset/asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type' ] ,
               $asset/storage_item[@key='abstimmungsdokument_short' or @key='abstimmungsdokument'])"/>
                    <xsl:copy-of select="$asset/asset_feature[@feature='censhare:approval.type']/asset_feature[@feature='censhare:approval.status' and @value_key='rejected']/.."/>
            </asset>

        </xsl:variable>
        <xsl:copy-of select="svtx:update($newAsset)"/>
    </xsl:function>




</xsl:stylesheet>