<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>


    <!-- Globale CONSTS -->

    <xsl:variable name="REL_WEBUSER" select="'user.web-usage.'"/>


    <!--
           erzeugt für Medien (Layout und PPTX) die jeweiligen Public-Versionen (text) aber nicht text.faq.
        - setzt ggf Daten der Originale zurück
        - und überführt ggf Public Versionen nach archived
        TODO ORTCONTENT-709
        UUID-Setzen wenn noch nicht vorhanden => aus ID-Orginal-Text
         <asset_feature feature="svtx:inherit-parent-uuid" value_string="{$updateUid}"/>
          + z.B. Makler oder so ?
        die Freigabe direkt unter den Artikel setzten
       -->
    <xsl:template match="/asset">
        <xsl:variable name="asset" select="." as="element(asset)"/>
        <xsl:message>CONTEXT ASSET ARCHIVE <xsl:value-of select="$asset/@id"/></xsl:message>
        <xsl:message>=== Generate Public/Archive Version of Text oder Media <xsl:value-of select="$asset/@type"/> </xsl:message>

        <xsl:choose>
            <xsl:when test="$asset[@type='presentation.issue.']">
                <xsl:variable name="ret" select="svtx:processPPTX($asset)"/>
            </xsl:when>
            <xsl:when test="$asset[@type='layout.']">
                <xsl:variable name="ret" select="svtx:processLayout($asset)"/>
            </xsl:when>
            <xsl:when test="$asset[starts-with(@type,'text.') and @type != 'text.faq.' ]">
                <xsl:variable name="ret1" select="svtx:publishTextAssets($asset)"/>
            </xsl:when>
            <xsl:otherwise><xsl:message>No work on <xsl:value-of select="$asset/@type"/></xsl:message></xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- schaut nach, ob eine svtx uuid vorhanden, sonst die Text ID + type
         FIX
         Nach letztem Gesräch immer ID des Artikels
    -->
    <xls:function name="svtx:getUUIDToUse" as="xs:string">
        <xsl:param name="textAsset"/>

        <xsl:value-of select="$textAsset/@id"/>
        <!--
                <xsl:variable name="uuid">
                    <xsl:choose>

                        <xsl:when test="$textAsset/cs:parent-rel()[@key='user.main-content.']">
                            <xsl:choose>
                                <xsl:when test="$textAsset/cs:parent-rel()[@key='user.main-content.']/asset_feature[@feature='censhare:target-group']">
                                    <xsl:value-of select="concat($textAsset/@id,'_',$textAsset/@type)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="if($textAsset/asset_feature[@feature='svtx:inherit-parent-uuid']) then $textAsset/asset_feature[@feature='svtx:inherit-parent-uuid']/@value_string
                  else  concat($textAsset/@id/@value_string,'_',$textAsset/@type)" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($textAsset/@id,'_',$textAsset/@type)"/>
                        </xsl:otherwise>

                    </xsl:choose>
                </xsl:variable>

                <xsl:message>getUUIDToUse <xsl:value-of select="$uuid"/></xsl:message>
                <xsl:value-of select="$uuid"/>
                -->
    </xls:function>

    <xsl:function name="svtx:selectValidFromOrCurrent" as="xs:string">
        <xsl:param name="asset"/>
        <xsl:value-of select="if($asset/asset_feature[@feature='svtx:media-valid-from']/@value_timestamp)
         then $asset/asset_feature[@feature='svtx:media-valid-from']/@value_timestamp  else  format-date(current-date(),'[Y0001]-[M01]-[D01]T00:00:00Z')" />
    </xsl:function>

    <xsl:function name="svtx:checkInNewAsset">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="result"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>

        <xsl:copy-of select="$result" />
    </xsl:function>



    <!-- liefert den TextVariantenType standard/sales/agent aus der der Relationsauswertung -->
    <xsl:function name="svtx:getTextVarianType" as="xs:string">
        <xsl:param name="articleText" as="element(asset)"/>
        <xsl:choose>
            <xsl:when test="$articleText/parent_asset_rel[@key='variant.1.']/asset_rel_feature[@feature='svtx:text-variant-type']/@value_key='sales'">
                <xsl:value-of select="'sales'"/>
            </xsl:when>
            <xsl:when test="$articleText/parent_asset_rel[@key='variant.1.']/asset_rel_feature[@feature='svtx:text-variant-type']/@value_key='agent'">
                <xsl:value-of select="'agent'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'standard'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- erzeugt eine Copy des Textasset, welches für hcms freigegeben wird
         Wenn das Original kein svtx:inherit-parent-uuid hat, wird es erzeugt
         - der Type wird text.subtexttype => text.public.subtexttype
         - im master werden die Sonder-Umbrüche (bresks) bearbeitet
         - setzt relation zu "user.main-content". zum Artikel
         - neu setzt  "user.main-content". zum Hauptartiel
    -->
    <xsl:function name="svtx:createTextCopy">
        <xsl:param name="articleText" as="element(asset)"/>
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:param name="publicTextType" as="xs:string"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:param name="validFrom" as="xs:string"/>
        <xsl:param name="validUntil" as="xs:string"/>

        <xsl:variable name="newName" select="$articleText/@name"/>
        <xsl:variable name="productName" select="svtx:getProductName($articleText)" />
        <xsl:variable name="svtxuuid" select="svtx:getUUIDToUse($articleText)"/>
        <xsl:variable name="masterArticle" select="svtx:getMasterArticle($articleText)"/>
        <xsl:variable name="clone"/>
        <cs:command name="com.censhare.api.assetmanagement.CloneAndCleanAssetXml" returning="clone">
            <cs:param name="source" select="$articleText"/>
        </cs:command>

        <xsl:variable name="forAdvisorSuite" select="if(contains($channel,'root.web.bs.')) then 'yes' else 'no'"/>
        <xsl:variable name="channelNo" select="svtx:channelToNumber($channel)"/>
        <xsl:variable name="tmpXmlFile" select="svtx:getTmpXmlWithRemovedSpecialBreaks($articleText,$forAdvisorSuite,$channelNo)"/>

        <xsl:variable name="textVarianType" select="svtx:getTextVarianType($articleText)"/>
        <xsl:variable name="newTextAsset">
            <asset type="{$publicTextType}" name="{$newName}" domain="{$publicDomain}">

                <xsl:copy-of select="$clone/node() except($clone/child_asset_rel[@key='variant.1.'],
                   $clone/asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type'],
                   $clone/asset_feature[@feature='svtx:preselected-output-channel'],
                   $clone/storage_item,
                   $clone/asset_feature[@feature='svtx:text-variant-type'],
                   $clone/asset_feature[@feature='svtx:inherit-parent-uuid'])"/>

                <storage_item corpus:asset-temp-file-url="{$tmpXmlFile}" element_idx="0" key="master" mimetype="text/xml" />
                <parent_asset_rel key="{$REL_WEBUSER}" parent_asset="{$articleAsset/@id}">

                </parent_asset_rel>
                <xsl:if test="$masterArticle/@id != $articleAsset/@id">
                    <parent_asset_rel key="{$REL_WEBUSER}" parent_asset="{$masterArticle/@id}" />
                </xsl:if>

                <asset_feature feature="censhare:output-channel"  value_key="{$channel}"/>
                <asset_feature feature="svtx:asset.id_original"  value_long="{$articleText/@id}"/>
                <xsl:variable name="oldTexts" select="$articleAsset/cs:child-rel()[@key='user.web-usage.']/cs:asset()[@censhare:output-channel=$channel]" as="element(asset)*"/>
                <xsl:variable name="maxVersion" select="max($oldTexts/asset_feature[@feature='censhare:approval.asset-version']/@value_long)" as="xs:long?"/>
                <xsl:variable name="versionCount" select="if ($maxVersion) then $maxVersion + 1 else 1" as="xs:long?"/>
                <asset_feature feature="svtx:asset.version"  value_long="{$versionCount}"/>

                <xsl:variable name="dt" select="current-dateTime()" as="xs:dateTime?"/>
                <!-- publication date -->
                <asset_feature feature="svtx:asset-publication-date" value_timestamp="{format-dateTime($dt,'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')}"/>

                <xsl:if test="$validUntil">
                    <asset_feature feature="svtx:media-valid-until"   value_timestamp="{ svtx:toDateTime($validUntil)}"/>
                </xsl:if>
                <xsl:if test="$validFrom">
                    <asset_feature feature="svtx:media-valid-from"   value_timestamp="{svtx:toDateTime($validFrom)}"/>
                </xsl:if>
                <xsl:if test="$productName">
                    <asset_feature feature="svtx:product-name"   value_string="{$productName}"/>
                </xsl:if>
                <asset_feature feature="svtx:text-variant-type"   value_key="{$textVarianType}"/>

                <asset_feature feature="svtx:inherit-parent-uuid"   value_string="{$svtxuuid}"/>
            </asset>
        </xsl:variable>

        <xsl:copy-of select="svtx:checkInNewAsset($newTextAsset)"/>
    </xsl:function>

    <xsl:function name="svtx:toDateTime">
        <xsl:param name="d"/>
        <xsl:value-of select="if ($d castable as xs:dateTime) then xs:dateTime($d) else if ($d castable as xs:date) then xs:dateTime(concat($d, 'T00:00:00Z')) else ''"/>
    </xsl:function>

    <!-- sucht den MasterArticle also keine parent-Rel variante mehr ist -->
    <!-- TODO masterArticle?   -->
    <xsl:function name="svtx:getMasterArticle">
        <xsl:param name="textAsset" as="element(asset)"/>
        <!-- direkt oder user-main/variant.1 -->
        <xsl:variable name="articleAsset" select="($textAsset/cs:parent-rel()[@key='user.main-content.'],$textAsset/cs:parent-rel()[@key = 'variant.1.']/cs:parent-rel()[@key='user.main-content.'])[1]"/>
        <xsl:variable name="vorMasterArticle" select="($articleAsset/cs:parent-rel()[@key = 'variant.1.']/cs:asset()[@censhare:asset.type = 'article.*'],$articleAsset)[1]"/>
        <xsl:variable name="masterArticle" select="($vorMasterArticle/cs:parent-rel()[@key = 'variant.']/cs:asset()[@censhare:asset.type = 'article.*'],$vorMasterArticle)[1]"/>

        <xls:message>==== getMasterArticle <xsl:value-of select="$textAsset/@id"/> :  <xsl:value-of select="$articleAsset/@id"/> : <xsl:value-of select="$masterArticle/@id"/>  </xls:message>
        <xsl:copy-of select="$masterArticle"  />
    </xsl:function>

    <!-- TODO macht das nach ORTCONTENT-709 noch so Sinn -->

    <xsl:function name="svtx:publishAssetsTillProduct">
        <xsl:param name="textAsset" as="element(asset)"/>

        <xsl:variable name="channels" as="xs:string*">
            <xsl:for-each select="$textAsset/asset_feature[@feature='svtx:preselected-output-channel']">
                <xsl:value-of  select="./@value_string" />
            </xsl:for-each>
        </xsl:variable>


        <xsl:variable name="masterArticle" select="svtx:getMasterArticle($textAsset)"/>
        <xsl:variable name="ret" select="svtx:setChannels($masterArticle,$channels)"/>
        <xsl:variable name="productAsset" select="$masterArticle/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*']"/>
        <xsl:variable name="ret2" select="svtx:setChannels($productAsset,$channels)"/>
    </xsl:function>

    <!-- setzt ggf fehlende Channes am Asset
        Freigaben
    -->
    <xsl:function name="svtx:setChannels">

        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="channels" as="xs:string*"/>
        <xsl:message>=== Set Channels <xsl:copy-of select="$channels"/> für <xsl:value-of select="$asset/@id"/> </xsl:message>

        <xsl:variable name="newChannels" as="xs:string*?">
            <xsl:for-each select="$channels">
                <xsl:variable name="channelKey" select="." as="xs:string"/>
                <xsl:if test="not($asset/asset_feature[@feature='censhare:output-channel' and @value_key=$channelKey])">
                    <xsl:value-of select="$channelKey"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="count($newChannels)">
            <xsl:variable name="updatedAsset" as="element(asset)?">
                <asset>
                    <xsl:copy-of select="$asset/@*"/>
                    <xsl:copy-of select="$asset/node()"/>
                    <xsl:for-each select="$newChannels">
                        <xsl:variable name="channelKey" select="." as="xs:string"/>
                        <asset_feature feature="censhare:output-channel"  value_key="{$channelKey}"/>
                    </xsl:for-each>
                </asset>
            </xsl:variable>

            <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAssetXml">
                <cs:param name="source" select="$updatedAsset"/>
            </cs:command>
        </xsl:if>
    </xsl:function>


    <!-- setzt bei allen Bilder des Textasset ggf. die Channels
         TODO Funktionsaufruf setChannesl nutzen
     -->
    <xsl:function name="svtx:publishPicture">
        <xsl:param name="textAsset" as="element(asset)"/>
        <!-- alle Medien -->
        <xsl:variable name="masterStorage" select="$textAsset/storage_item[@key='master' and @mimetype='text/xml']" as="element(storage_item)?"/>
        <xsl:variable name="xmlContent" select="if ($masterStorage/@url) then doc($masterStorage/@url) else ()"/>
        <xsl:variable name="pictureElements" select="$xmlContent//picture[@xlink:href]" as="element(picture)*"/>

        <xsl:variable name="relatedMediaAssets" select="$textAsset/cs:child-rel()[@key='user.media.']/cs:asset()[@censhare:asset.type='picture.*']" as="element(asset)*"/>
        <xsl:variable name="mediaAssetVariants" select="$relatedMediaAssets/cs:child-rel()[@key='user.channel-content.']/cs:asset()[@censhare:asset.type='picture.*']" as="element(asset)*"/>
        <xsl:variable name="relatedMediaAssetIds" select="($relatedMediaAssets, $mediaAssetVariants)/@id" as="xs:long*"/>

        <xsl:variable name="contentMediaAssetIds" select="for $x in $pictureElements/@xlink:href return svtx:getAssetIdFromCenshareUrl($x)" as="xs:long*"/>
        <xsl:for-each select="distinct-values(($relatedMediaAssetIds, $contentMediaAssetIds))">
            <xsl:variable name="mediaAssetId" select="." as="xs:long"/>
            <xsl:variable name="mediaAsset" select="cs:get-asset($mediaAssetId)"/>
            <xsl:if test="exists($mediaAsset)">
                <!-- Channels suchen, deren Freigabe fehlt -->
                <xsl:variable name="channels" as="xs:string*?">
                    <xsl:for-each select="$textAsset/asset_feature[@feature='svtx:preselected-output-channel']">
                        <xsl:variable name="channelKey" select="./@value_string" as="xs:string"/>

                        <xsl:if test="not($mediaAsset/asset_feature[@feature='censhare:output-channel' and @value_key=$channelKey])">
                            <xsl:value-of select="$channelKey"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="count($channels)">
                    <xsl:variable name="updatedAsset" as="element(asset)?">
                        <asset>
                            <xsl:copy-of select="$mediaAsset/@*"/>
                            <xsl:copy-of select="$mediaAsset/node()"/>
                            <xsl:for-each select="$channels">
                                <xsl:variable name="channelKey" select="." as="xs:string"/>
                                <asset_feature feature="censhare:output-channel"  value_key="{$channelKey}"/>
                            </xsl:for-each>
                        </asset>
                    </xsl:variable>
                    <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAssetXml">
                        <cs:param name="source" select="$updatedAsset"/>
                    </cs:command>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>



    <!-- publiziert ein Textasset für hcms
        -archiviert ältere Freigaben
        -erzeugt eine neues FreigabeTextas pro Channel
        -erzeugt eine Relation (user.web-usage.) zum  Artikel und Masterartikel
        - Gibt ggf. Artikel und Produkt für HCMS frei
        - Gibt die Bilder frei
    -->

    <xsl:function name="svtx:publishTextAssets" >
        <xsl:param name="textAsset"/>
        <xsl:variable name="articleAsset" select="if (svtx:isAssetVariant($textAsset))
            then ($textAsset/cs:parent-rel()[@key='variant.1.']/cs:parent-rel()[@key='user.main-content.'])[1]
            else ($textAsset/cs:parent-rel()[@key='user.main-content.'])[1]" as="element(asset)?"/>
        <xsl:variable name="productAsset" select="($articleAsset/cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type='product.*'])[1]" as="element(asset)?"/>

        <xsl:variable name="publicTextType" select="svtx:getPublicType($textAsset)"/>

        <xsl:for-each select="$textAsset/asset_feature[@feature='svtx:preselected-output-channel']">
            <xsl:variable name="channelKey" select="./@value_string" as="xs:string"/>
            <xsl:variable name="validFrom" select="./asset_feature[@feature='svtx:media-valid-from']/@value_timestamp" as="xs:string?"/>
            <xsl:variable name="validUntil" select="./asset_feature[@feature='svtx:media-valid-until']/@value_timestamp" as="xs:string?"/>
            <!-- <xsl:variable name="ret1" select="svtx:setToTextArchived($articleAsset,$publicTextType,$channelKey,$validFrom)"/> -->
            <xsl:variable name="ret1" select="svtx:setToTextArchivedV2($textAsset,$channelKey,$validFrom)"/>

            <xsl:variable name="validFrom1"  select="if($validFrom)then $validFrom else  format-date(current-date(),'[Y0001]-[M01]-[D01]T00:00:00Z')" />
            <xsl:variable name="ret" select="svtx:createTextCopy($textAsset,$articleAsset,$publicTextType,$channelKey,$validFrom1,$validUntil)"/>
        </xsl:for-each>
        <xsl:variable name="ret" select="svtx:publishPicture($textAsset)"/>
        <!--Update ohne Historyänderung  und löscht dabei die  Channels
        TODO funktioniert das? Haben wir noch svtx:preselected-output-channel?
        -->


        <!--<cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="checkedOutAsset">
            <cs:param name="source" select="$textAsset" />
        </cs:command>
        <xsl:variable name="newAsset" as="element(asset)">
            <asset wf_id="10" wf_step="30">
                <xsl:copy-of select="$checkedOutAsset/@* except $checkedOutAsset/(@wf_step, @wf_id)"/>
                <xsl:copy-of select="$checkedOutAsset/node() except($checkedOutAsset/asset_feature[@feature='svtx:preselected-output-channel'] )"/>
                <xsl:for-each select="$checkedOutAsset/asset_feature[@feature='svtx:preselected-output-channel']">
                    <asset_feature  feature="svtx:preselected-output-channel"   value_string="{./@value_string}"/> >
                </xsl:for-each>
            </asset>
        </xsl:variable>
        <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="checkedInAsset">
            <cs:param name="source" select="$newAsset" />
        </cs:command>-->
        <cs:command name="com.censhare.api.assetmanagement.Update" returning="updatedTextAsset">
            <cs:param name="source">
                <asset wf_id="10" wf_step="30">
                    <xsl:copy-of select="$textAsset/@* except $textAsset/(@wf_step, @wf_id)"/>
                    <xsl:copy-of select="$textAsset/node() except($textAsset/asset_feature[@feature='svtx:preselected-output-channel'] )"/>
                    <xsl:for-each select="$textAsset/asset_feature[@feature='svtx:preselected-output-channel']">
                        <asset_feature  feature="svtx:preselected-output-channel"   value_string="{./@value_string}"/> >
                    </xsl:for-each>
                </asset>
            </cs:param>
        </cs:command>
        <xsl:variable name="p" select="svtx:publishAssetsTillProduct($updatedTextAsset)"/>
    </xsl:function>

    <xsl:function name="svtx:additionalFeatures" as="element(additional)">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="productName" select="svtx:getProductName($asset)"/>
        <additional>
            <xsl:if test="$asset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp">
                <asset_feature feature="svtx:media-valid-until"   value_timestamp="{$asset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp}"/>
            </xsl:if>
            <xsl:if test="$asset/asset_feature[@feature='censhare:target-group']/@value_asset_id">
                <asset_feature feature="censhare:target-group"   value_asset_id="{$asset/asset_feature[@feature='censhare:target-group']/@value_asset_id}"/>
            </xsl:if>

            <xsl:if test="$asset/asset_feature[@feature='svtx:text-variant-type']/@value_key">
                <asset_feature feature="svtx:text-variant-type"  value_key="{$asset/asset_feature[@feature='svtx:text-variant-type']/@value_key}"/>
            </xsl:if>

            <xsl:if test="$asset/asset_feature[@feature='censhare:content-editor.config']/@value_asset_key_ref">
                <asset_feature feature="censhare:content-editor.config"   value_asset_key_ref="{$asset/asset_feature[@feature='censhare:content-editor.config']/@value_asset_key_ref}"/>
            </xsl:if>

            <xsl:if test="$asset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref">
                <asset_feature feature="svtx:layout-template-resource-key"  value_asset_key_ref="{$asset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref}"/>
            </xsl:if>

            <xsl:if test="$productName">
                <asset_feature feature="svtx:product-name"   value_string="{$productName}"/>
            </xsl:if>

            <xsl:if test="$asset/asset_feature[@feature='svtx:aem-template']">
                <asset_feature feature="svtx:aem-template" value_key="{$asset/asset_feature[@feature='svtx:aem-template']/@value_key}"/>
            </xsl:if>
        </additional>
    </xsl:function>


    <xsl:function name="svtx:getDocumentType" as="xs:string">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="clonedFrom" select="$asset/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref"/>
        <xls:choose>
            <xsl:when test="contains($clonedFrom,'flyer')">document.flyer.</xsl:when>
            <xsl:otherwise>document.psb.</xsl:otherwise>
        </xls:choose>
    </xsl:function>

    <xsl:function name="svtx:processLayout">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="ret1" select="svtx:setToArchived($asset,$asset/asset_feature[@feature='svtx:media-valid-from']/@value_timestamp)"/>

        <!-- Daten sammeln -->
        <xsl:variable name="pdfOnline" select="$asset/storage_item[@key='pdf-online'][1]" as="element(storage_item)?"/>
        <!-- TODO ist das auf Live auch so ? -->
        <xsl:variable name="pdfPrint" select="$asset/storage_item[@key='pdf-drbk-x4' or @key='pdf'][1]" as="element(storage_item)?"/>
        <xsl:variable name="tmpFilePdfOnline" select="svtx:createTmpFile($pdfOnline)"/>
        <xsl:variable name="tmpFilePdfPrint" select="svtx:createTmpFile($pdfPrint)"/>

        <xsl:variable name="validFrom" select="svtx:selectValidFromOrCurrent($asset)" as="xs:string" />

        <xls:variable name="printnumber" select="$asset/asset_feature[@feature='svtx:layout-print-number']/@value_string"/>
        <xsl:variable name="newName" select="concat($asset/@name,' ',format-date(current-date(),'[D01].[M01].[Y0001]'),' ',$printnumber)"/>


        <xsl:variable name="additional" select="svtx:additionalFeatures($asset)"/>

        <xsl:variable name="documentType" select="svtx:getDocumentType($asset)"/>

        <!-- neues Public Asset erzeugen -->
        <xsl:variable name="newAssetXml">
            <asset name="{$newName}" type="{$documentType}" domain="root.allianz-leben-ag.contenthub.public.">
                <parent_asset_rel key="user.publication." parent_asset="{$asset/@id}"/>

                <asset_element key="actual." idx="0"/>
                <xsl:if test="$pdfPrint">
                    <storage_item corpus:asset-temp-file-url="{$tmpFilePdfPrint}" element_idx="0" key="master" mimetype="application/pdf" />
                </xsl:if>
                <xsl:if test="$pdfOnline">
                    <storage_item corpus:asset-temp-file-url="{$tmpFilePdfOnline}" element_idx="0" key="pdf-online" mimetype="application/pdf" />
                </xsl:if>
                <asset_feature feature="svtx:media-valid-from"  value_timestamp="{$validFrom}"/>
                <asset_feature feature="svtx:layout-print-number"  value_string="{$printnumber}"/>

                <xsl:copy-of select="$additional/node()"/>
            </asset>
        </xsl:variable>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
                <xsl:copy-of select="$newAssetXml"/>
            </cs:param>
        </cs:command>

        <!-- diverse Daten im Layout löschen -->

        <!-- Update asset -->

        <xsl:variable name="checkedOutAsset" as="element(asset)?">
            <xsl:copy-of select="svtx:checkOutAsset($asset)"/>
        </xsl:variable>
        <xsl:variable name="printNumberOld" select="$checkedOutAsset/asset_feature[@feature='svtx:layout-print-number']/@value_string" as="xs:string?"/>
        <xsl:variable name="updatedAsset" as="element(asset)?">
            <asset>
                <xsl:copy-of select="$checkedOutAsset/@*"/>
                <xsl:copy-of select="$checkedOutAsset/node() except($checkedOutAsset/asset_feature[@feature='svtx:media-valid-until'],
                $checkedOutAsset/asset_feature[@feature='svtx:media-valid-from'],$checkedOutAsset/asset_feature[@feature=('svtx:layout-print-number','svtx:layout-print-number-old')])"/>
                <xsl:if test="$printNumberOld">
                    <asset_feature feature="svtx:layout-print-number-old" value_string="{$printNumberOld}"/>
                </xsl:if>
            </asset>
        </xsl:variable>

        <xsl:variable name="checkedInAsset" as="element(asset)?">
            <xsl:copy-of select="svtx:checkInAsset($updatedAsset)"/>
        </xsl:variable>
    </xsl:function>

    <xsl:function name="svtx:getProductName" as="xs:string?">
        <xsl:param name="asset"  as="element(asset)"/>

        <xsl:variable name="product" select="($asset/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $asset/cs:parent-rel()[@key='variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $asset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*'],
                      $asset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*']
                      )[1]"/>

        <xsl:value-of select="$product/@name"/>
    </xsl:function>

    <!--  setzt die public version des MEdium-Assets, wenn vorhanden, auf archived bzw setzt endDatum  -->
    <xsl:function name="svtx:setToArchived">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="validFrom"/> <!--welcher Typ? -->

        <xsl:message>count ===  <xsl:value-of select="count($asset/cs:child-rel()[@key='user.publication.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.'])"/> </xsl:message>

        <xsl:choose>
            <!-- ist direkt gültig -->
            <xsl:when test="not($validFrom)">
                <xsl:message>
                    NOT VALIDFROM
                </xsl:message>
                <xsl:for-each select="$asset/cs:child-rel()[@key='user.publication.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.']">
                    <xsl:variable name="currentAsset" select="."/>
                    <xsl:variable name="validUntil" select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>
                    <xsl:if test="not($validUntil)">
                        <xsl:message>archiveren des alten ==== <xsl:value-of select="$currentAsset/@id"/> </xsl:message>
                        <cs:command name="com.censhare.api.assetmanagement.Update">
                            <cs:param name="source">
                                <asset domain="root.allianz-leben-ag.archive.">
                                    <xsl:copy-of select="$currentAsset/@* except($currentAsset/@domain)"/>
                                    <xsl:copy-of select="$currentAsset/node()"/>
                                </asset>
                            </cs:param>
                        </cs:command>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$asset/cs:child-rel()[@key='user.publication.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.']">
                    <xsl:variable name="currentAsset" select="."/>
                    <xsl:variable name="validUntil" select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>

                    <xsl:message>
                        <asset_feature feature="svtx:media-valid-until"   value_timestamp="{$validFrom}"/>
                    </xsl:message>

                    <xsl:if test="not($validUntil)">
                        <xsl:message>setzen validUntil ==== <xsl:value-of select="$validFrom"/> </xsl:message>
                        <cs:command name="com.censhare.api.assetmanagement.Update">
                            <cs:param name="source">
                                <asset>
                                    <xsl:copy-of select="$currentAsset/@*"/>
                                    <xsl:copy-of select="$currentAsset/node()"/>
                                    <asset_feature feature="svtx:media-valid-until"   value_timestamp="{$validFrom}"/>
                                </asset>
                            </cs:param>
                        </cs:command>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>



    <xsl:function name="svtx:setToTextArchivedV2">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:param name="validFrom"/> <!--welcher Typ? -->

        <xsl:variable name="bsChannel" select="'root.web.bs.'" as="xs:string"/>
        <xsl:variable name="masterArticle" select="svtx:getMasterArticle($textAsset)"/>
        <!-- wir müssen dan nur noch vom masterArtikel alle user.web-usage. textAsset mit der svtxUUID=textAsset/id suchen
          die @censhare:asset.domain ='root.allianz-leben-ag.contenthub.public. sind
          -->
        <xsl:choose>
            <!-- ist direkt gültig -->
            <xsl:when test="not($validFrom) or $channel=$bsChannel">
                <xsl:for-each
                        select="$masterArticle/cs:child-rel()[@key='user.web-usage.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' ]">

                    <xsl:variable name="currentAsset" select="."/>
                    <xsl:if test="$currentAsset/asset_feature[@feature='svtx:inherit-parent-uuid']/@value_string = $textAsset/@id">
                        <xsl:variable name="validUntil"
                                      select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>
                        <xsl:variable name="currentChannel"
                                      select="($currentAsset/asset_feature[@feature='censhare:output-channel'])[1]/@value_key"
                                      as="xs:string?"/>

                        <xsl:if test="($channel=$currentChannel)  and  (not($validUntil) or $bsChannel=$channel)">
                            <xsl:message>archiveren des alten ====
                                <xsl:value-of select="$currentAsset/@id"/>
                            </xsl:message>
                            <cs:command name="com.censhare.api.assetmanagement.Update">
                                <cs:param name="source">
                                    <asset domain="root.allianz-leben-ag.archive.">
                                        <xsl:copy-of select="$currentAsset/@* except($currentAsset/@domain)"/>
                                        <xsl:copy-of select="$currentAsset/node() except $currentAsset/asset_feature[@feature='censhare:output-channel']"/>
                                    </asset>
                                </cs:param>
                            </cs:command>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each
                        select="$masterArticle/cs:child-rel()[@key='user.web-usage.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.']">
                    <xsl:variable name="currentAsset" select="."/>

                    <xsl:if test="$currentAsset/asset_feature[@feature='svtx:inherit-parent-uuid']/@value_string = $textAsset/@id">

                        <xsl:variable name="validUntil"
                                      select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>
                        <xsl:variable name="currentChannel"
                                      select="($currentAsset/asset_feature[@feature='censhare:output-channel'])[1]/@value_key"
                                      as="xs:string?"/>
                        <xsl:if test="($channel=$currentChannel)  and  not($validUntil)">
                            <xsl:variable name="vf" select="svtx:dayBefore($validFrom)"/>
                            <xsl:message>setzen validUntil ====
                                <xsl:value-of select="$vf"/>
                            </xsl:message>
                            <xsl:message>VALID_FROM
                                <xsl:value-of select="$validFrom"/>
                            </xsl:message>
                            <cs:command name="com.censhare.api.assetmanagement.Update">
                                <cs:param name="source">
                                    <asset>
                                        <xsl:copy-of select="$currentAsset/@*"/>
                                        <xsl:copy-of select="$currentAsset/node()"/>
                                        <asset_feature feature="svtx:media-valid-until" value_timestamp="{$vf}"/>
                                    </asset>
                                </cs:param>
                            </cs:command>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:function>

    <!--  setzt die public version(en) des Text-Assets, wenn vorhanden, auf archived bzw setzt endDatum
    TODO ggf. main-Content zu masterArticle löschen?
      if count(moin-Conten > 1) and rel-Maincontent 1= directes Article Asset bzw varinate.1
    -->
    <xsl:function name="svtx:setToTextArchived">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:param name="publicTextType" as="xs:string"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:param name="validFrom"/> <!--welcher Typ? -->

        <xsl:message>count ===  <xsl:value-of select="count($articleAsset/cs:child-rel()[@key='user.main-content.']/
        cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' and @censhare:asset.type=$publicTextType])"/> </xsl:message>

        <xsl:choose>
            <!-- ist direkt gültig -->
            <xsl:when test="not($validFrom)">
                <xsl:for-each select="$articleAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' and @censhare:asset.type=$publicTextType]">
                    <xsl:variable name="currentAsset" select="."/>
                    <xsl:variable name="validUntil" select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>
                    <xsl:variable name="currentChannel" select="($currentAsset/asset_feature[@feature='censhare:output-channel'])[1]/@value_key" as="xs:string"/>

                    <xsl:if test="($channel=$currentChannel)  and  not($validUntil)">
                        <xsl:message>archiveren des alten ==== <xsl:value-of select="$currentAsset/@id"/> </xsl:message>
                        <cs:command name="com.censhare.api.assetmanagement.Update">
                            <cs:param name="source">
                                <asset domain="root.allianz-leben-ag.archive.">
                                    <xsl:copy-of select="$currentAsset/@* except($currentAsset/@domain)"/>
                                    <xsl:copy-of select="$currentAsset/node()"/>
                                </asset>
                            </cs:param>
                        </cs:command>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$articleAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' and @censhare:asset.type=$publicTextType]">
                    <xsl:variable name="currentAsset" select="."/>
                    <xsl:variable name="validUntil" select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>
                    <xsl:variable name="currentChannel" select="($currentAsset/asset_feature[@feature='censhare:output-channel'])[1]/@value_key" as="xs:string"/>
                    <xsl:if test="($channel=$currentChannel)  and  not($validUntil)">
                        <xsl:variable name="vf" select="svtx:dayBefore($validFrom)"/>
                        <xsl:message>setzen validUntil ==== <xsl:value-of select="$vf"/> </xsl:message>
                        <xsl:message>VALID_FROM <xsl:value-of select="$validFrom"/> </xsl:message>
                        <cs:command name="com.censhare.api.assetmanagement.Update">
                            <cs:param name="source">
                                <asset>
                                    <xsl:copy-of select="$currentAsset/@*"/>
                                    <xsl:copy-of select="$currentAsset/node()"/>
                                    <asset_feature feature="svtx:media-valid-until"   value_timestamp="{$vf}"/>
                                </asset>
                            </cs:param>
                        </cs:command>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="svtx:dayBefore">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="date2" select="if ($date castable as xs:dateTime) then xs:dateTime($date) else xs:dateTime(concat($date, 'T00:00:00Z'))" as="xs:dateTime?"/>
        <xsl:value-of select="$date2 - xsd:dayTimeDuration('P1D')"/>
    </xsl:function>


    <xsl:function name="svtx:processText">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="srcFile" select="$asset/storage_item[@key='master'][1]" as="element(storage_item)?"/>
        <xsl:variable name="tmpFile" select="svtx:createTmpFile($srcFile)"/>
        <xsl:variable name="newName" select="concat($asset/@name,' ',format-date(current-date(),'[D01].[M01].[Y0001]'))"/>

        <xsl:variable name="additional" select="svtx:additionalFeatures($asset)"/>
        <xsl:variable name="newAssetXml">
            <asset name="{$newName}"  domain="root.allianz-leben-ag.contenthub.public." type="{$asset/@type}">
                <parent_asset_rel key="user.publication." parent_asset="{$asset/@id}"/>
                <asset_element key="actual." idx="0"/>
                <storage_item corpus:asset-temp-file-url="{$tmpFile}" element_idx="0" key="master" mimetype="application/xhtml+xml" />

                <xsl:copy-of select="$additional/node()"/>

            </asset>
        </xsl:variable>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
                <xsl:copy-of select="$newAssetXml"/>
            </cs:param>
        </cs:command>

    </xsl:function>



    <!-- erzeugt eine tmp Datei mit der gereinigten XML-Text-Datei -->
    <xsl:function name="svtx:getTmpXmlWithRemovedSpecialBreaks" as="xs:string">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:param name="advisorySuite" as="xs:string"/>
        <xsl:param name="channelNo" as="xs:integer"/>
        <xsl:variable name="transformed" />
        <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="transformed">
            <cs:param name="key" select="'svtx:web_text_transform_linebreak'"/>
            <cs:param name="source" select="$textAsset"/>
            <cs:param name="xsl-parameters">
                <cs:param name="advisorySuite" select="$advisorySuite"/>
                <cs:param name="channel" select="$channelNo"/>
            </cs:param>
        </cs:command>

        <xsl:message>XML ==== <xsl:copy-of select="$transformed"/></xsl:message>

        <xsl:variable name="out"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="filename" select="concat($out, 'temp-text')" as="xs:string?"/>

        <cs:command name="com.censhare.api.io.WriteXML" dissolve-document-fragments="false">
            <cs:param name="source" select="$transformed"/>
            <cs:param name="dest" select="$filename"/>
            <cs:param name="output">
                <output indent="no"/>
                <output method="xml"/>
                <output omit-xml-declaration="yes"/>
            </cs:param>
        </cs:command>

        <xsl:value-of select="$filename"/>
    </xsl:function>

    <xsl:function name="svtx:processPPTX">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="srcFile" select="$asset/storage_item[@key='master'][1]" as="element(storage_item)?"/>
        <xsl:variable name="tmpFile" select="svtx:createTmpFile($srcFile)"/>

        <xsl:variable name="ret1" select="svtx:setToArchived($asset,$asset/asset_feature[@feature='svtx:media-valid-from']/@value_timestamp)"/>

        <xsl:variable name="validFrom" select="svtx:selectValidFromOrCurrent($asset)" as="xs:string" />
        <xsl:message>===== valid from  <xsl:value-of  select="$validFrom"/>     </xsl:message>
        <xsl:variable name="newName" select="concat($asset/@name,' ',format-date(current-date(),'[D01].[M01].[Y0001]'))"/>

        <xsl:variable name="additional" select="svtx:additionalFeatures($asset)"/>
        <xsl:variable name="newAssetXml">
            <asset name="{$newName}" type="presentation." domain="root.allianz-leben-ag.contenthub.public.">
                <parent_asset_rel key="user.publication." parent_asset="{$asset/@id}"/>
                <asset_element key="actual." idx="0"/>
                <storage_item corpus:asset-temp-file-url="{$tmpFile}" element_idx="0" key="master" mimetype="application/vnd.openxmlformats-officedocument.presentationml.presentation" />
                <asset_feature feature="svtx:media-valid-from"  value_timestamp="{$validFrom}"/>
                <xsl:copy-of select="$additional/node()"/>
            </asset>
        </xsl:variable>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
            <cs:param name="source">
                <xsl:copy-of select="$newAssetXml"/>
            </cs:param>
        </cs:command>
    </xsl:function>


    <!-- erzeugt eine Kopie der Datei auf einem tmp Verzeichnis, wobei der Dateiname gleich bleibt -->

    <xsl:function name="svtx:createTmpFile">
        <xsl:param name="srcFilePath"/>
        <xsl:choose>
            <xsl:when test="$srcFilePath">
                <xsl:message>==== create tmp SRC</xsl:message>
                <xsl:variable name="fileName" select="tokenize($srcFilePath/@url, '\/')[last()]" as="xs:string?"/>
                <xsl:variable name="out"/>
                <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
                <xsl:variable name="destFile" select="concat($out, '.', $fileName)"/>
                <cs:command name="com.censhare.api.io.Copy">
                    <cs:param name="source" select="$srcFilePath"/>
                    <cs:param name="dest" select="$destFile"/>
                </cs:command>
                <xsl:value-of select="$destFile"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="svtx:checkOutAsset" as="element(asset)?">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="result"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

    <xsl:function name="svtx:checkInAsset">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:variable name="result"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

    <xsl:function name="svtx:getAssetIdFromCenshareUrl" as="xs:string?">
        <xsl:param name="url" as="xs:string?"/>
        <xsl:value-of select="substring-after($url, 'censhare:///service/assets/asset/id/')"/>
    </xsl:function>


</xsl:stylesheet>
