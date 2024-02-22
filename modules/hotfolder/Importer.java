/**
  * Copyright (c) by censhare AG
  *
  * SVN $Id$
  */
package modules.hotfolder;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;

import modules.hotfolder.GlobalSettings.HotfolderEvents;

import com.censhare.manager.assetmanager.AssetManagementService;
import com.censhare.model.corpus.impl.Asset;
import com.censhare.model.corpus.impl.AssetTyping.AssetRelType;
import com.censhare.server.manager.DBTransactionManager;
import com.censhare.support.io.FileFactoryService;
import com.censhare.support.model.DataObjectKey;
import com.censhare.support.model.DataObjectUtil;
import com.censhare.support.model.PersistenceManager;
import com.censhare.support.xml.AXml;
import com.censhare.support.xml.Node;

/**
 * Importer for assets.
 *
 * @author Florin Kollan
 */
public abstract class Importer {

    protected DBTransactionManager tm;
    protected AssetManagementService am;
    protected PersistenceManager pm;
    protected FileFactoryService ffs;
    protected GlobalSettings globalSettings;
    protected ImporterSettings importerSettings;
    protected HotfolderEvents hotfolderEvents;
    protected Logger logger;

    /**
     * Handles the occurrence of duplicate assets.
     * @param assetCollection the asset entry
     * @param asset entry in the database
     */
    private void handleDuplicateAsset(AssetFilesMapping mappedAssetFiles, Asset folderAsset)
            throws Exception, ConditionException {
        Asset asset = mappedAssetFiles.getAsset();
        boolean isNotCheckedOut = checkNotCheckedout(asset);

        if ((importerSettings.isCheckoutCheckinIn() && !isNotCheckedOut)
                || (importerSettings.isCheckoutCheckinOutIn() && isNotCheckedOut)
                || (importerSettings.isCheckoutCheckinUpdate() && isNotCheckedOut)) {
            if (isNotCheckedOut && !importerSettings.isCheckoutCheckinUpdate()) {
                asset = am.checkOut(tm, asset.getPrimaryKey());
                tm.end();
                tm.begin();

            }
            else {
                if (importerSettings.isCheckoutCheckinUpdate()) {
                    asset = queryAndLock(asset);
                } else {
                    //query for checkout version
                    DataObjectKey<Asset> assetKey = Asset.newUn(asset.getId(), Asset.VERSION_CHECKEDOUT);
                    asset = pm.query(assetKey);
                    am.tryLockAssetEx(tm, asset, false);
                }
            }

            try {
                AssetFilesMapping preparedMappedAssetFiles = new AssetFilesMapping(mappedAssetFiles.getAssetFiles(), asset);
                updateAsset (preparedMappedAssetFiles, isNotCheckedOut && !importerSettings.isCheckoutCheckinUpdate());
                asset = preparedMappedAssetFiles.getAsset();
            } catch (Exception e) {
                // try to reset asset state
                try {
                    if (isNotCheckedOut && !importerSettings.isCheckoutCheckinUpdate()) {
                        // transaction might be still active
                        if(tm.getStatus() != DBTransactionManager.STATE_BEGUN)
                            tm.begin();

                        am.checkOutAbort(tm, asset.getPrimaryKey());
                        tm.end();
                    }
                } catch (Exception e1) {
                    logger.log(Level.WARNING, "Unable to reset asset state after update failure!", e1);
                }

                throw e;
            }

            if (folderAsset != null)
                asset.struct().createOrGetParentAssetRel(folderAsset, AssetRelType.USER);

	    // MSP EDIT
	    pm.makePersistentRecursive(asset);

            if (!importerSettings.isCheckoutCheckinUpdate()) {

                // checkin
                am.checkIn(tm, asset);
            }
            else {

                am.update(tm, asset);
            }

            tm.commit();
        }
        else {
            tm.end();
            throw new ConditionException("ignore asset " + asset.getId() + "-wrong checkout/checkin state!",
                    ConditionException.CHECKOUT_STATE);
        }
    }

