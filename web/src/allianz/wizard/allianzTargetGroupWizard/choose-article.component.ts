import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsAssetUtil } from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';
import { Mode } from "./target-group-wizard.model";


interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csQueryBuilder: any;
    csApiSession: IcsApiSession;
    csAssetUtil: IcsAssetUtil;
    $scope: any;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csQueryBuilder',
        'csApiSession',
        'csAssetUtil',
        '$scope'
    ];
    private getDependencies: () => IWizardDependencies;


    public mediaComponents: Array<any> = [];
    // if its the default target grp, show article which will be created new, else show article that can be overriden
    public mode: Mode;

    public $onInit(): void {
        const { wizardStep, wizardInstance } = this.getDependencies();
        const wizardStep1: IcsWizardStep = wizardStep.prevStep.getValue();
        const wizardStep2: IcsWizardStep = wizardStep1.prevStep.getValue();

        this.mode = wizardStep2.data.mode;
        this.setMediaComponents();

        wizardInstance.enableDone();
        wizardInstance.enablePrev();
    }


    public onChange(): void {
        const { wizardStep } = this.getDependencies();
        wizardStep.data.MediaComponent = this.mediaComponents;
    }

    private setMediaComponents(): void {
        const { wizardStep } = this.getDependencies();
        let mediaComponentData = wizardStep.data && wizardStep.data.MediaComponent || []
        if (!Array.isArray(mediaComponentData)) {
            mediaComponentData = [mediaComponentData];
        }

        const itemOrder: Array<String> = [
            'article.header.',
            'article.produktbeschreibung.',
            'article.funktionsgrafik.',
            'article.vorteile.',
            'article.fallbeispiel.',
            'article.nutzenversprechen.',
            'article.zielgruppenmodul.',
            'article.productdetails.',
            'article.staerken.',
            'article.faq.',
            'article.baveinsatz.',
            'article.schichten.'
        ]

        this.mediaComponents = mediaComponentData.sort((a,b) => itemOrder.indexOf(a.type) - itemOrder.indexOf(b.type));
    }
    public $onDestroy(): void { }
}



const template: string = `
   <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzTargetGroupWizard__container"> 
                    
                    <h6 ng-if="$ctrl.mode === 'override'" class="csAssetProperties__category_title" cs-translate="'allianzTargetGroupWizard.step3InputLabel'"></h6>
                    <h6 ng-if="$ctrl.mode === 'enrich'" class="csAssetProperties__category_title" cs-translate="'allianzTargetGroupWizard.step3InputLabelAlt'"></h6>
                    
                    <div ng-repeat="mediaComponent in $ctrl.mediaComponents track by $index">
                        <cs-checkbox label="{{ mediaComponent.display_name }}" ng-model="mediaComponent.selected" ng-disabled="mediaComponent.disabled" ng-change="$ctrl.onChange()"></cs-checkbox>
                    </div>
                  
                </div>
            </div>
        </div>
    </article>
    
`;

export const chooseArticle: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};