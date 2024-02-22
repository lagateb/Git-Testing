import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IDialogManager } from '@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types';
import { DefaultDialogActions } from '@cs/client/frames/csMainFrame/csDialogs/csModalWindow/modal-window.component';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import {IActionGroup} from "@cs/client/base/csActions/csActionInterfaces";

class Dialog {
    public static $inject: string[] = [];

    constructor() {
    }

    public open(dialogManagerPromise: any, ctx: string) {
        return dialogManagerPromise.then((dialogManager: IDialogManager) => {
            const defaultActions: DefaultDialogActions = new DefaultDialogActions(dialogManager);

            return dialogManager.openNewDialog({
                kind: 'allianzRecurringModulesDialog',
                actions: [defaultActions.close, defaultActions.submit],
                dialogCssClass: 'allianzRecurringModulesDialog',
                data: {
                    context: ctx
                }
            });
        });
    }
}

interface IDependencies {
    dialogInstance: any;
    csApiSession: IcsApiSession;
    csQueryBuilder: any;
}

@groupedInjections
class DialogController {
    public static $inject: string[] = ['dialogInstance', 'csApiSession'];
    public static $name: string = 'allianzRecurringModulesDialogController';
    private getDependencies: () => IDependencies;

    public options: any = [];
    public resultObservable: any;

    public $onInit(): void {
        const { dialogInstance, csApiSession } = this.getDependencies();
        const data = dialogInstance.getData();
        dialogInstance.setTitle('allianzRecurringModulesAction.title');
        this.resultObservable = dialogInstance.getResultObservable();
        const params = {
            contextAsset: data.context.traits.ids.id,
        };
        csApiSession.transformation('svtx:recurring.modules.dialog.options',params).then(result => {
            if (result && result.options && result.options.length > 0) {
                this.options = result.options.sort((a,b) => {
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
                        'article.faq.'
                    ]
                    return itemOrder.indexOf(a.type) - itemOrder.indexOf(b.type);
                });
                console.log('this.options', this.options);
            }
        }).catch(()=> {
            this.options = [];
        })
    }

    public $doCheck(): void {
        this.resultObservable.setValue(this.options);
    }
}


const template: string =`
    <h6 class="csAssetProperties__category_title">Basis Module</h6>
    <div ng-repeat="option in $ctrl.options | filter: { article_type: 'basic' } track by $index">
        <dl class="cs-form-01">
            <dt><label ng-bind="::option.name"></label></dt>
            <dd>
                <cs-toggle ng-model="option.checked"></cs-toggle>
            </dd>
        </dl>
    </div>
    <h6 class="csAssetProperties__category_title">Optionale Module</h6>
    <div ng-repeat="option in $ctrl.options | filter: { article_type: 'optional' } track by $index">
        <dl class="cs-form-01">
            <dt><label ng-bind="::option.name"></label></dt>
            <dd>
                <cs-toggle ng-model="option.checked"></cs-toggle>
            </dd>
        </dl>
    </div>
`;

const allianzRecurringModulesDialogComponent: ng.IComponentOptions = {
    controller: DialogController,
    template: template
};


/* NEXT DIALOG FOR UPDATE */

class Dialog2 {
    public static $inject: string[] = [];

    constructor() {
    }

    public open(dialogManagerPromise: any, ctx: string) {
        return dialogManagerPromise.then((dialogManager: IDialogManager) => {
            const defaultActions: DefaultDialogActions = new DefaultDialogActions(dialogManager);

            return dialogManager.openNewDialog({
                kind: 'allianzRecurringModulesUpdateDialog',
                actions: [defaultActions.close, defaultActions.submit],
                dialogCssClass: 'allianzRecurringModulesUpdateDialog',
                data: {
                    context: ctx
                }
            });
        });
    }
}

@groupedInjections
class DialogController2 {
    public static $inject: string[] = ['dialogInstance', 'csApiSession', 'csQueryBuilder'];
    public static $name: string = 'allianzRecurringModulesUpdateDialogController';
    private getDependencies: () => IDependencies;

    /*public options: any;*/
    public resultObservable: any;
    public productsDoneCount: number = 0;
    public email: boolean = false;
    public message: string;
    public data: any = {
        options:[],
        message:''
    }
    private dialogActions: IActionGroup;
    public showErrorValidation: boolean = false;

    public $onInit(): void {
        const { dialogInstance, csApiSession } = this.getDependencies();
        const data = dialogInstance.getData();
        dialogInstance.setTitle('allianzRecurringModulesAction.title');
        this.resultObservable = dialogInstance.getResultObservable();
        this.dialogActions = dialogInstance.getActions();
        const params = {
            contextAsset: data.context.assetId
        };
        csApiSession.transformation('svtx:recurring.modules.update.ref.options',params).then(result => {
            if (result && result.options && result.options.length > 0) {
                this.data.options = result.options;
            }
        }).catch(()=> {
            this.data.options = [];
        })
    }

    public $doCheck(): void {
        this.resultObservable.setValue(this.data);
    }

    public validate(): void {
        // check options if any checked
        const hasCheckedItem = this.data.options.find(o => o.checked===true);
        if (hasCheckedItem && this.data.message==='') {
            DialogController2.disableOkAction(this.dialogActions);
            this.showErrorValidation = true;
        } else {
            DialogController2.enableOkAction(this.dialogActions);
            this.showErrorValidation = false;
        }
    }

    private static enableOkAction(actions: IActionGroup) {
        if (angular.isFunction(actions.getChildren)) {
            actions.getChildren().filter((a) => a.getTitleKey() === 'csCommonTranslations.ok').forEach((a) => a.enable());
        }
    }

    private static disableOkAction(actions: IActionGroup) {
        if (angular.isFunction(actions.getChildren)) {
            actions.getChildren().filter((a) => a.getTitleKey() === 'csCommonTranslations.ok').forEach((a) => a.disable());
        }
    }
}

const template2: string = `
    <div>
        Mit der Aktualisierung des Textes werden die Inhalte der folgenden Produkte geändert. Bitte wählen Sie, ob Sie die Marketing Manager über
        die Änderung via E-Mail benachrichtigen lassen möchten:
    </div>
    <div ng-repeat="option in $ctrl.data.options track by $index"> 
        <cs-checkbox ng-model="option.checked" label="{{::option.display_name}}" ng-change="$ctrl.validate()"></cs-checkbox>
    </div>
    <span class="cs-label">E-Mail Text</span>
    <div class="cs-form-validation-msg" ng-show="$ctrl.showErrorValidation">Bitte einen Text eingeben</div>
    <cs-input  ng-model="$ctrl.data.message" multilines="7" ng-change="$ctrl.validate()"></cs-input>
    
`

const allianzRecurringModulesUpdateDialogComponent: ng.IComponentOptions = {
    controller: DialogController2,
    template: template2
};


export { Dialog, allianzRecurringModulesDialogComponent, Dialog2, allianzRecurringModulesUpdateDialogComponent };
