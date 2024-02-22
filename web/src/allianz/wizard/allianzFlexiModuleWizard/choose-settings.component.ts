import {groupedInjections} from '@cs/framework/csApi/csUtils/csUtils';
import {IcsWizardInstance, IcsWizardStep} from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {IcsApiSession} from '@cs/framework/csApi/cs-api.model';
import {IcsAssetUtil} from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';
import {ICommandPromise} from '@cs/framework/csApi/csCommander/csCommander';
import { ICsTranslate } from "@cs/framework/csApplication/csTranslate/translate.provider";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    csQueryBuilder: any;
    csAssetUtil: IcsAssetUtil;
    csTranslate: ICsTranslate;
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
    public moduleAsset: any;

    public moduleName: string;

    // Da erher definiert als currentPptxSlide

    public assetOk = false

    public configuration = {
        imageAlignment: {
            options: [
                {value: 'image_left', display_value: 'Bild Links'},
                {value: 'image_right', display_value: 'Bild Rechts'}
            ],
            value: null
        },
        imageInsertion: {
            options: [
                {value: 'image', display_value: 'Bild'},
                {value: 'icon', display_value: 'Icon'},
                {value: 'none', display_value: 'Ohne Bild/Icon'}
            ],
            value: null
        },
        columnCount: {
            options: [
                {value: '2', display_value: '2'},
                {value: '3', display_value: '3'},
                {value: '4', display_value: '4'}
            ],
            value: null
        },
        showLink: {
            value: false
        },
        showText: {
            value: false
        },
        currentPptxSlide: undefined,
        moduleType: null
    }

    /* für das InputFeld, danmit die Daten akualisiert werden */

    public validateInput = function(scope) {
        //console.log('validateInput')
        scope.$ctrl.validate()
        return true
    }

    public $onInit() {
        const { wizardInstance, wizardStep, csAssetUtil  } = this.getDependencies();
        const prevStep: IcsWizardStep = wizardStep.prevStep.getValue();
        const moduleRef: string = prevStep && prevStep.data && prevStep.data.templateRef;
        const moduleId: number = csAssetUtil.getAssetIdFromAssetRef(moduleRef);

        this.queryAssetById(moduleId).then(result => {
            if (result.asset ) {
                const asset = result.asset[0];
                this.moduleAsset = asset;
                this.configuration.moduleType = csAssetUtil.getValueByPath(asset, 'traits.allianzTemplateOptions.freeModuleType.value');
                this.validate();
            }
        }).catch(console.log);

        wizardInstance.enableNext();
        wizardInstance.enablePrev();
    }

    private queryAssetById(id: number): ICommandPromise<any> {
        const { csQueryBuilder, csApiSession } = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.id', id);
        qb.view().setTransformation('svtx:asset.query.with.relations');
        return csApiSession.asset.query(qb.build());
    }

    private filter() {
        const relations = this.moduleAsset && this.moduleAsset.relations || {};
        const showLink = this.configuration.showLink.value;
        const showText = this.configuration.showText.value;
        const imageAlignment = this.configuration.imageAlignment.value;
        const imageInsertion = this.configuration.imageInsertion.value;
        const columnCount = this.configuration.columnCount.value;
        const type = this.configuration.moduleType;
        const userRelFilter = (rel) => rel.type === 'user.';

        const linkFilter = (rel) => {
            const traits = rel.traits;
            const config = traits.allianzTemplateOptions || {};
            if (showLink && showLink === true) {
                return config.hasOwnProperty('showLink') && config.showLink.value === true;
            } else {
                return !config.hasOwnProperty('showLink') || config.showLink.value === false;
            }
        }

        const showTextFilter = (rel) => {
            const traits = rel.traits;
            const config = traits.allianzTemplateOptions || {};
            if (showText && showText === true) {
                return config.hasOwnProperty('showText') && config.showText.value === true;
            } else {
                return !config.hasOwnProperty('showText') || config.showText.value === false;
            }
        }

        const imageAlignmentFilter = (rel) => {
            const traits = rel.traits;
            const config = traits.allianzTemplateOptions;
            if (config) {
                return config.hasOwnProperty('imageAlignment') && config.imageAlignment.value === imageAlignment;
            } else {
                return true
            }
        }

        const imageInsertionFilter = (rel) => {
            const traits = rel.traits;
            const config = traits.allianzTemplateOptions;
            if (config) {
                return config.hasOwnProperty('insertImage') && config.insertImage.value === imageInsertion;
            } else {
                return true
            }
        }

        const columnCountFilter = (rel) => {
            const traits = rel.traits;
            const config = traits.allianzTemplateOptions;
            if (config) {
                return config.hasOwnProperty('columnCount') && config.columnCount.value === columnCount;
            } else {
                return true
            }
        }

        let found;
        if (type === 'textandimage') {
            found = relations.filter(userRelFilter).filter(imageAlignmentFilter).filter(linkFilter)[0] || null;
        } else if (type === 'imageorvideo') {
            found = relations.filter(userRelFilter).filter(showTextFilter).filter(linkFilter)[0] || null;
        } else if (type === 'flexibletile') {
            found = relations.filter(userRelFilter).filter(columnCountFilter).filter(imageInsertionFilter).filter(linkFilter)[0] || null;
        } else {
            found = relations.filter(userRelFilter).filter(linkFilter)[0] || null;
        }

        const assetRef = found && found.ref_asset || undefined;
        const id = typeof (assetRef) !== 'undefined' ? +assetRef.split('/')[2] : -1;
        if (id === -1) {
            this.configuration.currentPptxSlide = null;
            this.assetOk = false
        }
        return this.queryAssetById(id).then(result => {
            this.assetOk = true
            const relFilter = (rel) => rel.type === 'user.main-picture.';

            const asset = result.asset[0];

            let mainPreview = asset.relations.filter(relFilter)[0] || null;
            let previewUrl = null;
            if(mainPreview) {
                const id =  mainPreview.ref_asset.split('/')[2] ||  -1;
                return this.queryAssetById(id).then(result => {
                    const previewAsset = result.asset[0];
                    previewUrl = previewAsset.preview.url
                    this.configuration.currentPptxSlide = {
                        ref: asset.self,
                        preview: this.getDependencies().csApiSession.session.resolveUrl(previewUrl)
                    };
                })



            } else {
                previewUrl = asset.preview ? asset.preview.url : asset.aspects.icon.large.url

                this.configuration.currentPptxSlide = {
                    ref: asset.self,
                    preview: this.getDependencies().csApiSession.session.resolveUrl(previewUrl)
                };
            }




        });
    }

    //const storageItems = asset && asset.actual_root && asset.actual_root.storage_items || [];
    // Wir haben dem Artikel ein Hauptbild zugewiesen. Das wird dann genommen
    //const previewItem = asset.preview;

    public validate(): void {
        const { wizardInstance, wizardStep } = this.getDependencies();

        wizardStep.data.moduleName = this.moduleName;


        if (this.configuration.moduleType === 'imageorvideo' && this.configuration.showText.value === false) {
            this.configuration.showLink.value = false;
        }
        this.filter().then(() => {
            wizardStep.data.pptxSlide = this.configuration.currentPptxSlide;
            wizardStep.data.config = this.configuration;

            if ((this.assetOk || this.configuration.currentPptxSlide) && this.moduleName) {
                wizardInstance.enableNext();
            } else {
                wizardInstance.disableNext();
            }
        }).catch(() => {
            wizardInstance.disableNext();
        });
    }
}

