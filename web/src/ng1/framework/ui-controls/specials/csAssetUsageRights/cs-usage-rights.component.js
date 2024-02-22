define(["require", "exports", "tslib", "@cs/framework/csApi/csUtils/csUtils", "./cs-usage-rights.html!text"], function (require, exports, tslib_1, csUtils_1, cs_usage_rights_html_text_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    var CsUsageRightsController = (function () {
        function CsUsageRightsController() {
            this.trait = 'usage_rights';
            this.hideValidity = false;
        }
        Object.defineProperty(CsUsageRightsController.prototype, "assetId", {
            get: function () {
                return this._assetId;
            },
            set: function (value) {
                var _this_1 = this;
                this._assetId = value;
                if (value > 0) {
                    this.hideValidity = true;
                    var csApiSession = this.getDependencies().csApiSession;
                    csApiSession.execute('com.censhare.api.applications.asset.metadata.AssetTraitsInfo', {
                        assetId: value,
                        traitNames: [this.trait]
                    }).then(function (result) {
                        var asset = result && result.asset && result.asset[0];
                        _this_1.usageRights = asset && asset.traits && asset.traits[_this_1.trait] && asset.traits[_this_1.trait].usageRights;
                        _this_1.getProducts();
                    });
                }
            },
            enumerable: true,
            configurable: true
        });
        CsUsageRightsController.prototype.getProducts = function () {
            if (this.usageRights && this.usageRights.value[0].useForProducts) {
                var loadIds_1 = [];
                this.usageRights.value[0].useForProducts.value.forEach(function (item) {
                    if (item && item.value) {
                        loadIds_1.push(item.value);
                    }
                });
                if (loadIds_1.length > 0) {
                    var csApiSession = this.getDependencies().csApiSession;
                    var _this_2 = this;
                    csApiSession.asset.get(loadIds_1).then(function (result) {
                        _this_2.products = result.container;
                    });
                }
            }
        };
        CsUsageRightsController.prototype.$onChanges = function (onChangesObj) {
            this.getProducts();
        };
        CsUsageRightsController.$inject = ['csApiSession'];
        CsUsageRightsController = tslib_1.__decorate([
            csUtils_1.groupedInjections
        ], CsUsageRightsController);
        return CsUsageRightsController;
    }());
    exports.CsUsageRightsComponent = {
        template: cs_usage_rights_html_text_1.default,
        controller: CsUsageRightsController,
        bindings: {
            assetId: '<',
            usageRights: '<',
            hideValidity: '<?'
        }
    };
});
//# sourceMappingURL=cs-usage-rights.component.js.map