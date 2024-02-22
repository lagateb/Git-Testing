package com.allianz.target.group.wizard;

import com.allianz.product.wizard.AllianzProductWizardApplication;
import com.allianz.product.wizard.AllianzProductWizardApplication.PPTXData;
import com.censhare.api.applications.wizards.AbstractWizardsApplication;
import com.censhare.api.applications.wizards.model.WizardModel;
import com.censhare.db.query.model.AssetQBuilder;
import com.censhare.db.query.model.QRelation;
import com.censhare.model.corpus.impl.Feature;
import com.censhare.model.logical.api.base.Property;
import com.censhare.model.logical.api.base.Trait;
import com.censhare.model.logical.api.domain.*;
import com.censhare.model.logical.api.domain.traits.AssetTraits;
import com.censhare.model.logical.api.properties.StringProperty;
import com.censhare.server.support.api.impl.CommandAnnotations;
import com.censhare.server.support.api.transaction.AtomicRef;
import com.censhare.server.support.api.transaction.QueryService;
import com.censhare.server.support.api.transaction.UpdatingRepository;
import com.censhare.support.context.Platform;
import com.censhare.support.io.FileFactoryService;
import com.censhare.support.json.ClassAnalyzer.Key;
import com.censhare.support.json.Serializers;
import com.censhare.support.model.QOp;
import com.censhare.support.model.QSelect;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.transaction.TransactionException;
import com.censhare.support.xml.AXml;
import modules.product_classification.classification.DataModel;

import java.util.*;
import java.util.stream.Collectors;


@CommandAnnotations.CommandHandler(command = "com.allianz.target.group.wizard", scope = CommandAnnotations.ScopeType.CONVERSATION)
public class TargetGroupHandler extends AbstractWizardsApplication {

