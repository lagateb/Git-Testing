import { IcsBehaviorApi } from '@cs/client/base/csAssetActions/behavior';
import { IDialogManager } from '@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';

export class AllianzRecurringModulesAction {
    public static $name: string = 'allianzRecurringModulesBehavior';
    public static $inject: string[] = [
        'properties',
        'name',
        'context',
        'allianzRecurringModulesDialog',
        'dialogManager',
        'csApiSession',
        'csNotify'
    ];

    public getName: () => string;
    public getActionAPI: () => IcsBehaviorApi;

    constructor(public properties: any,
                public name: string,
                public context: any,
                public allianzRecurringModulesDialog: any,
                public dialogManager: IDialogManager,
                public csApiSession: IcsApiSession,
                public csNotify: INotify){

        this.getName = (): string => name;
        this.getActionAPI = (): IcsBehaviorApi => {
            return {
                icon: properties.icon,
                title: properties.title,
                priority: properties.priority,
                type: properties.type,
                callback: () => {
                    this.allianzRecurringModulesDialog.open(this.dialogManager, this.context).then(result=> {
                        if (result && Array.isArray(result)) {
                            const ids: Array<number> = [];
                            result.forEach((option) => {
                                if (option.checked === true) {
                                    if (option.is_recurring_module === false) {
                                        ids.push(option.product_module);
                                    }
                                } else {
                                    if (option.is_recurring_module === true) {
                                        ids.push(option.product_module);
                                    }
                                }
                            });
                            if (ids.length > 0) {
                                const params = {
                                    contextAsset: this.context.traits.ids.id,
                                    variables: [
                                        {key: 'ids', value: ids.join(',')}
                                    ]
                                };
                                this.csApiSession.transformation('svtx:recurring.module.switch', params).then(()=> {
                                    this.csNotify.success('allianzRecurringModulesAction.title', 'Moduländerungen wurden übernommen')
                                });
                            }
                        }
                    }).catch(err => {
                        console.log(err);
                    });
                }
            };
        };
    }
}