    /**
     * Handles the occurrence of new assets.
     * @param assetCollection the asset entry
     * @param folderId folder id
     */
    private Asset handleNewAsset(AssetFilesMapping mappedAssetFiles, Asset folderAsset)
            throws Exception {
        // add a new asset
        AXml assetXml = getNewAssetSample ().cloneMutableDeep();
        assetXml.setAttr("version", "0");
        Asset newAsset = (Asset) pm.mapAndMakePersistentRecursive(assetXml);

        AssetFilesMapping newMappedAssetFiles = new AssetFilesMapping(mappedAssetFiles.getAssetFiles(), newAsset);
        newAsset (newMappedAssetFiles);
        setAttributes(newMappedAssetFiles, false, true);

        newAsset = newMappedAssetFiles.getAsset();
        DataObjectUtil.createDataObjectsRec(newAsset, true);

        if (folderAsset != null)
            newAsset.struct().createOrGetParentAssetRel(folderAsset, AssetRelType.USER);
       
        // MSP EDIT 
        pm.makePersistentRecursive(newAsset);
        am.checkInNew(tm, newAsset);

        tm.commit();

        return newAsset;
    }

    /** Assure that asset is up to date and lock. */
    protected Asset queryAndLock(Asset asset) {
        // AssetAutomation is triggered on current assets only,
        // however assets may be updated through other processes.
        // Therefore query using version to stick on that asses version.
        asset = am.assureUpToDateAndLock(tm, asset, true /* queryCurrent */);
        return asset;
    }

    private boolean checkNotCheckedout(Asset asset) throws Exception {
        if (asset.isCheckedout()) {
            return false;
        }
        if (asset.getCurrversion() != Asset.VERSION_CURRENT)
            throw new Exception("asset is not the current version: " + asset);
        return true;
    }

    private void copyXMLAttributesRecursive(AXml source, AXml target) {
        for (Node attr: source.getAttributes()) {
            target.setAttr(attr.getNodeName(), attr.getNodeValueObject());
        }

        AXml sourceChildNd = source.getFirstChildElement();
        while (sourceChildNd != null) {
            AXml targetChildNd = target.create(sourceChildNd.getNodeName());
            copyXMLAttributesRecursive(sourceChildNd, targetChildNd);
            sourceChildNd = sourceChildNd.getNextSiblingElement();
        }
    }

    /** Unable to handle asset */
    protected void handlingNotPermitted (String message, AssetFiles assetFiles)
        throws Exception {
        if (globalSettings.isIgnoreNonMatchingFiles())
            // move files back
            logger.info(message + "- ignoring " + assetFiles.getType() +" " + assetFiles);
        else
            logger.info("asset creation not permitted- move " + assetFiles.getType() +" " + assetFiles + " to error dir");
    }

    /** Update asset */
    protected void updateAsset (AssetFilesMapping mappedAssetFiles, boolean checkedoutByImporter)
        throws Exception {
        setAttributes(mappedAssetFiles, true, false);
    }

    /** Create new asset */
    protected void newAsset (AssetFilesMapping mappedAssetFiles)
        throws Exception {
    }

    /** Initialize importer */
    public Importer (   DBTransactionManager tm,
                        AssetManagementService am,
                        PersistenceManager pm,
                        FileFactoryService ffs,
                        ImporterSettings importerSettings,
                        HotfolderEvents hotfolderEvents,
                        Logger logger) {
        this.tm = tm;
        this.am = am;
        this.pm = pm;
        this.ffs = ffs;
        this.hotfolderEvents = hotfolderEvents;
        this.importerSettings = importerSettings;
        this.globalSettings = importerSettings.getGlobalSettings();
        this.logger = logger;
    }

