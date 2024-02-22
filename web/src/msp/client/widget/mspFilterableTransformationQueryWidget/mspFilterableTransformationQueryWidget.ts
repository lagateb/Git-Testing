import { IActionGroup }                                         from '@cs/client/base/csActions/csActionInterfaces';
import { IWidgetInstance }                                      from '@cs/client/frames/csMainFrame/csDefaultPages/default-pages.types';
import {
    IPageInstance,
}                                                               from '@cs/client/frames/csMainFrame/csWorkspaceManager/csPageRegistry/page-registry.types';
import { IcsApiSession }                                        from '@cs/framework/csApi/cs-api.model';
import { actionFactory }                                        from '@cs/client/base/csActions/csActionFactory';
import { groupedInjections }                                    from "@cs/framework/csApi/csUtils/csUtils";
import { IAbstractQueryDataManagerHeadless, IQueryDataManager } from "@cs/client/DAM/widgets/base/query-managers.factories";
import { ICommandPromise }                                      from "@cs/framework/csApi/csCommander/csCommander";

const refreshActionName = 'csRefreshWidgetAction';

interface IScope extends ng.IScope {
    widgetId: string;
    missingConfig: boolean;

    toolbarData: any;
    toolbarState: any;
    toolbarTransformationKey: string;
    toolbarOnChangeCallback: () => void;

    listFlavor: string;
    widgetConfiguration: () => void;
}

interface IMspFilterableDataManager extends IAbstractQueryDataManagerHeadless {
    liveQueryCommand(_query, _queryLivecycleContext): ICommandPromise<any>;

    setQueryParams(params: any[]): void;
}

class MspFilterableTransformationQueryWidgetHeadless {
    public static $name: string     = 'mspFilterableTransformationQueryWidgetHeadless';
    public static $inject: string[] = ['widgetInstance', 'pageInstance', 'csQueryDataManager',
        'csApiSession', 'csServices', 'csViewNameResolver', '$timeout'];

    private timer: any;

    constructor(widgetInstance: IWidgetInstance, pageInstance: IPageInstance, csQueryDataManager,
                csApiSession: IcsApiSession, private csServices, private csViewNameResolver, private $timeout) {
        let commandPromise;

        const queryDM = new csQueryDataManager({
            query:                 {}, // Init datamanger with overwritten query command
            queryLivecycleContext: pageInstance,
        });

        const queryManager = this.extendQueryManager(queryDM, widgetInstance) as any;

        queryManager.liveQueryCommand = function (_query, _queryLivecycleContext) {
            // @ts-ignore ignore invalid Interface
            commandPromise = csApiSession.command.liveQuery('com.mspag.api.query.FilterableQueryAsset', _query, _queryLivecycleContext);
            return commandPromise;
        };

        queryManager.setViewLimit = (newViewLimit) => {
            if (commandPromise && newViewLimit !== queryManager.viewLimitReader.getValue()) {
                commandPromise.notify('setViewLimit', { limit: newViewLimit });
            }
        };

        queryManager.setOffset = (newOffset) => {
            if (commandPromise && newOffset !== queryManager.offsetReader.getValue()) {
                commandPromise.notify('setOffset', { offset: newOffset });
            }
        };

        queryManager.setQueryParams = (params) => {
            this.callDelayed(() => {
                // wrap into another level (param) to ensure an array like structure for backend
                commandPromise.notify('queryParams', { params: { param: params } });
            }, 600);
        };

        return queryManager;
    }

