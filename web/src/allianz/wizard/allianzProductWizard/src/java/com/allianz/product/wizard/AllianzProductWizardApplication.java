package com.allianz.product.wizard;

import com.censhare.api.applications.SelfDescribingApplication;
import com.censhare.api.applications.wizards.AbstractWizardsApplication;
import com.censhare.api.applications.wizards.model.WizardModel;
import com.censhare.api.applications.wizards.model.WizardModel.WizardStep;
import com.censhare.model.corpus.impl.FeatureValue;
import com.censhare.model.corpus.impl.Workflow;
import com.censhare.model.corpus.impl.WorkflowStep;
import com.censhare.model.logical.api.base.Property;
import com.censhare.model.logical.api.base.Property.PropertyKey;
import com.censhare.model.logical.api.base.Trait;
import com.censhare.model.logical.api.domain.*;
import com.censhare.model.logical.api.domain.AssetRelation.RelationType;
import com.censhare.model.logical.api.properties.StringProperty;
import com.censhare.model.logical.api.properties.LongProperty;
import com.censhare.model.logical.api.properties.TimestampProperty;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.server.support.api.CommandContext;
import com.censhare.server.support.api.impl.CommandAnnotations.Execute;
import com.censhare.server.support.api.impl.CommandAnnotations.CommandHandler;
import com.censhare.server.support.api.impl.CommandAnnotations.ScopeType;
import com.censhare.server.support.api.transaction.AtomicRef;
import com.censhare.server.support.api.transaction.QueryService;
import com.censhare.server.support.api.transaction.UpdatingRepository;
import com.censhare.server.support.transformation.AssetTransformation;
import com.censhare.support.cache.CacheService.CachedTable;
import com.censhare.support.cache.CacheService;
import com.censhare.support.context.Platform;
import com.censhare.support.io.FileFactoryService;
import com.censhare.support.io.FileLocator;
import com.censhare.support.io.FileLocatorUtilities;
import com.censhare.support.json.ClassAnalyzer.Key;
import com.censhare.support.json.Serializers;
import com.censhare.support.model.QSelect;
import com.censhare.support.model.DataObject;
import com.censhare.support.service.ServerEvent;
import com.censhare.support.service.ServiceContext;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.transaction.Atomic;
import com.censhare.support.util.DataWrapper;
import com.censhare.support.util.TypeConversion;
import com.censhare.support.xml.AXml;
import com.censhare.support.xml.CXmlUtil;
import modules.lib.LayoutServiceHelper;

import java.util.*;
import java.util.stream.Collectors;

//import com.censhare.api.assetmanagement.CloneAndCleanAssetXml

@CommandHandler(command = "com.allianz.product.wizard", scope = ScopeType.CONVERSATION)
public class AllianzProductWizardApplication extends AbstractWizardsApplication {

    protected Asset pptxAsset = null;
    protected Asset productAsset = null;
    protected int pptxRelationCount = 0;
    protected Asset targetGroupAsset = null;
    protected String newAssetDomain = null;

    protected String productArea = null;
    protected String productBranch = null;
    protected String productCategoryAzde = null;

    private FileFactoryService ffs = ServiceLocator.getStaticService(FileFactoryService.class);

