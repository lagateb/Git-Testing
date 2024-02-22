package modules.msp.allianz.mmc_import.media_json_import.model;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;


/**
 * POJO for link JSON object
 */
public class Link implements Serializable {

    @SerializedName("ParentObjectType")
    private Integer parentObjectType;

    @SerializedName("ParentObjectId")
    private Long parentObjectId;

    @SerializedName("ObjectType")
    private Integer objectType;

    @SerializedName("ObjectId")
    private Long objectId;

    @SerializedName("CreationDate")
    private String creationDate;

    @SerializedName("CreatorMemberId")
    private Long creatorMemberId;

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

    public String getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(String creationDate) {
        this.creationDate = creationDate;
    }

    public Long getCreatorMemberId() {
        return creatorMemberId;
    }

    public void setCreatorMemberId(Long creatorMemberId) {
        this.creatorMemberId = creatorMemberId;
    }
}
