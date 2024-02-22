import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';
import { IcsAssetUtil } from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';

interface ISelect {
    value: string;
    display_value: string;
    preview?: string;
    selected?: boolean;
}


interface IWizardDependencies {
    $scope: any;
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csQueryBuilder: any;
    csApiSession: IcsApiSession;
    csAssetUtil: IcsAssetUtil;
    wizardDataManager: any;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        '$scope',
        'wizardStep',
        'wizardInstance',
        'csQueryBuilder',
        'csApiSession',
        'csAssetUtil',
        'wizardDataManager'
    ];
    private getDependencies: () => IWizardDependencies;

    public moduleTemplates: Array<ISelect>;
    //public moduleName: string;
    public moduleTemplateAssets: Array<any>;
    public optionalArray: any;
    public templateRef: string;
    public previewUrl: string;
    public targetGroups: Array<any> = [];
    public hasFlexiModule: boolean;
    public allTargetGroupsHaveFlexi: boolean;
    public articleType: string;
    public currentTemplate:any;

    public $onInit(): void {
        const { wizardStep, wizardInstance, csAssetUtil } = this.getDependencies();
        console.log('Enter Wizard Step ', wizardStep);
        const wizardConfig: { self: string }  = wizardInstance.config.getValue();
        const contextAssetId =  csAssetUtil.getAssetIdFromAssetRef(wizardConfig.self);
        this.optionalArray = {};
        this.queryTargetGroups(contextAssetId);
        this.articleType = wizardStep.prevStep.getValue().data.moduleType;
        this.hasFlexiModule = wizardStep.prevStep.getValue().data.hasFlexiModule;
        this.queryModuleTemplates()
            .then(this.initSelect)
            .catch(e => console.log('Error on Asset Query', e));

        wizardInstance.enablePrev();
    }

    private queryTargetGroups(id): any {
        const { csApiSession } = this.getDependencies();
        const contextAsset = { contextAsset: id };
        csApiSession.transformation("svtx:flexi.module.find.target.groups", contextAsset).then(r => {
            if (r && r.entry ) {
                if (!Array.isArray(r.entry)) {
                    r.entry = [r.entry];
                }
                this.targetGroups = r.entry;
                this.allTargetGroupsHaveFlexi = this.targetGroups.every(tg => tg.has_target_group_specific_flexi_module === true);
            }
        })
    }

    private buildAssetPojo = (asset): ISelect => {
        const { csApiSession } = this.getDependencies();
        const value = asset.self;
        const traits = asset && asset.traits;
        let display_value = traits && traits.display && traits.display.name;
        console.log("display name"+display_value )
        //const storageItems = asset && asset.actual_root && asset.actual_root.storage_items || [];
        // Wir haben dem Artikel ein Hauptbild zugewiesen. Das wird dann genommen
        const previewItem = asset.preview; //Ja storageItems.find(si => si.type === 'master');
        const url = previewItem && previewItem.url;
        const preview = url ? csApiSession.session.resolveUrl(url) : undefined;
        display_value = display_value.replace('Freies Modul (','').replace(')','')
        return { value, display_value, preview }
    }

    private initSelect = (item: any): void => {
        if (item && item.asset) {
            this.moduleTemplateAssets = item.asset;
            this.moduleTemplates = item.asset.map(this.buildAssetPojo);
        }

        this.validate();
    };

    private queryModuleTemplates(): ICommandPromise<any> {
        const { csQueryBuilder, csApiSession } = this.getDependencies();
        const qb = new csQueryBuilder();
        if (this.articleType.startsWith('article.optional-module.')) {
            qb.condition('censhare:asset.type', 'article.optional-module.*');
            qb.condition('censhare:template-hierarchy', 'root.content-building-block.optional-modules.');
        } else if (this.articleType.startsWith('article.flexi-module.')) {
            qb.condition('censhare:asset.type', 'article.flexi-module.*');
            qb.condition('censhare:template-hierarchy', 'root.content-building-block.flexi-modules.');
        } else if (this.articleType.startsWith('article.free-module.')) {
            qb.condition('censhare:asset.type', 'article.free-module.*');
            qb.condition('censhare:template-hierarchy', 'root.content-building-block.free-modules.');
        }
        else{
            qb.condition('censhare:asset.type', this.articleType);
        }
        qb.condition('censhare:asset-flag', 'is-template');
        qb.view().setTransformation('svtx:asset.query.with.relations');
        /*qb.view().setTransformation('censhare:cs5.query.asset.list');*/
        return csApiSession.asset.query(qb.build());
    }

    public $onDestroy(): void { }

    public validate = ():void => {
        const { wizardInstance, wizardStep } = this.getDependencies();
        //update preview
        if (this.templateRef && this.moduleTemplates) {
            const currentTemplate = this.moduleTemplates.find(t => t.value === this.templateRef);
            this.previewUrl = currentTemplate && currentTemplate.hasOwnProperty('preview') ? currentTemplate.preview : undefined;
        }
        wizardStep.data.templateRef = this.templateRef;
        wizardStep.data.targetGroups = this.targetGroups;
        wizardStep.data.hasFlexiModule = this.hasFlexiModule;
        wizardStep.data.optionalArray = this.optionalArray;
        wizardStep.data.articleType = this.articleType;
        //wizardStep.data.moduleName = this.moduleName;
        if (this.templateRef && this.templateRef != '') {
            if (!this.hasFlexiModule || this.articleType === 'article.free-module.') {
                wizardInstance.enableNext();
            } else {
                const canSelectTargetGroup = this.targetGroups && this.targetGroups.some(val => {
                    return val.disabled === false && val.selected === true && val.has_target_group_specific_flexi_module === false;
                })
                if (canSelectTargetGroup) {
                    wizardInstance.enableNext();
                } else {
                    wizardInstance.disableNext();
                }
            }
        } else {
            if (this.optionalArray && this.optionalArray.value && this.optionalArray.value.length > 0) {
                wizardInstance.enableNext();
            } else {
                wizardInstance.disableNext();
            }
        }
    }
}

