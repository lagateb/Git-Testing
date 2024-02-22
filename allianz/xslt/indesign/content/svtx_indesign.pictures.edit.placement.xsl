<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:param name="placeAssetID" select="'64136'"/>

  <xsl:variable name="layoutAsset" select="asset[1]"/>

  <xsl:template match="/asset">
    <xsl:variable name="originLayoutKey" as="xs:string?">
      <xsl:choose>
        <xsl:when test="exists($layoutAsset/asset_feature[@feature = 'svtx:layout-template-resource-key'])">
          <xsl:value-of select="$layoutAsset/asset_feature[@feature = 'svtx:layout-template-resource-key']/@value_asset_key_ref"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- fallback -->
          <xsl:value-of select="($layoutAsset/cs:feature-ref-reverse()[@key='svtx:layout-template'])[1]/asset_feature[@feature='censhare:resource-key']/@value_string"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="placeAsset" select="if ($placeAssetID castable as xs:long) then cs:get-asset(xs:long($placeAssetID)) else ()"/>
    <xsl:variable name="childAsssetElementRels" select="$layoutAsset/child_asset_element_rel[@child_collection_id=$placeAssetID]"/>
    <xsl:variable name="externalIds" select="$childAsssetElementRels/@id_extern"/>
    <xsl:variable name="placedAssetElements" select="$layoutAsset/asset_element[@id_extern=$externalIds]"/>
    <xsl:variable name="groupName" select="distinct-values($placedAssetElements/xmldata/group/@group-name)"/> <!-- useless -->
    <xsl:variable name="placedPictures" select="$layoutAsset/asset_element[@category='pict' and xmldata/group[@group-name = $groupName]]"/>

    <xsl:for-each-group select="$placedPictures" group-by="xmldata/box/@uid">
      <xsl:variable name="uid" select="xmldata/box/@uid"/>
      <xsl:variable name="configAssetResource" select="xmldata/group/@configuration-asset"/>
      <xsl:variable name="configAsset" select="if ($configAssetResource) then cs:asset()[@censhare:resource-key=$configAssetResource] else ()" as="element(asset)?"/>
      <xsl:variable name="queryAssetResource" select="$configAsset/asset_feature[@feature='censhare:layout-box.asset-query']/@value_asset_key_ref"/>
      <xsl:if test="$queryAssetResource">
        <xsl:variable name="query">
          <cs:command name="com.censhare.api.transformation.AssetTransformation">
            <cs:param name="key" select="$queryAssetResource"/>
            <cs:param name="source" select="$placeAsset"/>
            <cs:param name="xsl-parameters">
              <cs:param name="target-asset-id" select="$layoutAsset/@id"/>
            </cs:param>
          </cs:command>
        </xsl:variable>
        <xsl:variable name="pictureAsset" select="$query/assets/asset[1]" as="element(asset)?"/>
        <xsl:variable name="cropFeatures" select="$pictureAsset/asset_feature[@feature='censhare:image-asset-crop.key']"/>
        <!-- check if crop key exist for group -->
        <xsl:variable name="cropKey" select="svtx:getCropKey($groupName, $originLayoutKey, $uid)"/>
        <xsl:variable name="cropFeature" select="$cropFeatures[@value_string=$cropKey]"/>
        <!-- -->
        <xsl:choose>
          <xsl:when test="$cropFeature">
            <xsl:variable name="boxWidth" select="xmldata/box/@width"/>
            <xsl:variable name="boxHeight" select="xmldata/box/@height"/>

            <xsl:variable name="cropWidthPx" select="$cropFeature/asset_feature[@feature='censhare:image-asset-crop.source-width']/@value_long"/>
            <xsl:variable name="cropHeightPx" select="$cropFeature/asset_feature[@feature='censhare:image-asset-crop.source-height']/@value_long"/>

            <xsl:variable name="cropX" select="$cropFeature/asset_feature[@feature='censhare:image-asset-crop.source-x']/@value_long"/>
            <xsl:variable name="cropY" select="$cropFeature/asset_feature[@feature='censhare:image-asset-crop.source-y']/@value_long"/>

            <xsl:variable name="pictureMasterStorage" select="$pictureAsset/storage_item[@key='master']"/>
            <xsl:variable name="dpi" select="svtx:getEffectiveDpi($pictureMasterStorage)"/>

            <xsl:if test="$dpi">
              <xsl:variable name="boxWidthMm" select="svtx:pt2mm($boxWidth)"/>
              <xsl:variable name="boxHeightMm" select="svtx:pt2mm($boxHeight)"/>

              <xsl:variable name="pictureCropWidthMM" select="svtx:pixelToMm($cropWidthPx, $dpi)"/>
              <xsl:variable name="pictureCropHeightMm" select="svtx:pixelToMm($cropHeightPx, $dpi)"/>

              <xsl:variable name="xScale" select="$boxWidthMm div $pictureCropWidthMM"/>
              <xsl:variable name="cropXmm" select="svtx:pixelToMm($cropX, $dpi)"/>
              <xsl:variable name="cropXPt" select="svtx:mm2pt($cropXmm)"/>

              <xsl:variable name="yScale" select="$boxHeightMm div $pictureCropHeightMm"/>
              <xsl:variable name="cropYmm" select="svtx:pixelToMm($cropY, $dpi)"/>
              <xsl:variable name="cropYPt" select="svtx:mm2pt($cropYmm)"/>

              <xsl:variable name="xOffset" select="$xScale * $cropXPt * -1"/>
              <xsl:variable name="yOffset" select="$yScale * $cropYPt * -1"/>

              <xsl:if test="every $x in ($yOffset, $yOffset, $xScale, $yScale) satisfies $x castable as xs:double">
                <!-- reset edit to x,y = 0 and scale = 1 -->
                <command method="edit-placement" yscale="1" xoffset="0" yoffset="0" xscale="1" document_ref_id="1" uid="{$uid}"/>
                <!-- change edit by crop now -->
                <command method="edit-placement" xscale="{$xScale}" yscale="{$yScale}"  document_ref_id="1" uid="{$uid}"/>
                <command method="edit-placement"  xoffset="{$xOffset}" yoffset="{$yOffset}" document_ref_id="1" uid="{$uid}"/>
              </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$cropKey and $pictureAsset">
              <!-- Hier kommt es sonst zu einem Fehler, wir müssen das Bild default platzieren, weil es sonst die crop werte aus der alten platzierung benutzt -->
              <command method="edit-placement" xoffset="0" yoffset="0" xscale="1" yscale="1" document_ref_id="1" uid="{$uid}"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>


  <xsl:function name="svtx:getCropKey" as="xs:string?">
    <xsl:param name="group" as="xs:string?"/>
    <xsl:param name="key" as="xs:string?"/>
    <xsl:param name="uid" as="xs:string?"/>
    <xsl:variable name="mapping">
      <xsl:choose>
        <xsl:when test="$key eq 'svtx:indd.template.bedarf_und_beratung.flyer.allianz'">
          <entry group="Header" crop-key="1-1" uids="b358"/>
          <entry group="flyerSnippet" crop-key="16-9"/>
        </xsl:when>
        <xsl:when test="$key eq 'svtx:indd.template.flyer.allianz'">
          <entry group="Header" crop-key="1-1" uids="b433"/>
          <entry group="Header" crop-key="4-5" uids="b431"/> <!-- altes Template -->
          <entry group="Vorteile" crop-key="4-3" uids="b420"/>
          <entry group="Vorteile" crop-key="4-3" uids="b466"/> <!-- altes Template -->
          <xsl:choose>
            <xsl:when test="some $key in $layoutAsset/child_asset_element_rel[@child_collection_id=$placeAssetID]/@url satisfies contains($key,'xsl.indesign.flyer.cd21.default.s.body.text.icml')">
              <!-- neues ICML für Nutzenversprechen benutzt, also anderen Bildausschnitt wählen -->
              <entry group="Nutzenversprechen" crop-key="1-1" uids="b1254"/>
            </xsl:when>
            <xsl:otherwise>
              <entry group="Nutzenversprechen" crop-key="4-3" uids="b1254"/>
            </xsl:otherwise>
          </xsl:choose>
          <entry group="Nutzenversprechen" crop-key="1-1" uids="b1103"/> <!-- altes Template -->
          <entry group="Fallbeispiel" crop-key="1-1" uids="b1273"/>
        </xsl:when>
        <xsl:when test="$key eq 'svtx:indd.template.twopager.allianz'">
          <entry group="Header" crop-key="3-2" uids="b474"/>
          <entry group="Header" crop-key="4-3" uids="b475"/> <!-- altes Template -->
          <entry group="twoPagerSnippet" crop-key="16-9"/>
          <!--<entry group="twoPagerSnippet" crop-key="16-9"/>
          <entry group="twoPagerSnippet" crop-key="16-9"/>-->
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="if ($group = ('twoPagerSnippet','flyerSnippet')) then $mapping/entry[@group = $group][1]/@crop-key else $mapping/entry[@group = $group and @uids = $uid][1]/@crop-key"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:pt2mm" as="xs:double">
    <xsl:param name="pt" as="xs:double"/>
    <xsl:sequence select="$pt * 0.3527777778"/>
  </xsl:function>

  <!-- pixel to mm -->
  <xsl:function name="svtx:pixelToMm">
    <xsl:param name="pixel"/>
    <xsl:param name="dpi"/>
    <xsl:value-of select="($pixel * 25.4) div $dpi"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:mm2pt" as="xs:double">
    <xsl:param name="pt" as="xs:double"/>
    <xsl:sequence select="$pt div 0.3527777778"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getEffectiveDpi">
    <xsl:param name="si" as="element(storage_item)"/>
    <xsl:variable name="exif">
      <cs:command name="com.censhare.api.exiftool.read">
        <cs:param name="source" select="$si/@url"/>
      </cs:command>
    </xsl:variable>
    <xsl:variable name="JFIF_unit" select="$exif/rdf:RDF/rdf:Description/JFIF:ResolutionUnit"/>
    <xsl:variable name="JFIF_x" select="$exif/rdf:RDF/rdf:Description/JFIF:XResolution"/>
    <xsl:choose>
      <xsl:when test="$JFIF_unit eq 'inches' and $JFIF_x gt 0">
        <xsl:value-of select="$JFIF_x"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="if ($si/@dpi) then $si/@dpi else 300"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