    public static final String CLONE_LAYOUT_AND_PLACE_ASSETS_TRAFO = "svtx:automation.clone.flyer.and.place.article";
    public static final PropertyKey<Trait.GenericTrait, StringProperty> TEXT_SIZE_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianzText"), "size");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> CONTENT_EDITOR_CONFIG_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "content"), "configuration");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> OPTIONAL_COMPONENT = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianzBaustein"), "optionalComponent");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> MEDIA_CHANNEL = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianz"), "mediaChannel");
    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> TARGET_GROUP_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "category"), "targetGroup");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> FEATURE_LAYOUT_TEMPLATE_RESOURCE_KEY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianz"), "layoutTemplateResourceKey");
    public static final PropertyKey<Trait.GenericTrait, TimestampProperty> FEATURE_LAYOUT_TEMPLATE_CREATION_DATE = TimestampProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianz"), "layoutTemplateCreationDate");
    public static final PropertyKey<Trait.GenericTrait, LongProperty> FEATURE_LAYOUT_TEMPLATE_VERSION = LongProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianz"), "layoutTemplateVersion");

    public static final PropertyKey<Trait.GenericTrait, StringProperty> FEATURE_PRODUCT_AREA = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "svtx"), "productArea");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> FEATURE_PRODUCT_BRANCH = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "svtx"), "productBranch");


    public static final PropertyKey<Trait.GenericTrait, StringProperty> FEATURE_AEM_TEMPLATE = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "savotex"), "aemTemplate");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> FEATURE_ALIAS_NAME = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "svtx"), "aliasName");


    public static final PropertyKey<Trait.GenericTrait, StringProperty> COPY_OF_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianz"), "copyOf");
    public static final PropertyKey<Trait.GenericTrait, StringProperty> BS_TEMPLATE_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "savotex"), "bsTemplate");

    public static final PropertyKey<Trait.GenericTrait, StringProperty> PRODUCT_CATEGORY_AZ_DE = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "aemAzCategory"), "aemAzCategory");

    public static final RelationType TEXT_REL_TYPE_PARENT = RelationType.valueOf("user.main-content.", AssetRelation.Direction.PARENT);
    public static final RelationType TEXT_REL_TYPE_CHILD = RelationType.valueOf("user.main-content.", AssetRelation.Direction.CHILD);


    public static final String FLYER = "svtx:channel.flyer";
    public static final String FLYER_BUB = "svtx:channel.flyer.bub";
    public static final String TWO_PAGER = "svtx:channel.twopager";
    public static final String VERTRIEBSPORTAL = "svtx:channel.vertriebsportal";
    public static final String ALLIANZ_DE = "svtx:channel.allianzde";
    public static final String POWERPOINT = "svtx:channel.powerpoint";
    public static final String POWERPOINTVSK = "svtx:channel.powerpoint-vsk";

    public static final String POWERPOINTBUB = "svtx:channel.powerpoint-bub";

    public static final  AssetType ASSET_TYPE_POWERPOINT_ISSUE = AssetType.valueOf("presentation.issue.");
    //public static final RelationType RELATION_TYPE_PRESENTATION_ISSUE = RelationType.valueOf("user.presentation-issue.", AssetRelation.Direction.CHILD);
    public static final AssetType ASSET_TYPE_POWERPOINT_REGENERATION = AssetType.valueOf("module.pptx-rebuild.");
    public static final AssetType ASSET_TYPE_EXTENDED_MEDIA = AssetType.valueOf("extended-media.html.");

    public static final String TRANSFORMATION_REGENERATE_PPTX_ISSUE =  "svtx:regenerate.pptx.issue";

    public final List<Channel> channels = new ArrayList<>();


    public enum AllianzProductWizardSteps {
        allianzProductWizardStep1,
        allianzProductWizardStep2,
        allianzProductWizardStep3,
        allianzProductWizardStep4,
        allianzProductWizardRecurringModules,
        allianzProductWizardStep5;

        public boolean isStep(WizardStep step) {
            return step != null && step.name.equals(this.name());
        }
    }

    public static class Product {
        @Key
        public String name;
        @Key
        public String type;
        @Key
        public String domain;

        public AssetType getType () {
            String type = this.type != null ? this.type : "product.";
            return AssetType.valueOf(type);
        }

        public String getName() {
            return this.name != null ? this.name : "undefined name";
        }

        public String getDomain() {
            return this.domain != null ? this.domain : "root.";
        }
    }

    @Key("channel")
    public static class Channel {
        @Key
        public long id;
        @Key
        public String name;
        @Key
        public String type;
        @Key
        public String template;
        @Key
        public List<Article> article;
        @Key
        public String resourceKey;

        public Channel(long id, String name, String type) {
            this.id = id;
            this.name = name;
            this.type = type;
        }

        public void addArticle(Article article) {
            if (this.article == null) {
                this.article = new ArrayList<>();
            }
            this.article.add(article);
        }

        public AXml asXml() {
            return Serializers.fromPojo(this).toXML();
        }
    }

    @Key("text")
    public static class Text {
        @Key
        public long id;
        @Key
        public String size;
        @Key
        public String type;
        @Key
        public String label;
        @Key
        public boolean isRecurring;
        @Key
        public String defaultName;

        public Text(long id, String type, String size, String label) {
            this.id = id;
            this.type = type;
            this.size = size;
            this.label = label;
        }

        public Text(long id, String type, String size, String label, boolean isRecurring, String defaultName) {
            this.id = id;
            this.type = type;
            this.size = size;
            this.label = label;
            this.isRecurring = isRecurring;
            this.defaultName = defaultName;
        }

        @Override
        public boolean equals(Object o) {
            if (o == this) {
                return true;
            }
            if (!(o instanceof Text)) {
                return false;
            }
            Text t = (Text) o;
            return id == t.id;
        }
    }

    public static class OptionalComponent {
        @Key
        public String name;
        @Key
        public String template;
        @Key
        public long articleId;

        public OptionalComponent(String name, String template, long articleId) {
            this.name = name;
            this.template = template;
            this.articleId = articleId;
        }
    }

    @Key("article")
    public static class Article {
        @Key
        public long id;
        @Key
        public String name;
        @Key
        public List<Text> text;
        @Key
        public String type;
        @Key
        public long pptxId;
        @Key
        public boolean optionalComponent;
        @Key
        public List<OptionalComponent> optionalComponents;
        @Key
        public boolean isRecurring;

        public Article(long id, String name, String type) {
            this.id = id;
            this.name = name;
            this.type = type;
        }

        public void addText(Text text) {
            if (this.text == null) {
                this.text = new ArrayList<>();
            }
            this.text.add(text);
        }

        public void addComponent(OptionalComponent opc) {
            if (this.optionalComponents == null) {
                this.optionalComponents = new ArrayList<>();
            }
            this.optionalComponents.add(opc);
        }

        @Override
        public boolean equals(Object o) {
            if (o == this) {
                return true;
            }
            if (!(o instanceof Article)) {
                return false;
            }
            Article a = (Article) o;
            return id == a.id;
        }
    }


    public static class PPTXData{
        public long pptxAssetId;
        public Asset articleCopy;
        public Text textSize;
    }

    private static class PPTXKeys {
        public final static String TEXT_VARIANT_TYPE  = "svtx:text-variant-type";
        public final static String TEXT_VARIANT_TYPE_STANDARD = "standard";
        public final static String TEXT_VARIANT_TYPE_SALES = "sales";
        public final static String TEXT_VARIANT_TYPE_AGENT = "agent";
    }

    @Override
    protected void addMethods(Set<String> methods) {
        methods.add("rendererIsAvailable");
    }

    @Override
    protected void initWizardData(WizardModel wizard) {
        // ORTCONTENT-303 - Bitte den Step Ergänzungsmodule entfernen/verstecken
        logger.info("####### INIT WIZARD " + wizard);
        WizardStep step4 = wizard.findStep(AllianzProductWizardSteps.allianzProductWizardStep4.name());
        if (step4 != null) {
            wizard.removeStep(step4);
        }
    }

    @Override
    protected boolean beforeStepAction(WizardStepAction action, WizardStep step){
        logger.info("####### ENTER STEP " + step);
        // step 4 is hidden for now, so use step 5 to generate data
        if (AllianzProductWizardSteps.allianzProductWizardRecurringModules.isStep(step) || AllianzProductWizardSteps.allianzProductWizardStep5.isStep(step)) {
            AXml step3Data = getStepData(AllianzProductWizardSteps.allianzProductWizardStep3);
            List<Asset> selectedAssets = getSelectedAssets(step3Data);
            AXml stepRecurringModulesData = getStepData(AllianzProductWizardSteps.allianzProductWizardRecurringModules);
            AXml recurringModules = stepRecurringModulesData.find("recurringModules");
            cleanStepData(step);
            this.channels.clear();

            for (Asset asset : selectedAssets) {
                Channel channel = new Channel(asset.getId(), asset.getName(), asset.getType().getDBValue());
                String templateKey = getRelatedTemplateResourceKey(asset);
                if (templateKey != null && !templateKey.isEmpty()) {
                    channel.template = templateKey;
                }
                String resourceKey = asset.traitResourceAsset().getResourceKey();
                if (resourceKey != null && !resourceKey.isEmpty()) {
                    channel.resourceKey = resourceKey;
                }

                //only asset relations which contains the text size property
                getRelationsWithTextSizeProperty(asset).forEach(assetRelation -> {
                    String textSize = assetRelation.properties().getProperty(TEXT_SIZE_PROPERTY).getValue();
                    String textType = getAssetTypeOfTextSize(textSize);
                    try {

                        Asset articleAsset = assetRelation.getChildAssetRef().get();
                        Article article = new Article(articleAsset.getId(), articleAsset.getName(), articleAsset.getType().getDBValue());


                        /*Asset textAsset = getRelatedTextAsset(articleAsset, textType);*/
                        Asset textAsset = null;
                        boolean isRecurringTxt = false;
                        AXml rm = recurringModules != null ? recurringModules.findX(String.format("options[@type=%s%s%s]", "'",articleAsset.getType().getDBValue(), "'" )) : null;
                        if (rm != null) {
                            long id = rm.getAttrLong("value");
                            AssetRef rmArticleRef = AssetRef.createUnversioned(id);
                            textAsset = getRelatedTextAsset(rmArticleRef.get(), textType);
                            /* fallback */
                            if (textAsset == null) {
                                textAsset = getRelatedTextAsset(articleAsset, textType);
                            } else {
                                isRecurringTxt = true;
                                article.isRecurring = true;
                            }

                        } else {
                            textAsset = getRelatedTextAsset(articleAsset, textType);
                        }

                        if (textAsset != null) {
                            String textLabel = getFeatureLabelOfTextSize(textSize);
                            Asset defaultText = getRelatedTextAsset(articleAsset, textType);
                            String defaultTextName = defaultText != null? defaultText.getName() : "";
                            article.addText(new Text(textAsset.getId(), textAsset.getType().getDBValue(), textSize, textLabel, isRecurringTxt, defaultTextName));
                        }
                        Asset pptSlideAsset = getRelatedPptSlide(articleAsset);
                        if (pptSlideAsset != null) {
                            article.pptxId = pptSlideAsset.getId();
                        }

                        StringProperty optionalComponent = articleAsset.properties().getProperty(OPTIONAL_COMPONENT);

                        if (optionalComponent.exist() && optionalComponent.getValue().equals("true")) {
                            article.optionalComponent = true;
                        }
                        channel.addArticle(article);
                    } catch (Exception e) {
                        logger.info("Failed to get Asset from AssetRef " + assetRelation.getChildAssetRef());
                    }
                });
                step.data.appendChild(channel.asXml());
                this.channels.add(channel);
            }
        } else if (AllianzProductWizardSteps.allianzProductWizardStep5.isStep(step)) {
            // map optional components to article to create
            AXml step4Data = getStepData(AllianzProductWizardSteps.allianzProductWizardStep4);

            if (step4Data != null) {
                step4Data.findAll("optionalArticle").forEach(article -> {
                    String template = article.getAttr("template", "");
                    String name = article.getAttr("name", "");
                    long articleId = article.getAttrLong("articleId", -1);
                    if (!name.isEmpty() && !template.isEmpty() && articleId != -1) {
                        OptionalComponent optionalComponent = new OptionalComponent(name, template, articleId);
                        for (Article a : getAllArticle()) {
                            if (articleId == a.id) {
                                a.addComponent(optionalComponent);
                            }
                        }
                    }
                });
            }
            cleanStepData(step);
            this.channels.forEach(channel -> {
                step.data.appendChild(channel.asXml());
            });
        }
        return true;
    }

    @Override
    protected boolean afterStepAction(WizardStepAction action, WizardStep step) throws Exception {
        logger.info("####### LEAVE STEP " + step);
        return true;
    }

    @Override
    protected boolean onCancel() {
        logger.info("####### CANCEL");
        return true;
    }

    /**
     * Liefert, wenn vorhanden, das PPTX ChannelAsset
     * @return
     * @throws Exception
     */
    private Asset getUsedPPTXChannel() throws Exception {
        for (Channel channel : this.channels) {
            Asset channelAsset = AssetRef.createUnversioned(channel.id).get();
            if (channelAsset != null) {
                String resourceKey = channelAsset.traitResourceAsset().getResourceKey();
                if(resourceKey.equals(POWERPOINT) || resourceKey.equals(POWERPOINTVSK) ||resourceKey.equals(POWERPOINTBUB)  ) {
                    return channelAsset;
                }
            }
        }
        return null;
    }

    // kontrolliert, ob der Text,z.B. text-m der richtige für den Channel ist
    // Der Wert steht als Merkmal in der Channel->(Planning)->Article Relation
    //TODO is text.size der richtige
    private boolean isPPTXText(Text text,Asset article,Asset pptxChannel) throws Exception {



        AssetRelation r =  pptxChannel.asRelations(RelationType.PLANNING).getRelations().
                first(assetRelation -> {

                            try {
                                return
                                        assetRelation.properties().getProperty(TEXT_SIZE_PROPERTY).exist() &&
                                                assetRelation.getChildAssetRef().get().getId()==article.getId() &&
                                                assetRelation.properties().getProperty(TEXT_SIZE_PROPERTY).getValue().equals(text.size);
                            } catch (Exception e) {
                                return false;
                            }
                        }

                ) ;
        return r != null;
    }

    @Override
    protected Object onFinish() throws Exception {
        AXml step2Data = getStepData(AllianzProductWizardSteps.allianzProductWizardStep2);
        AXml productData = step2Data.find("product");
        List<PPTXData> pptxDatas = new ArrayList<>();
        List <Asset>   pptxRebuildAssets = new ArrayList<>();
        Asset pptxChannel = getUsedPPTXChannel();


        if (productData != null) {
            this.newAssetDomain = step2Data.getAttr("domain");
            this.productBranch = step2Data.getAttr("productBranch", null);
            this.productArea = step2Data.getAttr("productArea", null);
            this.productCategoryAzde = step2Data.getAttr("productCategoryAzde", null);

            Product product  = Serializers.fromXML(productData).toPojo(Product.class);
            productAsset = createAssetAndCheckInNew(product.getName(), product.getType());
            long assignedUser = step2Data.getAttrLong("assignedUser", 0);
            if (assignedUser != 0) {
                try {
                    Asset userAsset = AssetRef.createUnversioned(assignedUser).get();
                    if (userAsset != null) {
                        createRelation(productAsset, userAsset, RelationType.valueOf("user.responsible.",  AssetRelation.Direction.CHILD));
                    }
                } catch (Exception e) {
                    logger.info("Failed to get Asset from Assigned User" + e.toString());
                }
            }

            List<Article> distinctArticle = new ArrayList<>();
            for (Article article : getAllArticle()) {
                if (!distinctArticle.contains(article)) {
                    distinctArticle.add(article);
                } else {
                    Article presentArticle = distinctArticle.get(distinctArticle.indexOf(article));
                    article.text.forEach(text -> {
                        if (!presentArticle.text.contains(text)) {
                            presentArticle.text.add(text);
                        }
                    });
                }
            }
            startProgress("allianzProductWizard.articleWillBeCreated");
            distinctArticle.forEach(article -> {
                AssetRef assetRef = AssetRef.createUnversioned(article.id);
                try {
                    Asset articleAsset = assetRef.get();
                    String articleName = String.format("%s - %s", productAsset.getName(), articleAsset.getName());
                    Asset articleCopy = copyAsset(articleAsset, articleName, false, false, productAsset, RelationType.ASSIGNED_IN, article.isRecurring);
                    article.text.forEach(text -> {
                        AssetRef textAssetRef = AssetRef.createUnversioned(text.id);
                        try {
                            Asset textAsset = textAssetRef.get();
                            String textName = String.format("%s - %s", productAsset.getName(), textAsset.getName());
                            if (text.isRecurring) {
                                textName = text.defaultName;
                            }
                            copyAsset(textAsset, textName, true, false, articleCopy, TEXT_REL_TYPE_PARENT, text.isRecurring);
                            if (article.pptxId > 0 && isPPTXText(text,articleAsset,pptxChannel)) {
                                ////Asset pptx = AssetRef.createUnversioned(article.pptxId).get();
                                // Das ist die Relation zur Vorlage(template)  IMHO wird diese nicht mehr benötigt, da wir ja jetzt eine
                                // Kopie machen
                                //createRelation(articleCopy, pptx, RelationType.PLANNED_IN);
                                ////createPPTXSlide(pptx,articleCopy);

                                PPTXData pptxData = new PPTXData();
                                pptxData.pptxAssetId = article.pptxId;
                                pptxData.articleCopy = articleCopy;
                                pptxData.textSize = text;

                                pptxDatas.add(pptxData);
                            }
                        } catch (Exception e) {
                            logger.info("Failed to get Asset from AssetRef " + assetRef);
                        }
                    });

                    //check for optional component article
                    if (article.optionalComponents != null && article.optionalComponents.size() > 0) {
                        for (OptionalComponent oc : article.optionalComponents) {
                            String componentAssetName = String.format("%s - %s ", productAsset.getName(), oc.name);
                            Asset optionalArticleAsset = copyAsset(articleAsset, componentAssetName, false, true, productAsset, RelationType.ASSIGNED_IN, false);
                            if (oc.template != null && !oc.template.isEmpty()) {
                                String template = oc.template;
                                AssetRef textTemplateRef = AssetRef.createResourceRef(resourceKeyByTemplate(template));
                                try {
                                    Asset textTemplate = textTemplateRef.get();
                                    if (textTemplate != null) {
                                        // [Produktname] - Text [Name optionaler Baustein]
                                        String textName = String.format("%s - Text %s", productAsset.getName(), oc.name);
                                        copyAsset(textTemplate, textName, true, false, optionalArticleAsset, TEXT_REL_TYPE_PARENT, false);
                                    }
                                } catch (Exception e) {
                                    logger.info("Failed to get Asset from AssetRef " + assetRef);
                                }
                            }
                        }
                    }

                } catch (Exception e) {
                    logger.info("Failed to get Asset from AssetRef " + assetRef);
                }
            });
            stopProgress();

            startProgress("allianzProductWizard.articleWillBeRendered");
            for (Channel channel : this.channels) {
                Asset channelAsset = AssetRef.createUnversioned(channel.id).get();
                if (channelAsset != null) {
                    createMedia(channelAsset, productAsset, pptxDatas, null);
                }
            }
            return openDefaultAssetPage(productAsset);
        } else {
            logger.info("####### Cant create product asset. No product data found.");
        }

        return null;
    }

    public void createMedia(Asset channelAsset, Asset productAsset, List<PPTXData> pptxDataList, Long targetGroup) throws Exception {
        List<PPTXData> pptxDatas;
        if (pptxDataList != null) {
            pptxDatas = pptxDataList;
        } else {
            pptxDatas = new ArrayList<>();
        }
        List <Asset>   pptxRebuildAssets = new ArrayList<>();

        if (targetGroup != null) {
            AssetRef targetGroupRef = AssetRef.createUnversioned(targetGroup);
            try {
                targetGroupAsset = targetGroupRef.get();
            } catch (Exception e) {
                logger.info("Failed to get Asset");
            }
        } else {
            targetGroupAsset = null;
        }

        if (channelAsset != null && productAsset != null) {
            String channelResourceKey = channelAsset.traitResourceAsset().getResourceKey();
            if (channelResourceKey != null) {
                switch (channelResourceKey) {
                    case FLYER_BUB:
                    case FLYER:
                    case TWO_PAGER:
                        try {
                            // default the template with production flag is-template
                            Asset targetLayout = getRelatedTemplate(channelAsset);
                            // if we have a targetGroup, there must be 1 existing base layout
                            // we want to make a variant from the base layout then for a target group, not the template
                            for (Asset asset : productAsset.asRelations().getRelatedAssets()) {
                                // look for related layouts
                                if (asset.traitType().getType().startsWith("layout.")) {
                                    // find layout that has the property media channel and the current channel as reference,
                                    // thats the layout that got created from this channel
                                    String value = asset.properties().getPropertyValue(MEDIA_CHANNEL, "");
                                    if (value.equals(String.valueOf(channelAsset.getId()))) {
                                        targetLayout = asset;
                                        break;
                                    }
                                }
                            }


                            Asset finalTargetLayout = targetLayout;
                            Asset clonedAsset = context.executeAtomically(Atomic.RETRY_ON_PERSISTENCE_LAYER_ERRORS,() -> {
                                try {
                                    AXml clone = executeTransformation(productAsset, CLONE_LAYOUT_AND_PLACE_ASSETS_TRAFO, finalTargetLayout.getId(), channelAsset.getId(), targetGroup);
                                    long id = clone.find("asset").getAttrLong("id");
                                    AssetRef cloneRef = AssetRef.createUnversioned(id);
                                    return cloneRef.get();
                                } catch (Exception e) {
                                    return null;
                                }
                            });

                            /*context.executeAtomically(Atomic.RETRY_ON_PERSISTENCE_LAYER_ERRORS,() -> {
                                try {
                                    executeTransformation(clonedAsset, "svtx:automation.indesign.replace.product", null, null, null);
                                } catch (Exception e) {
                                    DBTransactionManager tm = Platform.getCurrentContext().getService(DBTransactionManager.class);

                                    ServerEvent event = new ServerEvent("CustomAssetEvent", "svtx-content-update-failed", clonedAsset.getId(), clonedAsset.traitVersioning().getVersion());
                                    tm.addEvent(event);
                                }
                                return null;
                            });*/

                        } catch (Exception e) {
                            logger.info("Error on rendering templates. Renderer running?" + e);
                        }
                        break;

                    case ALLIANZ_DE:
                    case VERTRIEBSPORTAL:

                        // check if its a target group and the variant already exist, then do nothing. Later exchange storage item

                        String name = productAsset.getName();
                        AssetType type = AssetType.valueOf("extended-media.html.");
                        if (channelResourceKey.equals(VERTRIEBSPORTAL)) {
                            name += " - Vertriebsportal";
                        } else {
                            name += " - Allianz.de";
                        }

                        Asset allianz_de = null;
                        Asset parent = null;
                        RelationType parentRel = null;

                        if (targetGroupAsset == null) {
                            allianz_de = createAssetAndCheckInNew(name, type, channelAsset);
                            parent = productAsset;
                            parentRel = RelationType.ASSIGNED_IN;
                        }

                        else  {
                            for (Asset asset : productAsset.asRelations(RelationType.ASSIGNMENT).getRelatedAssets()) {
                                if (asset.traitType().getType().equals(type.getDBValue())) {
                                    String mediaChannel = asset.properties().getPropertyValue(MEDIA_CHANNEL);

                                    // does a target group specific variant for the current selected target group exist?
                                    java.util.Optional<Asset> at = asset
                                            .asRelations()
                                            .getRelatedAssets(AssetRelation.filter(RelationType.VARIANT)).toList()
                                            .stream()
                                            .filter(a -> a.properties().getProperty(TARGET_GROUP_PROPERTY).getValue().equals(String.valueOf(targetGroupAsset.getId())))
                                            .findFirst();

                                    if (!at.isPresent() && mediaChannel != null && mediaChannel.equals(String.valueOf(channelAsset.getId()))) {
                                        // Vertriebsportal gibt es also schon, deshalb das neue Asset als Variante vom aktuellen Vertriebsportal anlegen
                                        allianz_de = createAssetAndCheckInNew(name, type, channelAsset);
                                        parent = asset;
                                        parentRel = RelationType.VARIANT_OF;
                                        break;
                                    }
                                }
                            }
                        }

                        if (allianz_de != null) {
                            createRelation(allianz_de, parent, parentRel);
                        }

                        break;
                    case POWERPOINT :
                    case POWERPOINTVSK:
                    case POWERPOINTBUB:
                        try {
                            createPPTXSlides(channelAsset, productAsset, pptxDatas,PPTXKeys.TEXT_VARIANT_TYPE_STANDARD,"Standard");
                            pptxRebuildAssets.add(pptxAsset);
                            //executeTransformation(pptxAsset,TRANSFORMATION_REGENERATE_PPTX_ISSUE,null);
                        } catch (Exception e) {
                            logger.info("Error on creating  pptx issue standard" + e);
                        }

                        try {
                            createPPTXSlides(channelAsset, productAsset, pptxDatas,PPTXKeys.TEXT_VARIANT_TYPE_SALES,"Vertrieb");
                            pptxRebuildAssets.add(pptxAsset);
                            //executeTransformation(pptxAsset,TRANSFORMATION_REGENERATE_PPTX_ISSUE,null);
                        } catch (Exception e) {
                            logger.info("Error on creating pptx issue sales" + e);
                        }

                        try {
                            createPPTXSlides(channelAsset, productAsset, pptxDatas,PPTXKeys.TEXT_VARIANT_TYPE_AGENT,"Makler");
                            pptxRebuildAssets.add(pptxAsset);
                            //executeTransformation(pptxAsset,TRANSFORMATION_REGENERATE_PPTX_ISSUE,null);
                        } catch (Exception e) {
                            logger.info("Error on creating  pptx issue agent" + e);
                        }

                        try {
                            createRegenerationAsset(pptxRebuildAssets);
                        }catch (Exception e) {
                            logger.info("Error on creating regenerating Asset" + e);
                        }

                        break;
                }
            }

        }
    }



    @Execute
    public SelfDescribingApplication.SelfDescribingApplicationData rendererIsAvailable(CommandContext context) throws Exception {
        return success(LayoutServiceHelper.isLayoutServiceAvailable());
    }

    /**
     * Liefert die TextAssetRelationen vom ChannelAsset
     * @param channelAsset
     * @return
     */
    private List<AssetRelation> getRelationsWithTextSizeProperty(Asset channelAsset) {
        return channelAsset.asRelations(RelationType.PLANNING)
                .getRelations()
                .filter(assetRelation -> assetRelation.properties().getProperty(TEXT_SIZE_PROPERTY).exist())
                .toList();
    }
    /**
     * Alle Relationen des Basisfoliensatzes
     * @param asset
     * @return
     */
    private List<AssetRelation> getAllPowerpointRelations(Asset asset) {
        return asset.asRelations(RelationType.PLANNING)
                .getRelationsSorted(true)
                .filter(assetRelation -> {
                    try {
                        return assetRelation.getChildAssetRef().get().getType().getDBValue().equals("presentation.slide.") ;
                    } catch (Exception e) {
                        e.printStackTrace();
                        return false;
                    }
                })
                .toList();
    }


    private String getRelatedTemplateResourceKey(Asset asset) {
        Asset layout = asset.asRelations(RelationType.valueOf("user.layout.", AssetRelation.Direction.CHILD)).getRelatedAssets().first();
        if (layout != null) {
            return layout.properties().getPropertyValueString(Asset.TRAITS.ResourceAsset.key, "");
        }
        return "";
    }

    private Asset getRelatedTemplate(Asset asset) {
        return asset.asRelations(RelationType.valueOf("user.layout.", AssetRelation.Direction.CHILD)).getRelatedAssets().first();
    }

    private List<Article> getAllArticle() {
        return this.channels.stream().filter(channel -> channel.article != null).flatMap(channel -> channel.article.stream()).collect(Collectors.toList());
    }

    private Asset extendedMediaOfProduct(Asset productAsset, Asset channelAsset) {
        return productAsset.asRelations().getRelatedAssets(assetRelation -> {
            AssetRef childAssetRef = assetRelation.getChildAssetRef();
            if (childAssetRef != null) {
                try {
                    Asset childAsset = childAssetRef.get();
                    return childAsset.properties().getProperty("allianz", "mediaChannel").asLong(0) == channelAsset.getId();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            return false;
        }).first();
    }

    private void createRelation(Asset asset, Asset asset2, RelationType relationType) throws Exception {
        createRelation(asset, asset2, relationType,-1);
    }


    private void createRelation(Asset asset, Asset asset2, RelationType relationType,int sortNumber) throws Exception {
        context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.getAsset(asset.getSelf());

            Asset newAsset = assetRef.get();
            AssetRelation rel= newAsset.asRelations().createOrGetRelation(asset2.getSelf(),relationType);
            if(sortNumber>=0) {
                rel.traitSortable().setSorting(sortNumber);
            }
            assetRef.set(newAsset);
            return assetRef;
        });
    }

    private Asset getRelatedTextAsset(Asset asset, String textType) {
        return asset.asRelations(TEXT_REL_TYPE_CHILD)
                .getRelatedAssets()
                .first(text -> text.getType().getDBValue().equals(textType));
    }

    private Asset getRelatedPptSlide(Asset asset) {
        return asset.asRelations(RelationType.PLANNING)
                .getRelatedAssets()
                .first(slide -> slide.getType().getDBValue().equals("presentation.slide."));
    }

    private void cleanStepData(WizardStep step) {
        if (step.data == null) {
            step.setDataProperty("init", true);
        } else {
            step.data.removeAllChildNodes();
        }
    }



    private List<Asset> getSelectedAssets(AXml stepData) {
        List<Asset> assets = new ArrayList<>();

        if (stepData == null) {
            return assets;
        }

        for (AXml selection : stepData.findAllX("selection")) {
            String assetRef = selection.getAttr("assetRef");
            if (AssetRef.isValidRef(assetRef)) {
                try {
                    Asset asset = AssetRef.fromString(assetRef).get();
                    assets.add(asset);
                } catch (Exception e) {
                    logger.info("Failed to get Asset from AssetRef " + assetRef);
                }
            }
        }
        return assets;
    }

    private AXml getStepData(AllianzProductWizardSteps step) {
        WizardStep s = getWizardModel().findStep(step.name());
        if (s != null && s.data != null) {
            return s.data;
        }
        return AXml.createElement("data");
    }

    protected String getFeatureLabelOfTextSize(String textSize) {
        CacheService cacheService = Platform.getCCServiceEx(CacheService.class);
        CachedTable cachedTable = cacheService.getCachedTable(FeatureValue.ELM_NAME, context.getTransactionContext().getLocale());
        FeatureValue featureValue = (FeatureValue) cachedTable.getEntry(FeatureValue.ATTR_VALUE_KEY, textSize);
        if (featureValue != null) {
            return featureValue.getName();
        }
        return "";
    }

    private String getAssetTypeOfTextSize(String textSize) {
        switch (textSize) {
            case "size-s":
                return "text.size-s.";
            case "size-m":
                return "text.size-m.";
            case "size-l":
                return "text.size-l.";
            case "size-xl":
                return "text.size-xl.";
            default:
                return "text.";
        }
    }

    private String resourceKeyByTemplate(String template) {
        switch (template) {
            case "optional-template-column":
                return "svtx:optional-template-column";
            case "optional-template-tiles":
                return "svtx:optional-template-tiles";
            default:
                return "";
        }
    }

    private AXml executeTransformation (Asset ctxAsset, String resourceKey, Long targetLayout, Long targetChannel, Long targetGroup) throws Exception {
        DBTransactionManager tm = Platform.getCCServiceEx(DBTransactionManager.class);
        AssetTransformation assetTransformation = new AssetTransformation(tm, resourceKey);
        // add transformation parameters
        assetTransformation.setParamObject(ServiceContext.PROPERTY_TM, tm);

        if (targetLayout != null) {
            assetTransformation.setParamObject("target-layout", targetLayout);
        }

        if (targetChannel != null) {
            assetTransformation.setParamObject("target-channel", targetChannel);
        }

        if (targetGroup != null) {
            assetTransformation.setParamObject("target-group", targetGroup);
        }

        if (newAssetDomain != null) {
            assetTransformation.setParamObject("new-domain", newAssetDomain);
        }

        // Execute the transformation
        DataWrapper transformationResult = assetTransformation.transform(ctxAsset.toLegacyXml().getDocumentNode());
        return transformationResult.asXML();
    }

    private void copyMasterStorage(Asset srcAsset, Asset destAsset) throws Exception {
        StorageItem srcStorageItem = srcAsset.asStorages().getMasterStorageItem();
        if (srcStorageItem == null) {
            return;
        }
        //System.out.println(srcStorageItem.properties().getAllProperties();
        StorageItem destStorageItem = destAsset.asStorages().createOrGetStorageItem(srcStorageItem.getType(), srcStorageItem.getFileLocator().mimetype());
        FileLocator tempFile = ffs.createTempFile("temp-file", srcStorageItem.getFileExtension());
        FileLocatorUtilities.streamCopy(srcStorageItem.getFileLocator(), tempFile,false,null);
        destStorageItem.attachData(tempFile, null);
    }

    private Asset createAssetAndCheckInNew(String name, AssetType type) throws Exception {
        return createAssetAndCheckInNew(name, type, null);
    }


    private Asset createAssetAndCheckInNew(String name, AssetType type, Asset channel) throws Exception {
        AtomicRef ref = context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.createNewAndSetDefaults(name, type);
            Asset asset = assetRef.get();

            if (newAssetDomain != null) {
                asset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
            }

            if(type.isSameType("presentation.issue.") || type.isSameType("extended-media.html.")) {

                Workflow wf = getWorkflow(80);
                if(wf != null) {
                    asset.traitWorkflow().setWorkflow(wf);
                }
                WorkflowStep step = getWorkflowStep(80, 10);
                if(step != null) {
                    asset.traitWorkflow().setWorkflowStep(step);
                }
            } else if (type.isSameType("product.") || type.isSameType("product.vsk.") || type.isSameType("product.needs-and-advice.")) {
                asset.traitWorkflow().setWorkflowAndStep(30,20);
            }



            if (channel != null) {
                asset.properties().setProperty(MEDIA_CHANNEL, String.valueOf(channel.getId()));
            }
            if (targetGroupAsset != null) {
                asset.properties().setProperty(TARGET_GROUP_PROPERTY, String.valueOf(targetGroupAsset.getId()));
            }

            if (AssetType.PRODUCT.isMainTypeOf(type)) {
                if (productArea != null) {
                    asset.properties().setProperty(FEATURE_PRODUCT_AREA, productArea);
                }
                if (productBranch != null) {
                    asset.properties().setProperty(FEATURE_PRODUCT_BRANCH, productBranch);
                }
                if (productCategoryAzde != null) {
                    asset.properties().setProperty(PRODUCT_CATEGORY_AZ_DE, productCategoryAzde);
                }
            }

            assetRef.checkInNew(asset);
            return assetRef;
        });
        return ref.get();
    }

    private Asset copyAsset(Asset srcAsset, String assetName, boolean copyMasterStorageItem, boolean isOptionalComponent) throws Exception {
        return copyAsset(srcAsset, assetName, copyMasterStorageItem, isOptionalComponent, null, null, false);
    }


    private Asset copyAsset(Asset srcAsset, String assetName, boolean copyMasterStorageItem, boolean isOptionalComponent, Asset relationAsset, RelationType relationType, boolean lockAsset) throws Exception {
        String newName = assetName == null ? srcAsset.getName() : assetName;
        AtomicRef ref = context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.createNewAndSetDefaults(newName, srcAsset.getType());
            Asset copiedAsset = assetRef.get();
            if (copyMasterStorageItem) {
                copyMasterStorage(srcAsset, copiedAsset);
            }
            StringProperty editorProperty = srcAsset.properties().getProperty(CONTENT_EDITOR_CONFIG_PROPERTY);
            if (editorProperty != null && editorProperty.getValue() != null) {
                copiedAsset.properties().createProperty(CONTENT_EDITOR_CONFIG_PROPERTY).setValue(editorProperty.getValue());
            }

            if (newAssetDomain != null) {
                copiedAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
            }

            Arrays.asList(FEATURE_AEM_TEMPLATE, FEATURE_ALIAS_NAME).forEach(prop -> {
                StringProperty assetProperty = srcAsset.properties().getProperty(prop);
                if (assetProperty != null) {
                    copiedAsset.properties().setProperty(prop, assetProperty.getValue());
                }
            });

            StringProperty bsTemplateProperty = srcAsset.properties().getProperty(BS_TEMPLATE_PROPERTY);
            if (bsTemplateProperty != null && bsTemplateProperty.getValue() != null) {
                copiedAsset.properties().createProperty(BS_TEMPLATE_PROPERTY).setValue(bsTemplateProperty.getValue());
            }

            /* copy workflow */
            copiedAsset.traitWorkflow().setWorkflow(srcAsset.traitWorkflow().getWorkflow());
            copiedAsset.traitWorkflow().setWorkflowStep(srcAsset.traitWorkflow().getWorkflowStep());
            copiedAsset.traitWorkflow().setWorkflowTarget(srcAsset.traitWorkflow().getWorkflowTarget());

            copiedAsset.properties().createProperty(COPY_OF_PROPERTY).setValue(String.valueOf(srcAsset.getId()));

            if (isOptionalComponent) {
                copiedAsset.properties().setProperty(OPTIONAL_COMPONENT, "1");
            }

            if (relationAsset != null && relationType != null) {
                copiedAsset.asRelations().createOrGetRelation(relationAsset.getSelf(), relationType);
            }

            if (lockAsset) {
                if (AssetType.TEXT.isMainTypeOf(copiedAsset.getType())) {
                    copiedAsset.traitAccessRights().addOwner(2);
                    copiedAsset.traitAccessRights().setNonOwnerAccess(1);
                }
                if (AssetType.ARTICLE.isMainTypeOf(copiedAsset.getType())) {
                    AssetRef recurringModule = findRecurringModuleTemplate(srcAsset.getType().getDBValue());
                    if (recurringModule != null) {
                        copiedAsset.trait("allianz").setProperty("recurringModule", recurringModule.getAssetId());
                    }
                }

            }
            assetRef.checkInNew(copiedAsset);
            return assetRef;
        });
        return ref.get();
    }


    private Asset copySlideAsset(Asset srcAsset, String assetName ) throws Exception {

        String newName = assetName == null ? srcAsset.getName() : assetName;

        AtomicRef ref = context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.createNewAndSetDefaults(newName, srcAsset.getType());
            Asset copiedAsset = assetRef.get();

            copyMasterStorage(srcAsset, copiedAsset);

            // Suchen aller asset_feature welche mit  savotex:"  und eintragen in das neue
            ArrayList<Property> plist = new ArrayList<Property>();
            srcAsset.properties().getAllFeatureProperties(). forEach(p->{

                if(p.getInfo().getFeatureKey().startsWith("savotex:pp")) {
                    plist.add(p);
                } else if (p.getInfo().getFeatureKey().equals("censhare:resource-key")){
                    try {
                        addProperty(copiedAsset,"allianz","layoutTemplateResourceKey",p.getValue());
                    }  catch (Exception e) {
                        logger.info(e.toString());
                    }
                }
            });


            copiedAsset.properties().createProperty(FEATURE_LAYOUT_TEMPLATE_CREATION_DATE).setValue(srcAsset.traitCreated().getDate());
            copiedAsset.properties().createProperty(FEATURE_LAYOUT_TEMPLATE_VERSION).setValue((long)srcAsset.traitVersioning().getVersion());

            try {
                //StringProperty editorProperty = srcAsset.properties().getProperty(CONTENT_EDITOR_CONFIG_PROPERTY);
                // Wir holen uns den Resourcekey des Masterslides oder nehmen ggf seine ID
                String resourceKey = srcAsset.traitResourceAsset().getResourceKey();
                /*
                if(resourceKey == null) {
                    resourceKey = Long.toString(srcAsset.getId());
                }

                 */
                if (resourceKey != null ) {// CONTENT_EDITOR_CONFIG_PROPERTY
                    copiedAsset.properties().createProperty(FEATURE_LAYOUT_TEMPLATE_RESOURCE_KEY).setValue(resourceKey);
                }

                if (newAssetDomain != null) {
                    copiedAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
                }

                if (targetGroupAsset != null) {
                    copiedAsset.properties().setProperty(TARGET_GROUP_PROPERTY, String.valueOf(targetGroupAsset.getId()));
                }
                //copiedSlideAsset.properties().createProperty(FEATURE_LAYOUT_TEMPLATE_RESOURCE_KEY).setValue("THEMAster");

                plist.forEach(p -> {
                    PropertyKey<Trait.GenericTrait, StringProperty> tempKey = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "ppt"), p.getInfo().getName());
                    StringProperty savotexProperty = (StringProperty) p;
                    copiedAsset.properties().createProperty(tempKey).setValue(savotexProperty.getValue());
                    //copiedAsset.properties().createProperty((PropertyKey)p.getPropertyId()).setValue(p.getValue());
                });



            }  catch (Exception e) {
                logger.info(e.toString());
            }


            assetRef.checkInNew(copiedAsset);
            return assetRef;
        });
        return ref.get();
    }


    protected Asset copyCompleteAsset(Asset srcAsset) throws Exception {
        AtomicRef ref = context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.createNew(srcAsset);
            Asset copiedAsset = assetRef.get();
            assetRef.checkInNew(copiedAsset);
            return assetRef;
        });
        return ref.get();
    }


    protected PPTXData findTextPPTXData(List<PPTXData> pptxDatas, Asset pptxAsset) {
        for(PPTXData data:pptxDatas ) {
            if(data.pptxAssetId == pptxAsset.getId()) {
                return data;
            }
        }
        return null;
    }


    protected Asset getBasicSetAsset(Asset asset) {
        for (Asset a : asset.asRelations(RelationType.ASSIGNMENT).getRelatedAssets().toList()) {
            if (a.getType().getDBValue().equals("presentation.issue." )) { //TODO and application="collection"

                if(a.trait("type").getProperty("application").getValue().equals("collection")) {
                    // if ((AssetData) pptxGroup.properties()).getTrait("type").getProperty("application")
                    return a;
                }
            }
        }

        return null;
    }

    protected void createRegenerationAsset( List <Asset>   pptxRebuildAssets) throws Exception {
        AtomicRef ref = context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.createNewAndSetDefaults("Regeneration", ASSET_TYPE_POWERPOINT_REGENERATION);
            Asset modulAsset = assetRef.get();
            for(Asset asset2 :pptxRebuildAssets) {
                AssetRelation rel= modulAsset.asRelations().createOrGetRelation(asset2.getSelf(), TEXT_REL_TYPE_CHILD);
                //assetRef.set(newAsset);
            }

            assetRef.checkInNew(modulAsset);
            return assetRef;
        });

    }

    protected void createPPTXSlides(Asset pptxChannelAsset, Asset productAsset, List<PPTXData> pptxDatas,String type,String typeName) throws Exception {
        String name = productAsset.getName()+" PowerPoint "+typeName;
        Asset existingPptx = null;
        if (targetGroupAsset != null) {
            QueryService qs = Platform.getCCServiceEx(QueryService.class);
            name = name + " - " + targetGroupAsset.getName();
            // find a alreay existing pptx with given targetgroup/text type related to product
            String queryStr = "<query type=\"asset\">\n" +
                    "  <condition name=\"censhare:asset.type\" value=\"presentation.issue.*\"/>\n" +
                    "  <condition name=\"censhare:target-group\" value=\"@@targetgroup@@\"/>\n" +
                    "  <condition name=\"svtx:text-variant-type\" value=\"@@type@@\"/>\n" +
                    "  <relation target=\"parent\" type=\"variant.*\">\n" +
                    "    <target>\n" +
                    "      <condition name=\"censhare:asset.type\" value=\"presentation.issue.*\"/>\n" +
                    "      <relation target=\"parent\" type=\"user.*\">\n" +
                    "        <target>\n" +
                    "          <condition name=\"censhare:asset.id\" value=\"@@product@@\"/>\n" +
                    "        </target>\n" +
                    "      </relation>\n" +
                    "    </target>\n" +
                    "  </relation>\n" +
                    "</query>\n";

            queryStr = queryStr.replace("@@product@@", TypeConversion.toString(productAsset.getId()));
            queryStr = queryStr.replace("@@type@@", TypeConversion.toString(type));
            queryStr = queryStr.replace("@@targetgroup@@", TypeConversion.toString(targetGroupAsset.getId()));
            AXml queryXml = CXmlUtil.parse(queryStr);
            QSelect select = qs.xmlToQ(queryXml);
            Iterable<AssetRef> result = qs.queryAssetIds(select);
            if (result.iterator().hasNext()) {
                existingPptx = result.iterator().next().get();
            }
        }

        if (existingPptx != null) {
            //svtx:pptx.slide.update.target.group.variant
            Asset finalExistingPptx = existingPptx;
            context.executeAtomically(()-> {
                try {
                    return executeTransformation(finalExistingPptx, "svtx:pptx.slide.update.target.group.variant", null, null, null);
                } catch (Exception e) {
                    return null;
                }
            });
            return;
        }




        /* create or find */

        pptxAsset =  createAssetAndCheckInNew(name, ASSET_TYPE_POWERPOINT_ISSUE, pptxChannelAsset);

        //addProperty(pptxAsset,"type","application","collection");// svtx:text-variant-type
        addProperty(pptxAsset,"allianzTextVariantType","textVariantType",type);
        //addProperty(pptxAsset,"allianz","layoutTemplateResourceKey","MYTestValue");


        // default parent Asset + Relation for a pptx slide
        Asset parent = productAsset;
        AssetRelation.RelationType parentRel = RelationType.ASSIGNMENT;

        if (targetGroupAsset != null) {
            // if we have a target group, we want to create variant of the defult pptx Asset, so we change parent Asset and Relationtype
            for (Asset asset : productAsset.asRelations().getRelatedAssets()) {
                String mediaChannel = asset.properties().getProperty(MEDIA_CHANNEL).getValue();
                if (mediaChannel != null && mediaChannel.equals(String.valueOf(pptxChannelAsset.getId()))) {
                    if (asset.getName().contains(typeName)) {
                        parent = asset;
                        parentRel = RelationType.VARIANT;
                        break;
                    }
                }
            }
        }

        createRelation(parent, pptxAsset, parentRel);

        pptxRelationCount =0;

        Asset pptxGroup = getBasicSetAsset(pptxChannelAsset);

        if (pptxGroup != null) {
            List<AssetRelation> pptxRelations = getAllPowerpointRelations(pptxGroup);

            pptxRelations.forEach(
                    pptxRef -> {
                        try {
                            Asset slideAsset = pptxRef.getChildAssetRef().get();
                            PPTXData pptxData = findTextPPTXData(pptxDatas, slideAsset);
                            // Für fixe Slides gibt es weder Text noch textSize
                            if(pptxData==null) {
                                createPPTXSlide(slideAsset, null, productAsset, type,null);
                            } else{
                                Asset article =  pptxData.articleCopy;
                                if (article != null && targetGroupAsset != null) {
                                    // zielgruppen variante finden zum aktuellen zielgruppen asset
                                    Relations articleVariants = article.asRelations(RelationType.VARIANT);
                                    for (Asset articleVariant : articleVariants.getRelatedAssets()) {
                                        StringProperty targetGroupProperty = articleVariant.properties().getProperty(TARGET_GROUP_PROPERTY);
                                        if (targetGroupProperty != null && targetGroupProperty.getValue().equals(String.valueOf(targetGroupAsset.getId()))) {
                                            article = articleVariant;
                                            break;
                                        }
                                    }
                                }
                                // testSite
                                // vom slide (planung)=> article => (planung Merkmal-Textgöße) =>  pptxGroup
                                createPPTXSlide(slideAsset, article, productAsset, type,pptxData.textSize);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                    }
            );
        }
    }

    protected void addProperty(Asset asset, String traitName, String popertyName, Object data) throws Exception {
        context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.getAsset(asset.getSelf());

            Asset newAsset = assetRef.get();
            newAsset.trait(traitName).setProperty(popertyName,data);
            assetRef.set(newAsset);
            return assetRef;
        });
    }

    public void setCommandContext(CommandContext ctx) {
        context = ctx;
    }


    protected void addProperty(AtomicRef assetRef, String traitName, String popertyName, Object data) throws Exception {
        context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            Asset newAsset = assetRef.get();
            newAsset.trait(traitName).setProperty(popertyName,data);
            assetRef.set(newAsset);
            return assetRef;
        });
    }


    protected void createPPTXSlide(Asset slide,Asset article, Asset productAsset, String type,Text textSize) throws Exception {

        Asset copiedSlideAsset = copySlideAsset(slide,productAsset.getName()+ " "+ slide.getName());

        addProperty(copiedSlideAsset,"allianzTextVariantType","textVariantType",type);
        if(textSize != null) { // TODO TargetGroup kennt die gewünschte TextSize nicht ;-(
            addProperty(copiedSlideAsset, "allianzText", "size", textSize.size);  // textSize.size
        }

        pptxRelationCount +=1;
        createRelation(pptxAsset, copiedSlideAsset, RelationType.PLANNING, pptxRelationCount); //TODO das ist nicht planning
        if(article != null) {
            createRelation(copiedSlideAsset, article, RelationType.PLANNING);
        }
    }

    protected Workflow getWorkflow(int workflowId) {
        if (workflowId != -1) {
            CacheService cacheService = Platform.getCCServiceEx(CacheService.class);
            CachedTable wfTable = cacheService.getCachedTable("workflow", context.getTransactionContext().getLocale());

            DataObject[] entries = wfTable.getEntries();

            for (DataObject entry : entries) {
                Workflow wf = (Workflow) entry;
                if (wf.getId(-1) == workflowId) {
                    return wf;
                }
            }
        }
        return null;
    }

    protected WorkflowStep getWorkflowStep(int workflowId, int stepId) {
        if (workflowId != -1 && stepId != -1) {
            CacheService cacheService = Platform.getCCServiceEx(CacheService.class);
            CachedTable wfStepTable = cacheService.getCachedTable("workflow_step", context.getTransactionContext().getLocale());
            DataObject[] entries = wfStepTable.getEntries();

            for (DataObject entry : entries) {
                WorkflowStep step = (WorkflowStep) entry;
                if (step.getWfStep(-1) == stepId && step.getWfId(-1) == workflowId) {
                    return step;
                }
            }
        }
        return null;
    }

    private AssetRef findRecurringModuleTemplate(String type) throws Exception {
        QueryService qs = Platform.getCCServiceEx(QueryService.class);
        String queryStr =
                "<query limit=\"1\"  type=\"asset\">\n" +
                        "  <condition name=\"censhare:asset.type\" value=\"@@type@@\"/>\n" +
                        "  <condition name=\"censhare:asset-flag\" value=\"is-template\"/>\n" +
                        "  <condition name=\"censhare:template-hierarchy\" value=\"root.content-building-block.recurring-modules.\"/>\n" +
                        "</query>\n";
        queryStr = queryStr.replace("@@type@@", type);
        AXml queryXml = CXmlUtil.parse(queryStr);
        QSelect select = qs.xmlToQ(queryXml);
        Iterable<AssetRef> result = qs.queryAssetIds(select);
        if (result.iterator().hasNext()) {
            return result.iterator().next();
        }
        return null;
    }
}
