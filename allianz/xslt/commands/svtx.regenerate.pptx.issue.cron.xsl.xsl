<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">


    <xsl:function name="svtx:pptxFunctions">
        <xsl:param name="pptxId"/>
        <xsl:param name="command"/>
        <xsl:variable name="command-xml">
            <cmd timeout="600">
                <xml-info title="{$command} PPTX " locale="__ALL">
                </xml-info>
                <cmd-info name="{$command} PPTX"/>
                <commands currentstep="command">
                    <command method="{$command}" scriptlet="modules.savotex.powerpoint.PPCapsulate"  target="ScriptletManager"/>
                </commands>
                <config>
                    <pptx>
                        <timeout value="600"/>
                    </pptx>
                </config>
                <content>
                </content>
                <assets>
                    <cs:param name="asset" select="cs:get-asset(xs:long($pptxId))"/>
                </assets>
            </cmd>

        </xsl:variable>
        <!-- setup the data -->
        <cs:command name="com.censhare.api.Command.execute">
            <cs:param name="source" select="$command-xml"/>
        </cs:command>

    </xsl:function>

    <xsl:function name="svtx:updateMasterPowerPoint">
        <xsl:param name="assetId"/>
        <xsl:message>=== assetId <xsl:value-of select="$assetId"/></xsl:message>
        <xsl:variable name="asset" select="cs:get-asset(xs:long($assetId))" as="element(asset)?"/>
        <xsl:value-of select="svtx:pptxFunctions($assetId,'merge')"/>
    </xsl:function>

    <xsl:function name="svtx:deleteAsset">
        <xsl:param name="assetId"/>
        <xsl:message>=== cron delete RegenerationAsset  <xsl:value-of select="$assetId"/></xsl:message>
        <cs:command name="com.censhare.api.assetmanagement.Delete">
            <cs:param name="source" select="$assetId"/>
            <cs:param name="state" select="'physical'"/>
        </cs:command>
    </xsl:function>

    <xsl:template match="asset[starts-with(@type, 'module.pptx-rebuild.')]">
        <xsl:message>=== Execute regeneration over rebuild asset <xsl:value-of select="@id"/></xsl:message>
        <!-- <child_asset_rel child_asset="18962" key="user.main-content." parent_asset="19010" /> -->
        <xsl:for-each select="child_asset_rel[@key='user.main-content.']/@child_asset">
            <xsl:variable name="pId" select="."/>
            <xsl:message>=== cron Regenerate Powerpoint  <xsl:value-of select="$pId"/></xsl:message>
            <xsl:value-of select="svtx:updateMasterPowerPoint($pId)"/>
        </xsl:for-each>

        <xsl:value-of select="svtx:deleteAsset(@id)"/>

        <!--
        <xsl:when test="child_asset_rel[@key='user.main-content.']"></xsl:when>
         <xsl:choose>
             <xsl:when test="child_asset_rel[@key='user.main-content.']"></xsl:when>
         </xsl:choose>
         -->
    </xsl:template>

</xsl:stylesheet>
