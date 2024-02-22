<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:csc="http://www.censhare.com/censhare-custom" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs csc">

    <!-- feature url  -->

    <!-- output -->
    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

    <!-- params -->
    <xsl:param name="rootAsset"/>
    <xsl:param name="language"/>

    <!-- asset match -->
    <xsl:template match="asset">
        <xsl:variable name="published" select="cs:child-rel()[@key='user.web-usage.']" as="element(asset)*"/>
        <xsl:variable name="mainContent" select="cs:child-rel()[@key='user.main-content.']" as="element(asset)*"/>
        <xsl:variable name="layouts" select="$mainContent/cs:parent-rel()[@key='actual.']/cs:asset()[@censhare:asset.type='layout.*']"/>
        <xsl:variable name="slide" select="cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type='presentation.slide.']"/>
        <xsl:variable name="issue" select="$slide/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type='presentation.issue.']"/>
        <xsl:variable name="publishedLayouts" select="exists($layouts[@wf_step=(30,60,55,90)])" as="xs:boolean"/>
        <xsl:variable name="publishedIssue" select="exists($issue[@wf_step=(30,60,55,90)])" as="xs:boolean"/>
        <xsl:variable name="public" select="$published[@domain = 'root.allianz-leben-ag.contenthub.public.']" as="element(asset)*"/>
        <xsl:variable name="sizes" as="xs:string*">
            <xsl:if test="$public[@type='text.public.size-s.'] or (($publishedLayouts or $publishedIssue) and $mainContent[@type='text.size-s.'])">
                <text>S</text>
            </xsl:if>
            <xsl:if test="$public[@type='text.public.size-m.']  or (($publishedLayouts or $publishedIssue) and $mainContent[@type='text.size-m.'])">
                <text>M</text>
            </xsl:if>
            <xsl:if test="$public[@type='text.public.size-l.'] or (($publishedLayouts or $publishedIssue) and $mainContent[@type='text.size-l.'])">
                <text>L</text>
            </xsl:if>
            <xsl:if test="$public[@type='text.public.size-xl.'] or (($publishedLayouts or $publishedIssue) and $mainContent[@type='text.size-xl.'])">
                <text>XL</text>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="string-join($sizes,', ')"/>
    </xsl:template>

</xsl:stylesheet>