const template: string = `
<article class="csWidget cs-has-no-header">
    <div class="csWidget__content">
        <div class="csWidget__content__inner">
            <!--Flexi modules template-->
            <div class="allianzFlexiModuleWizard__container" ng-if="$ctrl.articleType == 'article.flexi-module.'">
                <h6 class="csAssetProperties__category_title"
                    cs-translate="'allianzFlexiModuleWizard.createFlexiModule'"></h6>
                <dl class="cs-form-01">
                    <dt><label cs-translate="'allianzFlexiModuleWizard.template'"></label></dt>
                    <dd>
                        <cs-select-new required model="$ctrl.templateRef" values="$ctrl.moduleTemplates"
                            on-change="$ctrl.validate()"
                            placeholder="{{ 'allianzFlexiModuleWizard.chooseTemplate' | csTranslate }}">
                        </cs-select-new>
                        <img class="image__item" ng-src="{{$ctrl.previewUrl}}" />
                    </dd>
                </dl>
                <div ng-if="$ctrl.targetGroups.length > 0">
                    <h6 class="csAssetProperties__category_title"
                        cs-translate="'allianzFlexiModuleWizard.chooseTargetGroups'"></h6>
                    <div ng-repeat="item in $ctrl.targetGroups track by $index">
                        <cs-checkbox label="{{ item.target_group_name }}" ng-model="item.selected"
                            ng-disabled="item.disabled == true" ng-change="$ctrl.validate()"></cs-checkbox>
                    </div>
                </div>
            </div>
            <!--Optional modules template-->
            <div class="allianzFlexiModuleWizard__container"
                ng-if="$ctrl.articleType.startsWith('article.optional-module.')">
                <h6 class="csAssetProperties__category_title"
                    cs-translate="'allianzFlexiModuleWizard.createOptionalModule'"></h6>
                <dl class="cs-form-01">
                    <dt><label cs-translate="'allianzFlexiModuleWizard.template'"></label></dt>
                    <dd>
                        <cs-select-new multiselect required model="$ctrl.optionalArray.value"
                            values="$ctrl.moduleTemplates" on-change="$ctrl.validate()"
                            placeholder="{{ 'allianzFlexiModuleWizard.chooseTemplate' | csTranslate }}">
                        </cs-select-new>
                    </dd>
                </dl>
            </div>
            <div ng-if="$ctrl.articleType == 'article.free-module.'">
                <!--
                <div class="allianzFlexiModuleWizard__container">
              
                    <h6 class="csAssetProperties__category_title"
                        cs-translate="'allianzFlexiModuleWizard.createFreeModule'"></h6>
                   
                   laut Nico jetzt im nächsten Scbhritt    
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'allianzFlexiModuleWizard.moduleName'"></label></dt>
                        <dd>
                            <cs-input ng-model="$ctrl.moduleName" required placeholder="Namen eingeben"></cs-input>
                        </dd>
                    </dl>
                    
                </div>
                -->
                <ul class="cs-share-link-wizard__wrapper" style="margin-top: 5rem">
                    <li class="cs-share-link-wizard__choice" ng-repeat="template in $ctrl.moduleTemplates">
                        <div class="cs-share-link-wizard__link">
                            <cs-radio class="cs-share-link-wizard__radio" ng-change="$ctrl.validate()"
                                ng-model="$ctrl.templateRef" value="{{template.value}}"></cs-radio>
                            <h3 class="cs-share-link-wizard__headline cs-multiple-lines">{{template.display_value}}</h3>
                            <!--<p class="joerg3 cs-share-link-wizard__description" cs-translate="'csShareLinkWizard.sendMailClientDesc'"></p>-->
                             <img class="image__item" ng-src="{{template.preview}}" />
                        </div>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</article>`;

export const flexiModuleChooseModule: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};