/*
 * Copyright (c) by censhare AG
 */
import { IScope } from 'angular';
import { ITableColumn, ITableComponentConfig, ITableRow, ITableRowBehavior, } from '../../../../framework/ui-controls/csAssetTableControl/cs-asset-table-control.component.d';
import { TableWidgetDataManager } from './table-widget-headless.constant';
import { IWidgetInstance } from '../../../frames/csMainFrame/csDefaultPages/default-pages.types';
import { TableManager } from '../../../../framework/ui-controls/csAssetTableControl/cs-asset-table-control-abstract-manager';
import { TableWidgetService } from './services/table-widget-service.constant';
import { groupedInjections } from '../../../../framework/csApi/csUtils/csUtils';
import { INotify } from '../../../frames/csMainFrame/notifications/csNotify/notify';
import { IcsApiSession } from '../../../../framework/csApi/cs-api.model';
import { TableControlUtils } from '../../../../framework/ui-controls/csAssetTableControl/cs-asset-table-control-utils';
import { IDropDataInfo, ITableWidgetConfig, } from './table-widget.model';
import template from './table-widget.component.html';
import { IDialogManager } from '../../../frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types';

const ASSET_TABLE_CONFIG: ITableComponentConfig = {
    notifications: true,
    rows: {
        draggable: true,
        hierarchical: true
    },
    columns: {
        sorting: true,
        resizing: true
    }
};

@groupedInjections
class TableWidgetCtrl implements ng.IComponentController {
    public static $inject: string[] = [
        '$scope',
        'csServices',
        'widgetDataManager',
        'csWidgetConfigDialog',
        'widgetInstance',
        'csNotify',
        'csTranslate',
        'csApiSession',
        'csBehaviorUtil',
        'csUserPreferencesManager',
        'csAssetTableSortDialog',
        'dialogManager',
        '$window',
    ];

    public tableConfig: ITableComponentConfig = ASSET_TABLE_CONFIG;
    public tableManagerReader: csServices.IReader<TableManager>;
    public dirtyConfig: boolean = false;
    public widgetConfig: ITableWidgetConfig = null;
    public toolbarData: any = {};
    public toolbarState: any = {};
    public widgetId: string;
    public groupPageColumnConfig: ITableColumn[];

    private getDependencies: () => {
        $scope: IScope;
        csServices: csServices.IcsServicesService;
        widgetDataManager: TableWidgetDataManager;
        csWidgetConfigDialog: any; // ADD TYPE
        widgetInstance: IWidgetInstance;
        csNotify: INotify;
        csTranslate: any;
        csApiSession: IcsApiSession;
        csBehaviorUtil: any;
        csUserPreferencesManager: any;
        csAssetTableSortDialog: any;
        dialogManager: Promise<IDialogManager>;
        $window: ng.IWindowService;
    };
    private configChangeListener = (config: ITableWidgetConfig): void => {
        if (config !== this.widgetConfig && this.widgetConfig) {
            this.dirtyConfig = true;
        }

        this.widgetConfig = (config.tableId && config.rootQueryId) ? config : null;
        if (this.toolbarData) {
            this.toolbarOnChangeCallback();
        }
    }

    public $onInit(): void {
        const { $scope, csServices, widgetDataManager, widgetInstance } = this.getDependencies();
        this.tableManagerReader = csServices.createObservable(widgetDataManager.tableManager).reader;
        widgetInstance.getConfig().registerChangeListenerAndFire(this.configChangeListener);
        widgetInstance.acquireWidgetService('csTableWidgetService', '').then((widgetService: TableWidgetService) => {
            widgetService.setSelectionManager(widgetDataManager.selectionManager);
            widgetService.setTableWidget(widgetInstance);
        });

        this.widgetId = widgetInstance.getIdEscaped();
        // would be nice to set types on drop-interface which we got from widgetDataManager.widgetRelationInfo

        if (widgetDataManager.contextAssetId) {
            this.toolbarData.contextAsset = widgetDataManager.contextAssetId;
        }

        $scope.$on('cs:table-widget-modify', (event, arg) => {
            if (arg) {
                setTimeout(() => {
                    widgetDataManager.tableManager.callProcedure('refreshAsset', {
                        id: arg
                    });
                }, 100); // must be delayed
            }
            event.stopPropagation();
        });
        this.toolbarState = {
            initialized: false
        };
    }

    public $doCheck(): void {
        if (!this.groupPageColumnConfig && this.toolbarState.initialized) {
            if (this.tableManagerReader.getValue().getColumnsConfig().length) {
                this.setGroupByOptions();
            }
        }
    }

    public $onDestroy(): void {
        const { widgetInstance } = this.getDependencies();
        widgetInstance.getConfig().unregisterChangeListener(this.configChangeListener);
        widgetInstance.acquireWidgetService('csTableWidgetService', '').then((widgetService: TableWidgetService) => {
            widgetService.onDestroy();
        });
    }

