import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';
import {ISelect, ProductType} from "./flexi-module-wizard.model";


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

    public productType: ProductType;
    public productRef: string;
    public productSelect: Array<ISelect>;
    public vskSelect: Array<ISelect>;
    public currentSelect: Array<ISelect>;

    public $onInit() {
        const { wizardStep } = this.getDependencies();
        console.log('Enter Wizard Step ', wizardStep);

        this.productType = wizardStep.data.productType || ProductType.product;
        this.productRef = wizardStep.data.productRef || '';


        this.initSelect()
            .catch(err => console.log('Error on init Select options', err))
    }

    private async initSelect(): Promise<void> {
        const { wizardStep } = this.getDependencies();
        const promises = [
            this.getAssets(ProductType.product),
            this.getAssets(ProductType.vsk)
        ];
        const result = await Promise.all(promises);
        wizardStep.data.productSelect = this.productSelect = (
            result[0] && result[0].container && result[0].container.map(this.toSelect) || []
        );
        wizardStep.data.vskSelect = this.vskSelect = (
            result[1] && result[1].container && result[1].container.map(this.toSelect) || []
        );
        this.changeSelect();
    }

    private toSelect = (item: any): ISelect => {
        const asset = item && item.asset;
        const value = asset && asset.self;
        const display_value = asset && asset.traits && asset.traits.display && asset.traits.display.name;
        return { value, display_value };
    };

    protected asArray(input: any): Array<any> {
        if (!input) {
            return undefined;
        }
        return Array.isArray(input) ? input : [input];
    }

    public changeSelect(): void {
        switch (this.productType) {
            case ProductType.product:
                this.currentSelect = this.productSelect;
                break;
            case ProductType.vsk:
                this.currentSelect = this.vskSelect;
                break;
            default:
                this.currentSelect = [];
                break;
        }

        const productRefExistAsOption: boolean = (
            this.currentSelect && this.currentSelect.some(item => item.value === this.productRef) || false
        );
        if (!productRefExistAsOption) {
            this.productRef = '';
        }
        this.validate();
    }

    public validate(): void {
        const { wizardInstance, wizardStep } = this.getDependencies();
        wizardStep.data.productRef = this.productRef;
        wizardStep.data.productType = this.productType;
        if (this.productRef) {
            wizardInstance.enableNext();
        } else {
            wizardInstance.disableNext();
        }
    }

    private getAssets = (type: string): ICommandPromise<any> => {
        const { csApiSession, csQueryBuilder } = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', type);
        qb.condition('censhare:asset-flag', 'ISNULL', null);
        return csApiSession.asset.query(qb.build());
    }
}

const template: string = `
   <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzFlexiModuleWizard__container">
                    <cs-radio 
                        class="cs-is-alt" 
                        label="{{ 'allianzFlexiModuleWizard.product' | csTranslate}}" 
                        ng-change="$ctrl.changeSelect()" 
                        ng-model="$ctrl.productType" 
                        value="product.">    
                    </cs-radio>
                    <br/>
                    <cs-radio
                        class="cs-is-alt"
                        label="{{ 'allianzFlexiModuleWizard.vsk' | csTranslate}}" 
                        ng-change="$ctrl.changeSelect()" 
                        ng-model="$ctrl.productType" 
                        value="product.vsk.">    
                    </cs-radio>
                    <br/>
                    <cs-select-new  
                        required
                        model="$ctrl.productRef"
                        values="$ctrl.currentSelect"
                        on-change="$ctrl.validate()"
                        placeholder="{{ 'allianzFlexiModuleWizard.chooseOptionProductLabel' | csTranslate }}">       
                    </cs-select-new>
                </div>
            </div>
        </div>
    </article>
`;

export const flexiModuleChooseProduct: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};