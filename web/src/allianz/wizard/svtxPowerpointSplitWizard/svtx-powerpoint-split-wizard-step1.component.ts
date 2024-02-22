import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import { IcsAssetUtil } from "@cs/framework/csApplication/csAssetUtil/cs-asset-util.model";
import { IcsApiSession } from "@cs/framework/csApi/cs-api.model";
import { ICsTranslate } from "@cs/framework/csApplication/csTranslate/translate.provider";
import { ICommandPromise } from "@cs/framework/csApi/csCommander/csCommander";
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';

enum PptxCommandHandler {
    SPLIT = 'com.savotex.api.powerpoint.split',
    SECTION = 'com.savotex.api.powerpoint.section'
}

interface PptxCommandParam {
    assetId: number,
    issueName: string
}

interface IOption {
    value: string,
    display_value: string
}

interface IWizardDependencies {
    $scope: any;
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csAssetUtil: IcsAssetUtil;
    csApiSession: IcsApiSession;
    csTranslate: ICsTranslate;
    csQueryBuilder: any;
    csNotify: INotify;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject = [
        '$scope',
        'wizardStep',
        'wizardInstance',
        'csAssetUtil',
        'csApiSession',
        'csTranslate',
        'csQueryBuilder',
        'csNotify'
    ];
    private getDependencies: () => IWizardDependencies;
    private contextAssetId: number;

    public actionOptions: IOption [];
    public inputAction: string;
    public inputIssueName: string;
    public contextAsset: any;
    public extractImages: boolean = false;
    public checkDuplicates: boolean = false;
    public copyTargetGroups: boolean = false;
    public wfTarget: number;

    public $onInit(): void {
        const { $scope, wizardStep, wizardInstance, csTranslate } = this.getDependencies();
        const config = wizardInstance.config.getValue();
        this.contextAssetId = config.assetId ? config.assetId: -1;
        // Optionen für die auswählbaren powerpoint aktionen
        this.actionOptions = [
            {
                display_value: csTranslate.instant('svtxPowerpointSplitWizard.step1ActionSplitAllLabel'),
                value: PptxCommandHandler.SPLIT
            },
            {
                display_value: csTranslate.instant('svtxPowerpointSplitWizard.step1ActionSplitSectionsLabel'),
                value: PptxCommandHandler.SECTION
            }
        ];

        // asset auf dem die aktion aufgerufen wurde
        this.getAssetPromise(this.contextAssetId).then(result => {
            if (result.asset && result.asset.length > 0) {
                this.contextAsset = result.asset[0];
                this.inputIssueName = this.contextAsset.traits.display.name;
                console.log('Context asset', this.contextAsset);
            } else {
                console.log(`Empty query result for asset with id ${this.contextAssetId}`);
            }
        }).catch(error => {
            console.log(error);
        });

        wizardInstance.enableDone();

        wizardStep.onAction(['done'], this.onWizardDone);
        $scope.$watch('$ctrl.inputIssueName', this.onInputChange);
    }

    public $onDestroy(): void {

    }

    private onInputChange = (val) => {
      console.log(val);
    };

    private onWizardDone = () => {
        const { wizardInstance, csApiSession, csNotify, csTranslate } = this.getDependencies();
        wizardInstance.lock();
        wizardInstance.disableCancel();
        wizardInstance.disableDone();

        const param: PptxCommandParam = {
            assetId: this.contextAssetId,
            issueName: this.inputIssueName
        };

        return csApiSession.execute(this.inputAction, param).then(() => {
            csNotify.success(
                csTranslate.instant('svtxPowerpointSplitWizard.step1NotificationTitle'),
                csTranslate.instant('svtxPowerpointSplitWizard.step1NotificationSuccessMsg')
            );
            return true;
        }).catch(error => {
            csNotify.warning(
                csTranslate.instant('svtxPowerpointSplitWizard.step1NotificationTitle'),
                error
            );
            wizardInstance.unlock();
            wizardInstance.enableCancel();
            wizardInstance.enableDone();
            return false;
        });
    };


    private getAssetPromise(id: number): ICommandPromise<any> {
        const { csApiSession, csQueryBuilder } = this.getDependencies();
        const q = new csQueryBuilder();
        q.condition('censhare:asset.id', id).view().setTransformation('censhare:cs5.query.asset.list');
        return csApiSession.asset.query(q.build());
    }
}

