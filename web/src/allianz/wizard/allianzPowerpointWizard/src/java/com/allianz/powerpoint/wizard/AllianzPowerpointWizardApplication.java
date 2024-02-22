package com.allianz.powerpoint.wizard;

import com.censhare.api.applications.wizards.AbstractWizardsApplication;
import com.censhare.api.applications.wizards.model.WizardModel;
import com.censhare.server.support.api.impl.CommandAnnotations.CommandHandler;
import com.censhare.server.support.api.impl.CommandAnnotations;

@CommandHandler(command = "com.allianz.powerpoint.wizard", scope = CommandAnnotations.ScopeType.CONVERSATION)
public class AllianzPowerpointWizardApplication extends AbstractWizardsApplication {
    @Override
    protected void initWizardData(WizardModel wizard) throws Exception {
        logger.info("### Init Powerpoint Wizard " + wizard);
    }

    @Override
    protected boolean beforeStepAction(WizardStepAction action, WizardModel.WizardStep step) throws Exception {
        logger.info("### Enter STEP " + step);
        return true;
    }

    @Override
    protected boolean afterStepAction(WizardStepAction action, WizardModel.WizardStep step) throws Exception {
        logger.info("### LEAVE STEP " + step);
        return true;
    }

    @Override
    protected boolean onCancel() throws Exception {
        return true;
    }

    @Override
    protected Object onFinish() throws Exception {
        return null;
    }
}
