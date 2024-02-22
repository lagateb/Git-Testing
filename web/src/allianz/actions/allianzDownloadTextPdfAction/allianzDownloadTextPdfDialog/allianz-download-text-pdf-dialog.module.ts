import * as censhare from 'censhare';

import { AllianzDownloadTextPdfDialogService, allianzDownloadTextPdfComponent } from "./allianz-download-text-pdf-dialog.component";

export const allianzDownloadTextPdfDialogModule: string = censhare
    .module('allianzDownloadTextPdfDialog', [])
    .component('allianzDownloadTextPdfComponent', allianzDownloadTextPdfComponent )
    .service('allianzDownloadTextPdfDialog', AllianzDownloadTextPdfDialogService)
    .name;
