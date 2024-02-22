package modules.msp.allianz.mmc_import.media_json_import.model;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;


/**
 * POJO for audit log JSON object
 */
public class AuditLog implements Serializable {

    @SerializedName("Id")
    private Long id;

    @SerializedName("TenantId")
    private String tenantId;

    @SerializedName("ObjectType")
    private Integer objectType;

    @SerializedName("ObjectId")
    private Long objectId;

    @SerializedName("ObjectTitle")
    private String objectTitle;

    @SerializedName("ParentObjectType")
    private Integer parentObjectType;

    @SerializedName("ParentObjectId")
    private Long parentObjectId;

    @SerializedName("Timestamp")
    private String timestamp;

    @SerializedName("MemberId")
    private Long memberId;

    @SerializedName("EventType")
    private Integer eventType;

    @SerializedName("Content")
    private String content;

    @SerializedName("RequestId")
    private String requestId;

    @SerializedName("Permission")
    private String permission;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTenantId() {
        return tenantId;
    }

    public void setTenantId(String tenantId) {
        this.tenantId = tenantId;
    }

    public Integer getObjectType() {
        return objectType;
    }

    public void setObjectType(Integer objectType) {
        this.objectType = objectType;
    }

    public Long getObjectId() {
        return objectId;
    }

    public void setObjectId(Long objectId) {
        this.objectId = objectId;
    }

    public String getObjectTitle() {
        return objectTitle;
    }

    public void setObjectTitle(String objectTitle) {
        this.objectTitle = objectTitle;
    }

    public Integer getParentObjectType() {
        return parentObjectType;
    }

    public void setParentObjectType(Integer parentObjectType) {
        this.parentObjectType = parentObjectType;
    }

    public Long getParentObjectId() {
        return parentObjectId;
    }

    public void setParentObjectId(Long parentObjectId) {
        this.parentObjectId = parentObjectId;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public Long getMemberId() {
        return memberId;
    }

    public void setMemberId(Long memberId) {
        this.memberId = memberId;
    }

    public Integer getEventType() {
        return eventType;
    }

    public void setEventType(Integer eventType) {
        this.eventType = eventType;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getPermission() {
        return permission;
    }

    public void setPermission(String permission) {
        this.permission = permission;
    }
}
