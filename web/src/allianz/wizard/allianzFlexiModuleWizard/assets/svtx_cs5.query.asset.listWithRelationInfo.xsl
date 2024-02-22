<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  exclude-result-prefixes="#all">

  <!-- output -->
  <xsl:output indent="no" method="xml" omit-xml-declaration="no" encoding="UTF-8"/>

  <!-- view model transformation for asset list -->
  <!-- change elements: -->
  <!-- - traits/workflow: add attributes "isGroup", "isMe" -->
  <!-- - actual_notes: reduce to attribute "count" -->
  <!-- - actual_root: add attribute "pageCount" and reduce "storage_items" -->
  <!-- - planning_root: reduce to attribute "count" -->
  <!-- - messages: reduce to attribute "count" -->
  <!-- - storage_items: reduce to "master", "preview" and "thumbnail" storage keys -->
  <!-- remove elements: -->
  <!-- - relations (are also removed in this transformation because they're not used [rm])-->
  <!-- add elements (if data exists): -->
  <!-- - actualNotes -->
  <!-- - address -->
  <!-- - categories -->
  <!-- - contentUpdates -->
  <!-- - gdpr -->
  <!-- - geometryUpdates -->
  <!-- - goal -->
  <!-- - keywordRefs -->
  <!-- - masterStorageItems -->
  <!-- - person -->
  <!-- - preview -->
  <!-- - productCategories -->
  <!-- - rating -->
  <!-- - task -->
  <!-- - tasks -->
  <!-- - thumbnail -->
  <!-- - variants -->
  <!-- - variantUpdates -->
  <!-- - workingCopies -->
 
  <!-- global variables -->
  <xsl:variable name="addedTraits" select="('access_rights', 'checked_out', 'created', 'default', 'display', 'domain', 'facebook', 'file_meta_data', 'ids', 'modified', 'resource_asset', 'resource_planning', 'state', 'type', 'twitter', 'usage_rights', 'versioning', 'workflow', 'youtube', 'allianzTemplateOptions')"/>
  <xsl:variable name="urlPrefix" select="'/rest/'"/>
  <xsl:variable name="assetServiceUrl" select="'/rest/service/assets/'"/>
  <xsl:variable name="loggedInPartyID" select="system-property('censhare:party-id')"/>
  <xsl:variable name="locale" select="cs:master-data('party')[@id=$loggedInPartyID]/@locale"/>
  <xsl:variable name="language" select="if ($locale) then $locale else 'en'"/>

  <!-- asset match -->
  <xsl:template match="asset">
    <asset>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="actual_root"/>
      <xsl:apply-templates select="planning_root"/>
      <xsl:apply-templates select="actual_notes"/>
      <xsl:apply-templates select="messages"/>
      <xsl:apply-templates select="storage_items"/>
      <xsl:apply-templates select="traits"/>
      <xsl:copy-of select="aspects"/>
      <xsl:copy-of select="relations"/>
      <xsl:call-template name="actualNotes"/>
      <xsl:call-template name="address"/>
      <xsl:call-template name="categories"/>
      <xsl:call-template name="contentUpdates"/>
      <xsl:call-template name="gdpr"/>
      <xsl:call-template name="geometryUpdates"/>
      <xsl:call-template name="goal"/>
      <xsl:call-template name="keywordRefs"/>
      <xsl:call-template name="masterStorageItems"/>
      <xsl:call-template name="person"/>
      <xsl:call-template name="preview"/>
      <xsl:call-template name="productCategories"/>
      <xsl:call-template name="rating"/>
      <xsl:call-template name="task"/>
      <xsl:call-template name="tasks"/>
      <xsl:call-template name="thumbnail"/>
      <xsl:call-template name="variants"/>
      <xsl:call-template name="variantUpdates"/>
      <xsl:call-template name="workingCopies"/>
    </asset>
  </xsl:template>
  
  <xsl:template match="actual_root">
    <actual_root page_count="{count(pages/page)}">
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="traits"/>
      <xsl:apply-templates select="storage_items"/>
    </actual_root>
  </xsl:template>

  <xsl:template match="planning_root">
    <planning_root page_count="{count(pages/page)}"/>
  </xsl:template>
  
  <xsl:template match="actual_notes">
    <actual_notes count="{count(note)}"/>
  </xsl:template>
  
  <xsl:template match="messages">
    <messages count="{count(message)}"/>
  </xsl:template>
  
  <xsl:template match="storage_items">
    <storage_items>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="storage_item[@type='master']"/>
      <xsl:apply-templates select="storage_item[@type='thumbnail']"/>
      <xsl:apply-templates select="storage_item[@type='preview']"/>
    </storage_items>
  </xsl:template>
  
  <xsl:template match="storage_item">
    <storage_item>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of select="traits"/>
    </storage_item>
  </xsl:template>

  <xsl:template match="traits">
    <traits>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*" mode="traits"/>
    </traits>
  </xsl:template>

  <!-- add attributes "isGroup" and "isMe" to "workflow" trait -->
  <xsl:template match="workflow" mode="traits" priority="2.0">
    <workflow>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="workflowTarget" select="@workflowTarget"/>
      <xsl:variable name="workflowParty" select="if ($workflowTarget) then cs:master-data('party')[@id=$workflowTarget] else ()"/>
      <xsl:if test="$workflowParty">
        <xsl:attribute name="isGroup" select="$workflowParty/@isgroup='1'"/>
        <xsl:attribute name="isMe" select="boolean($workflowTarget=$loggedInPartyID)"/>
      </xsl:if>
      <xsl:copy-of select="*"/>
    </workflow>
  </xsl:template>

  <xsl:template match="*" mode="traits" priority="1.0">
    <xsl:if test="node-name(.)=$addedTraits">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <!-- creates "actualNotes" element -->
  <!-- <actualNotes count="10"/> -->
  <xsl:template name="actualNotes">
    <xsl:variable name="actualNotesElement" select="traits/actual_notes"/>
    <xsl:if test="$actualNotesElement">
      <actualNotes>
        <xsl:attribute name="count" select="count(traits/actual_notes/note)"/>
      </actualNotes>
    </xsl:if>
  </xsl:template>

  <!-- creates "address" element -->
  <!-- <address work="Paul-Gerhardt-Allee 50, 81245 München, 81245, Germany"/> -->
  <xsl:template name="address">
    <xsl:variable name="addressElement" select="traits/address/address/addressType"/>
    <xsl:variable name="workElement" select="$addressElement/value[@value='work']"/>
    <xsl:if test="$workElement">
      <address>
        <xsl:attribute name="work" select="string-join((string-join(($workElement/street/@value, $workElement/streetNumber/@value), ' '), string-join(($workElement/zipCode/@value, $workElement/city/@value), ' '), $workElement/zipCode/@value, $workElement/countryCode/@label_value), ', ')"/>
      </address>
    </xsl:if>
  </xsl:template>

  <!-- creates "categories" element -->
  <!-- <categories censhare:_annotation.arraygroup="true"> -->
  <!--   <category value="censhare:category.persona" label="Persona"/> -->
  <!-- </categories> -->
  <xsl:template name="categories">
    <xsl:variable name="categories" select="traits/type/category/value"/>
    <xsl:if test="$categories">
      <xsl:variable name="items" as="element(category)*">
        <xsl:for-each select="$categories">
          <category
            value="{@value}"
            label="{if (@label_category) then @label_category else csc:getLocalizedAssetName(@value)}">
          </category>
        </xsl:for-each>
      </xsl:variable>
      <categories censhare:_annotation.arraygroup="true">
        <xsl:for-each select="$items">
          <xsl:sort select="@label"/>
          <xsl:sequence select="."/>
        </xsl:for-each>
      </categories>
    </xsl:if>
  </xsl:template>

  <!-- creates "contentUpdates" element -->
  <!-- <contentUpdates countParent="1" countChild="1"/> -->
  <xsl:template name="contentUpdates">
    <xsl:variable name="parentAssetRels" select="relations/relation[@type='actual.' and @direction='parent' and traits/state/@hasUpdateContent='true']"/>
    <xsl:variable name="childAssetRels" select="relations/relation[@type='actual.' and @direction='child' and traits/state/@hasUpdateContent='true']"/>
    <xsl:if test="$parentAssetRels or $childAssetRels">
      <contentUpdates
        countParent="{count($parentAssetRels)}"
        countChild="{count($childAssetRels)}">
      </contentUpdates>
    </xsl:if>
  </xsl:template>

  <!-- creates "gdpr" element -->
  <!-- <gdpr isLoggedInPartyPersonPage="true" isPartyUser="true" viewContactDataAllowed="true" viewPersonalDataAllowed="true"/> -->
  <xsl:template name="gdpr">
    <xsl:if test="traits/type/@type='person.'">
      <xsl:variable name="partyAssetId" select="cs:master-data('party')[@id=$loggedInPartyID]/@party_asset_id"/>
      <xsl:variable name="isPartyUser" select="exists(cs:master-data('party')[@party_asset_id=traits/ids/@id])"/>
      <xsl:variable name="isLoggedInPartyPersonPage" select="traits/ids/@id=$partyAssetId"/>
      <gdpr
        isLoggedInPartyPersonPage="{$isLoggedInPartyPersonPage}"
        isPartyUser="{$isPartyUser}"
        viewContactDataAllowed="{not($isPartyUser) or $isLoggedInPartyPersonPage or traits/address/privacyAllowViewContactData/@value='true'}"
        viewPersonalDataAllowed="{not($isPartyUser) or $isLoggedInPartyPersonPage or traits/address/privacyAllowViewPersonalData/@value='true'}">
      </gdpr>
    </xsl:if>
  </xsl:template>

  <!-- creates "geometryUpdates" element -->
  <!-- <geometryUpdates countParent="1" self="true" countChild="1"/> -->
  <xsl:template name="geometryUpdates">
    <xsl:variable name="parentAssetRels" select="relations/relation[@type='target.' and @direction='parent' and traits/state/@hasUpdateChildGeometry='true']"/>
    <xsl:variable name="hasUpdateFlag" select="traits/state/@hasUpdateGeometry='true'"/>
    <xsl:variable name="childAssetRels" select="relations/relation[@type='target.' and @direction='child' and traits/state/@hasUpdateChildGeometry='true']"/>
    <xsl:if test="$parentAssetRels or $hasUpdateFlag or $childAssetRels">
      <geometryUpdates
        countParent="{count($parentAssetRels)}"
        self="{$hasUpdateFlag}"
        countChild="{count($childAssetRels)}">
      </geometryUpdates>
    </xsl:if>
  </xsl:template>

  <!-- creates "goal" element -->
  <!-- <goal startDate="2015-12-31T23:00:00Z" startValue="0" endDate="2016-04-29T22:00:00Z" endValue="100" totalAchievedPercent="60" relativeAchievedPercent="205.4"/> -->
  <xsl:template name="goal">
    <xsl:variable name="goalTraitElement" select="traits/goal"/>
    <xsl:if test="$goalTraitElement">
      <goal>
        <xsl:copy-of select="$goalTraitElement[1]/@startDate"/>
        <xsl:copy-of select="$goalTraitElement[1]/@startValue"/>
        <xsl:copy-of select="$goalTraitElement[1]/@endDate"/>
        <xsl:copy-of select="$goalTraitElement[1]/@endValue"/>
        <xsl:variable name="startDate" select="xs:dateTime($goalTraitElement[1]/@startDate)"/>
        <xsl:variable name="endDate" select="xs:dateTime($goalTraitElement[1]/@endDate)"/>
        <xsl:variable name="givenStartValue" select="$goalTraitElement[1]/@startValue"/>
        <xsl:variable name="startValue" select="if ($givenStartValue) then $givenStartValue else 0"/>
        <xsl:variable name="endValue" select="$goalTraitElement[1]/@endValue"/>
        <xsl:variable name="achievedElements" select="$goalTraitElement[1]/achievedDate/value[exists(achievedValue)]"/>
        <xsl:variable name="lastAchievedDate" select="max(for $x in $achievedElements return xs:dateTime($x/@value))"/>
        <xsl:variable name="lastAchievedValue" select="$achievedElements[xs:dateTime(@value)=$lastAchievedDate]/achievedValue[1]/@value"/>
        <xsl:variable name="totalAchievedPercent" select="(($lastAchievedValue - $startValue) * 100) div ($endValue - $startValue)"/>
        <xsl:variable name="endDateSeconds" select="if (exists($startDate) and exists($endDate)) then ($endDate - $startDate) div xs:dayTimeDuration('PT1S') else ()"/>
        <xsl:variable name="lastAchievedDateSeconds" select="if (exists($lastAchievedDate) and exists($startDate)) then ($lastAchievedDate - $startDate) div xs:dayTimeDuration('PT1S') else ()"/>
        <xsl:variable name="lastAchievedGoalValue" select="(($lastAchievedDateSeconds * ($endValue - $startValue)) div $endDateSeconds) + $startValue"/>
        <xsl:variable name="relativeAchievedPercent" select="(($lastAchievedValue - $startValue) * 100) div ($lastAchievedGoalValue - $startValue)"/>
        <xsl:if test="$totalAchievedPercent">
          <xsl:attribute name="totalAchievedPercent" select="$totalAchievedPercent"/>
        </xsl:if>
        <xsl:if test="$relativeAchievedPercent">
          <xsl:attribute name="relativeAchievedPercent" select="$relativeAchievedPercent"/>
        </xsl:if>
      </goal>
    </xsl:if>
  </xsl:template>

  <!-- creates "keywordRefs" element -->
  <!-- <keywordRefs censhare:_annotation.arraygroup="true"> -->
  <!--   <keywordRef value="/m/012mj" label="Alcoholic drink" relevance="48.66618952318724"/> -->
  <!-- </keywordRefs> -->
  <xsl:template name="keywordRefs">
    <xsl:variable name="keywordRefs" select="traits/category/keywordRef/value"/>
    <xsl:if test="$keywordRefs">
      <xsl:variable name="items" as="element(keywordRef)*">
        <xsl:for-each select="$keywordRefs">
          <keywordRef
            value="{@value}"
            label="{if (@label_category) then @label_category else csc:getLocalizedAssetName(@value)}"
            relevance="{@relevance}">
          </keywordRef>
        </xsl:for-each>
      </xsl:variable>
      <keywordRefs censhare:_annotation.arraygroup="true">
        <xsl:for-each select="$items">
          <xsl:sort select="@label"/>
          <xsl:sequence select="."/>
        </xsl:for-each>
      </keywordRefs>
    </xsl:if>
  </xsl:template>

  <!-- creates "masterStorageItems" element -->
  <!-- <masterStorageItems count="1" size="4158" mimetype="image/jpeg" mimetypeLabel="JPEG image" audioFormat="mp4a" bitrateMps="126.0" -->
  <!--                     durationSec="257.0" color="rgb" dpi="72" framesPerSecond="30.0" lineCount="1" wordCount="1" charCount="1" -->
  <!--                     videoFormat="H.264" heightPx="200" widthPx="200" appVersion="6.0" appVersionLabel="Adobe InDesign 6.0 (CS-4)"/> -->
  <xsl:template name="masterStorageItems">
    <xsl:variable name="masterStorageItems" select="(actual_root, actual_root/pages/page)/storage_items/storage_item[@type='master']"/>
    <xsl:if test="$masterStorageItems">
      <masterStorageItems
        count="{count($masterStorageItems)}"
        size="{round(sum($masterStorageItems/traits/file_meta_data/@fileLength))}"
        mimetype="{$masterStorageItems[1]/traits/file_meta_data/@mimetype}"
        mimetypeLabel="{$masterStorageItems[1]/traits/file_meta_data/@label_mimetype}">
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@audioFormat"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@bitrateMps"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@durationSec"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@color"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@dpi"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@framesPerSecond"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@heightPx"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@videoFormat"/>
        <xsl:copy-of select="$masterStorageItems[1]/traits/file_meta_data/@widthPx"/>
        <xsl:if test="$masterStorageItems/traits/file_meta_data/@lineCount">
          <xsl:attribute name="lineCount" select="round(sum($masterStorageItems/traits/file_meta_data/@lineCount))"/>
        </xsl:if>
        <xsl:if test="$masterStorageItems/traits/file_meta_data/@wordCount">
          <xsl:attribute name="wordCount" select="round(sum($masterStorageItems/traits/file_meta_data/@wordCount))"/>
        </xsl:if>
        <xsl:if test="$masterStorageItems/traits/file_meta_data/@charCount">
          <xsl:attribute name="charCount" select="round(sum($masterStorageItems/traits/file_meta_data/@charCount))"/>
        </xsl:if>
        <xsl:variable name="typeElement" select="$masterStorageItems[1]/traits/type"/>
        <xsl:if test="$typeElement">
          <xsl:copy-of select="$typeElement/@appVersion"/>
          <xsl:if test="$typeElement/@label_appVersion">
            <xsl:attribute name="appVersionLabel" select="$typeElement/@label_appVersion"/>
          </xsl:if>
        </xsl:if>
      </masterStorageItems>
    </xsl:if>
  </xsl:template>

  <!-- creates "person" element -->
  <!-- <person/> -->
  <xsl:template name="person">
    <xsl:variable name="personalDataElement" select="traits/address/address/personalData"/>
    <xsl:variable name="comElement" select="traits/address/address/comTelType"/>
    <xsl:variable name="emailElement" select="traits/address/address/comEmailType"/>
    <xsl:if test="$personalDataElement or $comElement or $emailElement">
      <person>
        <xsl:variable name="birthday" select="$personalDataElement/birthday/@value"/>
        <xsl:if test="$birthday">
          <xsl:attribute name="birthday" select="$birthday"/>
          <xsl:attribute name="age">
            <xsl:choose>
              <xsl:when test="month-from-date(current-date()) > month-from-date($birthday) or month-from-date(current-date()) = month-from-date($birthday) and day-from-date(current-date()) >= day-from-date($birthday)">
                <xsl:value-of select="year-from-date(current-date()) - year-from-date($birthday)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="year-from-date(current-date()) - year-from-date($birthday) - 1" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$personalDataElement/birthplace">
          <xsl:attribute name="birthplace" select="$personalDataElement/birthplace/@value"/>
        </xsl:if>
        <xsl:if test="$personalDataElement/gender">
          <xsl:attribute name="gender" select="$personalDataElement/gender/@value"/>
        </xsl:if>
        <xsl:if test="$personalDataElement/title">
          <xsl:attribute name="title" select="$personalDataElement/title/@value"/>
        </xsl:if>
        <xsl:if test="$personalDataElement/firstName">
          <xsl:attribute name="firstName" select="$personalDataElement/firstName/@value"/>
        </xsl:if>
        <xsl:if test="$personalDataElement/middleName">
          <xsl:attribute name="middleName" select="$personalDataElement/middleName/@value"/>
        </xsl:if>
        <xsl:if test="$personalDataElement/lastName">
          <xsl:attribute name="lastName" select="$personalDataElement/lastName/@value"/>
        </xsl:if>
        <xsl:if test="$personalDataElement/function">
          <xsl:attribute name="function" select="$personalDataElement/function/@value"/>
        </xsl:if>
        <xsl:if test="$comElement/value[@value='cell']">
          <xsl:attribute name="cellPhone" select="$comElement/value[@value='cell']/uriTel/@value"/>
        </xsl:if>
        <xsl:if test="$emailElement">
          <email>
            <xsl:if test="$emailElement/value[@value='work']">
              <xsl:attribute name="work" select="$emailElement/value[@value='work']/uriMailTo/@value"/>
            </xsl:if>
            <xsl:if test="$emailElement/value[@value='home']">
              <xsl:attribute name="home" select="$emailElement/value[@value='home']/uriMailTo/@value"/>
            </xsl:if>
          </email>
        </xsl:if>
      </person>
    </xsl:if>
  </xsl:template>
  
  <!-- creates "preview" element -->
  <!-- <preview url="/rest/service/assets/asset/id/294464/version/2/element/actual/0/storage/thumbnail/file/485731.jpg"/> -->
  <xsl:template name="preview">
    <xsl:variable name="storageItem" select="if (exists(actual_root/storage_items/storage_item[@type='preview'])) then actual_root/storage_items/storage_item[@type='preview'] else actual_root/pages/page[1]/storage_items/storage_item[@type='preview']"/>
    <xsl:variable name="url" select="if ($storageItem) then (replace($storageItem/@url,'censhare:///',$urlPrefix)) else ()"/>
    <xsl:if test="$url">
      <preview url="{$url}"/>
    </xsl:if>
  </xsl:template>
  
  <!-- creates "productCategories" element -->
  <!-- <productCategories censhare:_annotation.arraygroup="true"> -->
  <!--   <productCategory value="234683" label="Bicycles"/> -->
  <!-- </productCategories> -->
  <xsl:template name="productCategories">
    <xsl:variable name="productCategories" select="traits/product/category/value"/>
    <xsl:if test="$productCategories">
      <xsl:variable name="items" as="element(productCategory)*">
        <xsl:for-each select="$productCategories">
          <productCategory
            value="{@value}"
            label="{if (@label_category) then @label_category else csc:getLocalizedAssetName(@value)}">
          </productCategory>
        </xsl:for-each>
      </xsl:variable>
      <productCategories censhare:_annotation.arraygroup="true">
        <xsl:for-each select="$items">
          <xsl:sort select="@label"/>
          <xsl:sequence select="."/>
        </xsl:for-each>
      </productCategories>
    </xsl:if>
  </xsl:template>

  <!-- creates "rating" element -->
  <!-- <rating bookmarkCountCalc="1" dislikeCountCalc="1" followerCountCalc="1" likeCountCalc="8"> -->
  <!--   <own value="4.0" fullStars="4" emptyStars="0"/> -->
  <!--   <avg value="4.5" fullStars="4" emptyStars="0"/> -->
  <!-- </rating> -->
  <xsl:template name="rating">
    <xsl:variable name="ratingTraitElement" select="traits/rating"/>
    <xsl:if test="$ratingTraitElement">
      <rating>
        <!-- copy all attributes of "rating" trait element -->
        <xsl:copy-of select="$ratingTraitElement/@*"/>
        <!-- create rating -->
        <xsl:variable name="ratings" select="$ratingTraitElement/rating/value"/>
        <xsl:variable name="ownRating" select="$ratings[@party=$loggedInPartyID][1]/@value"/>
        <xsl:variable name="avgRating" select="avg($ratings/@value)"/>
        <xsl:if test="$ownRating">
          <own>
            <value censhare:_annotation.datatype="number"><xsl:value-of select="$ownRating"/></value>
            <fullStars censhare:_annotation.datatype="number"><xsl:value-of select="floor($ownRating)"/></fullStars>
            <emptyStars censhare:_annotation.datatype="number"><xsl:value-of select="5-floor($ownRating)"/></emptyStars>
          </own>
        </xsl:if>
        <avg>
          <value censhare:_annotation.datatype="number"><xsl:value-of select="$avgRating"/></value>
          <fullStars censhare:_annotation.datatype="number"><xsl:value-of select="floor($avgRating)"/></fullStars>
          <emptyStars censhare:_annotation.datatype="number"><xsl:value-of select="5-floor($avgRating)"/></emptyStars>
        </avg>
      </rating>
    </xsl:if>
  </xsl:template>

  <!-- creates "task" element -->
  <!-- <task> -->
  <!--   <duration value="4" unit="days"> -->
  <!--   <workingTime value="2" unit="days"> -->
  <!-- </task> -->
  <xsl:template name="task">
    <xsl:variable name="givenDurationString" select="traits/resource_planning/@givenDuration"/>
    <xsl:variable name="givenWorkingTimeString" select="traits/resource_planning/@givenWorkingTime"/>
    <xsl:if test="$givenDurationString or $givenWorkingTimeString">
      <task>
        <xsl:if test="$givenDurationString">
          <xsl:variable name="givenDurationValue" select="xs:double(substring-before($givenDurationString, 'w'))"/>
          <xsl:variable name="givenDurationUnit" select="concat('w', substring-after($givenDurationString, 'w'))"/>
          <duration
            value="{cs:format-number($givenDurationValue, '#,##0.#')}"
            unit="{csc:getWorkingTimeUnitKey($givenDurationValue, $givenDurationUnit)}">
          </duration>
        </xsl:if>
        <xsl:if test="$givenWorkingTimeString">
          <xsl:variable name="givenWorkingTimeValue" select="if (contains($givenWorkingTimeString, 'w')) then xs:double(substring-before($givenWorkingTimeString, 'w')) else (xs:double($givenWorkingTimeString))"/>
          <xsl:variable name="givenWorkingTimeUnit" select="if (contains($givenWorkingTimeString, 'w')) then concat('w', substring-after($givenWorkingTimeString, 'w')) else ()"/>
          <workingTime
            value="{cs:format-number($givenWorkingTimeValue, '#,##0.#')}"
            unit="{if ($givenWorkingTimeUnit) then csc:getWorkingTimeUnitKey($givenWorkingTimeValue, $givenWorkingTimeUnit) else ()}">
          </workingTime>
        </xsl:if>
      </task>
    </xsl:if>
  </xsl:template>

  <!-- creates "tasks" element -->
  <!-- <tasks countParent="1" countPredecessor="1" countSuccessor="1" countChild="1"/> -->
  <xsl:template name="tasks">
    <xsl:variable name="parentAssetRels" select="relations/relation[starts-with(@type, 'user.task.') and @direction='parent']"/>
    <xsl:variable name="childAssetRels" select="relations/relation[starts-with(@type, 'user.task.') and @direction='child']"/>
    <xsl:variable name="predecessorAssetRels" select="relations/relation[starts-with(@type, 'user.dependency-finish-to-start.') and @direction='parent']"/>
    <xsl:variable name="successorAssetRels" select="relations/relation[starts-with(@type, 'user.dependency-finish-to-start.') and @direction='child']"/>
    <xsl:if test="$parentAssetRels or $childAssetRels or $predecessorAssetRels or $successorAssetRels">
      <tasks>
        <xsl:if test="$parentAssetRels">
          <xsl:attribute name="countParent" select="count($parentAssetRels)"/>
        </xsl:if>
        <xsl:if test="$predecessorAssetRels">
          <xsl:attribute name="countPredecessor" select="count($predecessorAssetRels)"/>
        </xsl:if>
        <xsl:if test="$successorAssetRels">
          <xsl:attribute name="countSuccessor" select="count($successorAssetRels)"/>
        </xsl:if>
        <xsl:if test="$childAssetRels">
          <xsl:attribute name="countChild" select="count($childAssetRels)"/>
        </xsl:if>
      </tasks>
    </xsl:if>
  </xsl:template>

  <!-- creates "thumbnail" element -->
  <!-- <thumbnail url="/rest/service/assets/asset/id/294464/version/2/element/actual/0/storage/thumbnail/file/485731.jpg"/> -->
  <xsl:template name="thumbnail">
    <xsl:variable name="storageItemUrl" select="csc:findThumbnailUrl()"/>
    <xsl:if test="$storageItemUrl">
      <thumbnail url="{replace($storageItemUrl, 'censhare:///', $urlPrefix)}"/>
    </xsl:if>
  </xsl:template>

  <!-- creates "variants" element -->
  <!-- <variants> -->
  <!--   <parent type="variant.1." label="Variant with update flag" id="123456"/> -->
  <!--   <child count="1"/> -->
  <!-- </variants> -->
  <xsl:template name="variants">
    <xsl:variable name="variantParentRel" select="/container/asset/relations/relation[@direction='parent' and starts-with(@type, 'variant.')][1]"/>
    <xsl:variable name="variantChildRels" select="/container/asset/relations/relation[@direction='child' and starts-with(@type, 'variant.')]"/>
    <xsl:if test="$variantParentRel or $variantChildRels">
      <variants>
        <xsl:if test="$variantParentRel">
          <parent type="{$variantParentRel/@type}" label="{cs:master-data('asset_rel_typedef')[@key=$variantParentRel/@type]/@name}">
            <xsl:variable name="id" select="tokenize($variantParentRel/@ref_asset, '/')[3]"/>
            <xsl:if test="$id">
              <xsl:attribute name="id" select="$id"/>
            </xsl:if>
            <xsl:variable name="roleElements" select="$variantParentRel/traits/resource_asset/roleRelation/value"/>
            <xsl:if test="$roleElements">
              <roles censhare:_annotation.arraygroup="true">
                <xsl:for-each select="$roleElements">
                  <role id="{@value}" label="{@label_value}"/>
                </xsl:for-each>
              </roles>
            </xsl:if>
          </parent>
        </xsl:if>
        <xsl:if test="$variantChildRels">
          <child count="{count($variantChildRels)}"/>
        </xsl:if>
      </variants>
    </xsl:if>
  </xsl:template>

  <!-- creates "variantUpdates" element -->
  <!-- <variantUpdates countParent="1" countChild="1"/> -->
  <xsl:template name="variantUpdates">
    <xsl:variable name="parentAssetRels" select="relations/relation[starts-with(@type, 'variant.') and @direction='parent' and traits/state/@hasUpdateContent='true']"/>
    <xsl:variable name="childAssetRels" select="relations/relation[starts-with(@type, 'variant.') and @direction='child' and traits/state/@hasUpdateContent='true']"/>
    <xsl:if test="$parentAssetRels or $childAssetRels">
      <variantUpdates countParent="{count($parentAssetRels)}" countChild="{count($childAssetRels)}"/>
    </xsl:if>
  </xsl:template>

  <!-- creates "workingCopies" element -->
  <!-- <workingCopies countParent="1" releaseDate="2020-05-18T04:14:00Z" countChild="1"/> -->
  <xsl:template name="workingCopies">
    <xsl:variable name="parentAssetRels" select="relations/relation[starts-with(@type, 'user.working-copy.') and @direction='parent']"/>
    <xsl:variable name="childAssetRels" select="relations/relation[starts-with(@type, 'user.working-copy.') and @direction='child']"/>
    <xsl:if test="$parentAssetRels or $childAssetRels">
      <workingCopies>
        <xsl:if test="$parentAssetRels">
          <xsl:attribute name="countParent" select="count($parentAssetRels)"/>
          <xsl:variable name="releaseDate" select="traits/publication/@releaseDate"/>
          <xsl:if test="$releaseDate">
            <xsl:attribute name="releaseDate" select="$releaseDate"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="$childAssetRels">
          <xsl:attribute name="countChild" select="count($childAssetRels)"/>
        </xsl:if>
      </workingCopies>
    </xsl:if>
  </xsl:template>

  <xsl:function name="csc:findThumbnailUrl" as="xs:string?">
    <xsl:variable name="asset" select="." as="element(asset)"/>
    <!-- first check for thumbnail ow own asset -->
    <xsl:variable name="thumbnailStorageItems" as="element(storage_item)*" select="$asset/actual_root/storage_items/storage_item[@type='thumbnail'] | $asset/actual_root/pages/page[1]/storage_items/storage_item[@type='thumbnail']"/>
    <xsl:choose>
      <xsl:when test="exists($thumbnailStorageItems)">
        <xsl:value-of select="$thumbnailStorageItems[1]/@url"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- find asset type specific thumbnails -->
        <xsl:variable name="assetTypeThumbnailStorageItemUrl" as="xs:string?">
          <xsl:choose>
            <!-- asset type slideshow -->
            <xsl:when test="$asset/traits/type/@type='extended-media.slideshow.'">
              <xsl:variable name="slideAssetId" select="tokenize($asset/relations/relation[@type='user.media.'][1]/@ref_asset, '/')[3]"/>
              <xsl:variable name="slideAsset" select="if ($slideAssetId) then cs:get-asset(xs:long($slideAssetId)) else ()"/>
              <xsl:variable name="thumbnailStorageItem" select="if ($slideAsset) then $slideAsset/storage_item[@key='thumbnail'][1] else ()"/>
              <xsl:choose>
                <!-- slide has thumbnail preview -->
                <xsl:when test="$thumbnailStorageItem">
                  <xsl:sequence select="$thumbnailStorageItem/@url"/>
                </xsl:when>
                <!-- follow media related assets -->
                <xsl:otherwise>
                  <xsl:variable name="textAssets" select="for $x in $slideAsset/child_asset_rel[@key='user.main-content.']/@child_asset return cs:get-asset($x)"/>
                  <xsl:variable name="locale" select="cs:master-data('party')[@id=system-property('censhare:party-id')]/@locale"/>
                  <xsl:variable name="textAsset" select="if ($textAssets) then (if ($textAssets/@language=$locale) then $textAssets[@language=$locale][1] else $textAssets[1]) else ()"/>
                  <xsl:variable name="imageAssetId" select="if ($textAsset) then $textAsset/child_asset_rel[@key='actual.key-visual.']/@child_asset else ()"/>
                  <xsl:variable name="imageAsset" select="if ($imageAssetId) then cs:get-asset(xs:long($imageAssetId)) else ()"/>
                  <xsl:variable name="thumbnailStorageItem" select="if ($imageAsset) then $imageAsset/storage_item[@key='thumbnail'][1] else ()"/>
                  <xsl:sequence select="if ($thumbnailStorageItem) then $thumbnailStorageItem/@url else ()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- asset type slide -->
            <xsl:when test="$asset/traits/type/@type='extended-media.slide.'">
              <xsl:variable name="textAssets" select="for $x in $asset/relations/relation[@type='user.main-content.']/@ref_asset return cs:get-asset(xs:long(tokenize($x, '/')[3]))"/>
              <xsl:variable name="locale" select="cs:master-data('party')[@id=system-property('censhare:party-id')]/@locale"/>
              <xsl:variable name="textAsset" select="if ($textAssets) then (if ($textAssets/@language=$locale) then $textAssets[@language=$locale][1] else $textAssets[1]) else ()"/>
              <xsl:variable name="imageAssetId" select="if ($textAsset) then $textAsset/child_asset_rel[@key='actual.key-visual.']/@child_asset else ()"/>
              <xsl:variable name="imageAsset" select="if ($imageAssetId) then cs:get-asset(xs:long($imageAssetId)) else ()"/>
              <xsl:variable name="thumbnailStorageItem" select="if ($imageAsset) then $imageAsset/storage_item[@key='thumbnail'][1] else ()"/>
              <xsl:sequence select="if ($thumbnailStorageItem) then $thumbnailStorageItem/@url else ()"/>
            </xsl:when>
            <!-- asset type issue -->
            <xsl:when test="$asset/traits/type/@type='issue.'">
              <xsl:variable name="firstPlacedAssetId" select="tokenize($asset/planning_root/pages/page[1]/planning_element_relations[1]/planning_element_relation[@type='target.'][1]/@ref_asset, '/')[3]"/>
              <xsl:variable name="placedAsset" select="if ($firstPlacedAssetId) then cs:get-asset(xs:long($firstPlacedAssetId)) else ()"/>
              <xsl:variable name="thumbnailStorageItem" select="if ($placedAsset) then $placedAsset/storage_item[@key='thumbnail'][1] else ()"/>
              <xsl:sequence select="if ($thumbnailStorageItem) then $thumbnailStorageItem/@url else ()"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$assetTypeThumbnailStorageItemUrl">
            <xsl:value-of select="$assetTypeThumbnailStorageItemUrl"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- find fallback via relation user.main-picture. -->
            <xsl:variable name="mainPictureAssetId" select="tokenize($asset/relations/relation[@type='user.main-picture.'][1]/@ref_asset, '/')[3]"/>
            <xsl:variable name="mainPictureAsset" select="if ($mainPictureAssetId) then cs:get-asset(xs:long($mainPictureAssetId)) else ()"/>
            <xsl:variable name="thumbnailStorageItem" select="if ($mainPictureAsset) then $mainPictureAsset/storage_item[@key='thumbnail'][1] else ()"/>
            <xsl:value-of select="if ($thumbnailStorageItem) then $thumbnailStorageItem/@url else ()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- get working time text -->
  <xsl:function name="csc:getWorkingTimeUnitKey" as="xs:string">
    <xsl:param name="value" as="xs:double"/>
    <xsl:param name="unit" as="xs:string"/>
    <xsl:variable name="valueString" select="cs:format-number($value, '#,##0.#')"/>
    <xsl:choose>
      <xsl:when test="$unit='wmo'">
        <xsl:value-of select="if ($valueString='1') then 'month' else 'months'"/>
      </xsl:when>
      <xsl:when test="$unit='ww'">
        <xsl:value-of select="if ($valueString='1') then 'week' else 'weeks'"/>
      </xsl:when>
      <xsl:when test="$unit='wd'">
        <xsl:value-of select="if ($valueString='1') then 'day' else 'days'"/>
      </xsl:when>
      <xsl:when test="$unit='wh'">
        <xsl:value-of select="if ($valueString='1') then 'hour' else 'hours'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="cs:master-data('unit')[@key=$unit]/@name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- get localized asset name of given asset ID or resource key -->
  <xsl:function name="csc:getLocalizedAssetName" as="xs:string?">
    <xsl:param name="value" as="xs:string"/>
    <xsl:variable name="asset" select="if ($value castable as xs:long) then cs:get-asset(xs:long($value)) else cs:get-resource-asset($value)"/>
    <xsl:variable name="name" select="if ($asset) then $asset/asset_feature[@feature='censhare:name' and @language=$language][1]/@value_string else ()"/>
    <xsl:value-of select="if ($name) then $name else $asset/@name"/>
  </xsl:function>

</xsl:stylesheet>
