/**
 * Controller für AusgabeMedien Anzeige
 *  WebAusgabe
 *  Alle Powerpoints
 **/

function controller($scope, application,csApiSession, ApiService,csQueryBuilder,pageInstance,csNavigationManager,csAssetUtil,csNotify,csConfirmDialog) {
    // $scope.asset.traits.type.type.value[0].value
    $scope.dataModel = {};
    $scope.pptxMedias = []; // alle PowerpointAusgaben
    $scope.currentAssigments =  $scope.asset.traits.modulFaq.medium.value; // alle PowerpointAusgaben  asset.traits.modulFaq.medium"
    $scope.webAssignsments = [ ];
    $scope.currentWebAssigments =[];
    //$scope.hasChanged = true

    const assetId = pageInstance.getPathContextReader().getValue().get('id');
    const pptxMediasTrafo ='svtx:faq-media-chooser';
    const mediasAssignment = 'svtx:faq-media-assignments';

    const webTextTrafo = 'svtx:preselected_output_channel-chooser';
    const readActualData = 'svtx:read_text_diversion';


    const contextAsset = { contextAsset: assetId };

    $scope.inProgress = false;


    const assignOptions = (result) => {
        $scope.pptxMedias=[]
        if(result &&  result.option) {
            result.option.forEach(element => {
                $scope.pptxMedias.push({
                    id: element.value,
                    display_value: element.display_value,
                    value: true,
                    selected: isSelected(element.value)
                })
            })
        }
        csApiSession.transformation(webTextTrafo, contextAsset)
            .then(assignOptionsWeb)
            .catch(console.log)
    };

    const assignOptionsWeb = (result) => {
        $scope.webAssignsments=[]
        $scope.currentWebAssigments = []
        //  TODO Auselsen der Momentanen Daten!
        result.option.forEach(element => {
            $scope.webAssignsments.push({
                id: element.value, display_value:element.display_value, value: false, selected: false,
               key: element.value
            })

            $scope.currentWebAssigments.push({
                id: element.value, display_value:element.display_value, value: false, selected: false,
                key: element.value
            })
        })

        csApiSession.transformation(readActualData, contextAsset)
            .then(addActualData)
            .catch(console.log)
    };

    const addActualData = (result) => {
        if(result !== null) {
            if(!Array.isArray(result.option)) {
                result.option = [result.option];
            }
            result.option.forEach(element => {

                $scope.webAssignsments.forEach(item => {
                        if (item.key  == element.key) {
                            item.selected = true;
                        }
                    }
                )

                $scope.currentWebAssigments.forEach(item => {
                        if (item.key  == element.key) {
                            item.selected = true;
                        }
                    }
                )
            })
        }
    }

    function getSelectedMediasIDs() {
        return  $scope.pptxMedias
            .filter(item => item.selected === true)
            .map(item => item.id);
    }

    $scope.hasChanged = function() {

        if( $scope.inProgress ) {
            return false;
        }


        if(textMustSavedBefore()) {
            return false;
        }

        const selectedMedias= getSelectedMediasIDs();

        if(selectedMedias.length != $scope.currentAssigments.length) {
            return true;
        }

        let changed=false;

        selectedMedias.forEach(
            id => changed=changed || !isSelected(id)
        )

        $scope.webAssignsments.forEach(item => {
                const old = $scope.currentWebAssigments.find(function (el) {
                    return el.key == item.key
                })
                changed ||=  item.selected != old.selected
            }
        );


        return changed;
    }

    function textMustSavedBefore() {
        const app = application.getValue();
        return typeof(app.methods.checkin) == "function"
    }

    $scope.saveMediaAssignment =function (){
        const app = application.getValue();



        // User muss erst den geänderten Text speichern
        if(!textMustSavedBefore()){
            $scope.inProgress = true;

            // IDS der selektierten Medien
            const selectedMedias= getSelectedMediasIDs();
            let data =''
            let separator = ''
            $scope.webAssignsments.forEach(item => {
                    if (item.selected) {
                        data += separator + item.key
                        separator = '|'
                    }
                }
            );

            var params={
                contextAsset: assetId,
                variables: [
                    { key: 'mediaAssignmentsIDs', value: selectedMedias.join(',')},
                    { key: 'webAssignments', value: data},
                ]
            };
                csApiSession.transformation(mediasAssignment, params).then(function (data) {
                csNotify.success('Asset updated','')
                    $scope.currentAssigments = [];
                    selectedMedias.forEach(id => $scope.currentAssigments.push({value:id}))
                    //initData()
                }).catch(function() {

                csNotify.warn('Error updating asset','');

            }).finally(function () {
                    $scope.inProgress = false;
            });


        } else {
            // doUpdateAssetApproval(approval, approvalStatus, comment);
            //   resetForm();
        }
    }



    function isSelected(mediaId) {
        return $scope.currentAssigments.find(media => media.value == mediaId) !== undefined
    }


    function initData() {
        csApiSession.transformation(pptxMediasTrafo, contextAsset)
            .then(assignOptions)
            .catch(console.log)
        //.finally(assignObservable);
    }
    console.log("Start DEbug")
    initData();
}