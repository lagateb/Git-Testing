package modules.msp.allianz.mmc_import.media_json_import;

import com.censhare.db.query.model.AssetQBuilder;
import com.censhare.manager.assetmanager.AssetManagementService;
import com.censhare.manager.assetquerymanager.AssetQueryService;
import com.censhare.model.corpus.generated.FeatureBase;
import com.censhare.model.corpus.impl.Asset;
import com.censhare.model.corpus.impl.AssetFeature;
import com.censhare.model.corpus.impl.Feature;
import com.censhare.model.corpus.impl.StorageItem;
import com.censhare.model.corpus.impl.StorageItem.StorageItemKey;
import com.censhare.server.kernel.Command;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.support.cache.CacheService;
import com.censhare.support.io.FileLocator;
import com.censhare.support.model.DataObject;
import com.censhare.support.model.PersistenceManager;
import com.censhare.support.model.QOp;
import com.censhare.support.model.QSelect;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.transaction.TransactionException;
import com.censhare.support.xml.AXml;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import modules.msp.allianz.mmc_import.media_json_import.field_types.ImportField;
import modules.msp.allianz.mmc_import.media_json_import.model.Media;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.List;
import java.util.logging.Logger;
import java.util.regex.Pattern;
import java.util.zip.Deflater;


/**
 * Import MMC media metadata from JSON file to create assets
 * Final asset type will depend on uploaded file (other process)
 */
public class MmcImportMediaJson {

    private static final Pattern DELETE_FEATURE_PATTERN = Pattern.compile("^msp:alz\\.media\\..+", Pattern.CASE_INSENSITIVE);
    private static final String  DOMAIN_MEDIA_FINAL     = "root.allianz.media.final.";

    private static final Gson gson = new GsonBuilder().create();

    private static final int COMMIT_THRESHOLD = 500;

    private final Command                command;
    private final Logger                 logger;
    private final AssetManagementService am;
    private final DBTransactionManager   tm;
    private final PersistenceManager     pm;
    private final AssetQueryService      aqs;
    private final CacheService           cacheService;

    /**
     * Constructor.
     *
     * @param command the command context
     */
    public MmcImportMediaJson(Command command) {
        this.command = command;
        this.logger = command.getLogger();
        this.am = ServiceLocator.getStaticService(AssetManagementService.class);
        this.tm = command.getTransactionManager();
        this.pm = tm.getDataObjectTransaction()
                    .getPersistenceManager();
        this.aqs = ServiceLocator.getStaticService(AssetQueryService.class);
        this.cacheService = ServiceLocator.getStaticService(CacheService.class);
    }

    /**
     * Get asset with json and parse it - add assets for all entries
     *
     * @return {@link Command#CMD_COMPLETED} on success, {@link Command#CMD_ERROR} if asset has no master storage item
     *
     * @throws Exception various reasons
     */
    public int action() throws Exception {
        AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);
        AXml assetXml = cmdXml.find("assets.asset");
        if (assetXml != null) {
            final Asset asset = am.cacheGetAssetNoAttach(tm, assetXml.getAttrLong("id"));
            StorageItem jsonMasterStorage = asset.struct()
                                                 .getStorageItem(StorageItemKey.MASTER.getDBValue());
            if (jsonMasterStorage == null) {
                logger.severe("MmcImportMediaJson: no master storage found in " + asset);
                return Command.CMD_ERROR;
            }
            FileLocator jsonFileLocator = jsonMasterStorage.getFileLocator();
            int transactionCounter = 0;
            try (InputStream in = jsonFileLocator.getInputStream(FileLocator.STANDARD_FILE, Deflater.NO_COMPRESSION);
                 Reader reader = new BufferedReader(new InputStreamReader(in))) {

                Media[] importMedias = gson.fromJson(reader, Media[].class);
                for (Media media : importMedias) {
                    command.noteAccess();
                    createOrUpdateMediaAsset(media);
                    transactionCounter++;
                    if (transactionCounter >= COMMIT_THRESHOLD) {
                        tm.commit();
                        pm.reset();
                        transactionCounter = 0;
                    }
                }
            }
            if (transactionCounter > 0) {
                tm.commit();
            }
        }

        logger.info("MmcImportMediaJson: finished");
        return Command.CMD_COMPLETED;
    }

    private void createOrUpdateMediaAsset(Media media) throws Exception {
        Asset mediaAsset = queryAsset(ImportField.ID.getFeatureKey(), media.getId());
        boolean isNew = false;
        if (mediaAsset == null) {
            mediaAsset = Asset.newInstance(Asset.AssetType.OTHER.getDBValue(), media.getName());
            pm.makePersistentRecursive(mediaAsset);
            mediaAsset.setDomain(DOMAIN_MEDIA_FINAL);
            isNew = true;
        } else {
            tm.begin();
            mediaAsset = am.checkOut(tm, mediaAsset.getPrimaryKey());
            tm.end();
            tm.begin();
            // Update name
            mediaAsset.setName(media.getName());
            // Cleanup current Asset
            mediaAsset.getAll(AssetFeature.class)
                      .forEach((af) -> {
                          if (DELETE_FEATURE_PATTERN.matcher(af.getFeature())
                                                    .matches()) {
                              af.deleteRecursive();
                          }
                      });
        }

        for (ImportField importField : ImportField.values()) {
            if (!importField.isImportField()) {
                continue;
            }
            List<AXml> featureNodes = importField.getFeatureStructure(media);
            for (AXml featureNode : featureNodes) {
                if (featureNode == null) {
                    continue;
                }
                // Move temp value attribute to feature type specific value attribute
                fixFeatureStructure(featureNode);
                // Map to DataObject
                DataObject<?> dto = pm.mapRecursive(featureNode);
                // Append Object to Asset
                mediaAsset.appendChild(dto);
                // Make DataObject Persistent
                pm.makePersistentRecursive(dto);
            }
        }

        if (isNew) {
            tm.begin();
            am.checkInNew(tm, mediaAsset);
            tm.end();
        } else {
            am.checkIn(tm, mediaAsset);
            tm.end();
        }
    }

    private void fixFeatureStructure(AXml featureNode) {
        if (featureNode.getNodeName()
                       .equals(AssetFeature.ELM_NAME)) {
            String tempValue = featureNode.getAttr("value");
            String targetFeature = featureNode.getAttr("feature");
            FeatureBase.FeatureValueType valueType = this.cacheService.getEntry(Feature.newPk(targetFeature))
                                                                      .getValueType();
            AssetFeature.setFeatureValue(tempValue, null, featureNode, valueType);
            featureNode.setAttr("value", null);
            for (AXml childNode : featureNode.findAll()) {
                fixFeatureStructure(childNode);
            }
        }
    }

    private Asset queryAsset(String featureKey, String featureValue) throws TransactionException {
        AssetQBuilder builder = aqs.prepareQBuilder();
        QOp whereClause = builder.and(builder.feature(featureKey, featureValue));
        QSelect query = builder.select()
                               .where(whereClause);
        return aqs.queryAssets(query, tm)
                  .iterator()
                  .next();
    }

}
