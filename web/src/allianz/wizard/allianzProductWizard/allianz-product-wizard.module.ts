import * as censhare from 'censhare';

import { allianzProductWizardStep1 } from './allianz-product-wizard-step1.component';
import { allianzProductWizardStep2 } from './allianz-product-wizard-step2.component';
import { allianzProductWizardStep4 } from './allianz-product-wizard-step4.component';
import { allianzProductWizardStep5 } from './allianz-product-wizard-step5.component';
import { AllianzProductWizardController } from './allianz-product-wizard.controller';
import { AllianzProductWizardOpenAction } from './allianz-product-wizard-open-action.constant';
import {allianzProductWizardRecurringModulesStep} from "./allianz-product-wizard-recurring-modules-step.component";

export const allianzProductWizardModule: string = censhare
    .module('allianzProductWizard', [])
    .controller(AllianzProductWizardController)
    .component('allianzProductWizardStep1', allianzProductWizardStep1)
    .component('allianzProductWizardStep2', allianzProductWizardStep2)
    .component('allianzProductWizardStep4', allianzProductWizardStep4)
    .component('allianzProductWizardRecurringModules', allianzProductWizardRecurringModulesStep)
    .component('allianzProductWizardStep5', allianzProductWizardStep5)
    .constant('allianzProductWizardCreateBehavior', AllianzProductWizardOpenAction)
    .name;