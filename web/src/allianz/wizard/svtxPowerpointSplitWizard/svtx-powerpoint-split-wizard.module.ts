import * as censhare from 'censhare';
import {SvtxPowerpointSplitWizardController} from "./svtx-powerpoint-split-wizard.controller";
import {SvtxPowerpointSplitWizardOpenActionConstant} from "./svtx-powerpoint-split-wizard-open-action.constant";
import {svtxPowerpointSplitWizardStep1} from "./svtx-powerpoint-split-wizard-step1.component";


export const svtxPowerpointSplitWizardModule: string = censhare
    .module('svtxPowerpointSplitWizard', [])
    .component('svtxPowerpointSplitWizardStep1', svtxPowerpointSplitWizardStep1)
    .controller(SvtxPowerpointSplitWizardController)
    .constant(SvtxPowerpointSplitWizardOpenActionConstant)
    .name;