import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { sortArticle} from "./allianz-product-wizard.model";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csQueryBuilder: any;
    csApiSession: IcsApiSession;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csQueryBuilder',
        'csApiSession'
    ];
    private getDependencies: () => IWizardDependencies;
    public options: Array<{value, display_value, type, selected, id}> = [];

    public $onInit() {
        const { wizardStep, wizardInstance, csQueryBuilder, csApiSession } = this.getDependencies();
        let channel: Array<any> = wizardStep.data && wizardStep.data.channel || [];
        if (!Array.isArray(channel)) {
            channel = [channel];
        }
        let articleTypes: Array<String> = [];
        channel.forEach(ch => {
            if (ch.article && ch.article.length > 0) {
                ch.article.forEach(a => {
                  const type = a.type;
                  if (articleTypes.indexOf(type) === -1) {
                      articleTypes.push(type);
                  }
                })
            }
        })

        const qb = new csQueryBuilder();
        qb.condition('censhare:asset.type', 'IN', articleTypes.join(','));
        qb.condition('censhare:asset-flag', 'is-template');
        qb.condition('censhare:template-hierarchy', 'root.content-building-block.recurring-modules.');
        csApiSession.asset.query(qb.build()).then(result => {
            if (result.container) {
                this.options = result.container.map(entry => {
                    const asset = entry.asset;
                    return {
                        value: asset.traits.ids.id,
                        display_value: asset.traits.type.label_type,
                        type: asset.traits.type.type,
                        id: asset.traits.ids.id
                    }
                }).sort(sortArticle);
            }
        });
        wizardInstance.enableNext();
        wizardInstance.enablePrev();
    }

    public inputChange() {
        const { wizardStep } = this.getDependencies();
        wizardStep.data.recurringModules = {
            options: this.options.filter(opt => opt.hasOwnProperty('selected') && opt.selected === true)
        }
        console.log('Stepdata', wizardStep.data);
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="allianzProductWizard__container">
                <h6 class="csAssetProperties__category_title" cs-translate="'allianzProductWizard.addRecurringModules'"></h6>
                    <div ng-repeat="opt in $ctrl.options track by $index">
                        <cs-checkbox label="{{ opt.display_value }}" ng-model="opt.selected" ng-change="$ctrl.inputChange()"></cs-checkbox>
                    </div>
                </div>
            </div>
        </div>
    </article>
`;

export const allianzProductWizardRecurringModulesStep: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};