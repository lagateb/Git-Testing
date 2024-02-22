import * as censhare from 'censhare';
import {AllianzRecurringModulesAction} from "./allianz-recurring-modules-action.constant";
import {allianzRecurringModulesDialogComponent, Dialog, allianzRecurringModulesUpdateDialogComponent, Dialog2} from "./allianz-recurring-modules-dialog.component";

export const allianzRecurringModulesActionModule: string = censhare
    .module('allianzRecurringModulesAction', [])
    .service('allianzRecurringModulesDialog', Dialog)
    .service('allianzRecurringModulesUpdateDialog', Dialog2)
    .component('allianzRecurringModulesDialogComponent', allianzRecurringModulesDialogComponent)
    .component('allianzRecurringModulesUpdateDialogComponent', allianzRecurringModulesUpdateDialogComponent)
    .constant('allianzRecurringModulesBehavior', AllianzRecurringModulesAction)
    .name;
