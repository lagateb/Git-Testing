import * as censhare from 'censhare';

import { csAssetInfoApplicationControllerModule } from '../../../ng1/client/DAM/widgets/assetInfo/cs-asset-info-application-controller.module';
import { csFiltersModule } from '../../../ng1/framework/filters/cs-filters.module';
import { csDndModule } from '../../../ng1/client/DAM/shared/directive/cs-dnd/cs-dnd.module';
import { csConfirmDialogModule } from '../../../ng1/client/frames/csMainFrame/csDefaultPages/csConfirmDialog/cs-confirm-dialog.module';
import { csAssetApplicationsModule } from '../../../ng1/client/DAM/base/csAssetApplications/asset-application.module';
import { csItemRendererModule } from '../../../ng1/client/base/csItemRenderer/item-renderer.module';
import { behaviorsModule } from '../../../ng1/client/base/csBehaviors/behaviors.module';

import { csDynamicAssetFileListWidgetController, csDynamicAssetFileListWidgetConfigController } from './dynamic-asset-file-list-widget.controller';
import { csDynamicAssetFileListWidgetManager } from './dynamic-asset-file-list-widget-manager.constant';

export const csDynamicAssetFileListWidgetModule: string = censhare.module('csDynamicAssetFileListWidget', [
        csAssetInfoApplicationControllerModule,
        csFiltersModule,
        csDndModule,
        csConfirmDialogModule,
        csAssetApplicationsModule,
        csItemRendererModule,
        behaviorsModule
])
    .constant('csDynamicAssetFileListWidgetManager', csDynamicAssetFileListWidgetManager)
    .controller('csDynamicAssetFileListWidgetController', csDynamicAssetFileListWidgetController)
    .controller('csDynamicAssetFileListWidgetConfigController', csDynamicAssetFileListWidgetConfigController)

    .name;
