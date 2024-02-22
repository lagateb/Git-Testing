import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';
import {ISelect, selectOption} from "./allianz-powerpoint-wizard-step1.component";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    csQueryBuilder: any;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csApiSession',
        'csQueryBuilder'
    ];
    private getDependencies: () => IWizardDependencies;

    public presentationIssueRef: string;
    public options: Array<ISelect>;

    public $onInit() {
        const { wizardStep, wizardInstance } = this.getDependencies();
        console.log('Enter Step 2', wizardStep);

        this.presentationIssueRef = wizardStep.data.presentationIssueRef || '';

        const prevStep:IcsWizardStep = wizardStep.prevStep.getValue();
        const productType = prevStep.data.productType;

        this.getPresentationIssues(productType).then(result => {
            if (result && result.container) {
                this.options = result.container.map(selectOption);
            }
            console.log('PresentationIssue options',this.options);
        }).catch(err => {
            console.log('Error on retrieving presentationIssue assets', err)
        });

        wizardInstance.enableNext();
        wizardInstance.enablePrev();

        this.inputChange();
    }

    public getPresentationIssues(productType: string): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder} = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'presentation.issue.')
          .relation('parent', 'user.')
          .condition('censhare:asset.type', 'channel.')
            .relation('parent', 'user.')
            .condition('censhare:asset.type', productType)
            .condition('censhare:asset-flag', 'is-template');
        return csApiSession.asset.query(qb.build());
    }


    public inputChange(): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        wizardStep.data.presentationIssueRef = this.presentationIssueRef;
        if (this.presentationIssueRef && this.presentationIssueRef.length > 0) {
            wizardInstance.enableNext();
        } else {
            wizardInstance.disableNext();
        }
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzPowerpointWizard__container">                   
                    <h6 class="csAssetProperties__category_title" cs-translate="'allianzPowerpointWizard.choosePresentationTemplate'"></h6>
                    <dl class="cs-form-01">
                        <dd>
                            <cs-select-new required
                               model="$ctrl.presentationIssueRef"
                               values="$ctrl.options"
                               on-change="$ctrl.inputChange()"
                               placeholder="{{ 'allianzPowerpointWizard.chooseOptionPresentationTemplateLabel' | csTranslate }}"
                               value-key="assetRef"
                               display-key="name">       
                            </cs-select-new>
                        </dd>
                    </dl>
                </div>
            </div>
        </div>
    </article>
`;

export const allianzPowerpointWizardStep2: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};