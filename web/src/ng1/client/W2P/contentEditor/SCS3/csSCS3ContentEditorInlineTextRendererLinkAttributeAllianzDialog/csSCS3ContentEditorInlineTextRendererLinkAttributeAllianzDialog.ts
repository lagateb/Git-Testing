import * as censhare from 'censhare';
import {
    ModalButtonViewFactory,
    ModalSubmitViewFactory
} from '@cs/client/frames/csMainFrame/csDialogs/csModalWindow/modal-window.component';
import { actionFactory } from '@cs/client/base/csActions/csActionFactory';
import { IDialogManager } from '@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types';
import { IActionGroup, IActionCallback } from '@cs/client/base/csActions/csActionInterfaces';

const xlink = 'http://www.w3.org/1999/xlink';
const assetRefUrl = 'censhare:///service/assets/asset/id/';

export const csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog =
    [function() {
        return {
            openDialog: function(dialogManagerPromise, model, elementRule) {
                const runAttributes = model.getSelectionAttributes().getValue()[elementRule.attribute] || [];
                const savedSelection = model.getTextSelection();
                const customActions = undefined;

                return dialogManagerPromise.then((dM: IDialogManager) => {
                        return dM.openNewDialog({
                            kind: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog',
                            dialogCssClass: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog',
                            actions: customActions,
                            data: {
                                elementRule: elementRule,
                                mixed: runAttributes === model.MIXED,
                                model: model,
                                savedSelection: savedSelection,
                                runAttributes: runAttributes,
                                activeView: 'url1'
                            }
                        });
                    }
                ).then(function(data) {
                    const attributes = data.runAttributes.filter(function(value) {
                        if (data.activeView === 'asset') {
                            return (value.name !== 'url');
                        }
                        if (data.activeView === 'url') {
                            return (value.name !== 'href' && value.name !== 'role');
                        }
                        if (data.activeView === 'url1') {
                            return (value.name !== 'href' && value.name !== 'role');
                        }
                        if (data.activeView === 'url2') {
                            return (value.name !== 'href' && value.name !== 'role');
                        }
                        if (data.activeView === 'url3') {
                            return (value.name !== 'href' && value.name !== 'role');
                        }
                    });

                    model.setTextSelection(savedSelection[0], savedSelection[1]);
                    model.setSelectionAttribute(elementRule.attribute, attributes);
                }).finally(function() {
                    model.setTextSelection(savedSelection[0], savedSelection[1]);
                    model.getRefocusTrigger().notify();
                });

            }
        };
    }
];

