package modules.msp.allianz.mmc_import.media_json_import.model;


import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;


/**
 * POJO for media JSON object
 */
public class Media
        implements Serializable {

    @SerializedName("Id")
    private String          id;
    @SerializedName("Name")
    private String          name;
    @SerializedName("Size")
    private Long         size;
    @SerializedName("MimeType")
    private String          mimeType;
    @SerializedName("Creation")
    private String          creation;
    @SerializedName("Path")
    private String          path;
    @SerializedName("Uploader")
    private User            uploader;
    @SerializedName("ResponsibleMember")
    private User            responsibleMember;
    @SerializedName("LithoMember")
    private User            lithoMember;
    @SerializedName("AgencyMember")
    private User            agencyMember;
    @SerializedName("Hash")
    private String          hash;
    @SerializedName("CopyrightStateId")
    private String          copyrightStateId;
    @SerializedName("Title")
    private String          title;
    @SerializedName("Source")
    private String          source;
    @SerializedName("Author")
    private String          author;
    @SerializedName("NotMatchesDesignGuidelines")
    private Boolean         notMatchesDesignGuidelines;
    @SerializedName("MaxWidth")
    private String          maxWidth;
    @SerializedName("MaxHeight")
    private String          maxHeight;
    @SerializedName("Keywords")
    private List<Keyword>   keywords;
    @SerializedName("Description")
    private String          description;
    @SerializedName("WorkflowStatusId")
    private Integer         workflowStatusId;
    @SerializedName("ContentAreas")
    private String          contentAreas;
    @SerializedName("Categories")
    private List<Category>  categories;
    @SerializedName("Links")
    private List<Link>      links;
    @SerializedName("Copyrights")
    private List<Copyright> copyrights;
    @SerializedName("AuditLog")
    private List<AuditLog>    auditLog;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public String getCreation() {
        return creation;
    }

    public void setCreation(String creation) {
        this.creation = creation;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public User getUploader() {
        return uploader;
    }

    public void setUploader(User uploader) {
        this.uploader = uploader;
    }

    public User getResponsibleMember() {
        return responsibleMember;
    }

    public void setResponsibleMember(User responsibleMember) {
        this.responsibleMember = responsibleMember;
    }

    public User getLithoMember() {
        return lithoMember;
    }

    public void setLithoMember(User lithoMember) {
        this.lithoMember = lithoMember;
    }

    public User getAgencyMember() {
        return agencyMember;
    }

    public void setAgencyMember(User agencyMember) {
        this.agencyMember = agencyMember;
    }

    public String getHash() {
        return hash;
    }

    public void setHash(String hash) {
        this.hash = hash;
    }

    public String getCopyrightStateId() {
        return copyrightStateId;
    }

    public void setCopyrightStateId(String copyrightStateId) {
        this.copyrightStateId = copyrightStateId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public Boolean getNotMatchesDesignGuidelines() {
        return notMatchesDesignGuidelines;
    }

    public void setNotMatchesDesignGuidelines(Boolean notMatchesDesignGuidelines) {
        this.notMatchesDesignGuidelines = notMatchesDesignGuidelines;
    }

    public String getMaxWidth() {
        return maxWidth;
    }

    public void setMaxWidth(String maxWidth) {
        this.maxWidth = maxWidth;
    }

    public String getMaxHeight() {
        return maxHeight;
    }

    public void setMaxHeight(String maxHeight) {
        this.maxHeight = maxHeight;
    }

    public List<Keyword> getKeywords() {
        return keywords;
    }

    public void setKeywords(List<Keyword> keywords) {
        this.keywords = keywords;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getWorkflowStatusId() {
        return workflowStatusId;
    }

    public void setWorkflowStatusId(Integer workflowStatusId) {
        this.workflowStatusId = workflowStatusId;
    }

    public String getContentAreas() {
        return contentAreas;
    }

    public void setContentAreas(String contentAreas) {
        this.contentAreas = contentAreas;
    }

    public List<Category> getCategories() {
        return categories;
    }

    public void setCategories(List<Category> categories) {
        this.categories = categories;
    }

    public List<Link> getLinks() {
        return links;
    }

    public void setLinks(List<Link> links) {
        this.links = links;
    }

    public List<Copyright> getCopyrights() {
        return copyrights;
    }

    public void setCopyrights(List<Copyright> copyrights) {
        this.copyrights = copyrights;
    }

    public List<AuditLog> getAuditLog() {
        return auditLog;
    }

    public void setAuditLog(List<AuditLog> auditLog) {
        this.auditLog = auditLog;
    }
}
