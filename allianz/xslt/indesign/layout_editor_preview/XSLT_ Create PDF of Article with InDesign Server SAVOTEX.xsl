<?xml version="1.0" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs corpus csc">

  <!-- The XSLT place a asset (given as placeAssetID and placeAssetVersion)
  into the first layout group of a layout preview template or updates the placed asset in the layout
  (given as source). The result is a generated PDF document including all pages -->

  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />
  <!-- output -->
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no" encoding="UTF-8"/>

  <!-- parameters (select values are only for testing) -->
  <xsl:param name="placeAssetID" select="'38823'"/>   <!-- mandatory -->
  <xsl:param name="placeAssetVersion" select="'-2'"/>  <!-- optional, value "-2" for checked-out version, "0" for current version or version -->
  <xsl:param name="previewMode" select="'true'"/>      <!-- if "true" then images are unlinked for PDF generation to get a bettrer performance -->

  <!-- root match -->
  <xsl:template match="/asset">
    <!-- variables -->
    <xsl:variable name="layoutAsset" select="."/>
    <xsl:variable name="isTemplateLayout" select="exists($layoutAsset/asset_feature[@feature='censhare:resource-usage' and @value_key='censhare:print-preview-template'])"/>
    <xsl:variable name="givenPlaceAsset" select="csc:getGivenPlaceAsset($placeAssetID, $placeAssetVersion)"/>
    <xsl:variable name="placeAsset" select="csc:getPlaceAsset($givenPlaceAsset)"/>
    <xsl:variable name="templateKey" select="$layoutAsset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" as="xs:string?"/>
    <!-- debug -->
    <xsl:message>==== XSLT_Create_PDF_of_Article_with_InDesign_Server: placeAssetID=<xsl:value-of select="$placeAssetID"/>, placeAssetVersion=<xsl:value-of select="$placeAssetVersion"/>, previewMode=<xsl:value-of select="$previewMode"/>, isTemplateLayout=<xsl:value-of select="$isTemplateLayout"/></xsl:message>

    <xsl:message>PLACE ASSET <xsl:value-of select="$placeAsset/@id"/></xsl:message>

    <!-- check placeAsset -->
    <xsl:if test="$placeAsset">

      <!-- use checked-out asset versions of the current user: checked-out inside asset versions + given place asset (if it's checked-out)  -->
      <xsl:variable name="checkedOutInsideAssets" select="csc:getCheckedOutInsideAssets($placeAsset)"/>
      <xsl:variable name="checkedOutAssets" select="($checkedOutInsideAssets, if ($givenPlaceAsset/@currversion='-2') then $givenPlaceAsset else ())"/>

      <!-- check asset with Adobe InDesign document -->
      <xsl:variable name="indesignStorageItem" select="$layoutAsset/storage_item[@key='master' and @mimetype='application/indesign']"/>
      <xsl:if test="$indesignStorageItem">
        <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)"/>
        <xsl:variable name="layoutGroupID" select="distinct-values($layoutAsset/asset_element[@key='actual.']/xmldata/group/@group-id)[1]"/>

        <xsl:variable name="externalID" select="$layoutAsset/child_asset_element_rel[@child_collection_id = $placeAsset/@id][1]/@id_extern" as="xs:string?"/>
        <xsl:variable name="layoutGroupElement" select="$layoutAsset/asset_element[@id_extern = $externalID][1]" as="element(asset_element)?"/>
        <xsl:variable name="layoutGroupName" select="$layoutGroupElement/xmldata/group/@group-name" as="xs:string?"/>

        <xsl:variable name="siblingAsset"  select="svtx:placeOtherAsset($layoutAsset,$layoutGroupName)"  as="element(asset)?" />
        <xsl:variable name="siblingAssetGroupName"  select="svtx:getGroupNameToPlace($layoutAsset,$layoutGroupName)" as="xs:string?" />



        <xsl:variable name="layoutGroupTransformSource" select="if ($placeAsset/@currversion='-2' or $givenPlaceAsset/@currversion='-2') then csc:getLayoutGroupTransformSource($layoutAsset, $layoutGroupID) else ()"/>
        <xsl:variable name="boxPlacements" select="if ($layoutGroupTransformSource) then csc:getBoxPlacements($placeAsset, $layoutAsset, $layoutGroupTransformSource) else ()"/>
        <xsl:variable name="pdfPresetNamePreview" select="csc:getPdfPresetNamePreview()"/>

        <xsl:variable name="edit-command">
          <cs:command name="com.censhare.api.transformation.AssetTransformation">
            <cs:param name="key" select="'svtx:indesign.pictures.edit.placement'"/>
            <cs:param name="source" select="$layoutAsset"/>
            <cs:param name="xsl-parameters">
              <cs:param name="placeAssetID" select="$placeAsset/@id"/>
            </cs:param>
          </cs:command>
        </xsl:variable>

        <!--
         <xsl:variable name="strengthAsset"  select="svtx:getStaerkenAsset($layoutAsset)" />
        <xsl:variable name="strengthAsset" select="svtx:getMainContentMasterStorageXML('s',$givenPlaceAsset)"/>
             <xsl:variable name="strengthAsset" select="svtx:getMainContentMasterStorageXML('s',$givenPlaceAsset))"/>

               <xsl:variable name="contentXml" select=" svtx:getContentXml($masterAsset)"/>
        -->

        <xsl:variable name="strengthAsset" select="svtx:getContentXml($givenPlaceAsset)"/>
        <!--
                  <xsl:message>====GPA <xsl:copy-of select="$givenPlaceAsset"/> </xsl:message>
                  <xsl:message>====strn <xsl:copy-of select="$strengthAsset"/> </xsl:message>
        -->
        <xsl:variable name="showHideRendercommand" select="svtx:hideShowStrengthPictureRenderCommand($strengthAsset)"/>
        <!-- create PDF -->
        <xsl:variable name="renderResult">
          <cs:command name="com.censhare.api.Renderer.Render">
            <cs:param name="facility" select="$appVersion"/>
            <cs:param name="instructions">
              <cmd>
                <renderer>
                  <command method="open" asset_id="{$layoutAsset/@id}" document_ref_id="1"/>
                  <xsl:if test="$layoutGroupName='Stärken'">
                    <xsl:message>==== Wir sind in Stärken</xsl:message>
                    <xsl:copy-of select="$showHideRendercommand"/>
                  </xsl:if>
                  <xsl:choose>
                    <xsl:when test="$isTemplateLayout">
                      <!-- Place article into layout group of template layout -->
                      <xsl:choose>
                        <!-- Place checked-out version -->
                        <xsl:when test="$placeAsset/@currversion='-2' or $givenPlaceAsset/@currversion='-2'">
                          <xsl:for-each select="$boxPlacements/boxes/box">
                            <xsl:if test="exists(placement)">
                              <xsl:variable name="assetID" select="placement[1]/@asset-id"/>
                              <xsl:choose>
                                <!-- Storage placement e.g. <storage asset-element-idx="0" key="master" mimetype="image/png"/> -->
                                <xsl:when test="exists(placement[1]/storage)">
                                  <command method="place" update-content-elements="true" uid="{@uid}" place_asset_id="{$assetID}" place_asset_element_id="{placement[1]/storage[1]/@asset-element-idx}" place_storage_key="{placement[1]/storage[1]/@key}" group_transformation_url="censhare:///service/assets/asset/id/{$placeAsset/@id}/transform;key=layout-group;target-asset-id={$layoutAsset/@id}" is_manual_placement="false" document_ref_id="1"/>
                                </xsl:when>
                                <!-- Transformation placement e.g. <transformation format="icml" key="transform:author-to-icml"/> -->
                                <xsl:when test="exists(placement[1]/transformation)">
                                  <command method="place" update-content-elements="true" uid="{@uid}" place_asset_id="{$assetID}" group_transformation_url="censhare:///service/assets/asset/id/{$placeAsset/@id}/transform;key=layout-group;target-asset-id={$layoutAsset/@id}" is_manual_placement="false" document_ref_id="1">
                                    <transformation url="censhare:///service/assets/asset/id/{$assetID}{if ($checkedOutAssets/@id=$assetID) then concat('/version/', $checkedOutAssets[@id=$assetID]/@version) else ''}/transform;key={placement[1]/transformation/@key};format=icml;mimetype=application%2Fvnd.adobe.incopy-icml;target-asset-id={$layoutAsset/@id};time={current-dateTime()}"/>
                                  </command>
                                </xsl:when>
                              </xsl:choose>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:when>
                        <!-- Place current version -->
                        <xsl:otherwise>
                          <command method="place-collection" group_id="{$layoutGroupID}" place_asset_id="{$placeAsset/@id}" picture_placement_rule="fit-proportional" document_ref_id="1"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="$placeAsset and $layoutGroupName">
                          <command document_ref_id="1" method="place-collection" group_name="{$layoutGroupName}" place_asset_id="{$placeAsset/@id}" picture_placement_rule="fit-proportional"/>
                          <xsl:if test="$siblingAsset">
                            <xsl:message>=== Geschwisterasset für Fussnote setzen!<xsl:value-of select="$siblingAssetGroupName"/># </xsl:message>
                            <command document_ref_id="1" method="place-collection" group_name="{$siblingAssetGroupName}" place_asset_id="{$siblingAsset/@id}" picture_placement_rule="fit-proportional"/>
                          </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:variable name="assetElementRels" select="$layoutAsset/child_asset_element_rel[(@child_collection_id, @child_asset)=$placeAssetID]"/>
                          <xsl:for-each select="$assetElementRels">
                            <xsl:variable name="checkedOutAsset" select="$checkedOutAssets[@id=current()/@child_asset]"/>
                            <xsl:variable name="assetElement" select="$layoutAsset/asset_element[@key='actual.' and @idx=current()/@parent_idx]"/>
                            <!-- only place assets of checkedout inside assets -->
                            <xsl:if test="$checkedOutAsset and not($assetElement/@child_storage_key) or current()/@child_asset=$placeAssetID">
                              <command method="place" ignore_content_update="true" update-content-elements="true" document_ref_id="1"  is_manual_placement="false" place_asset_id="{@child_asset}" uid="{$assetElement/@id_extern}">
                                <xsl:copy-of select="@group_transformation_url"/>
                                <xsl:if test="$assetElement/@child_storage_key">
                                  <xsl:attribute name="place_storage_key" select="@child_storage_key"/>
                                  <xsl:attribute name="place_asset_element_id" select="@child_idx"/>
                                </xsl:if>
                                <xsl:if test="@url">
                                  <!-- add asset version in url -->
                                  <transformation url="{concat(substring-before(@url, '/transform;'), '/version/', $checkedOutAsset/@version, '/transform;', substring-after(@url, '/transform;'))}"/>
                                </xsl:if>
                              </command>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>


                  <xsl:for-each select="$edit-command/command">
                    <xsl:variable name="uid" select="@uid"/>
                    <xsl:if test="exists($layoutAsset/child_asset_element_rel[@key='actual.' and starts-with(@child_storage_mimetype, 'image')])">
                      <xsl:copy-of select="."/>
                    </xsl:if>
                  </xsl:for-each>


                  <xsl:if test="$placeAsset/@type='article.flexi-module.' and $templateKey='svtx:indd.template.bedarf_und_beratung.flyer.allianz'">
                    <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key='svtx:indesign.create-qr-code']" as="xs:long?"/>
                    <xsl:variable name="flexiModuleMainContent" select="$placeAsset/cs:child-rel()[@key='user.main-content.']" as="element(asset)?"/>
                    <xsl:variable name="siMainContent" select="$flexiModuleMainContent/storage_item[@key='master']" as="element(storage_item)?"/>
                    <xsl:variable name="content" select="if ($siMainContent/@url) then doc($siMainContent/@url) else ()"/>
                    <xsl:variable name="url" select="$content/article/content/calltoaction-link/@url" as="xs:string?"/>
                    <xsl:if test="$scriptId and $url">
                      <command document_ref_id="1" method="script" script_asset_id="{$scriptId}">
                        <param name="url" value="{$url}"/>
                      </command>
                    </xsl:if>
                  </xsl:if>

                  <xsl:if test="$placeAsset/@type='article.solution-overview.' and $templateKey = 'svtx:indd.template.bedarf_und_beratung.flyer.allianz'">
                    <xsl:copy-of select="svtx:qrCodeSolutionOverviewCmd($placeAsset)"/>
                  </xsl:if>

                  <command method="pdf" spread="true" document_ref_id="1">
                    <xsl:if test="$pdfPresetNamePreview">
                      <xsl:attribute name="pdf_stylename" select="$pdfPresetNamePreview"/>
                    </xsl:if>
                    <!--xsl:attribute name="unlink-image-links" select="'false'"/-->
                    <!-- Exclude image files in preview mode -->
                    <!--xsl:if test="$previewMode">
                      <xsl:attribute name="unlink-image-links" select="$previewMode"/>
                    </xsl:if-->
                  </command>
                  <command method="close" document_ref_id="1"/>
                </renderer>
                <assets>
                  <!-- Add assets -->
                  <xsl:copy-of select="$layoutAsset"/>
                  <!-- pictures of content xml, else it cant be placed -->
                  <xsl:copy-of select="csc:getPictureAssetsOfContentXml($givenPlaceAsset)"/>
                  <xsl:copy-of select="$siblingAsset"/>
                  <xsl:choose>
                    <xsl:when test="$isTemplateLayout">
                      <xsl:copy-of select="$placeAsset"/>
                      <xsl:if test="$givenPlaceAsset/@id!=$placeAsset/@id">
                        <xsl:copy-of select="$givenPlaceAsset"/>
                      </xsl:if>
                      <xsl:if test="$placeAsset/@currversion='-2' or $givenPlaceAsset/@currversion='-2'">
                        <xsl:for-each select="$boxPlacements/boxes/box/placement[1]/@asset-id">
                          <xsl:variable name="assetID" select="."/>
                          <xsl:copy-of select="if ($checkedOutAssets/@id=$assetID) then $checkedOutAssets[@id=$assetID] else cs:get-asset($assetID)"/>
                        </xsl:for-each>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:copy-of select="$checkedOutAssets"/>
                      <!--  always add the specified asset to place for the content editor preview -->
                      <xsl:if test="$givenPlaceAsset and count($checkedOutAssets/asset[@id = $givenPlaceAsset/@id]) = 0">
                        <xsl:copy-of select="$givenPlaceAsset"/>
                      </xsl:if>
                      <xsl:if test="$placeAsset">
                        <xsl:copy-of select="$placeAsset"/>
                      </xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </assets>
              </cmd>
            </cs:param>
          </cs:command>
        </xsl:variable>

        <!-- Debug output result of renderer -->
        <!--debug>
          <xsl:copy-of select="$renderResult"/>
        </debug-->
        <!-- Return the result (file locator) -->
        <xsl:variable name="pdfCmd" select="$renderResult/cmd/renderer/command[@method='pdf']"/>
        <cs:output href="csc:getUrlOfRenderCmd($pdfCmd)" media-type="'application/pdf'"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- get given place asset of given assetId and assetVersion -->
  <xsl:function name="csc:getGivenPlaceAsset" as="element(asset)?">
    <xsl:param name="assetId" as="xs:string"/>
    <xsl:param name="assetVersion" as="xs:string"/>
    <xsl:variable name="assetIdNumber" select="xs:long($assetId)"/>
    <xsl:if test="$assetId">
      <xsl:choose>
        <xsl:when test="$assetVersion and $assetVersion='-2'">
          <xsl:variable name="checkedOutAsset" select="cs:get-asset($assetIdNumber, 0, -2)"/>
          <xsl:sequence select="if (checkedOutAsset) then $checkedOutAsset else cs:get-asset($assetIdNumber)"/>
        </xsl:when>
        <xsl:when test="$assetVersion and $assetVersion='0'">
          <xsl:sequence select="cs:get-asset($assetIdNumber)"/>
        </xsl:when>
        <xsl:when test="$assetVersion">
          <xsl:sequence select="cs:get-asset($assetIdNumber, xs:long($assetVersion))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="cs:get-asset($assetIdNumber)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:function>

  <!-- get place asset of given assetId and assetVersion (if given asset has a parent main content relation then use parent asset instead of given asset) -->
  <xsl:function name="csc:getPlaceAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:variable name="parentAsset" select="if ($asset/parent_asset_rel[@key='user.main-content.']) then cs:get-asset($asset/parent_asset_rel[@key='user.main-content.'][1]/@parent_asset) else ()"/>
    <xsl:sequence select="if ($parentAsset) then $parentAsset else $asset"/>
  </xsl:function>

  <!-- get checked out inside assets (checked out versions) of given asset -->
  <xsl:function name="csc:getBoxPlacements">
    <xsl:param name="placeAsset" as="element(asset)"/>
    <xsl:param name="layoutAsset" as="element(asset)"/>
    <xsl:param name="layoutGroupTransformSource" as="element(boxes)"/>
    <cs:command name="com.censhare.api.transformation.XslTransformation">
      <cs:param name="stylesheet" select="'censhare:///service/assets/asset;censhare:resource-key=layout-group/storage/master/file'"/>
      <cs:param name="source" select="$placeAsset"/>
      <cs:param name="xsl-parameters">
        <cs:param name="data" select="$layoutGroupTransformSource"/>
        <cs:param name="transform">
          <transform target-asset-id="{$layoutAsset/@id}"/>
        </cs:param>
      </cs:param>
    </cs:command>
  </xsl:function>

  <!-- get layout group transform source or given asset of given groupID -->
  <!-- example result -->
  <!-- <boxes xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"> -->
  <!--   <box can-place-metadata="false" content="image" height-mm="10.0" page-x-mm="107.5" page-y-mm="274.2999877929688" uid="b252" width-mm="10.0"> -->
  <!--     <metadata content-lock="false" geometry-lock="true" group-id="1" group-name="Article" index="1" placement-method="transformation" search-transformation-key="censhare:search-author-main-picture"/> -->
  <!--   </box> -->
  <!--   <box can-place-metadata="false" content="text" height-mm="10.0" mimetypes="application/vnd.adobe.incopy-icml" page-x-mm="107.5" page-y-mm="274.2999877929688" uid="b272" width-mm="89.80000305175781"> -->
  <!--     <metadata content-lock="false" geometry-lock="true" group-id="1" group-name="Article" index="1" placement-method="transformation" search-transformation-key="censhare:search-author" transformation-key="transform:author-to-icml"/> -->
  <!--   </box> -->
  <!-- </boxes> -->
  <xsl:function name="csc:getLayoutGroupTransformSource" as="element(boxes)">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:param name="groupID" as="xs:integer"/>
    <xsl:variable name="layoutGroupElements" select="$asset/asset_element[@key='actual.' and xmldata/group/@group-id=$groupID]"/>
    <boxes>
      <xsl:for-each select="$layoutGroupElements">
        <xsl:variable name="content" select="if (@category='text') then 'text' else 'image'"/>
        <box can-place-metadata="{@can_place_attributes=1}" content="{$content}" height-mm="{@height_mm}" page-x-mm="{@xoffsmm}" page-y-mm="{@yoffsmm}" uid="{@id_extern}" width-mm="{@width_mm}">
          <xsl:if test="$content='text'">
            <xsl:attribute name="mimetypes" select="'application/vnd.adobe.incopy-icml'"/>
          </xsl:if>
          <metadata>
            <xsl:copy-of select="xmldata/group/@*"/>
          </metadata>
        </box>
      </xsl:for-each>
    </boxes>
  </xsl:function>

  <!-- get checked out inside assets (checked out versions) of given asset -->
  <xsl:function name="csc:getCheckedOutInsideAssets" as="element(asset)*">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:variable name="assetIDs" select="cs:asset()[@censhare:asset.checked_out_inside_id=$asset/@id]/@id"/>
    <xsl:for-each select="$assetIDs">
      <xsl:sequence select="cs:get-asset(., 0, -2)"/>
    </xsl:for-each>
  </xsl:function>

  <!-- get URL of given render command element -->
  <xsl:function name="csc:getUrlOfRenderCmd" as="xs:string">
    <xsl:param name="renderCmd" as="element(command)"/>
    <xsl:variable name="fileSystem" select="$renderCmd/@corpus:asset-temp-filesystem"/>
    <xsl:variable name="filePath" select="$renderCmd/@corpus:asset-temp-filepath"/>
    <xsl:value-of select="concat('censhare:///service/filesystem/', $fileSystem, '/', if (starts-with($filePath, 'file:')) then substring-after($filePath, 'file:') else '')"/>
  </xsl:function>

  <!-- find picture ids in content xml and return assets -->
  <xsl:function name="csc:getPictureAssetsOfContentXml">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="si" select="$asset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
    <xsl:variable name="xmlContent" select="if ($si) then doc($si/@url) else ()"/>
    <xsl:variable name="assetRefElements" select="$xmlContent//*[@xlink:href]" as="element()*"/>
    <xsl:variable name="assetIds" select="for $ref in $assetRefElements return substring-after($ref/@xlink:href, 'censhare:///service/assets/asset/id/')" as="xs:string*"/>
    <xsl:copy-of select="for $id in $assetIds return if ($id castable as xs:long) then cs:get-asset(xs:long($id)) else ()"/>
  </xsl:function>

  <!-- Kontrolliert ob die Transformation  für ein Flyer Asset aufgerufen wird
     group-configuration-asset wnthält flyer
     Alternative page > p1
        <xsl:value-of select="if ($asset/asset_element[xmldata/group[contains(@configuration-asset,'flyer')]]) then true() else false()"/>
  -->
  <xsl:function name="svtx:isFlyer">
    <xsl:param name="asset"/>
    <xsl:value-of select="exists($asset/asset_element/xmldata/box[@page='p2'])"/>
  </xsl:function>

  <xsl:function name="svtx:getGroupNameToPlace">
    <xsl:param name="layoutAsset"/>
    <xsl:param name="layoutGroupName"/>
    <xsl:choose>
      <xsl:when test="svtx:isFlyer($layoutAsset) = true()">Produktbeschreibung</xsl:when>
      <xsl:when test="svtx:isFlyer($layoutAsset) = false()">
        <xsl:choose>
          <xsl:when test="$layoutGroupName eq 'Header' or $layoutGroupName eq 'Funktionsgrafik'  or $layoutGroupName eq 'Vorteile' ">Produktbeschreibung</xsl:when>
          <xsl:when test="$layoutGroupName eq 'Zielgruppenmodul' or $layoutGroupName eq 'Stärken' ">Produktdetails</xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="svtx:placeOtherAsset">
    <xsl:param name="layoutAsset"/>
    <xsl:param name="layoutGroupName"/>
    <xsl:choose>
      <xsl:when test="svtx:isFlyer($layoutAsset) = true()">
        <xsl:message>==== OK, ist ein Flyer</xsl:message>
        <xsl:if test="$layoutGroupName eq 'Fallbeispiel'">
          <xsl:variable name="idExtern" select="$layoutAsset/asset_element[xmldata/group[@group-name='Produktbeschreibung']][1]/@id_extern" as="xs:string?"/>
          <xsl:variable name="id"
                        select="$layoutAsset/child_asset_element_rel[@id_extern eq $idExtern]/@child_collection_id"
                        as="xs:long?"/>
          <xsl:message>==== Wir nutzen <xsl:value-of select ="$id"/>  </xsl:message>
          <xsl:copy-of select="cs:get-asset($id)"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="svtx:isFlyer($layoutAsset) = false()">
        <xsl:message>==== OK, ist ein TwoPager</xsl:message>
        <xsl:choose>
          <xsl:when
                  test="$layoutGroupName eq 'Header' or $layoutGroupName eq 'Funktionsgrafik'  or $layoutGroupName eq 'Vorteile' ">
            <xsl:message>==== OK, Seite 1 TwoPager</xsl:message>
            <xsl:variable name="idExtern" select="$layoutAsset/asset_element[xmldata/group[@group-name='Produktbeschreibung']][1]/@id_extern" as="xs:string?"/>
            <xsl:message>==== idExtern <xsl:value-of select ="$idExtern"/>  </xsl:message>
            <xsl:variable name="id" select="$layoutAsset/child_asset_element_rel[@id_extern eq $idExtern]/@child_collection_id" as="xs:long?"/>
            <xsl:message>==== Wir nutzen <xsl:value-of select ="$id"/>  </xsl:message>
            <xsl:copy-of select="cs:get-asset($id)"/>
          </xsl:when>
          <xsl:when test="$layoutGroupName eq 'Zielgruppenmodul' or $layoutGroupName eq 'Produktdetails'  ">
            <xsl:message>==== OK, Seite 2 TwoPager</xsl:message>
            <xsl:variable name="idExtern" select="$layoutAsset/asset_element[xmldata/group[@group-name='Stärken']][1]/@id_extern" as="xs:string?"/>
            <xsl:message>==== idExtern <xsl:value-of select ="$idExtern"/>  </xsl:message>
            <xsl:variable name="id" select="$layoutAsset/child_asset_element_rel[@id_extern eq $idExtern]/@child_collection_id" as="xs:long?"/>
            <xsl:message>==== Wir nutzen <xsl:value-of select ="$id"/>  </xsl:message>
            <xsl:copy-of select="cs:get-asset($id)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>==== OK, <xsl:value-of select ="$layoutGroupName"/> braucht nicht</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getPictureBoxes">
    <xsl:param name="layout" as="element(asset)?"/>
    <xsl:param name="placeAsset" as="element(asset)?"/>
    <xsl:variable name="externalIds" select="$layout/child_asset_element_rel[@child_collection_id = $placeAsset/@id and child_storage_mimetype='image/png']/@id_extern"/>
    <xsl:copy-of select="$layout/asset_element[@id_extern = $externalIds and @category='pict']"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:pt2pixel" as="xs:double?">
    <xsl:param name="point"/>
    <xsl:value-of select="$point * 1.3333333333333"/>
  </xsl:function>

  <!-- pixel to mm -->
  <xsl:function name="svtx:pixelToMm">
    <xsl:param name="pixel"/>
    <xsl:param name="dpi"/>
    <xsl:value-of select="($pixel * 25.4) div $dpi"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:pt2mm" as="xs:double">
    <xsl:param name="pt" as="xs:double"/>
    <xsl:sequence select="$pt * 0.3527777778"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:mm2pt" as="xs:double">
    <xsl:param name="pt" as="xs:double"/>
    <xsl:sequence select="$pt div 0.3527777778"/>
  </xsl:function>

  <xsl:function name="svtx:getCropKey" as="xs:string?">
    <xsl:param name="group" as="xs:string?"/>
    <xsl:param name="template" as="xs:string?"/>
    <xsl:variable name="mapping">
      <xsl:choose>
        <xsl:when test="$template eq 'svtx:indd.template.flyer.allianz'">
          <entry group="Header" crop-key="4-5"/>
          <entry group="Vorteile" crop-key="1-1"/>
          <entry group="Nutzenversprechen" crop-key="1-1"/>
          <entry group="Fallbeispiel" crop-key="1-1"/>
        </xsl:when>
        <xsl:when test="$template eq 'svtx:indd.template.twopager.allianz'">
          <entry group="Header" crop-key="4-3"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$mapping/entry[@group = $group][1]/@crop-key"/>
  </xsl:function>


  <xsl:function name="svtx:getStaerkenAsset">
    <xsl:param name="layoutAsset"/>
    <xsl:variable name="idExtern" select="$layoutAsset/asset_element[xmldata/group[@group-name='Stärken']][1]/@id_extern" as="xs:string?"/>
    <xsl:message>==== getStaerkenAssetXml idExtern <xsl:value-of select ="$idExtern"/>  </xsl:message>
    <xsl:variable name="id" select="$layoutAsset/child_asset_element_rel[@id_extern eq $idExtern]/@child_collection_id" as="xs:long?"/>
    <xsl:message>==== Hiervon brauchen wir den  das ChildAsset Text? masterFile  <xsl:value-of select ="$id"/>  </xsl:message>
    <!--
    <xsl:variable name="mainContent" select="svtx:getMainContentMasterStorageXML('s',cs:get-asset($id))"/>
    -->
    <xsl:variable name="mainContent" select="svtx:getMainContentMasterStorageXML('s',cs:get-asset($id))"/>

    <xsl:message>====2copy-ofs <xsl:copy-of select="$mainContent"/> </xsl:message>

    <xsl:copy-of select="$mainContent"/>
  </xsl:function>

  <xsl:function name="svtx:getMainContent">
    <xsl:param name="layout" as="element(asset)?"/>
    <xsl:param name="article" as="element(asset)?"/>
    <xsl:if test="$layout and $article">
      <xsl:variable name="searchResult">
        <cs:command name="com.censhare.api.transformation.AssetTransformation">
          <cs:param name="key" select="'svtx:indesign.dynamic.search.main-content'"/>
          <cs:param name="source" select="$article"/>
          <cs:param name="xsl-parameters">
            <cs:param name="target-asset-id" select="$layout/@id"/>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:variable name="mainContentAsset" select="$searchResult/assets/asset[1]" as="element(asset)?"/>
      <xsl:variable name="masterStorage" select="$mainContentAsset/storage_item[@key='master']" as="element(storage_item)?"/>
      <xsl:copy-of select="if ($masterStorage) then doc($masterStorage/@url) else ()" />
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>

