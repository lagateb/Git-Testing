import * as censhare from 'censhare';
import {TargetGroupWizardController} from "./target-group-wizard.controller";
import {chooseTargetGroup} from "./choose-target-group.component";
import {chooseArticle} from "./choose-article.component";
import {TargetGroupWizardOpenAction} from "./target-group-wizard.constant";

export const targetGroupWizardModule: string = censhare.module('allianzTargetGroupWizard', [])
    .controller(TargetGroupWizardController)
    .component('chooseTargetGroup', chooseTargetGroup)
    .component('chooseArticle', chooseArticle)
    .constant('allianzTargetGroupWizardCreateBehavior', TargetGroupWizardOpenAction).name;

