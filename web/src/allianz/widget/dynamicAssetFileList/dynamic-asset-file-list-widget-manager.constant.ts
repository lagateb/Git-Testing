/*
 * Copyright (c) by censhare AG
 */

import { IPromise } from 'angular';
import { FileState, IMessage } from '@cs/client/base/csUploadsManager/cs-uploads-manager.service';

export interface IWidgetDataManager {
    uploadReader: any;
    uploadStart(promise: IPromise<any>): void;
    getApplication(): any;
}

const csDynamicAssetFileListWidgetManager = ['pageContextProviderPromise', 'csServices',
function(pageContextProviderPromise, csServices) {
    return pageContextProviderPromise.then(function(pageContextProvider) {
        const InitialState: IMessage = {
            state: {
                error: null,
                state: FileState.END,
                progress: 0,
                reentries: 0
            },
            payload: {
                uploadProgress: false
            }
        };

        let assetApplication;

        const uploadObservable = csServices.createObservable({data: [InitialState]});

        const endSuccess = (end: IMessage[]) => {
            if (!end[0].payload) {
                end[0].payload = {};
            }

            end[0].payload.uploadProgress = false;
            uploadObservable.setValue({data: end});

            uploadObservable.unbind();
        };

        const endError = (error: IMessage[]) => {
            if (!error[0].payload) {
                error[0].payload = {};
            }

            error[0].payload.uploadProgress = false;
            uploadObservable.setValue(error);

            uploadObservable.unbind();
        };

        const uploadProgress = (progress: IMessage) => {

            progress.payload = {};
            progress.payload.uploadProgress = true;
            uploadObservable.setValue({ data: [progress]});
        };

        if (pageContextProvider.getLiveApplicationInstance) {
            assetApplication = pageContextProvider.getLiveApplicationInstance('com.censhare.api.applications.asset.metadata.AssetInfoApplication');
        }

        return {
            uploadReader: uploadObservable.getReader(),
            uploadStart: (promise: IPromise<any>) => {
                const newState: IMessage = {
                    state: {
                        error: null,
                        state: FileState.READY,
                        progress: 0,
                        reentries: 0
                    },
                    payload: {
                        uploadProgress: true
                    }
                };
                uploadObservable.setValue({data: [newState]});

                promise.then(endSuccess, endError, uploadProgress);
            },
            getApplication : function() {
                return assetApplication;
            }
        };
    });
}];

export { csDynamicAssetFileListWidgetManager };
