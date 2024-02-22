package modules.msp.allianz.mmc_import.promotion;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;


/**
 * Configuration for Allianz MMC Import Promotion
 */
public enum MmcImportPromotionField {
    /**
     * XML element MaterialID maps to feature msp:alz-mmc.promotion-id
     */
    MATERIALID("msp:alz-mmc.promotion-id", "MaterialID"),
    /**
     * XML element MaterialName maps to feature msp:alz-mmc.promotion-name
     */
    MATERIALNAME("msp:alz-mmc.promotion-name", "MaterialName"),
    /**
     * XML element MaterialNumber maps to feature msp:alz-mmc.promotion-number
     */
    MATERIALNUMBER("msp:alz-mmc.promotion-number", "MaterialNumber"),
    /**
     * XML element ArticleNumber maps to feature msp:alz-mmc.promotion-article-number
     */
    ARTICLENUMBER("msp:alz-mmc.promotion-article-number", "ArticleNumber"),
    /**
     * XML element MaterialCreationDate maps to feature msp:alz-mmc.promotion-article-number
     */
    MATERIALCREATIONDATE("msp:alz-mmc.promotion-creation-date", "MaterialCreationDate"),
    /**
     * XML element MaterialVersionNumber maps to feature msp:alz-mmc.promotion-version-number
     */
    MATERIALVERSIONNUMBER("msp:alz-mmc.promotion-version-number", "MaterialVersionNumber"),
    /**
     * XML element MaterialDeeplink maps to feature msp:alz-mmc.promotion-deeplink-mmc
     */
    MATERIALDEEPLINK("msp:alz-mmc.promotion-deeplink-mmc", "MaterialDeeplink"),
    /**
     * XML element MaterialCategory_DescriptionPartner maps to feature msp:alz-mmc.description-partner
     */
    MATERIALCATEGORY_DESCRIPTIONPARTNER("msp:alz-mmc.description-partner", "MaterialCategory_DescriptionPartner"),
    /**
     * XML element MaterialCreator maps to feature msp:alz-mmc.creator
     */
    MATERIALCREATOR("msp:alz-mmc.creator", "MaterialCreator"),
    /**
     * XML element MaterialMediendienstleister maps to feature msp:alz-mmc.media-provider
     */
    MATERIALMEDIASERVICEPROVIDER("msp:alz-mmc.media-provider", "MaterialMediaServiceProvider"),
    /**
     * XML element MaterialStatus maps to feature msp:alz-mmc.promotion-status
     */
    MATERIALSTATUS("msp:alz-mmc.promotion-status", "MaterialStatus"),
    /**
     * XML element Documents maps to feature msp:alz-mmc.promotion.media-file-id
     */
    DOCUMENT_ID("msp:alz-mmc.promotion.media-file-id", "Documents"),
    /**
     * XML element Documents/@filename maps to feature msp:alz-mmc.promotion.media-file
     */
    DOCUMENT_FILE("msp:alz-mmc.promotion.media-file", "filename"),
    /**
     * XML element Documents/@folder maps to feature msp:alz-mmc.promotion.media-relation
     */
    DOCUMENT_RELATION("msp:alz-mmc.promotion.media-relation", "folder");

    private final String featureKey;
    private final String xmlElementName;

    private static final List<MmcImportPromotionField>        values      = List.of(values());
    private static final Map<String, MmcImportPromotionField> ELEMENT_MAP = values.stream()
                                                                                  .collect(Collectors.toUnmodifiableMap(k -> k.xmlElementName, Function.identity()));

    /**
     * Create an instance
     *
     * @param featureKey     feature key for storing in asset
     * @param xmlElementName element name found in xml file
     */
    MmcImportPromotionField(String featureKey, String xmlElementName) {
        this.featureKey = featureKey;
        this.xmlElementName = xmlElementName;
    }

    public String getFeatureKey() {
        return featureKey;
    }

    public String getXmlElementName() {
        return xmlElementName;
    }

    /**
     * Get an instance by xml element name
     *
     * @param xmlElementName element name
     *
     * @return enum instance
     */
    public static MmcImportPromotionField get(String xmlElementName) {
        return ELEMENT_MAP.get(xmlElementName);
    }
}
