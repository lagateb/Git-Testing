function controller($scope, application, pageInstance,  csApiSession,  ApiService,  csNotify, $http, csTranslate, csAssetWorkflowEditDialog, csColorUtil,csConfirmDialog) {

    // Global variables 
    const assetId = pageInstance.getPathContextReader().getValue().get('id');
    const currentUserAssetId = ApiService.session.getUserAssetId()
    const featureKey = 'censhare:approval.type'

    const ResetToInWork = 'svtx:reset_wf_state_from_modul_object'

    const ResetTextToRecreation =  'svtx:reset_text_wf_state_creation'


    console.log('$scope.asset.traits.workflow', $scope.asset.traits.workflow);

    $scope.$watch('asset.traits.workflow.workflowStep.value[0].value', function(a,b) {
        console.log('WF CHANGED');
        console.log(a);
        console.log(b);
        getDataModel();
        resetForm();
    })



    $scope.WF_TEXT = 10;
    $scope.WF_MEDIA = 80;


    $scope.WF_STEP_TEXT_PUBLISHED = 35;
    $scope.WF_STEP_TEXT_APPROVED = $scope.WF_STEP_APPROVED =  30;
    $scope.WF_STEP_TEXT_TO_APPROV =   $scope.WF_STEP_TO_APPROV =  20;
    $scope.WF_STEP_TEXT_CREATION = 10;
    $scope.WF_STEP_MEDIA_PUBLISHED = 90;


    // Defaults
    $scope.dataModel = {};
    $scope.dataModelLoaded = false;

    $scope.approvals = [];
    $scope.formData = {};

    $scope.formData.addComment = false;
    $scope.formData.createTask = false;
    $scope.formData.addCommentApprovals = false;
    $scope.formData.addAdditionalComment = false;

    $scope.enableComment = false;

    // approvalStatusConfig could enriched by enrichStatusConfigModel ifsome settings should be from masterdata 
    $scope.approvalStatusConfig = {
        none:    {value:'none',     display_value: csTranslate.instant('csCommonTranslations.none'),     buttonLabel:'',                                     enabled:true, addComment:true, createTask:false},
        start:   {value:'started',  display_value: csTranslate.instant('csCommonTranslations.started'),  buttonLabel: csTranslate.instant('csCommonTranslations.startApproval'),  enabled:true, addComment:true, createTask:false},
        approve: {value:'approved', display_value: csTranslate.instant('csCommonTranslations.approved'), buttonLabel: csTranslate.instant('csCommonTranslations.approve'),        enabled:true, addComment:true, createTask:false},
        reject:  {value:'rejected', display_value: csTranslate.instant('csCommonTranslations.rejected'), buttonLabel: csTranslate.instant('csCommonTranslations.reject'),         enabled:true, addComment:true,  createTask:false},
        delete:  {value:'deleted',  display_value: csTranslate.instant('csCommonTranslations.deleted'),  buttonLabel: csTranslate.instant('csCommonTranslations.delete'),         enabled:true, addComment:true,  createTask:false},
        ignore:  {value:'ignored',  display_value: csTranslate.instant('csCommonTranslations.ignored'),  buttonLabel: csTranslate.instant('csCommonTranslations.ignore'),         enabled:true, addComment:true,  createTask:false}
    };




    function isTextWorkFlow() {
        return   $scope.dataModelLoaded && $scope.dataModel.metadata.workflowID == $scope.WF_TEXT
    }

    function isMediaWorkFlow() {
        return $scope.dataModelLoaded && $scope.dataModel.metadata.workflowID == $scope.WF_MEDIA
    }


    $scope.showDeclined =function () {
        return $scope.dataModelLoaded &&   $scope.dataModel.metadata.workflowStepID == 10
    }


    // Nur für Rolle Marketing Mananger
    $scope.enableMarkmanagement=function() {
        return  $scope.dataModelLoaded &&  $scope.hasRequiredRoll();
    }

    // Wenn Text noch nicht freigegebn aber NIO
    $scope.enableTextToReCreation =function() {

        return  isTextWorkFlow() && $scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TEXT_TO_APPROV ;
    }

    // Abegschlossenre Ablauf neu starten
    $scope.enableNewVersion =function() {
        return  isTextWorkFlow() &&
            ($scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TEXT_PUBLISHED  ||  $scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TEXT_APPROVED) ;
    }

    // Text zur Abstimmung freigben
    $scope.enableTextToApprov =function() {
        return   isTextWorkFlow() && $scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TEXT_CREATION ;
    }

    // Text freigeben
    $scope.enableTextToApproved =function() {
        return   isTextWorkFlow() &&  $scope.enableTextToApprov() || $scope.enableTextToReCreation();
    }




    $scope.enableMediaToReCreation =function() {
        return  isMediaWorkFlow() && $scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TO_APPROV ;
    }


    // Media freigeben
    $scope.enableMediaToApproved =function() {
        const stepId = $scope.dataModel.metadata.workflowStepID;
        return   isMediaWorkFlow() && (stepId === 10 || stepId === 20);
    }


    $scope.enableMediaToApprov =function() {
        return   isMediaWorkFlow() && $scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TEXT_CREATION ;
    }



    $scope.setMediaToWFApprove =function() {
        $scope.updateWorkflow($scope.dataModel.metadata.workflowID, $scope.WF_STEP_TO_APPROV,true )
    }


    $scope.assetWFStateIsNotInCreation = function() {
        return $scope.dataModelLoaded && (($scope.dataModel.metadata.workflowID == $scope.WF_TEXT && $scope.dataModel.metadata.workflowStepID != $scope.WF_STEP_TEXT_CREATION)
            || ($scope.dataModel.metadata.workflowID ==$scope.WF_MEDIA && $scope.dataModel.metadata.workflowStepID != 10))
    }



    $scope.setMediaToWFApproved =function() {

        csConfirmDialog(pageInstance.getDialogManager(), 'Medium freigeben',  "Sind Sie sicher?\n Das Medium wird freigegeben.").then(() => {
            // $scope.updateWorkflow($scope.WF_TEXT, $scope.WF_STEP_TEXT_CREATION)
            var params={
                contextAsset: assetId

            };
            $scope.updateWorkflow($scope.dataModel.metadata.workflowID, $scope.WF_STEP_APPROVED,true )
        }).catch(function() {

        })



    }






    $scope.setTextToWFApprove =function() {
       $scope.updateWorkflow($scope.dataModel.metadata.workflowID, $scope.WF_STEP_TEXT_TO_APPROV,true )
    }

    $scope.setTextToWFApproved =function() {

        csConfirmDialog(pageInstance.getDialogManager(), 'Text freigeben',  "Sind Sie sicher?\n Der Text wird freigegeben.").then(() => {
            // $scope.updateWorkflow($scope.WF_TEXT, $scope.WF_STEP_TEXT_CREATION)
            var params={
                contextAsset: assetId

            };
            $scope.updateWorkflow($scope.dataModel.metadata.workflowID, $scope.WF_STEP_TEXT_APPROVED,true, true )
            }).catch(function() {

            })



    }


    $scope.setMediaToRecreation =function() {
        csConfirmDialog(pageInstance.getDialogManager(), 'Medium neu bearbeiten',  "Sind Sie sicher?\n Das Medium wird in den Bearbeitungsstand gesetzt .").then(() => {

            var params={
                contextAsset: assetId,
            };

            csApiSession.transformation(ResetTextToRecreation, params).then(function (data) {
                csNotify.success('Assets updated','');
                getDataModel();
            }).catch(function() {
                csNotify.warn('Error updating assets','');
            }).finally(function () {
                resetForm();
            });

        }).catch(function() {

        })

    }



    $scope.setTextToRecreation =function() {
        csConfirmDialog(pageInstance.getDialogManager(), 'Text neu bearbeiten',  "Sind Sie sicher?\n Der Text wird in den Bearbeitungsstand gesetzt .").then(() => {

            var params={
                contextAsset: assetId,
            };

            csApiSession.transformation(ResetTextToRecreation, params).then(function (data) {
                csNotify.success('Assets updated','');
                getDataModel();
            }).catch(function() {
                csNotify.warn('Error updating assets','');
            }).finally(function () {
                resetForm();
            });

        }).catch(function() {

        })

    }




    pageInstance.getContextProvider().then(function (contextProvider) {
        $scope.application = contextProvider.getLiveApplicationInstance("com.censhare.api.applications.asset.metadata.AssetInfoApplication");
    });

    $scope.addWorkflow = function () {
        if ($scope.application) {
            csAssetWorkflowEditDialog.open(pageInstance.getDialogManager(), $scope.application).then(
                function () {
                    var app = $scope.application.getValue();
                    if (angular.isFunction(app.methods.checkin)) {
                        app.methods.checkin();
                    }
                    setTimeout(function() {
                        getDataModel();
                    }, 1000);
                }
            );
        }
    };

    csApiSession.permission.checkAssetIndependentPermission('approval_additional_comment').then(function (value) {
        if(value.permission) {
            $scope.enableComment = true;
        }
    });

    $scope.workflowStepColor = csColorUtil.dec2hex(0);
    $scope.workflowStateColor = csColorUtil.dec2hex(0);


    // This fucnction will update props on $scope.approvalStatusConfig from asset model (masterdata)
    const enrichStatusConfigModel = function(){
        for(var approvalStatusConfigName in $scope.approvalStatusConfig) {
            approvalStatusConfig = $scope.approvalStatusConfig[approvalStatusConfigName];
            const statusOption = angular.copy($scope.asset.traits.approval.approvalType.value[0].status.generator.options.filter(option => option.value == approvalStatusConfig.value)[0]);
            approvalStatusConfig.enabled = statusOption !== undefined;
            approvalStatusConfig.display_value = statusOption.display_value;
        }
    };
    // Commet line below to make settings here to override settings from mastedata
    //enrichStatusConfigModel();

    //console.log('$scope.approvalStatusConfig', $scope.approvalStatusConfig);

    function getDataModel() {
        console.log('getDataModel')
        let dataModelTransformationKey ='svtx:transformation.approval.data-model';
        url = csApiSession.session.resolveUrl('rest/service/assets/asset/id/' + assetId +  '/transform;key=' + dataModelTransformationKey + '/json');

        $http.get(url)
            .then(function(response) {
                $scope.dataModel = response.data;
                //console.log('dataModel: ',$scope.dataModel);
                $scope.dataModelLoaded = true;

                $scope.workflowStepColor = csColorUtil.dec2hex($scope.dataModel.metadata.workflowStepColor);
                $scope.workflowStateColor = csColorUtil.dec2hex($scope.dataModel.metadata.workflowStateColor);

                // $scope.dataModel.metadata.additionalComment = $scope.dataModel.metadata.additionalComment.replace("/\n/g", "<br>");
            })
            .catch(function() {
                $scope.chart = null;
                $scope.dataModelLoaded = false;
            });
    }

    getDataModel();

    /*  $scope functions  */

    $scope.approvalActionForm = function() {
        if ($scope.formData.createTask !== false){
            csNotify.warn('Create Task ','Not implemented yet...');
        }

        if ($scope.formData.addComment !==false){

        }
        updateApproval($scope.formData.currentApproval, $scope.formData.actionKey, $scope.formData.comment);
        resetForm();
    }

    $scope.approvalAction = function(approval, approvalStatusConfig) {

        if(approvalStatusConfig.addComment===true) {
            $scope.formData.currentApproval = approval;
            $scope.formData.actionKey = approvalStatusConfig.value;
            $scope.formData.addComment = approval.key;
        }
        else if(approvalStatusConfig.createTask===true) {
            $scope.formData.currentApproval = approval;
            $scope.formData.actionKey = approvalStatusConfig.value;
            $scope.formData.createTask = approval.key;
        } else {
            updateApproval(approval, approvalStatusConfig.value, $scope.formData.comment);
        }
    };

    $scope.approvalActionByKey = function(approvalKey, approvalStatusConfig) {
        let approval = $scope.dataModel.approval?.find(obj => obj.key === approvalKey);
        if(approval) {
            if (approvalStatusConfig.addComment === true) {
                $scope.formData.currentApproval = approval;
                $scope.formData.actionKey = approvalStatusConfig.value;
                $scope.formData.addCommentApprovals = approval.key;
            } else if (approvalStatusConfig.createTask === true) {
                $scope.formData.currentApproval = approval;
                $scope.formData.actionKey = approvalStatusConfig.value;
                $scope.formData.createTask = approval.key;
            } else {
                updateApproval(approval, approvalStatusConfig.value, $scope.formData.comment);
            }
        }
    };

    $scope.writeAdditionalComment = function() {
        $scope.formData.addAdditionalComment = true;
        $scope.formData.comment=$scope.dataModel.metadata.additionalComment;
    }

    $scope.additionalCommentActionForm = function() {
        $scope.formData.addAdditionalComment = false;
        updateAdditionalComment($scope.formData.comment);
        resetForm();
    }




    const updateAdditionalComment = function(comment){

        const app = application.getValue();

        if(!app.methods.checkin){

            var params={
                contextAsset: assetId,
                variables: [
                    { key: 'featureKey', value: 'svtx:approval.additional.comment'},
                    { key: 'comment', value: comment}
                ]
            };
            csApiSession.transformation('svtx:set-approvals.extension', params).then(function (data) {
                csNotify.success('Asset updated','');
                $scope.dataModel.metadata.additionalComment = comment;
                resetForm();
            }).catch(function() {

                csNotify.warn('Error updating asset','');

            }).finally(function () {
                resetForm();
            });

        } else {
            resetForm();
        }
    }


    // Der Text wird in den Status "Text creation" => 10 gesetzt
    // Schritt des Produktes wird auf "in Bearbeitung" gesetzt. ?
    // Schritt der Medien in (denen der Text genutzt wird) wird auf "in Bearbeitung" gesetzt.

    $scope.resetTextToCreationState = function() {
        csConfirmDialog(pageInstance.getDialogManager(), 'Neue Version anlegen',  "Sind Sie sicher?\n Freigaben des Texte und der Medien werden gelöscht und müssen neu durchlaufen werden.").then(() => {
           // $scope.updateWorkflow($scope.WF_TEXT, $scope.WF_STEP_TEXT_CREATION)
            var params={
                contextAsset: assetId

            };
            csApiSession.transformation(ResetToInWork, params).then(function (data) {
                csNotify.success('Assets updated','');
                getDataModel();
            }).catch(function() {
                csNotify.warn('Error updating assets','');
            }).finally(function () {
                resetForm();
            });


        });

    }

    $scope.updateWorkflow = function(workflowID, workflowStepID,withHistoryReset=false, versioned = false){

        const app = application.getValue();

        if(!app.methods.checkin){

            var params={
                contextAsset: assetId,
                variables: [
                    { key: 'workflowID', value: workflowID},
                    { key: 'workflowStepID', value: workflowStepID},
                    { key: 'historyReset', value: withHistoryReset?'yes':'no'},
                    { key: 'versioned', value: versioned }
                ]
            };
            csApiSession.transformation('svtx:set-approvals.extension.workflow', params).then(function (data) {
                csNotify.success('Asset updated','');
                /*getDataModel();*/
            }).catch(function() {
                csNotify.warn('Error updating asset','');
            }).finally(function () {
                /*resetForm();*/
            });

        } else {
            resetForm();
        }
    }
    // text.faq. hat beim Text keine Ausleitung
    $scope.isNotFAQ = function(){

        return $scope.asset.traits.type.type.value[0].value != 'text.faq.'
    }

    $scope.hasRequiredRoll = function() {

        let hasRoll = false;

        if($scope.dataModel && $scope.dataModel.metadata && $scope.dataModel.metadata.userRoles) {

            if (angular.isArray($scope.dataModel.metadata.userRoles.systemRoles.role)) {
                $scope.dataModel.metadata.userRoles.systemRoles.role.forEach(function (role) {
                    if (role.role === 'admin' || role.role === 'marketing_manager') {
                        hasRoll = true;
                    }
                });
            }
            else {
                if ($scope.dataModel.metadata.userRoles.systemRoles.role.role === 'admin' || $scope.dataModel.metadata.userRoles.systemRoles.role.role === 'marketing_manager') {
                    hasRoll = true;
                }
            }
        }

        return hasRoll;
    }

    $scope.enableDeleteButton = function(assetApproval) {
        let approval = $scope.dataModel.approval?.find(obj => obj.key === assetApproval.value);
        let allowed = false;
        if(approval && approval.roleShowApproval) {
            allowed = true;
        }

        return (allowed && (assetApproval.status.value[0].value == 'approved' || assetApproval.status.value[0].value == 'ignored'));
    }

    $scope.cancel = function(){
        resetForm();
    };

    // Get display_value of status needed for dialog as asset may not have status
    $scope.getStatusDisplayValue = function(approvalObjectOrKeyString){
        return getAssetApprovalStatus(approvalObjectOrKeyString, true);
    };

    $scope.getApprovalDescription = function(approvalObjectOrKeyString){

        const defaultReturnVal = '[No description available]';

        if($scope.dataModelLoaded === false || $scope.dataModel.approval === undefined)
            return defaultReturnVal;

        // Need to hande both key as string and object approval (prop key) or assetApproval (prop value)
        let approvalKey=''
        if(typeof approvalObjectOrKeyString == 'string'){
            approvalKey = approvalObjectOrKeyString;
        } else if (typeof approvalObjectOrKeyString == 'object'){
            approvalKey = approvalObjectOrKeyString.key ? approvalObjectOrKeyString.key : approvalObjectOrKeyString.value;
        }

        if(approvalKey === undefined || approvalKey === '')
            return defaultReturnVal;

        const approval = $scope.dataModel.approval.filter(approval => approval.key == approvalKey)[0];
        if(approval !== undefined && approval.description !== ''){
            return approval.description;
        } else {
            return defaultReturnVal;
        }

    };

    $scope.statusCss = function(approvalObjectOrKeyString){
        const statusValue = getAssetApprovalStatus(approvalObjectOrKeyString);

        switch (statusValue) {
            case $scope.approvalStatusConfig.approve.value:
                return 'cs-icon-circle-ok cs-color-30';
            case $scope.approvalStatusConfig.start.value:
                return 'cs-icon-no-progress cs-color-36';
            case $scope.approvalStatusConfig.reject.value:
                return 'cs-icon-circle-remove cs-color-38';
            case $scope.approvalStatusConfig.ignore.value:
                return 'cs-icon-circle cs-color-05';
            case $scope.approvalStatusConfig.delete.value:
                return 'cs-icon-close-cross cs-color-00';
            case $scope.approvalStatusConfig.none.value:
                return 'cs-icon-no-progress cs-color-00';
            default:
                return 'cs-icon-no-progress cs-color-00';
        }
    };

    $scope.showButton = function(approvalObjectOrKeyString, approvalStatusConfig){

        const button = approvalStatusConfig.value;
        const statusValue = getAssetApprovalStatus(approvalObjectOrKeyString);

        if(!approvalStatusConfig.enabled) {
            return false;
        }
        switch (button) {
            case $scope.approvalStatusConfig.delete.value:
                switch (statusValue) {
                    case $scope.approvalStatusConfig.none.value: case $scope.approvalStatusConfig.delete.value:
                        return false;
                    default:
                        return true;
                }
            case $scope.approvalStatusConfig.ignore.value:
                switch (statusValue) {
                    case $scope.approvalStatusConfig.ignore.value: case $scope.approvalStatusConfig.approve.value:
                        return false;
                    default:
                        return true;
                }
            case $scope.approvalStatusConfig.start.value:
                switch (statusValue) {
                    case $scope.approvalStatusConfig.none.value:  case $scope.approvalStatusConfig.delete.value:
                        return true;
                    default:
                        return false;
                }
            case $scope.approvalStatusConfig.approve.value:
                switch (statusValue) {
                    // approve button should be visible if current status is 'none' and "started" valueKey is deactivated
                    case $scope.approvalStatusConfig.none.value:
                        return ($scope.approvalStatusConfig.start.enabled === false);
                    case $scope.approvalStatusConfig.start.value: case $scope.approvalStatusConfig.reject.value:
                        return true;
                    default:
                        return false;
                }
            case $scope.approvalStatusConfig.reject.value:
                switch (statusValue) {
                    // reject button should be visible if current status is 'none' and "started" valueKey is deactivated
                    case $scope.approvalStatusConfig.none.value:
                        return ($scope.approvalStatusConfig.start.enabled === false);
                    case $scope.approvalStatusConfig.start.value: case $scope.approvalStatusConfig.reject.value:
                        return true;
                    default:
                        return false;
                }
            default:
                return false;
        }
    }

    $scope.progress = function(){

        if($scope.dataModelLoaded === false || $scope.dataModel.approval === undefined)
            return 0;

        const approvalCount = $scope.dataModel.approval.length;

        if(approvalCount===0)
            return 0;

        let readyApprovalCount = 0;
        $scope.dataModel.approval.forEach(function (approval) {
            const statusValue = getAssetApprovalStatus(approval.key);
            if (statusValue === $scope.approvalStatusConfig.approve.value || statusValue === $scope.approvalStatusConfig.ignore.value)
                readyApprovalCount = readyApprovalCount + 1;
        });

        return (readyApprovalCount / approvalCount) * 100;
    }

    // ** Global helper function **
    // Get asset approval  approvalObjectOrKeyString coudl be current assetApproval, approval or just approvalKey the get asset approval from key 
    const getAssetApproval = function(approvalObjectOrKeyString) {
        if (typeof approvalObjectOrKeyString == 'object'){
            // If key exusts asume approval object  
            if(approvalObjectOrKeyString.key){
                return getAssetApprovalByKey(approvalObjectOrKeyString.key);
            } else {
                // Asume asset approval object 
                return approvalObjectOrKeyString;
            }
        } else if (typeof approvalObjectOrKeyString == 'string'){
            return getAssetApprovalByKey(approvalObjectOrKeyString);
        } else {
            return;
        }

    };
    const getAssetApprovalByKey = function(approvalKey){
        return $scope.asset.traits.approval.approvalType.value.filter(approval => approval.value == approvalKey)[0]; // Assume there will be only one...if not we still want just one...
    }

    const getAssetApprovalStatus = function(approvalObjectOrKeyString, displayValue){

        const showDisplayValue = displayValue ? displayValue : false;
        const assetApproval = getAssetApproval(approvalObjectOrKeyString);

        if (assetApproval !== undefined){
            statusValue = assetApproval.status && assetApproval.status.value  && assetApproval.status.value[0].value ? assetApproval.status.value[0].value : $scope.approvalStatusConfig.none.value;
            if (showDisplayValue){
                const approvalStatusConfig = getApprovalStatusConfig(statusValue);
                return approvalStatusConfig.display_value;
            } else {
                return statusValue;
            }

        } else {
            return showDisplayValue ? $scope.approvalStatusConfig.none.display_value : $scope.approvalStatusConfig.none.value;
        }


    };

    const getApprovalStatusConfig = function(approvalStatusValue){

        for(let propName in $scope.approvalStatusConfig) {
            if($scope.approvalStatusConfig[propName].value === approvalStatusValue){
                return approvalStatusConfig = $scope.approvalStatusConfig[propName]
            }
        }
        return $scope.approvalStatusConfig.none;
    };


    const setApprovedIfOk = function() {
     if($scope.dataModel.metadata.workflowStepID == $scope.WF_STEP_TO_APPROV) {
         let currentStatus = $scope.progress();
         if (currentStatus>99) {
             let wf =  $scope.dataModel.metadata.workflowID
             let newStep =  $scope.WF_STEP_APPROVED // für beide 30
             $scope.updateWorkflow(wf,newStep)
         }
     }
    }

    // Update functions
    const updateApproval = function(approval, approvalStatus, comment){

        const app = application.getValue();

        if(!app.methods.checkin){

            var params={
                contextAsset: assetId,
                variables: [
                    { key: 'featureItemKey', value: approval.key},
                    { key: 'approvalStatus', value: approvalStatus},
                    { key: 'comment', value: comment}
                ]
            };
            csApiSession.transformation('svtx:set-approvals', params).then(function (data) {
                csNotify.success('Asset updated','');
                resetForm();

                if(approvalStatus === 'approved' || approvalStatus === 'ignored') {
                    setTimeout(function() {
                        getDataModel();
                        // Wieder nur   setApprovedIfOk();
                    }, 2000);
                }

            }).catch(function() {

                csNotify.warn('Error updating asset','');

            }).finally(function () {

                resetForm();

            });

            /*  Below does not work well using xslt instead
            $scope.asset.checkout();

            // Do the update in time out to make sure updated scope is updated
            $timeout(function () {
                // do update on the asset

                doUpdateAssetApproval(approval, approvalStatus, comment);
                $scope.asset.update();

                $timeout(function () {
                    // Get application and check if checkin s available
                    const app = application.getValue();
                    console.log('In first checkin attempt ', angular.copy($scope.asset.traits.approval))
                    if (app.methods.checkin) {
                        //$scope.asset.update();
                        $scope.asset.checkin();
                    }
                    else {
                        // Do another attempt with a bit longer delay
                        $timeout(function () {
                            const app = application.getValue();
                            console.log('In second checkin attempt ', angular.copy($scope.asset.traits.approval))
                            if (app.methods.checkin) {
                                $scope.asset.checkin();
                            } else {
                                csNotify.warn('Save command not yet available: ', 'Please try to save asset manually');
                            }

                        }, 500, true)
                    }
                },500, true);

            },500, true);
            */

        } else {
            doUpdateAssetApproval(approval, approvalStatus, comment);
            resetForm();
        }
    }
    const resetForm = function(){
        $scope.formData.addComment=false;
        $scope.formData.createTask = false;
        $scope.formData.addCommentApprovals = false;
        $scope.formData.addAdditionalComment = false;
        $scope.formData.currentApproval = {};
        $scope.formData.actionKey = '';
        $scope.formData.comment='';
    }

    const doUpdateAssetApproval = function(approval, approvalStatus, comment){

        let approvalKey = approval.key;
        let assetApproval = getAssetApproval(approvalKey);

        const assetVersionStamp = $scope.asset.traits.versioning.version.value[0].value + 1;

        // If not exists create it
        if(assetApproval===undefined){

            let assetApprovalTemplate = $scope.asset.traits.approval.approvalType.value;
            assetApproval = createValueTemplate(assetApprovalTemplate);
            assetApproval.value= approvalKey;
            assetApprovalTemplate.push(assetApproval);
            let assetApprovalArray=[];
            assetApprovalArray.push(assetApproval);
            approval.assetApproval= assetApprovalArray;
        }

        if(assetApproval !== undefined){
            assetApproval.status.value[0].value=approvalStatus;
            assetApproval.comment.value[0].value=comment;
            assetApproval.person.value[0].value=currentUserAssetId;
            assetApproval.date.value[0].value=Date.now();
            assetApproval.assetVersion.value[0].value=assetVersionStamp;
            if(approvalStatus===$scope.approvalStatusConfig.delete.value) {
                assetApproval.deleted = true;
            }

            // Also create a historyAproval
            // Check if an entry for current approvalKey and version already exists
            let historyAssetApprovals = $scope.asset.traits.approval.history.value[0].approvalType.value;
            let historyAssetApproval = historyAssetApprovals.filter(approval => approval.value == approvalKey && approval.assetVersion.value[0].value == assetVersionStamp)[0];

            if (historyAssetApproval === undefined){
                historyAssetApproval = createValueTemplate(historyAssetApprovals);
                historyAssetApproval.value = approvalKey;
                historyAssetApproval.assetVersion.value[0].value = assetVersionStamp;
                historyAssetApproval.person.value[0].value=currentUserAssetId;
                historyAssetApprovals.push(historyAssetApproval);
            }
            if (historyAssetApprovals !== undefined){
                historyAssetApproval.status.value[0].value=approvalStatus;
                historyAssetApproval.comment.value[0].value=comment;
                historyAssetApproval.date.value[0].value=Date.now();
            }
        }
    };


    const cleanValue = function(value) {
        let clean = {};
        angular.forEach(value, function (v, k) {
            if (angular.isObject(v) && v.hasOwnProperty('exists')) {
                v = angular.copy(v);
                v.value = [createValueTemplate(v.value)];
                v.exists = false;
                clean[k] = v;
            }
        });
        return clean;
    };
    const createValueTemplate = function(values) {

        let value;
        if (angular.isArray(values)) {
            for (let i = 0; i < values.length; i += 1) {
                value = values[i];
                if (!value.hasOwnProperty('self') || value.self.indexOf('temp') !== 0) {
                    return cleanValue(value);
                }
            }
        }
        return {};
    };
    console.log("Debug jetzt")
}