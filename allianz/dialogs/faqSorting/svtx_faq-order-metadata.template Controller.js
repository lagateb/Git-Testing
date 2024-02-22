function controller($scope, csApiSession, pageInstance,csQueryBuilder,csAssetUtil,csNotify,csConfirmDialog,csBehaviorUtil,csDownloadUtils) {

// parent_asset_real user.main-content.
 let assetId = pageInstance.getPathContextReader().getValue().get('id');

    const getFAQTextsTrafo ='svtx:get-faq-text-assets'
    const saveFAQTextSortingTrafo = 'svtx:faq-text-newsorting'
    const createFAQText = "svtx:create.faq.text"
    const deleteFAQText = "svtx:delete.faq.text"

    console.log('Start initData')


    $scope.faqTextOptions=[]
    $scope.faqTextOptionsStart=[]
    $scope.canChangePosition = true
    $scope.isWorking = false
    $scope.withSorting=false;
    $scope.positionChanged=false;

    /**
     *  <option value="root.web.aem." display_value="Vertriebsportal"/>
     <option value="root.web.bs." display_value="AZ.de"/>
     * @param val
     */
    //TODO Umbauen, wenn genause bekannt
    function getChannelNames(val) {
        let ret =''
        if (val.includes('root.web.aem.aem-vp.')) {
            ret = 'Vertriebsportal'
        }
        if (val.includes('root.web.aem.aem-azde.')) {
            if(ret.length>0) {
                ret +=', '
            }
            ret +='AZ.de'
        }
        return ret
    }


    const assignFAQs = (result) => {
        console.log('assignFAQs')
        $scope.faqTextOptions = []
        $scope.faqTextOptionsStart = []

        let curpos = 1;  // eigene Sortnummer, falls Fheler in den Zuordnungen vorhanden sind
        if (!Array.isArray(result.option)) {
            let h = result.option
            result.option = [];
            result.option.push(h)
            $scope.withSorting=false;
        } else {
            $scope.withSorting=true;
        }

        result.option.forEach(element => {
            style_color = '{background-color: #' + element.wf_step_color.toString(16) + '}'
            $scope.faqTextOptions.push({
                id: element.value,
                sorting: curpos,
                display_value: element.display_value,
                wf_step: element.wf_step,
                medias: element.medias+ (element.channels ? ', '+getChannelNames(element.channels):''),
                strapline: element.strapline,
                wf_step_name: element.wf_step_name,
                wf_step_color: element.wf_step_color,
                style_color: style_color
            })
            $scope.faqTextOptionsStart.push({
                id: element.value,
                sorting: curpos,
                display_value: element.display_value,
                wf_step: element.wf_step,
                medias: element.medias+ (element.channels ? ', '+getChannelNames(element.channels):''),
                strapline: element.strapline,
                wf_step_name: element.wf_step_name,
                wf_step_color: element.wf_step_color,
                style_color: style_color
            })
            curpos++
        })
        console.log($scope.faqTextOptions)
        verifyPositionChange();
        $scope.isWorking = false;

    }





  function switchPos(o1,o2) {
      let tmpPos = o1.sorting;
      o1.sorting = o2.sorting;
      o2.sorting = tmpPos;

      $scope.faqTextOptions[tmpPos-1] = o2;
      $scope.faqTextOptions[o1.sorting-1] = o1;
  }

    $scope.saveNewSorting = function() {
        $scope.isWorking=true;

        let ids=[]
        let sortings=[]

        let newSorting = '<newsorting>'
        $scope.faqTextOptions.forEach(
            o => {
                newSorting += '<faq id="'+o.id+'" sorting="'+o.sorting+'" />'
                ids.push(o.id)
                sortings.push(o.sorting)
            }
        )
        newSorting += '</newsorting>'

        console.log(ids)
        console.log(sortings)
        var params={
            contextAsset: assetId,
            variables: [
                { key: 'newSorting', value: JSON.stringify($scope.faqTextOptions)},
                { key: 'sortings', value : sortings.join(",")},
                { key: 'ids',  value : ids.join(",")},
            ]
        };
        console.log('Save Sorting Params', params);
        csApiSession.transformation(saveFAQTextSortingTrafo, params).then(function (data) {
            csNotify.success('Sortierung geändert','')
            initData();
        }).catch(function(err) {
            csNotify.warn('Error updating asset', err);
            console.log(err);
        }).finally(function () {
            $scope.isWorking=false;
        });
    }

   $scope.updateFAQTextPosition = function(faqOption,moveUp) {

      console.log('change position')
      let curpos = faqOption.sorting;

      if(moveUp) {
          if(curpos==1) {
              switchPos(faqOption, $scope.faqTextOptions[$scope.faqTextOptions.length-1])
          } else {
              switchPos(faqOption, $scope.faqTextOptions[curpos-1-1])
          }
      } else {
          if(curpos==$scope.faqTextOptions.length) {
              switchPos(faqOption, $scope.faqTextOptions[0])
          } else {
              switchPos(faqOption, $scope.faqTextOptions[curpos])
          }
      }
       verifyPositionChange();

      //console.log( $scope.faqTextOptions);
      //$scope.$digest;
  }

  function verifyPositionChange () {
      $scope.positionChanged = $scope.hasChanged();
  }

  $scope.hasChanged = function() {
     for(i=0;i<$scope.faqTextOptions.length;i++) {
         if($scope.faqTextOptions[i].id != $scope.faqTextOptionsStart[i].id) {
             return true;
         }
      }
     return false;
  }


    $scope.deleteFAQText = function(option) {
        if( true || value.permission) {

            console.log('deleteFAQText')


            let params = {
                contextAsset: option.id
            };

            csConfirmDialog(pageInstance.getDialogManager(), 'FAQ-Text löschen',  'Möchten Sie diesen FAQ-Text löschen?').then(() => {
                $scope.isWorking=true;
                csApiSession.transformation(deleteFAQText, params).then(
                    function (result) {
                        console.log(result);
                        csNotify.info('FAQ-Text', 'wurde gelöscht!'); // textAsset.name
                        // $scope.$digest oder apply
                        initData()
                    }
                ).catch(function (error) {
                    console.log('Error', error);
                    csNotify.warning('FAQ-Text', ' konnte nicht gelöscht werden!');
                }).finally(function () {
                    $scope.isWorking = false;
                });
            });
        }
    }


    $scope.editText = function(option) {
        //csBehaviorUtil.openAssetPage($scope.resultAsset, $scope);

        csBehaviorUtil.openAssetPageByAssetId(option.id, $scope);
    }




    $scope.createNewFAQPDF = function() {
        if( true || value.permission) {
            console.log('createNewFAQPDF')
            const param = {
                contextAsset: assetId,

            };
                csNotify.info('PDF wird generiert', 'Ihr FAQ-TEXT-PDF wird generiert. Bitte haben Sie einen Moment Geduld.')

                csApiSession.transformation('svtx:fop.create.faq-pdf', param).then(result => {
                    csNotify.success('Download gestartet', 'Ihr FAQ-TEXT-PDF wird nun heruntergeladen.')
                    if (result && result.href ) {
                        const date = new Date();
                        const dateString = `${date.getDate()}-${date.getMonth() + 1}-${date.getFullYear()}`;
                        const filename = 'FAQ-TEXT_' + dateString + '.pdf';
                        const name = result.fileName ? result.fileName : filename;
                        console.log('Attempt to download', result.href);
                        csDownloadUtils.downloadFile(result.href, name, false);

                    }
                }).catch(err => {
                    console.log(err);
                    csNotify.warning('Fehler', err);
                })

        }
    }

    $scope.createNewFAQText = function () {

        //csApiSession.permission.checkAssetIndependentPermission('creation_faq_text').then(function (value) {
        if( true || value.permission) {

            console.log('createNewFAQText')


            let transformationKey = createFAQText

            let assetId = pageInstance.getPathContextReader().getValue().get('id');
            //let ref = 'asset/id/' + assetId +'/currversion/0';

            let params = {
                contextAsset: assetId
            };
            csConfirmDialog(pageInstance.getDialogManager(), 'FAQ-Text anlegen',  'Möchten Sie einen neuen FAQ-Text ablegen?').then(() => {
                $scope.isWorking=true
                csApiSession.transformation(transformationKey, params).then(

                    function (result) {
                        console.log(result);
                        csNotify.info('FAQ-Text', 'wurde erstellt!'); // textAsset.name
                       // $scope.$digest oder apply
                       // initData()
                        $scope.editText({id:result.asset.id})
                    }
                ).catch(function (error) {
                    console.log('Error', error);
                    csNotify.warning('FAQ-Text', ' konnte nicht erstellt werden!');
                }).finally(function () {

                });
            });

        } else {
            csNotify.warning('Fehler', 'Sie haben nicht die benötigten Rechte, um diese Aktion auszuführen!');
        }
        //  });
    }


    $scope.getColorStyle = function(option) {
        return { 'background-color':'#'+parseInt(option.wf_step_color).toString(16)}
    }


  function  getRelatedAssetassets() {
        let qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'text.faq.*');
        qb.relation('parent', 'user.main-content.')
            .condition('censhare:asset.id', assetId);
        qb.view().setTransformation('censhare:cs5.query.asset.list');
        
         csApiSession.asset.query(qb.build()).then(assignFAQs);
    }


  
  
   function initData() {
       console.log('Start initData')
       const contextAsset = { contextAsset: assetId };
       csApiSession.transformation(getFAQTextsTrafo, contextAsset)
           .then(assignFAQs)
           .catch(console.log)
      
    }

    initData();
  

}