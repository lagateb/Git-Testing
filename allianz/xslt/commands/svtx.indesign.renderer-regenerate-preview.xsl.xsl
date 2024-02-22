<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">


    <xsl:function name="svtx:printNumberHasChanged"  as="xs:boolean">
        <xsl:param name="assetId"/>
        <xsl:variable name="checkedOutAsset" select="cs:get-asset($assetId,0, 0)"/>

        <xsl:variable name="currentPrintNumber" select="$checkedOutAsset/asset_feature[@feature='svtx:layout-print-number']/@value_string" />
        <xsl:message>#### currentPrintNumber#<xsl:value-of select="$currentPrintNumber"/>#</xsl:message>
        <xsl:variable name="currentVersion" select="$checkedOutAsset/@version"/>
        <xsl:message>#### currentVersion <xsl:value-of select="$currentVersion"/></xsl:message>
        <xsl:variable name="oldAsset" select="cs:get-asset($checkedOutAsset/@id,$currentVersion - 1, 0)"/>
        <xsl:variable name="oldPrintNumber" select="$oldAsset/asset_feature[@feature='svtx:layout-print-number']/@value_string" />
        <xsl:message>#### oldPrintNumber:<xsl:value-of select="$oldPrintNumber"/>#</xsl:message>
        <xsl:message>#### oldVersion:<xsl:value-of select="$oldAsset/@version"/>#</xsl:message>
        <xsl:value-of select="$currentPrintNumber and ($currentPrintNumber ne $oldPrintNumber)"/>
    </xsl:function>



    <!-- Transformation um die geänderte printNumber in der Preview sichtbar zu machen -->
    <xsl:template match="/asset[@type = 'layout.']">
        <xsl:message>### Preview ### LAYOUT #### <xsl:value-of select="@id"/></xsl:message>
        <xsl:variable name="isNew" select="svtx:printNumberHasChanged(@id)"/>
        <xsl:if test="$isNew">

            <xsl:message>### Preview ### LAYOUT #### UPDATE for PRINTNUMBER</xsl:message>

            <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutAsset">
                <cs:param name="source" select="@id"/>
            </cs:command>

            <xsl:variable name="indesignStorageItem" select="$checkedOutAsset/storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>

            <xsl:if test="$indesignStorageItem">


                <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)" as="xs:string"/>
                <xsl:variable name="renderResult">
                    <cs:command name="com.censhare.api.Renderer.Render">
                        <cs:param name="facility" select="$appVersion"/>
                        <cs:param name="instructions">
                            <cmd>
                                <renderer>
                                    <command method="open" asset_id="{ $checkedOutAsset/@id }" document_ref_id="1"/>
                                    <command document_ref_id="1" method="correct-document" force-correction="true" force-conversion="true"/>
                                    <command delete-target-elements="false" document_ref_id="1" force="true" method="update-asset-element-structure" sync-target-elements="false"/>
                                    <command document_ref_id="1" scale="1.0" method="preview"/>
                                    <command method="save" document_ref_id="1"/>
                                    <command method="close" document_ref_id="1"/>
                                </renderer>
                                <assets>
                                    <!-- Add assets -->
                                    <!-- layout -->
                                    <xsl:copy-of select="$checkedOutAsset"/>
                                </assets>
                            </cmd>
                        </cs:param>
                    </cs:command>
                </xsl:variable>
                <xsl:variable name="saveResult" select="$renderResult/cmd/renderer/command[@method = 'save']" as="element(command)?"/>
                <xsl:variable name="previewResult" select="$renderResult/cmd/renderer/command[@method = 'preview']" as="element(command)?"/>
                <xsl:variable name="layoutResult" select="$renderResult/cmd/assets/asset[1]" as="element(asset)?"/>
                <cs:command name="com.censhare.api.assetmanagement.CheckIn">
                    <cs:param name="source">
                        <asset>
                            <xsl:copy-of select="$layoutResult/@*"/>
                            <storage_item app_version="{$saveResult/@corpus:app_version}"
                                          key="master" element_idx="0" mimetype="application/indesign"
                                          corpus:asset-temp-filepath="{$saveResult/@corpus:asset-temp-filepath}"
                                          corpus:asset-temp-filesystem="{$saveResult/@corpus:asset-temp-filesystem}"/>
                            <xsl:for-each select="$previewResult/file">
                                <storage_item key="preview" mimetype="image/jpeg" element_idx="{@element_idx}">
                                    <xsl:variable name="fileSystem" select="@corpus:asset-temp-filesystem"/>
                                    <xsl:variable name="filePath" select="@corpus:asset-temp-filepath"/>
                                    <xsl:variable name="currentPath" select="concat('censhare:///service/filesystem/', $fileSystem, '/', tokenize($filePath, ':')[2])"/>
                                    <xsl:attribute name="corpus:asset-temp-file-url" select="$currentPath"/>
                                </storage_item>
                            </xsl:for-each>
                            <xsl:copy-of select="$layoutResult/* except $layoutResult/storage_item"/>
                        </asset>
                    </cs:param>
                </cs:command>
            </xsl:if>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
