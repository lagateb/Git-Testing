function controller($scope, csApiSession, csQueryBuilder,pageInstance,csNavigationManager,csAssetUtil,csNotify,csConfirmDialog) {



    $scope.isVariant = false;
    $scope.hasAgent = false;
    $scope.hasSales = false;
    $scope.disableSales = false;
    $scope.disableAgent=false;
    $scope.myVariants = [];
    $scope.items;
    $scope.item;


    const assetId =pageInstance.getPathContextReader().getValue().get('id');
    const rootAsset = $scope.asset;
    const relationType = 'variant.1.';

    //const id = csAssetUtil.getValueByPath(rootAsset, 'traits.ids.id.value.0.value');

    const relationFilter = rel => {
        return rel.type === relationType && rel.ref_asset.split('/')[2] == assetId && rel.direction === 'parent';
    }

    const qb = new csQueryBuilder();
    qb.condition('censhare:asset.type', 'LIKE', 'text.*');
    qb.relation('parent', 'variant.1.')
        .condition('censhare:asset.id', assetId);


    // Query for the cs-item-renderer
    const qb2 = new csQueryBuilder();

    qb2.condition('censhare:asset.type', 'LIKE', 'text.*');
    qb2.relation('parent', 'variant.1.').condition('censhare:asset.id', assetId);
    qb2.view().setTransformation('censhare:cs5.query.asset.list');


    $scope.updateAssets = function() {
        csApiSession.asset.query(qb2.build()).then(res=>{
            $scope.items = res.asset;
        })
    }

    $scope.updateAssets()

    const queryBack = {

        relation: [{ type: relationType, direction: "child",
            target : [{
                condition : [{ "name": "censhare:asset.id", "value": assetId }]
            }]
        }]

    };

    $scope.editItem = function(id) {
        let href = '/assetTextXML/'+id;
        csNavigationManager.openPage(href);
    }

    /**
     *
     csConfirmDialog(pageInstance.getDialogManager(), 'csAssetPreviewAssignWidget.delete', 'csAssetPreviewAssignWidget.deleteConfirm')
     .then(function () {});
     */

    $scope.createAgentVariant= function() {
        csConfirmDialog(pageInstance.getDialogManager(), 'Varianten erstellen', 'Maklervariante erstellen').then(() => {
            $scope.disableAgent = true
            csApiSession.transformation('svtx:clone.text.asset.with.relation', {
                contextAsset: assetId,
                variables: [
                    {key: 'relation', value: 'user.variant-agent.'},
                    {key: 'addName', value: 'Makler'}
                ]
            }).then(function (result) {
                console.log('Created Agent ', result);

                let newAsset=  result
                let href = '/assetTextXML/'+newAsset.id;
                csNotify.success('Variante anlegen', 'Variante wurde erfolgreich angelegt', null, 'Öffnen',
                    function() {
                        csNavigationManager.openPage(href);
                    }
                )
                $scope.init1()
                $scope.updateAssets()
            }).catch(function (error) {
                console.log(error);
                alert('createTransform error')
            });
        });
    }



    $scope.createSalesVariant= function() {
        csConfirmDialog(pageInstance.getDialogManager(), 'Varianten erstellen', 'Möchten Sie eine Variante für die Vertriebsansprache erstellen?').then(() => {
            $scope.disableSales = true
            csApiSession.transformation('svtx:clone.text.asset.with.relation', {
                contextAsset: assetId,
                variables: [
                    {key: 'relation', value: 'user.variant-sales.'},
                    {key: 'addName', value: 'Vertriebsansprache '}
                ]
            }).then(function (result) {
                console.log('Created Sales ', result);

                let newAsset=  result
                let href = '/assetTextXML/'+newAsset.id;
                csNotify.success('Variante anlegen', 'Variante wurde erfolgreich angelegt', null, 'Öffnen',
                    function() {
                        csNavigationManager.openPage(href);
                    }
                )
                $scope.init1()
                $scope.updateAssets()
            }).catch(function (error) {
                console.log(error);
                alert('createTransform error')
            })
        });
    }


    $scope.init1 = function() {
        $scope.myVariants=[];
        csApiSession.asset.query(qb.build()).then(res => {
            const container = res && res.container;

            if (container) {


                container.forEach(obj => {
                    let a = {};
                    const asset = obj.asset;
                    const relations = asset.relations;
                    const variantRel = relations.find(relationFilter)
                    const variantValue = csAssetUtil.getValueByPath(variantRel, 'traits.allianzTextVariantType.textVariantType.value');

                    if (variantValue === 'agent') {
                        $scope.hasAgent = true;
                        $scope.disableAgent=true;

                    }
                    if (variantValue === 'sales') {
                        $scope.hasSales = true
                        $scope.disableSales = true
                    }
                    a.name =csAssetUtil.getValueByPath(asset, 'traits.display.name');
                    a.id = csAssetUtil.getValueByPath(asset, 'traits.ids.id');
                    $scope.myVariants.push(a);
                })

            }
        })}

    $scope.init1();

    csApiSession.asset.query(queryBack,$scope).then(function onResult(data) {
        if (data && data.container) {
            console.log('hasSalesRelation true ');
            $scope.disableSales = true
            $scope.disableAgent=true
            $scope.isVariant=true
        } else {
            console.log('hasSalesRelation false ');

        }
    })


}
