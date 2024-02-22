import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IProduct } from "./allianz-product-wizard.model";
import {ICommandPromise} from "@cs/framework/csApi/csCommander/csCommander";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    pageInstance: any;
    $scope: any;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csApiSession',
        'pageInstance',
        '$scope'
    ];
    public product: IProduct;

    public referenceDomains: Array<any> = Array<any>();
    public selectedReferenceDomain: string = null

    public assignedUser:any = null;
    public marketingManager: Array<any> = Array<any>();

    public productAreas: Array<any> = Array<any>();
    public productAreaModel: string = null;

    public productBranches: Array<any> = Array<any>();
    public productBranchModel: string = null;

    public productCategoriesAzde: Array<any> = Array<any>();
    public productCategoryAzdeModel: string = null;

    private getDependencies: () => IWizardDependencies;

    public $onInit() {
        const { wizardStep, wizardInstance, csApiSession, pageInstance } = this.getDependencies();
        const prevStep: IcsWizardStep = wizardStep.prevStep.getValue();
        const assetId: string = pageInstance.getPathContextReader().getValue().get('id');

        this.product = wizardStep.data.product || {};
        this.assignedUser = wizardStep.data.assignedUser ? wizardStep.data.assignedUser : null;

        if (prevStep && prevStep.data && prevStep.data.productType) {
            this.product.type = prevStep.data.productType;
        }

        this.lookUpFeatureValues('svtx:product-branch').then(result => {
            this.productBranches = result;
        })
        this.lookUpFeatureValues('svtx:product-area').then(result => {
            this.productAreas = result;
        })
        this.lookUpFeatureValues('svtx:product-category-azde').then(result => {
            this.productCategoriesAzde = result;
        })

        const params = { contextAsset: assetId }
        csApiSession.transformation('svtx:xslt.get.avaible.reference.domains', params).then((result)=> {
            if (result && result.domains) {
                this.referenceDomains = result.domains.map(obj => ({
                    value: obj.write,
                    display_value: obj.name,
                    manager: obj.manager
                }));
            }
        });
        wizardInstance.enablePrev();
        this.inputChange();
    }

    private lookUpFeatureValues(featureKey: string): ICommandPromise<any> {
        const { csApiSession } = this.getDependencies();
        const lookup = {
            lookup: [{
                table: 'feature_value',
                condition: [
                    {name: 'feature', value: featureKey}
                ]
            }]
        }
        return csApiSession.masterdata.lookup(lookup).then(result => {
            if (result && result.records && result.records.record) {
                return result.records.record.map(obj => ({value: obj.value_key, display_value: obj.name}))
            } else {
                return []
            }
        }).catch(()=> {
            return []
        })
    }

    public inputChange(): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        let proceed: boolean = true;
        if (!this.validateInput(this.product.name)) {
            proceed = false;
        }

        if (!this.selectedReferenceDomain || this.selectedReferenceDomain === '') {
            proceed = false;
        }

        if (!this.assignedUser || this.assignedUser.length == 0) {
            proceed = false;
        }

        if (!this.productAreaModel || !this.productBranchModel || !this.productCategoryAzdeModel) {
            proceed = false;
        }

        if (proceed) {
            wizardStep.data.product = this.product;
            wizardStep.data.assignedUser = this.assignedUser;
            wizardStep.data.domain = this.selectedReferenceDomain;
            wizardStep.data.productArea = this.productAreaModel
            wizardStep.data.productBranch = this.productBranchModel;
            wizardStep.data.productCategoryAzde = this.productCategoryAzdeModel;
            wizardInstance.enableNext();
        } else {
            wizardInstance.disableNext();
        }
    }

    public referenceDomainChange(): void {
        this.assignedUser = null;
        const tmp = [];
        if (this.selectedReferenceDomain) {
            const currentRefDomain = this.referenceDomains.find(obj => obj.value === this.selectedReferenceDomain);
            if (currentRefDomain && currentRefDomain.hasOwnProperty('manager')) {
                currentRefDomain.manager.forEach(obj => tmp.push(Object.assign({}, obj)))
            }
        }
        this.marketingManager = tmp;
        this.inputChange();
    }

    protected validateInput(input: string): boolean {
        return input && input.length > 0;
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzProductWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'csCommonTranslations.metaData'"></h6>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'allianzProductWizard.productName'"></label></dt>
                        <dd><cs-input required ng-model="$ctrl.product.name" ng-change="$ctrl.inputChange()"></cs-input></dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label>Referat auswählen</label></dt>
                        <dd>     
                            <!--<cs-select-new required model-as-array="true"  model="$ctrl.selectedReferenceDomain" on-change="$ctrl.referenceDomainChange()"  values="$ctrl.referenceDomains" placeholder="Referat"></cs-select-new>-->
                            <cs-select  required ng-model="$ctrl.selectedReferenceDomain" ng-change="$ctrl.referenceDomainChange()" ng-options="opt.value as opt.display_value for opt in $ctrl.referenceDomains" placeholder="Referat"></cs-select>
                            <div class="cs-form-validation-msg" ng-show="($ctrl.selectedReferenceDomain && $ctrl.selectedReferenceDomain.length > 0) && (!$ctrl.marketingManager || $ctrl.marketingManager.length === 0)">Für dieses Referat steht kein Marketing Manager zur Verfügung</div>
                        </dd>
                    </dl>
                    <dl class="cs-form-01" ng-if="$ctrl.marketingManager && $ctrl.marketingManager.length > 0">
                        <dt><label>Marketing Manager auswählen</label></dt>
                        <dd>
                            <!--<cs-select-new required  value-key="party_asset_id" display-key="display_name" on-change="$ctrl.inputChange()"  model="$ctrl.assignedUser" values="$ctrl.marketingManager" placeholder="Marketing Manager"></cs-select-new>-->
                            <cs-select required ng-model="$ctrl.assignedUser" ng-change="$ctrl.inputChange()" ng-options="opt.party_asset_id as opt.display_name for opt in $ctrl.marketingManager" placeholder="Marketing Manager"></cs-select>
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label>Organisationsbereich</label></dt>
                        <dd>
                            <cs-select required ng-model="$ctrl.productBranchModel" ng-change="$ctrl.inputChange()" ng-options="opt.value as opt.display_value for opt in $ctrl.productBranches" placeholder="Organisationsbereich"></cs-select>  
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label>Produktsegment</label></dt>
                        <dd>     
                            <cs-select required ng-model="$ctrl.productAreaModel" ng-change="$ctrl.inputChange()" ng-options="opt.value as opt.display_value for opt in $ctrl.productAreas" placeholder="Produktsegment"></cs-select>
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label>Produktkategorie für AZ.de</label></dt>
                        <dd>     
                            <cs-select required ng-model="$ctrl.productCategoryAzdeModel" ng-change="$ctrl.inputChange()" ng-options="opt.value as opt.display_value for opt in $ctrl.productCategoriesAzde" placeholder="Produktkategorie für AZ.de"></cs-select>
                        </dd>
                    </dl>
                </div>
            </div>
        </div>
    </article>
`;

export const allianzProductWizardStep2: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};
