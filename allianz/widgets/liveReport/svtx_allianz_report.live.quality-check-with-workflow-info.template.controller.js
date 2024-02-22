function controller($scope, csColorUtil, application, csAssetWorkflowEditDialog, pageInstance, widgetDataManager) {
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
                }
            );
        }
    };

    $scope.$watch('data.workflowStepColor', function (val) {
        $scope.workflowStepColor = csColorUtil.dec2hex($scope.data.workflowStepColor);
        $scope.workflowStateColor = csColorUtil.dec2hex($scope.data.workflowStateColor);
    });
}