import * as censhare from 'censhare';

import { csSCS3RendererModule } from '@cs/client/W2P/contentEditor/SCS3/scs3-renderer.module';

import { csContentEditorRendererModule } from '@cs/client/W2P/contentEditor/renderer/cs-content-editor-renderer.module';

import { svtxSCS3ImageRendererHeadlessDataManager } from './svtxSCS3ImageRenderer';


export const svtxSCS3ImageRendererModule: string = censhare
    .module('svtxSCS3ImageRenderer', [ csSCS3RendererModule, csContentEditorRendererModule ])
    .constant('svtxSCS3ImageRendererHeadlessDataManager', svtxSCS3ImageRendererHeadlessDataManager)
    .name;
