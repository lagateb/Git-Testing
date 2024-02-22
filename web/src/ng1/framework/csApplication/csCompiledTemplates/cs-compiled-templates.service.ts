import * as censhare from 'censhare';
import * as angular from 'angular';
import { IcsLogger } from '../../csApi/csLogger/logger';

class CsCompiledTemplates {
    public static $name: string = 'csCompiledTemplates';
    public static $inject: string[] = ['$compile', '$http', '$templateCache', '$q', 'csLogger', 'csModuleLoader'];

    private compiledTemplates = {};
    private pendingTemplates = {};
    private compiledComponents = {};
    private logger = this.csLogger.get('csCompiledTemplates');

    constructor(private $compile: ng.ICompileService,
                private $http: ng.IHttpService,
                private $templateCache: ng.ITemplateCacheService,
                private $q: ng.IQService,
                private csLogger: IcsLogger,
                private csModuleLoader: csModuleLoader.IcsModuleLoaderModule) {
            console.log( "##### Compiled Templates");
    }

    public compile(template) {
        this.compiledTemplates[template.url] = this._compile(template);

        return this.compiledTemplates[template.url];
    }

    public getCompiledComponent(module, componentName) {
        // Splitted compiled template and components map in order to keep url properties only in templates map
        const result = this.compiledComponents[componentName];

        if (result) {
            return this.$q.when(result);
        }

        if (this.csModuleLoader.isLoaded([module])) {
            const componentSelector = componentName.replace(/([a-zA-Z])(?=[A-Z])/g, '$1-').toLowerCase();
            this.compiledComponents[componentName] = this._compile({
                template: '<' + componentSelector + '></' + componentSelector + '>'
            });
            return this.$q.when(this.compiledComponents[componentName]);
        }

        return this.csModuleLoader.load([module]).then(() => {
            const componentSelector = componentName.replace(/([a-zA-Z])(?=[A-Z])/g, '$1-').toLowerCase();
            this.compiledComponents[componentName] = this._compile({
                template: '<' + componentSelector + '></' + componentSelector + '>'
            });
            return this.$q.when(this.compiledComponents[componentName]);
        }).catch((err) => this.logger.error(err));
    }

    public getCompiledTemplateAsPromise(module, templateName) {
        const tpl = this.getCompiledTemplate(module, templateName);
        if (angular.isFunction(tpl.then)) {
            return tpl;
        } else {
            return this.$q.when(tpl);
        }
    }

    public getCompiledTemplate(module, templateName) {
        let result = this.getTemplateFromCache(module, templateName);
        let url;

        if (!result) {
            url = censhare.getResourceURL(module, templateName);

            if (this.pendingTemplates.hasOwnProperty(url)) {
                result = this.pendingTemplates[url];
            } else {
                result = this.getTemplateData(module, templateName).then((template) => {
                    delete this.pendingTemplates[url];
                    if (template && angular.isObject(template) && template.hasOwnProperty('template') && template.hasOwnProperty('url')) {
                        this.compiledTemplates[url] = this._compile(template);
                        return this.compiledTemplates[url];
                    }
                }).catch((err) => this.logger.error(err));

                this.pendingTemplates[url] = result;
            }
        }
        return result;
    }

    public getComponentFromCache(componentName) {
        return this.compiledComponents[componentName] || null;
    }

    public getTemplateFromCache(module, templateName) {
        const url = censhare.getResourceURL(module, templateName);

        if (this.compiledTemplates.hasOwnProperty(url)) {
            return this.compiledTemplates[url];
        } else {
            return null;
        }
    }

    public getTemplateData(module, templateName): any {
        if (this.csModuleLoader.isLoaded([module])) {
            return this.loadTemplate(module, templateName);
        }
        return this.$q.all({
            modules: this.csModuleLoader.load([module]),
            template: this.loadTemplate(module, templateName)
        }).then((promData: any) =>
            promData.template
        ).catch((err) =>
            this.logger.error(err)
        );
    }

    private _compile(template) {
        try {
            /*console.log( "#### compile template:", template);*/
            // template that needs to be compiled
            return this.$compile(template.template);
        } catch (e) {
            if (e && e.toString && angular.isFunction(e.toString)) {
                this.logger.error('an error occurred while compiling a template: ', template, e, e.toString());
            } else {
                this.logger.error('an error occurred while compiling a template: ', template, e);
            }
        }
    }

    private loadTemplate(module, templateName): any {
        if (templateName === false) {
            return this.$q.when(true);
        } else {
            this.logger.fine('Load template: ', module, templateName);
            const url = censhare.getResourceURL(module, templateName);
            return this.$http.get(url, {cache: this.$templateCache})
                .then((response) => {
                    // TODO: analyse status code
                    return {
                        template: response.data,
                        url: url,
                        module: module,
                        templateName: templateName
                    };
                }
                ).catch((err) =>
                    this.logger.error(err)
                );
        }
    }

}

export { CsCompiledTemplates };