    public errorEventHandler(event: any): void {
        const { csTranslate, csNotify } = this.getDependencies();
        let message = '<div>' + csTranslate.instant(event.message) + '</div>';
        if (angular.isArray(event.details)) {
            message += '<ul>';
            event.details.forEach((detail) => {
                message += '<li>' + detail + '</li>';
            });
            message += '</ul>';
        }
        csNotify.failure('csCommonTranslations.error', message);
    }

    public toolbarOnChangeCallback(): void {
        const { widgetDataManager } = this.getDependencies();
        // only support the queryParams method
        if (this.toolbarData) {
            let params = [];
            Object.keys(this.toolbarData).forEach((valueKey) => {
                if (valueKey !== 'filterGroupByOptions') {
                    params.push({ key: valueKey, value: this.toolbarData[valueKey] });
                }
            });
            this.toolbarData.isManualSortingEnabled = this.widgetConfig.isManualSortingEnabled;
            if (this.toolbarData.isManualSortingEnabled) {
                params = params.filter((p) => p.key !== 'filterGroupBy' || p.key !== 'groupModeType');
                params.push({ key: 'filterGroupBy', value: 'censhare:asset-rel' });
                params.push({ key: 'relationType', value: this.widgetConfig.manualSortingRelations });
            }

            widgetDataManager.setQueryParams(params);
        }
    }

    public onDrop(event: DragEvent, sourceNodeId: any): void {
        const { widgetDataManager, csApiSession, csNotify } = this.getDependencies();
        const dataTransfer: DataTransfer = event.dataTransfer;
        const sourceAssetId: number = TableControlUtils.getAssetIdFromNodeId(sourceNodeId);

        // for dropped asset, not file
        if (dataTransfer.files.length === 0) {
            const droppedInfoList: IDropDataInfo[] = widgetDataManager.getDroppedAssetInfoList(dataTransfer);
            droppedInfoList.forEach((droppedInfo) => {
                this.addRelation(droppedInfo, sourceAssetId, widgetDataManager, csApiSession, csNotify);
            });
        } else {
            csNotify.info('Drag and Drop of files is not supported yet', '');
        }
    }


    private addRelation(droppedInfo: IDropDataInfo, sourceAssetId: number, widgetDataManager: TableWidgetDataManager, csApiSession: IcsApiSession, csNotify: INotify) {
        if (droppedInfo) {
            if (sourceAssetId !== droppedInfo.assetId) {
                widgetDataManager.getWidgetRelationInfo().then((relations) => {
                    csApiSession.asset.get(sourceAssetId).then((result) => {
                        if (result && result.container.length) {
                            const sourceAssetType = result.container[0].asset.traits.type.type;
                            widgetDataManager.filteredRelations(relations, droppedInfo, sourceAssetType).then((filteredRelations) => {
                                widgetDataManager.addNewRelation(filteredRelations, (relation) => {
                                    csApiSession.relation.add(sourceAssetId, droppedInfo.assetId, relation.relationKey, relation.direction);
                                });
                            });
                        }
                    });
                });
            }

        } else {
            csNotify.warning('Drop asset failed', 'The drop event contained no asset-id');
        }
    }

    public onRowDoubleClick(row): void {
        const { $scope, csBehaviorUtil } = this.getDependencies();
        const tableId = this.widgetConfig.hasOwnProperty('tableId') ? this.widgetConfig.tableId : '';
        if (tableId !== 'svtx:table_template_allianz_published_medias') {
            csBehaviorUtil.openAssetPageByAssetId(TableControlUtils.getLastAssetIdFromAssetIdString(row.rowId), $scope);
        }
    }

    public onSortRelationClick(row): void {
        const { csAssetTableSortDialog: dialog, dialogManager } = this.getDependencies();
        const { tableId } = this.widgetConfig;
        const behavior = this.getSortableProperties(row);

        if (behavior) {
            dialog.open(dialogManager, {
                behavior,
                tableId,
                assetId: row.rowId.split('/').splice(-2, 1),
                groupName: row.groupName,
            });
        }
    }

    public openWidgetConfiguration(): void {
        const { csWidgetConfigDialog, widgetInstance } = this.getDependencies();
        csWidgetConfigDialog(widgetInstance);
    }

    public reloadPage(): void {
        const { $window } = this.getDependencies();
        $window.location.reload();
    }

    private setGroupByOptions(): void {
        this.groupPageColumnConfig = this.tableManagerReader.getValue().getColumnsConfig();
        this.toolbarData.filterGroupByOptions = this.groupPageColumnConfig.filter((item) => item.sortKey);
    }

    private getSortableProperties(row: ITableRow): ITableRowBehavior {
        if (Array.isArray(row.behavior)) {
            return row.behavior.find((item) => item.type === 'SORTABLE');
        }
        return null;
    }
}

export const csTableWidgetComponent: ng.IComponentOptions = {
    template,
    controller: TableWidgetCtrl
};
