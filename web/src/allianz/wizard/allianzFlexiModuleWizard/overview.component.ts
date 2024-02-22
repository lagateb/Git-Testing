import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { ICommandPromise } from '@cs/framework/csApi/csCommander/csCommander';


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

    public moduleName: any;
    public textSize: any;
    public articleType: string;

    public $onInit() {
        const { wizardStep, wizardInstance } = this.getDependencies();
        const prevStep: IcsWizardStep = wizardInstance.stepByName('flexiModuleChooseModule');
        if (prevStep && prevStep.data) {
            this.articleType = prevStep.data.articleType;
            if (this.articleType == 'article.flexi-module.') {
                this.moduleName = 'Flexi-Modul';
            } else if (this.articleType == 'article.free-module.') {
                this.moduleName = 'Freies-Modul';
            }
            if(this.articleType == 'article.flexi-module.' || this.articleType === 'article.free-module.'){
                const templateRef = prevStep.data.templateRef;
                const id = typeof (templateRef) !== 'undefined' ? + templateRef.split('/')[2] : void 0;
                if (id) {
                    this.getMainTextOf(id).then(result => {
                        const asset = result && result.asset && result.asset[0];
                        this.textSize = asset && asset.traits && asset.traits.type && asset.traits.type.label_type;
                        console.log('this.TextSize', this.textSize);
                    }).catch(e => console.log('Error on Text Asset Query', e));
                }
            }
            else if (this.articleType == 'article.optional-module.'){
                const optionalArray = Array.isArray(prevStep.data.optionalArray.value) ? prevStep.data.optionalArray.value : [prevStep.data.optionalArray.value];
                const sizeArrays: any = [];
                this.textSize = sizeArrays;
                optionalArray.forEach(module => {
                    const id = typeof (module.value) !== 'undefined' ? + module.value.split('/')[2] : void 0;
                    if (id) {
                        this.getMainTextOf(id).then(result => {
                            if (result && result.asset) {
                                sizeArrays.push({"name":module.display_value, "size":result.asset[0].traits.type.label_type});
                            }
                        }).catch(e => console.log('Error on Text Asset Query', e));
                    }
                })
            }
        }



        wizardInstance.enablePrev();
        wizardInstance.enableDone();
        console.log('Enter Wizard Step ', wizardStep);
    }

    private getMainTextOf(id: number | string): ICommandPromise<any> {
        const { csQueryBuilder, csApiSession } = this.getDependencies();
        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'text.*');
        qb.relation('parent', 'user.main-content.')
            .condition('censhare:asset.id', id);
        qb.view().setTransformation('censhare:cs5.query.asset.list');
        qb.setLimit(1);
        return csApiSession.asset.query(qb.build());
    }
}

const template: string = `
   <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzFlexiModuleWizard__container">
                    <table class="cs-table-03">
                        <thead>
                            <tr ng-if="$ctrl.articleType == 'article.flexi-module.'">
                                <th>Baustein</th>
                                <th>TwoPager</th>
                                <th>PowerPoint</th>
                                <!--<th>Vertriebsportal</th>-->
                            </tr>
                            <tr ng-if="$ctrl.articleType == 'article.free-module.'">
                                <th>Baustein</th>
                                <th>PowerPoint</th>
                                <!--<th>Vertriebsportal</th>-->
                            </tr>
                            <tr ng-if="$ctrl.articleType == 'article.optional-module.'">
                                <th>Baustein</th>
                                <th>PowerPoint</th>
                                <!--<th>Vertriebsportal</th>-->
                            </tr>
                        </thead>
                        <tbody>
                       
                            <tr ng-if="$ctrl.articleType == 'article.flexi-module.'" >
                                <td>{{:: $ctrl.moduleName}}</td>
                                <td>{{:: $ctrl.textSize}}</td>
                                <td>{{:: $ctrl.textSize}}</td>
                                <!--<td>{{:: $ctrl.textSize}}</td>-->
                            </tr>
                            <tr ng-if="$ctrl.articleType == 'article.free-module.'" >
                                <td>{{:: $ctrl.moduleName}}</td>
                                <td>{{:: $ctrl.textSize}}</td>
                                <!--<td>{{:: $ctrl.textSize}}</td>-->
                            </tr>
                            <tr  ng-if="$ctrl.articleType == 'article.optional-module.'" ng-repeat="moduldetail in $ctrl.textSize">
                                <td>{{:: moduldetail.name}}</td>
                                <td>{{:: moduldetail.size}}</td>
                                <!--<td>{{:: moduldetail.size}}</td>-->
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </article>
`;

export const flexiModuleOverview: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};