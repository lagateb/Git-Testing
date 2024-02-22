<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">


<!--  Daten für andere Transformationen
          Konstanten und allgemeine Functionen
          einbinden mit
          <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>
     -->

    <xsl:variable name="publicDomain" select="'root.allianz-leben-ag.contenthub.public.'"/>
    <xsl:variable name="archivedDomain" select="'root.allianz-leben-ag.archive.'"/>
    <xsl:variable name="publicTypeToken" select="'public.'"/>
    <xsl:variable name="faqPublicType" select="'text.public.faq.'"/>



    <!-- Liefert den type des text als public z.b. text.size-x => text.public.size-s.  -->
    <xsl:function name="svtx:getPublicType" as="xs:string">
        <!-- text.public.public.size-m. -->

        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:variable name="type" select="$textAsset/@type"/>
        <xsl:value-of select="concat(substring-before($type,'.'),'.',$publicTypeToken,substring-after($type,'.'))"/>
    </xsl:function>

    <xsl:function name="svtx:isAssetVariant" as="xs:boolean">
        <xsl:param name="asset" as="element(asset)?"/>
        <xsl:value-of select="exists($asset/parent_asset_rel[@key='variant.1.'])"/>
    </xsl:function>

    <!-- liefert fuer den OutputChannel-name die Nummer -->
    <xsl:function name="svtx:channelToNumber" as="xs:integer">
        <xsl:param name="channel" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$channel = 'root.web.aem.aem-vp.'">1</xsl:when>
            <xsl:when test="$channel = 'root.web.aem.aem-azde.'">2</xsl:when>
            <xsl:when test="$channel = 'root.web.bs.'">3</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
