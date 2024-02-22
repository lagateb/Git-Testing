<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xls="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:include href="censhare:///service/assets/asset;censhare:resource-key=svtx:util.handle.pptx/storage/master/file"/>

    <!-- TODO Aufsplitten in 3 Ereignisse. Masterdata Changed, Mediazuordnungen Changed und Reihenfolge -->


    <xsl:variable name="debug" select="false()" as="xs:boolean"/>
    <xsl:variable name="pptxFAQLayoutKey" select="'svtx:optional-modules.faq.slide'"/>


    <!-- Vergleicht den Assetnamen und setzt ihn ggf. neu -->
    <xls:function name="svtx:setAssetNameIfChanged">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:message>====== setAssetNameIfChanged Dürfte niemals mehr zuschlagen</xsl:message>
        <xsl:variable name="productAsset" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"  />
        <xsl:variable name="productName"  select="$productAsset/@name"   as="xs:string"/>

        <xsl:variable name="contentXml" select="if ($textAsset/storage_item[@key='master']) then doc($textAsset/storage_item[@key='master']/@url) else ()"/>
        <xsl:variable name="question" select="$contentXml/article/content/question" as="xs:string"/>
        <xsl:variable name="textAssetName" select="$textAsset/@name" as="xs:string"/>
        <xsl:variable name="newName"  select="concat($productName,' - ',$question)"/>

        <xsl:if test="$newName != $textAssetName">
            <xsl:message>====== falsch newName <xsl:value-of select="$newName"/> </xsl:message>
            <xsl:message>====== setAssetNameIfChanged Hat zuuschlagen ;-((</xsl:message>
            <cs:command name="com.censhare.api.assetmanagement.Update" returning="resultAsset">
                <cs:param name="source">
                    <asset>
                        <xsl:copy-of select="$textAsset/@* except($textAsset/@name)"/>
                        <xsl:attribute name="name" select="$newName"/>
                        <xsl:copy-of select="$textAsset/node()"/>
                    </asset>
                </cs:param>
            </cs:command>
            <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
                <cs:param name="flush" select="true()"/>
            </cs:command>
        </xsl:if>

    </xls:function>


    <!-- liefer alle PowerPoint Ausgaben ID's des übergeordneten Produkts -->
    <xsl:function name="svtx:getAllPPTXIds" as="xs:string*">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:variable name="productAsset" select="($textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"  />
        <xsl:copy-of select="$productAsset/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/@id,
            $productAsset/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/cs:child-rel()[@key = 'variant.']/cs:asset()[@censhare:asset.type = 'presentation.issue.']/@id">
        </xsl:copy-of>
    </xsl:function>

    <!-- durchsucht alle FAQ-TextAsset nach dem faq-Media-Feature
         Strukture
         <text-medias>
           <text-media id="textid" sorting="sort">
              <media id="pptx-ID"/>
                ...
           </text-media>
             ..
         </text-media>
      -->
    <xsl:function name="svtx:getAllTextAssetsMedia">
        <xsl:param name="textAsset" as="element(asset)"/>
        <text-medias>
            <xsl:for-each select="$textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.']">
                <text-media id="{@id}" sorting="{parent_asset_rel[@key='user.main-content.']/@sorting}" >
                    <xsl:for-each select="asset_feature[@feature='svtx:faq.medium']/@value_asset_id" >
                        <media id="{.}"/>
                    </xsl:for-each>
                </text-media>
            </xsl:for-each>
        </text-medias>
    </xsl:function>


    <xsl:function name="svtx:getAllTextAssetsMediaFromArticle">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <text-medias>
            <xsl:for-each select="$articleAsset/cs:child-rel()[@key = 'user.main-content.']/cs:asset()[@censhare:asset.type = 'text.faq.']">
                <text-media id="{@id}" sorting="{parent_asset_rel[@key='user.main-content.']/@sorting}" >
                    <xsl:for-each select="asset_feature[@feature='svtx:faq.medium']/@value_asset_id" >
                        <media id="{.}"/>
                    </xsl:for-each>
                </text-media>
            </xsl:for-each>
        </text-medias>
    </xsl:function>

    <xsl:function  name="svtx:getPPTXResourcesKey" as="xs:string">
        <xsl:param name="textAsset" as="element(asset)"/>
        <xsl:value-of  select="$textAsset/cs:parent-rel()[@key = 'user.main-content.']/cs:child-rel()[@key = 'target.']/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref"  />
    </xsl:function>


    <xsl:function name="svtx:getTextMediasForPPTX">
        <xsl:param name="pptxID" as="xs:string"/>
        <xsl:param name="textMedias" as="element(text-medias)"/>
        <text-medias>
            <xsl:for-each select="$textMedias/text-media">
                <xsl:if test="./media[@id=$pptxID]">
                    <text-media id="{@id}" sorting="{@sorting}"/>
                </xsl:if>
            </xsl:for-each>
        </text-medias>
    </xsl:function>


    <xsl:function name="svtx:getFAQTextContent">
        <xsl:param name="textid" as="xs:string"/>
        <xsl:message>=====articelID  <xsl:copy-of select="($textid/cs:asset())/storage_item[@key='master']"/>          </xsl:message>
        <xsl:variable name="content">
            <xsl:variable name="masterStorage" select="($textid/cs:asset())/storage_item[@key='master']" as="element(storage_item)?"/>
            <xsl:variable name="contentXml" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
            <xsl:variable name="transformedContent" select="svtx:prepareTextAsset($textid/cs:asset())"/>
            <xsl:message>====== transformed <xsl:copy-of select="$transformedContent"/></xsl:message>
            <slide>
                <xsl:copy-of select="$transformedContent/article/content/*"/>
            </slide>
        </xsl:variable>
        <xsl:copy-of select="$content"/>
    </xsl:function>

    <xsl:function name="svtx:createTextXML" as="element(article)">
        <xsl:param name="textMedias" as="element(text-medias)"/>
        <article>
            <content>
                <xsl:for-each select="$textMedias/text-media">
                    <xsl:sort select="./@sorting"/>
                    <xsl:copy-of select="svtx:getFAQTextContent(./@id)"/>
                </xsl:for-each>
            </content>
        </article>
    </xsl:function>

    <xsl:function name="svtx:createTextAsset">
        <xsl:param name="textXML" as="element(article)"/>
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
        <xsl:variable name="textAsset">
            <asset type="text." name="textasset">
                <asset_element idx="0" key="actual."/>

                <storage_item filesys_name="textAsset"
                              key="master" element_idx="0" mimetype="text/xml"
                              corpus:asset-temp-file-url="{$filename}"/>

            </asset>
        </xsl:variable>

        <!-- jetzt speichern wir  das TextAsset -->
        <xsl:variable name="newTextAsset" select="svtx:checkInNewAsset($textAsset)"/>
        <!-- damit alles geschrieben ist -->
        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <xsl:copy-of select="$newTextAsset"/>
    </xsl:function>


    <xsl:function name="svtx:getPPTXName" as="xs:string">
        <xsl:param name="pptxIssueID" as="xs:string"/>
        <xsl:param name="pptxTemplateID" as="xs:string"/>
        <xsl:variable name="pName" select="$pptxIssueID/cs:asset()/cs:parent-rel()[@key='user.']/cs:asset()/@name"/>
        <xsl:variable name="lName" select="$pptxTemplateID/cs:asset()/@name"/>
        <xsl:value-of select="concat($pName,concat(' ',$lName))"/>
    </xsl:function>



    <xls:function name="svtx:deletePPTXFaqSlide">
        <xsl:param name="pptxIssueID" as="xs:string"/>
        <xsl:variable name="pptxFAQAsset"   select="($pptxIssueID/cs:asset())/cs:child-rel()[@key='target.']/asset_feature[@feature='svtx:layout-template-resource-key' and @value_asset_key_ref=$pptxFAQLayoutKey]/.." />
        <xsl:if test="$pptxFAQAsset">
            <xsl:variable name="retDelete" select="svtx:deleteAsset($pptxFAQAsset/@id)"/>
            <xsl:value-of select="svtx:pptxFunctions($pptxIssueID,'merge','')"/>
        </xsl:if>
    </xls:function>

    <!-- Erzeugt ein PPTX Asset in der PPTX-Auqgaben Struktur oder updated es -->
    <!-- <asset_feature  feature="svtx:layout-template-resource-key" isversioned="1" party="10" rowid="1818585" sid="1919750" timestamp="2021-06-23T07:50:46Z" value_asset_key_ref="svtx:ppt-template-basic-produktdetails" value_string2="censhare:resource-key"/> -->
    <xsl:function name="svtx:addOrUpdatePPTXFAQ" >
        <xsl:param name="pptxIssueID" as="xs:string"/>
        <xsl:param name="pptxTemplateID" as="xs:string"/>
        <xsl:param name="tmpPPTXFile" as="xs:string"/>

        <xsl:variable name="pptxFAQAsset"   select="($pptxIssueID/cs:asset())/cs:child-rel()[@key='target.']/asset_feature[@feature='svtx:layout-template-resource-key' and @value_asset_key_ref=$pptxFAQLayoutKey]/.." />

        <xsl:choose>
            <xsl:when test="$pptxFAQAsset">
                <xsl:variable name="updatedAsset" as="element(asset)?">
                    <cs:command name="com.censhare.api.assetmanagement.Update">
                        <cs:param name="source">
                            <asset>
                                <xsl:copy-of select="$pptxFAQAsset/@*"/>
                                <xsl:copy-of select="$pptxFAQAsset/node() except ($pptxFAQAsset/storage_item,$pptxFAQAsset/asset_element)"/>
                                <storage_item key="master" filesys_name="assets.pptx" corpus:asset-temp-file-url="{$tmpPPTXFile}" element_idx="0" mimetype="application/vnd.openxmlformats-officedocument.presentationml.presentation"/>
                                <asset_element idx="0" key="actual."/>

                            </asset>
                        </cs:param>
                    </cs:command>
                </xsl:variable>

            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="templateAsset" select="$pptxTemplateID/cs:asset()"/>
                <xsl:variable name="sortval" select="count(($pptxIssueID/cs:asset())/cs:child-rel()[@key='target.'])+1"/>
                <xsl:variable name="pptxIssue" select="$pptxIssueID/cs:asset()"/>
                <!--
                <xsl:variable name="newName" select="svtx:getPPTXName($pptxIssueID,$pptxTemplateID)" />
                -->
                <xsl:variable name="clone"/>
                <cs:command name="com.censhare.api.assetmanagement.CloneAndCleanAssetXml" returning="clone">
                    <cs:param name="source" select="$templateAsset"/>
                </cs:command>

                <xsl:message> =====CloneAndClean  <xsl:copy-of select="$clone"/>  </xsl:message>
                <xsl:variable name="newAsset">
                    <asset type="{$clone/@type}" name="{$clone/@name}"  domain="{$pptxIssue/@domain}" domain2="{$pptxIssue/@domain2}" >
                        <asset_element idx="0" key="actual."/>
                        <parent_asset_rel key="target." parent_asset="{$pptxIssueID}"  sorting="{$sortval}"    />
                        <storage_item key="master" filesys_name="assets.pptx" corpus:asset-temp-file-url="{$tmpPPTXFile}" element_idx="0" mimetype="application/vnd.openxmlformats-officedocument.presentationml.presentation"/>

                        <asset_feature  feature="svtx:layout-template-resource-key"  value_asset_key_ref="{$clone/asset_feature[@feature='svtx:layout-template-resource-key']/@value_asset_key_ref}" value_string2="censhare:resource-key"/>

                        <!--
                        <asset_feature feature="svtx:layout-template-creation-date" value_timestamp="{$clone/@creation_date}"/>
                        <asset_feature feature="svtx:layout-template-version" value_long="{$clone/@version}"/>
                        -->
                    </asset>
                </xsl:variable>
                <xsl:message> =====newAsset  <xsl:copy-of select="$newAsset"/>  </xsl:message>
                <xsl:copy-of select="svtx:checkInNewAsset($newAsset)"/>
            </xsl:otherwise>
        </xsl:choose>

        <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
            <cs:param name="flush" select="true()"/>
        </cs:command>
        <!-- TODO nachher wieder zulassen -->
        <xsl:value-of select="svtx:pptxFunctions($pptxIssueID,'merge','')"/>


    </xsl:function>


    <xsl:function name="svtx:deleteAsset">
        <xsl:param name="assetId"/>
        <xsl:message>===== cron delete RegenerationAsset  <xsl:value-of select="$assetId"/></xsl:message>
        <cs:command name="com.censhare.api.assetmanagement.Delete">
            <cs:param name="source" select="$assetId"/>
            <cs:param name="state" select="'physical'"/>
        </cs:command>
    </xsl:function>

    <xsl:function name="svtx:createFAQPPTX">
        <xsl:param name="pptxTextMedia" as="element(article)"/>
        <xsl:param name="pptxTemplateID" as="xs:string"/>
        <xsl:variable name="textAssetXML" select="svtx:createTextXML($pptxTextMedia)" />


        <xsl:message>====== textasset <xsl:copy-of select="$textAssetXML"/> </xsl:message>

        <xsl:variable name="textAsset" select="svtx:createTextAsset($textAssetXML)" />

        <xsl:variable name="out"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out">
        </cs:command>

        <xsl:variable name="tmpPPTXFile" select="concat($out ,'temp-mutlislide.pptx')"/>

        <xsl:variable name="additionalData"><storeUrl value="{$tmpPPTXFile}"/><textAssetId value="{$textAsset/@id}"/></xsl:variable>

        <xsl:variable name="ret" select="svtx:pptxFunctions($pptxTemplateID,'createFromTemplate',$additionalData)"/>

        <!-- Pictures herausziehen fehlt noch -->

        <!-- delete TextAsset -->
        <xsl:variable name="retDelete" select="svtx:deleteAsset($textAsset/@id)"/>

        <xsl:value-of select="$tmpPPTXFile"/>
    </xsl:function>



    <xsl:template match="asset[@type='text.faq.']">
        <!-- TODO hier auch ? -->
        <xsl:param name="slide-id" as="xs:long?"/>
        <xsl:message>===== Start svtx.regenerate.pptx.faq.slide.on.text.changed.xsl <xsl:value-of select="@id"/></xsl:message>
        <xsl:variable name="asset" select="."/>

        <xsl:variable name="changeInfo" select="svtx:getTextChanges($asset)"/>

        <xsl:choose>
            <xsl:when test="$changeInfo/workstep/@has_change = 'true'">
                <xsl:message>===== war nur WF_STEP</xsl:message>
            </xsl:when>

            <xsl:when test="$changeInfo/approvals/@has_change = 'true'">
                <xsl:message>===== war nur approvals</xsl:message>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="powerPoints" select="svtx:getAllPPTXIds(.)"/>
                <xsl:variable name="textMedias" select="svtx:getAllTextAssetsMedia(.)"/>
                <xsl:variable name="pptxResourceKey" select="svtx:getPPTXResourcesKey(.)"/>
                <xsl:variable name="pptxTemplateID" select="./cs:parent-rel()[@key = 'user.main-content.']/cs:child-rel()[@key = 'target.']/@id"/>

                <xsl:if test="$debug">
                    <xsl:message>===== Start </xsl:message>
                    <xsl:message>===== Alle PPTX Ausgaben  <xsl:copy-of select="$powerPoints"/></xsl:message>
                    <xsl:message>===== TextMedia Struktur  <xsl:copy-of select="$textMedias"/></xsl:message>
                    <xsl:message>===== resourceKey <xsl:value-of select="$pptxResourceKey"/> </xsl:message>
                    <xsl:message>===== pptxTemplateID <xsl:value-of select="$pptxTemplateID"/> </xsl:message>
                </xsl:if>

                <xsl:variable name="faqAsset" select="svtx:setAssetNameIfChanged(.)"/>

                <xsl:for-each select="$powerPoints">
                    <xsl:variable name="pptxTextMedia" select="svtx:getTextMediasForPPTX(.,$textMedias)"/>
                    <xsl:message>===== pptxTextIds <xsl:copy-of select="$pptxTextMedia"/> </xsl:message>
                    <xsl:variable name="hh" select="." as="xs:string"/>

                    <xsl:choose>
                        <xsl:when test="count($pptxTextMedia/text-media) > 0 ">
                            <xsl:variable name="tmpPPTXFile" select="svtx:createFAQPPTX($pptxTextMedia,$pptxTemplateID)"/>
                            <xsl:variable name="ret" select="svtx:addOrUpdatePPTXFAQ(.,$pptxTemplateID,$tmpPPTXFile)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="ret" select="svtx:deletePPTXFaqSlide(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>

        <!-- -->
    </xsl:template>



    <xsl:template match="asset[@type='presentation.slide.']">

        <xsl:message>===== Start svtx.regenerate.pptx.faq.slide.on.text.changed.xsl presentation.slide <xsl:value-of select="@id"/></xsl:message>

        <xsl:variable name="powerPointID" select="@id"/>
        <xsl:variable name="powerPointAsset" select="cs:get-asset($powerPointID)"/>
        <xsl:variable name="pptxIssueID" select="$powerPointAsset/parent_asset_rel[@key='target.']/@parent_asset"/>
        <xsl:variable name="product" select="($pptxIssueID/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'],
                    $pptxIssueID/cs:parent-rel()[@key = 'variant.']/cs:parent-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'product.*'])[1]"/>
        <xsl:variable name="faqArticle" select="$product/cs:child-rel()[@key = 'user.']/cs:asset()[@censhare:asset.type = 'article.optional-module.faq.']"/>
        <xsl:variable name="pptxTemplate" select="$faqArticle/cs:child-rel()[@key = 'target.']"/>


        <xsl:variable name="textMedias" select="svtx:getAllTextAssetsMediaFromArticle($faqArticle)"/>
        <xsl:variable name="powerPointIssue" select="$powerPointID/cs:asset()"/>


        <xsl:if test="$debug">
            <xsl:message> ===== Meine PPTX- Ausgabe <xsl:value-of select="$pptxIssueID"/> </xsl:message>
            <xsl:message> ===== TextMedia Struktur <xsl:copy-of select="$textMedias"/> </xsl:message>
            <xsl:message> ===== pptxTemplateID <xsl:value-of select="$pptxTemplate/@id"/> </xsl:message>
        </xsl:if>



        <xsl:variable name="pptxTextMedia" select="svtx:getTextMediasForPPTX($pptxIssueID,$textMedias)"/>
        <xsl:message>===== pptxTextIds <xsl:copy-of select="$pptxTextMedia"/> </xsl:message>

        <!-- TODO wenn unr 1 dann egal <text-medias><text-media id="32503" sorting="1"/></text-medias> -->
        <xsl:if test="count($pptxTextMedia/text-media)>1">
            <xsl:message>===== ist betroffen</xsl:message>
            <xsl:variable name="tmpPPTXFile" select="svtx:createFAQPPTX($pptxTextMedia,$pptxTemplate/@id)"/>
            <xsl:variable name="ret" select="svtx:addOrUpdatePPTXFAQ($pptxIssueID,$pptxTemplate/@id,$tmpPPTXFile)"/>
        </xsl:if>
    </xsl:template>




    <xsl:function name="svtx:checkInNewAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

</xsl:stylesheet>
