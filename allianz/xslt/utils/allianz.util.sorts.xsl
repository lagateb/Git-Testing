<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"

                exclude-result-prefixes="#all"

                version="2.0">



    <xsl:function name="svtx:getSubSortForAssetName">
        <xsl:param name="name" as="xs:string" />
        <!-- 620 -->
        <xsl:choose>
            <xsl:when test="contains($name,'Vorsorgekonzept')">620</xsl:when>
            <xsl:when test="contains($name,'Rahmenbedingungen')">621</xsl:when>
            <xsl:when test="contains($name,'Nachhaltigkeit')">622</xsl:when>
            <xsl:when test="contains($name,'Tools')">623</xsl:when>
            <xsl:when test="contains($name,'FAQ')">624</xsl:when>
            <xsl:otherwise>629</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
 <!-- Liefert einen Value  zur speziellen Sortierung der AssetTypen
      Vorgaben von Allianz
 -->
    <xsl:function name="svtx:getSortValueForAssetType">
        <xsl:param name="type" as="xs:string" />
        <xsl:param name="name" as="xs:string" />
        <!-- Vorgaben von Allianz -->
        <xsl:choose>
            <xsl:when test="$type='article.header.'">100</xsl:when>
            <xsl:when test="$type='article.produktbeschreibung.'">200</xsl:when>
            <xsl:when test="$type='article.funktionsgrafik.'">200</xsl:when>
            <xsl:when test="$type='article.vorteile.'">300</xsl:when>
            <xsl:when test="$type='article.fallbeispiel.'">400</xsl:when>
            <xsl:when test="$type='article.nutzenversprechen.'">500</xsl:when>
            <xsl:when test="$type='article.zielgruppenmodul.'">510</xsl:when>
            <xsl:when test="$type='article.productdetails.'">530</xsl:when>
            <xsl:when test="$type='article.staerken.'">560</xsl:when>
            <xsl:when test="$type='article.flexi-module.'">570</xsl:when>
            <xsl:when test="$type='article.optional-module.'"><xsl:value-of select="svtx:getSubSortForAssetName($name)"/></xsl:when>
            <xsl:when test="$type='article.free-module.'">630</xsl:when>
            <xsl:when test="$type='layout.'">700</xsl:when>
            <xsl:when test="$type='presentation.issue.'">800</xsl:when>
            <xsl:otherwise>999</xsl:otherwise>
        </xsl:choose>
    </xsl:function>




<xsl:function name="svtx:getSortValueForAsset">
    <xsl:param name="asset" as="element(asset)" />
    <xsl:variable name="type" select="$asset/@type"/>
    <xsl:variable name="name" select="$asset/@name"/>
    <xsl:value-of select="svtx:getSortValueForAssetType($type,$name)"/>
</xsl:function>


        <!-- holt sich die Seitenzahl des angehängten PDFs über PDFInfo -->
    <xsl:function name="svtx:getPDFCountPages">
        <xsl:param name="textAsset" as="element(asset)" />
        <xsl:param name="storageItemType" as="xs:string"/>
        <xsl:variable name="pdfStorage" select="$textAsset/storage_item[@key=$storageItemType]" as="element(storage_item)?"/>
        <xsl:choose>
            <xsl:when test="$pdfStorage">
                <xsl:variable name="info">
                    <cs:command name="com.censhare.api.pdf.InfoPDF">
                        <cs:param name="source" select="$pdfStorage/@url" as="xs:string"/>
                    </cs:command>
                </xsl:variable>
                <xsl:copy-of select="$info/InfoPDF/Catalog/Pages/Pages/Count/text()"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
