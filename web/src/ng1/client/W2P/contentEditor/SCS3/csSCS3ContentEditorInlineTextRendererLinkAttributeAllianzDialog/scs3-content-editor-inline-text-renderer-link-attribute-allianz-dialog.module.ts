import * as censhare from 'censhare';

import { csContentEditorViewModelModule } from '@cs/client/W2P/contentEditor/csContentEditorViewModel/cs-content-editor-view-model.module';

import {
    csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog,
    csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialogController
} from './csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog';

export const csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialogModule: string = censhare
    .module('csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog', [ csContentEditorViewModelModule ])
    .constant('csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog', csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialog)
    .controller('csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialogController', csSCS3ContentEditorInlineTextRendererLinkAttributeAllianzDialogController)
    .name;
