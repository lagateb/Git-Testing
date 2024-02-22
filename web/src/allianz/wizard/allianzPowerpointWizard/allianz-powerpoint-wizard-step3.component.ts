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

interface ICoBranding {
    assetRef1:string,
    assetRef2:string
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
    public options: Array<ISelect> = [];
    public coBranding: ICoBranding;

    public $onInit() {
        const { wizardStep, wizardInstance } = this.getDependencies();
        // console.log('Enter Step 3', wizardStep);

        this.coBranding = wizardStep.data.coBranding || {};

        this.queryBrandingAssets().then(result => {
            if (result && result.container) {
                this.options = result.container.map(selectOption);
            }
            console.log('Cobranding options',this.options);
        }).catch(err => {
            console.log('Error on retrieving CoBranding assets', err);
        });

        wizardInstance.enableNext();
        wizardInstance.enablePrev();

        this.inputChange();
    }

    public queryBrandingAssets(): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder} = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'co-branding.');
        return csApiSession.asset.query(qb.build());
    }


    public inputChange(): void {
        const { wizardStep } = this.getDependencies();
        wizardStep.data.coBranding = this.coBranding;
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzPowerpointWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'allianzPowerpointWizard.chooseCoBranding'"></h6>
                    <div style="margin-bottom: 1rem;margin-top: .5rem;"><span cs-translate="'allianzPowerpointWizard.step2Description'"></span></div>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'allianzPowerpointWizard.chooseBranding1'"></label></dt>
                        <dd>
                            <cs-select-new
                               model="$ctrl.coBranding.assetRef1"
                               values="$ctrl.options"
                               on-change="$ctrl.inputChange()"
                               value-key="assetRef"
                               placeholder="{{ 'allianzPowerpointWizard.noCoBrandingSelected' | csTranslate }}"
                               display-key="name">       
                             </cs-select-new>
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'allianzPowerpointWizard.chooseBranding2'"></label></dt>
                        <dd>
                            <cs-select-new
                              model="$ctrl.coBranding.assetRef2"
                              values="$ctrl.options"
                              on-change="$ctrl.inputChange()"
                              value-key="assetRef"
                              placeholder="{{ 'allianzPowerpointWizard.noCoBrandingSelected' | csTranslate }}"
                              display-key="name">       
                            </cs-select-new>
                        </dd>
                    </dl>
                </div>
            </div>
        </div>
    </article>
`;

export const allianzPowerpointWizardStep3: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};