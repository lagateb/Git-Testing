import { UploadManagerService } from '@cs/client/base/csUploadsManager/cs-uploads-manager.service';
import { FileState, IMessage } from '../../../ng1/client/base/csUploadsManager/cs-uploads-manager.service';
import { IWidgetDataManager } from '@cs/client/DAM/widgets/assetInfo/assetFileList/asset-file-list-widget-manager.constant';
import { CommandType } from '../../../ng2/app/core/api/command/command-type';

const csDynamicAssetFileListWidgetController = [
    '$scope', '$filter', '$q', 'widgetDataManager', 'pageInstance', 'widgetInstance', 'csApiSession',
    'csUploadsManager', 'csConfirmDialog', 'csAssetUtil', 'csNotify', 'csAssetApplicationUtil', 'csTranslate',
    'csArrayDataManager', 'csServices', 'csDownloadFilesDialog', 'csGlobalDialogManagerService', 'csDownloadUtils',
     'csSystemSettings', 'csFileSizeService', 'csFileUploadService',
    function($scope, $filter, $q: ng.IQService, widgetDataManager: IWidgetDataManager, pageInstance, widgetInstance, csApiSession,
             csUploadsManager: UploadManagerService, csConfirmDialog, csAssetUtil, csNotify, csAssetApplicationUtil, csTranslate,
             csArrayDataManager, csServices, csDownloadFilesDialog, csGlobalDialogManagerService, csDownloadUtils) {

        const application = widgetDataManager.getApplication();
        const assetID = pageInstance.getPathContextReader().getValue().get('id');
        const globalDialogManager = csGlobalDialogManagerService.getGlobalDialogManager();
        const uploadCommand = 'com.censhare.api.dam.assetmanagement.replacemasterstorageitem';
        const uploadParams = {assetId: assetID};
            // Set up stuff for pagination renderer
        const resultAdm = csServices.createObservable([]);
        let asset;
        const currentState: IMessage = widgetDataManager.uploadReader.getValue().data[0];

        widgetDataManager.uploadReader.registerChangeListener((event: {data: IMessage[]}) => {
            switch (event.data[0].state.state) {
                case FileState.READY:
                case FileState.END:
                    $scope.uploadProgress = event.data[0].payload.uploadProgress;
                    $scope.uploadProgressValue = event.data[0].state.progress;

                    if ($scope.uploadProgress === false) {
                        // Being here means that upload is finished
                        widgetInstance.acquireWidgetService('csAssetPreviewContextService', assetID)
                            .then((widgetService) => {
                                widgetService.getAssetContextEventEmitter().emit('updateImagePreview');
                            });
                    }

                    break;
                case FileState.PROGRESS:
                    $scope.uploadProgress = event.data[0].payload.uploadProgress;
                    uploadProgress(event.data[0].state.progress);
                    break;
                case FileState.ERROR:
                    $scope.uploadProgress = event.data[0].payload.uploadProgress;
                    uploadFailed(event.data[0].state.error);
                    break;
                default:
                    break;
            }
        });

        csApiSession.asset.get(assetID, {limit: 1}).then(function(response) {
            if (response) {
                asset = response.container[0].asset;
            }
        });

        $scope.adm = new csArrayDataManager(resultAdm.reader);
        // After context object is created it is not safe to modify its primitive properties.
        // csVirtualListRenderer will make a copy of the context object passed and store it in the $scope of the renderer,
        // thus any new changes to the object below will not be visible in the renderer context
        $scope.context = {
            flavor: 'csDynamicAssetFileListWidgetItemRenderer',
            classicPagination: true,
            permissions: {
                edit: false,
                export: false
            }
        };

        // Sets title and icon for the widget
        widgetInstance.setTitle('csAssetFileListWidget.title');

        // Initialize boolean flags with default values

        $scope.uploadProgress = currentState.payload.uploadProgress;
        $scope.uploadProgressValue = currentState.state.progress;

        if (currentState.state.state === FileState.ERROR) {
            uploadFailed(currentState.state.error);
        }

        // Opt: Use standard icon URL call
        $scope.uploadIcon = csApiSession.session.resolveUrl('rest/service/resources/icon/assettype-other./minsize/128/background/dark/file');
        $scope.hasFiles = false;
        $scope.readOnly = false;
        $scope.hasMaster = false;
        $scope.csDropzoneVisible = false;

        $scope.dynIcons = {};
        $scope.dynIcons.upload = $scope.uploadIcon;
        $scope.dynIcons.pdf = csApiSession.session.resolveUrl('rest/service/resources/icon/assettype-adobe-pdf/minsize/128/file');
        $scope.dynIcons.print = csApiSession.session.resolveUrl('rest/service/resources/icon/assettype-channel.print./minsize/128/background/dark/file');

        widgetInstance.getConfig().registerChangeListenerAndFire(updateContextFlavor, $scope);

        application.registerChangeListenerAndFire(loadStorageItems, $scope);

        // refresh on language changes
        csTranslate.getLocaleReader().registerChangeListener(function() {
            loadStorageItems(application.getValue());
        }, $scope);

        // cs-drop-file drop-callback="dropFile"
        $scope.dropIface = {
            typeFilter: ['Files'],
            onDrop: dropFile,
            onDragWindowEnter: onDragWindowEnter,
            onDragWindowLeave: onDragWindowLeave
        };

        $scope.uploadFile = function() {
            return csUploadsManager.addNewUploadsWithFileChooser(false, uploadCommand, uploadParams).then(function(uploads) {
                if (uploads.length > 0) {
                    widgetDataManager.uploadStart(uploads[0]);
                }
            });
        };

        $scope.context.downloadCheckout = function(e) {

            if ($scope.context.permissions.edit) {

                const app = application.getValue();

                if (app.methods && app.methods.hasOwnProperty('checkout')) {

                    return app.methods.checkout().then(function() {

                        return true;

                    }, function(error) {
                        csNotify.warning('csAssetFileListWidget.checkout', error);
                    });
                } else {
                    return true;
                }
            }

            e.stopPropagation();
            e.preventDefault();

            return false;
        };

        $scope.context.replaceFile = function() {
            $scope.uploadFile().then(function() {
                resultAdm.setValue([]);
            });
        };

        $scope.context.deleteFile = function(type) {
            csConfirmDialog(pageInstance.getDialogManager(), 'csDynamicAssetFileListWidget.delete', 'csDynamicAssetFileListWidget.deleteConfirm').then(function() {
                const params: any = {};
                params.targetAssetID = assetID;
                params.storageItemType = type === 'master' ? 'master,preview,thumbnail' : type;
                csApiSession.execute('com.censhare.api.dam.storageitem.delete', params).then(() => {
                    widgetInstance.acquireWidgetService('csAssetPreviewContextService', assetID)
                        .then((widgetService) => {
                            widgetService.getAssetContextEventEmitter().emit('storageItemRemoved');
                        });
                }, function(error) {
                    csNotify.warning('csDynamicAssetFileListWidget.delete', error);
                });
            });
        };

        function downloadViaDialog(item, _asset) {
            csAssetUtil.loadAssets(_asset).then(function(assets) {
                csAssetUtil.getDownloadItemsInformation(assets).then(function(res) {
                    if (!res.storageItemsInfo) {
                        return; // no storage-items found
                    }

                    if (res.storageItemsInfo[item.value.key]) {
                        res.storageItemsInfo[item.value.key].selected = true;
                    }

                    csDownloadFilesDialog(globalDialogManager, res.assets, res.storageItemsInfo, res.dynamicFormatsInfo).then(function(result) {

                        // collect data
                        const keys = [];
                        const types = [];
                        const dynamicFormatsTypes = [];

                        angular.forEach(result.assets, function(a) {
                            if (a.selected) {
                                keys.push(a.self);
                            }
                        });

                        angular.forEach(result.storageItemsInfo, function(_item) {
                            if (_item.selected) {
                                types.push(_item.type);
                            }
                        });

                        if (result.dynamicFormatsInfo) {
                            if (!angular.isArray(result.dynamicFormatsInfo)) {
                                this.result.dynamicFormatsInfo = [result.dynamicFormatsInfo];
                            }
                            angular.forEach(result.dynamicFormatsInfo, (_item) => {
                                if (_item.selected) {
                                    dynamicFormatsTypes.push(_item.key);
                                }
                            });
                        }

                        if (keys.length !== 0 && (types.length !== 0 || dynamicFormatsTypes.length > 0)) {
                            csApiSession.execute(CommandType.DOWNLOAD_STORAGE_FILES, {
                                assetRefs: keys,
                                types,
                                dynamicFormats: dynamicFormatsTypes,
                                usageRightsAccepted: true // explicit confirmation that the usage right
                                                          // were accepted
                            }).then(function(data) {
                                    if (data.url) {
                                        // Download the file, but do not write statistics, since those were
                                        // already written by the CommandHandler
                                        csDownloadUtils.downloadFile(data.url, data.fileName, false /*no
                                            statistics*/);
                                    }
                                },
                                function(error) {
                                    csNotify.warning('csAssetActions.downloadAsset', error);
                                });
                        } else {
                            csNotify.warning('csAssetActions.downloadAsset', 'csAssetActions.noselection');
                        }
                    });
                });
            });

        }

        $scope.context.checkUsageRights = function(e, item) {
            if (isRequireAcceptUsageRights(asset)) {
                downloadViaDialog(item, asset);
                e.stopPropagation();
                e.preventDefault();
            }
        };

        function isRequireAcceptUsageRights(_asset) {
            return !!_asset.traits.usage_rights && _asset.traits.usage_rights.usageRights.value !== 'all-rights';
        }

        $scope.$on('$destroy', function() {
            resultAdm.destroy();
            $scope.adm.destroy();
        });

        function updateContextFlavor(config) {
            let widgetSize;
            let defaultWidgetSize;

            if (widgetInstance.getProperties().listWidget &&
                !!widgetInstance.getProperties().listWidget.rowHeightDefault) {
                defaultWidgetSize = widgetInstance.getProperties().listWidget.rowHeightDefault;
            }
            widgetSize = config.listSize || defaultWidgetSize || '3';
            if (widgetSize === '3') {
                $scope.context.flavor = 'csDynamicAssetFileListWidgetItemRenderer';
            } else if (widgetSize === '2') {
                $scope.context.flavor = 'csDynamicAssetFileListWidgetItemRenderer_2rows';
            } else if (widgetSize === '1') {
                $scope.context.flavor = 'csDynamicAssetFileListWidgetItemRenderer_1row';
            } else {
                $scope.context.flavor = 'csDynamicAssetFileListWidgetItemRenderer';
            }
        }

        function setValues(_asset, si) {
            si.preview = $scope.uploadIcon;
            si.downloadUrl = csApiSession.session.resolveUrl(si.url() + '?config-file-name=true&download=true');
            if (si.key() === 'master') {
                si.downloadUrl += '&metadata-mapper=true';
            }
            si.fileSize = $filter('bytes')(si.filelength());
        }

        function loadStorageItems(value) {
            const _asset = csAssetUtil.assetRoot(value.data);
            const assetType = _asset.traits.type.type.value[0].value;
            const key = 'asset_typedef/asset_type/' + assetType;
            const masterData = value.data.container.meta.master_data;
            const tempItemList = [];
            const itemLoadPromises = [];
            let masterDataEntry;

            // Check permissions for showing buttons (or not)
            $scope.context.permissions.edit = !csAssetApplicationUtil.isReadOnly(value);
            $scope.context.permissions.export = true;
            csApiSession.permission.checkAssetPermission('all', _asset.self)
                .then(function(_value) {
                    const hasAllPermissions = !!(_value && _value.permission);
                    // If all permission is not there check for asset_export_all
                    if (!hasAllPermissions) {
                        return csApiSession.permission.checkAssetPermission('asset_export_all', _asset.self);
                    } else {
                        return { permission: true };
                    }
                })
                .then(function(_value) {
                    $scope.context.permissions.export = !!(_value && _value.permission);
                });

            // clear list
            resultAdm.setValue([]);
            $scope.itemCount = 0;

            $scope.hasFiles = false;
            for (masterDataEntry in masterData) {
                if (masterData[masterDataEntry].self === key) {
                    $scope.hasFiles = masterData[masterDataEntry].record.hasfiles === 1;
                }
            }

            csAssetUtil.getStorageItems(_asset).forEach(function(si) {
                let siCopy;
                const _key = si.key();

                if (_key === 'preview' || _key === 'text-preview' || _key === 'watermark-preview' ||
                    _key === 'thumbnail' || _key === 'watermark-thumbnail' || _key === 'xml-structure' ||
                    _key === 'content' || _key === 'dummy' || _key == 'pdf-drbk-x4' || _key == 'pdf-online') {
                    return;
                }

                if (_key === 'master') {
                    $scope.hasMaster = true;
                }

                siCopy = angular.copy(si);
                setValues(_asset, siCopy);
                siCopy.name = si.key(true);
                siCopy.mimetype = si.mimetype(true);
                siCopy.key = _key;

                tempItemList.push(siCopy);
            });

            // sort storage-items if more than one
            if (tempItemList.length > 1) {
                tempItemList.sort(storageItemComparator);
            }

            // Build list with generatable items
            // Note: The filename of the transformation result is created as:
            // <_asset ID>_<transformation_key>.<original_Extension>
            itemLoadPromises.push(
                csApiSession.resourceassets.lookup({
                    sourceAssetRef: _asset.self,
                    usage: 'censhare:file-drag'
                }).then(function (result) {
                    const loadMimetypePromises = [];
                    if (result && result.resourceAssets && result.resourceAssets.length > 0) {
                        const filteredResAssets = [];
                        loadMimetypePromises.push(csApiSession.execute('com.censhare.api.dam.sharelink.dynamicFormatsHandler',
                            { assetIDs: _asset.traits.ids.id.value[0].value }).then((dynamicFormatsInfo: any) => {
                                let _dynamicFormatsIds = [];
                                if (angular.isArray(dynamicFormatsInfo.dynamic_formats.dynamic_format)) {
                                    dynamicFormatsInfo.dynamic_formats.dynamic_format.forEach(_item => {
                                        _dynamicFormatsIds.push(_item.ID);
                                    });
                                } else {
                                    if (dynamicFormatsInfo.dynamic_formats.dynamic_format) {
                                        _dynamicFormatsIds = [dynamicFormatsInfo.dynamic_formats.dynamic_format.ID];

                                    }
                                }

                                result.resourceAssets.forEach(function (_resAsset) {
                                    if (_dynamicFormatsIds.includes(csAssetUtil.getAssetIdFromAssetRef(_resAsset.assetRef))) {
                                        filteredResAssets.push(_resAsset);
                                    }
                                });
                                filteredResAssets.forEach(function (resAsset) {
                                    resAsset.downloadUrl = buildDownloadURL(resAsset);
                                    resAsset.preview = $scope.uploadIcon;
                                    tempItemList.push(resAsset);
                                });
                            }));
                        }
                    return $q.all(loadMimetypePromises);
                })
            );

            // FS: Extension of dynamic generatable dynamic formats including filtering and applying name corresponding to the asset
            var dynamicFileListParams = {
                contextAsset: assetID
            };
            // allianz:resolve-dynamic-format
            var dynPromise = csApiSession.transformation('allianz:resolve-dynamic-format', dynamicFileListParams).then( function(result) {
                var tempStorageItem = result ? result.storageitem : null;
                var storageItems = angular.isArray(tempStorageItem) ? tempStorageItem : ( tempStorageItem ? [tempStorageItem] : []);
                console.log( "Dynamic Asset Storageitems SUCCESS: ");

                storageItems.forEach(function(storageItem) {

                    if( storageItem.icon ) {
                        storageItem.preview =  $scope.dynIcons[storageItem.icon];
                    }
                    if( !storageItem.preview ) {
                        storageItem.preview = $scope.uploadIcon;
                    }

                    var downloadURL = storageItem.storageUrl;
                    if (downloadURL.indexOf('?') > -1) {
                        downloadURL = downloadURL.replace('?', '?config-file-name=false&download=true&');
                    } else {
                        downloadURL += '?config-file-name=false&download=true&';
                    }
                    downloadURL += 'filename=' + storageItem.filename;
                    storageItem.downloadUrl = csApiSession.session.resolveUrl(downloadURL);

                    tempItemList.push(storageItem);
                } );
                console.log( storageItems );
            }, function(error) {
                console.log( "Dynamic Asset Storageitems ERROR: ");
                console.log( error );
            });

            itemLoadPromises.push(dynPromise);


            $q.all(itemLoadPromises).then(function() {
                resultAdm.setValue(tempItemList);
                widgetInstance.setCounter(tempItemList.length);

                $scope.itemCount = tempItemList.length;
            });
        }

        function storageItemComparator(si1, si2) {
            if (si1.key === 'master') {
                return -1;
            }
            if (si1.key < si2.key) {
                return -1;
            }
            if (si1.key > si2.key) {
                return 1;
            }
            return 0;
        }

        function buildDownloadURL(resAsset) {
            // currently I cannot see any use of the addition of "&metadata-mapper=true" for drag items
            // this could be done inside a drag transformation, ar, 2016-03-09
            let downloadURL = resAsset.urlTemplate;

            if (downloadURL.indexOf('?') > -1) {
                downloadURL = downloadURL.replace('?', '?config-file-name=true&download=true&');
            } else {
                downloadURL += '?config-file-name=true&download=true&';
            }
            downloadURL += 'transformation-name=' + resAsset.name;
            return csApiSession.session.resolveUrl(downloadURL);
        }

        function uploadProgress(value) {
            $scope.uploadProgressValue = value;
        }

        function uploadFailed(value) {
            csNotify.warning('File Upload', value);
            $scope.uploadProgress = false;
        }

        function dropFile(event) {
            if (!$scope.context.permissions.edit) {
                return;
            }
            csUploadsManager.checkMaximumSize(event.dataTransfer.files).then((_files: File[]) => {
                    if (_files.length > 0) {
                        if (_files.length === 1) {
                            widgetDataManager.uploadStart(csUploadsManager.addNewUploads(_files, uploadCommand, uploadParams));
                        }
                    }
            });
        }


        function onDragWindowEnter() {
            $scope.csDropzoneVisible = true;
            $scope.$digest();
        }

        function onDragWindowLeave() {
            $scope.csDropzoneVisible = false;
            $scope.$digest();
        }
    }
];

/**
 * Controller for config dialog
 */
const csDynamicAssetFileListWidgetConfigController = ['$scope', 'csSearchTransformationService', 'config',
    function($scope, csSearchTransformationService, config) {
        $scope.config = config;
        csSearchTransformationService.list().then(
            function(result) {
                $scope.transformations = result;
            }
        );
    }
];


export { csDynamicAssetFileListWidgetController, csDynamicAssetFileListWidgetConfigController };
