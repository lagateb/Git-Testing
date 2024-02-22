<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">
    <!-- Teilt die Tabelle in 2 Teile auf, wobei die beiden Überschriftzeilen übrgangen werden und die Zeile 3
         auch auf dem 2 Bereich mit übernommen wird
    -->
    <!-- Welche Seite? -->
    <xsl:param name="transParam"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>

    <xsl:variable name="transParamInt" select="$transParam" as="xs:integer" />
    <!-- zum Test $transParam
    <xsl:variable name="transParam" select="1" as="xs:integer"/>
    -->
    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageConent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="headerRowCount" select="$storageConent/article/content/table/@header-row-count"/>
        <xsl:variable name="footerRowCount" select="$storageConent/article/content/table/@footer-row-count"/>
        <xsl:variable name="style" select="$storageConent/article/content/table/@style"/>
        <xsl:if test="$storageConent">
            <body>
                <table header-row-count="{$headerRowCount}"  footer-row-count="{$footerRowCount}"  >
                    <!--  Wir brauchen  headerRowCount Zeilen + 1 für jede Tabelle +5   bei 1 und   den rest für 2 -->
                    <!-- Aufgeteilt durch if, da besser lesbar -->
                     <xsl:if test="$transParamInt = 1">
                         <xsl:apply-templates select="$storageConent/article/content/table/row[ (position() le ($headerRowCount+5))  ]"/>
                    </xsl:if>
                    <xsl:if test="$transParamInt = 2">
                        <xsl:apply-templates select="$storageConent/article/content/table/row[ (position() le ($headerRowCount+1)) or  (position() gt ($headerRowCount+5)) ]"/>
                    </xsl:if>

                </table>
            </body>
        </xsl:if>
    </xsl:template>

    <xsl:template match="row" >
        <row>
            <xsl:copy-of  select="./*"/>
        </row>
    </xsl:template>




</xsl:stylesheet>
