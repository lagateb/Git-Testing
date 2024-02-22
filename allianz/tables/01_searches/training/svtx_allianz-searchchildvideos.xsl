<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- parameters -->
    <xsl:param name="context-id"/>


    <!-- search all user.* related child assets sorted by name asset type = video. -->
    <xsl:template match="/">
        <!-- query -->
        <query>
            <and>
                <relation direction="parent" type="user.">
                    <target>
                        <and>
                            <condition name="censhare:asset.id" op="=" value="{$context-id}"/>

                        </and>
                    </target>
                </relation>
                <condition name="censhare:asset.type" op="=" value="video.*"/>
            </and>
            <sortorders>
                <grouping mode="none"/>
                <order ascending="true" by="censhare:asset.name"/>
            </sortorders>
        </query>
    </xsl:template>
</xsl:stylesheet>
