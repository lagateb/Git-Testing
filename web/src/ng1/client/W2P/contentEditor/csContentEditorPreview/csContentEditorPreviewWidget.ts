import { IPageInstance } from '@cs/client/frames/csMainFrame/csWorkspaceManager/csPageRegistry/page-registry.types';
import { IWidgetInstance } from '@cs/client//frames/csMainFrame/csDefaultPages/default-pages.types';
import { IcsAssetUtil } from '@cs/framework/csApplication/csAssetUtil/cs-asset-util.model';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { INotify } from '@cs/client/frames/csMainFrame/notifications/csNotify/notify';
import { IcsLogger } from '@cs/framework/csApi/csLogger/logger';
import { OCBouncerAuth, OCBouncerAuthResult } from '@cs/client/OC/utils/oc-bouncer-auth';
import { ICsContentEditorPreviewSyncService } from './cs-content-editor-preview-sync.service';
import { debounceCallback } from '@cs/framework/csApi/csUtils/csUtils';

const REQUEST_PREVIEW_DELAY_DEFAULT: number = 1500;
const LANGUAGE_SYNC_DEFAULT: boolean = true;
const transformationGetAlternateLayouts = 'svtx:get_alternate_pptx_layouts'


/**
 * Datamanager for controller
 */
const csContentPreviewWidgetHeadless = [
    'pageContextProviderPromise', 'pageInstance', 'widgetInstance',
    'csServices', 'csApiSession', '$q', '$http', 'csAssetUtil', '$timeout', 'csNotify', 'csLogger', 'csTranslate', 'csContentEditorPreviewSyncService',
    'csQueryBuilder',
    function(pageContextProviderPromise, pageInstance: IPageInstance, widgetInstance: IWidgetInstance,
             csServices: csServices.IcsServicesService, csApiSession: IcsApiSession, $q: ng.IQService, $http: ng.IHttpService,
             csAssetUtil: IcsAssetUtil, $timeout, csNotify: INotify, csLogger: IcsLogger, csTranslate, csContentEditorPreviewSyncService,
             csQueryBuilder) {
        const logger = csLogger.get('csContentEditorPreviewWidget');
        const bouncerAuth: OCBouncerAuth = new OCBouncerAuth(csApiSession, $http, $q, logger);
        const treeObservable = csServices.createObservable(null); // selection tree
        const pathObservable = csServices.createObservable(null); // current selection path
        const urlObservable = csServices.createObservable(null); // current preview URL
        const assetId = pageInstance.getPathContextReader().getValue().get('id');
        const assetRef = 'asset/id/' + assetId + '/currversion/0';
        const syncService: ICsContentEditorPreviewSyncService = csContentEditorPreviewSyncService;

        let currentUrl = null;
        let requestPreviewDelay = REQUEST_PREVIEW_DELAY_DEFAULT;
        let pageContextProvider;
        let contentEditorClientApplication;
        let metadataApplication;
        let pathLoaded = false;
        let contextLocale;
        let uniqueId = 0;
        let pendingRefresh;
        let myAsset;

        let textSize

        let isFAQ = false

        function getAssetInformation(assetInfoApp) {
            try {
                contextLocale = assetInfoApp.data.container.asset[0].traits.content.language.value[0].value;
            } catch (error) {
                console.log("Komisch " + error)
            }
        }

        // PPTX Drop Down mit den möglichen Layout aufbauen
        const preparePPTXDropDown = (result) => {
            console.log('assignFAQs')
            let  opt = {
                key: 'pptx',
                uniqueId: uniqueId++,
                name: csTranslate.instant('csContentEditorPreviewWidget.channel_pptx'),
                child: {
                    key: 'transformation',
                    uniqueId: uniqueId++,
                    name: csTranslate.instant('csContentEditorPreviewWidget.slide'),
                    options: [],
                    defaultOption:''
                },
                defaultLayoutId:''
            };
            if(!Array.isArray(result.option)) {
                result.option = [result.option]
            }
            angular.forEach(result.option, function (option) {
                let name = option.display_value
                let pptxId = option.value
                // der letzte ist der default
                opt.child.defaultOption = pptxId
                opt.defaultLayoutId= pptxId

                opt.child.options.push({
                    key: pptxId,
                    uniqueId: uniqueId++,
                    name: name,
                    // Text Asset
                    url: "pptx:" + pptxId,
                    mimeType: 'application/pptx',
                    needsFlush: true,
                    position:option.position
                });
            });

            return opt;
        }

        const getPPTXResult =  (result) => {
            return result;
        }

        const myLogFunction = (reason) => {
         console.log("error "+transformationGetAlternateLayouts+" "+reason)
        }

        /**
         * Baut das Layout DropDown für PPTX-Vorlagen auf
         * @param pptx
         */
        function preparePPTX(pptx) {
             let  opt = {
                    key: 'pptx',
                    uniqueId: uniqueId++,
                    name: csTranslate.instant('csContentEditorPreviewWidget.channel_pptx'),
                    child: {
                        key: 'transformation',
                        uniqueId: uniqueId++,
                        name: csTranslate.instant('csContentEditorPreviewWidget.slide'),
                        options: [],
                        defaultOption:''
                    }
                };
                //Hier wird das DropDown der Layouts gefüllt

                angular.forEach(pptx.container, function (resource) {

                    let name = resource.asset.traits.display.name;
                    let pptxId = resource.asset.traits.ids.id;
                    if (!opt.child.defaultOption || opt.child.defaultOption==='') {
                        opt.child.defaultOption = pptxId;
                    }
                    opt.child.options.push({
                        key: pptxId,
                        uniqueId: uniqueId++,
                        name: name,
                        // Text Asset
                        url: "pptx:" + pptxId,
                        mimeType: 'application/pptx',
                        needsFlush: true
                    });
                });

            return opt;
        }

       //TODO pptx raus, da ja pptxNew ok

       return  csApiSession.asset.get(+assetId).then((result) => {
           myAsset = result.container[0].asset
           let type = myAsset.traits.type.type
           console.log(myAsset)
           // text.????. => ????
           textSize = type.slice(5, -1)
           isFAQ = textSize == "faq"


           let qb = new csQueryBuilder();
           if(isFAQ) {
               //let or = qb.or();
               //let and1 = or.and();
               //and1.condition("@censhare:resource-key","svtx:optional-modules.faq.slide"); // =$resourceKey, "presentation.slide."
               let and1 = qb.and();
               and1.condition("censhare:resource-key","svtx:optional-modules.faq.slide"); // =$resourceKey, "presentation.slide."
           } else {


               let or = qb.or();

               //Vorlagen
               let and1 = or.and();
               and1.condition("censhare:asset.type", "presentation.slide.");
               and1.condition("censhare:asset-flag", "is-template");

               //auf platzierten folien

               let and2 = or.and();
               and2.condition("censhare:asset.type", "presentation.*");
               and2.condition("svtx:text-size", "=", textSize)
               and2.not().condition("censhare:asset-flag", "is-template");
               and2.relation("child", "target.").relation("child", "user.main-content.").condition("censhare:asset.id", assetId);
               and2.condition("svtx:text-variant-type", "=", "standard");

               let and2_2 = or.and();
               and2_2.condition("censhare:asset.type", "presentation.*");
               and2_2.condition("svtx:text-size", "ISNULL", "")
               and2_2.not().condition("censhare:asset-flag", "is-template");
               and2_2.relation("child", "target.").relation("child", "user.main-content.").condition("censhare:asset.id", assetId);
               and2_2.condition("svtx:text-variant-type", "=", "standard");


               // Wenn der Text Varianten hat, darf er kein Powerpoint haben. Eventuel noch feature überprüfen?
               // TODO enfällt ?
               // and2.not().relation("child", "target.").relation("child", "user.main-content.").condition("censhare:asset.id", assetId).
               // relation("child", "variant.1.");

               // Folie(presentation.*) => artikel(target.)=>text(user.main-content.)=>variante( variant.1.)
               let and3 = or.and();
               and3.condition("censhare:asset.type", "presentation.*");

               // Die Folienvorlagen sind bei allen Varianten und Haupttext gleich
               and3.condition("svtx:text-variant-type", "=", "standard");
               and3.not().condition("censhare:asset-flag", "is-template");
               and3.relation("child", "target.").relation("child", "user.main-content.").relation("child", "variant.1.").condition("censhare:asset.id", assetId);
           }



           // preload resource assets
           return $q.all({
               pageContextProvider: pageContextProviderPromise,
               html: csApiSession.resourceassets.lookup({
                   sourceAssetRef: assetRef,
                   usage: 'censhare:preview'
               }),
               // TODO Unsere Abfrage
               pptxNew: csApiSession.transformation(transformationGetAlternateLayouts,{'contextAsset':assetId})
                   .then(getPPTXResult)
                   .catch(myLogFunction),
               pptx: csApiSession.asset.query(qb.build()),
               pdf: csApiSession.resourceassets.lookup({
                   sourceAssetRef: assetRef,
                   usage: 'censhare:xsl-fo-pdf-preview'
               }),
               online: csApiSession.resourceassets.lookup({
                   sourceAssetRef: assetRef,
                   usage: 'censhare:online-channel-preview-server'
               }),
               devices: csApiSession.resourceassets.lookup({
                   sourceAssetRef: assetRef,
                   usage: 'censhare:device-display-frame'
               }),
               layouts: csApiSession.execute('com.censhare.api.web2print.contentEditorPreview.layouts', {
                   asset: assetId
               })
           } as any).then(function (result: any) {
               pageContextProvider = result.pageContextProvider;
               pageContextProvider.registerOnAfterMethodListener(refreshPreviewAfterSave);
               if (pageContextProvider.hasApplication('csContentEditorClientApplication')) {
                   contentEditorClientApplication = pageContextProvider.getLiveApplicationInstance('csContentEditorClientApplication');
               }
               metadataApplication = pageContextProvider.getLiveApplicationInstance('com.censhare.api.applications.asset.metadata.AssetInfoApplication');
               metadataApplication.registerNativeChangeListenerAndFire(getAssetInformation);

               // construct static part of selection tree
               const root = {
                   key: 'preview',
                   uniqueId: uniqueId++,
                   name: csTranslate.instant('csContentEditorPreviewWidget.channel'),
                   options: []
               };
               let opt;
               /*const scale = {
                   key: 'scale',
                   uniqueId: uniqueId++,
                   name: csTranslate.instant('csContentEditorPreviewWidget.scale'),
                   defaultOption: '1.0',
                   options: [
                       {
                           key: '0.5',
                           uniqueId: uniqueId++,
                           name: '50%',
                           url: ';scale=0.5'
                       },
                       {
                           key: '0.75',
                           uniqueId: uniqueId++,
                           name: '75%',
                           url: ';scale=0.75'
                       },
                       {
                           key: '1.0',
                           uniqueId: uniqueId++,
                           name: '100%',
                           url: ';scale=1.0'
                       }
                   ]
               };*/
               let device = {
                   key: 'device',
                   uniqueId: uniqueId++,
                   name: csTranslate.instant('csContentEditorPreviewWidget.device'),
                   defaultOption: 'none',
                   options: [
                       {
                           key: 'none',
                           uniqueId: uniqueId++,
                           name: csTranslate.instant('csContentEditorPreviewWidget.deviceNone')
                       }
                   ] as any[]
               };
               const layouts = {
                   key: 'layout',
                   uniqueId: uniqueId++,
                   name: csTranslate.instant('csContentEditorPreviewWidget.layout'),
                   defaultOption: 'none',
                   options: [
                       /*{
                           key: 'none',
                           uniqueId: uniqueId++,
                           name: csTranslate.instant('csContentEditorPreviewWidget.deviceNone')
                       }*/
                   ] as any[]
               };
               const onlineReqs: Array<ng.IPromise<any>> = [];

               if (result.layouts.layouts && result.layouts.layouts.length > 0) {
                   opt = {
                       key: 'print',
                       uniqueId: uniqueId++,
                       name: csTranslate.instant('csContentEditorPreviewWidget.channel_print'),
                       child: layouts,
                       mimeType: 'application/pdf',
                       needsFlush: true
                   };

                   angular.forEach(result.layouts.layouts, function (layout) {
                       const layoutId = csAssetUtil.getAssetIdFromAssetRef(layout.id);
                       if (layouts.defaultOption === 'none' ) {
                           layouts.defaultOption = String(layoutId);
                       }
                       layouts.options.push({
                           key: layoutId,
                           uniqueId: uniqueId++,
                           name: csTranslate.instant(layout.name),
                           mimeType: 'application/pdf',
                           url: 'censhare:///service/assets/asset/id/' + layoutId +
                               '/transform;key=censhare:create-pdf-of-article-with-indesign-server;placeAssetID=' +
                               assetId + ';placeAssetVersion=-2;previewMode=true;time=' + Date.now() + '.pdf'
                       });
                   });

                   root.options.push(opt);
               }



                if (result.pptxNew != undefined ) {
                   //opt= preparePPTX(result.pptx);
                     opt = preparePPTXDropDown(result.pptxNew);
                     root.options.push(opt);
               } else  if (result.pptx.container != undefined && result.pptx.container.length > 0) {
                    opt= preparePPTX(result.pptx);
                    root.options.push(opt);
                }



               if (result.html.resourceAssets.length > 0) {
                   result.html.resourceAssets = result.html.resourceAssets.filter(x => {
                       return x.resourceKey === 'svtx:html-preview.allianz-de' || x.resourceKey === 'svtx:html-preview.vertriebsportal';
                   })
                   opt = {
                       key: 'html',
                       uniqueId: uniqueId++,
                       name: csTranslate.instant('csContentEditorPreviewWidget.channel_html'),
                       child: {
                           key: 'transformation',
                           uniqueId: uniqueId++,
                           name: csTranslate.instant('csContentEditorPreviewWidget.transformation'),
                           options: []
                       }
                   };
                   // Keine Ahnung was das ist ? Soll das Mobile Iphone etc sein?
                   if (result.devices.resourceAssets.length > 0) {
                       angular.forEach(result.devices.resourceAssets, function (resource) {
                           device.options.push({
                               key: resource.resourceKey,
                               uniqueId: uniqueId++,
                               name: csTranslate.instant(resource.name),
                               url: ';device=' + encodeURIComponent(resource.resourceKey),
                               /*child: scale*/
                           });
                       });
                   } else {
                       /*device = scale;*/
                   }

                   angular.forEach(result.html.resourceAssets, function (resource) {
                       if (!opt.child.defaultOption) {
                           opt.child.defaultOption = resource.resourceKey;
                       }
                       opt.child.options.push({
                           key: resource.resourceKey,
                           uniqueId: uniqueId++,
                           name: csTranslate.instant(resource.name),
                           url: resource.urlTemplate + ';mode=cs5;app=contenteditor',
                           /*child: device,*/
                           needsFlush: true
                       });

                   });

                   root.options.push(opt);
               }
               if (result.pdf.resourceAssets.length > 0) {
                   opt = {
                       key: 'pdf',
                       uniqueId: uniqueId++,
                       name: csTranslate.instant('csContentEditorPreviewWidget.channel_pdf'),
                       child: {
                           key: 'transformation',
                           uniqueId: uniqueId++,
                           name: csTranslate.instant('csContentEditorPreviewWidget.transformation'),
                           options: []
                       },
                       needsFlush: true
                   };

                   angular.forEach(result.pdf.resourceAssets, function (resource) {
                       if (!opt.child.defaultOption) {
                           opt.child.defaultOption = resource.resourceKey;
                       }
                       opt.child.options.push({
                           key: resource.resourceKey,
                           uniqueId: uniqueId++,
                           name: csTranslate.instant(resource.name),
                           url: resource.urlTemplate + ';app=contenteditor',
                           mimeType: 'application/pdf'
                       });
                   });

                   root.options.push(opt);
               }
               if (result.online.resourceAssets.length > 0) {
                   // try to fetch online preview pages

                   angular.forEach(result.online.resourceAssets, function (resource) {
                       const url = resource.urlTemplate + '/__preview/asset/' + encodeURIComponent(assetId);

                       // Call Online Channel preview URL via the BouncerAuth, which handles token based authorization
                       onlineReqs.push(bouncerAuth.callUrl(url));
                   });

                   return csServices.promiseBestEffort(onlineReqs, 10000).then(function (onlineResults) {
                       const localeKeys = [];
                       let i;
                       let online;
                       let foundSite = false;
                       let foundPage;
                       let previewPages;
                       let channel;
                       let onlineResultValue: OCBouncerAuthResult;

                       online = {
                           key: 'online',
                           uniqueId: uniqueId++,
                           name: csTranslate.instant('csContentEditorPreviewWidget.channel_online'),
                           child: {
                               key: 'site',
                               uniqueId: uniqueId++,
                               name: csTranslate.instant('csContentEditorPreviewWidget.onlineSite'),
                               options: []
                           }
                       };

                       for (i = 0; i < result.online.resourceAssets.length; i += 1) {
                           if (!onlineResults.entries[i].value) {
                               continue;
                           }
                           onlineResultValue = onlineResults.entries[i].value;
                           if (!onlineResultValue.response || onlineResultValue.response.status !== 200) {
                               continue;
                           }

                           // staging/live/...
                           channel = {
                               key: result.online.resourceAssets[i].resourceKey,
                               uniqueId: uniqueId++,
                               name: csTranslate.instant(result.online.resourceAssets[i].name), // TODO: localization?
                               child: {
                                   key: 'page',
                                   uniqueId: uniqueId++,
                                   name: csTranslate.instant('csContentEditorPreviewWidget.onlineLocale'),
                                   options: []
                               }
                           };

                           foundPage = false;

                           previewPages = $(onlineResultValue.response.data).find('preview_page');
                           previewPages.each(function () {
                               const el = $(this);
                               const locale = el.attr('locale');
                               if (localeKeys.indexOf(locale) === -1) {
                                   localeKeys.push(locale);
                               }
                           });

                           localeKeys.forEach(function (locale) {
                               const language: any = {
                                   key: locale,
                                   uniqueId: uniqueId++,
                                   name: locale,
                                   child: {
                                       key: 'onlinePage',
                                       uniqueId: uniqueId++,
                                       name: csTranslate.instant('csContentEditorPreviewWidget.onlinePage'),
                                       options: []
                                   }
                               };

                               previewPages.each(function () {
                                   const el = $(this);
                                   if (locale === el.attr('locale')) {
                                       if (!language.child.defaultOption) {
                                           language.child.defaultOption = el.attr('qualified-url');
                                       }
                                       const qualifiedUrl = el.attr('qualified-url');
                                       // If an authorization token was returned with the response, we must include it as query parameter into the URL
                                       const enhancedUrl = qualifiedUrl && onlineResultValue.token ? onlineResultValue.token.enhanceUrl(qualifiedUrl) : qualifiedUrl;

                                       language.child.options.push({
                                           key: el.attr('qualified-url'),
                                           uniqueId: uniqueId++,
                                           name: el.attr('url'),
                                           url: enhancedUrl,
                                           locale: el.attr('locale')
                                       });
                                   }
                                   foundPage = true;
                               });

                               channel.child.options.push(language);
                           });

                           if (foundPage) {
                               foundSite = true;
                               if (!online.child.defaultOption) {
                                   online.child.defaultOption = channel.key;
                               }
                               online.child.options.push(channel);
                               if (!!contextLocale && localeKeys.indexOf(contextLocale) > -1) {
                                   channel.child.defaultOption = contextLocale;
                               } else {
                                   channel.child.defaultOption = localeKeys[0];
                               }
                           }
                       }

                       if (foundSite) {
                           root.options.push(online);
                       }

                       return root;
                   });
               }

               return root;
           }).then(function (root) {
               widgetInstance.getConfig().registerChangeListenerAndFire(handleWidgetConfig);

               treeObservable.setValue(root);

               return {
                   getTree: treeObservable.getReader,
                   getPath: pathObservable.getReader,
                   getPathFromConfig: widgetInstance.getConfig,
                   setPath: debounceCallback(setPath, 100),
                   getUrl: urlObservable.getReader,
                   refresh: refresh,
                   destroy: destroy,
                   openInNewWindow: openInNewWindow
               };

           });
       });

        function syncPreviews(cfg): void {
            cfg.preview = cfg.preview || {};

            if (
                cfg.preview.previewSyncLanguageToAllInstances
                || cfg.preview.previewSyncLanguageToAllInstances === undefined && LANGUAGE_SYNC_DEFAULT
            ) {
                widgetInstance.saveConfig(cfg);
                syncService.setGlobalPreviewConfig(cfg);
            } else {
                widgetInstance.saveConfig(cfg);
            }
        }

        function destroy() {
            if (pageContextProvider) {
                pageContextProvider.unregisterOnAfterMethodListener(refreshPreviewAfterSave);
            }
            if (metadataApplication) {
                metadataApplication.unregisterNativeChangeListener(getAssetInformation);
            }
        }

        function setPath(path) {
            let last;
            let opt;
            let widgetConfig;
            let previewConfig;
            pathObservable.setValue(path);
            widgetConfig = widgetInstance.getConfig().getValue() || {};
            widgetConfig = angular.copy(widgetConfig);
            previewConfig = widgetConfig.preview || {};
            previewConfig.channels = previewConfig.channels || {};

            delete previewConfig.channel;
            if (angular.isArray(path) && path.length) {
                previewConfig.channel = path[0];
                previewConfig.channels[previewConfig.channel] = JSON.stringify(path);
            }
            widgetConfig.preview = previewConfig;
            syncPreviews(widgetConfig);

            let url = null;
            let type = 'text/html';
            let needsFlush = false;
            let current: any = {child: treeObservable.getValue()};
            for (const p of path) {
                if (current.child) {
                    for (opt = 0; opt < current.child.options.length; opt += 1) {
                        if (current.child.options[opt].key === p) {
                            last = current;
                            current = current.child.options[opt];
                            last.child.defaultOption = current.key;
                            if (current.url) {
                                url = (url ? url : '') + current.url;
                            }
                            if (current.mimeType) {
                                type = current.mimeType;
                            }
                            if (current.needsFlush) {
                                needsFlush = true;
                            }
                            break;
                        }
                    }
                }
            }
            if (url && url.indexOf('censhare:') === 0) {
                url = csApiSession.session.resolveUrl(url);
            }
            currentUrl = url ? [type, url, needsFlush] : null;
            refresh();
        }



        function refresh() {
            const currentRefresh = pendingRefresh = {};
            const refreshFn = () => {
                $timeout(() => {
                    if (pendingRefresh === currentRefresh) {
                        urlObservable.setValue(currentUrl);
                    }
                }, 0, false);
            };
            urlObservable.setValue(null);

            let p: ng.IPromise<any> = $q.resolve();
            if (currentUrl && currentUrl[2] && contentEditorClientApplication) {
                p = contentEditorClientApplication.getValue().flushChanges(true);
            }

            p.then(() => validateUrl(currentUrl))
                .then(refreshFn)
                .catch((e) => {
                    csNotify.warning('csContentEditorPreviewWidget.refresh', e);
                });
        }

        /** Checks an authorization token contained in the URL for validity. Renews it if required. */
        function validateUrl(url: any[]): ng.IPromise<any> {
            if (!url) {
                return $q.resolve();
            }

            return bouncerAuth.checkAndUpdateUrl(url[1]).then((newUrl: string) => {
                url[1] = newUrl;
                return newUrl;
            });
        }

        function openInNewWindow(url, withAuth: boolean) {
            if (withAuth) {
                if (url.indexOf('?') > -1) {
                    url += '&';
                } else {
                    url += '?';
                }
                url += 'ssoAuthURL=' + window.location; // TODO: url encode url?
                window.open(url);
            } else {
                window.open(url);
            }
        }

        function refreshPreviewAfterSave(methodDetail) {
            if (methodDetail.method === 'checkin' || (currentUrl && currentUrl[2] && methodDetail.method === 'abortCheckout')) {
                $timeout(refresh, requestPreviewDelay, false);
            }
        }

        function handleWidgetConfig(widgetConfig) {
            let previewPath;
            let isPreviewTypeOnline;
            let editorPreviewConfig;

            if (widgetConfig) {
                editorPreviewConfig = widgetConfig.preview;
                if (editorPreviewConfig && editorPreviewConfig.channel) {
                    try {
                        previewPath = JSON.parse(editorPreviewConfig.channels[editorPreviewConfig.channel]);
                        isPreviewTypeOnline = editorPreviewConfig.channel && editorPreviewConfig.channel === 'online';
                        if (!pathLoaded && angular.isArray(previewPath) && !angular.equals(pathObservable.getValue(), previewPath)) {
                            if (isPreviewTypeOnline && !!contextLocale && !previewPath[2]) {
                                // switch locale to document-locale if not set
                                previewPath[2] = contextLocale;
                            }
                            pathObservable.setValue(previewPath);
                            pathLoaded = true;
                        }
                        requestPreviewDelay = 0;
                        if (isPreviewTypeOnline && editorPreviewConfig.previewCriticalRemoteDelayTimeout) {
                            requestPreviewDelay = parseInt(editorPreviewConfig.previewCriticalRemoteDelayTimeout, 0);
                        }
                    } catch (err) {
                    }
                }
            }
        }

    }
];

