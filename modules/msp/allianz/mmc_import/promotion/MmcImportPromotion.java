package modules.msp.allianz.mmc_import.promotion;

import com.censhare.db.query.model.AssetQBuilder;
import com.censhare.manager.assetmanager.AssetManagementService;
import com.censhare.manager.assetquerymanager.AssetQueryService;
import com.censhare.model.corpus.generated.FeatureBase.FeatureValueType;
import com.censhare.model.corpus.generated.FeatureValueBase;
import com.censhare.model.corpus.impl.Asset;
import com.censhare.model.corpus.impl.AssetFeature;
import com.censhare.model.corpus.impl.DataObjectFeature;
import com.censhare.model.corpus.impl.Feature;
import com.censhare.model.corpus.impl.Feature.Key;
import com.censhare.model.corpus.impl.FeatureContainer;
import com.censhare.model.corpus.impl.FeatureValue;
import com.censhare.server.kernel.Command;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.support.cache.CacheService;
import com.censhare.support.cache.CacheService.CachedTable;
import com.censhare.support.io.FileLocator;
import com.censhare.support.model.DataObject;
import com.censhare.support.model.PersistenceManager;
import com.censhare.support.model.QOp;
import com.censhare.support.model.QSelect;
import com.censhare.support.service.ServerEvent;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.transaction.TransactionException;
import com.censhare.support.util.TypeConversion;
import com.censhare.support.xml.AXml;
import com.censhare.support.xml.CXmlUtil;
import com.censhare.support.xml.XmlIterator;
import com.censhare.support.xml.XsDateTime;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;
import java.util.zip.Deflater;


/**
 * Load file from configured hotfolder, read the xml elements and write text content to found assets
 */
public class MmcImportPromotion {

    /** feature with mapping table for domain keys */
    public static final String MSP_ALZ_MMC_MEDIA_PROVIDER = "msp:alz-mmc.media-provider";

    /** default event for new asset */
    public final String CUSTOM_EVENT = "mmc-import-finished";

    private static final String TARGET_ASSET_TYPE = "promotion.";

    private static final Pattern DELETE_FEATURE_PATTERN = Pattern.compile("msp:alz-mmc\\..+", Pattern.CASE_INSENSITIVE);

    private final Command                          command;
    private final Logger                           logger;
    private final DBTransactionManager             tm;
    private final AssetManagementService           am;
    private final PersistenceManager               pm;
    private final AssetQueryService                aqs;
    private final CacheService                     cacheService;
    private final CachedTable                      featureValueTable;
    private final Map<String, FeatureValueType>    featureValueTypeMap = new HashMap<>();
    private final Map<String, Map<String, String>> featureValueKeysMap = new HashMap<>();
    private       String                           customEventName;

    /**
     * Create instance
     *
     * @param command censhare command
     */
    public MmcImportPromotion(Command command) {
        this.command = command;
        logger = command.getLogger();
        tm = command.getTransactionManager();
        am = ServiceLocator.getStaticService(AssetManagementService.class);
        pm = tm.getDataObjectTransaction()
               .getPersistenceManager();
        aqs = ServiceLocator.getStaticService(AssetQueryService.class);
        cacheService = ServiceLocator.getStaticService(CacheService.class);
        featureValueTable = cacheService.getCachedTable(FeatureValue.ELM_NAME, command.getLocale());
    }

    /**
     * Main action: init hotfolder, get the files, move to completed on success, else to error
     * import each file: parse xml, read content, write to asset
     *
     * @return censhare command result
     *
     * @throws Exception from hotfolder
     */
    public int action() throws Exception {
        logger.info("Start MmcImportPromotion");

        AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);
        AXml configXml = cmdXml.find("config");
        customEventName = configXml.getAttr("repost-asset-source-finished", CUSTOM_EVENT)
                                   .replaceAll("^.+\\.", "");

        Hotfolder hotfolder = new Hotfolder(command);
        List<FileLocator> hotfolderFileLocators = hotfolder.getFileLocators();

