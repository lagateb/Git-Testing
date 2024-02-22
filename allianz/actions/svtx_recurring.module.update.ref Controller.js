function controller($scope, pageInstance,csApiSession,csQueryBuilder, csAssetUtil,allianzRecurringModulesUpdateDialog,dialogManager,csNotify) {
  $scope.products;
  $scope.disableBtn = true;
  const assetId = pageInstance.getPathContextReader().getValue().get('id');
  const assetType = csAssetUtil.getValueByPath($scope.asset, 'traits.type.type.value.0.value');
  const parentMainContentRelation = $scope.asset.relation.find(obj => obj.direction === 'parent' && obj.type === 'user.main-content.');
  const parentArticleId = csAssetUtil.getAssetIdFromAssetRef(parentMainContentRelation.ref_asset);
  const qb = new csQueryBuilder();
  qb.condition('censhare:asset.type', 'product.*');
  qb.condition('censhare:asset-flag', 'ISNULL', null);
  qb.relation('child', 'user.*')
      .condition('censhare:asset.type', 'article.*')
      .condition('svtx:recurring-module-of', parentArticleId)
      .relation('child', 'user.main-content.')
      .condition('censhare:asset.type', assetType);

  qb.view().setTransformation('censhare:cs5.query.asset.list');


  csApiSession.asset.query(qb.build()).then(result => {
    $scope.products = result.asset;
    if (Array.isArray($scope.products) && $scope.products.length > 0) {
      $scope.disableBtn = false;
    }
  })


  $scope.doUpdate = function() {
    allianzRecurringModulesUpdateDialog.open(dialogManager, { assetId: assetId }).then(function (dialogResult) {
      const options = dialogResult.options || [];
      const message = dialogResult.message || '';
      const productsToNotify = options.filter(obj => obj.checked && obj.checked===true);
      csApiSession.transformation('svtx:recurring.modules.update', {contextAsset: assetId}).then(function () {
        csNotify.success('allianzRecurringModulesAction.title', 'Textbausteine wurden aktualisiert');
        if (productsToNotify.length > 0) {
          const pIds = productsToNotify.map(obj=>obj.id);
          if (pIds.length > 0) {
            const mailParams= {
              contextAsset: assetId,
              variables: [
                {key: 'product-ids', value: pIds.join(',')},
                {key: 'message', value: message}
              ]
            }
            csApiSession.transformation('svtx:recurring.modules.notify.mail', mailParams).then(result => {
              csNotify.success('allianzRecurringModulesAction.title', 'E-mail wurde versandt');
            })
          }
        }
      });
    });
  }
}
