const csIncludeDialog = ['$compile', '$log', 'csDialogTemplateService', 'csIncludeDialogControllerService',
function($compile, $log, csDialogTemplateService, csIncludeDialogControllerService) {
    return {
        restrict: 'E',
        controller: ['$scope', '$element', '$attrs', '$controller', '$parse', 'csLocalInjector', 'csAssetUtil', function($scope, $element, $attrs, $controller, $parse, csLocalInjector, csAssetUtil) {
            let templateScope;
            let unwatch;
            let contextWatch;
            let options;

            function applyTemplate(template?) {
                let compiledContent;
                let ctrl;
                let application;
                let widgetInstance;
                let pageInstance;
                let dialogManager;
                let dialogInstance;

                // always destroy old-template if exists
                if (templateScope && angular.isFunction(templateScope.$destroy)) {
                    templateScope.$destroy();
                    templateScope = null;
                    $element.empty();
                }

                if (template) {
                    if (template.content) {
                        compiledContent = $compile(template.content);
                    } else {
                        return;
                    }

                    templateScope = $scope.$new();
                    compiledContent(templateScope, function(clonedElement) {
                        let loadedCallback;

                        $element.html(clonedElement);

                        // add anonymous controller function
                        if (template.controller) {
                            if (angular.isFunction(template.controller)) {
                                ctrl = template.controller;
                            } else {
                                ctrl = csIncludeDialogControllerService.create(template.controller, template.key);
                            }
                            if (ctrl) {
                                // load locals if available
                                application = csLocalInjector.getLocal('application');
                                widgetInstance = csLocalInjector.getLocal('widgetInstance');
                                pageInstance = csLocalInjector.getLocal('pageInstance');
                                dialogManager = csLocalInjector.getLocal('dialogManager');
                                dialogInstance = csLocalInjector.getLocal('dialogInstance');

                                $controller(ctrl, {
                                    $scope: templateScope,
                                    application: application,
                                    widgetInstance: widgetInstance,
                                    pageInstance: pageInstance,
                                    dialogManager: dialogManager,
                                    dialogInstance: dialogInstance
                                });
                            }
                        }

                        // check and call callback for on-template-loaded
                        if ($attrs.hasOwnProperty('onTemplateLoaded')) {
                            loadedCallback = $parse($attrs.onTemplateLoaded)($scope);
                            if (angular.isFunction(loadedCallback)) {
                                loadedCallback($element);
                            }
                        }
                    });
                }
            }

            /*
             * load template for resource-key
             */
            if ($attrs.key) {
                unwatch = $scope.$watch($attrs.key, function(key) {
                    let context;
                    let watchCcn;
                    let watchOptions;

                    if (key) {
                        if ($attrs.hasOwnProperty('default')) {
                            options = options || {};
                        }

                        /* svtx custom attribute */
                        if ($attrs.hasOwnProperty('svtxCustomParam')) {
                            /*$scope.svtxAssetId = $attrs.svtxAssetId;*/
                            $scope.svtxCustomParam = $parse($attrs.svtxCustomParam)($scope);
                        }

                        if (contextWatch) {
                            // unregister already watching asset
                            contextWatch();
                        }

                        if ($attrs.hasOwnProperty('default')) {
                            options = options || {};
                            options.defaultTemplateKey = $parse($attrs.default)($scope);
                        }

                        // if ($attrs.hasOwnProperty('options')) {
                        //     // XSLT options
                        //     options = options || {};
                        //     options.options = $parse($attrs.options)($scope);
                        // }

                        // context asset makes only sense for key (pointing to a xslt)
                        if ($attrs.contextAsset) {
                            options = options || {};
                            watchCcn = $attrs.hasOwnProperty('watchCcn');
                            watchOptions = $attrs.hasOwnProperty('options');

                            context = $parse($attrs.contextAsset)($scope);

                            // only add watcher on asset object
                            if (angular.isObject(context) && context.hasOwnProperty('self')) {
                                // watch for version changes on the asset object
                                contextWatch = $scope.$watch(function() {
                                    let value = '';
                                    context = $parse($attrs.contextAsset)($scope); // not same object
                                    // only watching the version (self), not whole asset object
                                    if (context) {
                                        if (watchCcn && context.traits && context.traits.versioning) {
                                            if (context.traits.versioning.ccn.value.length) {
                                                value = context.traits.versioning.ccn.value[0].value;
                                            } else {
                                                value = context.traits.versioning.ccn;
                                            }
                                        } else {
                                            // use combined current-version + version
                                            value = context.self + context.self_versioned;
                                        }
                                    }

                                    if (watchOptions) {
                                        options = options || {};
                                        options.options = $parse($attrs.options)($scope);
                                        value += JSON.stringify(options.options);
                                    }
                                    return value;
                                }, function(newValue) {
                                    if (newValue) {
                                        if (!context.traits.ids) {
                                            options.contextAsset = csAssetUtil.getAssetIdFromAssetRef(context.self);
                                        } else if (context.traits.ids.id.value && context.traits.ids.id.value.length) {
                                            options.contextAsset = context.traits.ids.id.value[0].value;
                                        } else {
                                            options.contextAsset = context.traits.ids.id;
                                        }
                                        csDialogTemplateService.load(key, options).then(applyTemplate);
                                    } else {
                                        applyTemplate();
                                    }
                                });
                            } else {
                                // just the asset-id
                                contextWatch = $scope.$watch(function() {
                                    let value = '';
                                    if (watchOptions) {
                                        options = options || {};
                                        options.options = $parse($attrs.options)($scope);
                                        value += JSON.stringify(options.options);
                                    }
                                    return value;
                                }, function(newValue) {
                                    if (newValue) {
                                        try {
                                            options.contextAsset = parseInt(context, 10);
                                            csDialogTemplateService.load(key, options).then(applyTemplate);
                                        } catch (e) {
                                            applyTemplate();
                                        }
                                    } else {
                                        applyTemplate();
                                    }
                                });

                            }
                        } else {
                            csDialogTemplateService.load(key, options).then(applyTemplate);
                        }
                    } else {
                        applyTemplate(); // remove existing
                    }
                });
            } else if ($attrs.template) {
                unwatch = $scope.$watch($attrs.template, function(template) {
                    if (template && !$attrs.hasOwnProperty('observe')) {
                        unwatch(); // stop watching after first template arrived
                    }

                    applyTemplate(template);
                });
            } else if ($attrs.assetType && $attrs.usage) {
                unwatch = $scope.$watch($attrs.assetType, function(type) {
                    if (type) {
                        if (!$attrs.hasOwnProperty('observe')) {
                            unwatch();
                        }

                        const resourceUsage = $parse($attrs.usage)($scope);
                        const defaultTemplate = $parse($attrs.default)($scope);
                        csDialogTemplateService.loadForAssetType(resourceUsage, type, defaultTemplate).then(applyTemplate);
                    } else {
                        applyTemplate(); // remove existing
                    }
                });
            } else {
                $log.warn('miss-use of cs-include-dialog: no matching attributes found to load a template');
            }
        }]
    };
}];

export { csIncludeDialog };
