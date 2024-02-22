import { IcsBehaviorApi } from '@cs/client/base/csAssetActions/behavior';
import { IDialogManager } from '@cs/client/frames/csMainFrame/csDialogs/csDialogManager/dialog-manager.types';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';

export class AllianzDownloadTextPdfAction {
    public static $name: string = 'allianzDownloadTextPdfBehavior';
    public static $inject: string[] = [
        'dialogManager',
        'properties',
        'name',
        'context',
        'allianzDownloadTextPdfDialog',
        'csDownloadUtils',
        'csApiSession',
        'csNotify'
    ];

    public getName: () => string;
    public getActionAPI: () => IcsBehaviorApi;

    constructor(private dialogManager: IDialogManager,
                public properties: any,
                public name: string,
                public context: any,
                private allianzDownloadTextPdfDialog: any,
                public csDownloadUtils: any,
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
                    this.allianzDownloadTextPdfDialog.open(this.dialogManager, context).then(retData => {

                            let options = retData[0];
                            let withMediachannels = retData[1][0].selected

                            if (!Array.isArray(options)) {
                                options = [options];
                            }



                            const selectedTexts: Array<number> = options
                                .filter(item => item.selected === true)
                                .map(item => item.value);

                            const param = {
                                contextAsset: context.traits.ids.id,
                                variables: [
                                    //   key2:'withMediachannels', value2:withMediachannels
                                    { key: 'text-ids', value: selectedTexts.join(',')},
                                    { key: 'withMediachannels', value: withMediachannels},
                                ]
                            };

                            if (selectedTexts.length > 0) {
                                csNotify.info('PDF wird generiert', 'Ihr Abstimmungsdokument wird generiert. Bitte haben Sie einen Moment Geduld.')
                                csApiSession.transformation('svtx:download.text.pdf.combine.pdf', param).then(result => {
                                    csNotify.success('Download gestartet', 'Ihr Abstimmungsdokument wird nun heruntergeladen.')
                                    if (result && result.output &&  result.output.url) {
                                        const date = new Date();
                                        const dateString = `${date.getDate()}-${date.getMonth() + 1}-${date.getFullYear()}`;
                                        const filename = 'Abstimmungsdokument_'+(withMediachannels?'':'oM_')   + dateString + '.pdf';
                                        const name = result.fileName ? result.fileName : filename;
                                        console.log('Attempt to download', result.output.url);
                                        csDownloadUtils.downloadFile(result.output.url, name, false);
                                        /*if (result.output.id) {
                                            csApiSession.execute('com.censhare.api.dam.assetmanagement.deletion', {
                                                keys: [{
                                                    id: result.output.id,
                                                    version: 0
                                                }],
                                                state: 'physical'
                                            });
                                        }*/
                                    }
                                }).catch(err => {
                                    console.log(err);
                                    csNotify.warning('Fehler', err);
                                })
                            }
                        }
                    ).catch(() => {
                        console.log("cancel")
                    })
                }
            };
        };
    }
}