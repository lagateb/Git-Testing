<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:my="http://www.censhare.com/my">

  <!-- Article preview for censhare Web-->

  <!-- output -->
  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>
  <xsl:param name="size"/>

  <!-- variables -->
  <!--xsl:variable name="language" select="cs:master-data('party')[@id=system-property('censhare:party-id')]/@locale"/-->
  <xsl:variable name="urlPrefix" select="'/censhare5/client/rest/service/'"/>
  <xsl:variable name="rootAsset" select="asset[1]"/>
  <xsl:variable name="mainContentAssets" select="my:getCheckedOutInsideAsset(my:getMainContentAsset($rootAsset, $size))"/>
  <xsl:variable name="mainPictureAssets" select="if (exists($rootAsset/child_asset_rel[@key='user.main-picture.'])) then $rootAsset/cs:child-rel()[@key='user.main-picture.'] else ()"/>
  <xsl:variable name="mainPictureVariantAssets" select="if (exists($mainPictureAssets/child_asset_rel[@key, 'variant.transformation.'])) then $mainPictureAssets/cs:child-rel()[@key='variant.transformation.'] else ()"/>
  <xsl:variable name="authorAssets" select="if (exists($rootAsset/child_asset_rel[@key='user.author.'])) then $rootAsset/cs:child-rel()[@key='user.author.'] else ()"/>

  <!-- asset match -->
  <xsl:template match="/asset">
    <xsl:choose>
      <!-- asset with main contents -->
      <xsl:when test="exists($mainContentAssets)">
        <xsl:variable name="contentStorage" select="$mainContentAssets[1]/storage_item[@key='master' and @mimetype='text/xml']"/>
        <xsl:if test="exists($contentStorage)">
          <xsl:apply-templates select="doc($contentStorage/@url)"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <cs-empty-state cs-empty-state-icon="'cs-icon-image cs-color-09'">
          <span class="cs-state-headline cs-color-08">${noPreview}</span>
        </cs-empty-state>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- content match -->
  <xsl:template match="content">
    <div class="csAssetPreview__customPreview__head">
      <xsl:if test="exists($mainPictureAssets)">
        <div class="csAssetPreview__customPreview__image"><xsl:copy-of select="my:getImageElementOfAsset($mainPictureAssets[1], 'preview')"/></div>
      </xsl:if>
      <div>
        <xsl:if test="strapline">
          <xsl:apply-templates select="strapline"/>
        </xsl:if>
        <xsl:if test="title">
          <xsl:apply-templates select="title"/>
        </xsl:if>
        <xsl:if test="headline">
          <xsl:apply-templates select="headline"/>
        </xsl:if>
        <xsl:if test="subtitle">
          <xsl:apply-templates select="subtitle"/>
        </xsl:if>
        <xsl:if test="subline">
          <xsl:apply-templates select="subline"/>
        </xsl:if>
      </div>
    </div>
    <div class="csAssetPreview__customPreview__content">
      <xsl:if test="exists($mainPictureAssets)">
        <div class="csAssetPreview__customPreview__image"><xsl:copy-of select="my:getImageElementOfAsset($mainPictureAssets[1], 'preview')"/></div>
      </xsl:if>
      <xsl:apply-templates select="text"/>
      <xsl:apply-templates select="body"/>
      <!-- allianz custom content editor elements -->
      <xsl:apply-templates select="calltoaction"/>
      <xsl:apply-templates select="calltoaction-link"/>
      <!-- <xsl:apply-templates select="accompanying-1 | accompanying-2"/> -->
        <xsl:apply-templates select="seals/seal"/>
      <xsl:apply-templates select="footnote"/>
      <!-- author -->
      <xsl:if test="exists($authorAssets)">
        <div style="position: relative;">
          <xsl:variable name="authorMainPictureAsset" select="if ($authorAssets[1]/child_asset_rel[@key='user.main-picture.']) then cs:get-asset($authorAssets[1]/child_asset_rel[@key='user.main-picture.'][1]/@child_asset) else ()"/>
          <xsl:variable name="pictureStorageItem" select="$authorMainPictureAsset/storage_item[@key='thumbnail']"/>
          <xsl:variable name="authorMainContentAsset" select="my:getMainContentAsset($authorAssets[1], $size)"/>
          <xsl:variable name="contentStorageItem" select="$authorMainContentAsset/storage_item[@key='master' and @mimetype='text/xml']"/>
          <br/>
          <xsl:if test="exists($pictureStorageItem)">
            <div style="border-radius: 50%; overflow: hidden; width: 44px; height: 44px; margin-right: 10px;">
              <img style="display: block; width: 100%; height: 100%; min-width: 100%; min-height: 100%;" src="{concat($urlPrefix, 'assets/asset/id/', $pictureStorageItem/@asset_id, '/storage/thumbnail/file/', tokenize($pictureStorageItem/@relpath,'/')[last()])}"/>
            </div>
          </xsl:if>
          <div style="position: absolute; top: 0; margin-top: 22px; margin-left: 55px">
            <xsl:choose>
              <xsl:when test="exists($contentStorageItem)">
                <xsl:apply-templates select="doc($contentStorageItem/@url)/article/content/text"/>
                <xsl:apply-templates select="doc($contentStorageItem/@url)/article/content/body"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$authorAssets[1]/@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- element match -->
  <xsl:template match="print | website | app"/>

  <xsl:template match="strapline">
    <h6 class="csAssetPreview__customPreview__strapline"><xsl:apply-templates/></h6>
  </xsl:template>

  <xsl:template match="title | headline">
    <h3 class="csAssetPreview__customPreview__title"><xsl:apply-templates/></h3>
  </xsl:template>
  
  <xsl:template match="headline" mode="smaller">
    <h4><xsl:apply-templates/></h4>
  </xsl:template>

  <xsl:template match="item/headline">
    <h4><xsl:apply-templates/></h4>
  </xsl:template>

  <xsl:template match="subtitle | subline">
    <h4 class="csAssetPreview__customPreview__subtitle"><xsl:apply-templates/></h4>
  </xsl:template>

    <!-- <xsl:template match="accompanying-1 | accompanying-2"> --->
  <xsl:template match="seal">
    <xsl:apply-templates select="headline" mode="smaller"/>
    <xsl:apply-templates select="paragraph"/>
  </xsl:template>

  <xsl:template match="text | body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="intro">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <xsl:template match="subheadline-1">
    <h3><xsl:apply-templates/></h3>
  </xsl:template>

  <xsl:template match="subheadline-2">
    <h4><xsl:apply-templates/></h4>
  </xsl:template>

  <xsl:template match="subheadline-3">
    <h5 class="cs-like-h6"><xsl:apply-templates/></h5>
  </xsl:template>
  
  <xsl:template match="calltoaction-link">
    <p><xsl:apply-templates/></p>
    <xsl:if test="@url">
      <i><xsl:apply-templates select="@url"/></i>
    </xsl:if>
  </xsl:template>

  <xsl:template match="paragraph | calltoaction | footnote">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="new-page">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="group">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="hdivider">
    <hr width="100%" size="1" align="left"/>
  </xsl:template>

  <xsl:template match="image-box | video-box | audio-box | slideshow-box | image-reveal-box | turntable-box | interactive-element-box">
    <p>
      <xsl:apply-templates select="image"/>
      <xsl:apply-templates select="poster"/>
      <xsl:apply-templates select="caption"/>
    </p>
  </xsl:template>

  <xsl:template match="callout | callout-box">
    <h4 class="csAssetPreview__customPreview__subtitle">
      <xsl:for-each select="paragraph">
        <xsl:value-of select="."/><br/>
      </xsl:for-each>
    </h4>
  </xsl:template>

  <xsl:template match="pre">
    <pre><xsl:apply-templates/></pre>
  </xsl:template>

  <xsl:template match="link[@url != '']">
    <a>
      <xsl:attribute name="href" select="@url"/>
      <xsl:attribute name="target" select="concat('_', @target)"/>
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

  <xsl:template match="xi:include">
    <xsl:choose>
      <xsl:when test="cs:override">
        <i><xsl:apply-templates select="cs:override"/></i>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="doc(@href)/*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="image">
    <xsl:copy-of select="my:getImageElementOfHref(@xlink:href, 'thumbnail')"/>
  </xsl:template>

  <xsl:template match="poster">
    <xsl:copy-of select="my:getImageElementOfHref(@xlink:href, 'thumbnail')"/>
  </xsl:template>

  <xsl:template match="caption">
    <p><i><xsl:apply-templates/></i></p>
  </xsl:template>

  <!-- Lists -->
  <xsl:template match="enumeration">
    <ol><xsl:apply-templates/></ol>
  </xsl:template>

  <xsl:template match="bullet-list">
    <ul class="cs-list-01"><xsl:apply-templates/></ul>
  </xsl:template>

  <xsl:template match="item">
    <li><xsl:apply-templates/></li>
  </xsl:template>

  <!-- Tables -->
  <xsl:template match="table">
    <p>
      <table class="cs-table-01">
        <xsl:apply-templates/>
      </table>
    </p>
  </xsl:template>

  <xsl:template match="row">
    <tr><xsl:apply-templates/></tr>
  </xsl:template>

  <xsl:template match="th">
    <th><xsl:apply-templates/></th>
  </xsl:template>

  <xsl:template match="cell">
    <td>
      <xsl:if test="@rowspan">
        <xsl:attribute name="rowspan" select="@rowspan"/>
      </xsl:if>
      <xsl:if test="@colspan">
        <xsl:attribute name="colspan" select="@colspan"/>
      </xsl:if>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- Physical character styles -->
  <xsl:template match="bold">
    <b><xsl:apply-templates/></b>
  </xsl:template>

  <xsl:template match="italic">
    <i><xsl:apply-templates/></i>
  </xsl:template>

  <xsl:template match="bold-italic">
    <b><i><xsl:apply-templates/></i></b>
  </xsl:template>

  <xsl:template match="underline">
    <u><xsl:apply-templates/></u>
  </xsl:template>

  <xsl:template match="sub">
    <sub><xsl:apply-templates/></sub>
  </xsl:template>

  <xsl:template match="sup">
    <sup><xsl:apply-templates/></sup>
  </xsl:template>

  <xsl:template match="big">
    <big><xsl:apply-templates/></big>
  </xsl:template>

  <xsl:template match="marker[@semantics='small']">
    <small><xsl:apply-templates/></small>
  </xsl:template>

  <!-- Logical character styles -->
  <xsl:template match="marker[@semantics='emphasized']">
    <em><xsl:apply-templates/></em>
  </xsl:template>

  <xsl:template match="marker[@semantics='strong']">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <!-- Interview -->
  <xsl:template match="conversation">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="conversation-item">
    <xsl:apply-templates/>
    <br/>
  </xsl:template>

  <xsl:template match="question">
    <i><xsl:apply-templates/></i>
    <br/>
  </xsl:template>

  <xsl:template match="answer">
    <xsl:apply-templates/>
    <br/>
  </xsl:template>

  <xsl:template match="person">
    <b><xsl:apply-templates/></b>
  </xsl:template>

  <!-- get image element of given asset and storage key -->
  <xsl:function name="my:getImageElementOfAsset" as="element(img)?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="storageKey" as="xs:string"/>
    <xsl:variable name="assetID" select="$asset/@id"/>
    <xsl:variable name="storageItem" select="$asset/storage_item[@key=$storageKey]"/>
    <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" width="100%" alt="{$asset/@name}" title="{$asset/@name}"/>
  </xsl:function>

  <!-- get image element of given HREF and storage key -->
  <xsl:function name="my:getImageElementOfHref" as="element(img)?">
    <xsl:param name="href" as="xs:string"/>
    <xsl:param name="storageKey" as="xs:string"/>
    <xsl:variable name="assetID" select="tokenize(substring-after($href, '/asset/id/'), '/')[1]"/>
    <xsl:if test="$assetID">
      <xsl:variable name="assetVersion" select="substring-before(substring-after($href, '/version/'), '/')"/>
      <xsl:variable name="asset" select="if ($assetVersion) then cs:get-asset(xs:integer($assetID), xs:integer($assetVersion)) else cs:get-asset(xs:integer($assetID))"/>
      <xsl:variable name="storageItem" select="$asset/storage_item[@key=$storageKey]"/>
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" width="100%" alt="{$asset/@name}" title="{$asset/@name}"/>
    </xsl:if>
  </xsl:function>

  <!-- get main content asset -->
  <xsl:function name="my:getMainContentAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="size" as="xs:string?"/>
    <xsl:variable name="relatedAssets" select="if (exists($asset/child_asset_rel[@key='user.main-content.'])) then $asset/cs:child-rel()[@key='user.main-content.'] else ()"/>
    <xsl:if test="exists($relatedAssets)">
      <xsl:choose>
        <xsl:when test="exists($size) and not($size eq '')">
          <xsl:sequence select="$relatedAssets[@type = $size][1]"/>
        </xsl:when>
        <!--<xsl:otherwise>
          <xsl:sequence select="$relatedAssets[1]"/>
        </xsl:otherwise>-->
      </xsl:choose>
    </xsl:if>
  </xsl:function>

  <!-- get checked out version of given assets or current version, if not exists -->
  <xsl:function name="my:getCheckedOutInsideAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="if (exists($asset) and $asset/@checked_out_inside_id = $rootAsset/@id) then cs:get-asset($asset/@id, 0, -2) else $asset"/>
  </xsl:function>

</xsl:stylesheet>
