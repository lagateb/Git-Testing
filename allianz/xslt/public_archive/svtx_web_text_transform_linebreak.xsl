<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:param name="transFormed"/>
    <xsl:param name="advisorySuite" select="'yes'"/>
    <xsl:param name="channel" select="0" />

    <xsl:variable name="debug" select="false()" as="xs:boolean"/>

    <!--
      - löscht die Sonderzeichen für Linebreak Flyer und Produktsteckbrief und setzt für PPTX das break
      - bearbeitet das Element link he nach channel
    -->


    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
        <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="content" select="if ($transFormed) then $transFormed else $storageContent"/>
        <xsl:if test="$storageContent"><xsl:apply-templates select="$content"  /></xsl:if>
    </xsl:template>




    <xsl:function name="svtx:getFollowValue" as="xs:string?">
        <xsl:param name="followValue"/>
        <xsl:choose>
            <xsl:when test="$followValue = 'no-follow'">nofollow</xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <!-- kopiert alle Elemente + attribute -->
    <xsl:template match="*|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="link">
        <xsl:variable name="data">
            <xsl:choose>
                <xsl:when test="$channel = 1 and ./@url1 and ./@url1 != '' ">
                    <a href="{./@url1}" target="{./@target1}" title="{./@seo-title1}" rel="{svtx:getFollowValue(./@follow1)}">
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="$channel = 2 and ./@url2 and ./@url2 != '' ">
                    <a href="{./@url2}" target="{./@target2}" title="{./@seo-title2}" rel="{svtx:getFollowValue(./@follow2)}">
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:when test="$channel = 3 and ./@url3 and ./@url3 != '' ">
                    <a href="{./@url3}" target="{./@target3}" title="{./@seo-title3}" rel="{svtx:getFollowValue(./@follow3)}">
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$data"/>
    </xsl:template>


    <xsl:template match="text()" >
        <!-- Habe bis jetzt keinen anderen Weg gefunden ein Zeilenumbruch einzufügen
           ACHTUNG so stehen lassen. nicht einrücken etc.
        -->
        <xsl:variable name="myBreak"><xsl:text>
</xsl:text>
        </xsl:variable>
        <xsl:variable name="con" select="replace(., '&#xe000;|&#xe001;|&#xe002;', '')"/>
        <xsl:choose>
            <xsl:when test="$advisorySuite='yes'">
                <!-- crlf oder nur cr oder wirklich  \n? -->
                <xsl:value-of  select="replace($con, '&#xe003;', $myBreak)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of  select="replace($con, '&#xe003;', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
