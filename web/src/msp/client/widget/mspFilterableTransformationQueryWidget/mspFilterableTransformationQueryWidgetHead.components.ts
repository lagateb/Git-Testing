import * as censhare                          from 'censhare';
import { groupedInjections }                  from '@cs/framework/csApi/csUtils/csUtils';
import { IWidgetInstance }                    from '@cs/client/frames/csMainFrame/csDefaultPages/default-pages.types';
import { actionFactory }                      from '@cs/client/base/csActions/csActionFactory';
import { IActionViewFactory, IOverflowGroup } from '@cs/client/base/csActions/csActionInterfaces';
import { DefaultActionViewFactory }           from '@cs/client/base/csActions/csActionDefaultViewFactory';
import { ICsTranslate }                       from '@cs/framework/csApplication/csTranslate/translate.provider';
// @ts-ignore html file is there
import template                               from './mspFilterableTransformationQueryWidgetHead.component.html!text';

@groupedInjections
class TransformationQuery {
    public static $inject: string[]           = [
        'widgetInstance',
        'csTranslate',
        'widgetDataManager',
        'csAssetSelectionManager',
    ];
    private getDependencies: () => {
        widgetInstance: IWidgetInstance;
        csTranslate: ICsTranslate;
        widgetDataManager: any;
    };
    public actions: IOverflowGroup; // old action registry
    public multiActionsGroup: IOverflowGroup; // old action registry
    public actionView: IActionViewFactory;
    private showMultiSelectedActions: boolean = false;
    public showSelectedCount: string;

    get title() {
        return this.getDependencies().widgetInstance.getTitle().getValue();
    }

    get titleIsHidden() {
        return this.getDependencies().widgetInstance.getTitleIsHidden().getValue();
    }

    get icon() {
        return this.getDependencies().widgetInstance.getIcon().getValue();
    }

    get counter() {
        return this.getDependencies().widgetInstance.getCounter().getValue();
    }

    public $onInit() {
        const { widgetInstance } = this.getDependencies();
        this.actions             = actionFactory.overflowGroup()
            .setPrimaryActionGroup(widgetInstance.getOrCreateTitleActions())
            .setSecondaryActionGroup(widgetInstance.getOrCreateMenuActions());

        this.multiActionsGroup = actionFactory.overflowGroup()
            .setPrimaryActionGroup(widgetInstance.getOrCreateTitleMultiActions())
            .setSecondaryActionGroup(widgetInstance.getOrCreateMenuMultiActions());

        this.actionView = new DefaultActionViewFactory(censhare.getInjector);

        widgetInstance.hasSelectedAssets().registerChangeListenerAndFire(this.onSelectionAmountChanged);
    }

    public $onDestroy() {
        const { widgetInstance } = this.getDependencies();

        widgetInstance.hasSelectedAssets().unregisterChangeListener(this.onSelectionAmountChanged);
    }

    private onSelectionAmountChanged = (value: any) => {
        const { widgetInstance, csTranslate } = this.getDependencies();
        this.showMultiSelectedActions         = value > 1;
        if (this.showMultiSelectedActions) {
            this.showSelectedCount = csTranslate.instant('csCommonTranslations.itemsSelected', { items: value });
            this.multiActionsGroup = actionFactory.overflowGroup()
                .setPrimaryActionGroup(widgetInstance.getOrCreateTitleMultiActions())
                .setSecondaryActionGroup(widgetInstance.getOrCreateMenuMultiActions());
        }
    };
}

const mspFilterableTransformationQueryWidgetHead: ng.IComponentOptions = {
    template,
    controller: TransformationQuery,
};

export { mspFilterableTransformationQueryWidgetHead };
