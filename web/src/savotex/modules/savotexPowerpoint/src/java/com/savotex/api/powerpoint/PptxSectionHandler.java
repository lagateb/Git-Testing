package com.savotex.api.powerpoint;

import com.censhare.server.support.api.CommandContext;
import com.censhare.support.util.logging.ContextLogger;

import java.util.logging.Logger;

import static com.censhare.server.support.api.impl.CommandAnnotations.*;

@CommandHandler(command = "com.savotex.api.powerpoint.section", scope = ScopeType.REQUEST)
public class PptxSectionHandler extends PptxCommandHandlerUtils{
    private static final Logger logger = ContextLogger.getLogger(PptxSectionHandler.class);
    private static final String commandName = "savotex.pp-section";

    @Execute
    public Object execute(CommandContext context, final DefaultParam param) throws Exception {
        if (param.assetId < 1) {
            throw new Exception("No asset id in param provided");
        }
        return executeCommandSync(context, param, commandName);
    }
}
