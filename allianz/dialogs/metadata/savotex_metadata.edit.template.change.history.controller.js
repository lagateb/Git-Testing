function controller($scope, csApiSession, csNotify, pageInstance) {
    var assetId = pageInstance.getPathContextReader().getValue().get('id');

    $scope.historyEntries = [];
    $scope.changeDescription = "";
    $scope.addingAllowed = false;
    $scope.templateLabel = "";

    if( $scope.asset.traits.resource_asset &&
        $scope.asset.traits.resource_asset.key &&
        $scope.asset.traits.resource_asset.key.value &&
        $scope.asset.traits.resource_asset.key.value[0] &&
        $scope.asset.traits.resource_asset.key.value[0].value ) {

        $scope.addingAllowed = true;
    }

    console.log( "Asset", $scope.asset );

    $scope.refreshHistory = function() {
        try {
            var params = {
                contextAsset: assetId
            };

            csApiSession.transformation("svtx:xslt.retrieve.template.history", params).then(
                function (result) {
                    if( Array.isArray(result.history.historyEntry) ) {
                        $scope.historyEntries = result.history.historyEntry;
                    } else if( result.history.historyEntry == undefined) {
                        $scope.historyEntries = [];
                    } else {
                        $scope.historyEntries = [result.history.historyEntry];
                    }

                    $scope.templateLabel = "Änderungshistorie von '" + result.templateName + "'";
                    $scope.changeDescription = "";
                }
            );

        } catch (e) {
            console.log("Cannot retrieve media template information: ", e);
        }
    };

    $scope.addNewEntry = function(newNote) {
        try {
            var params = {
                contextAsset: assetId,
                variables: [
                    {key: 'note', value: newNote}
                ]
            };

            csApiSession.transformation("svtx:xslt.add.template.history", params).then(
                function (result) {
                    $scope.refreshHistory();
                }
            );

        } catch (e) {
            console.log("Cannot update change history: ", e);
        }
    };

    $scope.refreshHistory();
}
