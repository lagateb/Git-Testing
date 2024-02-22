import * as censhare from 'censhare';

import { allianzPowerpointWizardStep1 } from "./allianz-powerpoint-wizard-step1.component";
import { allianzPowerpointWizardStep2 } from "./allianz-powerpoint-wizard-step2.component";
import { allianzPowerpointWizardStep3 } from "./allianz-powerpoint-wizard-step3.component";
import { allianzPowerpointWizardStep4 } from "./allianz-powerpoint-wizard-step4.component";
import { allianzPowerpointWizardStep5 } from "./allianz-powerpoint-wizard-step5.component";
import { AllianzPowerpointWizardOpenAction} from "./allianz-powerpoint-wizard-open-action.consant";
import { AllianzPowerpointWizardController} from "./allianz-powerpoint-wizard.controller";

export const allianzPowerpointWizardModule: string = censhare.module('allianzPowerpointWizard', [])
    .controller(AllianzPowerpointWizardController)
    .component('allianzPowerpointWizardStep1', allianzPowerpointWizardStep1)
    .component('allianzPowerpointWizardStep2', allianzPowerpointWizardStep2)
    .component('allianzPowerpointWizardStep3', allianzPowerpointWizardStep3)
    .component('allianzPowerpointWizardStep4', allianzPowerpointWizardStep4)
    .component('allianzPowerpointWizardStep5', allianzPowerpointWizardStep5)
    .constant('allianzPowerpointWizardCreateBehavior', AllianzPowerpointWizardOpenAction).name;