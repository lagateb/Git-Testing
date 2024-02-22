<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform" xmlns:scl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsp="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>

    <!-- TODO change it -->
    <xsl:variable name="webTypes" select="'root.web.aem.aem-vp.,root.web.aem.aem-azde.,root.web.bs.,root.web.bs.bs-dev.'"/>

    <xsl:variable name="REL_WEBUSER" select="'user.web-usage.'"/>
    <xsl:variable name="newStep" select="'35'"/>
    <!--
       erzeugt für FAQ-Article texte die Web-Assets
        - setzt ggf Daten und setzt den Status der Texte auf Text zur Nutzung freigegeben  wf_step="35"
       -->

    <xsl:template match="/asset[@type='article.optional-module.faq.']">
        <xsl:variable name="asset" select="." as="element(asset)"/>
        <xsl:message>=== Generate Public/Archive Version of FAQ Text</xsl:message>
        <xsl:variable name="ret" select="svtx:publishFAQTextAssets($asset)"/>

        <xsl:variable name="ret1" select="svtx:setNewWFStep($asset)"/>

        <!-- und Freigabbezeiten löschen

        Testen !!!
           <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>


        <xsl:variable name="newAsset" select="cs:get-asset($asset/@id,0,0)"/>
        <xsl:variable name="newAsset2">
            <asset>
                <xsl:copy-of select="$newAsset/@*"/>
                <xsl:copy-of select="$newAsset/node() except $newAsset/asset_feature[@feature='svtx:preselected-output-channel']"/>
            </asset>
        </xsl:variable>
        <xsl:variable name="ret2" select="svtx:update($newAsset2)"/>

       -->
    </xsl:template>



    <!--  setzt die public version(en) des Text-Assets, wenn vorhanden, auf archived bzw setzt endDatum  -->
    <xsl:function name="svtx:setToTextArchived">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:param name="publicTextType" as="xs:string"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:param name="validFrom"/> <!--welcher Typ? -->

        <xsl:message>count ===  <xsl:value-of select="count($articleAsset/cs:child-rel()[@key=$REL_WEBUSER]/
        cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' and @censhare:asset.type=$publicTextType])"/> </xsl:message>

        <xsl:choose>
            <!-- ist direkt gültig -->
            <xsl:when test="not($validFrom)">
                <xsl:for-each select="$articleAsset/cs:child-rel()[@key=$REL_WEBUSER]/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' and @censhare:asset.type=$publicTextType]">
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
                <xsl:for-each select="$articleAsset/cs:child-rel()[@key=$REL_WEBUSER]/cs:asset()[@censhare:asset.domain ='root.allianz-leben-ag.contenthub.public.' and @censhare:asset.type=$publicTextType]">
                    <xsl:variable name="currentAsset" select="."/>
                    <xsl:variable name="validUntil" select="$currentAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp"/>
                    <xsl:variable name="currentChannel" select="($currentAsset/asset_feature[@feature='censhare:output-channel'])[1]/@value_key" as="xs:string"/>
                    <xsl:if test="($channel=$currentChannel)  and  not($validUntil)">
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








    <xsl:function name="svtx:publishFAQTextAssets" >
        <xsl:param name="articleAsset"/>
        <xsl:variable name="textMedias" select="svtx:getAllFAQTextAssetsIds($articleAsset)"/>

        <xsl:variable name="validFrom" select="$articleAsset/asset_feature[@feature='svtx:media-valid-from']/@value_timestamp" as="xs:string?"/>
        <xsl:variable name="validUntil" select="$articleAsset/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp" as="xs:string?"/>
        <xsl:variable name="productName" select="svtx:getProductName($articleAsset)" />
        <xsl:for-each select="tokenize($webTypes, ',')">
            <xsl:variable name="channelKey" select="." as="xs:string"/>
            <xsl:variable name="xmlChannelText" select="svtx:createTextXMLForChannel($textMedias,$channelKey)"/>
            <xsl:if test="count($xmlChannelText//faq) > 0">

                <xsl:variable name="channelElement" select="$articleAsset/asset_feature[@feature='svtx:preselected-output-channel' and value_string=$channelKey]"/>
                <xsl:variable name="validFrom" select="$channelElement/asset_feature[@feature='svtx:media-valid-from']/@value_timestamp" as="xs:string?"/>
                <xsl:variable name="validUntil" select="$channelElement/asset_feature[@feature='svtx:media-valid-until']/@value_timestamp" as="xs:string?"/>
                <xsl:variable name="ret1" select="svtx:setToTextArchived($articleAsset,$faqPublicType,$channelKey,$validFrom)"/>
                <xsl:message>diversions ===  <xsl:value-of select="$channelKey"/>    <xsl:value-of select="$validFrom"/> <xsl:value-of select="$validUntil"/>  <xsl:copy-of select="$channelElement"/>   </xsl:message>
                <xsl:variable name="ret" select="svtx:createTextAsset($articleAsset/@name,$xmlChannelText,$articleAsset/@id,$channelKey,$validFrom,$validUntil,$productName)"/>

            </xsl:if>
        </xsl:for-each>
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="false()"/>
        </cs:command>
        <xsl:variable name="ret" select="svtx:setChannels($articleAsset,$webTypes)"/>
        <xsl:variable name="productAsset" select="$articleAsset/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type ='product.*']"/>
        <xsl:variable name="ret2" select="svtx:setChannels($productAsset,$webTypes)"/>
    </xsl:function>



    <xsl:function name="svtx:setNewWFStep">
        <xsl:param name="articleAsset" as="element(asset)" />
        <xsl:for-each select="($articleAsset/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.' and @censhare:asset.wf_step='30'])">
            <xsl:variable name="textAsset" select="."/>
            <xsl:variable name="ret" select ="svtx:setWFStepTo($textAsset,$newStep)" />
        </xsl:for-each>
    </xsl:function>


    <xsl:function name="svtx:update" as="element(asset)">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="ret"/>
        <cs:command name="com.censhare.api.assetmanagement.Update" returning="ret">
            <cs:param name="source" select="$asset"/>
        </cs:command>
        <xsl:copy-of select="$ret"/>
    </xsl:function>

    <!-- setzt den WorkFlowStep des Asset und Updated(saved) es -->
    <xsl:function name="svtx:setWFStepTo" as="element(asset)">
        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="newStep" as="xs:string" />
        <xsl:variable name="newAsset" as="element(asset)?">
            <asset  wf_step="{$newStep}">
                <xsl:copy-of select="$asset/@*[not(local-name() = 'wf_step')]"/>
                <xsl:copy-of select="$asset/node()"/>
            </asset>
        </xsl:variable>
        <xsl:copy-of select="svtx:update($newAsset)"/>
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

    <xsl:function name="svtx:createTextAsset">
        <xsl:param name="textAssetName" as="xs:string"/>
        <xsl:param name="textXML" as="element(article)"/>
        <xsl:param name="articleAssetId"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:param name="validFrom" as="xs:string"/>
        <xsl:param name="validUntil" as="xs:string"/>
        <xsl:param name="productName" />

        <xsl:variable name="newName" select="concat($textAssetName,' ',format-date(current-date(),'[D01].[M01].[Y0001]'))"/>

        <xsl:message> ==== start svtx:createTextAsset</xsl:message>

        <xsl:variable name="out"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="filename" select="concat($out, 'temp-text')" as="xs:string?"/>

        <cs:command name="com.censhare.api.io.WriteXML" dissolve-document-fragments="false">
            <cs:param name="source" select="$textXML"/>
            <cs:param name="dest" select="$filename"/>
            <cs:param name="output">
                <output indent="no"/>
                <output method="xml"/>
                <output omit-xml-declaration="yes"/>
            </cs:param>
        </cs:command>
        <!-- XML Aufbau TextAsset -->
        <xsl:message> ==== start1 svtx:createTextAsset</xsl:message>
        <xsl:variable name="textAsset">
            <asset type="{$faqPublicType}" name="{$newName}" domain="{$publicDomain}">
                <asset_element idx="0" key="actual."/>
                <storage_item filesys_name="textAsset"
                              key="master" element_idx="0" mimetype="text/xml"
                              corpus:asset-temp-file-url="{$filename}"/>

                <parent_asset_rel key="user.web-usage." parent_asset="{$articleAssetId}"/>


                <asset_feature feature="censhare:output-channel"  value_key="{$channel}"/>

                <xsl:if test="$validUntil">
                    <asset_feature feature="svtx:media-valid-until"   value_timestamp="{$validUntil}"/>
                </xsl:if>
                <xsl:if test="$validFrom">
                    <asset_feature feature="svtx:media-valid-from"   value_timestamp="{$validFrom}"/>
                </xsl:if>
                <xsl:if test="$productName">
                    <asset_feature feature="svtx:product-name"   value_string="{$productName}"/>
                </xsl:if>
                <asset_feature feature="svtx:inherit-parent-uuid"   value_string="{$articleAssetId}"/>
                <asset_feature  feature="svtx:aem-template"  value_key="accordion"/>
            </asset>
        </xsl:variable>
        <xsl:message> ==== start2 svtx:createTextAsset</xsl:message>

        <!-- jetzt speichern wir  das TextAsset -->
        <xsl:variable name="newTextAsset" select="svtx:checkInNewAsset($textAsset)"/>
        <!-- damit alles geschrieben ist -->
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <xsl:message> ==== start3 svtx:createTextAsset</xsl:message>

        <xsl:copy-of select="$newTextAsset"/>
    </xsl:function>




    <!-- generiert eine Sortierte List der FAQ Text IDS -
             <text-medias>
                <text-media id="{@id}"
                ...
    -->
    <xsl:function name="svtx:getAllFAQTextAssetsIds">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <text-medias>
            <xsl:for-each select="$articleAsset/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.'  and (@censhare:asset.wf_step='30' or @censhare:asset.wf_step='35') ]">

                <text-media id="{@id}" sorting="{parent_asset_rel[@key='user.main-content.']/@sorting}" >
                    <xsl:for-each select="asset_feature[@feature='svtx:faq.medium']/@value_asset_id" >
                        <media id="{.}"/>
                    </xsl:for-each>
                </text-media>
            </xsl:for-each>
        </text-medias>
    </xsl:function>




    <xsl:function name="svtx:createTextXMLForChannel" as="element(article)">
        <xsl:param name="textMedias" as="element(text-medias)"/>
        <xsl:param name="channelKey" as="element(text-medias)"/>
        <article>
            <content>
                <faqs>
                <xsl:for-each select="$textMedias/text-media">
                    <xsl:sort select="./@sorting"/>
                    <xsl:variable name="assetId" select="./@id" as="xs:integer"/>

                    <xsl:if test="($assetId/cs:asset())/asset_feature[@feature='svtx:preselected-output-channel'  and @value_string=$channelKey]" >
                        <xsl:copy-of select="svtx:getFAQTextContent(./@id,$channelKey)"/>
                    </xsl:if>
               </xsl:for-each>
                </faqs>
            </content>
        </article>
    </xsl:function>

    <!-- Liefert fuer einen Channel alle FAQ -Texte als eine XML -->

    <xsl:function name="svtx:getFAQTextContent">
        <xsl:param name="textid" as="xs:string"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:variable name="content">
            <xsl:variable name="masterStorage" select="($textid/cs:asset())/storage_item[@key='master']" as="element(storage_item)?"/>
            <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
            <xsl:variable name="transformedContent" select="svtx:prepareTextAsset($textid/cs:asset(),$channel)"/>

            <faq>
                <xsl:copy-of select="$transformedContent/article/content/*"/>
            </faq>
        </xsl:variable>
        <xsl:copy-of select="$content"/>
    </xsl:function>

    <xsl:function name="svtx:prepareTextAsset">
        <xsl:param name="textAsset"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:variable name="forAdvisorSuite" select="if(contains($channel,'root.web.bs.')) then 'yes' else 'no'"/>
        <xsl:variable name="channelNo" select="svtx:channelToNumber($channel)"/>
        <xsl:variable name="trans1"/>
        <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans1">
            <cs:param name="key" select="'svtx:xsl.pptx.footnotes'"/>
            <cs:param name="source" select="$textAsset"/>
        </cs:command>


        <xsl:variable name="trans2"/>
        <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans2">
            <cs:param name="key" select="'svtx:web_text_transform_linebreak'"/>
            <cs:param name="source" select="$textAsset"/>
            <cs:param name="xsl-parameters">
            <cs:param name="transFormed" select="$trans1"/>
            <cs:param name="advisorySuite" select="$forAdvisorSuite"/>
                <cs:param name="channel" select="$channelNo"/>
            </cs:param>
        </cs:command>

        <xsl:copy-of select="$trans2"/>
    </xsl:function>


    <xsl:function name="svtx:checkInNewAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <xsl:variable name="result"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>



    <xsl:function name="svtx:setChannels">

        <xsl:param name="asset" as="element(asset)"/>
        <xsl:param name="channelString" as="xs:string*"/>
        <xsl:variable name="channels" select="tokenize($channelString,',')" as="xs:string*"/>
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

</xsl:stylesheet>
