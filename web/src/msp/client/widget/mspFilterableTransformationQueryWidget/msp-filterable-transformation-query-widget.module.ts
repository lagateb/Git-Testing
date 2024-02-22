import * as censhare from 'censhare';

import { csBasicWidgetUtilsModule }      from '@cs/client/DAM/widgets/base/basic-widget-utils.module';
import { csQueryAssetDataManagerModule } from '@cs/client/base/query/csQueryAssetDataManager/query-asset-data-manager.module';

import {
    MspFilterableTransformationQueryWidgetConfigController,
    MspFilterableTransformationQueryWidgetController,
    MspFilterableTransformationQueryWidgetHeadless,
}                                            from './mspFilterableTransformationQueryWidget';
import { csTransformationQueryWidgetModule } from "@cs/client/DAM/widgets/assetList/csTransformationQueryWidget/transformation-query-widget.module";

export const mspFilterableTransformationQueryWidgetModule: string = censhare
    .module('mspFilterableTransformationQueryWidget', [
        csBasicWidgetUtilsModule,
        csQueryAssetDataManagerModule,
        csTransformationQueryWidgetModule
    ])
    .constant(MspFilterableTransformationQueryWidgetHeadless)
    .controller(MspFilterableTransformationQueryWidgetController)
    .controller(MspFilterableTransformationQueryWidgetConfigController)
    .name;
