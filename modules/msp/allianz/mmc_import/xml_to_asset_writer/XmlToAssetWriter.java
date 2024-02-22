package modules.msp.allianz.mmc_import.xml_to_asset_writer;

import com.censhare.manager.assetmanager.AssetManagementService;
import com.censhare.model.corpus.generated.FeatureBase.FeatureValueType;
import com.censhare.model.corpus.impl.Asset;
import com.censhare.model.corpus.impl.AssetCacheKey;
import com.censhare.model.corpus.impl.AssetFeature;
import com.censhare.model.corpus.impl.Feature;
import com.censhare.model.corpus.impl.StorageItem;
import com.censhare.model.corpus.impl.StorageItem.StorageItemKey;
import com.censhare.server.kernel.Command;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.support.cache.CacheService;
import com.censhare.support.io.FileLocator;
import com.censhare.support.model.PersistenceManager;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.xml.AXml;
import com.censhare.support.xml.CXml;
import com.censhare.support.xml.CXmlUtil;
import com.censhare.support.xml.XsDateTime;
import org.xml.sax.SAXException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.time.Instant;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;
import java.util.zip.Deflater;


/**
 * Read xml file and write content to assets
 */
public class XmlToAssetWriter {

    private final Command                command;
    private final Logger                 logger;
    private final AssetManagementService am;
    private final DBTransactionManager   tm;
    private final PersistenceManager     pm;
    private final CacheService           cacheService;
    private final Map<String, Feature> featureValueTypeMap = new HashMap<>();
    private       Date                 featureTimestamp;

    /**
     * Constructor initializes some fields
     *
     * @param command censhare {@link Command}
     */
    public XmlToAssetWriter(Command command) {
        this.command = command;
        this.logger = command.getLogger();
        this.am = ServiceLocator.getStaticService(AssetManagementService.class);
        this.tm = command.getTransactionManager();
        this.pm = tm.getDataObjectTransaction()
                    .getPersistenceManager();
        this.cacheService = ServiceLocator.getStaticServiceNoEx(CacheService.class);
    }

