<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">
    <xsl:param name="transParam"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>

    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />
    <!-- zum Test $transParam
    <xsl:variable name="transParam" select="1" as="xs:integer"/>
    -->
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="footerRowCount" select="count($storageContent/article/content/body/bullet-list/item)"/>
        <xsl:if test="$storageContent">
            <xsl:variable name="what"  select="svtx:getGroupInfo($transParamInt,$footerRowCount)"/>
            <group action="{$what}"/>
        </xsl:if>
    </xsl:template>

       <!-- kontrolliert ob die Gruppe angezeigt werden soll oder gelöscht -->
    <xsl:function name="svtx:getGroupInfo">
        <xsl:param name="group"/>
        <xsl:param name="count"/>
        <xsl:choose>
            <xsl:when test="$group = $count">show</xsl:when>
            <xsl:when test="$group = 3 and $count lt 3">show</xsl:when>
            <xsl:when test="$group = 5 and $count gt 5">show</xsl:when>
            <xsl:otherwise>hide</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
