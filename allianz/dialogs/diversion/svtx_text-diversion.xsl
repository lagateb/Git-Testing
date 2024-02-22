<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="#all">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>

    <xsl:param name="diversions" select="'root.web.aem.aem-vp.,18.08.2021,18.08.2022|root.web.aem.aem-vzde.,18.08.2021,18.08.2022'"  as="xs:string"/>


    <!-- Erstellt  die Webausleitun der Texte
        Es werden jweils eigene Kopien für jeden Channel gemacht und
         Relationen zum Artikel gesetzt  . Die Text Typen sind dann  text.public.size-s. etc

            <asset_feature asset_id="15745" feature="censhare:output-channel"  value_key="root.web.aem.aem-dev."/>
         <asset_feature asset_id="15745" asset_version="4" corpus:dto_flags="pt" feature="censhare:output-channel" isversioned="1" party="109" rowid="960383" sid="1007758" timestamp="2021-07-22T08:06:57Z" value_key="root.web.bs.bs-dev."/>


         <feature_value feature="censhare:output-channel" domain="root." domain2="root." is_hierarchical="1" value_key="root.web." parent_key="root." shortname="web" name="Web" name_de="Web" sorting="2" enabled="1" source="censhare-Server/install/system/optional/sample-data/masterdata.xml"/>
         <feature_value feature="censhare:output-channel" domain="root." domain2="root." is_hierarchical="1" value_key="root.web.aem." parent_key="root.web." shortname="aem" name="AEM" name_de="AEM" sorting="3" enabled="1"/>

     -->

    <!-- Fragen
         Werden alle alten Verknüpfungen dann zurückgesetzt bzw. archiviert?
         <xsl:variable name="mainContent" select="(cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*'])[1]" as="element(asset)?"/>
    -->

    <!-- alle public TextAsset des Types vom Article auf archived setzen -->
    <xsl:function name="svtx:setCurrentVersionToArchived">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:param name="textType" as="xs:string"/>
        <xsl:for-each select="$articleAsset/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type=$textType and @censhare:asset.domain=$publicDomain]">
            <!-- Ohne Ändrungshistorie, da sonst etliche unnötige Trigger gestartet werden -->
            <xsl:variable name="currentAsset" select="."/>
            <cs:command name="com.censhare.api.assetmanagement.Update">
                <cs:param name="source">
                    <asset>
                        <xsl:copy-of select="$currentAsset/@* except($currentAsset/domain)"/>
                        <xsl:attribute name="domain" select="$archivedDomain"/>
                        <xsl:copy-of select="$currentAsset/node()" />

                    </asset>
                </cs:param>
            </cs:command>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="svtx:checkInNewAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="result">
            <cs:param name="source" select="$asset" />
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>




    <!-- TODO Freigabe der Bilder  aber müssen die nicht über ein anderes Management frei sein?  -->
    <xsl:function name="svtx:createTextCopy">
        <xsl:param name="articleText" as="element(asset)"/>
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:param name="publicTextType" as="xs:string"/>
        <xsl:param name="channel" as="xs:string"/>
        <xsl:param name="validFrom" as="xs:string"/>
        <xsl:param name="validUntil" as="xs:string"/>

        <xsl:variable name="newName" select="concat($articleText/@name,' ',format-date(current-date(),'[D01].[M01].[Y0001]'))"/>

        <xsl:variable name="clone"/>
        <cs:command name="com.censhare.api.assetmanagement.CloneAndCleanAssetXml" returning="clone">
            <cs:param name="source" select="$articleText"/>
        </cs:command>
        <xsl:message> ==== <xsl:copy-of select="$clone"/> </xsl:message>

        <xsl:variable name="newTextAsset">
            <asset type="{$publicTextType}" name="{$newName}" domain="{$publicDomain}">

                <xsl:copy-of select="$clone/node() except($clone/child_asset_rel[@key='variant.1.'],
                   $clone/asset_feature[@feature='censhare:approval.history' or @feature='censhare:approval.type'])"/>

                <parent_asset_rel key="user.main-content." parent_asset="{$articleAsset/@id}">
                    <!-- TODO brauchen wir den  ?
                      <asset_rel_feature  feature="svtx:text-variant-type"  value_key="{$relationFeature}"/>
                      -->
                </parent_asset_rel>
                <asset_feature feature="censhare:output-channel"  value_key="{$channel}">
                <xsl:if test="$validUntil">
                    <asset_feature feature="svtx:media-valid-until"   value_timestamp="{$validUntil}"/>
                </xsl:if>
                <xsl:if test="$validFrom">
                    <asset_feature feature="svtx:media-valid-from"   value_timestamp="{$validFrom}"/>
                </xsl:if>
                </asset_feature>
            </asset>
        </xsl:variable>

        <xsl:copy-of select="svtx:checkInNewAsset($newTextAsset)"/>
    </xsl:function>



    <xsl:template match="/" >
        <xsl:variable name="textAsset" select="./asset"/>
        <xsl:variable name="articleAsset" select="$textAsset/cs:parent-rel()[@key='user.main-content.']"/>
        <xsl:variable name="publicTextType" select="svtx:getPublicType($textAsset)"/>

        <xsl:variable name="ret" select="svtx:setCurrentVersionToArchived($articleAsset,$publicTextType)"/>

        <xsl:for-each select="tokenize($diversions, '\|')">
            <xsl:variable name="diversion" select="."/>
            <xsl:message>=== Mit Token <xsl:value-of select="$diversion"/></xsl:message>
            <xsl:variable name="channelKey" select="substring-before($diversion,',')"/>
            <xsl:variable name="tmp" select="substring-after($diversion,',')"/>
            <xsl:variable name="validFrom" select="substring-before($tmp,',')"/>
            <xsl:variable name="validUntil" select="substring-after($tmp,',')"/>
            <xsl:variable name="ret" select="svtx:createTextCopy($textAsset,$articleAsset,$publicTextType,$channelKey,$validFrom,$validUntil)"/>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>