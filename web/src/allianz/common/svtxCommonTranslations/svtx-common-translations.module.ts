import * as censhare from 'censhare';

import { csTranslateModule } from '@cs/framework/csApplication/csTranslate/translate.module';

export const svtxCommonTranslationsModule: string = censhare
    .module('svtxCommonTranslations', [csTranslateModule])
    .name;

