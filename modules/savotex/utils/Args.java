package modules.savotex.utils;

import java.util.Map;

public class Args {
    Map<String, Object> vals;
    public Args(Map<String, Object> vals) {
        this.vals = vals;
    }


    /**
     *
     * @param name
     * @param defaultVal
     * @return
     */
    public String getStringVal( String name,String defaultVal) {
        Object o = vals.get(name);
        if(o==null) {
            return defaultVal;
        } else {
            String tmp = String.valueOf(o);
            return tmp.replace("<root>", "").replace("</root>", "");
        }
    }


    public long getLongVal(String name,long defaultVal) {
        try {
           return  Long.parseLong(getStringVal(name,""+defaultVal));
        } catch (NumberFormatException nfe) {
           return defaultVal;
        }
    }

    public String getStringVal( String name) {
        return getStringVal(name,"");
    }

    public boolean getAsBool(String name,String compare,String valueIfNotFound) {
        return getStringVal(name,valueIfNotFound).equals(compare);
    }
}
