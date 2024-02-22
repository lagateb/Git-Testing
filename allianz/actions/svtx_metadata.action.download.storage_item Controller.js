function controller($scope,csDownloadUtils,csApiSession,csAssetUtil, csNotify) {
  $scope.download = function() {
    const id = csAssetUtil.getValueByPath($scope,'$parent.svtxCustomParam.id');
    const storageKey = csAssetUtil.getValueByPath($scope,'$parent.svtxCustomParam.storageKey');
    if (id && storageKey) {
      const ref = csAssetUtil.createAssetRef(parseInt(id, 10))
      const param = {
        assetRefs: [ref],
        types: [storageKey],
        dynamicFormats: [],
        usageRightsAccepted: true
      };
      csApiSession.execute('com.censhare.api.dam.assetmanagement.downloadStorageItems', param).then(result => {
        if (result.url && result.fileName) {
          csDownloadUtils.downloadFile(result.url, result.fileName, false);
        }
      }).catch(err => {
        csNotify.warning('Fehler beim Download',err)
      });
    }
  }
}
