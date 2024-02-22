import { IcsWizardDataManager, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {IArticle, IChannel, IText} from "./allianz-product-wizard.model";

export class AllianzProductWizardController {
    public static $name: string = 'allianzProductWizardController';
    public static $inject: string[] = [
        '$scope',
        'wizardDataManager',
        'wizardInstance'
    ];

    constructor($scope: any, wizardDataManager: IcsWizardDataManager, wizardInstance: IcsWizardInstance) {
        console.log('open allianzProductWizard', wizardInstance, wizardDataManager, $scope);
    }
}

export class AllianzProductWizardUtil {
    private channel: Array<IChannel>;

    constructor(channel: Array<IChannel>) {
        this.channel = this.asArray(channel);
    }

    public getChannel(): Array<IChannel> {
        return this.channel;
    }

    public getDistinctArticle(): Array<IArticle> {
        const allArticle: Array<any> = (
            this.channel.filter(this.hasArticle).map(channel => channel.article.map(obj => obj))
        );
        const flattenArticle: Array<IArticle> = this.flatten(allArticle);
        const distinctArticle: Array<IArticle> = this.removeDuplicates(flattenArticle, 'id');
        return this.asArray(distinctArticle);
    }

    public getDistinctTexts(): Array<IText> {
        const allText: Array<any> = (
            this.channel.filter(this.hasArticle).map(channel => channel.article.map(obj => obj).filter(this.hasText).map(obj => obj.text))
        );
        const flattenText = this.flatten(allText);
        return this.removeDuplicates(flattenText, 'id');
    }

    protected asArray(val: any): Array<any> {
        if (val) {
            return Array.isArray(val) ? val : [val];
        }
        return [];
    }

    protected hasArticle(item: any): boolean {
        return item.article && item.article.length > 0;
    }

    protected hasText(item: any): boolean {
        return item.hasOwnProperty('text');
    }

    private removeDuplicates(arr: Array<any>, prop: string): Array<any> {
        return arr.filter((obj, pos, self) => {
            return self.map(mapObj => mapObj[prop]).indexOf(obj[prop]) === pos;
        });
    }

    private flatten(arr: Array<any>): Array<any> {
        const flatten = (arr: Array<any>) => {
            return arr.reduce((flat, toFlatten) => {
                return flat.concat(Array.isArray(toFlatten) ? flatten(toFlatten) : toFlatten);
            }, []);
        };
        return flatten(arr);
    }
}