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
    <div class="c-chapter__content" style="position: absolute; top: 0px; left: 0px; transform: scale({$scale},{$scale}); -ms-transform: scale({$scale},{$scale}); -moz-transform: scale({$scale},{$scale}); -webkit-transform: scale({$scale},{$scale});">
      <div class="flexible-tile-container container">
        <div class="c-flexible-tile-container c-flexible-tile-container--with-icon" style="display:block;background-color:#F1F9FA;">
          <div class="js-component-header">
            <div class="l-grid l-grid--max-width c-component-header ">
              <div class="l-grid__row">
                <div class="l-grid__column-medium-6 offset-medium-3 c-component-header__pre-headline-wrapper">
                  <xsl:apply-templates select="strapline"/>
                </div>
                <div class="l-grid__column-medium-10 offset-medium-1 c-component-header__headline-wrapper">
                  <xsl:apply-templates select="headline"/>
                </div>
              </div>
            </div>
          </div>
          <div class="c-flexible-tile-container__content l-grid l-grid--max-width">
            <div class="l-grid__row">
              <div class="js-tile-container js-carousel--product-tile l-grid__column-large-12">
                <div class="l-grid__row c-tile__product-tile--wrapper c-flexible-tile__tiles--wrapper">
                  <xsl:apply-templates select="body/bullet-list"/>
                  <div class="desktop-line-break"></div>
                </div>
                <div class="c-tile__product-tile--pagination c-product-tile__pagination swiper-pagination-clickable swiper-pagination-bullets"><span class="c-tile__product-tile--bullet is-active"></span><span class="c-tile__product-tile--bullet"></span><span class="c-tile__product-tile--bullet"></span></div>
                <span class="swiper-notification" aria-live="assertive" aria-atomic="true"></span></div>
            </div>
          </div>
          <div class="c-component-bottom l-container c-component-bottom--no-padding-top">
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ### ELEMENT MATCH ###-->
  <!-- -->
  <xsl:template match="picture[@xlink:href]">
    <a>
      <div class="js-tile-media c-flexible-tile__icon__wrapper">
        <div  aria-hidden="true">
          <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'master')"/>
        </div>
      </div>
    </a>
  </xsl:template>

  <xsl:template match="strapline">
    <span class="c-heading  c-heading--subsection-medium u-text-center c-component-header__pre-headline c-link--capitalize u-text-hyphen-auto">
      <div style="text-align: center;"><xsl:apply-templates/></div>
    </span>
  </xsl:template>

  <xsl:template match="headline">
    <h2 class="c-heading  c-heading--section u-text-center c-component-header__headline c-link--capitalize u-text-hyphen-auto">
      <div style="text-align: center;"><xsl:apply-templates/></div>
    </h2>
  </xsl:template>

  <xsl:template match="item">
    <xsl:if test="position() lt 4">
      <div class="l-grid__column-large-4 l-grid__column-medium-4 c-carousel__three-column__slide c-tile__product-tile--slide c-flexible-tile__slide">
        <div class="flexible-tile container">
          <div class="js-tile-item js-default-component c-flexible-tile c-flexible-tile--with-icon" id="c-flexible-tile1760489507" data-is-init="true">
            <xsl:apply-templates select="picture"/>
            <xsl:apply-templates select="headline" mode="custom"/>
            <xsl:apply-templates select="paragraph"/>
            <div class="js-tile-cta c-flexible-tile__bottom" style="margin-bottom: 0px; margin-top: auto;">
            </div>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates select="bullet-list"/>
  </xsl:template>

  <xsl:template match="headline" mode="custom">
    <span class="c-unformatted-text">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="bullet-list">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="bold">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="paragraph">
    <div class="c-copy c-flexible-tile__text u-text-center  u-text-hyphen-auto">
      <xsl:apply-templates/>
    </div>
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
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" style="background: #006192;padding: 1rem;" alt="{$asset/@name}" title="{$asset/@name}" class="c-icon c-flexible-tile__icon c-flexible-tile__icon-bg-white c-icon--m t-primary-action-dark"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
