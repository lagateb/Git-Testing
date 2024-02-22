function controller($scope, csWizardManager, csNavigationManager, csNotify, csApiSession,pageInstance, csConfirmDialog) {





    $scope.createNewFAQText = function () {

        //csApiSession.permission.checkAssetIndependentPermission('creation_faq_text').then(function (value) {
        if( true || value.permission) {
            let transformationKey = "svtx:create.faq.text";

            let assetId = pageInstance.getPathContextReader().getValue().get('id');
            //let ref = 'asset/id/' + assetId +'/currversion/0';

            let params = {
                contextAsset: assetId
            };
            csConfirmDialog(pageInstance.getDialogManager(), 'FAQ-Text anlegen',  'Möchten Sie einen neuen FAQ-Text ablegen?').then(() => {
                csApiSession.transformation(transformationKey, params).then(
                    function (result) {
                        console.log(result);
                        csNotify.info('FAQ-Text', 'wurde erstellt!'); // textAsset.name
                    }
                ).catch(function (error) {
                    console.log('Error', error);
                    csNotify.warning('FAQ-Text', ' konnte nicht erstellt werden!');
                }).finally(function () {

                });
            });

        } else {
            csNotify.warning('Fehler', 'Sie haben nicht die benötigten Rechte, um diese Aktion auszuführen!');
        }
        //  });
    }
}