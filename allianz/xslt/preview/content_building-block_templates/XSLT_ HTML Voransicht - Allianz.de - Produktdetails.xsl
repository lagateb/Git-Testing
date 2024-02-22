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
    <div class="chapter container" style="top: 0px; left: 0px; transform: scale({$scale},{$scale}); -ms-transform: scale({$scale},{$scale}); -moz-transform: scale({$scale},{$scale}); -webkit-transform: scale({$scale},{$scale});">
      <div class="c-chapter js-chapter" data-is-init="false">
      <div class="c-chapter__content">
        <div class="comparison-table container">
          <div class="c-comparison-table-wrapper js-azde-comparison-table" data-columns="1" data-marked="none">
            <div class="c-comparison-table-bg" style="background-color: #CFE9EE;">
              <div class="c-comparison-table-top-bg" style="background-color: rgb(207, 233, 238); height: 502.633px;"></div>
              <div class="js-component-header c-comparison-table-header">
                <div class="l-grid l-grid--max-width c-component-header ">
                  <div class="l-grid__row">
                    <div class="l-grid__column-medium-6 offset-medium-3 c-component-header__pre-headline-wrapper">
                      <span class="c-heading  c-heading--subsection-medium u-text-center c-component-header__pre-headline c-link--capitalize u-text-hyphen-auto">
                        <xsl:apply-templates select="strapline"/>
                      </span>
                    </div>
                    <div class="l-grid__column-medium-10 offset-medium-1 c-component-header__headline-wrapper">
                      <xsl:apply-templates select="headline"/>
                    </div>
                    <div class="l-grid__column-medium-8 offset-medium-2 c-component-header__image-position--below c-component-header__image-wrapper">
                      <picture class="cmp-image c-image">
                        <xsl:apply-templates select="picture"/>
                      </picture>
                    </div>
                    <xsl:apply-templates select="table"/>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ### ELEMENT MATCH ###-->
  <xsl:template match="table">
    <div class="c-comparison-table-large-container--wrapper">
      <div class="c-comparison-table-large-container l-container">
        <div class="c-comparison-table-container c-comparison-table-container--1-columns" data-columns="1">
          <div class="js-sticky-placeholder"></div>
          <div class="js-comparison-table-content">
            <div class="c-comparison-table__section c-comparison-table__section--header js-sticky-header">
              <div class="c-comparison-table__row c-comparison-table__row--header js-sticky-header-row">
                <div class="c-comparison-table__col c-comparison-table__col--header empty-cell" style="flex: 1 1 1px; width: 100%;"></div>
                <div class="c-comparison-table__col c-comparison-table__col--header c-comparison-table__col--highlighted" style="flex: 1 1 1px; width: 100%;">
                  <div class="c-comparison-table__col--header-highlighted ">
                    <div class="c-comparison-table-head-cell c-comparison-table-head-cell-2" style="height: 24px;">
                      <div class="c-comparison-table-head-cell-content">
                        <div class="unformatted-text c-comparison-table-head-cell-headline">
                        </div>
                        <div class="unformatted-text c-comparison-table-head-cell-price">
                        </div>
                        <div class="unformatted-text c-comparison-table-head-cell-legend">
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="c-comparison-table__section c-comparison-table__section-body">
              <div class="parsys c-comparison-table__section-body--wrapper">
                <xsl:apply-templates select="row"/>
              </div>
            </div>
            <div class="c-comparison-table__section c-comparison-table__section-footer">
              <div class="c-comparison-table__row shadow-top-bottom">
                <div class="c-comparison-table__col empty-cell"
                     style="flex: 1 1 1px; width: 100%;">
                </div>
                <div class="comparison-table-button-cell container c-comparison-table__col c-comparison-table__col--highlighted"
                     style="flex: 1 1 1px; width: 100%;">
                  <div class="c-comparison-table__col--button-highlighted">
                    <a href="https://www.allianz.de/vorsorge/schatzbrief/rechner/"
                       target="_self"
                       aria-label="Jetzt berechnen"
                       class=" c-button     c-button--direct-emphasis  c-button--link c-button-link-center-align">
                      Jetzt berechnen
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- -->
  <xsl:template match="row">
    <div class="c-comparison-table__row">
      <div class="comparison-table-row-label container c-comparison-table__row-label c-comparison-table__col">
        <div class="c-comparison-table__col--regular">
          <div class="c-copy   c-comparison-table__row-label--text">
            <xsl:apply-templates select="cell[1]"/>
          </div>
        </div>
      </div>
      <div class="comparison-table-cell container c-comparison-table__row-cell c-comparison-table__col c-comparison-table__row-cell--tooltip" style="height: 80px; flex: 1 1 1px; width: 100%;">
        <div class="c-comparison-table__col--highlighted ">
          <div class="c-copy   c-comparison-table__row-label--text ">
            <xsl:apply-templates select="cell[1]"/>
          </div>
          <span class="c-unformatted-text">
            <xsl:apply-templates select="cell[2]"/>
          </span>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- -->
  <xsl:template match="cell">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- -->
  <xsl:template match="picture[@xlink:href]">
    <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'preview')"/>
  </xsl:template>

  <xsl:template match="strapline">
    <div style="text-align: center;"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="headline">
    <h2 class="c-heading  c-heading--section u-text-center c-component-header__headline c-link--capitalize u-text-hyphen-auto">
      <div style="text-align: center;"><xsl:apply-templates/></div>
    </h2>
  </xsl:template>

  <xsl:template match="bold">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="paragraph">
    <xsl:apply-templates/>
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
