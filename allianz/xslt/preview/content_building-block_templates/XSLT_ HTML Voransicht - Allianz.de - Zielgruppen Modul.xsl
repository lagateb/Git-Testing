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
      <div class="two-column-icon-container container">
        <div class="c-two-column-icon-container" style="background-color:transparent">
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

          <div class="l-container js-tile-container">
            <div class="l-grid__row">
              <div class="l-grid__column-medium-6">
                <div class="c-two-column-icon-container__column js-two-column-icon-container__column js-tile-item"
                     style="background-color: #ECECEC"
                     id="two-column-icon-container-column-1589362440" data-is-init="true">
                  <div class="c-two-column-icon-container__column__icon js-tile-media">
                    <em class="c-icon c-icon--check t-process-success c-icon--outline c-icon--m t-bg-white"
                        aria-hidden="true">
                    </em>
                  </div>
                  <xsl:apply-templates select="body/pro"/>
                  <div class="js-tile-cta c-two-column-icon-container__column__bottom-content u-hidden-small-down u-text-align-left"
                       style="margin-bottom: 0px; margin-top: auto;">
                  </div>
                  <div class="c-two-column-icon-container__column__show-more-less-wrapper u-hidden-medium-up">
                    <a class="c-link c-link--block c-two-column-icon-container__column__show-more-less-wrapper__more-link"
                       href="#">
                      <span aria-hidden="true"
                            class="c-link__icon c-icon c-icon--chevron-down"></span>
                      <span class="c-link__text">Mehr Infos</span>
                    </a>
                    <a class="c-link c-link--block c-two-column-icon-container__column__show-more-less-wrapper__less-link u-hidden"
                       href="#">
                      <span aria-hidden="true"
                            class="c-link__icon c-icon c-icon--chevron-up"></span>
                      <span class="c-link__text">Weniger Infos</span>
                    </a>
                  </div>
                </div>
              </div>
              <div class="l-grid__column-medium-6">
                <div class="c-two-column-icon-container__column js-two-column-icon-container__column js-tile-item"
                     style="background-color: #ECECEC" data-is-init="true">
                  <div class="c-two-column-icon-container__column__icon js-tile-media">
                    <em class="c-icon c-icon--minus t-rich-red  c-icon--outline c-icon--m t-bg-white" aria-hidden="true">
                    </em>
                  </div>
                  <xsl:apply-templates select="body/contra"/>
                  <div class="js-tile-cta c-two-column-icon-container__column__bottom-content u-hidden-small-down u-text-align-left"
                       style="margin-bottom: 0px; margin-top: auto;">
                  </div>

                  <div class="c-two-column-icon-container__column__show-more-less-wrapper u-hidden-medium-up">
                    <a class="c-link c-link--block c-two-column-icon-container__column__show-more-less-wrapper__more-link"
                       href="#">
                      <span aria-hidden="true"
                            class="c-link__icon c-icon c-icon--chevron-down"></span>
                      <span class="c-link__text">Mehr Infos</span>
                    </a>
                    <a class="c-link c-link--block c-two-column-icon-container__column__show-more-less-wrapper__less-link u-hidden"
                       href="#">
                      <span aria-hidden="true"
                            class="c-link__icon c-icon c-icon--chevron-up"></span>
                      <span class="c-link__text">Weniger Infos</span>
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="c-component-bottom l-container c-component-bottom--no-padding-top"></div>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ### ELEMENT MATCH ###-->

  <xsl:template match="strapline">
    <span class="c-heading  c-heading--subsection-medium u-text-center c-component-header__pre-headline c-link--capitalize u-text-hyphen-auto">
      <div style="text-align: center;"><xsl:apply-templates/></div>
    </span>
  </xsl:template>

  <xsl:template match="pro | contra">
    <xsl:apply-templates mode="custom">
      <xsl:with-param name="style" select="local-name(.)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="item/paragraph" mode="custom">
    <xsl:param name="style"/>
    <li class="c-text-with-column-icon">
      <div class="c-two-column-icon-container__column__text-with-icon">
        <span style="border-width:0px;" class="c-two-column-icon-container__column__text-with-icon__icon c-icon {if ($style='pro') then 'c-icon--check t-process-success' else 'c-icon--minus t-rich-red'}  c-icon--outline t-bg-white c-icon–xs"></span>
        <div class="c-two-column-icon-container__column__text-with-icon__copytext">
          <div class="c-copy     u-text-hyphen-auto">
            <xsl:apply-templates/>
          </div>
        </div>
      </div>
    </li>
  </xsl:template>

  <xsl:template match="bullet-list" mode="custom">
    <xsl:param name="style"/>
    <ul class="c-two-column-icon-container__column__text-with-column-icon-container u-hidden-small-down">
      <xsl:apply-templates select="item/paragraph" mode="custom">
        <xsl:with-param name="style" select="$style"/>
      </xsl:apply-templates>
    </ul>
  </xsl:template>

  <xsl:template match="headline" mode="custom">
    <h3 class="c-heading  c-heading--subsection-large c-two-column-icon-container__column__content__headline c-link--capitalize u-text-hyphen-auto">
      <xsl:apply-templates/>
    </h3>
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
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" style="background: #006192;padding: 1rem;" alt="{$asset/@name}" title="{$asset/@name}" class="c-icon c-flexible-tile__icon c-flexible-tile__icon-bg-white c-icon--m t-primary-action-dark"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
