import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';


interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance'
    ];
    public productType: string;
    private getDependencies: () => IWizardDependencies;

    public $onInit() {
        const { wizardStep } = this.getDependencies();
        this.productType = wizardStep.data.productType || 'product.';
        this.inputChange();
    }

    public inputChange(): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        wizardStep.data.productType = this.productType;
        if (this.productType) {
            wizardInstance.enableNext();
        } else {
            wizardInstance.disableNext()
        }
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzProductWizard__container">
                    <ul class="cs-share-link-wizard__wrapper product-choice">
                        <li class="cs-share-link-wizard__choice">
                            <div class="cs-share-link-wizard__link">
                                <cs-radio class="cs-share-link-wizard__radio" ng-model="$ctrl.productType" value="product." ng-change="$ctrl.inputChange()"></cs-radio>
                                <h3 class="cs-share-link-wizard__headline cs-multiple-lines" cs-translate="'allianzProductWizard.createProduct'"></h3>
                            </div>
                        </li>
                        <li class="cs-share-link-wizard__choice">
                            <div class="cs-share-link-wizard__link">
                                <cs-radio class="cs-share-link-wizard__radio" ng-model="$ctrl.productType" value="product.vsk." ng-change="$ctrl.inputChange()"></cs-radio>
                                <h3 class="cs-share-link-wizard__headline cs-multiple-lines" cs-translate="'allianzProductWizard.createVsk'"></h3>
                            </div>
                        </li>
                        <li class="cs-share-link-wizard__choice">
                            <div class="cs-share-link-wizard__link">
                                <cs-radio class="cs-share-link-wizard__radio" ng-model="$ctrl.productType" value="product.needs-and-advice." ng-change="$ctrl.inputChange()"></cs-radio>
                                <h3 class="cs-share-link-wizard__headline cs-multiple-lines" cs-translate="'allianzProductWizard.createNeedsAndAdvice'"></h3>
                            </div>
                        </li>      
                    </ul>
                </div>
            </div>
        </div>
    </article>
`;

export const allianzProductWizardStep1: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};