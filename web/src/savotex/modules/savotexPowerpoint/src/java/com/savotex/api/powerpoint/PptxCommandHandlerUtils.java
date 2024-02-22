package com.savotex.api.powerpoint;

import com.censhare.db.query.model.AssetQBuilder;
import com.censhare.model.logical.api.domain.Asset;
import com.censhare.server.kernel.Command;
import com.censhare.server.manager.CommonServiceFactory;
import com.censhare.server.support.api.CommandContext;
import com.censhare.server.support.api.transaction.QueryService;
import com.censhare.support.context.Platform;
import com.censhare.support.transaction.TransactionException;
import com.censhare.support.xml.AXml;

import java.util.ArrayList;
import java.util.List;

import static com.censhare.support.json.ClassAnalyzer.Key;


public class PptxCommandHandlerUtils {
    private static final long EXEC_TIMEOUT = 6000000;

    public static String MIX_MERGE_COMMAND =  "savotex.pp-mix-merge";

    protected static class DefaultParam {
        @Key
        public long assetId = -1;
        @Key
        public String issueName;
        @Key
        public long targetId = -1;
        @Key
        public String path;
        @Key
        public AXml mergeSlides;
    }

    private Asset getAsset(long id) throws TransactionException {
        QueryService qs = Platform.getCCService(QueryService.class);
        if (qs != null) {
            AssetQBuilder qb = qs.prepareQBuilder();
            Iterable<Asset> assets = qs.queryAssets(qb.select().where(qb.feature("censhare:asset.id", id)));
            if (assets.iterator().hasNext()) {
                return assets.iterator().next();
            }
        }
        return null;
    }

    private AXml getCommandSlotXml(Command command) throws Exception {
        return (AXml) command.getCommandData().getSlot(Command.XML_COMMAND_SLOT);
    }

    private Command createCommand(CommandContext commandContext, String commandName) throws Exception {
        return CommonServiceFactory.createCommand(commandContext.getTransactionContext(), commandName);
    }


    /*
    * Führt ein kommando anhand des namens aus. Damit es das kontext asset kennt,
    * muss das asset xml dem kommando xml hinzugefügt werden.
    * */
    protected int executeCommandSync(CommandContext context, DefaultParam param, String commandName) throws Exception {
        Command cmd = createCommand(context, commandName);
        AXml cmdXml = getCommandSlotXml(cmd);

        if (param.assetId > 0) {
            Asset asset = getAsset(param.assetId);
            if (asset != null) {
                cmdXml.appendNewChild("assets").appendChild(asset.toLegacyXml());
                AXml pptConfig = cmdXml.findX("config/pptx");
                if (pptConfig == null) {
                    pptConfig = cmdXml.appendNewChild("config").appendNewChild("pptx");
                }
                if (param.issueName != null) {
                    pptConfig.appendNewChild("issueName").setAttr("value", param.issueName);
                }
                if (param.targetId > -1) {
                    pptConfig.appendNewChild("targetId").setAttr("value", param.targetId);
                }
                if (param.path != null) {
                    pptConfig.appendNewChild("path").setAttr("value", param.path);
                }
                return cmd.executeSync(EXEC_TIMEOUT);
            }
        } else if(commandName.equals(MIX_MERGE_COMMAND)) {
            AXml pptConfig = cmdXml.findX("config/pptx");
            if (pptConfig == null) {
                pptConfig = cmdXml.appendNewChild("config").appendNewChild("pptx");
            }
            if (param.path != null) {
                pptConfig.appendNewChild("path").setAttr("value", param.path);
            }
            if (param.mergeSlides != null) {
                pptConfig.appendNewChild("mergeSlides").setAttr("value", param.mergeSlides);
            }
            return cmd.executeSync(EXEC_TIMEOUT);
        }
        return Command.CMD_ERROR;
    }

}
