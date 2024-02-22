import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';

export interface ISelect {
    assetRef:string,
    name: string,
    type?: string;
}

export const selectOption = (entry): ISelect => {
    const asset = entry.asset;
    const assetRef = asset.self;
    const name = asset.traits.display.name;
    const type = asset.traits.type.type;
    return { assetRef, name, type };
};

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
    public productRef: string;
    public options: Array<ISelect> = [];

    public $onInit() {
        const { wizardStep } = this.getDependencies();
        console.log('Enter Step 1', wizardStep);

        this.productRef = wizardStep.data.productRef || '';

        this.queryProductAssets().then(result => {
            if (result && result.container) {
                this.options = result.container.map(selectOption)
            }
            console.log('Product options',this.options);
        }).catch(err => {
            console.log('Error on retrieving product asset', err)
        });

        this.inputChange();
    }

    public inputChange(option = null): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        if (this.productRef) {
            wizardStep.data.productRef = this.productRef;
        }
        if (option && option.type) {
            wizardStep.data.productType = option.type;
        }
        if (this.productRef && this.productRef.length > 0) {
            wizardInstance.enableNext();
        } else {
            wizardInstance.disableNext();
        }
    }

    public queryProductAssets(): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder} = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'product.*');
        qb.condition('censhare:asset-flag', 'ISNULL', null);
        return csApiSession.asset.query(qb.build());
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzPowerpointWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'allianzPowerpointWizard.chooseProduct'"></h6>
                    <dl class="cs-form-01">
                        <dd>
                            <cs-select-new required
                               model="$ctrl.productRef"
                               values="$ctrl.options"
                               on-change="$ctrl.inputChange(option)"
                               placeholder="{{ 'allianzPowerpointWizard.chooseOptionProductLabel' | csTranslate }}"
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

export const allianzPowerpointWizardStep1: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};