    // Copy of csQueryDataManagerViewNameExtended with some edits
    private extendQueryManager(queryDataManager: IQueryDataManager, widgetInstance: IWidgetInstance): IAbstractQueryDataManagerHeadless {
        const csViewNameResolver      = this.csViewNameResolver;
        const listFlavorObservable    = this.csServices.createObservable(null);
        const contextFlavorObservable = this.csServices.createObservable(null);
        const originalDoQueryFunction = queryDataManager.doQuery;

        let currentFlavorViewName: string;

        function widgetConfigUpdateHandler(config) {
            let defaultWidgetSize;
            if (widgetInstance.getProperties().listWidget && !!widgetInstance.getProperties().listWidget.rowHeightDefault) {
                defaultWidgetSize = widgetInstance.getProperties().listWidget.rowHeightDefault;
            }
            const widgetSize: string = config.listSize || defaultWidgetSize || '3';

            let newFlavorViewName: string;
            const flavor: string = csViewNameResolver.getFlavorFromRowHeight(widgetSize);
            contextFlavorObservable.setValue(flavor);
            if (config.customView) {
                newFlavorViewName = config.customView;
            } else {
                // auto calculated viewName for a widget size
                newFlavorViewName = csViewNameResolver.getViewFromFlavor(flavor);
            }
            if (currentFlavorViewName !== newFlavorViewName) {
                const query = queryDataManager.getQuery();

                if (query) {
                    // todo kko investigate
                    queryDataManager.doQuery(); // reset old query settings
                }

                currentFlavorViewName = newFlavorViewName;
                queryDataManager.doQuery(query);
            }
        }

        // overwrite the doQuery function to add viewName for each query
        queryDataManager.doQuery = function extendedDoQueryWithFlavorChecking(newQuery) {
            if (newQuery) {
                // add view values if query is set later
                newQuery.view       = newQuery.view || {};
                // default view transformation, always used
                newQuery.view.trafo = newQuery.view.trafo || 'censhare:cs5.query.asset.list';
                // always set viewName if available
                if (currentFlavorViewName) {
                    newQuery.view.viewName = currentFlavorViewName;
                }
            }

            originalDoQueryFunction(newQuery);
        };

        // all setup, now register and fire widgetConfigUpdateHandler
        widgetInstance.getConfig().registerChangeListenerAndFire(widgetConfigUpdateHandler);

        return { ...queryDataManager, listFlavorObservable, contextFlavorObservable };
    }

    private callDelayed(call: () => void, delay: number): void {
        if (this.timer) {
            this.$timeout.cancel(this.timer);
            this.timer = null;
        }

        // send with a delay to let user might finish typing
        this.timer = this.$timeout(() => {
            call();
        }, delay, false);
    }

}

@groupedInjections
class MspFilterableTransformationQueryWidgetController implements ng.IComponentController {
    public static $name: string     = 'mspFilterableTransformationQueryWidgetController';
    public static $inject: string[] = ['$scope', 'csAbstractAssetListWidgetController', 'pageInstance', 'widgetInstance',
        'csWidgetConfigDialog', 'widgetDataManager'];

    private getDependencies: () => {
        $scope: IScope,
        csAbstractAssetListWidgetController,
        pageInstance: IPageInstance,
        widgetInstance: IWidgetInstance,
        csWidgetConfigDialog,
        widgetDataManager
    };
    private actions: IActionGroup;
    private queryManager: IMspFilterableDataManager;
    private assetId: string;
    private transformationKey: any;
    private initLimit: number;
    private widgetConfig: any;
    private initSearch = true;

    constructor() {
        //@ts-ignore hack for having groupedInjections
        this.onInjectionsGrouped(this.init);
    }

    public init() {
        const {
                  $scope,
                  csAbstractAssetListWidgetController,
                  pageInstance,
                  widgetInstance,
                  csWidgetConfigDialog,
                  widgetDataManager,
              } = this.getDependencies();

        $scope.widgetId = widgetInstance.getIdEscaped();
        this.actions    = widgetInstance.getOrCreateTitleActions();

        // add refresh action for query manager
        this.actions.addChildAfter(actionFactory.action(() => {
            this.runQuery();
        }).setTitle('csCommonTranslations.refresh').setIcon('cs-icon-refresh').setName(refreshActionName).hide());

        this.queryManager = widgetDataManager;

        widgetInstance.setTitle('mspFilterableTransformationQueryWidget.title');

        if (pageInstance.getPathContextReader() && pageInstance.getPathContextReader().getValue()) {
            this.assetId = pageInstance.getPathContextReader().getValue().get('id');
        }

        // widget configuration button in empty state
        $scope.widgetConfiguration = function () {
            csWidgetConfigDialog(widgetInstance);
        };

        $scope.toolbarData             = {};
        $scope.toolbarState            = {
            initialized: true,
        };
        $scope.toolbarOnChangeCallback = this.toolbarOnChangeCallback.bind(this);

        // remove liveQuery when widget is not visible
        $scope.$on('$destroy', this.queryManager.destroy);

        $scope.listFlavor = 'csVirtualListRender';
        this.queryManager.listFlavorObservable.setValue($scope.listFlavor);
        this.queryManager.totalCountReader.registerChangeListenerAndFire(widgetInstance.setCounter, $scope);

        widgetInstance.getConfig().registerChangeListenerAndFire(this.configListener.bind(this), $scope);

        widgetInstance.getDimensions().registerChangeListener(this.dimensionsListener.bind(this), $scope);

        csAbstractAssetListWidgetController({
            $scope:            $scope,
            widgetInstance:    widgetInstance,
            widgetDataManager: this.queryManager,
            context:           {},
        });
    }

