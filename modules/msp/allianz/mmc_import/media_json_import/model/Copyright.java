package modules.msp.allianz.mmc_import.media_json_import.model;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;


/**
 * POJO for copyright JSON object
 */
public class Copyright
        implements Serializable {

    @SerializedName("Id")
    private String         id;
    @SerializedName("Creation")
    private String         creation;
    @SerializedName("Begin")
    private String         begin;
    @SerializedName("End")
    private String         end;
    @SerializedName("Medium")
    private String         medium;
    @SerializedName("Edition")
    private String         edition;
    @SerializedName("Distribution")
    private String         distribution;
    @SerializedName("RestraintsOfTrade")
    private String         restraintsOfTrade;
    @SerializedName("Notes")
    private String         notes;
    @SerializedName("CreatorMember")
    private User           creatorMember;
    @SerializedName("Files")
    private List<Media>    files;
    @SerializedName("Categories")
    private List<Category> categories;
    @SerializedName("Archived")
    private Boolean        archived;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCreation() {
        return creation;
    }

    public void setCreation(String creation) {
        this.creation = creation;
    }

    public String getBegin() {
        return begin;
    }

    public void setBegin(String begin) {
        this.begin = begin;
    }

    public String getEnd() {
        return end;
    }

    public void setEnd(String end) {
        this.end = end;
    }

    public String getMedium() {
        return medium;
    }

    public void setMedium(String medium) {
        this.medium = medium;
    }

    public String getEdition() {
        return edition;
    }

    public void setEdition(String edition) {
        this.edition = edition;
    }

    public String getDistribution() {
        return distribution;
    }

    public void setDistribution(String distribution) {
        this.distribution = distribution;
    }

    public String getRestraintsOfTrade() {
        return restraintsOfTrade;
    }

    public void setRestraintsOfTrade(String restraintsOfTrade) {
        this.restraintsOfTrade = restraintsOfTrade;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public User getCreatorMember() {
        return creatorMember;
    }

    public void setCreatorMember(User creatorMember) {
        this.creatorMember = creatorMember;
    }

    public List<Media> getFiles() {
        return files;
    }

    public void setFiles(List<Media> files) {
        this.files = files;
    }

    public List<Category> getCategories() {
        return categories;
    }

    public void setCategories(List<Category> categories) {
        this.categories = categories;
    }

    public Boolean getArchived() {
        return archived;
    }

    public void setArchived(Boolean archived) {
        this.archived = archived;
    }
}