    /**
     * Get asset with json and parse it - add assets for all entries
     *
     * @return always {@link Command#CMD_COMPLETED}
     *
     * @throws Exception various reasons
     */
    public int action() throws Exception {
        logger.info("XmlToAssetWriter: starting");
        this.featureTimestamp = new Date();
        AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);
        AXml assetXml = cmdXml.findAll("assets.asset")
                              .next();
        if (assetXml != null) {
            long assetId = assetXml.getAttrLong("id", -1);
            AXml importXml = getMasterStorageItemXml(assetId);
            int counter = 0;
            for (AXml assetImportXml : importXml.findAll()) {
                logger.info("XmlToAssetWriter: creating asset " + assetImportXml.getAttr("name") + ", type: " + assetImportXml.getAttr("type"));
                createAsset(assetImportXml);
                counter++;
                if ((counter % 1000) == 0) {
                    tm.commit();
                    pm.reset();
                    noteAccess();
                }
            }
        }
        tm.commit();
        pm.reset();
        logger.info("XmlToAssetWriter: finished");
        return Command.CMD_COMPLETED;
    }

    /**
     * read a xml file from asset master storage item
     *
     * @param assetId id of asset to get file from
     *
     * @return xml content
     */
    private CXml getMasterStorageItemXml(long assetId) throws IOException, SAXException {
        Asset xmlAsset = am.cacheGetAssetLazy(tm, new AssetCacheKey(assetId));
        StorageItem masterStorage = xmlAsset.struct()
                                            .getStorageItem(StorageItemKey.MASTER.getDBValue());
        if (masterStorage == null) {
            throw new IllegalStateException("XmlToAssetWriter: no Master-Storage Item for Lookup Asset: " + xmlAsset);
        }
        StringBuilder result = new StringBuilder();
        try (InputStreamReader isr = new InputStreamReader(masterStorage.getFileLocator()
                                                                        .getInputStream(FileLocator.STANDARD_FILE, Deflater.NO_COMPRESSION), Charset.forName("WINDOWS-1252"));
             BufferedReader br = new BufferedReader(isr)) {
            br.lines()
              .filter(s -> !s.isEmpty())
              .forEach(result::append);

        }
        return CXmlUtil.parse(result.toString());
    }

    /**
     * Create new asset from xml
     */
    private void createAsset(AXml xml) throws Exception {
        long assetId = Long.parseLong(xml.getAttr("id", "-1"));
        Asset asset;
        tm.begin();
        if (assetId > 0) {
            logger.info("XmlToAssetWriter: loading asset " + assetId);
            asset = am.checkOut(tm,
                                am.cacheGetAssetNoAttach(tm, assetId)
                                  .getPrimaryKey());
            tm.end();
            tm.begin();

            // clean up features - make sure only current data is in asset.
            String deleteFeatureRegExString = xml.getAttr("deleteFeatureRegEx");
            if (deleteFeatureRegExString != null) {
                asset.getAll(AssetFeature.class)
                     .forEach(assetFeature -> {
                         if (assetFeature.getFeature()
                                         .matches(deleteFeatureRegExString)) {
                             assetFeature.delete();
                         }
                     });
            }
        } else {
            logger.info("XmlToAssetWriter: creating asset " + xml.getAttr("type") + " / " + xml.getAttr("name"));
            asset = Asset.newInstance(xml.getAttr("type"), xml.getAttr("name"));
            String domain = xml.getAttr("domain");
            if (domain != null) {
                asset.setDomain(domain);
            }
            pm.makePersistentRecursive(asset);
        }

        xml.findAll()
           .forEach(featureXml -> {
               String featureKey = featureXml.getAttr("key");
               FeatureValueType featureValueType = getFeatureValueType(featureKey);
               if (featureValueType != null) {
                   AssetFeature feature;
                   if (isMultivalue(featureKey)) {
                       feature = asset.createFeature(featureKey);
                   } else {
                       feature = asset.createOrGetFeature(featureKey);
                   }
                   setFeatureValue(featureXml, featureKey, featureValueType, feature);
               } else {
                   logger.warning("XmlToAssetWriter: unknown feature: " + featureKey);
               }
           });

        if (assetId > 0) {
            am.checkIn(tm, asset);
        } else {
            am.checkInNew(tm, asset);
        }

        tm.end();
    }

    private void addFeatures(AssetFeature parentFeature, AXml xml) {
        xml.findAll()
           .forEach(featureXml -> {
               String featureKey = featureXml.getAttr("key");
               logger.info("XmlToAssetWriter: feature " + featureXml.toStringPretty());
               FeatureValueType featureValueType = getFeatureValueType(featureKey);
               if (featureValueType != null) {
                   AssetFeature feature;
                   if (isMultivalue(featureKey)) {
                       feature = parentFeature.createAssetFeature(featureKey);
                   } else {
                       feature = parentFeature.createOrGetAssetFeature(featureKey);
                   }
                   setFeatureValue(featureXml, featureKey, featureValueType, feature);
               } else {
                   logger.warning("XmlToAssetWriter: unknown feature: " + featureKey);
               }
           });
    }

    private void setFeatureValue(AXml featureXml, String featureKey, FeatureValueType featureValueType, AssetFeature feature) {
        feature.setTimestamp(featureTimestamp);
        switch (featureValueType) {
            case ENUMERATION:
                feature.setValueKey(featureXml.getAttr("value"));
                break;
            case STRING:
                feature.setValueString(featureXml.getAttr("value"));
                break;
            case DATE:
                feature.setValueTimestamp(XsDateTime.from(Instant.parse(featureXml.getAttr("value"))));
                break;
            default:
                logger.warning("XmlToAssetWriter: not implemented: " + featureValueType + " for " + featureKey);
        }
        if (featureXml.countChildElements() > 0) {
            logger.warning("XmlToAssetWriter: not implemented: child elements");
            addFeatures(feature, featureXml);
        }
    }

    /**
     * Get {@link FeatureValueType} of feature key
     *
     * @param featureKey the feature key
     *
     * @return the feature value type
     */
    private FeatureValueType getFeatureValueType(String featureKey) {
        if (cacheService == null) {
            return null;
        }
        if (!featureValueTypeMap.containsKey(featureKey)) {
            Feature feature = cacheService.getEntry(Feature.newPk(featureKey));
            if (feature != null) {
                featureValueTypeMap.put(featureKey, feature);
            }
        }

        if (featureValueTypeMap.get(featureKey) != null) {
            return featureValueTypeMap.get(featureKey)
                                      .getValueType();
        }
        return null;
    }

    private boolean isMultivalue(String featureKey) {
        if (featureValueTypeMap.get(featureKey) != null) {
            return featureValueTypeMap.get(featureKey)
                                      .isMultivalue(false);
        }
        return false;
    }

    private void noteAccess() {
        this.command.noteAccess();
        try {
            this.tm.getConnection()
                   .noteAccess();
        } catch (SQLException e) {
            this.logger.severe("error in noteAccess: " + e.getLocalizedMessage());
        }
    }
}
