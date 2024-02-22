import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance, IcsWizardDataManager } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {IDialogManager} from "@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types";
import {ICsTranslate} from "@cs/framework/csApplication/csTranslate/translate.provider";
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';
import {IArticle, IChannel, IText, sortArticle} from "./allianz-product-wizard.model";
import {AllianzProductWizardUtil} from "./allianz-product-wizard.controller";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csConfirmDialog: any;
    dialogManager: IDialogManager;
    csTranslate: ICsTranslate;
    wizardDataManager: IcsWizardDataManager;
    csNotify: INotify;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csConfirmDialog',
        'dialogManager',
        'csTranslate',
        'wizardDataManager',
        'csNotify'
    ];
    private getDependencies: () => IWizardDependencies;
    public channel: Array<IChannel>;
    public distinctArticle: Array<IArticle>;
    public distinctArticleWithComponents: Array<IArticle>;
    public distinctTexts: Array<IText>;
    public tempFoundArticle: IArticle;

    public $onInit() {
        const { wizardStep, wizardInstance } = this.getDependencies();
        if (wizardStep.data && wizardStep.data.channel) {
            const productWizardUtil: AllianzProductWizardUtil = new AllianzProductWizardUtil(wizardStep.data.channel);
            this.channel = productWizardUtil.getChannel();
            this.distinctArticle = productWizardUtil.getDistinctArticle();
            this.distinctTexts = productWizardUtil.getDistinctTexts();
            this.distinctArticleWithComponents = [];
            const tempArticle = [];
            this.distinctArticle.forEach(article => {
                tempArticle.push(article);
                if (article.optionalComponents) {
                    const opc = Array.isArray(article.optionalComponents) ? article.optionalComponents : [article.optionalComponents];
                    opc.forEach(o => {
                        const a: IArticle = {
                            id : article.id,
                            name: o.name,
                            type: article.type,
                            isInstance: true
                        };
                        tempArticle.push(a);
                    });
                }
            });
            this.distinctArticleWithComponents = tempArticle.sort(sortArticle)
        }

        wizardStep.onAction(['done'], this.onDone);
        wizardInstance.enablePrev();
        wizardInstance.enableDone();
    }

    private onDone = () => {
        const { csNotify } = this.getDependencies();

        if (!this.rendererIsNeeded()) {
            return this.openConfirmDialog();
        }

        return this.rendererIsAvailable().then(result => {
            if (result === false) {
                csNotify.info('Indesign Render Service nicht verfügbar', 'Bitte versuchen Sie es zu einem späteren Zeitpunkt erneut.');
                return false;
            } else {
                return this.openConfirmDialog();
            }
        }).catch(() => {
            return false;
        })
    };

    private rendererIsNeeded = () => {
        const channelWithTemplate = this.channel.find(channel=> channel.template != null);
        return !!channelWithTemplate;
    };

    private rendererIsAvailable(): any {
        const { wizardDataManager } = this.getDependencies();
        return wizardDataManager.executeStepMethod('rendererIsAvailable').then(result => {
            let isAvailable: boolean = false;
            if (result.result && result.result.hasOwnProperty('data')) {
                isAvailable = result.result.data;
            }
            return isAvailable;
        });
    }

    private openConfirmDialog:any = () => {
        const { csTranslate, csConfirmDialog, dialogManager } = this.getDependencies();
        return csConfirmDialog(dialogManager,
            csTranslate.instant('allianzProductWizard.title'),
            `Es werden ${this.distinctArticle.length} Bausteine und ${this.distinctTexts.length} Texte angelegt.`
        ).then(() => {
            return true
        }).catch(() => {
            return false
        });
    };

    public findArticleInChannel(channel: IChannel, article: IArticle): IArticle {
        if (!channel.article || !Array.isArray(channel.article) || channel.article.length === 0) {
            return this.tempFoundArticle = null;
        }
        const index = channel.article.findIndex(obj => obj.id === article.id);
        if (index < 0) {
            return this.tempFoundArticle = null;
        }
        return this.tempFoundArticle = channel.article[index];
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <censhare-scroll>
                    <div class="allianzProductWizard__container" style="max-width: none">
                        <table class="cs-table-03">
                            <thead>
                                <tr>
                                    <th><strong cs-translate="'allianzProductWizard.article'"></strong></th>
                                    <th ng-repeat="channel in $ctrl.channel track by $index"><strong>{{::channel.name}}</strong></th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr ng-repeat="article in $ctrl.distinctArticleWithComponents track by $index" ng-class="{'cs-lvl-02': article.isInstance}">
                                    <td>
                                        <cs-open-asset-page asset-id="{{article.id}}" class="cs-is-subtle">
                                            <span>{{::article.name}}</span>
                                        </cs-open-asset-page>
                                    </td>
                                    <td ng-repeat="channel in $ctrl.channel track by $index">
                                        <div ng-switch="$ctrl.findArticleInChannel(channel, article)" ng-if="!article.isInstance">
                                            <div ng-switch-when="null">
                                                <span><i cs-tooltip="{{'allianzProductWizard.tooltipCircleRemove' | csTranslate}}" style="cursor: help" class="cs-icon cs-icon-circle-remove cs-iconsize-200 cs-color-04"></i></span>
                                            </div>
                                            
                                            <div ng-switch-default>
                                                <span>{{::$ctrl.tempFoundArticle.text.label}}</span>
                                                <span><i cs-tooltip="{{'allianzProductWizard.tooltipCircleAdd' | csTranslate}}" style="cursor: help" class="cs-icon cs-icon-circle-info cs-iconsize-200 cs-color-36"></i></span>
                                            </div>
                                        </div>
                                    </td>
                               </tr> 
                            </tbody>
                        </table>
                    </div>
                </censhare-scroll>
            </div>
        </div>
    </article>
`;

export const allianzProductWizardStep5: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};