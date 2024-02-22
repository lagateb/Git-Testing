import * as censhare from 'censhare';
import { IWidgetInstance } from '@cs/client/frames/csMainFrame/csDefaultPages/default-pages.types';
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IPageInstance } from '@cs/client/frames/csMainFrame/csWorkspaceManager/csPageRegistry/page-registry.types';


class SvtxDomainSwitchController implements ng.IComponentController {

    public static $inject: string[] = ['pageInstance', 'csApiSession', 'widgetInstance', 'csNotify'];

    public contextAssetId: any;
	public contextAsset: any;

    public data: any;
    public selectedDomain: string;
    public mode: string;
	public isVisible: boolean;
	public isEditable : boolean;
    public isProcessing : boolean;

    constructor (private pageInstance: IPageInstance,
				 private csApiSession: IcsApiSession,
				 private widgetInstance : IWidgetInstance,
				 private csNotify: INotify) {

        this.widgetInstance.setTitle('svtxDomainSwitchWidget.title');
		this.contextAssetId = this.pageInstance.getPathContextReader().getValue().get('id');
    }

	public $onInit(): void {
        this.initWidget();
    }

    public initWidget() {
        this.csApiSession.asset.get(this.contextAssetId).then( (result) => {
            let widget = this;
            widget.contextAsset = result.container[0].asset;

            widget.isVisible = true;
            widget.isEditable = false;
            widget.isProcessing = false;
            widget.selectedDomain = null;
            widget.mode =  'none';

            try {
                let params = {
                    contextAsset: this.contextAssetId
                };

                this.csApiSession.transformation("svtx:xslt.domain.info", params).then(
                    function (result) {
                        widget.data = result;

                        if (widget.data.permission === 'true') {
                            widget.isEditable = true;
                        }

                        let currentDomain = widget.data.currentDomain.key;
                        if (currentDomain.startsWith('root.allianz-leben-ag.contenthub.l-mm') || currentDomain.startsWith('root.allianz-leben-ag.contenthub.playground')) {
                            let domainParts = currentDomain.split('.');

                            if (domainParts && domainParts.length == 5) {
                                widget.mode = 'unit';
                            }
                            if (domainParts && domainParts.length == 6) {
                                widget.mode = 'agency';
                            }
                        }
                    }
                );

            } catch (e) {
                console.log("Cannot retrieve domain information: ", e);
            }
        });
	}

	public switchToAgency(): void {

        let widget = this;
        if(widget.selectedDomain) {
            try {

                widget.isEditable = false;
                widget.isProcessing = true;

                let params = {
                    contextAsset: this.contextAssetId,
                    variables: [
                        { key: 'mode', value: 'switchToAgency'},
                        { key: 'domain', value: widget.selectedDomain}
                    ]
                };

                this.csApiSession.transformation("svtx:xslt.domain.switch", params).then(
                    function () {
                        widget.initWidget();
                        let message = "Zugriffsrechte wurden erfolgreich geändert!";
                        widget.csNotify.success("Zugriffsrechte", message);
                    }
                ).catch(function (error) {
                    console.log('Error', error);
                    widget.csNotify.warning('Zugriffsrechte', 'Zugriffsrechte konnten nicht geändert werden');
                });

            } catch (e) {
                console.log("Cannot switch domain: " + e);
                widget.initWidget();
            }
        }
    }

    public switchToUnit(): void {

        let widget = this;
        try {

            widget.isEditable = false;
            widget.isProcessing = true;

            let params = {
                contextAsset: this.contextAssetId,
                variables: [
                    { key: 'mode', value: 'switchToUnit'},
                    { key: 'domain', value: ''}
                ]
            };

            this.csApiSession.transformation("svtx:xslt.domain.switch", params).then(
                function () {
                    widget.initWidget();
                    let message = "Zugriffsrechte wurden erfolgreich geändert!";
                    widget.csNotify.success("Zugriffsrechte", message);
                }
            );

        } catch (e) {
            console.log("Cannot switch domain: " + e);
            widget.initWidget();
        }
    }
}

/**
 * handle export
 */

export const svtxDomainSwitchComponent: ng.IComponentOptions = {
	controller: SvtxDomainSwitchController,
	templateUrl: censhare.getResourceURL('svtxDomainSwitchWidget', 'svtx-domain-switch.component.html')
};