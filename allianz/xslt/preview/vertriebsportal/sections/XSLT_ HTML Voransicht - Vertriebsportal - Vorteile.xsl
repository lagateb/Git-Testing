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
        <div class="container" style="top: 0px; left: 0px; transform: scale({$scale},{$scale}); -ms-transform: scale({$scale},{$scale}); -moz-transform: scale({$scale},{$scale}); -webkit-transform: scale({$scale},{$scale});">
            <div class="mod-infotables bg-soft-blue padding-medium px-4">
                <div class="row">
                    <div class="col-12 text-center">
                        <h3>
                            <xsl:apply-templates select="strapline"/>
                        </h3>
                        <h2 class="margin-small">
                            <xsl:apply-templates select="headline"/>
                        </h2>
                        <p class="d-block mb-5">
                            <xsl:apply-templates select="subline"/>
                        </p>
                    </div>
                </div>
                <div class="row mt-5  circle-image">

                    <xsl:apply-templates select="body/bullet-list"/>
                </div>
                <div class="row mt-2">
                    <div class="col-12">
                        <small>
                            <xsl:apply-templates select="footnote"/>
                        </small>
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
            <p class="helperimage offset-top-50" >
              <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'master')"/>
            </p>
        </div>
      </div>
    </a>
  </xsl:template>

  <xsl:template match="strapline">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="headline">
     <xsl:apply-templates/>
  </xsl:template>

    <xsl:template match="subline">
        <xsl:apply-templates/>
    </xsl:template>

  <xsl:template match="item">
    <xsl:if test="position() lt 5">
        <div class="col-12 col-lg-3 mb-4 mb-lg-0">
            <div class="inner bg-grey text-center px-4 h-100 pb-5 circle-image {concat('impos',position())}">

                <xsl:apply-templates select="picture"/>

                <p style="margin-top: -18px;">
                    <strong><xsl:apply-templates select="headline"/></strong>&#160;
                    <xsl:apply-templates select="paragraph"/>
                </p>


            </div>
        </div>

    </xsl:if>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates select="bullet-list"/>
  </xsl:template>

  <xsl:template match="bullet-list">
    <xsl:apply-templates/>
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
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}"  class="img-fluid"  />
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
