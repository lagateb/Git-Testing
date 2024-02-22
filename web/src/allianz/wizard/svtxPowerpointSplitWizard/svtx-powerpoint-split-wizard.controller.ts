export class SvtxPowerpointSplitWizardController {
    public static $name = 'svtxPowerpointSplitWizardController';
    public static $inject = ['wizardInstance'];

    constructor(wizardInstance) {
        // Entfernung der Buttons Save & Close | Previous
        const oldActions = wizardInstance.actions.getValue();
        if (oldActions) {
            if (oldActions.save) delete oldActions.save;
            if (oldActions.prev) delete oldActions.prev;
        }
    }
}