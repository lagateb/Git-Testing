<?xml version="1.0" encoding="UTF-8"?>
<!-- Wir wollen keine Namespaces exclude-result-prefixes="#all" -->
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping" xmlns:csl="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:output indent="yes" method="xml"/>
    <xsl:variable name="debug" select="true()" as="xs:boolean"/>
    <xsl:variable name="masterStorage" select="asset[starts-with(@type, 'text.')]/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>

    <xsl:variable name="groupedFootnotes">
        <xsl:element name="footnotes" >

            <xsl:for-each-group select="$storageContent//footnote/." group-by=".">
                <xsl:if test="name(parent::node()) != 'content'">
                    <sup><xsl:copy-of  select="position()"/></sup>
                    <footnote no="{position()}">
                        <xsl:copy-of  select="text()" />
                    </footnote>
                </xsl:if>
            </xsl:for-each-group>

        </xsl:element>
    </xsl:variable>

    <xsl:template match="asset[starts-with(@type, 'text.')]">

        <xsl:if test="$storageContent">
            <!-- wir holen uns alle verschiedenen Fussnoten ausser aus dem Root content, da wir das als eigenes
                Struktur-Element genutzt haben :(
             -->

            <body> <xsl:apply-templates select="$storageContent/article/content/."/>

                <!-- Ausgabe ohne Namespaces -->
                <xsl:copy-of  select="$groupedFootnotes" copy-namespaces="no" />

            </body>
        </xsl:if>
    </xsl:template>

    <!-- Alles ausser die benannten ? -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="footnote" >
        <xsl:if test="name(parent::node()) != 'content'">
            <xsl:variable name="toSearch" select="text()"/>
            <sup> <xsl:value-of  select="$groupedFootnotes/footnotes/footnote[text()=$toSearch]/@no" /></sup>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