/* Zielgruppen übernehmen (Themen, Kampagnen, Zielgruppen) */
/* Workflowziel zuweisen: */
/* Dubletten überprüfen */

/* more options dublette */
const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <div class="svtxPowerpointSplitWizard__container">
                    <h6 class="csAssetProperties__category_title" cs-translate="'svtxPowerpointSplitWizard.step1WorkingOnTitle'"></h6>
                    <ul class="csAssetProperties__list">
                        <li class="csAssetProperties__list__item">
                            <span class="csAssetProperties__list__label" cs-translate="'csCommonTranslations.asset_id'"></span>
                            <div class="csAssetProperties__list__value">
                                <span>{{$ctrl.contextAsset.traits.ids.id}}</span>
                            </div>
                        </li>
                        <li class="csAssetProperties__list__item">
                            <span class="csAssetProperties__list__label" cs-translate="'csCommonTranslations.name'"></span>
                            <div class="csAssetProperties__list__value">
                                <span>{{$ctrl.contextAsset.traits.display.name}}</span>
                            </div>
                        </li>
                        <li class="csAssetProperties__list__item">
                            <span class="csAssetProperties__list__label" cs-translate="'csCommonTranslations.type'"></span>
                            <div class="csAssetProperties__list__value">
                                <span>{{$ctrl.contextAsset.traits.type.label_type}}</span>
                            </div>
                        </li>
                        <li class="csAssetProperties__list__item" ng-if="$ctrl.contextAsset.actual_root.page_count > 0">
                            <span class="csAssetProperties__list__label" cs-translate="'svtxPowerpointSplitWizard.step1PageCountLabel'"></span>
                            <div class="csAssetProperties__list__value">
                                <span>{{$ctrl.contextAsset.actual_root.page_count}}</span>
                            </div>
                        </li>
                    </ul>
                    <h6 class="csAssetProperties__category_title" cs-translate="'svtxPowerpointSplitWizard.step1ChooseActionTitle'"></h6>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'svtxPowerpointSplitWizard.step1ChooseActionLabel'"></label></dt>
                        <dd>
                            <cs-select-new model-as-array="false"
                                           model="$ctrl.inputAction"
                                           placeholder="{{ 'svtxPowerpointSplitWizard.step1ChooseActionPlaceholder' | csTranslate }}"
                                           order-by="display_value"
                                           values="$ctrl.actionOptions"
                                           required>
                            </cs-select-new>
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'svtxPowerpointSplitWizard.step1IssueNameLabel'"></label></dt>
                        <dd>
                            <cs-input required ng-model="$ctrl.inputIssueName" placeholder="{{ 'svtxPowerpointSplitWizard.step1EnterIssueNamePlaceholder' | csTranslate }}"></cs-input>
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'csCommonTranslations.assetImportResetWfTarget'"></label></dt>
                        <dd>
                            <cs-select-new options-generator="{id: 'party/id', eager: true, name: 'generatedOptions', filter: 'issystem:0, isactive:1, isgroup:0'}"
                                           model="$ctrl.wfTarget"
                                           model-as-array="false">
                            </cs-select-new>
                        </dd>
                    </dl>
                    <h6 class="csAssetProperties__category_title" cs-translate="'svtxPowerpointSplitWizard.step1MoreOptionsTitle'"></h6>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'svtxPowerpointSplitWizard.step1ExtractImagesLabel'"></label></dt>
                        <dd>
                            <cs-checkbox ng-model="$ctrl.extractImages" disabled></cs-checkbox>
                        </dd>
                    </dl> 
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'svtxPowerpointSplitWizard.step1CheckDuplicatesLabel'"></label></dt>
                        <dd>
                            <cs-checkbox ng-model="$ctrl.checkDuplicates" disabled></cs-checkbox>
                        </dd>
                    </dl>
                    <dl class="cs-form-01">
                        <dt><label cs-translate="'svtxPowerpointSplitWizard.step1CopyTargetGroupsLabel'"></label></dt>
                        <dd>
                            <cs-checkbox ng-model="$ctrl.copyTargetGroups" disabled></cs-checkbox>
                        </dd>
                    </dl>
                </div>
            </div>
        </div>
    </article>
`;

export const svtxPowerpointSplitWizardStep1: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: { }
};
