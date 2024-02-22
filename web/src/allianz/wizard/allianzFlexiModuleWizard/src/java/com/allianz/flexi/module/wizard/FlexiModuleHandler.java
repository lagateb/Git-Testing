package com.allianz.flexi.module.wizard;

import com.censhare.api.applications.SelfDescribingApplication;
import com.censhare.api.applications.wizards.AbstractWizardsApplication;
import com.censhare.api.applications.wizards.model.WizardModel;
import com.censhare.api.applications.wizards.model.WizardModel.WizardStep;
import com.censhare.model.logical.api.base.Property;
import com.censhare.model.logical.api.base.Trait;
import com.censhare.model.logical.api.domain.*;
import com.censhare.model.logical.api.domain.Template.AssetDuplicator;
import com.censhare.model.logical.api.properties.GenericProperty;
import com.censhare.model.logical.api.properties.StringProperty;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.server.support.api.CommandContext;
import com.censhare.server.support.api.impl.CommandAnnotations;
import com.censhare.server.support.api.impl.CommandAnnotations.CommandHandler;
import com.censhare.server.support.api.impl.CommandAnnotations.ScopeType;
import com.censhare.server.support.api.transaction.AtomicRef;
import com.censhare.server.support.api.transaction.UpdatingRepository;
import com.censhare.server.support.transformation.AssetTransformation;
import com.censhare.support.context.Platform;
import com.censhare.support.fj.IterableFj;
import com.censhare.support.service.ServiceContext;
import com.censhare.support.util.DataWrapper;
import com.censhare.support.xml.AXml;


import java.util.*;
import java.util.function.Predicate;

@CommandHandler(command = "com.allianz.flexi.module.wizard", scope = ScopeType.CONVERSATION)
public class FlexiModuleHandler extends AbstractWizardsApplication {

