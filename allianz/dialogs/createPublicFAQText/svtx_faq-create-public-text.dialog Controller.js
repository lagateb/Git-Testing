function controller($scope, application, csApiSession, ApiService, csQueryBuilder, pageInstance, csNavigationManager, csAssetUtil, csNotify, csConfirmDialog) {

    const assetId = pageInstance.getPathContextReader().getValue().get('id')

    const contextAsset = {contextAsset: assetId};

    const createPublicFAQTextTrafo = 'svtx:create_public_faq_text_version'
    const countFAQTextApproved = 'svtx:count-faqs-text-approved';

    $scope.inProgress = false;

    const askToDo =(result) => {


        if( (result.value.val > 0)) {
            csConfirmDialog(pageInstance.getDialogManager(), 'Texte zu Nutzung freigeben', 'Sind Sie sicher?').then(() => {

                var params = {
                    contextAsset: assetId,
                };
                csApiSession.transformation(createPublicFAQTextTrafo, params).then(function (data) {
                    csNotify.success('WEB-Ausleitung durchgeführt', '')

                }).catch(function () {

                    csNotify.warn('Fehler WEB-Ausleitung ', '');

                }).finally(function () {
                    $scope.inProgress = false;
                });
            });


        } else {
            csNotify.warning('Hinweis', 'Es sind keine FAQ-Texte frei zu geben!');
        }
        $scope.inProgress = false;
    }

    const countReleaedTexts = () => {
        const qb = new csQueryBuilder()
        qb.condition('censhare:asset.type', 'text.faq.')
        let and = qb.and()

        and.relation('parent', 'user.main-content.')
            .condition('censhare:asset.id', assetId)

        qb.setOffset(0).setLimit(30)
        qb.view().setViewName($scope.viewName)


        csApiSession.asset.liveQuery(qb.build(), $scope).then(null, null, result => {
            let c = 0
            if (result && result.container) {
                $scope.releasedVersions = result.container.map(entry => {
                    const asset = entry.asset;
                    const wfStep = csAssetUtil.getValueByPath(asset, 'traits.workflow.workflowStep');
                    const validUntil = csAssetUtil.getValueByPath(asset, 'traits.allianzMedia.validUntil.value');
                    if(wfStep>=30) {
                        c++;
                    }
                });
            }
            return c;
        })
    }




    $scope.createPublicFAQText = function () {
        if (!$scope.inProgress) {
            $scope.inProgress = true;
            csApiSession.transformation(countFAQTextApproved, contextAsset)
                .then(askToDo)
                .catch(console.log('Fehler'))
        }
    }

}