const template: string = `
<style>
 .imagesize.img {
    width: 135%;
    padding-top: 20px;
 }
</style>
<article class="csWidget cs-has-no-header">
    <div class="csWidget__content">
        <div class="csWidget__content__inner">
            <div class="allianzFlexiModuleWizard__container">
                <h6 class="csAssetProperties__category_title">
                <span  cs-translate="'allianzFlexiModuleWizard.templateOptions'"></span>
                </h6>
                
                
                <dl class="cs-form-01">
                    <dt><label cs-translate="'allianzFlexiModuleWizard.moduleName'"></label></dt>
                    <dd>
                        <cs-input  ng-change="$ctrl.validate()"  ng-model="$ctrl.moduleName" required placeholder="Namen eingeben"></cs-input>
                    </dd>
                </dl>
                
                
                <dl class="cs-form-01" ng-if="$ctrl.configuration.moduleType === 'textandimage'">
                    <dt><label cs-translate="'allianzFlexiModuleWizard.imageAlignment'"></label></dt>
                    <dd>
                        <cs-select-new required model="$ctrl.configuration.imageAlignment.value"
                            on-change="$ctrl.validate()" values="$ctrl.configuration.imageAlignment.options"
                            placeholder="{{ 'allianzFlexiModuleWizard.chooseTemplate' | csTranslate }}">
                        </cs-select-new>
                    </dd>
                </dl>
                <dl class="cs-form-01" ng-if="$ctrl.configuration.moduleType === 'imageorvideo'">
                    <dt><label>Text einblenden</label></dt>
                    <dd>
                        <cs-checkbox ng-model="$ctrl.configuration.showText.value" ng-change="$ctrl.validate()"></cs-checkbox>
                    </dd>
                </dl>
                <dl class="cs-form-01">
                    <dt><label>Link anzeigen</label></dt>
                    <dd>
                        <cs-checkbox ng-disabled="$ctrl.configuration.moduleType === 'imageorvideo' && $ctrl.configuration.showText.value === false" ng-model="$ctrl.configuration.showLink.value" ng-change="$ctrl.validate()"></cs-checkbox>
                    </dd>
                </dl>
                <dl class="cs-form-01" ng-if="$ctrl.configuration.moduleType === 'flexibletile'">
                    <dt><label>Spaltenanzahl</label></dt>
                    <dd>
                        <cs-select-new required model="$ctrl.configuration.columnCount.value"
                            on-change="$ctrl.validate()" values="$ctrl.configuration.columnCount.options">
                        </cs-select-new>
                    </dd>
                </dl>
                <dl class="cs-form-01" ng-if="$ctrl.configuration.moduleType === 'flexibletile'">
                    <dt><label>Bildeinsatz</label></dt>
                    <dd>
                        <cs-select-new required model="$ctrl.configuration.imageInsertion.value"
                            on-change="$ctrl.validate()" values="$ctrl.configuration.imageInsertion.options">
                        </cs-select-new>
                    </dd>
                </dl>
                <img class="image__item imagesize" ng-if="$ctrl.configuration.currentPptxSlide" ng-src="{{$ctrl.configuration.currentPptxSlide.preview}}" />
            </div>
        </div>
    </div>
</article>
`;

export const flexiModuleChooseSettings: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};