<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

    <!-- wieviel Spalten hat die PPTX-Vorlagen-Tabelle  -->
    <xsl:param name="transParam"/>
    <xsl:param name="transFormed"/>



    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:variable name="colCount" select="count($content/article/content/table/row[1]/cell)"/>

        <xsl:if test="$content">
            <xsl:variable name="what"  select="svtx:getTableInfo($transParam,$colCount)"/>
            <body>
                <!-- mit Übernahme der Attribute des Table Elements -->
            <table action="{$what}"> <xsl:copy-of select="$content/article/content/table/@*"/>
              <xsl:copy-of select="$content/article/content/table/*" />
            </table>
            </body>
        </xsl:if>
    </xsl:template>

    <!-- kontrolliert ob die Tabelle angezeigt werden soll
         v2 ge x damit es möglich ist trotz zu vieler Spalten eine Tabelle anzuzeigen
    -->
    <xsl:function name="svtx:getTableInfo">
        <xsl:param name="cols"/>
        <xsl:param name="count"/>

        <xsl:choose>
        <xsl:when test="starts-with($cols,'ge')">
            <xsl:variable name="minVal" select="number(substring-after($cols, 'ge'))"/>
            <xsl:choose>
                <xsl:when test="$count ge $minVal">show</xsl:when>
                <xsl:otherwise>hide</xsl:otherwise>
            </xsl:choose>
        </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="colsInt" select="number($cols)" />
                <xsl:choose>
                    <xsl:when test="$count = $colsInt">show</xsl:when>
                    <xsl:otherwise>hide</xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