/**
 * Content editor controller
 */

const levels = ['level1', 'level2', 'level3', 'level4'];

const csContentEditorPreviewWidgetController = ['$scope', 'widgetDataManager', 'csContentEditorPreviewSyncService', 'csApiSession', 'pageInstance','csDownloadUtils',



    function($scope, widgetDataManager, csContentEditorPreviewSyncService,csApiSession,pageInstance,csDownloadUtils) {

        const transformationSetNewPPTXLayout = 'svtx:pptx_set_new_layout'
        updateSelections();
        widgetDataManager.getPath().registerChangeListenerAndFire(onPreviewTypeChange, $scope);
        widgetDataManager.getUrl().registerChangeListenerAndFire(updateUrl, $scope);
        $scope.refresh = widgetDataManager.refresh;
        $scope.openInNewWindow = widgetDataManager.openInNewWindow;
        $scope.pptxUrl = null;
        $scope.showSpinner = true;
        $scope.onLevelOptionSelected = function (option, level) {
            $scope[level] = option;
            levels.slice(levels.indexOf(level) + 1).forEach(key => $scope[key] = null);
        };

        $scope.$watchGroup(levels, updateWatches);

        $scope.download = () => {
            if(!$scope.viewUrl) {return}
            $scope.showSpinner = true;
            let assetId = pageInstance.getPathContextReader().getValue().get('id')
            let r = Math.random().toString(36).slice(-5)
            let filename = new Date().getTime()+"-"+r+".pptx";
            let path = "/temp/"+filename;
            let selectedOption =  $scope.viewUrl.split(":")[1]
            console.log("render ppt with textId:"+assetId+" templateId:"+selectedOption+ " path:"+path);

            csApiSession.execute('com.savotex.api.powerpoint.preview', {assetId:assetId, targetId:selectedOption, path:path})
                .then(() => {
                    //$scope.previewUrl = csApiSession.session.resolveUrl('/rest/service/filesystem'+path);
                    console.log("render fertig");
                    let dlUrl = csApiSession.session.resolveUrl('/rest/service/filesystem'+path);
                    $scope.showSpinner = false;
                    //$scope.showPreview = true;
                    console.log("open "+dlUrl);
                    csDownloadUtils.downloadFile(dlUrl,filename);
                    return true;
                });
        }



        $scope.updatePPTXDropDown = (result) => {
            console.log('upDatePPTXDropDown')

            if(!Array.isArray(result.option)) {
                result.option = [result.option]
            }


            let opt = $scope.level1
            //TODO oder müssen wir neue machne?
            let uniqueId= opt.child.options[0].uniqueId+1000
            opt.child.options=[]

            angular.forEach(result.option, function (option) {
                let name = option.display_value
                let pptxId = option.value
                // der letzte ist der default
                opt.child.defaultOption = pptxId
                opt.defaultLayoutId= pptxId

                opt.child.options.push({
                    key: pptxId,
                    uniqueId: uniqueId++,
                    name: name,
                    // Text Asset
                    url: "pptx:" + pptxId,
                    mimeType: 'application/pptx',
                    needsFlush: true,
                    position:option.position
                });
            });
            $scope.viewUrl= "pptx:"+ opt.defaultLayoutId
            let level2 = opt.child.options[opt.child.options.length-1];
            $scope.level2.name=level2.name
            $scope.level2.uniqueId=level2.uniqueId
            $scope.level2.key=level2.key
            $scope.level2.url=level2.url
            $scope.$digest()
        }


        // Neues PPTX-Layout übernehmen
        $scope.applyLayout = () => {
            $scope.showSpinner = true;
            let assetId = pageInstance.getPathContextReader().getValue().get('id')
            let selectedLayoutId =  $scope.viewUrl.split(":")[1]
            let layoutId =  $scope.level1.defaultLayoutId  //  pageInstance.getPathContextReader().getValue().get('id')
            let params = {
                contextAsset:layoutId,
                variables: [
                    { key: 'masterSlideId', value:selectedLayoutId}
                ]
            }
            console.log("applyLayout start")

            $scope.showUpdatePPTXLayout= false
            $scope.pptxShowLevel1 = true
            $scope.level1.defaultLayoutId = selectedLayoutId


            csApiSession.transformation(transformationSetNewPPTXLayout,
                params)
                .then(() =>{
                    console.log("applyLayout end")
                    // Dropdown neu belegen
                    csApiSession.transformation(transformationGetAlternateLayouts,{'contextAsset':assetId})
                        .then(
                            function (result) {
                                console.log("applyLayout update drop down")
                                $scope.updatePPTXDropDown(result);
                                $scope.pptxShowLevel1 = true
                            }
                        )
                        .catch()

                    $scope.showSpinner =false
                })
                .catch(() =>{
                    console.log("applyLayout error")
                    $scope.showSpinner =false
                })
        }


        $scope.showUpdatePPTXLayout= false
        $scope.pptxShowLevel1 = true

        return

        /***********************************************************************************************/

        function updateSelections() {
            const tree = widgetDataManager.getTree().getValue();
            let path = widgetDataManager.getPath().getValue();
            let level;
            let current;
            let opt;
            let found;

            $scope.root = tree;

            const widgetConfig: any = widgetDataManager.getPathFromConfig().getValue() || {};
            widgetConfig.preview = widgetConfig.preview || {};

            if (widgetConfig.preview.previewSyncLanguageToAllInstances && csContentEditorPreviewSyncService.hasGlobalPreviewConfig()) {
                const pathFromConfig: any = csContentEditorPreviewSyncService.getGlobalPreviewConfig();
                const _channel: string = pathFromConfig.preview.channel;
                const _channels: any = pathFromConfig.preview.channels;
                if (_channel && _channels && _channels[_channel]) {
                    // config has prio to initialize
                    path = JSON.parse(_channels[_channel]);
                }
            }


            if (path) {
                current = {child: tree};
                for (level = 0; level < path.length; level += 1) {
                    found = false;
                    if (current.child) {
                        for (opt = 0; opt < current.child.options.length; opt += 1) {
                            if (current.child.options[opt].key === path[level]) {
                                current = current.child.options[opt];
                                $scope['level' + (level + 1)] = current;
                                found = true;
                                break;
                            }
                        }
                    }
                    if (!found) {
                        delete $scope['level' + (level + 1)];
                    }
                }
            }
        }

        function onPreviewTypeChange(path) {
            $scope.previewTypeIsTypeOnline = path && path[0] === 'online';
            $scope.showUpdatePPTXLayout=  $scope.level1 && $scope.level1.key &&
                                          $scope.level1.key == 'pptx' &&
                                          $scope.level1.child.options.length>1 &&
                                          $scope.level1.defaultLayoutId != undefined &&
                                          path[1]!=$scope.level1.defaultLayoutId
            $scope.disableLevel1 = $scope.level1 && $scope.level1.key &&  $scope.level1.key == 'pptx' && $scope.level1.child.options.length<2
        }




        function updateWatches(watches) {
            const selections = [];

            for (let i = 0; i < watches.length; i++) {
                if (watches[i] && watches[i].key) {
                    selections.push(watches[i].key);
                    if (watches[i].child && watches[i].child.defaultOption && !watches[i + 1]) {
                        for (let j = 0; j < watches[i].child.options.length; j++) {
                            if (watches[i].child.options[j].key === watches[i].child.defaultOption) {
                                $scope['level' + (i + 2)] = watches[i + 1] = watches[i].child.options[j];
                                break;
                            }
                        }
                    }
                }
            }

            widgetDataManager.setPath(selections);
        }


        function refreshpptx ()  {
            $scope.showSpinner = true;
            let r = Math.random().toString(36).slice(-5);
            let filename = new Date().getTime()+"-"+r+".jpg";
            let path = "/temp/"+filename;
            let assetId = pageInstance.getPathContextReader().getValue().get('id')
            let selectedId =  $scope.viewUrl.split(":")[1]

            console.log("render ppt with textId:"+assetId+" templateId:"+selectedId+ " path:"+path);

            csApiSession.execute('com.savotex.api.powerpoint.preview', {assetId:assetId, targetId:selectedId, path:path})
                .then(() => {
                    let previewUrl = csApiSession.session.resolveUrl('/rest/service/filesystem'+path);

                    $scope.pptxUrl  = previewUrl;
                    $scope.showSpinner = false;

                });
        }


        function updateUrl(url) {
            if (url) {
                $scope.viewType = url[0];
                $scope.viewUrl = url[1]
                let selectedId =  $scope.viewUrl.split(":")[1]
                if($scope.viewType  == 'application/pptx') {
                    refreshpptx()
                    $scope.showUpdatePPTXLayout=  $scope.level1 && $scope.level1.key &&
                        $scope.level1.key == 'pptx' &&
                        $scope.level1.child.options.length>1 &&
                        $scope.level1.defaultLayoutId != undefined &&
                        selectedId!=$scope.level1.defaultLayoutId
                }
            } else {
                $scope.viewType = null;
                $scope.viewUrl = null;
            }
        }
    }
];

