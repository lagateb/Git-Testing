<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom" exclude-result-prefixes="cs csc">

    <!-- dynamic value list of all media (pptx) assets  for the product where the article relate to-->

    <!--
    <?xml version="1.0" encoding="UTF-8"?>
    <options xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <option value="32330" display_value="P20210623_1 PowerPoint Makler"/>
        <option value="32304" display_value="P20210623_1 PowerPoint Standard"/>
        <option value="32317" display_value="P20210623_1 PowerPoint Vertrieb"/>
   </options>
-->

    <!-- import -->
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

    <!-- parameters -->
    <xsl:param name="asset" select="asset"/>
    <xsl:param name="feature-key"/>
    <xsl:param name="value" select="()"/>

    <!-- root match -->
    <xsl:template match="/">
        <!-- https://youtrack.savotex.com/issue/ORTCONTENT-646 -->
        <xsl:variable name="templateAsset" select="($asset/cs:feature-ref-reverse()[@key = 'svtx:copy-of'])[1]" as="element(asset)?"/>
        <xsl:variable name="outputAreas" select="$templateAsset/asset_feature[@feature='svtx:web-output-area']/@value_key" as="xs:string*"/>
        <options>
            <option value="root.web.aem.aem-vp." display_value="Vertriebsportal">
                <value censhare:_annotation.datatype="string">root.web.aem.aem-vp.</value>
                <display_value censhare:_annotation.datatype="string">Vertriebsportal</display_value>
                <allow_output censhare:_annotation.datatype="boolean"><xsl:value-of select="not($outputAreas='vertriebsportal')"/></allow_output>
            </option>
            <option value="root.web.aem.aem-azde." display_value="AZ.de">
                <value censhare:_annotation.datatype="string">root.web.aem.aem-azde.</value>
                <display_value censhare:_annotation.datatype="string">AZ.de</display_value>
                <allow_output censhare:_annotation.datatype="boolean"><xsl:value-of select="not($outputAreas='allianzde')"/></allow_output>
            </option>
            <option value="root.web.bs." display_value="Beratungssuite">
                <value censhare:_annotation.datatype="string">root.web.bs.</value>
                <display_value censhare:_annotation.datatype="string">Beratungssuite</display_value>
                <allow_output censhare:_annotation.datatype="boolean"><xsl:value-of select="not($outputAreas='beratungssuite')"/></allow_output>
            </option>
        </options>
    </xsl:template>

</xsl:stylesheet>