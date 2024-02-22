function controller($scope,csApiSession,csDownloadUtils, csAssetUtil, csNotify) {
  $scope.disabled = function () {
    const data = $scope.$parent.$parent.data;
    const assetType = csAssetUtil.getValueByPath(data, 'traits.type.type');
    return !(assetType.startsWith('layout') || assetType.startsWith('document') || assetType.startsWith('presentation'));
  }
  $scope.download = function () {
    const data = $scope.$parent.$parent.data;
    const assetType = csAssetUtil.getValueByPath(data, 'traits.type.type');
    const storageKey = assetType.startsWith('layout') ||  assetType.startsWith('document')? 'pdf-online' : 'master'
    const param = {
      assetRefs: [data.self],
      types: [storageKey],
      dynamicFormats: [],
      usageRightsAccepted: true
    };
    csApiSession.execute('com.censhare.api.dam.assetmanagement.downloadStorageItems', param).then(result => {
      if (result.url && result.fileName) {
        csDownloadUtils.downloadFile(result.url, result.fileName, false);
      } else {
        csNotify.warn('Download nicht möglich', 'Kein Storage Item für den Key: ' + storageKey + ' gefunden.');
      }
    }).catch(err => {
      csNotify.warn('Download nicht möglich', err);
    });
  }
}
