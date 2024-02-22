<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">

  <!-- output -->
  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- parameter -->
  <xsl:param name="mode" select="()"/>
  <xsl:param name="scale" select="1.0"/>

  <!-- variables -->
  <xsl:variable name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="urlPrefix" select="if ($mode = 'browser') then '/ws/rest/service/' else if ($mode='cs5') then '/censhare5/client/rest/service/' else '/service/'" as="xs:string"/>

  <xsl:template match="content">
    <div class="image-or-video container" style="top: 0px; left: 0px; transform: scale({$scale},{$scale}); -ms-transform: scale({$scale},{$scale}); -moz-transform: scale({$scale},{$scale}); -webkit-transform: scale({$scale},{$scale});">
      <div class="c-image-or-video js-default-component c-image-or-video--no-background" id="c-image-or-video1739936123" data-is-init="true" style="background-color:transparent;">
        <div class="js-component-header">
          <div class="l-grid l-grid--max-width c-component-header ">
            <div class="l-grid__row">
              <div class="l-grid__column-medium-6 offset-medium-3 c-component-header__pre-headline-wrapper">
                <span class="c-heading  c-heading--subsection-medium u-text-center c-component-header__pre-headline c-link--capitalize u-text-hyphen-auto">
                  <xsl:apply-templates select="strapline"/>
                </span>
              </div>
              <div class="l-grid__column-medium-10 offset-medium-1 c-component-header__headline-wrapper">
                <h2 class="c-heading  c-heading--section u-text-center c-component-header__headline c-link--capitalize u-text-hyphen-auto">
                  <xsl:apply-templates select="headline"/>
                </h2>
              </div>
              <div class="l-grid__column-medium-8 c-component-header__copytext-wrapper offset-medium-2">
                <xsl:apply-templates select="description"/>
              </div>
            </div>
          </div>
        </div>
        <div class="c-image-or-video__media">
          <div class="l-grid l-grid--max-width">
            <div class="c-image-or-video__image l-grid__row">
              <div class="l-grid__column-medium-12 offset-medium-0">
                <picture class="cmp-image c-image">
                  <xsl:apply-templates select="picture-q"/>
                </picture>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ### ELEMENT MATCH ###-->
  <!-- -->
  <xsl:template match="picture-q[@xlink:href]">
    <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'preview')"/>
  </xsl:template>

  <xsl:template match="strapline">
    <div style="text-align: center;"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="description">
    <div class="c-copy   u-text-center c-component-header__copytext  u-text-hyphen-auto">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="headline">
    <div style="text-align: center;"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="bold">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getCheckedOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="if (exists($asset) and $asset/@checked_out_by) then cs:get-asset($asset/@id, 0, -2) else $asset"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getCheckedOutMasterStorage" as="element(storage_item)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="checkedOutAsset" select="svtx:getCheckedOutAsset($asset)"/>
    <xsl:copy-of select="$checkedOutAsset/storage_item[@key='master']"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getImageElementOfHref" as="element(img)?">
    <xsl:param name="href" as="xs:string"/>
    <xsl:param name="storageKey" as="xs:string"/>
    <xsl:variable name="assetID" select="tokenize(substring-after($href, '/asset/id/'), '/')[1]"/>
    <xsl:if test="$assetID">
      <xsl:variable name="assetVersion" select="substring-before(substring-after($href, '/version/'), '/')"/>
      <xsl:variable name="asset" select="if ($assetVersion) then cs:get-asset(xs:integer($assetID), xs:integer($assetVersion)) else cs:get-asset(xs:integer($assetID))"/>
      <xsl:variable name="storageItem" select="$asset/storage_item[@key=$storageKey]"/>
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" alt="{$asset/@name}" title="{$asset/@name}" sizes="(max-width: 1110px) 100vw, 1110px" class="c-image__img"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
