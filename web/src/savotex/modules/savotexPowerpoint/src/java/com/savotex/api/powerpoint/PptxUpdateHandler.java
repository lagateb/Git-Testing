package com.savotex.api.powerpoint;

import com.censhare.server.support.api.CommandContext;

import static com.censhare.server.support.api.impl.CommandAnnotations.*;

@CommandHandler(command = "com.savotex.api.powerpoint.update", scope = ScopeType.REQUEST)
public class PptxUpdateHandler extends PptxCommandHandlerUtils {
    private static final String commandName = "savotex.pp-update";

    @Execute
    public Object execute(CommandContext context, final DefaultParam param) throws Exception {
        if (param.assetId < 1) {
            throw new Exception("No asset id in param provided");
        }
        return executeCommandSync(context, param, commandName);
    }
}
