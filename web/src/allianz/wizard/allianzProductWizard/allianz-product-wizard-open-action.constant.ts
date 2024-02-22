import { IcsNavigationManager } from '@cs/client/frames/csMainFrame/csWorkspaceManager/csNavigationManager/navigation-manager';
import { IcsWizardManager } from '@cs/client/frames/csMainFrame/csWizards/csWizardManager/csWizardManager';
import { IcsBehaviorApi } from '@cs/client/base/csAssetActions/behavior';

export class AllianzProductWizardOpenAction {
    public static $name: string = 'allianzProductWizardCreateBehavior';
    public static $inject: string[] = [
        'properties',
        'name',
        'csNavigationManager',
        'csWizardManager',
        'csApiSession'
    ];

    public getName: () => string;
    public getActionAPI: () => IcsBehaviorApi;

    constructor(properties: any,
                name: string,
                csNavigationManager: IcsNavigationManager,
                csWizardManager: IcsWizardManager) {

        this.getName = (): string => name;
        this.getActionAPI = (): IcsBehaviorApi => {
            return {
                icon: properties.icon,
                title: properties.title,
                priority: properties.priority,
                type: properties.type,
                callback: () => {
                    if (csNavigationManager) {
                        csWizardManager.createWizard(csNavigationManager, 'allianzProductWizard');
                    } else {
                        console.log('No navigation manager injected.');
                    }
                }
            };
        };
    }
}