    private static final String TWO_PAGER_TEMPLATE_KEY = "svtx:indd.template.twopager.allianz";
    private static final String FLYER_BUB_TEMPLATE_KEY = "svtx:indd.template.bedarf_und_beratung.flyer.allianz";
    private static final Property.PropertyKey<Trait.GenericTrait, StringProperty> SNIPPET_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "web2print"), "layoutSnippet");
    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> TARGET_GROUP_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "category"), "targetGroup");
    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> COPY_OF_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "allianz"), "copyOf");
    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> ALIAS_NAME_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "svtx"), "aliasName");

    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> BS_TEMPLATE_PROPERTY = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "savotex"), "bsTemplate");
    public static final Property.PropertyKey<Trait.GenericTrait, StringProperty> FAQ_MEDIA = StringProperty.createKey(new Trait.TraitKey<>(Trait.GenericTrait.class, "modulFaq"), "medium");

    public static final AssetRelation.RelationType SNIPPET_REL = AssetRelation.RelationType.valueOf("user.layout.", AssetRelation.Direction.CHILD);

    private static Asset TWO_PAGER_TEMPLATE = null;
    private static Asset FLYER_BUB_TEMPLATE = null;

    private AXml moduleConfigXml;

    private AssetRef contextAssetRef;
    private Asset contextAsset;
    private String newAssetDomain;

    //private static final String FAQ_RESOURCE_KEY = "svtx:optional-modules.faq";
    private static final String FAQ_ASSET_TYPE = "article.optional-module.faq.";

    public enum FlexiModuleSteps {
        flexiModuleChooseProduct,
        flexiModuleChooseType,
        flexiModuleChooseModule,
        flexiModuleChooseSettings,
        flexiModuleOverview;

        public boolean isStep(WizardStep step) {
            return step != null && step.name.equals(this.name());
        }
    }


    @Override
    protected void initWizardData(WizardModel wizard) {
        logger.info("### INIT WIZARD " + wizard);
        // if wizard got called on a context asset, then skip step 1
        if (wizard.hasConfigProperty("self")) {
            String ref = wizard.config.getAttr("self");
            if (AssetRef.isValidRef(ref)) {
                this.contextAssetRef = AssetRef.fromString(ref);
                WizardStep chooseProduct = wizard.findStep(FlexiModuleSteps.flexiModuleChooseProduct.name());
                WizardStep chooseModule = wizard.findStep(FlexiModuleSteps.flexiModuleChooseType.name());
                WizardStep chooseSettings = wizard.findStep(FlexiModuleSteps.flexiModuleChooseSettings.name());
                if (chooseProduct != null && chooseModule != null) {
                    wizard.moveCurrentStep(chooseModule.index);
                    wizard.removeStep(chooseProduct);
                    /*wizard.removeStep(chooseSettings);*/
                }

                try {
                    Asset contextAsset = this.contextAssetRef.get();
                    this.newAssetDomain = contextAsset.traitDomain().getDomainId();
                    this.contextAsset = contextAsset;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        try {
            TWO_PAGER_TEMPLATE = AssetRef.createResourceRef(TWO_PAGER_TEMPLATE_KEY).get();
            FLYER_BUB_TEMPLATE = AssetRef.createResourceRef(FLYER_BUB_TEMPLATE_KEY).get();
        } catch (Exception e) {
            logger.info("### Cant Query Layout Template with key " + TWO_PAGER_TEMPLATE_KEY + e);
        }
    }

    @Override
    protected boolean beforeStepAction(WizardStepAction action, WizardStep step){
        logger.info("### LEAVE STEP  ENTER STEP " + step);
        return true;
    }

    @Override
    protected boolean afterStepAction(WizardStepAction action, WizardStep step) throws Exception {
        logger.info("### LEAVE STEP " + step);
        // if first step and chosen type is not free module, disable template setting step
        if (FlexiModuleSteps.flexiModuleChooseType.isStep(step)) {
            // check type
            AXml stepData = getStepData(FlexiModuleSteps.flexiModuleChooseType);
            String s = "da";
        }
        return true;
    }

    @Override
    protected boolean onCancel() {
        logger.info("### CANCEL");
        return true;
    }

    @Override
    protected void addMethods(Set<String> methods) {
        methods.add("getAvailableTargetGroups");
    }

    @CommandAnnotations.Execute
    public SelfDescribingApplication.SelfDescribingApplicationData getAvailableTargetGroups(CommandContext context) throws Exception {
        List<Asset> variants = getLayout2PagerVariants();
        AXml result = AXml.createElement("result");

        variants.forEach(asset -> {
            StringProperty prop = asset.properties().getProperty(TARGET_GROUP_PROPERTY);
            if (prop != null) {
                long id = Long.parseLong(prop.getValue());
                AssetRef assetRef = AssetRef.createUnversioned(id);
                try {
                    Asset targetGroup = assetRef.get();

                    AXml targetGroupNode = AXml.createElement("targetGroup");
                    targetGroupNode.appendAttribute("name", targetGroup.getName());
                    targetGroupNode.appendAttribute("id", targetGroup.getId());
                    targetGroupNode.appendAttribute("layout", asset.getId());

                    result.appendChild(targetGroupNode);

                } catch (Exception e) {
                    logger.info("Fail" + e.toString());
                }



            }
            // target group name
            // target group id
            // layout id
        });

        result.appendAttribute("test", "true");

        return success(result);
    }

    protected void addProperty(Asset asset, String traitName, String popertyName, Object data) throws Exception {
        context.executeAtomically(() -> {
            UpdatingRepository repo = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef assetRef = repo.getAsset(asset.getSelf());
            addProperty(assetRef,traitName,popertyName,data);
            return assetRef;
        });
    }

    protected void addProperty(AtomicRef assetRef, String traitName, String popertyName, Object data) throws Exception {
        Asset newAsset = assetRef.get();
        newAsset.trait(traitName).setProperty(popertyName,data);
        assetRef.set(newAsset);
    }

    protected AtomicRef duplicatePPTXSlide(Asset pptxSlideAsset,AtomicRef articleRef) {
        return duplicatePPTXSlide(pptxSlideAsset, articleRef,true) ;
    }

    protected AtomicRef duplicatePPTXSlide(Asset pptxSlideAsset,AtomicRef articleRef,boolean withPlanningRelation) {
        try {
            AtomicRef copyRef = context.executeAtomically(() -> {
                UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
                AssetDuplicator duplicator = pptxSlideAsset.asTemplate().getDuplicator();
                Asset newAsset = duplicator.duplicate().get(0);
                String assetName = String.format("%s - %s", getContextAssetName(), pptxSlideAsset.getName());
                newAsset.traitDisplay().setName(assetName);
                AtomicRef atomicRef = repository.createNew(newAsset);
                Asset atomicAsset = atomicRef.get();

                // presentation.asRelations(AssetRelation.RelationType.TARGET).getRelations().toList().size()


                AssetRelation rel= atomicAsset.asRelations(AssetRelation.RelationType.PLANNED_IN).createOrGetRelation(articleRef);
                if(withPlanningRelation) {
                    atomicAsset.asRelations(AssetRelation.RelationType.PLANNING).createOrGetRelation(articleRef);
                }
                // Source-PPTX Resourcekey als layoutTemplateResourceKey setzen
                pptxSlideAsset.properties().getAllFeatureProperties(). forEach(p->{
                    if (p.getInfo().getFeatureKey().equals("censhare:resource-key")){
                        try {
                            addProperty(atomicRef,"allianz","layoutTemplateResourceKey",p.getValue());
                        }  catch (Exception e) {
                            logger.info(e.toString());
                        }
                    }
                });

                atomicRef.checkInNew(atomicAsset);
                return atomicRef;
            });
            return copyRef;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    protected AtomicRef createDuplicate(Asset asset,Asset presentation,AtomicRef artikelRef) {
        try {
            AtomicRef copyRef = context.executeAtomically(() -> {
                UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
                AssetDuplicator duplicator = asset.asTemplate().getDuplicator();
                Asset newAsset = duplicator.duplicate().get(0);
                String assetName = String.format("%s - %s", getContextAssetName(), asset.getName());
                newAsset.traitDisplay().setName(assetName);
                AtomicRef atomicRef = repository.createNew(newAsset);
                Asset atomicAsset = atomicRef.get();
                int sortNumber = (int) presentation.asRelations(AssetRelation.RelationType.TARGET).getRelations().toList().size();
                // presentation.asRelations(AssetRelation.RelationType.TARGET).getRelations().toList().size()
                AssetRelation rel= atomicAsset.asRelations(AssetRelation.RelationType.PLANNED_IN).createOrGetRelation(presentation.getRefUnversioned());
                atomicAsset.asRelations(AssetRelation.RelationType.PLANNING).createOrGetRelation(artikelRef);
                if(sortNumber>=0) {
                    sortNumber++;
                    rel.traitSortable().setSorting(sortNumber);
                }
                // Source-PPTX Resourcekey als layoutTemplateResourceKey setzen
                asset.properties().getAllFeatureProperties(). forEach(p->{
                    if (p.getInfo().getFeatureKey().equals("censhare:resource-key")){
                        try {
                            addProperty(atomicRef,"allianz","layoutTemplateResourceKey",p.getValue());
                        }  catch (Exception e) {
                            logger.info(e.toString());
                        }
                    }
                });
                // Von presentation den layoutTemplateResourceKey übernehmen
                presentation.properties().getAllFeatureProperties(). forEach(p->{
                    if (p.getInfo().getFeatureKey().equals("svtx:text-variant-type")){
                        try {
                            addProperty(atomicRef,"allianzTextVariantType","textVariantType",p.getValue());
                        }  catch (Exception e) {
                            logger.info(e.toString());
                        }
                    }
                });
                if (newAssetDomain != null) {
                    atomicAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
                }

                atomicRef.checkInNew(atomicAsset);
                return atomicRef;
            });
            return copyRef;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

    }

    protected void temp (Asset product, AtomicRef articleRef, Asset pptx) {
        if (pptx != null) {
            product.asRelations(AssetRelation.RelationType.ASSIGNMENT).getRelatedAssets().forEach(
                    asset -> {
                        if(asset.getType().isMainTypeOf("presentation.issue.")) {
                            AtomicRef pptxRef = createDuplicate(pptx,asset,articleRef);
                            if(pptxRef != null) {
                                logger.info("#### PPTX angelegt:"+pptx.getId());
                            }
                        }
                    }
            );
        }
    }

    // Alle ChildAsset rel (Zuordnung mit
    // vom Produkt alle childs presentation.issue.
    // Kopie der Powerpoint anhängen sorting = max+1
    // An die Powerpoint ein rel   key="target." zu artikel
    protected  void copyPPTXData(  Asset product,AtomicRef artikelRef,Asset template)  throws Exception {
        startProgress("Powerpoint-Dateien werden aktualisiert");
        Asset pptx = template.asRelations(AssetRelation.RelationType.TARGET).getRelatedAssets().first();
        if(pptx != null) {
            product.asRelations(AssetRelation.RelationType.ASSIGNMENT).getRelatedAssets().forEach(
                    asset -> {
                        if(asset.getType().isMainTypeOf("presentation.issue.")) {
                            AtomicRef pptxRef = createDuplicate(pptx,asset,artikelRef);
                            if(pptxRef != null) {
                                logger.info("#### PPTX angelegt:"+pptx.getId());
                            }
                        }
                    }
            );
        } else {
            logger.info("#### Keine PPTX vorhanden");
        }
        stopProgress();
    }

    /**
     * Hier wird dann das TargetgroupSlide gesucht und dort werden dann die Daten abgelegt
     * Relation variant. id=Taregtgroupd.id
     * @param product
     * @param artikelRef
     * @param template
     * @param targetGroup
     * @throws Exception
     */
    protected  void copyPPTXData(  Asset product,AtomicRef artikelRef,Asset template,Asset targetGroup)  throws Exception {
        startProgress("Powerpoint-Dateien für "+targetGroup.getName()+" werden aktualisiert");
        Asset pptx = template.asRelations(AssetRelation.RelationType.TARGET).getRelatedAssets().first();
        if(pptx != null) {
            product.asRelations(AssetRelation.RelationType.ASSIGNMENT).getRelatedAssets().forEach(
                    asset -> {
                        if(asset.getType().isMainTypeOf("presentation.issue.")) {
                            // Hier die Relation (Variant) zur Zielvariante suchen
                            asset.asRelations(AssetRelation.RelationType.VARIANT).getRelatedAssets().forEach(
                                    vasset -> {
                                        // Hat eine Zielgruppe und enspricht der Gesuchten
                                        if(vasset.properties().getProperty(TARGET_GROUP_PROPERTY).exist() &&
                                                vasset.properties().getProperty("category","targetGroup").asLong() == targetGroup.getId()
                                        ) {
                                            AtomicRef pptxRef = createDuplicate(pptx, vasset, artikelRef);
                                            if (pptxRef != null) {
                                                logger.info("#### PPTX angelegt:" + pptx.getId());
                                            }
                                        }
                                    }
                            );
                        }
                    }
            );
        } else {
            logger.info("#### Keine PPTX vorhanden");
        }
        stopProgress();
    }

    /**
     * ist das Asset vom Typ FAQ_ASSET_TYPE?
     * @param ref
     * @return
     * @throws Exception
     */
    private  boolean isFAQTemplate(String ref) throws Exception {
        Asset templateAsset = AssetRef.fromString(ref).get();
        return templateAsset.getType().getDBValue().equals(FAQ_ASSET_TYPE);
    }


    @Override
    protected Object onFinish() throws Exception {
        AXml chooseModuleData = getStepData(FlexiModuleSteps.flexiModuleChooseModule);
        AXml chooseTypeData = getStepData(FlexiModuleSteps.flexiModuleChooseType);
        AXml chooseSettingsData = getStepData(FlexiModuleSteps.flexiModuleChooseSettings);
        moduleConfigXml = chooseSettingsData.findX("config");

        String type = chooseTypeData.getAttr("moduleType", "");
        if (type.isEmpty() || AssetType.valueOf(type).getDBValue().isEmpty()) {
            return fail("Invalid Module Asset Type! " + type);
        }

        if("article.flexi-module.".equals(type)) {
            String ref = chooseModuleData.getAttr("templateRef", "");
            if (ref.isEmpty() || !AssetRef.isValidRef(ref)) {
                return fail("Invalid Asset Ref for Template! " + ref);
            }
            String productName = contextAsset != null ? contextAsset.getName() : "";
            String templateName = "Flexi Modul";
            try {
                Asset flexiTemplate = AssetRef.fromString(ref).get();
                templateName = flexiTemplate.getName();
            } catch (Exception e) {
                logger.info(e.getMessage());
            }
            String newModuleName = templateName;
            return createNewAsset(newModuleName,type,ref);
        }
        else if( type.startsWith("article.optional-module.")){
            //  logger.info(">>>>INFO"+ chooseModuleData.findAllX("//optionalArray/value"));
            for(AXml optionalXml: chooseModuleData.findAllX("//optionalArray/value")){
                String name = optionalXml.getAttr("display_value", "");
                if (name.isEmpty()) {
                    return fail("Invalid Module Name! " + name);
                }
                String ref = optionalXml.getAttr("value", "");
                if (ref.isEmpty() || !AssetRef.isValidRef(ref)) {
                    return fail("Invalid Asset Ref for Template! " + ref);
                }

                if(isFAQTemplate(ref)) {
                    createNewFAQAsset(name,ref);
                } else {
                    createNewAsset(name, type, ref);
                }
            }
        } else if ("article.free-module.".equals(type)) {
            // copy text
            // copy pptx
            // add to current product
            String ref = chooseModuleData.getAttr("templateRef", "");
            if (ref.isEmpty() || !AssetRef.isValidRef(ref)) {
                return fail("Invalid Asset Ref for Template! " + ref);
            }
            String productName = contextAsset != null ? contextAsset.getName() : "";
            String templateName = "Freies Modul";
            try {
                Asset flexiTemplate = AssetRef.fromString(ref).get();
                templateName = flexiTemplate.getName();
            } catch (Exception e) {
                logger.info(e.getMessage());
            }
            String newModuleName = templateName;
            return createNewAsset(newModuleName,type,ref);
        }
        return null;
    }

    /**
     * Erzeugt eine article.optional-module.faq Modul in einem Produkt
     * Im Gegensatz zu allen anderen Artikeln hat dieses kein Text-Asset, da alle Infos im Artikel stecken
     * @param name
     * @param ref
     * @return
     * @throws Exception
     */
    private Object createNewFAQAsset(String name, String ref) throws Exception {
        Asset templateAsset = AssetRef.fromString(ref).get();
        Asset product = this.contextAssetRef.get();
        Asset mainContent = templateAsset.asRelations(AssetRelation.RelationType.MAIN_CONTENT).getRelatedAssets().first();

        // Kopie vom Text-Asset anlegen
        String textCopyName = String.format("%s - %s", getContextAssetName(), mainContent.getName());
        AtomicRef textRef = copyFAQTextAsset(mainContent, textCopyName);

        String articleName = String.format("%s - %s", getContextAssetName(), name);
        Map<AssetRelation.RelationType, AssetRef> relationMapping = new HashMap<>();
        // ProduktRelation
        relationMapping.put(AssetRelation.RelationType.ASSIGNED_IN, this.contextAssetRef);


        relationMapping.put(AssetRelation.RelationType.MAIN_CONTENT, textRef);

        // PPTX-Vorlage
        Asset pptx = templateAsset.asRelations(AssetRelation.RelationType.TARGET).getRelatedAssets().first();
        // ArticleAsset Anlegen
        AtomicRef articleRef = createArticleFAQAsset(articleName, relationMapping);
        // Und PPTX. ArticleAsset=planning=>pptx Da diese anders ablaufen als der Standard
        AtomicRef pptxRef = duplicatePPTXSlide(pptx,articleRef,false);

        // createPPTXRelations(textRef);
        return openDefaultAssetPage(articleRef.get());
    }


    private AtomicRef copyFAQTextAsset(Asset asset, String name) throws Exception {
        return context.executeAtomically(() -> {
            UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
            AssetDuplicator duplicator = asset.asTemplate().getDuplicator();
            duplicator.setClearProductionFlags(true);
            Asset newAsset = duplicator.duplicate().get(0);
            newAsset.traitDisplay().setName(name);
            AtomicRef atomicRef = repository.createNew(newAsset);
            Asset atomicAsset = atomicRef.get();
            if (newAssetDomain != null) {
                atomicAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
            }
            this.contextAsset.asRelations(AssetRelation.RelationType.ASSIGNMENT).getRelatedAssets().forEach(
                    relAsset -> {
                        if (relAsset.getType().getDBValue().startsWith("presentation.issue.")) {
                            try {
                                //addProperty(atomicAsset,"modulFaq","medium",relAsset.getId());
                                //atomicAsset.trait("modulFaq").setProperty("medium",relAsset.getId());
                                //atomicAsset.properties().setProperty(FAQ_MEDIA, String.valueOf(relAsset.getId()));
                                atomicAsset.properties().createProperty(FAQ_MEDIA).setValue(String.valueOf(relAsset.getId()));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }

            );

            atomicRef.checkInNew(atomicAsset);

            return atomicRef;
        });
    }

    // für allen PPTX-Issues wird eine Property gesetzt
    private void createPPTXRelations(AtomicRef textRef) throws Exception {
        context.executeAtomically(() -> {
            UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
            //Asset checkoutAsset = repository.checkOut(textRef);
            AtomicRef arFAQText = repository.getAsset(textRef.getAssetId());
            Asset atomicAsset = arFAQText.get();
            this.contextAsset.asRelations(AssetRelation.RelationType.ASSIGNMENT).getRelatedAssets().forEach(
                    relAsset -> {
                        if (relAsset.getType().getDBValue().startsWith("presentation.issue.")) {
                            try {
                                //addProperty(atomicAsset,"modulFaq","medium",relAsset.getId());
                                atomicAsset.trait("modulFaq").setProperty("medium",relAsset.getId());

                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }

            );
            arFAQText.checkIn(atomicAsset);
            return arFAQText;
        });
    }


    private Object createNewAsset(String name, String type, String ref) throws Exception {

        AXml chooseModuleData = getStepData(FlexiModuleSteps.flexiModuleChooseModule);
        AXml chooseTypeData = getStepData(FlexiModuleSteps.flexiModuleChooseType);

        /*boolean hasFlexi = chooseModuleData.getAttr()*/
        boolean hasFlexiModule = chooseModuleData.getAttrBoolean("hasFlexiModule", false);

        Asset templateAsset = AssetRef.fromString(ref).get();
        Asset mainContent = templateAsset.asRelations(AssetRelation.RelationType.MAIN_CONTENT).getRelatedAssets().first();
        Asset product = this.contextAssetRef.get();

        // get layout snippets
        // prepare to update the layout
        /*String layoutSnippetId = templateAsset.properties().getProperty("web2print", "layoutSnippet").asString();*/

        Asset snippet = templateAsset.asRelations(SNIPPET_REL).getRelatedAssets(assetRelation -> {
            Object forTemplateProp = assetRelation.properties().getProperty("allianz","layoutTemplateResourceKey").getValue();
            String forTemplate = forTemplateProp != null ? forTemplateProp.toString() : "";
            if (product.getType().getDBValue().equals("product.needs-and-advice.")) {
                return Objects.equals(forTemplate, FLYER_BUB_TEMPLATE_KEY);
            } else {
                return !Objects.equals(forTemplate, FLYER_BUB_TEMPLATE_KEY);
            }
        }).filter(asset -> asset.getType().equals(AssetType.LAYOUT_SNIPPET)).first();

        String layoutSnippetId = snippet != null ? String.valueOf(snippet.getId()) : null;


        logger.info("#### SNIPPET ID ===" + layoutSnippetId);

        if (mainContent == null) {
            return fail("No Main Content Asset found for " + templateAsset.getId());
        }




        if ("article.free-module.".equals(type)) {

            logger.info("article.free-module. condition");

            AXml chooseSettingsData = getStepData(FlexiModuleSteps.flexiModuleChooseSettings);
            String moduleName = chooseSettingsData.getAttr("moduleName", "");
            String textCopyName = String.format("%s - %s", getContextAssetName(), mainContent.getName());
            AtomicRef textRef = copyTextAsset(mainContent, textCopyName, moduleName);
            String articleName = getContextAssetName();
            if (!moduleName.isEmpty()) {
                articleName = String.format("%s - %s", articleName, moduleName);
            }
            Map<AssetRelation.RelationType, AssetRef> relationMapping = new HashMap<>();
            relationMapping.put(AssetRelation.RelationType.ASSIGNED_IN, this.contextAssetRef);
            relationMapping.put(AssetRelation.RelationType.MAIN_CONTENT, textRef);
            AtomicRef articleRef = createArticleAsset(articleName, type, null, relationMapping, templateAsset, moduleName);

            // todo: choose module data => choose module settings
            AXml pptxTemplateData = chooseSettingsData.find("pptxSlide");
            if (pptxTemplateData != null) {
                String assetRefStr = pptxTemplateData.getAttr("ref");
                if (AssetRef.isValidRef(assetRefStr)) {
                    AssetRef pptxTemplateRef = AssetRef.fromString(assetRefStr);
                    Asset pptxTemplate = pptxTemplateRef.get();
                    temp(product, articleRef, pptxTemplate);
                }
                copyPPTXData(product,articleRef,templateAsset);
            }


        } else if (!hasFlexiModule || "article.optional-module.".equals(type)) {


            logger.info("!hasFlexiModule || article.optional-module. condition");
            /*
             *
             * Modus für Basis FlexiModul
             *
             * */


            // copy main content asset
            /*AtomicRef textRef = context.executeAtomically(() -> {
                UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
                AssetDuplicator duplicator = mainContent.asTemplate().getDuplicator();
                Asset newAsset = duplicator.duplicate().get(0);
                String assetName = String.format("%s - %s", getContextAssetName(), mainContent.getName());
                newAsset.traitDisplay().setName(assetName);
                AtomicRef atomicRef = repository.createNew(newAsset);
                Asset atomicAsset = atomicRef.get();
                atomicRef.checkInNew(atomicAsset);
                return atomicRef;
            });*/

            String textCopyName = String.format("%s - %s", getContextAssetName(), mainContent.getName());
            AtomicRef textRef = copyTextAsset(mainContent, textCopyName);


            // create new module
            /*AtomicRef articleRef = context.executeAtomically(() -> {
                UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
                String moduleName = String.format("%s - %s", getContextAssetName(), name);
                AtomicRef atomicRef = repository.createNew(moduleName, AssetType.valueOf(type));
                Asset atomicAsset = atomicRef.get();
                atomicAsset.properties().setProperty(SNIPPET_PROPERTY, layoutSnippetId);
                atomicAsset.asRelations(AssetRelation.RelationType.ASSIGNED_IN).createOrGetRelation(this.contextAssetRef);
                atomicAsset.asRelations(AssetRelation.RelationType.MAIN_CONTENT).createOrGetRelation(textRef);
                atomicRef.checkInNew(atomicAsset);
                return atomicRef;
            });*/

            String articleName = String.format("%s - %s", getContextAssetName(), name);
            Map<AssetRelation.RelationType, AssetRef> relationMapping = new HashMap<>();
            relationMapping.put(AssetRelation.RelationType.ASSIGNED_IN, this.contextAssetRef);
            relationMapping.put(AssetRelation.RelationType.MAIN_CONTENT, textRef);
            AtomicRef articleRef = createArticleAsset(articleName, templateAsset.getType().getDBValue(), layoutSnippetId, relationMapping, templateAsset);

            java.util.Optional<Asset> layout = product
                    .asRelations(AssetRelation.RelationType.ASSIGNMENT)
                    .getRelatedAssets()
                    .toList()
                    .stream()
                    .filter(isSnippetLayout())
                    .findFirst();

            logger.info("Flexi Module Handler layoutSnippetId " + layoutSnippetId);
            layout.ifPresent(asset -> logger.info("Flexi Module Handler layout is present " + asset.getId()));

            if (layout.isPresent() && layoutSnippetId != null) {
                startProgress("Layout wird aktualisiert");
                context.execute(() -> {
                    DBTransactionManager tm = Platform.getCCServiceEx(DBTransactionManager.class);
                    String transformationKey = "svtx:two_pager.render.snippet";
                    Object layoutKey = layout.get().properties().getProperty("allianz","layoutTemplateResourceKey").getValue();
                    if (layoutKey != null && layoutKey.toString().equals(FLYER_BUB_TEMPLATE_KEY)) {
                        transformationKey = "svtx:flyer.render.snippet";
                    }
                    logger.info("Flexi Module Handler place script  " + transformationKey);

                    AssetTransformation assetTransformation = new AssetTransformation(tm, transformationKey);
                    // add transformation parameters
                    assetTransformation.setParamObject(ServiceContext.PROPERTY_TM, tm);
                    assetTransformation.setParamObject("snippetId", layoutSnippetId);
                    assetTransformation.setParamObject("placeAssetId", articleRef.get().getId());
                    // Execute the transformation
                    DataWrapper transformationResult = assetTransformation.transform(layout.get().toLegacyXml().getDocumentNode());
                    return transformationResult.asXML();
                });
                stopProgress();
            }
            copyPPTXData(product,articleRef,templateAsset);
            return openDefaultAssetPage(articleRef.get());
        } else {

            logger.info("last condition");
            /*
             *
             * Modus für Zielgruppen
             *
             * */

            Asset flexiModule = product.asRelations().getRelatedAssets().filter(a -> a.getType().getDBValue().startsWith("article.flexi-module.")).first();
            List <Asset> layoutVariants = getLayout2PagerVariants();

            chooseModuleData.findAllX("targetGroups[@selected='true' and @disabled='false']").forEach(entry -> {
                String stringRef = entry.getAttr("value", "");
                long targetGroupId = entry.getAttrLong("target_group", -1);
                long layoutId = entry.getAttrLong("layout", -1);
                AssetRef targetGroupRef = AssetRef.createUnversioned(targetGroupId);
                AssetRef layoutRef = AssetRef.createUnversioned(layoutId);

                try {
                    Asset targetGroup = targetGroupRef.get(); // target group
                    String textCopyName =  String.format("%s - %s - %s", getContextAssetName(), mainContent.getName(), targetGroup.getName());
                    AssetRef textCopyRef = copyTextAsset(mainContent, textCopyName);

                    String articleName = String.format("%s - %s - %s", getContextAssetName(), name, targetGroup.getName());
                    Map<AssetRelation.RelationType, AssetRef> relationMapping = new HashMap<>();
                    relationMapping.put(AssetRelation.RelationType.MAIN_CONTENT, textCopyRef);
                    relationMapping.put(AssetRelation.RelationType.VARIANT_OF, flexiModule.getSelf());
                    AtomicRef articleRef = createArticleAsset(articleName, type, layoutSnippetId, relationMapping, templateAsset, targetGroup.getId());


                    Asset layout = layoutRef.get();
                    // Wir müssen jetzt das Neue Flex-Layout in die Zielgruppen kopieren
                    copyPPTXData(product,articleRef,templateAsset,targetGroup);

                    if (layout != null && layoutSnippetId != null) {
                        startProgress("Layout wird aktualisiert");
                        context.execute(() -> {
                            DBTransactionManager tm = Platform.getCCServiceEx(DBTransactionManager.class);
                            AssetTransformation assetTransformation = new AssetTransformation(tm, "svtx:two_pager.render.snippet");
                            // add transformation parameters
                            assetTransformation.setParamObject(ServiceContext.PROPERTY_TM, tm);
                            assetTransformation.setParamObject("snippetId", layoutSnippetId);
                            assetTransformation.setParamObject("placeAssetId", articleRef.get().getId());
                            // Execute the transformation
                            DataWrapper transformationResult = assetTransformation.transform(layout.toLegacyXml().getDocumentNode());
                            return transformationResult.asXML();
                        });
                        stopProgress();
                    }


                } catch (Exception e) {
                    logger.info("Failed to get Asset for" + targetGroupRef);
                }


                //copy text

                //create custom Flexi Module

            });


        }
        return success();
    }

    private List<Asset> getLayout2PagerVariants() throws Exception {
        List<Asset> variants = new ArrayList<>();
        Asset product = contextAssetRef.get();
        Asset baseLayout = product.asRelations().getRelatedAssets().filter(a-> {
            if (a.getType().getDBValue().startsWith("layout.")) {
                GenericProperty p = a.properties().getProperty("allianz", "layoutTemplateResourceKey");
                return p != null && p.getValue().equals("svtx:indd.template.twopager.allianz");
            }
            return false;
        }).first();
        if (baseLayout != null) {
            baseLayout.asRelations(AssetRelation.RelationType.VARIANT).getRelatedAssets().forEach(v -> {
                StringProperty p = v.properties().getProperty(TARGET_GROUP_PROPERTY);
                if (p != null) {
                    variants.add(v);
                }
            });
        }
        return variants;
    }

    private SelfDescribingApplication.SelfDescribingApplicationData fail(String msg) throws Exception {
        return failure(new ErrorInfo("FlexiModuleWizard", msg));
    }

    private AXml getStepData(FlexiModuleSteps step) {
        WizardStep wizardStep = getWizardModel().findStep(step.name());
        if (wizardStep != null && wizardStep.data != null) {
            return wizardStep.data;
        }
        return AXml.createElement("data");
    }

    private String getContextAssetName() {
        String result = "";
        try {
            result = contextAssetRef.get().getName();
        } catch (Exception e) {
            logger.info("Failed to get Asset Name" + e);
        }
        return result;
    }

    public static Predicate<Asset> isSnippetLayout() {
        return asset -> {
            if (asset.getType().isMainTypeOf(AssetType.LAYOUT) && TWO_PAGER_TEMPLATE != null && FLYER_BUB_TEMPLATE != null) {
                long originalTemplateId = asset.properties().getProperty("allianz", "layoutTemplate").asLong(0);
                return originalTemplateId == TWO_PAGER_TEMPLATE.getId() || originalTemplateId == FLYER_BUB_TEMPLATE.getId();
            }
            return false;
        };
    }

    private AtomicRef copyTextAsset(Asset asset, String name, String aliasName) throws Exception {
        return context.executeAtomically(() -> {
            UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
            AssetDuplicator duplicator = asset.asTemplate().getDuplicator();
            duplicator.setClearProductionFlags(true);
            Asset newAsset = duplicator.duplicate().get(0);
            newAsset.traitDisplay().setName(name);

            if (moduleConfigXml != null) {
                String moduleType = moduleConfigXml.getAttr("moduleType", "");
                if (Arrays.asList("imageorvideo", "flexibletile", "text", "textandimage").contains(moduleType)) {
                    HashMap<String,Object> params = new HashMap<>();
                    AXml imageInsertionNode = moduleConfigXml.find("imageInsertion");
                    if (imageInsertionNode != null) {
                        params.put("image-insert", imageInsertionNode.getAttr("value", "none"));
                    }
                    AXml tileCountNode = moduleConfigXml.find("columnCount");
                    if (tileCountNode != null) {
                        params.put("tile-count", tileCountNode.getAttrLong("value",2));
                    }
                    AXml showLinkNode = moduleConfigXml.find("showLink");
                    if (showLinkNode != null) {
                        params.put("use-link", showLinkNode.getAttrBoolean("value", false));
                    }
                    AXml showTextNode = moduleConfigXml.find("showText");
                    if (showTextNode != null && moduleType.equals("imageorvideo")) {
                        params.put("use-body", showTextNode.getAttrBoolean("value", true));
                    }
                    switch (moduleType) {
                        case "text":
                            params.put("use-picture", false);
                            break;
                        case "textandimage":
                        case "imageorvideo":
                            params.put("use-picture", true);
                            break;
                    }
                    if (params.size() > 0) {
                        AXml result = flexibleTileContent(asset, params);
                        newAsset.asStorages().getMasterStorageItem().attachDataAsXml(result);
                        StorageItem textPreview = newAsset.asStorages().getStorageItem(StorageItem.StorageItemType.TEXTPREVIEW);
                        if (textPreview != null) {
                            textPreview.delete();
                        }
                    }
                }
            }
            newAsset.properties().createProperty(COPY_OF_PROPERTY).setValue(String.valueOf(asset.getId()));

            if (aliasName != null && !aliasName.isEmpty()) {
                newAsset.properties().createProperty(ALIAS_NAME_PROPERTY).setValue(aliasName);
            }

            // Duplicator übernimmt die funktionalität
            /*StringProperty bsTemplateProperty = asset.properties().getProperty(BS_TEMPLATE_PROPERTY);
            if (bsTemplateProperty != null && bsTemplateProperty.getValue() != null) {
                newAsset.properties().createProperty(BS_TEMPLATE_PROPERTY).setValue(bsTemplateProperty.getValue());
            }*/

            AtomicRef atomicRef = repository.createNew(newAsset);
            Asset atomicAsset = atomicRef.get();
            if (newAssetDomain != null) {
                atomicAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
            }
            atomicRef.checkInNew(atomicAsset);
            return atomicRef;
        });
    }

    private AtomicRef copyTextAsset(Asset asset, String name) throws Exception {
        return copyTextAsset(asset,name,null);
    }

    private AXml flexibleTileContent (Asset ctxAsset, HashMap<String, Object> params) throws Exception {
        DBTransactionManager tm = Platform.getCCServiceEx(DBTransactionManager.class);
        AssetTransformation assetTransformation = new AssetTransformation(tm, "svtx:flexible-tiles.format-content");
        // add transformation parameters
        params.forEach(assetTransformation::setParamObject);
        assetTransformation.setParamObject(ServiceContext.PROPERTY_TM, tm);
        // Execute the transformation
        DataWrapper transformationResult = assetTransformation.transform(ctxAsset.toLegacyXml().getDocumentNode());
        return transformationResult.asXML();
    }

    private AtomicRef createArticleFAQAsset(String name,  Map<AssetRelation.RelationType, AssetRef> relations) throws Exception  {

/*
        AssetRelation rel= atomicAsset.asRelations(AssetRelation.RelationType.PLANNED_IN).createOrGetRelation(presentation.getRefUnversioned());
        atomicAsset.asRelations(AssetRelation.RelationType.PLANNING).createOrGetRelation(artikelRef);
        if(sortNumber>=0) {
            sortNumber++;
            rel.traitSortable().setSorting(sortNumber);
        }
*/


        return context.executeAtomically(() -> {
            UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef atomicRef = repository.createNew(name, AssetType.valueOf(FAQ_ASSET_TYPE));

            Asset atomicAsset = atomicRef.get();

            // Setzen der Relationen
            relations.forEach((rel , ref) -> {
                AssetRelation arel=   atomicAsset.asRelations(rel).createOrGetRelation(ref);
                // TextAsset hat Sortable Attribut
                if(rel.equals(AssetRelation.RelationType.MAIN_CONTENT)) {
                    arel.traitSortable().setSorting(1);
                }
            });


            if (newAssetDomain != null) {
                atomicAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
            }

            atomicRef.checkInNew(atomicAsset);
            return atomicRef;
        });
    }

    private AtomicRef createArticleAsset(String name, String type, String layoutSnippetId, Map<AssetRelation.RelationType, AssetRef> relations, Asset srcAsset) throws Exception {
        return createArticleAsset(name, type, layoutSnippetId, relations, srcAsset,null, null);
    }

    private AtomicRef createArticleAsset(String name, String type, String layoutSnippetId, Map<AssetRelation.RelationType, AssetRef> relations, Asset srcAsset, String aliasName) throws Exception {
        return createArticleAsset(name, type, layoutSnippetId, relations, srcAsset,null, aliasName);
    }

    private AtomicRef createArticleAsset(String name, String type, String layoutSnippetId, Map<AssetRelation.RelationType, AssetRef> relations, Asset srcAsset, Long targetGroupId) throws Exception {
        return createArticleAsset(name, type, layoutSnippetId, relations, srcAsset,targetGroupId, null);
    }

    private AtomicRef createArticleAsset(String name, String type, String layoutSnippetId, Map<AssetRelation.RelationType, AssetRef> relations, Asset srcAsset, Long targetGroupId, String aliasName) throws Exception {
        return context.executeAtomically(() -> {
            UpdatingRepository repository = Platform.getCCServiceEx(UpdatingRepository.class);
            AtomicRef atomicRef = repository.createNew(name, AssetType.valueOf(type));
            Asset atomicAsset = atomicRef.get();
            atomicAsset.properties().setProperty(SNIPPET_PROPERTY, layoutSnippetId);

            relations.forEach((rel, ref) -> {
                atomicAsset.asRelations(rel).createOrGetRelation(ref);
            });
            if (layoutSnippetId != null) {
                atomicAsset.properties().setProperty(SNIPPET_PROPERTY, layoutSnippetId);
            }
            if (targetGroupId != null) {
                atomicAsset.properties().setProperty(TARGET_GROUP_PROPERTY, String.valueOf(targetGroupId));
            }

            if (newAssetDomain != null) {
                atomicAsset.traitDomain().setDomains(new Domains(newAssetDomain, "root."));
            }

            if (aliasName != null && !aliasName.isEmpty()) {
                atomicAsset.properties().createProperty(ALIAS_NAME_PROPERTY).setValue(aliasName);
            }

            /* copy workflow */
            /* copy workflow and other props */
            if(srcAsset != null) {
                atomicAsset.traitWorkflow().setWorkflow(srcAsset.traitWorkflow().getWorkflow());
                atomicAsset.traitWorkflow().setWorkflowStep(srcAsset.traitWorkflow().getWorkflowStep());
                atomicAsset.traitWorkflow().setWorkflowTarget(srcAsset.traitWorkflow().getWorkflowTarget());
                atomicAsset.properties().createProperty(COPY_OF_PROPERTY).setValue(String.valueOf(srcAsset.getId()));
                StringProperty bsTemplateProperty = srcAsset.properties().getProperty(BS_TEMPLATE_PROPERTY);
                if (bsTemplateProperty != null && bsTemplateProperty.getValue() != null) {
                    atomicAsset.properties().createProperty(BS_TEMPLATE_PROPERTY).setValue(bsTemplateProperty.getValue());
                }
            }

            atomicRef.checkInNew(atomicAsset);
            return atomicRef;
        });
    }
}
