import { IcsBehavior } from '@cs/client/base/csAssetActions/behavior';
import { IcsNavigationManager } from '@cs/client/frames/csMainFrame/csWorkspaceManager/csNavigationManager/navigation-manager';
import { IcsWizardManager } from '@cs/client/frames/csMainFrame/csWizards/csWizardManager/csWizardManager';
import { IcsAssetUtil } from "@cs/framework/csApplication/csAssetUtil/cs-asset-util.model";

export class SvtxPowerpointSplitWizardOpenActionConstant implements IcsBehavior {
    public static $name = 'svtxPowerpointSplitWizardCreateBehavior';
    public static $inject = [
        'properties',
        'name',
        'context',
        'csNavigationManager',
        'csWizardManager',
        'csAssetUtil'
    ];

    constructor(private properties: any,
                public name: string,
                public context: any,
                private csNavigationManager: IcsNavigationManager,
                private csWizardManager: IcsWizardManager,
                private csAssetUtil:IcsAssetUtil) {
    }

    public getName(): string {
        return this.name;
    }

    public getActionAPI(): any {
        return {
            icon: this.properties.icon,
            title: this.properties.title,
            priority: this.properties.priority,
            callback: () => {
                const assetId = this.csAssetUtil.getAssetIdFromAssetRef(this.context.self);
                this.csWizardManager.createWizard(this.csNavigationManager, 'svtxPowerpointSplitWizard', { assetId });
            }
        };
    }
}
