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
            <div class="mod-detail-table bg-soft-blue padding-medium px-4">
                <div class="row">
                    <div class="col-12 text-center">
                        <h3>
                            <xsl:apply-templates select="strapline"/>
                        </h3>
                        <h2 class="margin-small mb-5">
                            <xsl:apply-templates select="headline"/>
                        </h2>
                    </div>
                </div>
                <div class="row justify-content-center">
                    <div class="col-12 col-md-8">
                        <xsl:apply-templates select="picture"/>
                        <canvas id="canvas1" width="1" height="1" style="height: auto;width: 100%;"> </canvas>
                    </div>
                </div>
                <xsl:apply-templates select="table"/>


            </div>
        </div>
    </xsl:template>



    <xsl:template match="table">
        <div class="row margin-medium table-view px-3">
            <div class="col-12 col-md-6">
            </div>
            <div class="col-12 col-md-6 bg-grey box-shadow-medium d-none d-md-block z-index-9001">
            </div>

            <xsl:apply-templates select="row"/>
            <div class="col-12 col-md-6">
            </div>
            <div class="col-12 col-md-6 bg-grey text-center">
                <a href="#" class="btn btn-primary btn-lg m-3">
                    Jetzt berechnen
                </a>
            </div>
        </div>

    </xsl:template>

 <xsl:template match="row">
     <div class="col-12 col-md-6 bg-white ">
         <strong>
             <xsl:apply-templates select="cell[1]"/>
         </strong>
     </div>
     <div class="col-12 col-md-6 bg-grey">
         <p>
             <xsl:apply-templates select="cell[2]"/>
         </p>
     </div>
 </xsl:template>

  <!-- -->
  <xsl:template match="cell">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- -->
  <xsl:template match="picture[@xlink:href]">
    <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'master')"/>
  </xsl:template>

  <xsl:template match="strapline">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="headline">
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

            <xsl:variable name="cropdata" select="$asset/asset_feature[@value_string='16-9']" />
            <xsl:variable name="height" select="$cropdata/asset_feature[@feature='censhare:image-asset-crop.source-height']/@value_long" as="xs:string?" />
            <xsl:variable name="width" select="$cropdata/asset_feature[@feature='censhare:image-asset-crop.source-width']/@value_long" as="xs:string?" />
            <xsl:variable name="startX" select="$cropdata/asset_feature[@feature='censhare:image-asset-crop.source-x']/@value_long" as="xs:string?" />
            <xsl:variable name="startY" select="$cropdata/asset_feature[@feature='censhare:image-asset-crop.source-y']/@value_long" as="xs:string?" />

            <!--
            <img    src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}"  alt="{$asset/@name}" title="{$asset/@name}" class="img-fluid" />
            -->

            <img  style="display:none"  src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}"
                  startX="{$startX}" startY="{$startY}" cWidth="{$width}" cHeight="{$height}"
                  onload="drawPicture(1,{$startX},{$startY},{$width},{$height})"
                  alt="{$asset/@name}" title="{$asset/@name}" class="img-fluid " id="picture1"/>

        </xsl:if>
    </xsl:function>


</xsl:stylesheet>
