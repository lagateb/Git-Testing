function controller($scope, csWizardManager,csNavigationManager,pageInstance) {
    var assetId = pageInstance.getPathContextReader().getValue().get('id');
    $scope.openWizard = function () {
        csWizardManager.createWizard(csNavigationManager, 'svtxPowerpointSplitWizard', {assetId: assetId});
    }
}