const csTrustedFilter = ['$sce', function($sce) {
    return function(url) {
        return $sce.trustAsResourceUrl(url);
    };
}];

const csContentEditorPreviewConfigController = ['$scope', 'config', 'pageInstance', 'csContentEditorPreviewSyncService',
    function($scope, config, pageInstance, csContentEditorPreviewSyncService) {

        // configurable preview generation timeout (used for 'online' preview)
        config.preview = config.preview || {};
        $scope.previewCriticalRemoteDelayTimeout = config.preview.previewCriticalRemoteDelayTimeout || REQUEST_PREVIEW_DELAY_DEFAULT;
        $scope.$watch('previewCriticalRemoteDelayTimeout', function(previewCriticalRemoteDelayTimeout) {
            if (config.preview.previewCriticalRemoteDelayTimeout !== previewCriticalRemoteDelayTimeout) {
                config.preview.previewCriticalRemoteDelayTimeout = previewCriticalRemoteDelayTimeout;
            }
        });

        $scope.previewSyncLanguageToAllInstances = config.preview.previewSyncLanguageToAllInstances
            || config.preview.previewSyncLanguageToAllInstances === undefined && LANGUAGE_SYNC_DEFAULT;
        $scope.$watch('previewSyncLanguageToAllInstances', function(previewSyncLanguageToAllInstances) {
            if (config.preview.previewSyncLanguageToAllInstances !== previewSyncLanguageToAllInstances) {
                config.preview.previewSyncLanguageToAllInstances = previewSyncLanguageToAllInstances;
                csContentEditorPreviewSyncService.syncContentEditorPreviewSyncOption(pageInstance, config);
            }
        });


    }
];

