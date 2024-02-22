function controller($scope, csApiSession, csAssetUtil, csNotify, csColorUtil) {
    const id = csAssetUtil.getValueByPath($scope, '$parent.svtxCustomParam.id');
    const contextAssetId = id? id: $scope.asset.traits.ids.id.value[0].value;

    $scope.allianzColors = [
        ['#96DCFA', '#007D8C','#7FE4E0','#FDD25C','#FF934F','#B71E3F','#5A5360','#8A679C', '#C1EBFB',
        '#49648B', '#CAD4DE', '#017D8C', '#417D71', '#C3E8E7', '#CCDD61','#E3EBAE', '#C3D8D4']
    ]

    $scope.dataModel;
    $scope.assetModelString;
    $scope.isEqual = false;

    setDataModel();

    function setDataModel() {
        const param = {
            contextAsset: contextAssetId
        }
        csApiSession.transformation('svtx:guarantee-asset.datamodel', param).then(function (result) {
            if (result && result.dataModel) {
                $scope.dataModel = result.dataModel;
                $scope.isEqual = result.isEqual;
                $scope.assetModelString = JSON.stringify(result.assetModel.dataModel);
            }
        }).catch(error => {
            console.log('Error on DataModel', error);
        });
    }

    $scope.$watch('dataModel', (newVal) => {
        $scope.isEqual = JSON.stringify(newVal) === $scope.assetModelString;
    }, true);

    function prepareXsltParams(){
        const dataModel = $scope.dataModel;
        const name = dataModel.name;
        const date = dataModel.date;
        const totalVolume = dataModel.totalVolume;
        const headline = dataModel.headline;
        const copy = dataModel.copy;
        const investmentsString = [];
        const regionString = [];
        const developmentsString = [];

        $scope.dataModel.investments.forEach(data => {
            investmentsString.push(
                [data.name, data.share, data.description, data.color].join('|'));
        });

        $scope.dataModel.regions.forEach(data => {
            regionString.push(
                [data.name, data.share, data.description, data.color].join('|'));
        });

        $scope.dataModel.developments.forEach(data => {
            developmentsString.push(
                [data.date, data.share].join('|'));
        })
        return {
            contextAsset: contextAssetId,
            variables: [
                {key: 'name', value: name},
                {key: 'date', value: date ? new Date(date) : ''},
                {key: 'total-volume', value: totalVolume},
                {key: 'headline', value: headline},
                {key: 'copy', value: copy},
                {key:'investments', value: investmentsString.join(';')},
                {key:'regions', value: regionString.join(';')},
                {key:'developments', value: developmentsString.join(';')},
            ]
        }
    }
    function updateAssetData(makePersistent = false) {
        const params = prepareXsltParams();
        if (params && params.variables && Array.isArray(params.variables)) {
            params.variables.push({key:'update-asset', value: makePersistent})
        }
        csApiSession.transformation('svtx:guarantee-asset.update', params).then(function () {
            csNotify.success($scope.dataModel.name, 'Updated');
            setDataModel();
        }).catch(console.log);
    }

    $scope.publish = function() {
        updateAssetData(true);
    }

    $scope.update = function() {
        updateAssetData(false);
    }

    $scope.addInvestment = function () {
        $scope.dataModel.investments.push({
            name: null,
            share: null,
            description: null,
            color: '#'
        });
    }

    $scope.addRegion = function () {
        $scope.dataModel.regions.push({
            name: null,
            share: null,
            description: null,
            color: '#'
        });
    }

    $scope.addDevelopment = function () {
        $scope.dataModel.developments.push({
            share: null,
            date: null
        });
    }

    $scope.remove = function (index, arr) {
        arr.splice(index,1);
    }

    $scope.log = function () {
        console.log('dataModel', $scope.dataModel)
    }
}