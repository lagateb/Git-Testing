function controller($scope, application, csApiSession, ApiService, csQueryBuilder, pageInstance, csNavigationManager, csAssetUtil, csNotify, csConfirmDialog) {
  console.log('das wird der FAQ-Artikel-Controller')

  const assetId = pageInstance.getPathContextReader().getValue().get('id');
  const contextAsset = { contextAsset: assetId };

  $scope.webAssignments = [ ]
  $scope.currentWebAssigments = []


  const webTextTrafo = 'svtx:preselected_output_channel-chooser'

  const readActualData = 'svtx:read_text_diversion'
  const saveActualData = 'svtx:save_text_diversion'

  const assignOptionsWeb = (result) => {


    $scope.webAssignments = []
    $scope.currentWebAssigments = []
    if (result && result.option) {
      //  TODO Ausldsen der Momentanen Daten!
      result.option.forEach(element => {
        $scope.webAssignments.push({
          id: element.value, display_value: element.display_value, value: false, selected: true,
          validFrom: null, validUntil: null, key: element.value
        })

        $scope.currentWebAssigments.push({
          id: element.value, display_value: element.display_value, value: false, selected: true,
          validFrom: null, validUntil: null,
          key: element.value
        })
      })
    }
    csApiSession.transformation(readActualData, contextAsset)
        .then(addActualData)
        .catch(console.log)
  }


  const addActualData = (result) => {
    if(result !== null) {
      if(!Array.isArray(result.option)) {
        result.option = [result.option];
      }
      result.option.forEach(element => {

        $scope.webAssignments.forEach(item => {
              if (item.key  == element.key) {
                item.selected = true;
                item.validFrom = element.validFrom
                item.validUntil = element.validUntil
              }
            }
        )

        $scope.currentWebAssigments.forEach(item => {
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


  function valueOrNothing(val) {
    return val != null ? val : '';
  }

  function valueTimeOrNothing(val) {
    return val != null ? makeDatetimeOk(val) : '';
  }

  function makeDatetimeOk(dt) {

    const defaultTime = 'T12:00:00.000Z'
    return (dt.split('T'))[0] + defaultTime
  }


  $scope.saveData = function () {

    let data = ''
    let separator = ''

    $scope.webAssignments.forEach(item => {
          if (item.selected) {
            data += separator + item.key +',' +valueTimeOrNothing(item.validFrom) + ',' +
                valueTimeOrNothing(item.validUntil)
            separator = '|'
          }
        }
    );

    var params = {
      contextAsset: assetId,
      variables: [

        {key: 'diversions', value: data},
      ]
    };

    csApiSession.transformation(saveActualData, params).then(function (data) {
      csNotify.success('Asset updated', '')
      initData()
      //initData()
    }).catch(function () {

      csNotify.warn('Error updating asset', '');

    }).finally(function () {
      $scope.inProgress = false;
    });

  }

  $scope.hasChanged = function() {
    let changed=false;
    $scope.webAssignments.forEach(item => {
          const old = $scope.currentWebAssigments.find(function (el) {
            return el.key == item.key
          })
          changed ||=  item.validFrom != old.validFrom || item.validUntil != old.validUntil
        }
    );


    return changed


  }

  function initData() {
    csApiSession.transformation(webTextTrafo, contextAsset)
        .then(assignOptionsWeb)
        .catch(console.log)
    //.finally(assignObservable);
  }
  console.log("Start Debug")
  initData();
}