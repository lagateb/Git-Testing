package com.savotex.api.wizard.powerpointSplit;

import com.censhare.api.applications.wizards.AbstractWizardsApplication;
import com.censhare.api.applications.wizards.model.WizardModel;
import com.censhare.api.applications.wizards.model.WizardModel.*;
import com.censhare.server.support.api.impl.CommandAnnotations.*;

@CommandHandler(command = "com.savotex.api.wizard.powerpointSplit", scope = ScopeType.CONVERSATION)
public class PowerpointSplitCommandHandler extends AbstractWizardsApplication {

    public enum WizardSteps {
        svtxPowerpointSplitWizardStep1;

        public boolean isStep(WizardStep step) {
            return step != null && step.name.equals(this.name());
        }
    }

    @Override
    protected void initWizardData(WizardModel wizard) throws Exception {
        logger.info("### Savotex Demo Wizard init");
    }

    @Override
    protected boolean beforeStepAction(WizardStepAction action, WizardStep step) throws Exception {
        logger.info("### Before Step Action" + step);
        return true;
    }

    @Override
    protected boolean afterStepAction(WizardStepAction action, WizardStep step) throws Exception {
        logger.info("### After Step Action" + step);
        return true;
    }

    @Override
    protected boolean onCancel() throws Exception {
        logger.info("### Savotex Demo Wizard canceled");
        return true;
    }

    @Override
    protected Object onFinish() throws Exception {
        logger.info("### Savotex Demo Wizard finished");
        return true;
    }
}
