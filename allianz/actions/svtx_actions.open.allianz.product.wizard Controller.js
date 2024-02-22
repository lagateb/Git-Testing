function controller($scope, csWizardManager, csNavigationManager, csNotify, csApiSession) {

    $scope.openWizard = function () {
        csApiSession.permission.checkAssetIndependentPermission('product_creation_wizard_execution').then(function (value) {
            if(value.permission) {
                csWizardManager.createWizard(csNavigationManager, 'allianzProductWizard');
            } else {
                csNotify.warning('Fehler', 'Sie haben nicht die benötigten Rechte, um diese Aktion auszuführen!');
            }
        });
    }
}