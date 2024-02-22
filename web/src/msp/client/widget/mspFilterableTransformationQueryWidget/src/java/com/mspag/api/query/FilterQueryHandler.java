package web.src.msp.client.widget.mspFilterableTransformationQueryWidget.src.java.com.mspag.api.query;

import com.censhare.api.query.QueryCommand;
import com.censhare.api.transformation.TransformationHandlers;
import com.censhare.server.support.api.APICommand;
import com.censhare.server.support.api.CommandContext;
import com.censhare.server.support.api.Data;
import com.censhare.server.support.api.impl.CommandAnnotations;
import com.censhare.support.json.ClassAnalyzer;
import com.censhare.support.model.QSelect;
import com.censhare.support.util.logging.ContextLogger;
import com.censhare.support.xml.AXml;
import com.censhare.support.xml.xpath.XPathContext;
import com.censhare.support.xml.xpath.XslExprImpl;

import java.util.logging.Level;
import java.util.logging.Logger;


/**
 * Mostly copy of QueryAssetHandler because of private variables
 */
@CommandAnnotations.CommandHandler(command = "com.mspag.api.query.FilterableQueryAsset", scope = CommandAnnotations.ScopeType.CONVERSATION)
public class FilterQueryHandler
        extends QueryCommand.LiveQuery {

    private static final Logger logger = ContextLogger.getLogger(FilterQueryHandler.class);

    /**
     * The cached search xml
     */
    protected AXml cachedSearchXml;

    private String                    ressourceKey;
    private XslExprImpl.XslStylesheet xsl;

    private long contextId;

    private static final class FilterableTransformationInput {

        /**
         * The search id / transformation ressource key
         */
        @ClassAnalyzer.Key
        public String searchId;
        /**
         * The context (asset-id)
         */
        @ClassAnalyzer.Key
        public long   context;
        /**
         * The query limit
         */
        @ClassAnalyzer.Key
        public int    limit;
        /**
         * The query view
         */
        @ClassAnalyzer.Key
        public AXml   view;
        /**
         * The transformation parameters
         */
        @ClassAnalyzer.Key
        public AXml   params;

    }

    @Override
    @CommandAnnotations.Execute
    public APICommand.CommandResult execute(CommandContext context) throws Exception {
        final FilterableTransformationInput input = context.getInput()
                                                           .getPojo(FilterableTransformationInput.class);

        if (input.searchId == null) {
            return APICommand.CommandResult.failed(new Exception("Input parameter searchId is missing"));
        }

        if (this.xsl == null || this.ressourceKey == null || !this.ressourceKey.equals(input.searchId)) {
            // OPT: check if asset is a transformation or a stored search
            this.ressourceKey = input.searchId;
            this.xsl = TransformationHandlers.loadTransformation(input.searchId);
        }
        this.contextId = input.context;
        this.runTransformation(input);

        return super.execute(context);
    }

    /**
     * Runs the {@link #xsl} with given parameters and sets the result as {@link #cachedSearchXml}
     *
     * @param input a {@link FilterableTransformationInput} which provides needed params, limit and view
     *
     * @throws IllegalStateException if {@link #xsl} was not loaded through {@link #execute(CommandContext)}
     * @throws Exception             if asset xml creation for {@link #contextId} fails
     */
    protected void runTransformation(FilterableTransformationInput input) throws Exception {
        if (xsl == null) {
            throw new IllegalStateException("Transformation is not loaded.");
        }

        AXml contextXml = TransformationHandlers.createAssetContextXml(this.contextId);
        XPathContext xpc = new XPathContext(contextXml);
        xpc.setVariable("context-id", this.contextId);
        if (input.params != null && input.params.getFirstChildElement() != null) {
            AXml child = input.params.getFirstChildElement();
            do {
                xpc.setVariable(child.getAttr("key"), child.getAttr("value"));
                child = child.getNextSiblingElement();
            } while (child != null);
        }
        AXml oldSearchXml = cachedSearchXml;
        AXml result = (AXml) xsl.eval(xpc);
        // Block synchron updates on the searchXml
        synchronized (this) {
            cachedSearchXml = result.find("query");
            if (cachedSearchXml != null) {
                if (input.limit > 0) {
                    cachedSearchXml.setAttr("limit", input.limit);
                } else if (oldSearchXml != null) {
                    cachedSearchXml.setAttr("limit", oldSearchXml.getAttr("limit"));
                }

                AXml viewXml = null;
                if (input.view != null) {
                    viewXml = input.view;
                } else if (oldSearchXml != null) {
                    viewXml = oldSearchXml.create("view");
                }
                if (viewXml != null) {
                    cachedSearchXml.getRootNode()
                                   .getFirstChildElement()
                                   .insertBefore(viewXml.cloneMutableDeep());
                }
            }
        }
    }

    @Override
    protected QSelect generateSelect(CommandContext context, AXml data) {
        FilterableTransformationInput input = context.getInput()
                                                     .getPojo(FilterableTransformationInput.class);

        if (cachedSearchXml == null) {
            throw new RuntimeException("No query XML generated by resource asset with key: " + input.searchId);
        }

        try {
            return super.generateSelect(context, cachedSearchXml);
        } catch (Exception e) {
            logger.log(Level.WARNING, "Exception while creating query from transformation: " + input.searchId, e);
        }

        return null;
    }

    /**
     * Set the limit at {@link #cachedSearchXml}
     * Called by frontend
     *
     * @param limit the new limit
     */
    @CommandAnnotations.Notify
    public void setViewLimit(Data limit) {
        if (cachedSearchXml == null || limit == null || limit.isNull()) {
            return;
        }

        int l = limit.getXml()
                     .getAttrInt("limit");
        synchronized (this) {
            cachedSearchXml.setAttr("limit", l);
        }
        modifyQuery(Data.wrapXml(cachedSearchXml));
    }

    /**
     * Set the offset at {@link #cachedSearchXml}
     * Called by frontend
     *
     * @param offset the new offset
     */
    @CommandAnnotations.Notify
    public void setOffset(Data offset) {
        if (cachedSearchXml == null || offset == null || offset.isNull()) {
            return;
        }

        int o = offset.getXml()
                      .getAttrInt("offset");
        synchronized (this) {
            cachedSearchXml.setAttr("offset", o);
        }
        modifyQuery(Data.wrapXml(cachedSearchXml));
    }

    /**
     * Set query parameters and recreate {@link #cachedSearchXml} through {@link #runTransformation(FilterableTransformationInput)}
     * Called by frontend
     *
     * @param params the query parameters
     *
     * @throws Exception if {@link #runTransformation(FilterableTransformationInput)} fails
     */
    @CommandAnnotations.Notify
    public void queryParams(Data params) throws Exception {
        if (cachedSearchXml == null || params == null || params.isNull()) {
            return;
        }

        // Have to reexecute transformation with new Params
        runTransformation(params.getPojo(FilterableTransformationInput.class));
        modifyQuery(Data.wrapXml(this.cachedSearchXml));
    }

}
