import { IcsNavigationManager } from '@cs/client/frames/csMainFrame/csWorkspaceManager/csNavigationManager/navigation-manager';
import { IcsWizardManager } from '@cs/client/frames/csMainFrame/csWizards/csWizardManager/csWizardManager';
import { IcsBehaviorApi } from '@cs/client/base/csAssetActions/behavior';

export class FlexiModuleWizardOpenAction {
    public static $name: string = 'allianzFlexiModuleWizardCreateBehavior';
    public static $inject: string[] = [
        'properties',
        'name',
        'csNavigationManager',
        'csWizardManager'
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
                        csWizardManager.createWizard(csNavigationManager, 'allianzFlexiModuleWizard');
                    } else {
                        console.log('No navigation manager injected.');
                    }
                }
            };
        };
    }
}

export class FlexiModuleWizardAssetOpenAction {
    public static $name: string = 'allianzFlexiModuleWizardAssetCreateBehavior';
    public static $inject: string[] = [
        'properties',
        'name',
        'csNavigationManager',
        'csWizardManager',
        'context'
    ];

    public getName: () => string;
    public getActionAPI: () => IcsBehaviorApi;

    constructor(properties: any,
                name: string,
                csNavigationManager: IcsNavigationManager,
                csWizardManager: IcsWizardManager,
                context: any,) {

        this.getName = (): string => name;
        this.getActionAPI = (): IcsBehaviorApi => {
            return {
                icon: properties.icon,
                title: properties.title,
                priority: properties.priority,
                type: properties.type,
                callback: () => {
                    if (csNavigationManager) {
                        csWizardManager.createWizard(csNavigationManager, 'allianzFlexiModuleWizard',{
                            self: context.self
                        });
                    } else {
                        console.log('No navigation manager injected.');
                    }
                }
            };
        };
    }
}