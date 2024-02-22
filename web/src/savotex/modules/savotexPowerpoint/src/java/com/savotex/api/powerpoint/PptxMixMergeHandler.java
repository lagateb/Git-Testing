package com.savotex.api.powerpoint;

import com.censhare.server.support.api.CommandContext;
import com.censhare.support.util.logging.ContextLogger;

import java.util.logging.Logger;

import static com.censhare.server.support.api.impl.CommandAnnotations.*;

@CommandHandler(command = "com.savotex.api.powerpoint.mix-merge", scope = ScopeType.REQUEST)
public class PptxMixMergeHandler extends PptxCommandHandlerUtils{
    private static final Logger logger = ContextLogger.getLogger(PptxMixMergeHandler.class);
    //private static final String commandName = "savotex.pp-mix-merge";
    //private static final String commandName = "savotex.pp-preview";
    @Execute
    public Object execute(CommandContext context, final DefaultParam param) throws Exception {
        return executeCommandSync(context, param, MIX_MERGE_COMMAND);
    }
}
