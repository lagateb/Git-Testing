<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:allianz.util.sorts/storage/master/file" />

    <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
    <xsl:variable name="articles" select="$rootAsset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
    <xsl:variable name="texts" select="$articles/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*']" as="element(asset)*"/>

    <xsl:function name="svtx:sortValue">
        <xsl:param name="currentText"/>
        <xsl:variable name="article" select="$articles[@id = $currentText/parent_asset_rel[@key='user.main-content.']/@parent_asset]"/>
        <xsl:copy-of select="svtx:getSortValueForAsset($article)"/>
    </xsl:function>


    <xsl:template match="/asset[starts-with(@type, 'product.')]">
        <result>
            <options censhare:_annotation.arraygroup="true">
                <xsl:for-each select="$texts">
                    <xsl:sort select="svtx:sortValue(.)"/>

                    <xsl:variable name="currentText" select="." as="element(asset)?"/>
                    <xsl:variable name="article" select="$articles[@id = $currentText/parent_asset_rel[@key='user.main-content.']/@parent_asset]"/>

                    <xsl:variable name="articleTypeDisplayValue" select="cs:master-data('asset_typedef')[@asset_type=$article/@type]/@name" as="xs:string?"/>
                    <xsl:variable name="textTypeDisplayValue" select="cs:master-data('asset_typedef')[@asset_type=$currentText/@type]/@name" as="xs:string?"/>
                    <option id="{$currentText/@id}" display_value="{$articleTypeDisplayValue} - {$textTypeDisplayValue}" value="{$currentText/@id}" selected="false()"/>

                </xsl:for-each>
            </options>
        </result>
    </xsl:template>
</xsl:stylesheet>
