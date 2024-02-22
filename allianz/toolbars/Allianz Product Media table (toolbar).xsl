<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

    <!-- toolbar for articles table -->

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

    <!-- output -->
    <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

    <xsl:variable name="language" select="csc:getLoggedInPartyLocale()"/>

    <!-- root match -->
    <xsl:template match="/">
        <result>
            <content>
                <div class="cs-toolbar">
                    <div class="cs-toolbar-slot-1">
                    </div>
                    <div class="cs-toolbar-slot-2">
                        <div class="cs-toolbar-item">
                            <cs-include-dialog key="'svtx:actions.open.allianz.target.group.wizard'"></cs-include-dialog>
                        </div>
                    </div>
                </div>
            </content>
        </result>
    </xsl:template>

</xsl:stylesheet>
