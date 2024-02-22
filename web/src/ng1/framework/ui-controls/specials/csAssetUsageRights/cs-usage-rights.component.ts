import {IcsApiSession} from '@cs/framework/csApi/cs-api.model';
import {groupedInjections} from '@cs/framework/csApi/csUtils/csUtils';
import template from './cs-usage-rights.html';

/**
 * Controller
 */
@groupedInjections
class CsUsageRightsController implements ng.IController {
    public static $inject: string[] = ['csApiSession'];
    private _assetId: number;
    private readonly trait = 'usage_rights';
    usageRights: any;
    hideValidity = false;
    products: any;

    private getDependencies: () => {
        csApiSession: IcsApiSession;
    };

    get assetId() {
        return this._assetId;
    }
    set assetId(value: number) {
        this._assetId = value;
        if (value > 0) {
            this.hideValidity = true;
            const {csApiSession} = this.getDependencies();
            csApiSession.execute('com.censhare.api.applications.asset.metadata.AssetTraitsInfo', {
                assetId: value,
                traitNames: [this.trait]
            }).then((result: any) => {
                const asset = result && result.asset && result.asset[0];
                this.usageRights = asset && asset.traits && asset.traits[this.trait] && asset.traits[this.trait].usageRights;
                this.getProducts();
            });
        }
    }

    public getProducts() {
        if(this.usageRights && this.usageRights.value[0].useForProducts) {
            let loadIds = [];
            this.usageRights.value[0].useForProducts.value.forEach(function(item) {
                if (item && item.value) {
                    loadIds.push(item.value);
                }
            });

            if (loadIds.length > 0) {
                const {csApiSession} = this.getDependencies();
                const _this = this;
                csApiSession.asset.get(loadIds).then((result) => {
                    _this.products = result.container;
                });
            }
        }
    }

    $onChanges() {
        this.getProducts();
    }
}

export const CsUsageRightsComponent = {
    template,
    controller: CsUsageRightsController,
    bindings: {
        assetId: '<',
        usageRights: '<',
        hideValidity: '<?'
    }
};