    public void setAttributes(AssetFilesMapping mappedAssetFiles, boolean oldWorkflow, boolean setAuto) {
        boolean nameDetected = false;
        boolean setWorkflow = true;
        Asset asset = mappedAssetFiles.getAsset();
        AXml assetXml = asset.xml();

        if (importerSettings.isPerformUpdate()) {

            copyXMLAttributesRecursive(getNewAssetSample (), asset.xml());

            if (oldWorkflow) {
                String workflow = asset.xml().getAttr("wf_id");
                String workflowstep = asset.xml().getAttr("wf_step");
                if (workflow != null && !importerSettings.getOldWorkflow().equals("")) {
                    if (!importerSettings.getOldWorkflow().equals(workflow)) {
                        setWorkflow = false;
                    }
                    else {

                        if (workflowstep != null && !importerSettings.getOldWorkflowStep().equals("")) {
                            if (!importerSettings.getOldWorkflowStep().equals(workflowstep)) {
                                setWorkflow = false;
                            }
                        }
                    }
                }
            }
            AssetFiles.FileItem masterFItem = mappedAssetFiles.getFirstMasterFileItem();
            // if no master entry defined, take a file entry
            if (masterFItem == null) {
                logger.info("unable to find a master file- take a arbitrarily file for parameter generation");
                masterFItem = mappedAssetFiles.getFileItems().get(0);
            }
            for (ImporterSettings.FilenameAttributeMapping assetParameter : importerSettings.getAssetParameters()) {
                Matcher m = null;
                if (assetParameter.isUsePath())
                    m = assetParameter.getMatcher().matcher(masterFItem.getInputDirRelName());
                else
                    m = assetParameter.getMatcher().matcher(masterFItem.getFilename());
                if (m.matches()) {
                    String value = m.replaceFirst(assetParameter.getReplacement());
                    String target = assetParameter.getTarget(m, assetXml);
                    assetXml.put(target, value);
                    if (target.toLowerCase().equals("@name") && value != null) {
                        nameDetected = true;
                    }
                }

            }
            if (!nameDetected && setAuto) {

                logger.fine("couldn't set name attribute, using plain filename");
                assetXml.put("@name", masterFItem.getFilename());
            }
            if (!importerSettings.getWorkflow().equals("") && setWorkflow) {
                assetXml.put("@wf_id", importerSettings.getWorkflow());
            }
            if (!importerSettings.getWorkflowStep().equals("") && setWorkflow) {
                assetXml.put("@wf_step", importerSettings.getWorkflowStep());
            }
            if (!importerSettings.getDomain().equals("")) {
                asset.setDomain(importerSettings.getDomain());
            }
            if (!importerSettings.getDomain2().equals("")) {
                asset.setDomain2(importerSettings.getDomain2());
            }
            if (!importerSettings.getWorkflowTarget().equals("")) {
                assetXml.put("@wf_target", importerSettings.getWorkflowTarget());
            }
            if (!importerSettings.getApplication().equals("")) {
                asset.setApplication(importerSettings.getApplication());
            }
        }
    }

    /**
     * @return the importerSettings
     */
    public ImporterSettings getImporterSettings() {
        return importerSettings;
    }

    public final Asset importAsset (AssetFilesMapping mappedAssetFiles, Asset folderAsset)
        throws Exception {
        Asset importedAsset = null;
        if (mappedAssetFiles.getAsset() != null) {
            if (importerSettings.isReplaceExistingItems()) {

                // has duplicate
                logger.info("duplicate found- replace asset");
                tm.begin();
                handleDuplicateAsset(mappedAssetFiles, folderAsset);
                importedAsset = mappedAssetFiles.getAsset();
                hotfolderEvents.addHandledAsset(importedAsset.getId());
            }
            else {
                handlingNotPermitted (  "asset replacement not permitted", mappedAssetFiles.getAssetFiles());
            }
        }
        else {
            if (importerSettings.isCreateNewItems()) {
                logger.info("no duplicate found- create new asset");
                tm.begin();
                importedAsset = handleNewAsset(mappedAssetFiles, folderAsset);
                hotfolderEvents.addHandledAsset(importedAsset.getId());
            }
            else {
                handlingNotPermitted (  "asset creation not permitted", mappedAssetFiles.getAssetFiles());
            }

        }

        return importedAsset;
    }

    public AssetFiles getAssetFilesInstance (AssetFiles.FileItem masterFileItem) {
        return new AssetFiles(masterFileItem, this);
    }

    public AssetFiles getAssetFilesInstance (String matchCriterion, AssetFiles.FileItem masterFileItem) {
        return new AssetFiles(matchCriterion, masterFileItem, this);
    }

    public abstract void finishedAssetFilesImport (AssetFiles assetFiles);

    public abstract String getAssetImporterType ();

    public abstract AXml getNewAssetSample ();
}
