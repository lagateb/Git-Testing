<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:include href="censhare:///service/assets/asset;censhare:resource-key=svtx:util.handle.pptx/storage/master/file"/>

    <!-- Setzt alle Relation zu den Powerpoints mit Update -->

    <xsl:function name="svtx:getAllPPTXIds" as="xs:string*">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:variable name="productAsset" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"  />
        <xsl:copy-of select="$productAsset/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/@id,
            $productAsset/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/cs:child-rel()[@key = 'variant.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/@id">
        </xsl:copy-of>
    </xsl:function>



    <xsl:template match="asset[@type='text.faq.']">
        <xsl:variable name="asset" select="."/>
        <xsl:message>=== Start svtx.regenerate.pptx.faq.slide.on.text.create.xsl V3</xsl:message>
        <xsl:variable name="relations" select="svtx:getAllPPTXIds($asset)" as="xs:string*"/>
        <xsl:message>===  relations <xsl:copy-of select="$relations"/></xsl:message>


        <xsl:if test="$relations != ''" >
         <xsl:message>===  setrelations </xsl:message>
            <!--
        <xsl:variable name="checkedOutAsset" as="element(asset)" >
            <cs:command name="com.censhare.api.assetmanagement.CheckOut">
                <cs:param name="source" select="$asset"/>
            </cs:command>
        </xsl:variable>

        <xsl:variable name="newAsset">
            <asset>
                <xsl:copy-of select="$checkedOutAsset/@*"/>
                <xsl:copy-of select="$checkedOutAsset/node() except($checkedOutAsset/asset_feature[@feature='svtx:faq.medium'])" />

                <xsl:for-each select="$relations">
                    <xsl:variable name="assetID" select="." as="xs:string"/>
                    <asset_feature feature="svtx:faq.medium"  value_asset_id="{$assetID}" />
                </xsl:for-each>
            </asset>
        </xsl:variable>




        <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="result">
            <cs:param name="source" select="$newAsset" />
        </cs:command>

        -->
        <!-- Ohne Ändrungshistorie, da sonst etliche unnötige Trigger gestartet werden -->
        <cs:command name="com.censhare.api.assetmanagement.Update">
            <cs:param name="source">
                <asset>
                    <xsl:copy-of select="$asset/@*"/>
                    <xsl:copy-of select="$asset/node() except($asset/asset_feature[@feature='svtx:faq.medium'])" />

                    <xsl:for-each select="$relations">
                        <xsl:variable name="assetID" select="." as="xs:string"/>
                        <asset_feature feature="svtx:faq.medium"  value_asset_id="{$assetID}" />
                    </xsl:for-each>
                </asset>
            </cs:param>
        </cs:command>
        </xsl:if>
    </xsl:template>



</xsl:stylesheet>
