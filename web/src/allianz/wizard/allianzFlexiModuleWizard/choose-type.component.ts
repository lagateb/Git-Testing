import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsAssetUtil } from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';

interface ISelect {
    value: string;
    display_value: string;
}

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    csQueryBuilder: any;
    csAssetUtil: IcsAssetUtil;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csApiSession',
        'csQueryBuilder',
        'csAssetUtil'
    ];

    private getDependencies: () => IWizardDependencies;
    public moduleTypes: Array<ISelect>;
    public moduleType: string;

    public hasFlexiModule: boolean;
    public canCreateTargetGroupSpecificFlexi: boolean = false;

    public $onInit() {
        const { wizardStep, wizardInstance, csAssetUtil } = this.getDependencies();
        const wizardConfig: { self: string }  = wizardInstance.config.getValue();
        const contextAssetId =  csAssetUtil.getAssetIdFromAssetRef(wizardConfig.self);

        this.moduleType = wizardStep.data.moduleType || '';
        // all available types to pick from
        this.moduleTypes = [
            { value: 'article.flexi-module.', display_value: 'Flexi-Modul' },
            { value: 'article.optional-module.', display_value:'Optionales Modul'},
            { value: 'article.free-module.', display_value: 'Freies Modul'}
        ];


        Promise.all([this.queryFlexiModule(contextAssetId),this.queryTargetGroups(contextAssetId)]).then(result => {
            this.hasFlexiModule = result[0];
            this.canCreateTargetGroupSpecificFlexi = result[1];
            this.validate();
        })

        this.validate();
        wizardInstance.enablePrev();
    }

    private queryFlexiModule(id: number | string): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder } = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type','article.flexi-module.');
        qb.relation('parent', 'user.').condition('censhare:asset.id', id);
        qb.view().setTransformation('censhare:cs5.query.asset.list');
        return csApiSession.asset.query(qb.build())
            .then(result => result && result.hasOwnProperty("asset"))
            .catch(() => false);
    }

    private queryTargetGroups(id): ICommandPromise<any> {
        const { csApiSession } = this.getDependencies();
        const contextAsset = { contextAsset: id };
        return csApiSession.transformation("svtx:flexi.module.find.target.groups", contextAsset).then(r => {
            if (r && r.entry ) {
                if (!Array.isArray(r.entry)) {
                    r.entry = [r.entry];
                }
                const targetGroups = Array.isArray(r.entry) ? r.entry : [r.entry];
                return targetGroups.length > 0 && targetGroups.some(tg => tg.has_target_group_specific_flexi_module === false);
            }
        }).catch(()=> false);
    }

    public validate(): void {
        const { wizardInstance, wizardStep } = this.getDependencies();
        wizardStep.data.moduleType = this.moduleType;
        wizardStep.data.hasFlexiModule = this.hasFlexiModule;

        
        if (this.moduleType) {
            if (this.hasFlexiModule && this.moduleType === 'article.flexi-module.') {
                if (this.canCreateTargetGroupSpecificFlexi) {
                    wizardInstance.enableNext();
                } else {
                    wizardInstance.disableNext();
                }
            } else {
                wizardInstance.enableNext();
            }

            if (this.moduleType === 'article.free-module.') {
                wizardInstance.showStep('flexiModuleChooseSettings');
            } else {
                wizardInstance.hideStep('flexiModuleChooseSettings');
            }

        } else {
            wizardInstance.disableNext();
            wizardInstance.hideStep('flexiModuleChooseSettings');
        }
    }
}

const template: string = `
   <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzFlexiModuleWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'allianzFlexiModuleWizard.chooseType'"></h6> 
                    <cs-select-new  
                        required
                        model="$ctrl.moduleType"
                        values="$ctrl.moduleTypes"
                        on-change="$ctrl.validate()"
                        placeholder="{{ 'allianzFlexiModuleWizard.chooseType' | csTranslate }}">       
                    </cs-select-new>
                    <div ng-if="$ctrl.hasFlexiModule && $ctrl.moduleType === 'article.flexi-module.' && !$ctrl.canCreateTargetGroupSpecificFlexi" class="cs-form-validation-msg">
                        <span>Sie können im Moment kein Flexi-Modul anlegen, da bereits eines existiert. Sie können eine neue Zielgruppe anlegen und danach ein neues Flexi-Modul erstellen.</span>
                    </div>
                </div>
            </div>
        </div>
    </article>
`;

export const flexiModuleChooseType: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};