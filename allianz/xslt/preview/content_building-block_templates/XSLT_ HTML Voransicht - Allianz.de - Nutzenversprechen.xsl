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
    <div class="c-text-and-image " style="background-color:#CFE9EE;top: 0px; left: 0px; transform: scale({$scale},{$scale}); -ms-transform: scale({$scale},{$scale}); -moz-transform: scale({$scale},{$scale}); -webkit-transform: scale({$scale},{$scale});">
      <div class="l-grid l-grid--max-width">
        <div class="l-grid__row">
          <div class="offset-medium-1 l-grid__column-medium-6 c-text-and-image__right-image-alignment-content-wrapper">
            <div class="l-grid__row flex-column c-text-and-image__content">
              <div class="c-text-and-image__header js-component-header">
                <div class="c-text-and-image__header-container">
                  <div class="l-grid__column-12 u-flex-basis-auto c-text-and-image__subtitle__wrapper">
                    <xsl:apply-templates select="strapline"/>
                  </div>
                  <div class="l-grid__column-12 u-flex-basis-auto c-text-and-image__title__wrapper">
                    <xsl:apply-templates select="headline"/>
                  </div>
                </div>
              </div>
              <div class="l-grid__column-12 u-flex-basis-auto">
                <div class="c-copy   c-text-and-image__copytext  u-text-hyphen-auto">
                  <xsl:apply-templates select="body"/>
                </div>
              </div>
              <div class="c-text-and-image__links l-grid__column-12 u-flex-basis-auto">
              </div>
            </div>
          </div>
          <div class="offset-medium-1 l-grid__column-4 u-hidden-small-down">
            <div class="c-text-and-image__image-column c-text-and-image__image-column--default">
              <div class="c-text-and-image__image-wrapper js-default-component" id="c-text-and-image1891158779" data-is-init="true">
                <picture class="cmp-image c-image">
                  <xsl:apply-templates select="picture"/>
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
  <xsl:template match="picture[@xlink:href]">
    <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'preview')"/>
  </xsl:template>

  <xsl:template match="strapline">
    <div class="c-copy  c-copy--large u-text-small-center-down c-text-and-image__subtitle  u-text-hyphen-auto">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="headline">
    <h2 class="c-heading  c-heading--section u-text-small-center-down u-text-weight-light c-text-and-image__headline c-link--capitalize u-text-hyphen-auto">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="bold">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="paragraph">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="paragraph" mode="list">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="item">
    <li class="c-list__item"><xsl:apply-templates mode="list"/></li>
  </xsl:template>

  <xsl:template match="bullet-list">
    <ul class="c-list">
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates select="paragraph"/>
    <xsl:apply-templates select="bullet-list"/>
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
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" alt="{$asset/@name}" title="{$asset/@name}" sizes="(max-width: 767px) 100vw, (max-width: 991px) 33vw, 350px" data-component-id="root/parsys/chapter_637172613/parsys/text_and_image_13229/image" class="c-image__img"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
