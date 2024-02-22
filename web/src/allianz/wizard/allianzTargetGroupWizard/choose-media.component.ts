import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csQueryBuilder: any;
    csApiSession: IcsApiSession;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csQueryBuilder',
        'csApiSession'
    ];
    private getDependencies: () => IWizardDependencies;

    public $onInit(): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        console.log('Enter Wizard Step ', wizardStep);

        wizardInstance.enableNext();
        wizardInstance.enablePrev();
    }

    public $onDestroy(): void { }
}

const template: string = `
   <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzTargetGroupWizard__container">
                    WIZARD STEP 1
                </div>
            </div>
        </div>
    </article>
    
`;

export const chooseMedia: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};