        for (final FileLocator fileLocator : hotfolderFileLocators) {
            logger.info("Importing: " + fileLocator);
            try (InputStream is = new BufferedInputStream(fileLocator.getInputStream(FileLocator.STANDARD_FILE, Deflater.NO_COMPRESSION))) {
                createOrUpdateAssets(importData(CXmlUtil.parse(is)));
                hotfolder.completed(fileLocator);
            } catch (Exception e) {
                logger.log(Level.SEVERE, "Import error: " + e.getLocalizedMessage(), e);
                hotfolder.error(fileLocator);
            }
        }

        logger.info("Finished MmcImportPromotion");

        return Command.CMD_COMPLETED;
    }

    /**
     * Import the xml content: collect the data, search asset and write features.
     *
     * @param xml import data xml
     *
     * @return map with {@link MmcImportPromotionField} -> xml text value
     */
    private List<List<MmcImportPromotionFeature>> importData(final AXml xml) {
        XmlIterator<AXml> materialNodes = xml.findAll("material");
        List<List<MmcImportPromotionFeature>> datasets = new ArrayList<>();

        if (materialNodes.hasNext()) {
            materialNodes.forEach(materialNode -> {
                try {
                    materialNode.findAll("Text")
                                .forEach(textNode -> {
                                    List<MmcImportPromotionFeature> list = new ArrayList<>();
                                    textNode.findAll()
                                            .forEach(xmlElement -> {
                                                MmcImportPromotionField field = MmcImportPromotionField.get(xmlElement.getLocalName());
                                                if (field != null) {
                                                    if (field == MmcImportPromotionField.DOCUMENT_ID) {
                                                        MmcImportPromotionFeature fileId = new MmcImportPromotionFeature(MmcImportPromotionField.DOCUMENT_ID,
                                                                                                                         xmlElement.getTextValue()
                                                                                                                                   .replaceAll("\\..+", ""));
                                                        MmcImportPromotionFeature fileName = new MmcImportPromotionFeature(MmcImportPromotionField.DOCUMENT_FILE,
                                                                                                                           xmlElement.getAttr(MmcImportPromotionField.DOCUMENT_FILE.getXmlElementName()));
                                                        MmcImportPromotionFeature relation = new MmcImportPromotionFeature(MmcImportPromotionField.DOCUMENT_RELATION,
                                                                                                                           xmlElement.getAttr(MmcImportPromotionField.DOCUMENT_RELATION.getXmlElementName()));
                                                        fileId.addSubFeature(fileName);
                                                        fileId.addSubFeature(relation);
                                                        list.add(fileId);
                                                    } else {
                                                        list.add(new MmcImportPromotionFeature(field, xmlElement.getTextValue()));
                                                    }
                                                } else {
                                                    logger.warning("MmcImportPromotion node " + xmlElement.getLocalName() + "=" + xmlElement.getTextValue() + " has no feature ");
                                                }
                                            });
                                    datasets.add(list);
                                });
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            });
        } else {
            throw new NoSuchElementException("Element material / Text not found in XML file");
        }
        return datasets;
    }

    /**
     * Create a new asset or update matching asset and add new values
     *
     * @param datasets list with maps with MmcImportPromotionField -> value string
     *
     * @throws Exception on query or transaction manager errors
     */
    private void createOrUpdateAssets(List<List<MmcImportPromotionFeature>> datasets) throws Exception {
        for (List<MmcImportPromotionFeature> list : datasets) {
            MmcImportPromotionFeature materialIdField = getField(list, MmcImportPromotionField.MATERIALID);
            if (materialIdField != null) {
                Asset oldAsset = findAsset(materialIdField.getValue()).iterator()
                                                                      .next();
                Asset checkedOutAsset;
                tm.begin();
                if (oldAsset == null) {
                    MmcImportPromotionFeature materialNameField = getField(list, MmcImportPromotionField.MATERIALNAME);
                    checkedOutAsset = Asset.newInstance(TARGET_ASSET_TYPE, materialNameField.getValue());
                    pm.makePersistentRecursive(checkedOutAsset);
                } else {
                    checkedOutAsset = am.checkOut(tm, oldAsset.getPrimaryKey());
                    pm.attachRecursive(checkedOutAsset);
                    tm.end();
                    tm.begin();
                    checkedOutAsset.getAll(AssetFeature.class)
                                   .forEach((af) -> {
                                       if (DELETE_FEATURE_PATTERN.matcher(af.getFeature())
                                                                 .matches()) {
                                           af.deleteRecursive();
                                       }
                                   });
                }

                String providerKey = getProviderKey(list);
                checkedOutAsset.setDomain("root.allianz.promotion." + providerKey + ".");

                final Asset fcheckedOutAsset = checkedOutAsset;
                list.forEach((value) -> {
                    if (value.getField() == MmcImportPromotionField.MATERIALMEDIASERVICEPROVIDER) {
                        AssetFeature assetFeature = fcheckedOutAsset.struct()
                                                                   .createOrGetAssetFeature(value.getField()
                                                                                                 .getFeatureKey());
                        assetFeature.setValueKey(providerKey);
                        assetFeature.setTimestamp(new Date());
                    } else {
                        setFeature(fcheckedOutAsset, value);
                    }
                });

                if (oldAsset == null) {
                    am.checkInNew(tm, checkedOutAsset);
                } else {
                    checkedOutAsset = am.checkIn(tm, checkedOutAsset);
                }

                tm.end();
                tm.commit();

                sendEvent(checkedOutAsset);
            }
        }
    }

    private MmcImportPromotionFeature getField(List<MmcImportPromotionFeature> list, MmcImportPromotionField field) {
        return list.stream()
                   .filter(element -> element.getField() == field)
                   .findFirst()
                   .orElse(null);
    }

    /**
     * Find assets by {@link MmcImportPromotionField}.MATERIALID = value
     *
     * @param keyValue string for matching the key feature
     *
     * @return iterable assets
     *
     * @throws TransactionException in query
     */
    private Iterable<Asset> findAsset(String keyValue) throws TransactionException {
        AssetQBuilder builder = this.aqs.prepareQBuilder();
        QOp query = builder.and(builder.feature(Key.ASSET_TYPE, TARGET_ASSET_TYPE), builder.feature(MmcImportPromotionField.MATERIALID.getFeatureKey(), keyValue));
        QSelect select = builder.select()
                                .where(query);
        return aqs.queryAssetsLazy(select, tm);
    }

    /**
     * Set feature with import value for asset
     *
     * @param asset         checked out asset
     * @param featureKey    feature key to set
     * @param importFeature value to set
     */
    private void setFeature(DataObject<?> parent, MmcImportPromotionFeature importFeature) {
        if (!Objects.requireNonNullElse(importFeature.getValue(), "").isEmpty()) {
            String featureKey = importFeature.getField().getFeatureKey();
            FeatureValueType featureValueType = getFeatureValueType(featureKey);
            if (featureValueType == null) {
                throw new IllegalStateException("No feature value type found for " + featureKey);
            }

            Object newValue;
            switch (featureValueType) {
                case ENUMERATION:
                    newValue = getFeatureLookupKey(featureKey, importFeature.getValue());
                    break;
                case DATE:
                    newValue = TypeConversion.toXsDateTime(XsDateTime.XsDateTimeType.DATE, importFeature.getValue());
                    break;
                case TIMESTAMP:
                    newValue = TypeConversion.toXsDateTime(XsDateTime.XsDateTimeType.DATE_TIME, importFeature.getValue());
                    break;
                default:
                    newValue = importFeature.getValue();
            }
            if (newValue == null) {
                return;
            }

            boolean isNewFeature = true;
            for (AssetFeature feature : parent.getAll(AssetFeature.class)) {
                Objects.requireNonNull(featureValueType, "Feature value type not found for " + featureKey);
                Object oldValue = feature.getFeatureValue(featureValueType);
                if (oldValue instanceof Object[]) {
                    throw new IllegalStateException("Import doesn't support value pairs");
                }
                if (newValue.equals(oldValue)) {
                    isNewFeature = false;
                    break;
                }
            }

            if (isNewFeature) {
                @SuppressWarnings("unchecked")
                FeatureContainer<AssetFeature> featureContainer = (FeatureContainer<AssetFeature>) parent;
                AssetFeature newFeature = (AssetFeature) featureContainer.createFeature(featureKey);
                newFeature.setFeatureValue(newValue, null, featureValueType);
                newFeature.setTimestamp(new Date());
                importFeature.getSubFeatures()
                             .forEach(subFeature -> this.setFeature(newFeature, subFeature));
            }
        }
    }

    private FeatureValueType getFeatureValueType(String featureKey) {
        if (cacheService == null) {
            return null;
        }
        return featureValueTypeMap.computeIfAbsent(featureKey, key -> {
            Feature feature = cacheService.getEntry(Feature.newPk(featureKey));
            if (feature != null) {
                return feature.getValueType();
            }
            return null;
        });
    }

    private String getFeatureLookupKey(String featureKey, String valueString) {
        if (!featureValueKeysMap.containsKey(featureKey)) {
            HashMap<String, String> featureKeys = new HashMap<>();
            DataObject<?>[] featureValueRows = featureValueTable.getEntries(FeatureValueBase.ATTR_FEATURE, featureKey);
            if (featureValueRows != null) {
                Arrays.stream(featureValueRows)
                      .forEach(featureValueRow -> featureKeys.put(featureValueRow.getDisplayName(),
                                                                  featureValueRow.getDataAttr(FeatureValueBase.ATTR_VALUE_KEY)
                                                                                 .toString()));
            }
            featureValueKeysMap.put(featureKey, featureKeys);
        }
        Map<String, String> featureTable = featureValueKeysMap.get(featureKey);
        if (featureTable.containsKey(valueString)) {
            return featureTable.get(valueString);
        }
        if (featureTable.containsValue(valueString)) {
            return valueString;
        }
        logger.warning("MmcImportPromotion: no key found for " + featureKey + ": " + valueString);
        return null;
    }

    /**
     * Get key for provider name or "draft" if provider empty or not found
     *
     * @param list containing provider name
     *
     * @return provider key string
     */
    private String getProviderKey(List<MmcImportPromotionFeature> list) {
        String providerKey = "draft";
        MmcImportPromotionFeature provider = getField(list, MmcImportPromotionField.MATERIALMEDIASERVICEPROVIDER);
        if (provider != null) {
            if (!Objects.requireNonNullElse(provider.getValue(), "")
                        .isEmpty()) {
                FeatureValue featureValue = (FeatureValue) featureValueTable.getEntry(new String[]{FeatureValue.ATTR_FEATURE, FeatureValue.ATTR_NAME},
                                                                                      new Object[]{MSP_ALZ_MMC_MEDIA_PROVIDER, provider.getValue()});
                if (featureValue != null) {
                    providerKey = featureValue.getValueKey();
                }
            }
        }
        return providerKey;
    }

    /**
     * Send event on task completion
     *
     * @param asset asset for event
     *
     * @throws TransactionException on error
     */
    protected void sendEvent(Asset asset) throws TransactionException {
        if (asset != null) {
            try {
                Asset out = am.cacheGetAssetCurrent(tm, asset.getId());
                logger.info("Sending server event for " + out);
                tm.begin();
                tm.addEvent(new ServerEvent("CustomAssetEvent", customEventName, out.getId(), out.getVersion(), 0));
                tm.end();
                tm.commit();
            } catch (Exception ex) {
                throw new TransactionException("Error while sending event.", ex);
            }
        }
    }
}
