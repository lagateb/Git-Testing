package modules.msp.allianz.mmc_import.media_json_import.model;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.Map;


/**
 * POJO for category JSON object
 */
public class Category implements Serializable {
    @SerializedName("Id")
    private Long id;

    @SerializedName("Title")
    private Map<String, String> title;

    @SerializedName("Parent")
    private Category parent;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Map<String, String> getTitle() {
        return title;
    }

    public void setTitle(Map<String, String> title) {
        this.title = title;
    }

    public Category getParent() {
        return parent;
    }

    public void setParent(Category parent) {
        this.parent = parent;
    }
}
