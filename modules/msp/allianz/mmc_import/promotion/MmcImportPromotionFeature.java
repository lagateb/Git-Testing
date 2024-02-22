package modules.msp.allianz.mmc_import.promotion;

import java.util.ArrayList;
import java.util.List;


/**
 * Feature element from import file, possibly containing subfeatures
 */
public class MmcImportPromotionFeature {

    private final MmcImportPromotionField         field;
    private final String                          value;
    private final List<MmcImportPromotionFeature> subFeatures = new ArrayList<>();

    /**
     * Create new instance
     *
     * @param field {@link MmcImportPromotionField} with feature key
     * @param value feature value string (or value_key)
     */
    public MmcImportPromotionFeature(MmcImportPromotionField field, String value) {
        this.field = field;
        this.value = value;
    }

    public MmcImportPromotionField getField() {
        return field;
    }

    public String getValue() {
        return value;
    }

    public List<MmcImportPromotionFeature> getSubFeatures() {
        return subFeatures;
    }

    /**
     * Add a subfeature
     *
     * @param subFeature new subfeature
     */
    public void addSubFeature(MmcImportPromotionFeature subFeature) {
        this.subFeatures.add(subFeature);
    }

    @Override
    public String toString() {
        return "MmcImportPromotionFeature{" + "field=" + field + ", value='" + value + "', subFeatures=" + subFeatures + '}';
    }
}
