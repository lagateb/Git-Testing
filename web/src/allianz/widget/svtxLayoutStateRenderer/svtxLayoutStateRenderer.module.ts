import * as censhare from 'censhare';

import { csItemRendererModule } from '../../../ng1/client/base/csItemRenderer/item-renderer.module';

import { svtxLayoutStateRendererController } from './svtxLayoutStateRenderer.controller';

export const svtxLayoutStateRendererModule: string = censhare
    .module('svtxLayoutStateRenderer', [ csItemRendererModule])
    .controller('svtxLayoutStateRendererController', svtxLayoutStateRendererController)
    .name;
