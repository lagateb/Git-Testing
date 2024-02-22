function controller($scope,csApiSession, pageInstance, csNotify) {
    var assetId = pageInstance.getPathContextReader().getValue().get('id');
    $scope.isRefreshing = false;
    $scope.refresh = function () {
        $scope.isRefreshing = true;
        csApiSession.execute('com.savotex.api.powerpoint.merge', {assetId: assetId}).then(function (result) {
            console.log('Refresh done');
            csNotify.success('Powerpoint Ausgabe', 'Ausgabe erfolgreich aktualisiert');
            csApiSession.transformation('savotex:transformation.reset.preview', {contextAsset: assetId}).then(function (result) {
                console.log('Updated Preview', result);
            }).catch(function(error) {
                console.log(error);
            });
        }).catch(function (error) {
            console.log('Error', error);
            csNotify.warning('Powerpoint Ausgabe', 'Ausgabe konnte nicht aktualisiert werden');
        }).finally(function () {
            $scope.isRefreshing = false;
        });
    }
}