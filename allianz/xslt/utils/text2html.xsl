<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        xmlns:my="http://www.censhare.com/my"
        exclude-result-prefixes="#all"
        version="2.0">

  <xsl:variable name="urlPrefix" select="'/censhare5/client/rest/service/'"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

  <xsl:template match="/asset[starts-with(@type,'text.')]">
    <xsl:variable name="storage" select="storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
    <xsl:if test="$storage/@url">
      <xsl:apply-templates select="doc($storage/@url)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="article">
    <div id="custom_preview_content" style="padding:1.5rem">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="content">
    <div class="csAssetPreview__customPreview__head">
      <div>
        <xsl:if test="strapline">
          <xsl:apply-templates select="strapline" mode="head"/>
        </xsl:if>
        <xsl:if test="title">
          <xsl:apply-templates select="title" mode="head"/>
        </xsl:if>
        <xsl:if test="headline">
          <xsl:apply-templates select="headline" mode="head"/>
        </xsl:if>
        <xsl:if test="subtitle">
          <xsl:apply-templates select="subtitle" mode="head"/>
        </xsl:if>
        <xsl:if test="subline">
          <xsl:apply-templates select="subline" mode="head"/>
        </xsl:if>
      </div>
      <div class="csAssetPreview__customPreview__content">
        <xsl:apply-templates select="* except (headline,title,subtitle,subline,strapline)"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="strapline" mode="head">
    <h6 class="csAssetPreview__customPreview__strapline"><xsl:apply-templates/></h6>
  </xsl:template>

  <xsl:template match="title | headline" mode="head">
    <h3 class="csAssetPreview__customPreview__title"><xsl:apply-templates/></h3>
  </xsl:template>

  <xsl:template match="headline">
    <h6 class="csAssetPreview__customPreview__strapline"><xsl:apply-templates/></h6>
  </xsl:template>

  <xsl:template match="calltoaction-link">
    <xsl:apply-templates/>
    <xsl:if test="@url">
      <a href="{@url}" target="_blank"><xsl:text> </xsl:text><xsl:value-of select="@url"/></a>
    </xsl:if>
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

  <xsl:template match="seals">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="seal">
    <xsl:apply-templates/>
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


  <xsl:template match="subtitle | subline" mode="head">
    <h4 class="csAssetPreview__customPreview__subtitle"><xsl:apply-templates/></h4>
  </xsl:template>

  <xsl:template match="*"/>

  <xsl:template match="paragraph | calltoaction | speakernotes | footnote | description">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="picture | picture-q | picture-l">
    <xsl:variable name="href" select="@xlink:href" as="xs:string?"/>
    <xsl:variable name="assetID" select="tokenize(substring-after($href, '/asset/id/'), '/')[1]"/>
    <xsl:if test="$assetID">
      <xsl:variable name="pictureAsset" select="cs:get-asset(xs:long($assetID))" as="element(asset)?"/>
      <xsl:if test="$pictureAsset">
        <div class="csAssetPreview__customPreview__image">
          <xsl:copy-of select="my:getImageElementOfAsset($pictureAsset[1], 'preview', '50')"/>
        </div>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="item/picture | item/picture-q | item/picture-l">
    <xsl:variable name="href" select="@xlink:href" as="xs:string?"/>
    <xsl:variable name="assetID" select="tokenize(substring-after($href, '/asset/id/'), '/')[1]"/>
    <xsl:if test="$assetID">
      <xsl:variable name="pictureAsset" select="cs:get-asset(xs:long($assetID))" as="element(asset)?"/>
      <xsl:if test="$pictureAsset">
        <div class="csAssetPreview__customPreview__image">
          <xsl:copy-of select="my:getImageElementOfAsset($pictureAsset[1], 'preview', '20')"/>
        </div>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="logo">
    <xsl:variable name="href" select="@xlink:href" as="xs:string?"/>
    <xsl:variable name="assetID" select="tokenize(substring-after($href, '/asset/id/'), '/')[1]"/>
    <xsl:if test="$assetID">
      <xsl:variable name="pictureAsset" select="cs:get-asset(xs:long($assetID))" as="element(asset)?"/>
      <xsl:if test="$pictureAsset">
        <div class="csAssetPreview__customPreview__image">
          <xsl:copy-of select="my:getImageElementOfAsset($pictureAsset[1], 'preview', '20')"/>
        </div>
      </xsl:if>
    </xsl:if>
  </xsl:template>

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

  <xsl:template match="strapline">
    <h6 class="csAssetPreview__customPreview__strapline"><xsl:apply-templates/></h6>
  </xsl:template>

  <xsl:template match="faqs">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="pro | contra">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="faq">
    <xsl:apply-templates select="strapline"/>
    <xsl:apply-templates select="headline"/>
    <xsl:apply-templates select="question"/>
    <xsl:apply-templates select="answer"/>
    <!--<xsl:apply-templates select="footnote/font-size"/>-->
  </xsl:template>

  <xsl:template match="font-size">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xsl:template match="question">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="answer">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- get image element of given asset and storage key -->
  <xsl:function name="my:getImageElementOfAsset" as="element(img)?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="storageKey" as="xs:string"/>
    <xsl:param name="size" as="xs:string"/>
    <xsl:variable name="assetID" select="$asset/@id"/>
    <xsl:variable name="storageItem" select="$asset/storage_item[@key=$storageKey]"/>
    <xsl:if test="$storageItem">
      <img width="{$size}%" src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" alt="{$asset/@name}" title="{$asset/@name}"/>
      <!--<xsl:variable name="iptcFeature" select="$asset/asset_feature[@feature='censhare:iptc']" as="element(asset_feature)?"/>
      <xsl:variable name="iptcContent" select="$iptcFeature/asset_feature[@feature='censhare:iptc.content']" as="element(asset_feature)?"/>
      <xsl:variable name="iptcDescription" select="$iptcContent/asset_feature[@feature='censhare:iptc.description']/@value_string" as="xs:string?"/>
      <xsl:if test="$iptcDescription">
        <span><xsl:value-of select="$iptcDescription"/></span>
      </xsl:if>-->
    </xsl:if>
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
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" width="50%" alt="{$asset/@name}" title="{$asset/@name}"/>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>
