import { IcsWizardDataManager, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';

export class AllianzPowerpointWizardController {
    public static $name: string = 'allianzPowerpointWizardController';
    public static $inject: string[] = [
        '$scope',
        'wizardDataManager',
        'wizardInstance'
    ];

    constructor($scope: any, wizardDataManager: IcsWizardDataManager, wizardInstance: IcsWizardInstance) {
        console.log('pen allianzPowerpointWizard', wizardInstance, wizardDataManager, $scope);
    }
}