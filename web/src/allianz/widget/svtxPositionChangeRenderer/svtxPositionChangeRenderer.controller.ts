const svtxPositionChangeRendererController = ['$scope', 'item', 'context', 'csApiSession', 'csNotify',

    function($scope, item, context, csApiSession, csNotify) {

    $scope.canChangePosition = true
    
//    let childMedia = (item && item.getValue() && item.getValue().source ) ? item.getValue().source : {};


     $scope.currentAssetId = (item && item.getValue() && item.getValue().source ) ? item.getValue().source.id : 0;
//    childMedia.refreshing = false;

    context = context || {};
    $scope.context = context;
//    $scope.childMedia = childMedia;

    $scope.allowUpdate = false;

    csApiSession.permission.checkAssetIndependentPermission('layout_template_update').then(function (value) {
        if(value.permission) {
            $scope.allowUpdate = true;
        }
    });

    $scope.$on('$destroy', function() {
    });

    $scope.updateTextAsset = function(id,moveUp) {
        console.log( "change triggered with " + id + " and moveUp="+moveUp);

        try {
            var params = {
                contextAsset: id,
                variables: [

                    { key: 'move-up', value: moveUp}
                ]

            };


            let transformationKey = "svtx:text.faq.change.position";


              csApiSession.transformation(transformationKey, params).then(
                    function (result) {
                        console.log(result);
                        csNotify.info('FAQ-Text', ' wurde verschoben!');
                        //textAsset.state = 'ok';
                    }
                ).catch(function (error) {
                    console.log('Error', error);
                    csNotify.warning('FAQ-Text', ' konnte nicht verschoben werden!');
                }).finally(function () {
                    //textAsset.refreshing = false;
                });


        } catch (e) {
            csNotify.warning('FAQ-Text',  ' konnte nicht verschoben werden!');
            console.log("Cannot sort faq-text information: ", e);

           // textAsset.refreshing = false;
        }
    }

}];

export { svtxPositionChangeRendererController };
