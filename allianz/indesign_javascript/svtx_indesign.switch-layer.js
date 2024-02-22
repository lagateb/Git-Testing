// Sucht den Layer nach dem Namen und setzt den Status für visible

/*
    <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key = 'svtx:indesign.switch-layer']" as="xs:long?"/>
            <renderer>
                <command method="open" asset_id="{ @id }" document_ref_id="1"/>

                <command document_ref_id="1" method="script" script_asset_id="{ $scriptId }">
                  <param name="layerName" value="Siegel-1"/>
                  <param name="layerVisibel" value="true"/>
                </command>

                <command document_ref_id="1" scale="1.0" method="preview"/>
                <command method="save" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
 */

// Parameter aus xslt

  var targetDocument = app.documents.itemByID(Number(app.scriptArgs.getValue("censhareTargetDocument")));
  var layerName = String(app.scriptArgs.getValue("layerName"));
  var layerVisibel = String(app.scriptArgs.getValue("layerVisibel"));


  setVisisbility(layerName,layerVisibel=="true");

 function setVisisbility(layerName,state) {
  for (var j = targetDocument.layers.length - 1; j >= 0; j--) {
      var layer = targetDocument.layers[j]

      if (layer.name == layerName) {
          layer.visible = state;
          return;
      }
  }
}
