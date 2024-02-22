import { groupedInjections } from '@cs/framework/csApi/csUtils/csUtils';
import { IcsApiSession } from '@cs/framework/csApi/cs-api.model';
import { IcsWizardStep, IcsWizardInstance } from '@cs/client/frames/csMainFrame/csWizards/csWizardContainer/wizard';
import {IPptxSlide} from "./allianz-powerpoint-wizard-step4.component";

interface IWizardDependencies {
    wizardStep: IcsWizardStep;
    wizardInstance: IcsWizardInstance;
    csApiSession: IcsApiSession;
    csQueryBuilder: any;
    csDownloadUtils: any;
}

@groupedInjections
class StepController implements ng.IComponentController {
    public static $inject: string[] = [
        'wizardStep',
        'wizardInstance',
        'csApiSession',
        'csQueryBuilder',
        'csDownloadUtils'
    ];
    private getDependencies: () => IWizardDependencies;

    public slides: Array<IPptxSlide>;
    public chunkedSlides: Array<IPptxSlide>;
    private downloadFileName: string;
    private chunkSize: number = 3;

    public $onInit() {
        const { wizardStep, wizardInstance } = this.getDependencies();
        console.log('Enter Step 5', wizardStep);

        const actions = wizardInstance.actions.getValue();
        const step4: IcsWizardStep = wizardInstance.stepByName('allianzPowerpointWizardStep4');

        if (actions.done) {
            actions.done.callback = this.executePptxCommand;
            actions.done.title= 'allianzPowerpointWizard.downloadPresentation';
        }

        if (step4.data) {
            if (step4.data.slides) {
                this.slides = step4.data.slides;
                if (this.slides) {
                    this.slides = Array.isArray(this.slides) ? this.slides : [this.slides];
                    this.slides = this.slides.filter(slide => {
                        return slide.isStatic || slide.selected;
                    });
                    this.chunkedSlides = this.sortAndChunkArray(this.slides, this.chunkSize);
                }
            }
            if (step4.data.downloadFileName) {
                this.downloadFileName = `${step4.data.downloadFileName}.pptx`;
            } else {
                this.downloadFileName = `${Math.random().toString(36).slice(-5)}.pptx`;
            }
        }

        wizardInstance.enablePrev();
        wizardInstance.enableDone();
    }

    public $onDestroy() {

    }

    private executePptxCommand = () => {
        const { csApiSession, csDownloadUtils, wizardInstance } = this.getDependencies();
        const cmd: string = 'com.savotex.api.powerpoint.mix-merge';
        const path: string = `/temp/${this.downloadFileName}`;
        const param: any = {
            path: path,
            mergeSlides: {
                slide: this.slides
            }
        };

        wizardInstance.lock();
        wizardInstance.disableDone();
        wizardInstance.disablePrev();
        wizardInstance.disableCancel();
        wizardInstance.progress(-1, 'allianzPowerpointWizard.renderingPlaceholder');

        csApiSession.execute(cmd, param).then(() => {
            const downloadUrl: string = csApiSession.session.resolveUrl('/rest/service/filesystem' + path);
            csDownloadUtils.downloadFile(downloadUrl, this.downloadFileName);
        }).catch(err => {
            console.log('Failed on merging slides', err);
        }).finally(() => {
            wizardInstance.unlock();
            wizardInstance.removeProgress();
            wizardInstance.close();
        })
    };

    protected sortAndChunkArray(array: Array<any>, size:number = 4): Array<any> {
        const chunkedArray = [];
        let copy = Array.from(array);
        let index = 0;
        copy = copy.sort((a, b)=> a.sorting - b.sorting);
        while (index < copy.length) {
            chunkedArray.push(copy.slice(index, size + index));
            index += size;
        }
        return chunkedArray;
    }

    public getBadgeNumber(index:string, parentIndex:string) {
        const i = Number(index) + 1 + Number(parentIndex) * this.chunkSize;
        return '0'.concat(String(i)).substr(-2);
    }
}

const template: string = `
    <article class="csWidget cs-has-no-header">
        <div class="csWidget__content">
            <div class="csWidget__content__inner">
                <censhare-scroll>
                    <div class="allianzPowerpointWizard__container_large">
                        <div class="cs-grid-wrapper" style="width: 80%; margin: auto;" ng-repeat="chunk in $ctrl.chunkedSlides track by $index">
                            <div class="cs-grid-cell-1of3" ng-repeat="item in chunk track by $index">
                                <div class="cs-p-s pptexCell">
                                    <div class="preview-outer card card-2">
                                        <div class="preview-image" ng-style="::{'background-image': 'url(' + (item.preview | csUrlFilter) + ')'}"">
                                            <div class="wrapper">
                                                <span class="badge">{{$ctrl.getBadgeNumber($index, $parent.$index)}}</span>
                                            </div>
                                        </div>
                                        <div class="preview-headline">{{item.display_name}}</div>
                                        <div class="preview-info">
                                            <span ng-if="item.isStatic === false || item.isStatic === 'false'">Diese Folie wird automatisch mit Produkt-Inhalten befüllt.</span>
                                        </div>
                                    </div>  
                                 </div>
                             </div>
                            </div>  
                        </div>
                    </div>
                </censhare-scroll>
            </div>
        </div>       
    </article>
`;

export const allianzPowerpointWizardStep5: ng.IComponentOptions = {
    template: template,
    controller: StepController,
    bindings: {}
};