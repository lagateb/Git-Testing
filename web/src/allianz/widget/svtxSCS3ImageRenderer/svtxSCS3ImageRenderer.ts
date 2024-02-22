
//
import { NodeProxyElement, NodeProxyTree } from '@cs/client/W2P/contentEditor/renderer/csNodeSourceProxy/csNodeSourceProxy';
import { ContentEditorElementRendererHeadless } from '@cs/client/W2P/contentEditor/renderer/csContentEditorElementRenderer/csContentEditorElementRenderer';
import { IRenderLayout } from '@cs/client/W2P/contentEditor/csContentEditorView/csContentEditorSliceFactory';
import { IAngularSliceFactoryDescriptor } from '@cs/client/W2P/contentEditor/renderer/csContentEditorRendererBase/csContentEditorRendererBase';

export const svtxSCS3ImageRendererHeadlessDataManager = ['$injector', 'node',
    function($injector, node) {
        return node.loadSyncRecursive().then(onPrettyFormatPrefetchComplete);

        function onPrettyFormatPrefetchComplete() {
            return new SvtxSCS3ImageRendererHeadless($injector, node);
        }
    }
];

class SvtxSCS3ImageRendererHeadless extends ContentEditorElementRendererHeadless {

    private _sliceInfoEl: IAngularSliceFactoryDescriptor;
    private _sliceInfoContent: IAngularSliceFactoryDescriptor;
    private _sliceInfoInspector: IAngularSliceFactoryDescriptor;

    private _prettyCompNodeMap: any;
    private _topControllerNodeMap: any = {};

    private _structure: NodeProxyElement = new NodeProxyElement('picture').setViewNode(null);
    /*
        .setAttributes([
            new NodeProxyAttribute('aspect-ratio', '', null, true)
                .setViewNode(new NodeProxyViewNode(['1-1', '3-4', '4-3', '16-9', 'flexible'], '16-9')),
            new NodeProxyAttribute('alt-text')
                .setViewNode(new NodeProxyViewNode()),
            new NodeProxyAttribute('seo-title')
                .setViewNode(new NodeProxyViewNode())
        ]);

     */

    constructor($injector: ng.auto.IInjectorService, node: csContentEditorViewModel.IViewElement) {
        super($injector, node);
        this.prepareDataBeforeLayout();
    }

    public prepareDataBeforeLayout(): void {
        this.nodeProxy = new NodeProxyTree(this._structure, this.dataProvider);
        this.nodeProxy.buildRecursive();
        this._prettyCompNodeMap = this.nodeProxy.toNodeMap();

        this._topControllerNodeMap.PictureNode = this._prettyCompNodeMap.Picture;
        this._topControllerNodeMap.PictureFilter = { assettype: 'picture.icon.*' };

        if(this._prettyCompNodeMap.Picture.getRendererConfig().filter != undefined
            && this._prettyCompNodeMap.Picture.getRendererConfig().filter.assettype != undefined){
            this._topControllerNodeMap.PictureFilter.assettype = this._prettyCompNodeMap.Picture.getRendererConfig().filter.assettype;
        }


        this._sliceInfoEl = {
            module: 'csSCS3Renderer',
            template: 'csContentEditorElementNameSlice.html',
            controller: 'csSCS3RendererController',
            collapsable: true
        };
        this._sliceInfoContent = {
            module: 'svtxSCS3ImageRenderer',
            template: 'svtxSCS3_imageTop.html',
            controller: 'csSCS3RendererController',
            scopePropertyMap: this._topControllerNodeMap
        };
        this._sliceInfoInspector = {
            module: 'svtxSCS3ImageRenderer',
            template: 'svtxSCS3_imageBottom.html',
            controller: 'csSCS3RendererController',
            nodeProxyTree: this.nodeProxy
        };

    }

    public onLayout(canvasLayout: IRenderLayout): void {
        if (this.dataProvider.isInspectorMode()) {
            this.createAndAddAngularSliceToCanvas('inspector', this._sliceInfoInspector);
        } else {
            if (canvasLayout.getCurrentViewMode() === 'pretty-v2') {
                this.createAndAddAngularTitleAndContentSliceToCanvas(this._sliceInfoEl, this._sliceInfoContent);
            } else {
                this.createAndAddAngularSliceToCanvas('element', this._sliceInfoEl);
                if (this.contentIsVisible(canvasLayout)) {
                    this.createAndAddAngularSliceToCanvas('content', this._sliceInfoContent);
                }
            }
        }
    }

    private contentIsVisible(canvasLayout: IRenderLayout): boolean {
        return !this.dataProvider.getCollapsed() || ['flat', 'pretty-v2'].indexOf(canvasLayout.getCurrentViewMode()) !== -1;
    }

}
