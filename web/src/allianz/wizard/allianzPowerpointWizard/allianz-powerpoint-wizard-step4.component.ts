import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {IcsAssetUtil} from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';

export interface IArticle {
    id: number
    name: string,
    display_name: string,
    textId: number
}

export interface IPptxSlide {
    id: number,
    name: string,
    isStatic: boolean | string,
    sorting: number,
    article?: IArticle,
    selected?: boolean | string
}


interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    csQueryBuilder: any;
    $scope: ng.IScope;
    csAssetUtil: IcsAssetUtil;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csApiSession',
        'csQueryBuilder',
        '$scope',
        'csAssetUtil'
    ];
    private getDependencies: () => IWizardDependencies;
    private productAssetId: number;
    private presentationIssueId: number;

    private slides: Array<IPptxSlide> = [];

    public $onInit() {
        const { wizardStep, wizardInstance, csAssetUtil } = this.getDependencies();
        // console.log('Enter Step 4', wizardStep);

        const step1: IcsWizardStep = wizardInstance.stepByName('allianzPowerpointWizardStep1');
        const step2: IcsWizardStep = wizardInstance.stepByName('allianzPowerpointWizardStep2');

        const productRef: string = this.getStepData(step1, 'productRef', false);
        const presentationIssueId: string = this.getStepData(step2, 'presentationIssueRef', false);

        this.presentationIssueId = csAssetUtil.getAssetIdFromAssetRef(presentationIssueId);
        // console.log('PresentationIssue', this.presentationIssueId);

        this.productAssetId = csAssetUtil.getAssetIdFromAssetRef(productRef);
        // console.log('Product', this.productAssetId);

        this.slides = this.getStepData(wizardStep, 'slides');
        // console.log('Slides', this.slides);


        this.getArticlePptxMapping().then(result => {
            if (result) {
                if (result.fileName) {
                    wizardStep.data.downloadFileName = result.fileName;
                }

                if (result.slides) {
                    this.slides = result.slides.map(slide => {
                        // pre select for checkboxes, only non static needed.
                        if (slide.isStatic === false) {
                            slide.selected = true;
                        }
                        return slide;
                    })
                }
                this.inputChanged();
            }
        }).catch(err => {
            console.log('Error on pptx mapping transformation', err)
        });

        wizardInstance.enablePrev();
    }

    protected getStepData(step: IcsWizardStep, property: string, asArray: boolean = true): any {
        let result;
        if (step && step.data && step.data[property]) {
            result = step.data[property];
        }
        if (!result) {
            return;
        }
        if (asArray) {
            result = Array.isArray(result) ? result : [result];
        }
        return result;
    }


    public inputChanged = (): void => {
        const { wizardStep, wizardInstance } = this.getDependencies();
        const selected = (slide: IPptxSlide) => slide.selected === true || slide.selected === 'true';
        const nonStatic = (slide: IPptxSlide) => slide.isStatic === false || slide.isStatic === 'false';

        wizardStep.data.slides = this.slides;

        if (this.slides && this.slides.filter(nonStatic).some(selected)) {
            wizardInstance.enableNext();
        } else {
            wizardInstance.disableNext();
        }
    };

    private getArticlePptxMapping(): ICommandPromise<any> {
        const csApiSession = this.getDependencies().csApiSession;
        const params = {
            contextAsset: this.productAssetId,
            variables: [
                {key: 'presentationIssueId', value: this.presentationIssueId}
            ]
        };
        return csApiSession.transformation('svtx:powerpointwizard.article.slide.mapping', params);
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzPowerpointWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'allianzPowerpointWizard.chooseCoreModules'"></h6>
                    <div style="margin-bottom: 1rem;margin-top: .5rem;"><span cs-translate="'allianzPowerpointWizard.step3Description'"></span></div>
                    <div ng-repeat="item in $ctrl.slides | orderBy:'sorting' | filter: {isStatic: 'false'} track by $index">
                        <span>
                            <cs-checkbox label="{{item.article.display_name}}" ng-model="item.selected" ng-change="$ctrl.inputChanged()"></cs-checkbox></br>
                        </span>
                    </div>            
                    <div ng-if="$ctrl.articles.length === 0">
                        <cs-empty-state cs-empty-state-icon="'cs-icon-asset'">
                            <span class="cs-state-headline" cs-translate="'allianzPowerpointWizard.noCoreModules'"></span>
                        </cs-empty-state>
                    </div>
                </div>
            </div>
        </div>
    </article>
`;

export const allianzPowerpointWizardStep4: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};