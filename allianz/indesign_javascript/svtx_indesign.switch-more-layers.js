// Sucht die Layer nach den übergebenen Namen und setzt deren Sichtbarkeit

/*
      <xsl:variable name="scriptId" select="cs:asset-id()[@censhare:resource-key = 'svtx:indesign.switch-more-layers']" as="xs:long?"/>
            <renderer>
                <command method="open" asset_id="{ @id }" document_ref_id="1"/>

                <command document_ref_id="1" method="script" script_asset_id="{ $scriptId }">
                  <param name="visibleLayerNames" value="Siegel-1;Siegel-1"/>
                  <param name="hiddenLayerNames" value="standard_picture;strength_picture"/>
                </command>

                <command document_ref_id="1" scale="1.0" method="preview"/>
                <command method="save" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
 */

// Parameter aus xslt

  var targetDocument = app.documents.itemByID(Number(app.scriptArgs.getValue("censhareTargetDocument")));
  var visibleLayerNames = String(app.scriptArgs.getValue("visibleLayerNames"));
  var hiddenLayerNames = String(app.scriptArgs.getValue("hiddenLayerNames"));

  switchLayer(visibleLayerNames,hiddenLayerNames);

  function switchLayer(visibleLayerNames,hiddenLayerNames) {
      var layers = visibleLayerNames.split(";");
      for (var no = layers.length - 1; no >= 0; no--) {
          var l= layers[no];
          setVisisbility(l,true);
      }

      layers = hiddenLayerNames.split(";");
      for (var no = layers.length - 1; no >= 0; no--) {
          var l= layers[no];
          setVisisbility(l,false);
      }
  }

 function setVisisbility(layerName,state) {
  for (var j = targetDocument.layers.length - 1; j >= 0; j--) {
      var layer = targetDocument.layers[j]

      if (layer.name == layerName) {
          layer.visible = state;
          return;
      }
  }
}
