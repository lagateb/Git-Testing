<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:xsl.indesign.util/storage/master/file" />

  <xsl:variable name="script">
    try {
    var censhareTargetDocumentIndex = app.scriptArgs.getValue("censhareTargetDocumentIndex");
    var censhareTargetDocument = app.scriptArgs.getValue("censhareTargetDocument");
    var groupId = app.scriptArgs.getValue("groupId");

    if (groupId != "") {
    groupId = Number(groupId);
    }

    // get document
    var targetDocument;
    if (censhareTargetDocument != "") {
    targetDocument = app.documents.itemByID(parseInt(censhareTargetDocument));
    }
    else {
    targetDocument = app.documents.item(0);
    }

    /**
    * 1. Get Page Item By Box ID param
    * 2. Find Group ID of current Frame
    * 3. Get all Frames with same group id
    * 4. Change Stroke Color
    * 5. Export PDF (only pages of items that got changed)
    */

    var CustomColor = {
    red: addColor(targetDocument, "customRed", ColorModel.PROCESS, [0, 100, 100, 0]),
    green: addColor(targetDocument, "customGreen", ColorModel.PROCESS, [34, 0, 98, 49])
    };
    var strokeWeight = 1;
    var pages = [];
    if (groupId) {
    var pi = targetDocument.allPageItems;
    for (var i = 0; i &lt; pi.length; i++) {
    var p = pi[i];
    if (p instanceof TextFrame) {
    if (p.censhareGroupSlugId === groupId &amp;&amp; (p.words.length > 0 || p.tables)) {

    var overflows = p.overflows;
    var strokeColor  = overflows ? CustomColor.red : CustomColor.green;

    p.strokeAlignment = StrokeAlignment.OUTSIDE_ALIGNMENT;
    p.strokeColor = strokeColor;
    p.strokeWeight = strokeWeight;

    //special case, when doing a stroke leads into a overflow of text
    if (overflows == false &amp;&amp; p.overflows == true) {
    while(p.overflows) {
    var bounds = p.geometricBounds;
    bounds[2] += 0.1;
    p.geometricBounds = bounds;
    }
    }

    var pageNumber = p.parentPage.name;
    if (pageNumber &amp;&amp; !hasValue(pages, pageNumber)) {
    pages.push(pageNumber);
    }
    }
    }
    }
    }

    // EXPORT PDF
    var timestamp = Date.now();
    var prefix = timestamp + "_pdf_export_";
    var fileName = prefix + ".pdf";
    var fsName = targetDocument.filePath.fsName;

    var filePath;
    if (File.fs == "Windows") {
    filePath = fsName + "\\" + fileName
    } else {
    filePath = fsName + "/" + fileName
    }

    var files = [];
    if (pages.length > 0) {
    with(app.pdfExportPreferences){
    pageRange = pages.join(",");
    optimizePDF = true;
    }
    targetDocument.exportFile(ExportFormat.PDF_TYPE, (filePath));
    var exportFolder = new Folder(fsName);
    var filter = prefix + "*";
    files = exportFolder.getFiles(filter);
    }

    var xmlResult = "&lt;?xml version=\"1.0\" encoding=\"UTF-8\"?&gt;&lt;files&gt;";
    for (var z = 0; z &lt; files.length; z++) {
    var file = files[z];
    var path = file.fsName;
    xmlResult += "&lt;file path=\"" + path + "\" folder=\"false\"/&gt;"
    }
    xmlResult += "&lt;/files&gt;";
    app.scriptArgs.setValue("censhareResultFiles", xmlResult);
    }
    catch (err) {
    app.scriptArgs.setValue("censhareResult", err.description);
    }

    function addColor(document, colorName, colorModel, colorValue) {
    if (colorValue instanceof Array == false) {
    colorValue = [(parseInt(colorValue, 16) >> 16) &amp; 0xff, (parseInt(colorValue, 16) >> 8) &amp; 0xff, parseInt(colorValue, 16) &amp; 0xff];
    colorSpace = ColorSpace.RGB;
    } else {
    if (colorValue.length == 3)
    colorSpace = ColorSpace.RGB;
    else
    colorSpace = ColorSpace.CMYK;
    }
    try {
    color = document.colors.item(colorName);
    myName = color.name;
    }
    catch (myError) {
    color = document.colors.add();
    color.properties = { name: colorName, model: colorModel, space: colorSpace, colorValue: colorValue };
    }
    return color;
    }

    function hasValue(arr, val) {
    var hasValue = false;
    for (var i = 0; i &lt; arr.length; i++) {
    if (arr[i] == val) {
    hasValue = true;
    }
    }
    return hasValue;
    }
  </xsl:variable>

  <xsl:template match="/asset[starts-with(@type, 'text.')]">


    <xsl:variable name="article" select="(./cs:parent-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'article.*'])[1]" as="element(asset)?"/>

    <xsl:variable name="masterStorage" select="./storage_item[@key='master']" as="element(storage_item)?"/>

    <xsl:variable name="contentXML" select="if ($masterStorage) then doc($masterStorage/@url) else ()" />

    <xsl:variable name="showHideRenderCommand" select="svtx:hideShowStrengthPictureRenderCommand($contentXML)"/>

    <xsl:for-each-group select="parent_asset_element_rel" group-by="@parent_asset">

      <xsl:variable name="layout" select="cs:get-asset(@parent_asset)" as="element(asset)?"/>

      <xsl:variable name="templateKey" select="$layout/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" />

      <xsl:variable name="placeCommand">
        <cs:command name="com.censhare.api.transformation.AssetTransformation">
          <cs:param name="key" select="'svtx:indesign.group.placement.cmd'"/>
          <cs:param name="source" select="$article"/>
          <cs:param name="xsl-parameters">
            <cs:param name="template-key" select="$templateKey"/>
          </cs:param>
        </cs:command>
      </xsl:variable>

      <xsl:variable name="editCommands">
        <cs:command name="com.censhare.api.transformation.AssetTransformation">
          <cs:param name="key" select="'svtx:indesign.pictures.edit.placement'"/>
          <cs:param name="source" select="$layout"/>
          <cs:param name="xsl-parameters">
            <cs:param name="placeAssetID" select="$article/@id"/>
          </cs:param>
        </cs:command>
      </xsl:variable>

      <xsl:variable name="uid" select="@id_extern" as="xs:string?"/>
      <xsl:variable name="groupId" select="$layout/asset_element[@id_extern = $uid]/xmldata/group/@group-id" as="xs:long?"/>
      <xsl:variable name="indesignStorageItem" select="$layout/storage_item[@key='master' and @mimetype='application/indesign']"/>
      <xsl:if test="$indesignStorageItem and $groupId">
        <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)"/>
        <xsl:variable name="renderResult">
          <cs:command name="com.censhare.api.Renderer.Render">
            <cs:param name="facility" select="$appVersion"/>
            <cs:param name="instructions">
              <cmd>
                <renderer>
                  <command method="open" asset_id="{$layout/@id}" document_ref_id="1"/>
                  <xsl:if test="$showHideRenderCommand/command[@method='script' and @script_asset_id]">
                    <xsl:copy-of select="$showHideRenderCommand"/>
                  </xsl:if>
                  <xsl:copy-of select="$placeCommand"/>
                  <xsl:copy-of select="$editCommands"/>
                  <command method="script" document_ref_id="1">
                    <param name="groupId" value="{$groupId}"/>
                    <script language="javascript">
                      <xsl:value-of select="$script"/>
                    </script>
                  </command>
                  <command method="close" document_ref_id="1"/>
                </renderer>
                <assets>
                  <xsl:copy-of select="$layout"/>
                  <xsl:copy-of select="$article"/>
                </assets>
              </cmd>
            </cs:param>
          </cs:command>
        </xsl:variable>
        <xsl:variable name="pdfResult" select="$renderResult/cmd/renderer/command[@method='script']/script/files/file[1]"/>
        <xsl:if test="$pdfResult">
          <output href="{svtx:getUrlOfRenderCmd($pdfResult)}"/>
        </xsl:if>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:function name="svtx:getUrlOfRenderCmd" as="xs:string">
    <xsl:param name="pdfResult"/>
    <xsl:variable name="fileSystem" select="$pdfResult/@corpus:asset-temp-filesystem"/>
    <xsl:variable name="filePath" select="$pdfResult/@corpus:asset-temp-filepath"/>
    <xsl:value-of select="concat('censhare:///service/filesystem/', $fileSystem, '/', if (starts-with($filePath, 'file:')) then substring-after($filePath, 'file:') else '')"/>
  </xsl:function>

</xsl:stylesheet>

