<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="cs csc">

    <!-- Liefert den Produktnamen des published Mediums  -->

    <!-- output -->
    <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>

    <!-- asset match -->
    <xsl:template match="asset">
        <xsl:variable name="asset" select="."/>

        <xsl:variable name="product" select="($asset/cs:parent-rel()[@key = 'user.publication.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $asset/cs:parent-rel()[@key = 'user.publication.']/cs:parent-rel()[@key='variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $asset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $asset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*']
                      )[1]"/>
        <xsl:value-of select="$product/@name"/>

    </xsl:template>

</xsl:stylesheet>