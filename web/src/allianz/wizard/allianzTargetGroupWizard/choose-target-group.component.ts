import {groupedInjections} from '@cs/framework/csApi/csUtils/csUtils';
import {IcsWizardInstance, IcsWizardStep} from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {IcsApiSession} from '@cs/framework/csApi/cs-api.model';
import {ICommandPromise} from '@cs/framework/csApi/csCommander/csCommander';
import {IcsAssetUtil} from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';
import {Mode} from "./target-group-wizard.model";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csQueryBuilder: any;
    csApiSession: IcsApiSession;
    csAssetUtil: IcsAssetUtil;
}

interface ISelectOption {
    name: string,
    ref: string
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csQueryBuilder',
        'csApiSession',
        'csAssetUtil'
    ];
    private getDependencies: () => IWizardDependencies;

    public mode: Mode = Mode.enrich;
    public targetGroups: Array<ISelectOption> = [];
    public targetGroupRef: string;
    public productType: string;

    public $onInit(): void {
        const { wizardInstance, csAssetUtil, wizardStep } = this.getDependencies();
        const wizardConfig: any = wizardInstance.config.getValue();
        const ctxAssetId: number = wizardConfig && wizardConfig.self ? csAssetUtil.getAssetIdFromAssetRef(wizardConfig.self) : -1;

        this.assetById(ctxAssetId).then(result => {
            if (result && result.asset) {
                this.productType = result.asset[0].traits.type.type;
            }
        })

        this.targetGroupsQuery().then(result => {
            if (result && result.asset) {
                this.targetGroups = result.asset.map(asset => ({
                    name: asset.traits.display.name,
                    ref: asset.self
                }));

                if (this.targetGroups && this.targetGroups.length === 1) {
                    this.targetGroupRef = this.targetGroups[0].ref;
                }
            }
        })

        wizardStep.onAction(['next', 'save'], () => {
            if (!this.productType) {
                return false;
            }
            return this.getChannel(ctxAssetId).then(result => {
                if (result && result.asset) {
                    wizardStep.data.id = result.asset.map(asset => asset.traits.ids.id).join(',');
                }
                return true
            }).catch(() => {
                return false
            })
        });

        this.validate()
        wizardInstance.disablePrev();
    }

    public $onDestroy(): void { }

    public getChannel(assetId: number): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder } = this.getDependencies();
        const qb = new csQueryBuilder();
        // looking for channel assets with template flag
        qb.condition('censhare:asset.type', 'channel.');
        qb.condition('censhare:asset-flag', 'is-template');
        // product. or product.vsk get show different channel assets
        qb.relation('parent', 'user.').condition('censhare:asset.type', this.productType).condition('censhare:asset-flag', 'is-template')
        if (this.mode === Mode.enrich) {
            // if its the default target grp, just show media (pptx, indd etc.) that doesnt exist on current product
            const not = qb.not();
            not.relation('feature-reverse', 'svtx:media-channel')
                .condition('censhare:asset.type', 'NOTNULL', null)
                .relation('parent', 'user.').condition('censhare:asset.id', assetId)
        } else {
            // show currently exising media from product, which can be overriden with a new target grp
            qb.relation('feature-reverse', 'svtx:media-channel')
                .condition('censhare:asset.type', 'NOTNULL', null)
                .relation('parent', 'user.').condition('censhare:asset.id', assetId)
        }
        qb.view().setTransformation('censhare:cs5.query.asset.list');
        return csApiSession.asset.query(qb.build());
    }


    public assetById(assetId: number): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder } = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.id', assetId)
        qb.view().setTransformation('censhare:cs5.query.asset.list');
        return csApiSession.asset.query(qb.build());
    }

    public targetGroupsQuery() {
        const { csApiSession, csQueryBuilder } = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'category.target-group.');
        qb.condition('censhare:asset-flag', 'ISNULL', null);
        qb.view().setTransformation('censhare:cs5.query.asset.list');
        return csApiSession.asset.query(qb.build());
    }

    public validate(): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        wizardStep.data.targetGroupRef = this.targetGroupRef;
        wizardStep.data.productType = this.productType;
        wizardStep.data.mode = this.mode;

        if ((this.targetGroupRef && this.mode === Mode.override) || this.mode === Mode.enrich) {
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
                <div class="allianzTargetGroupWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'allianzTargetGroupWizard.step1InputLabel'"></h6>
                    <cs-radio 
                        class="cs-is-alt" 
                        label="{{ 'allianzTargetGroupWizard.step1EnrichLabel' | csTranslate}}" 
                        ng-change="$ctrl.validate()" 
                        ng-model="$ctrl.mode" 
                        value="enrich">    
                    </cs-radio>
                    <br/>
                    <cs-radio
                        class="cs-is-alt"
                        label="{{ 'allianzTargetGroupWizard.step1OverrideLabel' | csTranslate}}" 
                        ng-change="$ctrl.validate()" 
                        ng-model="$ctrl.mode" 
                        value="override">    
                    </cs-radio>
                    <div ng-if="$ctrl.mode === 'override'" style="margin-top: 1rem;">
                        <h6 class="csAssetProperties__category_title" cs-translate="'allianzTargetGroupWizard.step1InputLabelTargetGroup'"></h6>
                        <dl class="cs-form-01">
                            <dt><label cs-translate="'allianzTargetGroupWizard.targetGroup'"></label></dt>
                            <dd>
                                <cs-select-new order-by="name" required value-key="ref" display-key="name" model="$ctrl.targetGroupRef" values="$ctrl.targetGroups" on-change="$ctrl.validate()" placeholder="{{ 'allianzTargetGroupWizard.chooseTargetGroup' | csTranslate }}"></cs-select-new>
                            </dd>
                        </dl>
                    </div>
                    
                </div>
            </div>
        </div>
    </article>
    
`;

export const chooseTargetGroup: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};