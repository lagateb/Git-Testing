function controller($scope,csQueryBuilder,csApiSession,dialogInstance,dialogManager,csAssetUtil) {
  $scope.measureOptions;
  $scope.currentMeasure;
  $scope.printNumberAddition;
  $scope.newPrintNumber;

  /*
  * Get Current Print Number and put it already into the trait for the old print number, will be persistent if user saves
  * */
  const currentAssetPrintNumber = csAssetUtil.getValueByPath($scope.asset, 'traits.allianzLayout.printNumber.value.0.value');
  if (currentAssetPrintNumber) {
    $scope.asset.traits.allianzLayout.printNumberOld.value[0] = {
      value:currentAssetPrintNumber
    }
  }
  /*
  * Get all releveant promotion assets as custom objects
  * */
  const contextAssetId = csAssetUtil.getAssetIdFromAssetRef($scope.asset.self);
  csApiSession.transformation('svtx:query-promotion-data', { contextAsset: contextAssetId }).then(function(result) {
    if (result && result.promotions) {
      $scope.measureOptions = result.promotions;
      const activePromotion = result.promotions.find(obj => obj.is_active === true);
      if (activePromotion) {
        $scope.currentMeasure = activePromotion.value;
        const currentLayoutPrintNumber = csAssetUtil.getValueByPath($scope.asset,'traits.allianzLayout.printNumber.value.0.value');
        if (currentLayoutPrintNumber && activePromotion.print_number) {
          $scope.printNumberAddition = currentLayoutPrintNumber.replace(activePromotion.print_number,'')
        }
      }
    }
  })

  /*
  * Override default submitaction, add/remove relations before it will be closed
  * */
  const defaultSubmitAction = dialogInstance.getActions().getChildren()[1]._callback;
  dialogInstance.getActions().getChildren()[1]._callback = submitAction;

  /*
  * Find parent promotions and remove them
  * */
  const qb = new csQueryBuilder();
  qb.condition('censhare:asset.type', 'promotion.');
  qb.relation('child', 'user.layout.')
    .condition('censhare:asset.id', contextAssetId);
  qb.view().setTransformation('censhare:cs5.query.asset.list');

  let parentPromotions = [];
  csApiSession.asset.query(qb.build()).then(result => {
    if (result.asset && Array.isArray(result.asset)) {
      parentPromotions = result.asset;  
    }
  });

  function submitAction() {
    const removePromises = parentPromotions.filter(obj => obj.traits.ids.id !== $scope.currentMeasure).map(p => csApiSession.relation.remove(p.traits.ids.id, contextAssetId, 'user.layout.', 'child'));
    if ($scope.currentMeasure) {
      const addPromise = csApiSession.relation.add(contextAssetId, +$scope.currentMeasure, 'user.layout.', 'parent');
      Promise.all([...removePromises, addPromise]).finally(()=> {
          defaultSubmitAction();    
        });
    } else {
      
      Promise.all(parentPromotions.map(p => csApiSession.relation.remove(p.traits.ids.id, contextAssetId, 'user.layout.', 'child'))).finally(()=> {
          defaultSubmitAction();    
        })
    }
  }
  
  $scope.updatePrintNumber = function (value) {
    const measure = $scope.measureOptions.find(obj => obj.value === $scope.currentMeasure);
    if (measure) {
      $scope.newPrintNumber = measure.print_number;
      if ($scope.printNumberAddition) {
        $scope.newPrintNumber+= (' '+$scope.printNumberAddition)  
      }
      $scope.asset.traits.allianzLayout.printNumber.value = [{value:$scope.newPrintNumber}]
    } else {
      $scope.newPrintNumber=null;
      $scope.asset.traits.allianzLayout.printNumber.value = [{value:''}]
    }
  }
}
