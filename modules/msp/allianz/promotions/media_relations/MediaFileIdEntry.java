package modules.msp.allianz.promotions.media_relations;

import com.censhare.model.corpus.impl.AssetTyping;


/**
 * Data class for feature structure of msp:alz-mmc.promotion.media-file-id
 */
public class MediaFileIdEntry {

    /**
     * the media file id
     */
    private String                      fileId;
    /**
     * the media relation type
     */
    private AssetTyping.AssetRelSubType relationType;

    /**
     * Create a new instance
     *
     * @param fileId       the media file id
     * @param relationType the relation type
     */
    public MediaFileIdEntry(String fileId, String relationType) {
        this.fileId = fileId;
        this.relationType = AssetTyping.AssetRelSubType.dbValueOf("user.media." + relationType + ".");
    }

    public String getFileId() {
        return fileId;
    }

    public void setFileId(String fileId) {
        this.fileId = fileId;
    }

    public AssetTyping.AssetRelSubType getRelationType() {
        return relationType;
    }

    public void setRelationType(AssetTyping.AssetRelSubType relationType) {
        this.relationType = relationType;
    }

    public boolean isValidEntry() {
        boolean validFileId = fileId != null && !fileId.isBlank();
        boolean validRelationType = relationType != null && relationType != AssetTyping.AssetRelSubType.UNDEFINED;
        return validFileId && validRelationType;
    }
}
