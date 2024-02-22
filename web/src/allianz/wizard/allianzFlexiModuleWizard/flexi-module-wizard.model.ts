export enum ModuleType {
    flexi = 'article.flexi-module.',
    free = 'article.free-module.'
}

export enum ProductType {
    product = 'product.',
    vsk = 'product.vsk.'
}

export const ModuleSelectOptions = Object.freeze({
    flexi: {
        value: ModuleType.flexi,
        display_value: 'Flexi-Modul'
    },
    free: {
        value: ModuleType.free,
        display_value: 'Freies Modul'
    }
});

export interface ISelect {
    value: string;
    display_value: string;
}

export interface IConfig {
    self: string;
}

export interface ITemplate {
    value: string;
    display_value: string;
    preview: string;
}


class ModuleTemplate {
    readonly asset: any;

    preview: string;
    displayValue: string;
    value: string;

    constructor(asset: any) {
        this.asset = asset;
    }
    protected getTraits() {
        return this.asset && this.asset.traits;
    }
    protected getRelations() {
        return this.asset && this.asset.relations;
    }

    protected setValue () {
        this.value = this.asset && this.asset.self || void 0;
    }

    protected setDisplayValue() {
        this.displayValue = this.getTraits().display.name;
    }
}

export class FlexiTemplate extends ModuleTemplate{
    constructor(asset: any) {
        super(asset);
        this.setValue();
        this.setDisplayValue();
        this.setPreview();
    }

    private setPreview() {
        const mainPictureRel = this.getRelations().find(rel => rel.type === 'user.main-picture.');
        if (mainPictureRel) {
            const assetRef = mainPictureRel.ref_asset;
            const id = typeof (assetRef) !== 'undefined' ? +assetRef.split('/')[2] : void 0;
            if (id) {
                this.preview = `rest/service/assets/asset/id/${id}/preview/file`;
            }
        }
    }

    public getSelectOption() {
        return { value: this.value, display_value: this.displayValue, preview: this.preview };
    }
}


export class FreeTemplate extends ModuleTemplate {
    constructor(asset: any) {
        super(asset);
        this.setValue();
        this.setDisplayValue();
    }

    public getSelectOption() {
        return { value: this.value, display_value: this.displayValue, templateOptions: this.getTemplateOptions() };
    }

    /* refactor */
    public getTemplateOptions() {
        const traits = this.getTraits();
        const templateOptions = traits.allianzTemplateOptions && traits.allianzTemplateOptions.templateOptions || void 0;
        if (templateOptions) {
            const imageAlignments = templateOptions.imageAlignment && templateOptions.imageAlignment.values;
            if (imageAlignments) {
                return imageAlignments.map(obj => {
                    const templateValues = obj.template && obj.template.values || void 0;
                    let hasLinkOption = false;
                    if (templateValues) {
                        const objWithLink = templateValues.find(obj => obj.showLink && obj.showLink.value === true);
                        if (objWithLink) {
                            hasLinkOption = true;
                        }
                    }
                    return {
                        value: obj.value,
                        display_value:obj.label_value,
                        link: hasLinkOption,
                        getPreview(link: boolean = false) {
                            if (link === null) {
                                return
                            }
                            const imageAlignment =  imageAlignments.find(obj => obj.value === this.value);
                            const templates = imageAlignment && imageAlignment.template && imageAlignment.template.values;
                            const filerWithLink = obj => obj.showLink && obj.showLink.value === true;
                            const filterWithoutLink = obj => !obj.hasOwnProperty('showLink') || obj.showLink.value === false;
                            const filter = link ? filerWithLink : filterWithoutLink;
                            const templateAsset = templates && templates.find(filter);
                            const templateId = templateAsset && templateAsset.value;
                            if (templateId) {
                                return `rest/service/assets/asset/id/${templateId}/preview/file`;
                            }
                        }
                    }
                })
            }
        }
        return void 0;
    }
}



