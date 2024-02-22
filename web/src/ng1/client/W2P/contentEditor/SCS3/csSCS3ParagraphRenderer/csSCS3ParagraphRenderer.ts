import { NodeProxyElement, NodeProxyAttribute, NodeProxyViewNode, NodeProxyTree } from '../../renderer/csNodeSourceProxy/csNodeSourceProxy';
import { ContentEditorElementRendererHeadless } from '../../renderer/csContentEditorElementRenderer/csContentEditorElementRenderer';
import { IRenderLayout } from '../../csContentEditorView/csContentEditorSliceFactory';
import { IAngularSliceFactoryDescriptor } from '../../renderer/csContentEditorRendererBase/csContentEditorRendererBase';

export const csSCS3ParagraphHeadlessSwitcher = ['node', 'csTypeRegistry', 'managers',
    function(node, csTypeRegistry, managers) {
        const contentEditorContentHeadlessCfg = { name: 'csContentEditorInlineTextRenderer', type: 'csContentEditorRenderer' };
        const attributeInspectorHeadlessCfg = { name: 'csSCS3ParagraphStyleRenderer', type: 'csContentEditorRenderer' };

        return node.isInspectorMode() ?
            getHeadlessInstance(attributeInspectorHeadlessCfg) : getHeadlessInstance(contentEditorContentHeadlessCfg);

        function getHeadlessInstance(cfg) {
            const impl = csTypeRegistry.getImpl(cfg.name, cfg.type);
            return impl.instantiateFast({ node: node, managers: managers });
        }

    }
];

export const csSCS3ParagraphRendererHeadlessDataManager = ['$injector', 'node',
    function($injector, node) {
        return node.loadSyncRecursive().then(onPrettyFormatPrefetchComplete);

        function onPrettyFormatPrefetchComplete() {
            return new CsSCSParagraphRendererHeadless($injector, node);
        }
    }
];

class CsSCSParagraphRendererHeadless extends ContentEditorElementRendererHeadless {

    private _sliceInfoInspector: IAngularSliceFactoryDescriptor;

    /* custom savotex, add option to merge to right cell */
    private _structure: NodeProxyElement = new NodeProxyElement('paragraph').setViewNode(null).setAttributes([
        new NodeProxyAttribute('style', '', null, true)
            .setViewNode(new NodeProxyViewNode([/*'style-1', 'style-2', 'style-3', 'style-4', 'style-5', 'style-6', 'style-7', 'style-8', 'style-9', 'style-10'*/'merge-cell-right'])),

    ]);

    constructor($injector: ng.auto.IInjectorService, node: csContentEditorViewModel.IViewElement) {
        super($injector, node);
        this.prepareDataBeforeLayout();
    }

    public prepareDataBeforeLayout(): void {
        this.nodeProxy = new NodeProxyTree(this._structure, this.dataProvider);
        this.nodeProxy.buildRecursive();

        this._sliceInfoInspector = {
            module: 'csSCS3ParagraphRenderer',
            template: 'csSCS3_paragraphBottom.html',
            controller: 'csSCS3RendererController',
            nodeProxyTree: this.nodeProxy
        };
    }

    public onLayout(_canvasLayout: IRenderLayout): void {
        this.createAndAddAngularSliceToCanvas('inspector', this._sliceInfoInspector);
    }

}
