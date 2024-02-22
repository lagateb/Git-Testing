function controller($scope, csWizardManager, pageInstance,csNavigationManager) {
   var assetId = pageInstance.getPathContextReader().getValue().get('id');
   var ref = 'asset/id/' + assetId +'/currversion/0';
    $scope.openWizard = function () {
        csWizardManager.createWizard(csNavigationManager, 'allianzFlexiModuleWizard', 
          {self: ref}
        );
    }
}
