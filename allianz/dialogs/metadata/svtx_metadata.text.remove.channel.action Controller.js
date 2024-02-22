function controller($scope,pageInstance,csConfirmDialog,csApiSession, csAssetUtil) {
  const data = $scope.$parent.$parent.data || ($scope.asset || {});
  const assetId = data.traits.ids.id;
  const outputChannel = {
    'root.web.aem.aem-vp.': {
      short:'VP',
      long:'Vertriebsportal'
    },
    'root.web.aem.aem-azde.' : {
      short:'AZ',
      long:'Allianz.de'
    },
    'root.web.bs.': {
      short:'BS',
      long:'Beratungssuite'
    }
  }
  const title = 'Textausgabe Stoppen';
  let message;
  $scope.channel;
  csApiSession.asset.get(assetId).then(function(result) {
    if (result && result.container && result.container.length > 0) {
      const asset = result.container[0].asset;
      const channelKey = csAssetUtil.getValueByPath(asset,'traits.publication.outputChannel.values.0.value');
      const channel = outputChannel[channelKey];
      if (channel) {
        $scope.channel = channel.short;
        message = 'Möchten Sie die Textausgabe in diesem Kanal wirklich stoppen? Damit wird dieser Text nicht weiter im Ausgabekanal ' + channel.long  + ' verfügbar sein';
        if (channel.short === 'BS') {
          message += '\n\nAchtung: das Content-Fragment wird im nächsten Nachtlauf aus der Beratungssuite entfernt.'
        } else {
          message += '\n\nAchtung: bitte beachten Sie, dass dieses Content-Fragment zusätzlich manuell im ' + channel.long + ' gelöscht werden muss.'
        }
      }
    }
  })
  
  $scope.openDialog = function() {
    csConfirmDialog(pageInstance.getDialogManager(),title,message).then(function(result) {
      csApiSession.transformation('svtx:xslt.move.to.archived', {contextAsset: assetId}).then(console.log);
    })
  }
  
}
