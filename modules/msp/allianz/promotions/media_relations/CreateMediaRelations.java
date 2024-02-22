package modules.msp.allianz.promotions.media_relations;

import com.censhare.db.query.model.AssetQBuilder;
import com.censhare.manager.assetmanager.AssetManagementService;
import com.censhare.manager.assetquerymanager.AssetQueryService;
import com.censhare.model.corpus.impl.Asset;
import com.censhare.model.corpus.impl.AssetFeature;
import com.censhare.model.logical.api.domain.AssetType;
import com.censhare.server.kernel.Command;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.support.model.PersistenceManager;
import com.censhare.support.model.QPart;
import com.censhare.support.model.QSelect;
import com.censhare.support.service.ServiceLocator;

import java.sql.SQLException;
import java.util.List;
import java.util.Objects;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;


/**
 * Create media relations for promotion assets
 */
public class CreateMediaRelations {

    /**
     * Type of promotion assets
     */
    public static final  AssetType ASSET_TYPE_PROMOTION         = AssetType.valueOf("promotion.");
    /**
     * The MMC-ID Asset Feature
     */
    public static final  String    ASSET_FEATURE_MEDIA_MMC_ID   = "msp:alz.media.mmc-id";
    private static final String    ASSET_FEATURE_MEDIA_FILE_ID  = "msp:alz-mmc.promotion.media-file-id";
    private static final String    ASSET_FEATURE_MEDIA_RELATION = "msp:alz-mmc.promotion.media-relation";

    private static final int COMMIT_AFTER = 500;

    private final Command command;
    private final Logger logger;

    private final DBTransactionManager   tm;
    private final PersistenceManager     pm;
    private final AssetManagementService am;
    private final AssetQueryService      aqs;

    /**
     * Creates a new instance
     *
     * @param command the command instance
     */
    public CreateMediaRelations(Command command) {
        this.command = command;
        this.logger = command.getLogger();
        this.tm = command.getTransactionManager();

        this.pm = tm.getDataObjectTransaction()
                    .getPersistenceManager();
        this.am = ServiceLocator.getStaticService(AssetManagementService.class);
        this.aqs = ServiceLocator.getStaticService(AssetQueryService.class);
    }

    /**
     * Query promotion assets and create relations to media assets based on feature values
     *
     * @return always {@link Command#CMD_COMPLETED}
     *
     * @throws Exception if the transaction fails
     */
    @SuppressWarnings("UnusedReturnValue")
    public int action() throws Exception {
        AssetQBuilder aqBuilder = this.aqs.prepareQBuilder();
        QPart qWhere = aqBuilder.and(aqBuilder.feature("censhare:asset.type", ASSET_TYPE_PROMOTION.getDBValue()), aqBuilder.feature(ASSET_FEATURE_MEDIA_FILE_ID, "NOTNULL", ""));
        QSelect qSelect = aqBuilder.select()
                                   .where(qWhere);

        int transactionCounter = 0;
        for (Asset promotionAsset : aqs.queryAssetsLazy(qSelect, tm)) {
            noteAccess();
            List<MediaFileIdEntry> mediaFileIds = StreamSupport.stream(promotionAsset.struct()
                                                                                     .getAssetFeatureIter(ASSET_FEATURE_MEDIA_FILE_ID)
                                                                                     .spliterator(), false)
                                                               .map((mediaFileIdFeature) -> {
                                                                   AssetFeature relationFeature = mediaFileIdFeature.getAssetFeature(ASSET_FEATURE_MEDIA_RELATION);
                                                                   if (relationFeature == null) {
                                                                       this.logger.warning("Invalid Media-File-ID-Feature on Asset: " + mediaFileIdFeature.getAssetId());
                                                                       return null;
                                                                   }
                                                                   return new MediaFileIdEntry(mediaFileIdFeature.getValueString(), relationFeature.getValueKey());
                                                               })
                                                               .filter(Objects::nonNull)
                                                               .filter(MediaFileIdEntry::isValidEntry)
                                                               .collect(Collectors.toList());

            if (!mediaFileIds.isEmpty()) {
                tm.begin();
                try {
                    Asset updateAsset = am.getUpToDateAndLock(tm, promotionAsset.getId(), 0, Asset.VERSION_CURRENT);
                    pm.attachRecursive(updateAsset);
                    for (MediaFileIdEntry entry : mediaFileIds) {
                        noteAccess();
                        QPart qMediaWhere = aqBuilder.feature(ASSET_FEATURE_MEDIA_MMC_ID, entry.getFileId());
                        QSelect qMediaSelect = aqBuilder.select()
                                                        .where(qMediaWhere);
                        for (Asset mediaAsset : aqs.queryAssetsLazy(qMediaSelect, tm)) {
                            updateAsset.struct()
                                       .createOrGetChildAssetRel(mediaAsset, entry.getRelationType());
                            am.touch(tm, mediaAsset.getId());
                        }
                    }
                    am.update(tm, updateAsset);
                } catch (Exception e) {
                    // Rollback and bye
                    tm.rollback(e);
                    throw e;
                }
                tm.end();

                transactionCounter++;
                if (transactionCounter >= COMMIT_AFTER) {
                    tm.commit();
                    pm.reset();
                    transactionCounter = 0;
                }
            }
        }
        if (transactionCounter > 0) {
            tm.commit();
        }

        return Command.CMD_COMPLETED;
    }

    private void noteAccess() throws SQLException {
        tm.noteAccess();
        tm.getConnection()
          .noteAccess();
    }

}
