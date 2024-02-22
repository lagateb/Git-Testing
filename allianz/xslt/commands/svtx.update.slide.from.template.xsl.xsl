<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">
    <!--
    Updated  die PPTX Master Datei des Slide-Assets  mit der Template Masterdatei
    Regenriert das Slide-Asset mit dem TextAsset Infos
    Regeneriert das Asset der Slide Sammlung
    -->

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:pptx.command.utils.xsl/storage/master/file" />
    <!-- ruft unser Powerpoint Modul auf -->




    <xsl:template match="asset[starts-with(@type, 'presentation.slide.')]">
        <xsl:variable name="keyMaster" select="./asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref" />
        <xsl:if test="$keyMaster">
            <!--
                <xsl:variable name="additionalData"><textAssetId value="{./child_asset_rel[@key='target.']/@child_asset}"/></xsl:variable>
            -->
            <xsl:variable name="hasChild" select="./child_asset_rel[@key='target.']/@child_asset"/>
            <xsl:message>=== update slide master <xsl:value-of select="@id"/></xsl:message>
            <xsl:value-of select="svtx:updateSlideFromMaster(.,$keyMaster,$hasChild)"/>

        </xsl:if>
    </xsl:template>







</xsl:stylesheet>
