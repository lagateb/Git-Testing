/**
 * Controller für Ausgabe WEB Anzeige
 *  WebAusgabe

 **/

function controller($scope, application, csApiSession, ApiService, csQueryBuilder, pageInstance, csNavigationManager, csAssetUtil, csNotify, csQueryBuilder, csViewNameResolver, csAssetUtil) {
    const assetId = pageInstance.getPathContextReader().getValue().get('id');
    const webTextTrafo = 'svtx:preselected_output_channel-chooser';
    const webTextDiversion = 'svtx:save_text_diversion';
    const readActualData = 'svtx:read_text_diversion';
    const contextAsset = {contextAsset: assetId};
    const rootRelations = $scope.asset.relation && $scope.asset.relation.length > 0 ? $scope.asset.relation : [];
    const parentArticle = rootRelations.find(rel => rel.direction === 'parent' && rel.type === 'user.main-content.');
    const refAsset = parentArticle && parentArticle.hasOwnProperty('ref_asset') ? parentArticle.ref_asset : undefined;
    const refAssetId = refAsset !== undefined ? csAssetUtil.getAssetIdFromAssetRef(refAsset) : - 1;

    $scope.assetChanged = false;
    $scope.outputChannelids = [];


    $scope.dataModel = {};

    $scope.webAssignsments = [];

    //TODO testen
    $scope.currentAssigments = [];// $scope.webAssignsments.copy();

    $scope.releasedVersions = [];

    $scope.flavor = 'csAssetListItemRendererWidgetmxn_1rows';
    $scope.viewName = csViewNameResolver.getViewFromFlavor($scope.flavor);
    //$scope.hasChanged = true

    $scope.webOutputVisibility = {
        allianzde: true,
        beratungssuite: true,
        vertriebsportal: true
    }


    $scope.inProgress = false;


    function releasedVersionsLiveQuery() {
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'text.public.*');
        let or = qb.or();

        or.relation('parent', 'user.web-usage.')
            .condition('censhare:asset.type', 'article.*')
            .relation('child', 'user.main-content.')
            .condition('censhare:asset.id', assetId);

        or.relation('parent', 'user.web-usage.')
            .condition('censhare:asset.type', 'article.*')
            .relation('child', 'user.main-content.')
            .condition('censhare:asset.type', 'text.*')
            .relation('child', 'variant.1.')
            .condition('censhare:asset.id', assetId);

        qb.not().condition('censhare:asset.id', assetId);
        qb.not().condition('censhare:asset.domain', 'root.allianz-leben-ag.archive.');
        qb.setOffset(0).setLimit(15);
        qb.view().setViewName($scope.viewName);

        csApiSession.asset.liveQuery(qb.build(), $scope).then(null, null, result => {
            if (result && result.container) {
                $scope.releasedVersions = result.container.map(entry => {
                    const asset = entry.asset;
                    const validFrom = csAssetUtil.getValueByPath(asset, 'traits.allianzMedia.validFrom.value');
                    const validUntil = csAssetUtil.getValueByPath(asset, 'traits.allianzMedia.validUntil.value');
                    return {
                        id: asset.traits.ids.id,
                        name: asset.traits.display.name,
                        createdAt: asset.traits.created.date,
                        validFrom: validFrom,
                        validUntil: validUntil,
                        asset: asset
                    }
                });
                $scope.outputChannelIds = [];
                result.container.forEach(obj => {
                    const asset = obj.asset;
                    const outputChannel = csAssetUtil.getValueByPath(asset, 'traits.publication.outputChannel.values');
                    if (outputChannel && Array.isArray(outputChannel)) {
                        outputChannel.forEach(channel => {
                            $scope.outputChannelIds.push(channel.value);
                        })
                    }
                })
            }
        })
    }


    const assignOptions = (result) => {
        $scope.webAssignsments=[]
        $scope.currentAssigments = []

        //  TODO Auselsen der Momentanen Daten!
        result.option.filter(obj => obj.allow_output===true).forEach(element => {
            $scope.webAssignsments.push({
                id: element.value, display_value:element.display_value, value: false, selected: false,
                validFrom: null, validUntil: null, key: element.value
            })

            $scope.currentAssigments.push({
                id: element.value, display_value:element.display_value, value: false, selected: false,
                validFrom: null, validUntil:null, key: element.value
            })
        })

        /*csApiSession.transformation(readActualData, contextAsset)
            .then(addActualData)
            .catch(console.log)*/
    };




    const addActualData = (result) => {
        $scope.assetChanged = false;
        if(result !== null) {
            if(!Array.isArray(result.option)) {
                result.option = [result.option];
            }
            result.option.forEach(element => {

                $scope.webAssignsments.forEach(item => {
                        if (item.key  == element.key) {
                            item.selected = true;
                            item.validFrom = element.validFrom
                            item.validUntil = element.validUntil
                        }
                    }
                )

                $scope.currentAssigments.forEach(item => {
                        if (item.key  == element.key) {
                            item.selected = true;
                            item.validFrom = element.validFrom
                            item.validUntil = element.validUntil
                        }
                    }
                )
            })
        }
    }

    $scope.diversions = function(){
        let transformation = $scope.asset.traits.workflow.workflowStep.value[0].value == 35 ? 'svtx:create_public_version_and_archive':
            'svtx:set-approvals.extension.workflow'

        var params={
            contextAsset: assetId,
            variables: [
                { key: 'workflowID', value: 10},
                { key: 'workflowStepID', value: 35}
            ]
        };

        csApiSession.transformation(transformation, params).then(function (data) {
            csNotify.success('Asset public updated','')
            initData()

        }).catch(function(error) {
            csNotify.warn('Error updating public asset','')
            console.log(error);
            initData()
        })
    }

    $scope.hasSelectedAny = function () {
        return $scope.webAssignsments.filter(item => item.selected).length>0
    }

    $scope.cantUpdateWF = function() {
        return $scope.asset.traits.workflow.workflowStep.value[0].value <= 20
            ||
            $scope.webAssignsments.filter(item => item.selected).length===0;

    }

    function makeDatetimeOk(dt) {
        const defaultTime = 'T12:00:00.000Z'
        return (dt.split('T'))[0] + defaultTime
    }

    $scope.validateAssetChanged = function () {
        let changed = false
        if (!Array.isArray($scope.webAssignsments) || $scope.webAssignsments.length < 1) {
            return;
        }
        $scope.webAssignsments.forEach(item => {
                const old = $scope.currentAssigments.find(function (el) {
                    return el.key == item.key
                })
                changed ||=  item.selected != old.selected || valueOrNothing(item.validFrom )!= valueOrNothing(old.validFrom) ||
                    valueOrNothing(item.validUntil) != valueOrNothing(old.validUntil)
            }
        );

        if (changed === true) {
            $scope.assetChanged = true;
        }
    }

    $scope.hasChanged = function () {
        if ($scope.inProgress || $scope.webAssignsments.length<1) {
            return false
        }

        if(textMustSavedBefore()) {
            return false;
        }

        let changed = false

        $scope.webAssignsments.forEach(item => {
                const old = $scope.currentAssigments.find(function (el) {
                    return el.key == item.key
                })
                changed ||=  item.selected != old.selected || valueOrNothing(item.validFrom )!= valueOrNothing(old.validFrom) ||
                    valueOrNothing(item.validUntil) != valueOrNothing(old.validUntil)
            }
        );

        if (changed === true) {
            $scope.assetChanged = true;
        }
        return changed
    }



    function textMustSavedBefore() {
        const app = application.getValue();
        return typeof(app.methods.checkin) == "function"
    }

    function valueOrNothing(val) {
        return val != null ? val : '';
    }

    function valueTimeOrNothing(val) {
        return val != null ? makeDatetimeOk(val) : '';
    }


    function saveText() {
        let data = '';
        let separator = '';
        // zusammenfügern der Daten nach dem Muster  'root.web.aem.,2021.09.18,21021.10.19|....'
        // wenn einer weiss, wie ich XML an eine Transformation übergeben kann, bitte melden!
        $scope.webAssignsments.forEach(item => {
                if (item.selected) {
                    data += separator + item.key + ',' + valueTimeOrNothing(item.validFrom) + ',' + valueTimeOrNothing(item.validUntil)
                    separator = '|'
                }
            }
        );
        let selectedAssignsments = [];// getSelectedMediasIDs();
        var params = {
            contextAsset: assetId,
            variables: [
                {key: 'diversions', value: data}
            ]
        };
        return csApiSession.transformation(webTextDiversion, params);
    }

    $scope.saveTextAndNotify = function () {
        if (!textMustSavedBefore() && !$scope.inProgress) {
            $scope.inProgress = true;
            saveText().then(result => {
                csNotify.success('WEB-Ausleitung durchgeführt', '')
                $scope.inProgress = false;
                $scope.diversions();
            }).catch(err => {
                $scope.inProgress = false;
                csNotify.error('fehler', err);
            })
        }
    }



    $scope.saveTextDiversions = function () {
        let data = '';
        let separator = '';
        // zusammenfügern der Daten nach dem Muster  'root.web.aem.,2021.09.18,21021.10.19|....'
        // wenn einer weiss, wie ich XML an eine Transformation übergeben kann, bitte melden!
        $scope.webAssignsments.forEach(item => {
                if (item.selected) {
                    data += separator + item.key + ',' + valueTimeOrNothing(item.validFrom) + ',' + valueTimeOrNothing(item.validUntil)
                    separator = '|'
                }
            }
        );
        // User muss erst den geänderten Text speichern
        if (!textMustSavedBefore() && !$scope.inProgress) {
            // IDS der selektierten Medien
            let selectedAssignsments = [];// getSelectedMediasIDs();
            $scope.inProgress = true;
            var params = {
                contextAsset: assetId,
                variables: [
                    {key: 'diversions', value: data}
                ]
            };
            csApiSession.transformation(webTextDiversion, params).then(function (data) {
                csNotify.success('WEB-Ausleitung durchgeführt', '')
                $scope.inProgress = false;
                //selectedMedias.forEach(id => $scope.currentAssigments.push({value:id}))
                initData()
            }).catch(function () {
                $scope.inProgress = false;
                csNotify.warn('Error updating asset', '');
            }).finally(function () {
                $scope.inProgress = false;
                initData()
            });
        } else {
            // doUpdateAssetApproval(approval, approvalStatus, comment);
            //   resetForm();
        }
    }

    function initData() {
        csApiSession.transformation(webTextTrafo, contextAsset)
            .then(assignOptions)
            .catch(console.log)

        releasedVersionsLiveQuery();
    }

    initData();
}
