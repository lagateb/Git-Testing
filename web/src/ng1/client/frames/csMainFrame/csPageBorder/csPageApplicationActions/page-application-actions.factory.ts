const csPageApplicationActions = ['applicationObservable', 'pageInstance', '$q', 'csNotify', 'csNavigationManager', '$log', '$timeout',
function(applicationObservable, pageInstance, $q, csNotify, csNavigationManager, $log, $timeout) {

    const applicationValue = applicationObservable.getValue();
    const canAbortCheckout = applicationValue.methods.abortCheckout && angular.isFunction(applicationValue.methods.abortCheckout);
    const canCheckin = applicationValue.methods.checkin && angular.isFunction(applicationValue.methods.checkin);

    function chainMethods(before, main, after) {
        return $q.when(angular.isFunction(before) ? before() : true).then(
            function(resolveBefore) {
                if (resolveBefore === false) {
                    return false;
                }
                if (angular.isFunction(after)) {
                    return callWhenAvailable(main).then(function() {
                        return after();
                    });
                }
                return callWhenAvailable(main);
            }
        );
    }

    function callWhenAvailable(methodName) {
        let methods = applicationObservable.getValue().methods;
        let deferred;
        let listener;
        let timeout;

        if (!methods || !angular.isFunction(methods[methodName])) {
            $log.info('No method ' + methodName + ' found in the current state of the application');
            deferred = $q.defer();
            listener = function(newApplicationValue) {
                methods = newApplicationValue.methods;

                if (methods && angular.isFunction(methods[methodName])) {
                    applicationObservable.unregisterChangeListener(listener);

                    deferred.resolve(methods[methodName]());
                    $timeout.cancel(timeout);
                    $log.info('OK: Method ' + methodName + ' found and called');
                }
            };

            timeout = $timeout(function() {
                applicationObservable.unregisterChangeListener(listener);
                deferred.reject('No method ' + methodName + ' found in the current state of the application');
                $log.info('No method ' + methodName + ' found in the current state of the application. Promise rejected');
            }, 120000, false);

            applicationObservable.registerChangeListenerAndFire(listener);
            return deferred.promise;
        }

        $log.info('OK: Method ' + methodName + ' found and called');
        return methods[methodName]();
    }

    return {

        /**
         * Basic actions for assets
         * @return {{cancel: {title: string, callback: callback}, save: {title: string, primary: boolean, callback: callback}}}
         */
        assetBaseActions: function() {
            const actions: any = {
                cancel: {
                    kind: 'default',
                    enabled: true,
                    cssClass: 'cs-is-transparent',
                    title: 'csCommonTranslations.cancel',
                    priority: 10,
                    callback: function() {
                        if (canAbortCheckout) {
                            return chainMethods(this.before, 'abortCheckout', this.after);
                        } else {
                            return $q.reject('No method abortCheckout');
                        }
                    },
                    before: undefined,
                    after: undefined
                },
                separator: {
                    priority: 19,
                    type: 'separator'
                },
                save: {
                    kind: 'default',
                    enabled: true,

                    title: 'csCommonTranslations.save',
                    priority: 30,
                    primary: true,
                    callback: function() {
                        if (canCheckin) {
                            return chainMethods(this.before, 'checkin', this.after).then(
                                function(result) {
                                    if (result === false) {
                                        return false;
                                    }
                                },
                                function(result) {
                                    if (result !== 'close') {
                                        csNotify.error('Check-in', 'Check-in asset failed', result);
                                    }
                                }
                            );
                        } else {
                            return $q.reject('No method checkin');
                        }
                    },
                    before: undefined,
                    after: undefined
                }
            };

            /**
             * Extend with a save and close action
             * @type {{kind: string, title: string, callback: callback, before: *, after: *}}
             */
            actions.saveClose = {
                kind: 'extra',
                cssClass: 'cs-is-transparent',
                enabled: true,
                priority: 20,
                primary: false,
                title: 'csCommonTranslations.save_close',

                callback: function() {
                    return actions.save.callback.call(this).then(
                        function(result) {
                            if (result === false) {
                                return false;
                            }
                            // TODO: Hack: Sometimes open entry remains in navigation bar after close of page. Does not occur if close is done after a short delay
                            if (actions.saveClose.closeDelayMs > 0) {
                                $timeout(function() {
                                    csNavigationManager.closePage(pageInstance);
                                }, actions.saveClose.closeDelayMs, false);
                            } else {
                                csNavigationManager.closePage(pageInstance);
                            }
                        }
                    );
                },
                before: function() { return actions.save.before ? actions.save.before() : undefined; },
                after: function() { return actions.save.after ? actions.save.after() : undefined; },
                // TODO: Hack: Sometimes open entry remains in navigation bar after close of page. Does not occur if close is done after a short delay
                closeDelayMs: 0
            };

            return actions;
        }
    };
}];

export { csPageApplicationActions };
