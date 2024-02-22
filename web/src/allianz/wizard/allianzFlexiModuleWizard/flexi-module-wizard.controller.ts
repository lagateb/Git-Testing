import { IcsWizardDataManager, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';

export class FlexiModuleWizardController {
    public static $name: string = 'allianzFlexiModuleWizardController';
    public static $inject: string[] = [
        '$scope',
        'wizardDataManager',
        'wizardInstance'
    ];

    constructor($scope: any, wizardDataManager: IcsWizardDataManager, wizardInstance: IcsWizardInstance) {
        console.log('Open Allianz Flexi Module Wizard', wizardInstance, wizardDataManager, $scope);
    }
}