export const csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialogController =
    ['$scope', 'dialogInstance', 'dialogManager', 'csLocalInjector', 'csNotify', function($scope, dialogInstance, dialogManager, csLocalInjector, csNotify) {
        const result = dialogInstance.getResultObservable();
        const data = dialogInstance.getData();
        const elementRule = data.elementRule;
        const mixed = data.mixed;
        const model = data.model;
        const savedSelection = data.savedSelection;
        let runAttributes = data.runAttributes;

        if (mixed) {
            // get attributes from first run with attribute
            for (let i = savedSelection[0].index; i <= savedSelection[1].index; i += 1) {
                if (model.getRunAttributes(i)[elementRule.attribute]) {
                    runAttributes = model.getRunAttributes(i)[elementRule.attribute];
                    break;
                }
            }
            if (runAttributes === model.MIXED) {
                runAttributes = [];
            }
        }

        const deletePossible = function() {
            if (runAttributes) {
                let hasValues = false;
                runAttributes.forEach(function(attribute) {
                    if (attribute.value !== '' && attribute.name === 'href') {
                        hasValues = true;
                    }
                });

                if (hasValues) {
                    return true;
                }
            }
            return false;
        };

        const submitViewFactory = new ModalSubmitViewFactory(censhare.getInjector);
        const buttonViewFactory = new ModalButtonViewFactory(censhare.getInjector);
        const submitCallback: IActionCallback = () => {
            if (runAttributes.length > 0) {
                runAttributes.forEach(function(attribute) {
                    if (attribute.name === 'href' && attribute.namespace === xlink && attribute.value !== '') {

                        const assetRefAttr = assetRefUrl;
                        if (angular.isNumber(attribute.value) || attribute.value.indexOf(assetRefAttr) === -1) {
                            attribute.value = assetRefAttr + attribute.value;
                        }
                    }
                });
            }
            dialogManager.safeAndCloseDialog();
        };
        const cancelCallback: IActionCallback = () => {
            dialogManager.closeDialog();
        };
        const deleteCallback: IActionCallback = () => {
            dialogManager.closeDialog();
            model.setTextSelection(savedSelection[0], savedSelection[1]);
            model.clearSelectionAttribute(elementRule.attribute);
        };
        const submitAction = actionFactory.customCallbackAction(submitCallback, submitViewFactory)
            .setTitle('csCommonTranslations.ok');
        const cancelAction = actionFactory.customCallbackAction(cancelCallback, buttonViewFactory)
            .setTitle('csCommonTranslations.cancel');
        const deleteAction = actionFactory.customCallbackAction(deleteCallback, buttonViewFactory)
            .setTitle('csCommonTranslations.remove');

        deletePossible() ? deleteAction.show() : deleteAction.hide();

        const actions = dialogInstance.getActions() as IActionGroup;
        actions.addChildAfter(deleteAction);
        actions.addChildAfter(cancelAction);
        actions.addChildAfter(submitAction);

        if (!result.getValue()) {
            result.setValue(dialogInstance.getData());

            result.getValue().activeView = 'url1';
            if (result.getValue().runAttributes) {
                result.getValue().runAttributes.forEach(function(attribute) {
                    // initialise asset renderer with asset ID only
                    if (attribute.name === 'href' && attribute.namespace === xlink) {
                        const assetRefAttr = assetRefUrl;
                        if (attribute.value.indexOf(assetRefAttr) !== -1) {
                            attribute.value = attribute.value.replace(assetRefAttr, '');
                        }

                        $scope.myxlink = attribute;
                    }


                });
            }
        }

        csLocalInjector.add('dialogManager', dialogInstance.getDialogManager());

        $scope.mixed = result.getValue().mixed;

        $scope.setCurrentTabIndex = function(index) {
            $scope.currentTabIndex = index;
            result.getValue().activeView = $scope.currentTabIndex;
        };

        $scope.behaviors = filterBehaviors;
        initScope(result);
        $scope.$on('$destroy', () => actions.removeChildren());
        return;

        function filterBehaviors(behaviors) {
            const allowed = ['csOpenAssetPage', 'csAssetPreviewBehavior'];

            for (let i = behaviors.length - 1; i >= 0; i -= 1) {
                if (allowed.indexOf(behaviors[i].name) === -1) {
                    behaviors.splice(i, 1);
                }
            }
            if (!$scope.readOnly) {
                behaviors.push({
                    getName: function() {
                        return 'csAssetClearBehavior';
                    },
                    getActionAPI: function() {
                        return {
                            title: 'csContentEditorRenderer.clearTitle',
                            icon: 'cs-icon-close-cross',
                            callback: function() {
                                $scope.myxlink = undefined;
                            }
                        };
                    }
                });
            }
            return behaviors;
        }

        function getOrCreate(runAttrs, name) {
            let attribute = null;

            runAttrs.forEach(function(a) {
                if (a.name === name.name && a.namespace === name.namespace) {
                    attribute = a;
                }
            });

            if (!attribute) {
                runAttrs.push({
                    name: name.name,
                    namespace: name.namespace,
                    value: ''
                });

                return runAttrs[runAttrs.length - 1];
            }

            return attribute;
        }

        function createWatcher(obj) {
            $scope.$watch(obj.scopeProperty.name, function(newValue) {
                if (newValue !== undefined) {
                    if (angular.isString(newValue)) {
                        obj.node.value = newValue;
                    } else {
                        obj.node.value = (newValue !== null) ? newValue.value : '';
                    }
                }
            });
        }

        function createSelectWatchers() {
            $scope.$watch('selectedFollowOption1', function(newValue) {
                const property = $scope.qNodes.targetValue1;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });

            $scope.$watch('selectedFollowOption2', function(newValue) {
                const property = $scope.qNodes.targetValue2;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });
            $scope.$watch('selectedFollowOption3', function(newValue) {
                const property = $scope.qNodes.targetValue3;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });

/*
            $scope.$watch('selectedOpenInOption', function(newValue) {
                const property = $scope.qNodes.openValue;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });
*/
            $scope.$watch('selectedOpenInOption1', function(newValue) {
                const property = $scope.qNodes.openValue1;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });
            $scope.$watch('selectedOpenInOption2', function(newValue) {
                const property = $scope.qNodes.openValue2;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });
            $scope.$watch('selectedOpenInOption3', function(newValue) {
                const property = $scope.qNodes.openValue3;
                property.scopeProperty.value = newValue.value;
                property.node.value = newValue.value;
            });
        }

        function createXlinkWatcher(res) {
            $scope.$watch('myxlink', function(assetId) {
                res.runAttributes.forEach(function(attribute) {
                    if (attribute.name === 'href' && attribute.namespace === xlink) {
                        try {
                            attribute.value = assetId;
                        } catch (e) {
                            attribute.value = '';
                            csNotify.failure('An error occured!', 'Cannot reference asset.');
                        }
                    }

                    if (attribute.name === 'role' && attribute.namespace === xlink) {
                        let assetRoleAttr = 'censhare:///service/masterdata/asset_rel_typedef;key=';
                        let relationType;
                        try {
                            relationType = $scope.uiconfig.renderer.csContentEditorAssetRenderer.relation.type;
                        } catch (e) {
                        }
                        relationType = relationType || 'actual.';
                        if (assetRoleAttr.indexOf(relationType) === -1) {
                            assetRoleAttr = assetRoleAttr + relationType;
                        }
                        attribute.value = assetRoleAttr;
                    }
                });
            });
        }

        function initialize(res) {
            // initialise properties
            const map = Object.keys($scope.qNodes);
            angular.forEach(map, function(name) {
                const obj = $scope.qNodes[name];
                obj.node = getOrCreate(res.runAttributes, obj.qname);
                obj.scopeProperty.value = obj.node.value;
                $scope[obj.scopeProperty.name] = obj.node.value;

                if (name !== 'linkValue' && name !== 'roleValue') {
                    createWatcher(obj);
                } else {
                    createXlinkWatcher(res);
                }
            });

            const followValue1 = (angular.isObject($scope.qNodes.targetValue1.node) && $scope.qNodes.targetValue1.node.value !== '')
                ? $scope.qNodes.targetValue1.node.value
                : 'follow';


            const followValue2 = (angular.isObject($scope.qNodes.targetValue2.node) && $scope.qNodes.targetValue2.node.value !== '')
                ? $scope.qNodes.targetValue2.node.value
                : 'follow';


            const followValue3 = (angular.isObject($scope.qNodes.targetValue3.node) && $scope.qNodes.targetValue3.node.value !== '')
                ? $scope.qNodes.targetValue3.node.value
                : 'follow';
            /*
            const openValue = (angular.isObject($scope.qNodes.openValue.node) && $scope.qNodes.openValue.node.value !== '')
                ? $scope.qNodes.openValue.node.value
                : '_self';
            */
            const openValue1 = (angular.isObject($scope.qNodes.openValue1.node) && $scope.qNodes.openValue1.node.value !== '')
                ? $scope.qNodes.openValue1.node.value
                : '_self';
            const openValue2 = (angular.isObject($scope.qNodes.openValue2.node) && $scope.qNodes.openValue2.node.value !== '')
                ? $scope.qNodes.openValue2.node.value
                : '_self';
            const openValue3 = (angular.isObject($scope.qNodes.openValue3.node) && $scope.qNodes.openValue3.node.value !== '')
                ? $scope.qNodes.openValue3.node.value
                : '_self';


            $scope.selectedFollowOption1 = _getActiveOption(followValue1, $scope.followOptions1);
            $scope.selectedFollowOption2 = _getActiveOption(followValue2, $scope.followOptions2);
            $scope.selectedFollowOption3 = _getActiveOption(followValue3, $scope.followOptions3);
            //$scope.selectedOpenInOption = _getActiveOption(openValue, $scope.openInOptions);

            $scope.selectedOpenInOption1 = _getActiveOption(openValue1, $scope.openInOptions1);
            $scope.selectedOpenInOption2 = _getActiveOption(openValue2, $scope.openInOptions2);
            $scope.selectedOpenInOption3 = _getActiveOption(openValue3, $scope.openInOptions3);

            createSelectWatchers();

            // initialise tabs
            const activeView = (res.activeView !== undefined)
                ? res.activeView
                : 'url1';
            $scope.setCurrentTabIndex(activeView);
        }

        function _getActiveOption(value, options) {
            const r = options.filter(function(option) {
                if (option.value === value) {
                    return option;
                }
            });
            return r[0] || null;
        }

        function initScope(res) {
            const nodes = {
                linkValue: ['href', xlink, 'myxlink', ''],
                roleValue: ['role', xlink, 'roleValue', ''],
                //urlValue: ['url', '', 'urlValue', ''],
                //openValue: ['target', '', 'openValue', ''],
                urlFragmentValue: ['url-fragment', '', 'urlFragmentValue', ''],
                //titleSeoValue: ['seo-title', '', 'titleSeoValue', ''],
                //targetValue: ['follow', '', 'targetValue', ''],


                targetValue1: ['follow1', '', 'targetValue1', ''],
                targetValue2: ['follow2', '', 'targetValue2', ''],
                targetValue3: ['follow3', '', 'targetValue3', ''],

                urlValue1: ['url1', '', 'urlValue1', ''],
                urlValue2: ['url2', '', 'urlValue2', ''],
                urlValue3: ['url3', '', 'urlValue3', ''],
                titleSeoValue1: ['seo-title1', '', 'titleSeoValue1', ''],
                titleSeoValue2: ['seo-title2', '', 'titleSeoValue2', ''],
                titleSeoValue3: ['seo-title3', '', 'titleSeoValue3', ''],
                openValue1: ['target1', '', 'openValue1', ''],
                openValue2: ['target2', '', 'openValue2', ''],
                openValue3: ['target3', '', 'openValue3', ''],
            };

            const qNodes = {};

            for (const node in nodes) {
                if (nodes.hasOwnProperty(node)) {
                    const qname = {name: '', namespace: ''};
                    const scopeProperty = {name: '', value: ''};

                    [qname.name, qname.namespace, scopeProperty.name, scopeProperty.value] = nodes[node];
                    qNodes[node] = {qname, scopeProperty};
                }
            }

            $scope.qNodes = qNodes;

            $scope.openInOptions1 = [{
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.targetSame',
                value: '_self'
            }, {
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.targetNew',
                value: '_blank'
            }];
            $scope.openInOptions2 = [{
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.targetSame',
                value: '_self'
            }, {
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.targetNew',
                value: '_blank'
            }];
            $scope.openInOptions3 = [{
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.targetSame',
                value: '_self'
            }, {
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.targetNew',
                value: '_blank'
            }];

            $scope.followOptions1 = [{
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.followNo',
                value: 'no-follow'
            }, {
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.followYes',
                value: 'follow'
            }];

            $scope.followOptions2 = [{
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.followNo',
                value: 'no-follow'
            }, {
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.followYes',
                value: 'follow'
            }];

            $scope.followOptions3 = [{
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.followNo',
                value: 'no-follow'
            }, {
                key: 'csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.followYes',
                value: 'follow'
            }];



            initialize(res.getValue());
            //dialogInstance.setTitle('csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.linkDialogTitle');
            dialogInstance.setTitle('csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog.linkDialogTitle')
        }
    }
];
