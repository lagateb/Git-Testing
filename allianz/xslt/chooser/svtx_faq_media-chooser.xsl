<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom" exclude-result-prefixes="cs csc">

    <!-- dynamic value list of all media (pptx) assets  for the product where the article relate to-->

    <!--
    <?xml version="1.0" encoding="UTF-8"?>
    <options xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <option value="32330" display_value="P20210623_1 PowerPoint Makler"/>
        <option value="32304" display_value="P20210623_1 PowerPoint Standard"/>
        <option value="32317" display_value="P20210623_1 PowerPoint Vertrieb"/>
   </options>
-->

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

    <!-- parameters -->
    <xsl:param name="asset" select="asset"/>
    <xsl:param name="feature-key"/>
    <xsl:param name="value" select="()"/>


    <xsl:function name="svtx:sortOrder" as="xs:integer">
      <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$type='standard'">1</xsl:when>
            <xsl:when test="$type='sales'">2</xsl:when>
            <xsl:when test="$type='agent'">3</xsl:when>
            <xsl:otherwise>4</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- root match -->
    <xsl:template match="/">
        <options>
            <xsl:choose>
                <xsl:when test="$value">
                    <xsl:variable name="selectedAsset" select="cs:get-asset(xs:integer($value))"/>
                    <option value="{$value}" display_value="{if ($selectedAsset) then ($selectedAsset/@name) else ($value)}"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- create data model -->
                    <xsl:variable name="options" as="element(option)*">

                        <!-- faq.asset =hoch=> Produkt =runter=>presentation.issue und deren Varianten -->
                        <!--
                        <xsl:variable name="productAsset" select="(asset/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"  />
                        -->
                        <xsl:variable name="productAsset" select="(asset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"  />


                        <xsl:for-each select="$productAsset/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'presentation.issue.'],
            $productAsset/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/cs:child-rel()[@key = 'variant.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']">
                             <xsl:sort select="svtx:sortOrder(asset_feature[@feature='svtx:text-variant-type']/@value_key)"/>

                                       <!-- <asset_feature asset_id="34032" asset_version="16" corpus:dto_flags="pt" feature="svtx:text-variant-type" isversioned="1" party="100" rowid="1976733" sid="3192104" timestamp="2021-07-13T15:30:56Z" value_key="standard"/>
</asset>  -->
                            <option value="{@id}" display_value="{@name}"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <!-- create output -->
                    <xsl:for-each select="$options">
                        <!-- <xsl:sort select="@display_value"/> -->
                        <xsl:sequence select="."/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </options>
    </xsl:template>

</xsl:stylesheet>