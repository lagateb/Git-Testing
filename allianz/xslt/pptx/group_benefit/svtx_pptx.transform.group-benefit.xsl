<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

    <!-- Welche Gruppe 1 bis 4 -->
    <xsl:param name="transParam"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>

    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />
    <!-- zum Test $transParam
    <xsl:variable name="transParam" select="1" as="xs:integer"/>
    -->
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:if test="$storageContent">
            <xsl:variable name="what"  select="svtx:getGroupInfo($transParamInt,$storageContent)"/>
            <group action="{$what}"/>
        </xsl:if>
    </xsl:template>




    <!-- kontrolliert ob die Gruppe angezeigt werden soll oder gelöscht -->
    <!-- xlink:href
    select="$xmlContent/article/content/picture[1]/@xlink:href"/>
    -->
    <xsl:function name="svtx:getGroupInfo">
        <xsl:param name="group"/>
        <xsl:param name="content"/>
        <xsl:variable name="g1" select="if ($content/article/content/seals/seal[1]/logo/@xlink:href) then true() else false()" />
        <xsl:variable name="g2" select="if ($content/article/content/seals/seal[2]/logo/@xlink:href) then true() else false()" />
        <xsl:variable name="g3" select="if ($content/article/content/picture/@xlink:href) then true() else false()" />
        <xsl:choose>
            <xsl:when test="$group = 1">
                <xsl:value-of select="svtx:showOrHide($g1)"/>
            </xsl:when>
            <xsl:when test="$group = 2">
                <xsl:value-of select="svtx:showOrHide($g1 and $g2)"/>
            </xsl:when>
            <xsl:when test="$group = 3">
                <xsl:value-of select="svtx:showOrHide(not($g1) and $g3)"/>
            </xsl:when>

            <xsl:when test="$group = 4">
                <xsl:value-of select="svtx:showOrHide(not($g1 or $g3))" />
            </xsl:when>

            <xsl:otherwise>hide</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:showOrHide">
        <xsl:param name="show"/>
        <xsl:choose>
        <xsl:when test="$show">show</xsl:when>
        <xsl:otherwise>hide</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
