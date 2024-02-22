<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

  <!-- output -->
  <xsl:output indent="no" method="xml" omit-xml-declaration="no" encoding="UTF-8"/>

  <!-- params -->
  <xsl:param name="presentationIssueId" select="'23648'" as="xs:string?"/>

  <!-- globals -->
  <xsl:variable name="productRelatedArticle" select="cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
  <xsl:variable name="locale" select="svtx:getLoggedInPartyLocale()" as="xs:string?"/>
  <xsl:variable name="fallbackPreviewKey" select="if ($locale eq 'de') then 'svtx:allianz.powerpoint.wizard.no.preview.de' else 'svtx:allianz.powerpoint.wizard.no.preview.en'" as="xs:string"/>
  <xsl:variable name="fallbackPreviewAsset" select="cs:get-resource-asset($fallbackPreviewKey)" as="element(asset)?"/>

  <!-- asset match -->
  <xsl:template match="asset[@type='product.']">
    <xsl:variable name="presentationIssue" select="if ($presentationIssueId castable as xs:long) then cs:get-asset(xs:long($presentationIssueId))[1] else ()" as="element(asset)?"/>
    <xsl:variable name="today" select="cs:format-date(current-dateTime(), 'yyyy-MM-dd-hh-mm')"/>
    <xsl:variable name="fileName" select="cs:make-filename(concat($today,'-', $presentationIssue/@name, '-', @name), 128)" as="xs:string?"/>
    <xsl:variable name="locale" select="svtx:getLoggedInPartyLocale()" as="xs:string?"/>
    <xsl:variable name="fallbackPreviewKey" select="if ($locale eq 'de') then 'svtx:allianz.powerpoint.wizard.no.preview.de' else 'svtx:allianz.powerpoint.wizard.no.preview.en'" as="xs:string"/>
    <xsl:variable name="fallbackPreviewAsset" select="cs:get-resource-asset($fallbackPreviewKey)" as="element(asset)?"/>

    <object>
      <fileName><xsl:value-of select="$fileName"/></fileName>
      <slides censhare:_annotation.arraygroup="true">
        <xsl:variable name="slides" as="element(slide)*">
          <!-- for each defined basic slide -->
          <xsl:for-each select="$presentationIssue/cs:child-rel()[@key='target.']/cs:asset()[@censhare:asset.type = 'presentation.slide.']">
            <!-- sort by child relation sorting attribute -->
            <xsl:sort select="parent_asset_rel[@parent_asset=$presentationIssue/@id]/@sorting" data-type="number"/>
            <!--
            Ein Slide Objekt für:

              - Statische Folie
              - Produkt mit dynamischer Folie
              - Optionales Produkt mit dynamischer folie
             -->

            <xsl:variable name="templateArticle" select="(cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type='article.*' and @censhare:asset-flag='is-template'])[1]" as="element(asset)?"/>
            <xsl:variable name="productArticle" select="$productRelatedArticle[@type=$templateArticle/@type][not(asset_feature[@feature='svtx:optional-component' and @value_long = 1])][1]" as="element(asset)?"/>
            <xsl:variable name="optionalProductArticle" select="$productRelatedArticle[@type=$templateArticle/@type][asset_feature[@feature='svtx:optional-component' and @value_long = 1]]" as="element(asset)*"/>

            <xsl:call-template name="svtx:buildSlideObject">
              <xsl:with-param name="slide" select="."/>
              <xsl:with-param name="article" select="if (exists($productArticle)) then $productArticle else ()"/>
              <xsl:with-param name="template" select="if (exists($templateArticle)) then $templateArticle else ()"/>
            </xsl:call-template>

            <xsl:variable name="currentSlide" select="." as="element(asset)?"/>
            <xsl:for-each select="$optionalProductArticle">
              <xsl:call-template name="svtx:buildSlideObject">
                <xsl:with-param name="slide" select="$currentSlide"/>
                <xsl:with-param name="article" select="."/>
                <xsl:with-param name="template" select="if (exists($templateArticle)) then $templateArticle else ()"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:variable>

        <!-- just apply sorting -->
        <xsl:variable name="slidesWithSorting" as="element(slide)*">
          <xsl:for-each select="$slides">
            <slide>
              <xsl:copy-of select="@*"/>
              <sorting censhare:_annotation.datatype="number"><xsl:value-of select="position()"/></sorting>
              <xsl:copy-of select="node()"/>
            </slide>
          </xsl:for-each>
        </xsl:variable>

        <!-- copy end result -->
        <xsl:copy-of select="$slidesWithSorting"/>
      </slides>
    </object>
  </xsl:template>


  <xsl:template name="svtx:buildSlideObject">
    <xsl:param name="slide" as="element(asset)?"/>
    <xsl:param name="article" select="()" as="element(asset)?"/>
    <xsl:param name="template" select="()" as="element(asset)?"/>

    <xsl:variable name="isStatic" select="if (exists($article and $template)) then false() else true()" as="xs:boolean"/>
    <xsl:variable name="thumbnail" select="$slide/storage_item[@key='thumbnail']/@url" as="xs:string?"/>
    <xsl:variable name="previewUrl" select="if ($thumbnail) then concat('rest/', substring-after($thumbnail, 'censhare:///')) else concat('rest/service/assets/asset/id/', $fallbackPreviewAsset/@id, '/storage/preview/file')" as="xs:string?"/>
    <xsl:variable name="isOptional" select="exists($article/asset_feature[@feature='svtx:optional-component' and @value_long = 1])" as="xs:boolean"/>
    <xsl:variable name="text" select="$article/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*']" as="element(asset)?"/>

    <xsl:if test="$slide and ($isStatic or ($article and $template))">
      <slide display_name="{$slide/@name}">
        <name censhare:_annotation.datatype="string"><xsl:value-of select="$slide/@name"/></name>
        <display_name censhare:_annotation.datatype="string"><xsl:value-of select="if ($isStatic) then $slide/@name else if ($isOptional) then concat($template/@name, ' ', position()) else $template/@name"/></display_name>
        <isStatic censhare:_annotation.datatype="boolean"><xsl:value-of select="$isStatic"/></isStatic>
        <id censhare:_annotation.datatype="number"><xsl:value-of select="$slide/@id"/></id>
        <preview><xsl:value-of select="$previewUrl"/></preview>
        <xsl:if test="$article">
          <article>
            <name censhare:_annotation.datatype="string"><xsl:value-of select="$article/@name"/></name>
            <display_name censhare:_annotation.datatype="string"><xsl:value-of select="if (not($isOptional)) then $template/@name else concat($template/@name, ' ', position())"/></display_name>
            <id censhare:_annotation.datatype="number"><xsl:value-of select="$article/@id"/></id>
            <xsl:if test="$text">
              <textId censhare:_annotation.datatype="number"><xsl:value-of select="$text/@id"/></textId>
            </xsl:if>
          </article>
        </xsl:if>
      </slide>
    </xsl:if>
  </xsl:template>

  <xsl:function name="svtx:getLoggedInPartyLocale" as="xs:string">
    <xsl:variable name="locale" select="cs:master-data('party')[@id=system-property('censhare:party-id')]/@locale"/>
    <!-- because of a bug it's possible that no locale is available - therefore have an english default -->
    <xsl:value-of select="if ($locale) then $locale else 'en'"/>
  </xsl:function>
</xsl:stylesheet>
