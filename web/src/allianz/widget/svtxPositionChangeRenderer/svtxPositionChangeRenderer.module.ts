import * as censhare from 'censhare';

import { csItemRendererModule } from '../../../ng1/client/base/csItemRenderer/item-renderer.module';

import { svtxPositionChangeRendererController } from './svtxPositionChangeRenderer.controller';

export const svtxPositionChangeRendererModule: string = censhare
    .module('svtxPositionChangeRenderer', [ csItemRendererModule])
    .controller('svtxPositionChangeRendererController', svtxPositionChangeRendererController)
    .name;
