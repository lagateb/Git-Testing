import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IDialogInstance } from '@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types';
import { DefaultDialogActions } from '@cs/client/frames/csMainFrame/csDialogs/csModalWindow/modal-window.component';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';

export class AllianzDownloadTextPdfDialogService {
    public static $inject: string[] = ['$q'];
    public static $name: string = 'allianzDownloadTextPdfDialog';

    public open(dialogManagerPromise: any, model: any) {
        return dialogManagerPromise.then((dialogManager: any) => {
            const defaults = new DefaultDialogActions(dialogManager);
            return (
                dialogManager.openNewDialog({
                    kind: 'allianzDownloadTextPdfDialog',
                    actions: [defaults.close, defaults.submit],
                    dialogCssClass: 'allianzDownloadTextPdfDialog',
                    data: model
                })
            );
        });
    }
}

interface IDependencies {
    dialogInstance: IDialogInstance;
    csTranslate: any;
    csApiSession: IcsApiSession;
}

@groupedInjections
class AllianzDownloadTextPdfController {
    public static $inject: string[] = ['dialogInstance', 'csTranslate', 'csApiSession'];
    public static $name: string = 'allianzDownloadTextPdfCtrl';

    protected getDependencies: () => IDependencies;

    public options: Array<any> = [];
    //public withMediachannel = false;

    public additionalOptions: Array<any> = []

    private trafo: string = 'svtx:download.text.pdf.options';

    public $onInit() {
        const { dialogInstance, csApiSession } = this.getDependencies();
        const data: any = dialogInstance.getData();
        const assetId: number = data && data.traits && data.traits.ids && data.traits.ids.id || -1;
        const contextAsset = { contextAsset: assetId };

        const assignOptions = (result) => {
            this.options = result && result.options || []
            this.additionalOptions = [ { id:"1", display_value:"Medienvorschau in das Dokument übernehmen", value:"true", selected:"true"}]
            //this.withMediachannel = true;

        };
        const assignObservable = () => {
            // Hier werden die Daten zurückgegeben
            // TODO Object anstatt array
            dialogInstance.getResultObservable().setValue([this.options,this.additionalOptions]);
        }

        csApiSession.transformation(this.trafo, contextAsset)
            .then(assignOptions)
            .catch(console.log)
            .finally(assignObservable)

        dialogInstance.setTitle('Module auswählen');
    }

    public $postLink() { }

    public $onDestroy() { }
}

const template = `
    <div class="csFileDownloadSelect__file" ng-repeat="option in $ctrl.options track by $index">
        <cs-checkbox class="cs-is-alt" label="{{ option.display_value }}" ng-model="option.selected" class="cs-is-small cs-no-p-r"></cs-checkbox>
      
    </div>
        <br/>
        <bold>Optionen</bold>
        <hr/>
    <div class="csFileDownloadSelect_option"  ng-repeat="option in $ctrl.additionalOptions track by $index">
      
        
        <!--<cs-checkbox ngTrueValue="true"  class="cs-is-alt" label="Medienvorschau in das Dokument übernehmen" ng-model="$ctrl.withMediachannel" class="cs-is-small cs-no-p-r"></cs-checkbox>
        -->
        
         <cs-checkbox class="cs-is-alt" label="{{ option.display_value }}" ng-model="option.selected" class="cs-is-small cs-no-p-r"></cs-checkbox>
    </div>
    
`;

export const allianzDownloadTextPdfComponent: ng.IComponentOptions = {
    template: template,
    controller: AllianzDownloadTextPdfController
};
