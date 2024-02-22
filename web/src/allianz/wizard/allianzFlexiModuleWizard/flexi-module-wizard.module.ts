import * as censhare from 'censhare';

import {FlexiModuleWizardController} from "./flexi-module-wizard.controller";
import {flexiModuleChooseProduct} from "./choose-product.component";
import {flexiModuleChooseType} from "./choose-type.component";
import {flexiModuleChooseModule} from "./choose-module.component";
import {flexiModuleOverview} from "./overview.component";
import {FlexiModuleWizardAssetOpenAction} from "./flexi-module-wizard.constant";
import {flexiModuleChooseSettings} from "./choose-settings.component";

export const flexiModuleWizardModule: string = censhare.module('allianzFlexiModuleWizard', [])
    .controller(FlexiModuleWizardController)
    .component('flexiModuleChooseProduct', flexiModuleChooseProduct)
    .component('flexiModuleChooseType', flexiModuleChooseType)
    .component('flexiModuleChooseModule', flexiModuleChooseModule)
    .component('flexiModuleChooseSettings', flexiModuleChooseSettings)
    .component('flexiModuleOverview', flexiModuleOverview)
    .constant('allianzFlexiModuleWizardAssetCreateBehavior', FlexiModuleWizardAssetOpenAction).name;

