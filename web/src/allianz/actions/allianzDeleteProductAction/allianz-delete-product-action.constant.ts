import { IcsBehaviorApi } from '@cs/client/base/csAssetActions/behavior';
import {IDialogManager} from "@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types";
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsNavigationManager } from '@cs/client/frames/csMainFrame/csWorkspaceManager/csNavigationManager/navigation-manager';
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';

export class AllianzDeleteProductAction {
    public static $name: string = 'allianzDeleteProductBehavior';
    public static $inject: string[] = [
        'properties',
        'name',
        'csConfirmDialog',
        'dialogManager',
        'context',
        'csApiSession',
        'csNavigationManager',
        'csNotify',
        'pageInstance'
    ];

    public getName: () => string;
    public getActionAPI: () => IcsBehaviorApi;

    constructor(properties: any,
                name: string,
                csConfirmDialog: any,
                dialogManager: IDialogManager,
                context: any,
                csApiSession: IcsApiSession,
                csNavigationManager: IcsNavigationManager,
                csNotify: INotify,
                pageInstance) {

        this.getName = (): string => name;
        this.getActionAPI = (): IcsBehaviorApi => {
            return {
                icon: properties.icon,
                title: properties.title,
                priority: properties.priority,
                type: properties.type,
                callback: () => {
                    const assetId: string = context.traits.ids.id;
                    const assetName: string = context.traits.display.name;
                    const title: string = 'Produkt löschen';
                    const message: string = `Möchten Sie das Produkt ${assetName} sowie alle enthaltenen Medien, Bausteine und Texte löschen? Dieser Schritt kann nicht rückgängig gemacht werden.`;
                    const deleteProduct = () => csApiSession.transformation('svtx:delete.product.and.children', { contextAsset: assetId })
                    const pageId: string | number = pageInstance.getPathContextReader().getValue().get('id')
                    const navigateAndNotify = (result) => {
                        if (result) {
                            if (pageId == assetId) {
                                csNavigationManager.closeCurrentPage(true);
                            }
                            csNotify.success('Erfolgreich', 'Produkt wurde erfolgreich gelöscht');
                        } else {
                            csNotify.info('Fehlgeschlagen', 'Produkt konnte nicht gelöscht werden');
                        }
                    };

                    csConfirmDialog(dialogManager, title, message)
                        .then(deleteProduct)
                        .then(navigateAndNotify)
                }
            };
        };
    }
}