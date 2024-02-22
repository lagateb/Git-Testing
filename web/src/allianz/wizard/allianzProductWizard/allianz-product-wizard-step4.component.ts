import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {AllianzProductWizardUtil} from "./allianz-product-wizard.controller";
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import {IArticle} from "./allianz-product-wizard.model";


interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    $scope: any;
}

interface IOptionalComponent {
    name: string,
    template: string,
    articleId: string | number
}

interface ISelect {
    value: string | number;
    display_value: string;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csApiSession',
        '$scope'
    ];
    private getDependencies: () => IWizardDependencies;

    public componentSelect: Array<ISelect> = [];
    public templateSelect: Array<ISelect> = [];
    public optionalArticle: Array<IOptionalComponent> = [];
    public isEmpty: boolean = true;


    public $onInit() {
        const { wizardInstance, wizardStep, csApiSession, $scope } = this.getDependencies();


        if (wizardStep.data && wizardStep.data.optionalArticle) {
            this.optionalArticle = Array.isArray(wizardStep.data.optionalArticle) ? wizardStep.data.optionalArticle : [wizardStep.data.optionalArticle];
        }

        if (wizardStep.data && wizardStep.data.channel) {
            const productWizardUtil: AllianzProductWizardUtil = new AllianzProductWizardUtil(wizardStep.data.channel);
            const distinctArticle: Array<IArticle> = productWizardUtil.getDistinctArticle();
            const optionalComponents: Array<IArticle> = distinctArticle.filter(obj => obj.optionalComponent === true || obj.optionalComponent === 'true');
            if (optionalComponents.length > 0) {
                this.isEmpty = false;
            }
            this.componentSelect = optionalComponents.map(obj => ({display_value: obj.name, value:obj.id}));
            csApiSession.masterdata.lookup({
                lookup: [
                    {
                        table: 'feature_value',
                        condition: [
                            {name: 'feature', value: 'svtx:optional-component-template'}
                        ]
                    }
                ]
            }).then(result => {
                if (result.records && result.records.record) {
                    this.templateSelect = result.records.record.map(obj=>({value: obj.value_key, display_value:obj.name}));
                }
            })

        }

        $scope.$watch('$ctrl.optionalArticle', () => {
            wizardStep.data.optionalArticle = this.optionalArticle;
        }, true);

        wizardInstance.enablePrev();
        wizardInstance.enableNext();
    }

    public add(): void {
        const name: string = '';
        const template: string = '';
        const articleId: string | number = '';
        this.optionalArticle.push({name, template, articleId})
    }


    public remove(index: number): void {
        this.optionalArticle.splice(index, 1);
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <censhare-scroll>
                    <div class="allianzProductWizard__container">
                        <div ng-if="!$ctrl.isEmpty">
                            <h6 class="csAssetProperties__category_title" cs-translate="'allianzProductWizard.addOptionalModules'"></h6>
                            <div ng-repeat="article in $ctrl.optionalArticle track by $index">
                            <dl class="cs-form-01">
                                <dt><label>Baustein wählen</label></dt>
                                <dd><cs-select-new model="article.articleId" values="$ctrl.componentSelect" placeholder="Baustein wählen"></cs-select-new></dd>
                            </dl>
                            
                            <dl class="cs-form-01">
                                <dt><label>Template</label></dt>
                                <dd><cs-select-new model="article.template" values="$ctrl.templateSelect" placeholder="Template wählen"></cs-select-new></dd>
                            </dl>          
                        
                            <dl class="cs-form-01">
                                <dt><label>Namen wählen</label></dt>
                                <dd><cs-input required ng-model="article.name"></cs-input></dd>
                            </dl>
                            
                            <dl class="cs-form-01">
                                <dd>
                                    <cs-button class="cs-is-medium cs-has-icon-only" ng-click="$ctrl.remove($index)" title="Optionalen Baustein entfernen" style="float: right">
                                        <i class="cs-icon cs-icon-circle-minus"></i>
                                    </cs-button>
                                </dd>
                            </dl>

                            <hr class="cs-line-01 cs-m-t-xs" ng-if="!$last"/>
                        </div>
                        <cs-button class="cs-is-medium cs-has-icon-only" ng-click="$ctrl.add()" title="Optionales Modul hinzufügen">
                              <i class="cs-icon cs-icon-circle-plus"></i>
                        </cs-button>
                        </div>
                        
                        <cs-empty-state cs-empty-state-icon="'cs-icon-asset'" ng-if="$ctrl.isEmpty">
                            <span class="cs-state-headline">No Optional Components available</span>
                        </cs-empty-state>
                    </div>
                </censhare-scroll>
            </div>
        </div>
    </article>
`;

export const allianzProductWizardStep4: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};