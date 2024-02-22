function controller($scope, csApiSession, csNotify, pageInstance) {
    var assetId = pageInstance.getPathContextReader().getValue().get('id');

    $scope.medias = [];

    $scope.refreshMedia = function() {
        try {
            var params = {
                contextAsset: assetId
            };

            csApiSession.transformation("svtx:xslt.check.updated.templates", params).then(
                function (result) {
                    if( result && result.media ) {
                        if( Array.isArray(result.media) ) {
                            $scope.medias = result.media;
                        } else  {
                            $scope.medias = [result.media];
                        }

                        for( var m = 0; m < $scope.medias.length; m++ ) {
                            if( !Array.isArray($scope.medias[m].history.historyEntry) ) {
                                $scope.medias[m].history.historyEntry = [$scope.medias[m].history.historyEntry];
                            }
                        }
                    } else {
                        $scope.medias = [];
                    }

                    console.log( result);
                    console.log($scope.medias);
                }
            );

        } catch (e) {
            console.log("Cannot retrieve media template information: ", e);
        }
    };

    $scope.updateMedia = function (mediaAsset) {
        console.log( "updateMedia triggered with " + mediaAsset.id);

        try {
            var params = {
                contextAsset: mediaAsset.id
            };

            mediaAsset.refreshing = true;

            var transformationKey = mediaAsset.type == "presentation.slide." ? "svtx:update.slide.from.template" : "svtx:xsl.indesign.copy.layout.and.replace.product";

            csApiSession.transformation(transformationKey, params).then(
                function (result) {
                    console.log( result);

                    csNotify.info('Medien-Template', mediaAsset.name + ' wurde aktualisiert!');
                }
            ).catch(function (error) {
                console.log('Error', error);
                csNotify.warning('Medien-Template', mediaAsset.name + ' konnte nicht aktualisiert werden!');
            }).finally(function () {
                mediaAsset.refreshing = false;

                $scope.refreshMedia();
            });

        } catch (e) {
            csNotify.warning('Medien-Template', mediaAsset.name + ' konnte nicht aktualisiert werden!');
            console.log("Cannot retrieve media template information: ", e);

            mediaAsset.refreshing = false;
        }
    };

    $scope.toggleHistory = function(mediaAsset) {
        mediaAsset.showHistory = !mediaAsset.showHistory;
    }

    $scope.refreshMedia();
}
