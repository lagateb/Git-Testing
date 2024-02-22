/*
 * (c) Copyright by censhare AG
 */
package com.censhare.uicontrol.tree.asset;

import com.censhare.db.iindex.DocList;
import com.censhare.db.iindex.Result;
import com.censhare.db.query.AssetQueryEngine;
import com.censhare.manager.assetstore.AssetStoreService;
import com.censhare.model.corpus.impl.Asset;
import com.censhare.model.corpus.impl.AssetCacheKey;
import com.censhare.model.logical.api.domain.AssetRef;
import com.censhare.server.support.api.CommandContext;
import com.censhare.support.context.Platform;
import com.censhare.support.model.QSelect;
import com.censhare.support.xml.AXml;
import com.censhare.uicontrol.tree.asset.AssetDataResult.AssetData;
import com.censhare.uicontrol.tree.dataprovider.Result.MetaResult;
import com.censhare.uicontrol.tree.dataprovider.TreeDataProvider;
import com.censhare.uicontrol.tree.model.ConfigModel.TreeConfigModel;
import com.censhare.uicontrol.tree.model.Group;
import com.censhare.uicontrol.tree.model.TreeNodeId;
import com.censhare.uicontrol.tree.query.TreeQueryFactory;
import com.censhare.uicontrol.tree.query.XSLTreeQueryFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import static com.censhare.uicontrol.tree.asset.AbstractAssetDataRowList.CACHES_MAX_SIZE;

/**
 * DataProvider for assets and related child assets which results in a tree.
 * For every asset, a child-query is executed to find possible child assets.
 *
 * @author Christof Aenderl
 */
public class AssetTreeDataProvider extends AbstractAssetDataProvider implements TreeDataProvider<AssetDataResult> {

    private static final Logger logger = Logger.getLogger(AssetTreeDataProvider.class.getName());

    private final TreeQueryFactory childQueryFactory; // child query is created for each node on demand
    private final AssetStoreService assetStoreService;
    private final boolean isManualSortingEnabled;

    public AssetTreeDataProvider(CommandContext context, TreeConfigModel treeConfigModel, AssetRef contextAssetRef, AXml externalRootQuery) throws Exception {
        super(context, treeConfigModel, contextAssetRef, externalRootQuery);

        // prepare child query transformation
        childQueryFactory = treeConfigModel.getChildQueryKey() == null ? null : new XSLTreeQueryFactory(context, treeConfigModel.getChildQueryKey(), CACHES_MAX_SIZE);
        assetStoreService = Platform.getCCServiceEx(AssetStoreService.class);
        isManualSortingEnabled = treeConfigModel.isManualSortingEnabled();
    }

    @Override
    public AssetDataResult loadData(TreeNodeId nodeId, int offset, int limit) {
        try {
            QSelect query = getQuery(nodeId);
            query.limit(limit);
            query.offset(offset);

            List<AssetData> assetTreeDatas = new ArrayList<>(limit);

            Result result = qs.queryAssetResult(query);

            List<Group> groups = isGroupContext(result)
                ? Group.buildGroups(nodeId.getIdString(), result.getDocs().getDocList(), result.getGroupResults(), offset, limit, isManualSortingEnabled, childQueryFactory.getParams())
                : new ArrayList<>();

            Map<Long, Long> currentVersions = assetStoreService.getAssetVersions(Asset.VERSION_CURRENT);

            for (AssetCacheKey key : AssetQueryEngine.docListToKeys(result.getDocs())) {
                Long assetCCN = currentVersions.get(key.id);
                key.ccn = assetCCN != null ? assetCCN.intValue() : 0;

                final TreeNodeId treeNode = new TreeNodeId(nodeId, key.id, Group.getAssetGroup(groups, key.id));

                AssetData assetTreeData = new AssetData(key, treeNode);
                assetTreeData.childCount = getNoOfChildren(assetTreeData, key);
                assetTreeDatas.add(assetTreeData);
            }

            return new AssetDataResult(assetTreeDatas, result.getMaxCount());
        } catch (Exception e) {
            logger.log(Level.WARNING, "Query asset data failed", e);
            throw new RuntimeException(e);
        }
    }

    private int getNoOfChildren(AssetData assetTreeData, AssetCacheKey key) {
        int childCount = -1;

        // OPT: better way to find out if there are children

        if (childQueryFactory == null) return -1;

        try {
            QSelect childQuery = childQueryFactory.createSelect(assetTreeData.nodeId);
            // Standard ist 0. Wi rhaben 1 , damit auch bei unserem eigenen Sort die Anzahl zurückkommt
            childQuery.limit(1);
            //logger.log(Level.WARNING, "====MY Version2");
            Result childResult = qs.queryAssetResult(childQuery);
            childCount = childResult.getMaxCount();
        } catch (Exception e) {
            logger.log(Level.WARNING, "Not able to query for child count of asset: " + key, e);
        }

        return childCount;

    }

    private boolean isGroupContext(Result result) {
        return result.getGroupResults() != null && !result.getGroupResults().isEmpty() /*&& result.groupResults.get(0).groupContext != null*/ && !result.isEmpty();
    }

    void setQueryParams(Map<String, String> params) {
        super.setQueryParams(params);
        // also set the params to child factory
        childQueryFactory.setParams(params);
    }

    @Override
    public MetaResult loadMeta(TreeNodeId nodeId) {
        try {
            QSelect query = getQuery(nodeId);
            // only query for the asset-ids from cdb
            query.limit(-1);
            Result result = qs.queryAssetResult(query);
            DocList docList = result.getDocs().getDocList();

            return new DocListMetaResult(docList, result.getMaxCount());
        } catch (Exception e) {
            logger.log(Level.WARNING, "Query result data failed", e);
            throw new RuntimeException(e);
        }
    }

    private QSelect getQuery(TreeNodeId nodeId) throws Exception {
        if (nodeId.isRoot())
            return new QSelect(rootQuery); // return copy

        return childQueryFactory.createSelect(nodeId);
    }

    /**
     * To create the tree structure
     */
    public final static class DocListMetaResult implements MetaResult {

        private final DocList docList;
        private final int maxCount;

        DocListMetaResult(DocList docList, int maxCount) {
            this.docList = docList;
            this.maxCount = maxCount;
        }

        @Override
        public int getMaxCount() {
            return maxCount;
        }

        @Override
        public int getPosition(TreeNodeId nodeId) {
            long lookupId = nodeId.getOwnNodeIdLong();
            // docList contains sorted array of assetIds
            if (docList.docIDs != null) {
                for (int i = 0; i < docList.docIDs.length; i++) {
                    if (lookupId == docList.docIDs[i])
                        return i + 1; // not index but position
                }
            }
            return -1;
        }

        @Override
        public int[] getPositions(long key, int start, int end) {
            return MetaResult.findInList(key, docList.docIDs, start, end);
        }

        @Override
        public TreeNodeId firstNode() {
            if (docList.docIDs != null && docList.docIDs.length > 0)
                return new TreeNodeId(docList.docIDs[0]);
            return null;
        }
    }
}
