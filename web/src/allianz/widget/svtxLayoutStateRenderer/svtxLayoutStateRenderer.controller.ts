const svtxLayoutStateRendererController = ['$scope', 'item', 'context', 'csApiSession', 'csNotify',
function($scope, item, context, csApiSession, csNotify) {

    let childMedia = (item && item.getValue() && item.getValue().source ) ? item.getValue().source : {};

    childMedia.refreshing = false;

    context = context || {};
    $scope.context = context;
    $scope.childMedia = childMedia;

    $scope.allowUpdate = false;

    csApiSession.permission.checkAssetIndependentPermission('layout_template_update').then(function (value) {
        if(value.permission) {
            $scope.allowUpdate = true;
        }
    });

    $scope.$on('$destroy', function() {
    });

    $scope.updateMedia = function(mediaAsset) {
        console.log( "updateMedia triggered with " + mediaAsset.id);

        try {
            var params = {
                contextAsset: mediaAsset.id
            };

            mediaAsset.refreshing = true;

            let transformationKey = null;

            if( mediaAsset.type == "presentation.slide." ) {
                transformationKey = "svtx:update.slide.from.template";
            } else if ( mediaAsset.type == "presentation.issue." ) {
                transformationKey = "svtx:pptx.transform.update.all.slides.of.issue";
            } else if ( mediaAsset.type == "layout." ) {
                transformationKey = "svtx:xsl.indesign.copy.layout.and.replace.product";
            }

            if( !!transformationKey ) {
                csApiSession.transformation(transformationKey, params).then(
                    function (result) {
                        console.log(result);
                        csNotify.info('Medien-Template', mediaAsset.name + ' wurde aktualisiert!');
                        mediaAsset.state = 'ok';
                    }
                ).catch(function (error) {
                    console.log('Error', error);
                    csNotify.warning('Medien-Template', mediaAsset.name + ' konnte nicht aktualisiert werden!');
                }).finally(function () {
                    mediaAsset.refreshing = false;
                });
            } else {
                csNotify.warning('Medien-Template', mediaAsset.name + ' konnte nicht aktualisiert werden, da ' + mediaAsset.type + ' nicht unterstützt wird!');
                mediaAsset.refreshing = false;

            }


        } catch (e) {
            csNotify.warning('Medien-Template', mediaAsset.name + ' konnte nicht aktualisiert werden!');
            console.log("Cannot retrieve media template information: ", e);

            mediaAsset.refreshing = false;
        }
    }

}];

export { svtxLayoutStateRendererController };
