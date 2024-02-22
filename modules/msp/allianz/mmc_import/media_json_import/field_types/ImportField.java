package modules.msp.allianz.mmc_import.media_json_import.field_types;

import com.censhare.model.corpus.impl.AssetFeature;
import com.censhare.support.xml.AXml;
import modules.msp.allianz.mmc_import.media_json_import.model.Category;
import modules.msp.allianz.mmc_import.media_json_import.model.Copyright;
import modules.msp.allianz.mmc_import.media_json_import.model.Media;
import modules.msp.allianz.mmc_import.media_json_import.model.User;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;


/**
 * First level JSON key mapping to censhare feature
 */
public enum ImportField {
    /** JSON "Id" to "msp:alz.media.mmc-id" */
    ID("msp:alz.media.mmc-id", Media::getId),
    /** JSON "Title" to "msp:alz.media.name" */
    TITLE("msp:alz.media.name", Media::getTitle), // also used for asset name
    /** JSON "Keywords" to "censhare:asset.keywords" */
    KEYWORDS("msp:alz.media.keyword") {
        @Override
        public List<AXml> getFeatureStructure(Media media) {
            if (media.getKeywords() == null) {
                return Collections.emptyList();
            }
            return media.getKeywords()
                        .stream()
                        .map(keyword -> keyword.get(LOCALE_STRING))
                        .map(this::buildFeatureXml)
                        .filter(Objects::nonNull)
                        .collect(Collectors.toList());
        }
    },
    /** JSON "Hash" to "msp:alz.media.md5" */
    HASH("msp:alz.media.md5", Media::getHash),
    /** JSON "Name" to "msp:alz.media.filename" */
    NAME("msp:alz.media.filename", Media::getName),
    /** JSON "CopyrightStateId" to "msp:alz.media.licence-status" */
    COPYRIGHTSTATEID("msp:alz.media.licence-status", Media::getCopyrightStateId),
    /** JSON "Copyrights" to "msp:alz.media.copyright" */
    COPYRIGHTS("msp:alz.media.copyright") {
        @Override
        public List<AXml> getFeatureStructure(Media media) {
            if (media.getCopyrights() == null) {
                return Collections.emptyList();
            }
            List<AXml> featureNodes = new ArrayList<>();
            for (Copyright copyright : media.getCopyrights()) {
                if (copyright.getId() == null) {
                    continue;
                }
                AXml mainNode = this.buildFeatureXml(copyright.getId());
                Optional.ofNullable(ImportField.buildFeatureXmlForField(COPYRIGHT_BEGIN, copyright.getBegin()))
                        .ifPresent(mainNode::appendChild);
                Optional.ofNullable(ImportField.buildFeatureXmlForField(COPYRIGHT_END, copyright.getEnd()))
                        .ifPresent(mainNode::appendChild);
                featureNodes.add(mainNode);
                List<Category> copyrightCategories = copyright.getCategories();
                if (copyrightCategories != null) {
                    for (Category category : copyrightCategories) {
                        if (category == null || category.getParent() == null) {
                            continue;
                        }
                        Long parentId = category.getParent()
                                                .getId();
                        ImportField importField = CATEGORY_TO_FIELD_MAP.get(parentId);
                        if (importField == null) {
                            continue;
                        }
                        if (importField == CATEGORY_COMPANY) {
                            mainNode.appendChild(ImportField.buildFeatureXmlForField(importField,
                                                                                     category.getTitle()
                                                                                             .get(LOCALE_STRING)));
                        } else {
                            mainNode.appendChild(ImportField.buildFeatureXmlForField(importField, String.valueOf(category.getId())));
                        }
                    }
                }
            }
            return featureNodes;
        }
    },
    /** JSON "Begin" to "msp:alz.media.copyrights.startdate" */
    COPYRIGHT_BEGIN(false, "msp:alz.media.copyrights.startdate"),
    /** JSON "End" to "msp:alz.media.copyrights.enddate" */
    COPYRIGHT_END(false, "msp:alz.media.copyrights.enddate"),
    /** JSON "Uploader" to "msp:alz.media.usertype" */
    UPLOADER("msp:alz.media.usertype") {
        @Override
        public List<AXml> getFeatureStructure(Media media) {
            return buildUserTypeStructure(UPLOADER, media.getUploader(), "Uploader");
        }
    },
    /** JSON "ResponsibleMember" to "msp:alz.media.usertype" */
    RESPONSIBLE_MEMBER("msp:alz.media.usertype") {
        @Override
        public List<AXml> getFeatureStructure(Media media) {
            return buildUserTypeStructure(RESPONSIBLE_MEMBER, media.getResponsibleMember(), "ResponsibleMember");
        }
    },
    /** JSON "FirstName" to "msp:alz.media.usertype.firstname" */
    USERTYPE_FIRSTNAME(false, "msp:alz.media.usertype.firstname"),
    /** JSON "LastName" to "msp:alz.media.usertype.lastname" */
    USERTYPE_LASTNAME(false, "msp:alz.media.usertype.lastname"),
    /** JSON "CompanyId" to "msp:alz.media.usertype.company_id" */
    USERTYPE_COMPANYID(false, "msp:alz.media.usertype.company_id"),
    /** JSON "CompanyName" to "msp:alz.media.usertype.company_name" */
    USERTYPE_COMPANYNAME(false, "msp:alz.media.usertype.company_name"),
    /** JSON "Categories" is only keyword, no value (but subfeatures) */
    CATEGORIES("Categories") {
        @Override
        public List<AXml> getFeatureStructure(Media media) {
            if (media.getCategories() == null) {
                return Collections.emptyList();
            }
            List<AXml> featureList = new ArrayList<>();
            for (Category category : media.getCategories()) {
                if (category == null || category.getParent() == null) {
                    continue;
                }
                Long parentId = category.getParent()
                                        .getId();
                ImportField importField = CATEGORY_TO_FIELD_MAP.get(parentId);
                if (importField == null) {
                    continue;
                }
                if (importField == CATEGORY_COMPANY) {
                    featureList.add(ImportField.buildFeatureXmlForField(importField,
                                                                        category.getTitle()
                                                                                .get(LOCALE_STRING)));
                } else {
                    featureList.add(ImportField.buildFeatureXmlForField(importField, String.valueOf(category.getId())));
                }
            }
            return featureList;
        }
    },
    /** JSON "1583" to "msp:alz.media.content" */
    CATEGORY_CONTENT(false, "msp:alz.media.content"), // force lookup loading
    /** JSON "1582" to "msp:alz.media.subject" */
    CATEGORY_SUBJECT(false, "msp:alz.media.subject"),
    /** JSON "1585" to "msp:alz.media.company" */
    CATEGORY_COMPANY(false, "msp:alz.media.company"),
    /** JSON "1904" to "msp:alz.media.media-provider" */
    CATEGORY_COPYRIGHT_MEDIA_PROVIDER(false, "msp:alz.media.media-provider"),
    /** JSON "1905" to "msp:alz.media.licence-type" */
    CATEGORY_COPYRIGHT_LICENCE_TYPE(false, "msp:alz.media.licence-type"),
    /** JSON "1907" to "msp:alz.media.rights-original-file" */
    CATEGORY_COPYRIGHT_RIGHTS_ORIGINAL_FILE(false, "msp:alz.media.rights-original-file"),
    /** JSON "1908" to "msp:alz.media.permitted-types-of-use" */
    CATEGORY_COPYRIGHT_USAGES(false, "msp:alz.media.permitted-types-of-use"),
    /** JSON "1909" to "msp:alz.media.restriction" */
    CATEGORY_COPYRIGHT_RESTRICTION(false, "msp:alz.media.restriction"),
    /** JSON "1910" to "msp:alz.media.locked" */
    CATEGORY_COPYRIGHT_LOCKED(false, "msp:alz.media.locked"),
    /** JSON "2448" to "msp:alz.media.personalization-template" */
    CATEGORY_PERSONALIZATION_TEMPLATE(false, "msp:alz.media.personalization-template");

