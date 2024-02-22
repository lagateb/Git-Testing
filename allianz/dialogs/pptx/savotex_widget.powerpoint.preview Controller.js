function controller($scope, csApiSession, pageInstance, $timeout, csQueryBuilder ,csDownloadUtils) {

    let assetId = pageInstance.getPathContextReader().getValue().get('id');

    $scope.showSpinner = false;
    $scope.showPreview = false;
    $scope.previewUrl;
    $scope.selectedOption;

    let qb = new csQueryBuilder();
    let or = qb.or();

    //vorlagen
    let and1 = or.and();
    and1.condition("censhare:asset.type", "presentation.slide.");
    and1.condition("censhare:asset-flag", "is-template");

    //auf platzierten folien
    let and2 = or.and();
    and2.condition("censhare:asset.type", "presentation.*");
    and2.not().condition("censhare:asset-flag", "is-template");
    and2.relation("child", "target.").relation("child", "user.main-content.").condition("censhare:asset.id", assetId);

    csApiSession.asset.query(qb.build()).then(
        function (result) {
            var templates = [];
            angular.forEach(result.container, function (template) {
                let name = template.asset.traits.display.name;
                let id = template.asset.traits.ids.id;
                templates.push({value:id, display_value: name});
            });
            $scope.templates = templates;
        }
    );



    $scope.refresh = () => {
        $scope.showSpinner = true;
        let r = Math.random().toString(36).slice(-5);
        let filename = new Date().getTime()+"-"+r+".jpg";
        let path = "/temp/"+filename;
        console.log("render ppt with textId:"+assetId+" templateId:"+$scope.selectedOption+ " path:"+path);

        csApiSession.execute('com.savotex.api.powerpoint.preview', {assetId:assetId, targetId:$scope.selectedOption, path:path})
            .then(() => {
                $scope.previewUrl = csApiSession.session.resolveUrl('/rest/service/filesystem'+path);
                $scope.showSpinner = false;
                $scope.showPreview = true;
                return true;
            });
    }


    $scope.download = () => {
        $scope.showSpinner = true;
        let r = Math.random().toString(36).slice(-5);
        let filename = new Date().getTime()+"-"+r+".pptx";
        let path = "/temp/"+filename;
        console.log("render ppt with textId:"+assetId+" templateId:"+$scope.selectedOption+ " path:"+path);


        csApiSession.execute('com.savotex.api.powerpoint.preview', {assetId:assetId, targetId:$scope.selectedOption, path:path})
            .then(() => {
                //$scope.previewUrl = csApiSession.session.resolveUrl('/rest/service/filesystem'+path);
                console.log("render fertig");
                let dlUrl = csApiSession.session.resolveUrl('/rest/service/filesystem'+path);
                $scope.showSpinner = false;
                //$scope.showPreview = true;
                console.log("open "+dlUrl);
                //$window.open(dlUrl, '_blank');
                csDownloadUtils.downloadFile(dlUrl,filename);

                return true;
            });
    }
}