const pdfJsPreviewViewerDirective = [function () {
    return {
        restrict: 'E',
        replace: true,
        template: `
            <object data="{{viewerUrl}}">
                <embed src="{{viewerUrl}}"/>
            </object>`,
        scope: {
            url: '='
        },
        controller: ['$scope', 'csContentEditorPreviewLoadingStateService', function ($scope, csContentEditorPreviewLoadingStateService) {
            $scope.csContentEditorPreviewLoadingStateService = csContentEditorPreviewLoadingStateService;
        }],
        link: function (scope: any, el: ng.IAugmentedJQuery) {
            const cb = () => {
                scope.csContentEditorPreviewLoadingStateService.setLoadingState(false);
            };
            scope.$watch('url', function (url: string) {
                scope.viewerUrl = url || '';
                el[0].removeEventListener('load', cb);

                if (el && el.length && scope.viewerUrl && scope.viewerUrl.length > 0) {
                    el[0].addEventListener('load', cb, { once: true });
                }
            });

            scope.$on('$destroy', function () {
                el[0].removeEventListener('load', cb);
            });
        }
    };
}];
const СsContentEditorPreviewLoadingStateService = ['csServices', function (csServices) {
    const loading = csServices.createObservable();

    return {
        setLoadingState: (state: boolean): void => {
            loading.setValue(state);
        },
        getLoadingState: () => {
            return loading.getReader();
        },
    };
}];

export {
    csContentPreviewWidgetHeadless,
    csContentEditorPreviewWidgetController,
    csTrustedFilter,
    csContentEditorPreviewConfigController,
    pdfJsPreviewViewerDirective,
    СsContentEditorPreviewLoadingStateService
};