    private static final Map<Long, ImportField> CATEGORY_TO_FIELD_MAP = new HashMap<>() {
        {
            this.put(1583L, CATEGORY_CONTENT);
            this.put(1582L, CATEGORY_SUBJECT);
            this.put(1585L, CATEGORY_COMPANY);
            this.put(1904L, CATEGORY_COPYRIGHT_MEDIA_PROVIDER);
            this.put(1905L, CATEGORY_COPYRIGHT_LICENCE_TYPE);
            this.put(1907L, CATEGORY_COPYRIGHT_RIGHTS_ORIGINAL_FILE);
            this.put(1908L, CATEGORY_COPYRIGHT_USAGES);
            this.put(1909L, CATEGORY_COPYRIGHT_RESTRICTION);
            this.put(1910L, CATEGORY_COPYRIGHT_LOCKED);
            this.put(2448L, CATEGORY_PERSONALIZATION_TEMPLATE);
        }
    };

    private static final String LOCALE_STRING = "de-DE";

    private final String  featureKey;
    private       boolean isImportField = true;

    private final Function<Media, List<AXml>> valueMapper;

    /**
     * Creates a new instance
     *
     * @param isImportField flag for defining if this field is used as a direct import or in part of a structure
     * @param featureKey    the feature key
     */
    ImportField(boolean isImportField, String featureKey) {
        this.isImportField = isImportField;
        this.featureKey = featureKey;
        this.valueMapper = null;
    }

