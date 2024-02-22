<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:pptx.command.utils.xsl/storage/master/file" />
    <!--
       Wird durch csContentEditorPreviewWidget.ts aufgerufen und tauscht das Layout der PPTX-Folien gegen ein anderes
       Dabei wird ggf. auch der Name der Folie angepasst
       asset das zu ändernde  Slide
        masterSlideId Das #Asset mit dem neuen Layout
    -->

    <xsl:param name="masterSlideId" select="43888" />
    <xsl:variable name="masterSlideIdInt" select="$masterSlideId" as="xs:integer" />

    <xsl:variable name="debug" select="false()"/>

    <xsl:template match="/asset">
        <xsl:variable name="slide" select="."/>
        <xsl:if test="$debug">
        <xsl:message>====s <xsl:value-of select="$slide/@id"/></xsl:message>
        <xsl:message>====m <xsl:value-of select="$masterSlideIdInt"/></xsl:message>
        </xsl:if>
        <xsl:variable name="masterSlide" select="cs:get-asset($masterSlideIdInt)"/>
        <xsl:variable name="hasArticle" select="$slide/child_asset_rel[@key='target.']/@child_asset"/>
        <xsl:variable name="newMasterKey" select="$masterSlide/asset_feature[@feature='censhare:resource-key']/@value_asset_key" />

        <!-- immer alle Slides Standard,Makler Vertrieb
          über slide->article->slides
        -->
        <xsl:variable name="allSlides" select="$slide/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'article.*']/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.']" />


        <xsl:for-each select="$allSlides">
        <xsl:variable name="curentSlide" select="."/>
        <xsl:variable name="oldSlideMasterKey" select="$curentSlide/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref"/>
        <xsl:variable name="oldSlideLayout" select="cs:asset()[@censhare:resource-key=$oldSlideMasterKey]" as="element(asset)?"/>

        <xsl:variable name="newName" select="replace ($curentSlide/@name, $oldSlideLayout/@name, $masterSlide/@name)"/>
        <xsl:if test="$debug">
            <xsl:message>====o <xsl:value-of select="$curentSlide/@name"/></xsl:message>
            <xsl:message>====s <xsl:value-of select="$oldSlideLayout/@name"/></xsl:message>
            <xsl:message>====r <xsl:value-of select="$masterSlide/@name"/></xsl:message>
            <xsl:message>====n <xsl:value-of select="$newName"/></xsl:message>
        </xsl:if>
        <xsl:if test="$curentSlide and $newMasterKey">
          <xsl:value-of select="svtx:updateSlideFromMasterV2($curentSlide,$newMasterKey,$hasArticle,$newName)"/>
        </xsl:if>

        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
