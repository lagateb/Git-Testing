<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">
    <xsl:param name="transFormed"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>


    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$content">
            <body>
                <table style="let-textalignment" footer-row-count="1" >
                    <!-- <xsl:copy-of select="$content/article/content/table/row" copy-namespaces="no"  /> -->
                    <xsl:apply-templates select="$content/article/content/table/row"/>
                </table>
            </body>
        </xsl:if>
    </xsl:template>

    <xsl:template match="row" >
        <row >

            <xsl:apply-templates select="cell"/>
        </row>
    </xsl:template>

    <xsl:template match="cell[1]" >
        <cell style="left" >
            <xsl:copy-of  select="./*" copy-namespaces="no"  />
        </cell>
    </xsl:template>

    <xsl:template match="cell[2]" >
        <cell style="right" >
            <xsl:copy-of  select="./*" copy-namespaces="no"  />
        </cell>
    </xsl:template>



</xsl:stylesheet>
