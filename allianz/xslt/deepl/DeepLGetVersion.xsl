<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  exclude-result-prefixes="#all">

    <!-- Achtung check "Evaluate on Server" !!! -->
    <xsl:template match="/">

        <xsl:variable name="version"><cs:command name="modules.com.savotex.translator.Translate.getVersion"/></xsl:variable>

        <!-- <translation retCode="200" success="true" character_count="4960" character_limit="500000"/> -->
        <result>
            <config>
                <title id="title">Deepl Version Info</title>
            </config>
            <content>
                <div class="exDeeplStatistic_wrapper cs-p-h-w">
                    <span>Version: <xsl:value-of select="$version/translation/@version"/></span>
                </div>
            </content>

        </result>
    </xsl:template>

</xsl:stylesheet>
