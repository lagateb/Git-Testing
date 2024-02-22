function controller($scope,csApiSession, pageInstance, csNotify) {
  var assetId = pageInstance.getPathContextReader().getValue().get('id');
  $scope.isRefreshing = false;
  $scope.update = function () {
    $scope.isRefreshing = true;
    csApiSession.execute('com.savotex.api.powerpoint.update', {assetId: assetId}).then(function (result) {
      console.log('Update done');
      csNotify.success('Powerpoint Folie', 'Folie wurde erfolgreich aktualisiert');
    }).catch(function (error) {
      console.log('Error', error);
      csNotify.warning('Powerpoint Folie', 'Folie konnte nicht aktualisiert werden');
    }).finally(function () {
      $scope.isRefreshing = false;
    });
  }
}