    /**
     * Creates a new instance
     *
     * @param featureKey   the feature key
     * @param stringMapper the stringMapper used to convert {@link Media} to feature-xml
     */
    ImportField(String featureKey, Function<Media, String> stringMapper) {
        this.featureKey = featureKey;
        this.valueMapper = (media) -> {
            AXml featureXml = buildFeatureXml(stringMapper.apply(media));
            if (featureXml == null) {
                return Collections.emptyList();
            }
            return List.of(featureXml);
        };
    }

    /**
     * Creates a new instance, with {@link #isImportField} set to true
     *
     * @param featureKey the feature key
     *
     * @see ImportField#ImportField(boolean, String)
     */
    ImportField(String featureKey) {
        this(true, featureKey);
    }

    public boolean isImportField() {
        return isImportField;
    }

    public String getFeatureKey() {
        return featureKey;
    }

    /**
     * Create an asset_feature xml structure
     *
     * @param media The Media Object to create the structure from
     *
     * @return a {@link List<AXml>} containing asset_feature xml nodes, may contain null elements.
     */
    public List<AXml> getFeatureStructure(Media media) {
        if (valueMapper == null) {
            throw new UnsupportedOperationException("no value mapper provided");
        }
        return valueMapper.apply(media);
    }

    /**
     * Generates a AssetFeature-XML
     *
     * @param value the value to put into the feature xml
     *
     * @return a {@link AssetFeature}-XML or null if value is empty or null
     */
    protected AXml buildFeatureXml(String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        AXml featureXml = AXml.createElement(AssetFeature.ELM_NAME);
        featureXml.setAttr("feature", this.featureKey);
        featureXml.setAttr("value", value);

        return featureXml;
    }

    private static AXml buildFeatureXmlForField(ImportField field, String value) {
        return field.buildFeatureXml(value);
    }

    private static List<AXml> buildUserTypeStructure(ImportField field, User user, String value) {
        if (user == null) {
            return Collections.emptyList();
        }
        AXml mainNode = buildFeatureXmlForField(field, value);
        Optional.ofNullable(buildFeatureXmlForField(USERTYPE_FIRSTNAME, user.getFirstName()))
                .ifPresent(mainNode::appendChild);
        Optional.ofNullable(buildFeatureXmlForField(USERTYPE_LASTNAME, user.getLastName()))
                .ifPresent(mainNode::appendChild);
        if (user.getCompanyId() != null) {
            Optional.ofNullable(buildFeatureXmlForField(USERTYPE_COMPANYID, String.valueOf(user.getCompanyId())))
                    .ifPresent(mainNode::appendChild);
        }
        Optional.ofNullable(buildFeatureXmlForField(USERTYPE_COMPANYNAME, user.getCompanyName()))
                .ifPresent(mainNode::appendChild);
        return List.of(mainNode);
    }
}
