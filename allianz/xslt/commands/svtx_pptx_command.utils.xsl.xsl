<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        exclude-result-prefixes="#all"
        version="2.0">

    <!-- Wenn die SlideID  einer PowerpointDAtei zugeordnet ist, wird diese neu Aufgebaut  -->
    <xsl:function name="svtx:updateMasterPowerPoint">
        <xsl:param name="slideId"/>
        <xsl:variable name="pptxAsset" select="cs:get-asset(xs:long($slideId))" as="element(asset)?"/>
        <!-- <parent_asset_rel   key="target." parent_asset="17675" /> -->
        <xsl:variable name="assetId"  select="$pptxAsset/parent_asset_rel[@key='target.']/@parent_asset"  />
        <xsl:message>===Haben wir master pptx <xsl:value-of select="$assetId"/>  </xsl:message>
        <xsl:if test="$assetId">
            <xsl:message>===Bearbeiten Master </xsl:message>
            <xsl:variable name="asset" select="cs:get-asset(xs:long($assetId))" as="element(asset)?"/>
            <xsl:if test="exists($asset[@type='presentation.issue.'])">
                <xsl:message>===Bearbeiten Master merge </xsl:message>
                <xsl:value-of select="svtx:pptxFunctions($assetId,'merge','')"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>


<!-- ruft das Powerpoint Modul auf -->
<xsl:function name="svtx:pptxFunctions">
    <xsl:param name="pptxId"/>
    <xsl:param name="command"/>
    <xsl:param name="additionalData"/>
    <xsl:message>===update pptx <xsl:value-of select="$pptxId"/> : <xsl:value-of select="$command"/> </xsl:message>
    <xsl:message>=== additionalData    <xsl:copy-of select="$additionalData"/></xsl:message>
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
                    <xsl:copy-of select="$additionalData"/>
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

    <!-- Ruft die Standard-Funktion von Censhare auf um die Previews und thumbnails für das Asset neu zu generieren  -->
    <xsl:function name="svtx:updateAssetPreview">
        <xsl:param name="pptxId"/>
        <xsl:variable name="command-xml">
            <cmd timeout="600">
                <xml-info title="Update Previews " locale="__ALL">
                </xml-info>
                <cmd-info name="RebuildPreview PPTX"/>
                <commands currentstep="command">
                    <command target="ScriptletManager" method="postEvent" scriptlet="modules.preview_maker.RebuildPreview"/>
                </commands>
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



    <xsl:function name="svtx:updateSlideFromMaster">
    <xsl:param name="slideasset" as="element(asset)?"/>
    <xsl:param name="resourceKey"/>
    <xsl:param name="hasArticle"/>
      <xsl:copy-of select="svtx:updateSlideFromMasterV2($slideasset,$resourceKey,$hasArticle,'')"/>;
    </xsl:function>

    <!-- Tauscht das Storage-Item eines Slides gegen die Mastervorlage(resourceKey) aus und macht ggf. ein update
        wenn ein nuer Name vorhanden ist, wird auch dieser neu gesetzt (Template-Wechsel)
    -->
    <xsl:function name="svtx:updateSlideFromMasterV2">
        <xsl:param name="slideasset" as="element(asset)?"/>
        <xsl:param name="resourceKey"/>
        <xsl:param name="hasArticle"/>
        <xsl:param name="newName"/>
        <!-- Slide TemplateAsset anhand des ResourceKeys  laden-->
        <xsl:variable name="templateAsset" select="cs:asset()[@censhare:resource-key=$resourceKey]" as="element(asset)?"/>
        <!-- Gibt es das Asset und ist vom richtigen Typ? -->
        <xsl:if test="$templateAsset and $templateAsset/@type='presentation.slide.'">
            <!-- TODO and @mimetype='application/vnd.openxmlformats-officedocument.presentationml.presentation' schauen, ob immer der Mimetype -->
            <xsl:variable name="masterStorageTemplateSlide" select="$templateAsset/storage_item[@key='master'][1]" as="element(storage_item)?"/>
            <xsl:if test="$masterStorageTemplateSlide">
                <!-- Virtuelles File-System anlegen und die Datei dahin kopieren -->
                <xsl:variable name="fileExt" select="tokenize($masterStorageTemplateSlide/@url, '\.')[last()]" as="xs:string?"/>
                <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
                <xsl:variable name="destFile" select="concat($out, '.', $fileExt)"/>

                <cs:command name="com.censhare.api.io.Copy">
                    <cs:param name="source" select="$masterStorageTemplateSlide"/>
                    <cs:param name="dest" select="$destFile"/>
                </cs:command>

                <xsl:variable name="assetName" select="if(string-length($newName)>0) then $newName else  $slideasset/@name "/>
                <xsl:variable name="resultAssetXml"/>
                <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAssetXml">
                    <cs:param name="source">
                        <asset>
                            <!--
                            Alles ausser dem Storage Item und den pptx feature sowie svtx:layout-template-resource-key und name kopieren.
                            Storage item neu vom Template und pptx feature vom Template übernehmen.
                            -->
                            <xsl:copy-of select="$slideasset/@* except($slideasset/@name)"/>
                            <xsl:attribute name="name" select="$assetName"/>
                            <xsl:copy-of
                                    select="$slideasset/node() except ($slideasset/storage_item,$slideasset/asset_feature[starts-with(@feature,'savotex:pp.')],
                                       $slideasset/asset_feature[starts-with(@feature,'svtx:layout-template-creation-date')],
                                       $slideasset/asset_feature[starts-with(@feature,'svtx:layout-template-version')],
                                       $slideasset/asset_feature[@feature='svtx:layout-template-resource-key'] )"/>
                            <xsl:copy-of select="$templateAsset/asset_feature[starts-with(@feature,'savotex:pp.')]"/>
                            <asset_feature feature="svtx:layout-template-creation-date" value_timestamp="{$templateAsset/@creation_date}"/>
                            <asset_feature feature="svtx:layout-template-version" value_long="{$templateAsset/@version}"/>
                            <asset_feature feature="svtx:layout-template-resource-key" value_asset_key_ref="{$resourceKey}"/>

                            <storage_item  filesys_name="assets"
                                           key="master" element_idx="0"  mimetype="application/vnd.openxmlformats-officedocument.presentationml.presentation"
                                           corpus:asset-temp-file-url="{$destFile}"/>
                        </asset>
                    </cs:param>
                </cs:command>
                <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
                    <cs:param name="flush" select="false()"/>
                </cs:command>

                <xsl:if test="$hasArticle">
                    <xsl:value-of select="svtx:pptxFunctions($resultAssetXml/@id,'update','')"/>
                </xsl:if>
                <!-- sonst nur neues generieren der Preview/Thumbnails -->
                <xsl:if test="not($hasArticle)">
                    <xsl:value-of select="svtx:updateAssetPreview($resultAssetXml/@id)"/>
                </xsl:if>
                <!-- und merge der Powerpoint -->
                <xsl:value-of select="svtx:updateMasterPowerPoint($resultAssetXml/@id)"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>