    public configListener(config) {
        const { $scope, widgetInstance } = this.getDependencies();

        this.widgetConfig = config;
        if (config && config.transformationKey) {
            this.transformationKey = config.transformationKey;
            $scope.missingConfig   = false;

            if (config.toolbarTransformationKey) {
                $scope.toolbarTransformationKey = config.toolbarTransformationKey;
            }

            // enable refresh action
            this.actions.findChildForName(refreshActionName).show();

            this.dimensionsListener(widgetInstance.getDimensions().getValue());

            if ($scope.toolbarData) {
                this.toolbarOnChangeCallback();
            }
        } else {
            $scope.missingConfig = true;
            widgetInstance.setCounter();
        }
    }

    public dimensionsListener(dimensions) {
        let heightRatio;
        if (!this.widgetConfig) {
            return;
        }
        if (Number(this.widgetConfig.listSize) === 3) {
            heightRatio = 2.8;
        } else if (Number(this.widgetConfig.listSize === 2)) {
            heightRatio = 3.9;
        } else if (Number(this.widgetConfig.listSize === 1)) {
            heightRatio = 4.1;
        }

        this.initLimit = Math.round(dimensions.height * heightRatio - 2);
        this.runQuery();
    }

    public toolbarOnChangeCallback(): void {
        const { $scope } = this.getDependencies();
        // only support the queryParams method
        if ($scope.toolbarData) {
            const params = this.getToolbarParameters();

            this.queryManager.setQueryParams(params);
        }
    }

    private getToolbarParameters(): any[] {
        const { $scope } = this.getDependencies();
        let params = [];
        if ($scope.toolbarData) {
            Object.keys($scope.toolbarData).forEach((valueKey) => {
                if (valueKey !== 'filterGroupByOptions') {
                    params.push({ key: valueKey, value: $scope.toolbarData[valueKey] });
                }
            });
            $scope.toolbarData.isManualSortingEnabled = this.widgetConfig.isManualSortingEnabled;
            if ($scope.toolbarData.isManualSortingEnabled) {
                params = params.filter((p) => p.key !== 'filterGroupBy' || p.key !== 'groupModeType');
                params.push({ key: 'filterGroupBy', value: 'censhare:asset-rel' });
                params.push({ key: 'relationType', value: this.widgetConfig.manualSortingRelations });
            }
        }
        return params;
    }

    private runQuery() {
        if (this.widgetConfig && this.transformationKey) {
            // Empty query
            this.queryManager.doQuery();
            let queryObj = {
                command:  this.queryManager.liveQueryCommand,
                searchId: this.transformationKey,
                context:  this.assetId,
                view:     {
                    trafo: 'censhare:cs5.query.asset.list',
                },
                params: {
                    param: this.getToolbarParameters()
                }
            };
            if (this.initSearch) {
                // After the first search the limit is choosen by the virtual list renderer
                this.initSearch   = false;
                queryObj["limit"] = this.initLimit;
            }
            this.queryManager.doQuery(queryObj);
        }
    }
}

/**
 * Controller for config dialog
 */
@groupedInjections
class MspFilterableTransformationQueryWidgetConfigController implements ng.IComponentController {
    public static $name: string     = 'mspFilterableTransformationQueryWidgetConfigController';
    public static $inject: string[] = ['$scope', 'config', 'csApiSession'];
    private getDependencies: () => {
        $scope;
        config;
        csApiSession: IcsApiSession;
    };

    constructor() {
        //@ts-ignore hack for having groupedInjections
        this.onInjectionsGrouped(this.init);
    }

    public init(): void {
        const { $scope, config } = this.getDependencies();
        $scope.config            = config;
        this.getResourceAssetsByType('module.search.transformation.')
            .then((result) => $scope.transformations = result.resourceAssets)
            .catch(this.catchPromiseFailure);

        // load resource assets for toolbar transformations
        this.getResourceAssetsByUsage('censhare:toolbar-transformation').then((result) => {
            if (result && result.resourceAssets) {
                $scope.toolbarTransformations = [].concat(result.resourceAssets);
            }
        });
    }

    private getResourceAssetsByType(assetType: string): ng.IPromise<any> {
        const { csApiSession } = this.getDependencies();
        return csApiSession.resourceassets.lookup({
            assetType: assetType,
        });
    }

    private getResourceAssetsByUsage(usage: string): ng.IPromise<any> {
        const { csApiSession } = this.getDependencies();
        return csApiSession.resourceassets.lookup({
            usage: usage,
        });
    }

    private catchPromiseFailure = (error) => {
        throw error;
    };
}

export {
    MspFilterableTransformationQueryWidgetHeadless,
    MspFilterableTransformationQueryWidgetController,
    MspFilterableTransformationQueryWidgetConfigController,
};
