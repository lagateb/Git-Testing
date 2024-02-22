import * as censhare from 'censhare';

import {AllianzDownloadTextPdfAction} from "./allianz-download-text-pdf-action.constant";
import {allianzDownloadTextPdfDialogModule} from "./allianzDownloadTextPdfDialog/allianz-download-text-pdf-dialog.module";

export const allianzDownloadTextPdfActionModule: string = censhare
    .module('allianzDownloadTextPdfAction', [
        allianzDownloadTextPdfDialogModule
    ])
    .constant('allianzDownloadTextPdfBehavior', AllianzDownloadTextPdfAction)
    .name;