    private final FileFactoryService ffs = ServiceLocator.getStaticService(FileFactoryService.class);
    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> TARGET_GROUP_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "category"), "targetGroup");

    public static class MediaComponent {
        @Key
        public String display_name;
        @Key
        public String name;
        @Key
        public String type;
        @Key
        public Long id;
        @Key
        public boolean selected;
        @Key
        public boolean disabled;
        @Key
        public boolean hasVariant;
    }

    public enum Mode {
        override("override"),
        enrich("enrich");

        private final String mode;
        private static final Map<String, Mode> lookup = new HashMap<>();

        Mode(String mode) {
            this.mode = mode;
        }

        public String getValue() {
            return mode;
        }

        static {
            for(Mode mode : Mode.values()) {
                lookup.put(mode.getValue(), mode);
            }
        }

        public static Mode get(String mode) {
            return lookup.get(mode);
        }
    }

    public enum TargetGroupSteps {
        chooseTargetGroup,
        chooseMedia,
        chooseArticle;

        public boolean isStep(WizardModel.WizardStep step) {
            return step != null && step.name.equals(this.name());
        }
    }

    @Override
    protected void initWizardData(WizardModel wizard) {
        logger.info("### INIT WIZARD " + wizard);
    }

    @Override
    protected boolean beforeStepAction(WizardStepAction action, WizardModel.WizardStep step){

        if (TargetGroupSteps.chooseArticle.isStep(step)) {
            Asset ctxAsset = getContextAsset();
            List<Asset> channelList = getSelectedChannel();
            try {
                List<Asset> relatedChannelComponents = relatedMediaComponents(channelList.stream().map(Asset::getId).collect(Collectors.toList()));
                List<Asset> relatedProductComponents = relatedMediaComponents(Collections.singletonList(ctxAsset.getId()));
                List<Asset> createOrOverrideComponents = new ArrayList<>();
                relatedChannelComponents.forEach(asset -> {
                    String type = asset.getType().getDBValue();
                    java.util.Optional<Asset> article = relatedProductComponents
                            .stream()
                            .filter(asset1 -> asset1.getType().getDBValue().equals(type))
                            .findFirst();
                    if (getMode().equals(Mode.enrich)) {
                        if (!article.isPresent()) {
                            createOrOverrideComponents.add(asset);
                        }
                    } else {
                        article.ifPresent(createOrOverrideComponents::add);
                    }
                });

                WizardModel.WizardStep step3 = getWizardModel().findStep(TargetGroupSteps.chooseArticle.name());
                cleanStepData(step3);
                Asset targetGroup = getTargetGroupAsset();
                createOrOverrideComponents.forEach(asset -> {
                    MediaComponent mc = new MediaComponent();
                    mc.id = asset.getId();
                    mc.name = asset.getName();
                    mc.display_name = asset.traitType().getTypeRef().getName();
                    mc.type = asset.getType().getDBValue();
                    mc.selected = false;
                    mc.disabled = false;

                    if (targetGroup != null) {
                        Asset targetGroupVariant = asset.asRelations(AssetRelation.RelationType.VARIANT).getRelatedAssets(rel -> {
                            Asset relAsset = null;
                            try {
                                relAsset = rel.getChildAssetRef().get();
                            } catch (Exception e) {
                                logger.info("Failed to query Asset for " + rel.getChildAssetRef());
                            }
                            String propValue = "";
                            if (relAsset != null) {
                                propValue = relAsset.properties().getPropertyValue(TARGET_GROUP_PROPERTY, "");
                            }
                            return propValue.equals(String.valueOf(targetGroup.getId()));
                        }).first();
                        if (targetGroupVariant != null) {
                            mc.hasVariant = true;
                            mc.disabled = true;
                            mc.selected = true;
                        }
                    } else if (getMode().equals(Mode.enrich)) {
                        mc.selected = true;
                        mc.disabled = true;
                    }
                    step3.data.appendChild(Serializers.fromPojo(mc).toXML());
                });

            } catch (TransactionException e) {
                e.printStackTrace();
            }

        }

        logger.info("### LEAVE STEP  ENTER STEP " + step);
        return true;
    }

    @Override
    protected boolean afterStepAction(WizardStepAction action, WizardModel.WizardStep step) throws Exception {
        logger.info("### LEAVE STEP " + step);
        return true;
    }

    @Override
    protected boolean onCancel() {
        logger.info("### CANCEL");
        return true;
    }

    @Override
    protected Object onFinish() throws Exception {

        Asset targetGroup = getTargetGroupAsset();
        Asset ctxAsset = getContextAsset();

        List<MediaComponent> mediaComponents = new ArrayList<>();
        getStepData(TargetGroupSteps.chooseArticle).findAll("MediaComponent").forEach(mc -> {
            MediaComponent mediaComponent = Serializers.fromXML(mc).toPojo(MediaComponent.class);
            if (mediaComponent != null) {
                if (getMode().equals(Mode.enrich)) {
                    mediaComponents.add(mediaComponent);
                } else if (!mediaComponent.hasVariant && mediaComponent.selected) {
                    mediaComponents.add(mediaComponent);
                }
            }
        });


        mediaComponents.forEach(mediaComponent -> {
            AssetRef articleRef = AssetRef.createUnversioned(mediaComponent.id);
            try {
                Asset articleAsset = articleRef.get();
                Asset parentAsset;
                AssetRelation.RelationType relationType;
                String articleName;
                if (getMode().equals(Mode.enrich)) {
                    articleName = String.format("%s - %s", ctxAsset.getName(), articleAsset.getName());
                    parentAsset = ctxAsset;
                    relationType = AssetRelation.RelationType.ASSIGNED_IN;
                } else {
                    articleName = String.format("%s - %s", articleAsset.getName(), targetGroup.getName());
                    parentAsset = articleAsset;
                    relationType = AssetRelation.RelationType.VARIANT_OF;
                }
                Asset duplicateArticle = duplicate(articleAsset, articleName , parentAsset, relationType);
                if (targetGroup != null) {
                    setTargetGroup(duplicateArticle, targetGroup);
                }

                // copy texts
                getRelatedTextAssets(articleAsset).forEach(asset -> {
                    String textName = asset.getName();
                    if (targetGroup != null) {
                        textName = String.format("%s - %s", textName, targetGroup.getName());
                    }
                    Asset duplicateText = duplicate(asset, textName, duplicateArticle, AssetRelation.RelationType.valueOf("user.main-content.", AssetRelation.Direction.PARENT));
                    if (duplicateText != null) {
                        increaseVersionCount(duplicateText);
                    }
                    if (targetGroup != null) {
                        setTargetGroup(duplicateText, targetGroup);
                    }
                });

            } catch (Exception e) {
                logger.info("Fail");
            }
        });

        Long targetGroupId = getTargetGroupAsset() != null ? getTargetGroupAsset().getId() : null;

        AllianzProductWizardApplication productWizardApplication = new AllianzProductWizardApplication();
        productWizardApplication.setCommandContext(context);

        List<PPTXData> pptxDataList = getPptxData(ctxAsset);
        startProgress("Medien werden erstellt");
        getSelectedChannel().forEach(channel -> {
            try {
                productWizardApplication.createMedia(channel, ctxAsset, pptxDataList, targetGroupId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });

        /*
         * Wenn ein Medium (z.B. Flyer) um eine Zielgruppe erweitert wird,
         * dann muss unter dem Produkt nach weiteren Medien gesucht werden (z.B. Produktsteckbrief), welche die gleiche Zielgruppe haben.
         * Auch wenn der Kanal im 2. Step dafür NICHT gewählt wurde, muss der prozess des Renders trotztdem neu angestoßen werden.
         * Denn es kann sein dass in diesem Step eine neue Baustein Variante für die zielgruppe erstellt wird, welche dann auch in alle anderen Medien dieser Zielgruppe erscheinen sollen.
         *  Ticket: ORTCONTENT-212
         * */
        if (getMode().equals(Mode.override) && targetGroup != null) {
            // find layouts under product for current target group
            QueryService qs = Platform.getCCServiceEx(QueryService.class);
            AssetQBuilder qb = qs.prepareQBuilder();
            QOp and = qb.and();
            and.add(qb.feature(Feature.Key.ASSET_TYPE, "channel."));
            and.add(qb.feature(Feature.Key.PRODUCTION_FLAG, "is-template"));
            and.add(qb.relation(QRelation.REL_DIRECTION_FEATURE_REVERSE, "svtx:media-channel",
                    qb.and(
                            qb.feature("censhare:target-group", targetGroup.getId()),
                            qb.relation(QRelation.REL_DIRECTION_PARENT, "variant.",
                                    qb.and(
                                            qb.feature(Feature.Key.ASSET_TYPE, "LIKE" , "layout%"),
                                            qb.relation(QRelation.REL_DIRECTION_PARENT, "user.", qb.feature(Feature.Key.ASSET_ID, ctxAsset.getId()))
                                    )
                            ))));
            Long[] channelIds = getSelectedChannel().stream().map(Asset::getId).toArray(Long[]::new);
            if (channelIds.length > 0) {
                and.add(qb.not(qb.feature(Feature.Key.ASSET_ID, "IN" , channelIds)));
            }
            QSelect query = qb.select().where(and);
            qs.queryAssets(query).forEach(queryResult -> {
                try {
                    productWizardApplication.createMedia(queryResult, ctxAsset, pptxDataList, targetGroupId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }

        stopProgress();

        return success();
    }

    private List<PPTXData> getPptxData(Asset productAsset) throws TransactionException {
        List<Asset> articles = productAsset.asRelations().getRelatedAssets(assetRelation -> {
            AssetRef childAssetRef = assetRelation.getChildAssetRef();
            if (childAssetRef != null) {
                try {
                    Asset childAsset = childAssetRef.get();
                    return childAsset.traitType().getType().startsWith("article.");
                } catch (Exception e) {
                    logger.info("Failed to get Asset " + childAssetRef.toString());
                }
            }
            return false;
        }).toList();
        List<Asset> assetList = new ArrayList<>();
        QueryService qs = Platform.getCCServiceEx(QueryService.class);
        AssetQBuilder qb = qs.prepareQBuilder();
        String[] types = articles.stream().map(a -> a.traitType().getType()).toArray(String[]::new);
        QOp and = qb.and();
        and.add(qb.feature(Feature.Key.ASSET_TYPE, "IN" , types));
        and.add(qb.feature(Feature.Key.PRODUCTION_FLAG, "=" , "is-template"));
        and.add(
                qb.relation(QRelation.REL_DIRECTION_PARENT, "target.",
                        qb.and(
                                qb.feature(Feature.Key.ASSET_TYPE, "=", "channel."),
                                qb.and(qb.relation(QRelation.REL_DIRECTION_PARENT, "user.", qb.feature(Feature.Key.PRODUCTION_FLAG, "=" , "is-template")))
                        )
                )
        );


        QSelect query = qb.select().where(and);
        qs.queryAssets(query).forEach(assetList::add);

        List<PPTXData> pptxDataList = new ArrayList<>();

        assetList.forEach(asset -> {
            java.util.Optional<Asset> article = articles.stream().filter(a -> a.traitType().getType().equals(asset.traitType().getType())).findFirst();
            Asset pptSlide = getRelatedPptSlide(asset);
            if (pptSlide != null && article.isPresent()) {
                PPTXData pptxData = new PPTXData();
                pptxData.articleCopy = article.get();
                pptxData.pptxAssetId = pptSlide.getId();
                pptxData.textSize = getTextSizeInfo(asset);
                pptxDataList.add(pptxData);
            }
        });

        return pptxDataList;
    }


    private void cleanStepData(WizardModel.WizardStep step) {
        if (step.data == null) {
            step.setDataProperty("init", true);
        } else {
            step.data.removeAllChildNodes();
        }
    }

    private Asset getRelatedPptSlide(Asset asset) {
        return asset.asRelations(AssetRelation.RelationType.PLANNING)
                .getRelatedAssets()
                .first(slide -> slide.getType().getDBValue().equals("presentation.slide."));
    }

    private Asset getTargetGroupAsset() {
        Asset asset = null;
        if (getMode().equals(Mode.override)) {
            AssetRef assetRef =  AssetRef.fromString(getTargetGroup());
            try {
                asset = assetRef.get();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return asset;
    }

    private Mode getMode() {
        AXml step1Data = getStepData(TargetGroupSteps.chooseTargetGroup);
        String mode = step1Data.getAttr("mode", "");
        return Mode.get(mode);
    }

    private String getTargetGroup() {
        AXml step1Data = getStepData(TargetGroupSteps.chooseTargetGroup);
        return step1Data.getAttr("targetGroupRef", "");
    }

    private void setTargetGroup(Asset asset, Asset targetGroup) {
        try {
            context.executeAtomically(() -> {
                UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
                AtomicRef assetRef = repo.getAsset(asset.getId());
                Asset updatedAsset = assetRef.get();
                if (targetGroup != null) {
                    updatedAsset.properties().setProperty(TARGET_GROUP_PROPERTY, String.valueOf(targetGroup.getId()));
                }
                assetRef.set(updatedAsset);
                return assetRef;
            });
        } catch (Exception e) {
            logger.info("Failed to update Relation" + e.toString());
        }
    }

    private AXml getStepData(TargetGroupSteps step) {
        WizardModel.WizardStep s = getWizardModel().findStep(step.name());
        if (s != null && s.data != null) {
            return s.data;
        }
        return AXml.createElement("data");
    }

    private Asset getContextAsset() {
        String stringRef = getWizardModel().config.getAttr("self");
        return getAssetFromRef(stringRef);
    }

    private List<Asset> getSelectedChannel() {
        List<Asset> channelList = new ArrayList<>();
        for (AXml entry: getStepData(TargetGroupSteps.chooseMedia).findAll("selection")) {
            String stringRef = entry.getAttr("assetRef", "");
            if (AssetRef.isValidRef(stringRef)) {
                try {
                    Asset channel = AssetRef.fromString(stringRef).get();
                    channelList.add(channel);
                } catch (Exception e) {
                    logger.info("Failed to get Channel Asset from Ref" + e.toString());
                }
            }
        }
        //  Asset t= channelList.get(0);
        // channelList.set(0,channelList.get(1));
        // channelList.set(1,t);

        return channelList;
    }

    private Asset getAssetFromRef(String ref) {
        Asset asset = null;
        if (AssetRef.isValidRef(ref)) {
            try {
                asset = AssetRef.fromString(ref).get();
            } catch (Exception e) {
                logger.info("Failed to get Asset" + e.toString());
            }
        }
        return asset;
    }

    private Asset duplicate(Asset asset, String assetName) {
        return duplicate(asset, assetName, null, null);
    }

    // duplicate asset structure, copy master storage, delete asset flags, delete all relations
    private Asset duplicate(Asset asset, String assetName, Asset relAsset, AssetRelation.RelationType relationType){
        try {
            return context.executeAtomically(() -> {
                UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
                Template.AssetDuplicator duplicator = asset.asTemplate().getDuplicator();
                duplicator.setClearProductionFlags(true);
                duplicator.setHierarchical(false);
                Asset newAsset = duplicator.duplicate().get(0);
                newAsset.traitDisplay().setName(assetName);
                newAsset.asRelations().getRelations().copy().forEach(AssetRelation::delete);
                if (relAsset != null && relationType != null) {
                    newAsset.asRelations().createOrGetRelation(relAsset.getSelf(), relationType);
                }

                if (AssetType.ARTICLE.isMainTypeOf(asset.getType())) {
                    newAsset.traitWorkflow().setWorkflowAndStep(40, 10);
                } else if (AssetType.TEXT.isMainTypeOf(asset.getType())) {
                    newAsset.traitWorkflow().setWorkflowAndStep(10, 10);
                }

                AtomicRef atomicRef = repository.createNew(newAsset);
                Asset atomicAsset = atomicRef.get();

                atomicRef.checkInNew(atomicAsset);
                return atomicRef.get();
            });
        } catch (Exception e) {
            logger.info("Failed to duplicate Asset " +  asset.getSelf() + e.toString());
        }
        return null;
    }

    private void increaseVersionCount(Asset asset) {
        try {
            context.executeAtomically(() -> {
                UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
                AtomicRef atomicRef = repository.getAsset(asset.getId());
                atomicRef.checkIn(atomicRef.checkOut());
                return atomicRef.get();
            });
        } catch (Exception e) {
            logger.info("Failed to increase Version" + asset.getSelf());
        }

    }

    private List<Asset> relatedMediaComponents(List<Long> ids) throws TransactionException {
        List<Asset> assetList = new ArrayList<>();

        QueryService qs = Platform.getCCServiceEx(QueryService.class);
        AssetQBuilder qb = qs.prepareQBuilder();

        QOp and = qb.and();
        and.add(qb.feature(Feature.Key.ASSET_TYPE, "LIKE" , "article.%"));

        QOp or = qb.or();
        or.add(qb.relation(QRelation.REL_DIRECTION_PARENT, "user.", qb.feature(Feature.Key.ASSET_ID, "IN", ids.toArray())));
        or.add(qb.relation(QRelation.REL_DIRECTION_PARENT, "target.", qb.feature(Feature.Key.ASSET_ID, "IN", ids.toArray())));
        and.add(or);

        QSelect query = qb.select().where(and);
        qs.queryAssets(query).forEach(assetList::add);
        return assetList;
    }

    private Asset copyTextAsset(Asset text, Asset product) throws Exception {
        return context.executeAtomically(() -> {
            UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
            Template.AssetDuplicator duplicator = text.asTemplate().getDuplicator();
            Asset newAsset = duplicator.duplicate().get(0);
            String assetName = String.format("%s - %s", product.getName(), text.getName());
            newAsset.traitDisplay().setName(assetName);
            newAsset.properties().deleteProperties(AssetTraits.TypeTrait.DEF.assetFlag);
            AtomicRef atomicRef = repository.createNew(newAsset);
            Asset atomicAsset = atomicRef.get();
            atomicRef.checkInNew(atomicAsset);
            return atomicRef.get();
        });
    }

    private List<Asset> getRelatedTextAssets(Asset asset) {
        return asset
                .asRelations(AssetRelation.RelationType.MAIN_CONTENT)
                .getRelatedAssets().toList();
    }

    protected AllianzProductWizardApplication.Text getTextSizeInfo(Asset article) {
        List<AssetRelation>  rels=  article.asRelations(AssetRelation.RelationType.PLANNED_IN).getRelations().toList();

        for(AssetRelation ar:rels) {
            StringProperty sp =  ar.properties().getProperty(StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianzText"), "size"));
            if (sp != null) {
                // asset.asRelations(AssetRelation.RelationType.PLANNED_IN).getRelations().toList().get(4).getReferencedAsset().getResource().traitResourceAsset().getResourceKey()
                try {
                    if(ar.getReferencedAsset().getResource().traitResourceAsset().getResourceKey().equals(AllianzProductWizardApplication.POWERPOINT)
                            || ar.getReferencedAsset().getResource().traitResourceAsset().getResourceKey().equals(AllianzProductWizardApplication.POWERPOINTVSK)
                    ) {
                        String textSize=sp.getValue();
                        String textLabel =   textSize;// AllianzProductWizardApplication.getFeatureLabelOfTextSize(textSize);
                        return new AllianzProductWizardApplication.Text(article.getId(), article.getType().getDBValue(), textSize, textLabel);

                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        return null;
    }
}
