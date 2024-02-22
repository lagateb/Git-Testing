<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                xmlns:msp="http://www.mspag.com"
                exclude-result-prefixes="#all">
  <!-- toolbar for articles table -->
  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>
  <!-- output -->
  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>
  <xsl:variable name="language" select="csc:getLoggedInPartyLocale()"/>
  <!-- root match -->
  <xsl:template match="/">
    <xsl:variable name="endDate" select="format-date(current-date(), '[Y]-[M,2]-[D,2]')"/>
    <xsl:variable name="startDate" select="format-date(current-date() - xs:dayTimeDuration('P12M'), '[Y]-[M,2]-[D,2]')"/>
    <result>
      <!-- config contains default values, has to be prepared before, doesn't work if inserted in <defaultValues> because of xsl:value-of -->
      <xsl:variable name="defaultValues">{"myPromotions": "no", "stateFilter": "Freigabe Reinzeichnung", "sortBy": "promotionnr", "sortOrder": "ascending", "selection": "", "startDate": "<xsl:value-of select="$startDate"/>", "endDate": "<xsl:value-of select="$endDate"/>"}</xsl:variable>
      <config>
        <defaultValues>
          <xsl:value-of select="$defaultValues"/>
        </defaultValues>
      </config>
      <!-- content expects html snippet that is rendered in the widget -->
      <content>

        <!-- My Promotions -->
        <xsl:variable name="labelMyPromotions" select="'Nur meine Maßnahmen'" />
        <xsl:variable name="myPromotions" as="element(assign-to)*">
          <assign-to name="Ja" value="yes"/>
          <assign-to name="Nein" value="no"/>
        </xsl:variable>

        <!-- States -->
        <xsl:variable name="labelState" select="'Status'" />
        <xsl:variable name="stateFilter" as="element(state)*">
          <state name="ausgeliefert" value="ausgeliefert"/>
          <state name="Freigabe Reinzeichnung" value="Freigabe Reinzeichnung"/>
          <state name="Freigabe Layout" value="Freigabe Layout"/>
          <state name="geschlossen" value="geschlossen"/>
        </xsl:variable>

        <!-- Date range -->
        <xsl:variable name="labelDate" select="'Erstellungsdatum'" />

        <!-- Sorting -->
        <xsl:variable name="labelSortBy" select="'Sortiert nach'" />
        <xsl:variable name="sortOptions" as="element(sort)*">
          <sort name="Name" value="name"/>
          <sort name="Nummer" value="promotionnr"/>
          <sort name="Artikelnummer" value="artnr-and-version"/>
          <sort name="Mediendienstleister" value="mediaprovider"/>
          <sort name="Erstellungsdatum" value="creation-date"/>
          <!-- This will not work! -->
          <!--sort name="Mit Medien" value="with-media"/-->
          <!-- This will not work! -->
          <!--sort name="Qualität erfüllt" value="quality"/-->
        </xsl:variable>
        
        <xsl:variable name="labelSortOrder" select="'Sortiert nach'" />
        <xsl:variable name="sortOrders" as="element(sort)*">
          <sort name="Aufsteigend" value="ascending"/>
          <sort name="Absteigend" value="descending"/>
        </xsl:variable>

        <div class="cs-toolbar">
          <div class="cs-toolbar-slot-1">
            <div class="cs-toolbar-item">
              <cs-select class="cs-is-small cs-is-alt" label="{$labelMyPromotions}" width="auto" ng-model="toolbarData.myPromotions" unerasable="unerasable"
                         ng-options="item.value as item.name for item in [{msp:buildJSArray($myPromotions)}]"
                         ng-change="onChange({{ myPromotions: toolbarData.myPromotions }})">
              </cs-select>
            </div>
            <div class="cs-toolbar-item" style="max-width:240px; width:240px;">
              <cs-select class="cs-is-small cs-is-alt" label="{$labelState}" width="190px; max-width:190px" ng-model="toolbarData.stateFilter" unerasable="unerasable"
                         ng-options="item.value as item.name for item in [{msp:buildJSArray($stateFilter)}]"
                         ng-change="onChange({{ stateFilter: toolbarData.stateFilter }})">
              </cs-select>
            </div>
            <div class="cs-toolbar-item" style="width:200px;">
              <cs-datepicker class="cs-is-small cs-is-alt" label="{$labelDate}" style="width:120px; display: inline-block; margin-right: 10px;" date-only="true" required="true" ng-model="toolbarData.startDate" ng-change="onChange({{ stateFilter: toolbarData.startDate }})">
              </cs-datepicker>
              <cs-datepicker class="cs-is-small cs-is-alt" label="-" style="width:120px; display: inline-block;" date-only="true" required="true" ng-model="toolbarData.endDate" ng-change="onChange({{ stateFilter: toolbarData.endDate }})">
              </cs-datepicker>
            </div>
          </div>
          <div class="cs-toolbar-slot-5">
            <!-- order -->
            <div class="cs-toolbar-item cs-m-r-m">
              <cs-select class="cs-is-small cs-is-alt" label="{$labelSortOrder}" width="auto" ng-model="toolbarData.sortBy" unerasable="unerasable"
                         ng-options="item.value as item.name for item in [{msp:buildJSArray($sortOptions)}]"
                         ng-change="onChange({{ sortBy: toolbarData.sortBy }})">
              </cs-select>
              <cs-select class="cs-is-small cs-is-alt" label="" width="auto" ng-model="toolbarData.sortOrder" unerasable="unerasable"
                         ng-options="item.value as item.name for item in [{msp:buildJSArray($sortOrders)}]"
                         ng-change="onChange({{ sortOrder: toolbarData.sortOrder }})">
              </cs-select>
            </div>
            <!-- filter asset name -->
            <div class="cs-toolbar-item cs-m-r-s">
              <cs-input class="cs-is-small cs-is-alt" placeholder="${filterResults}" width="40pt" ng-model="toolbarData.selection" ng-change="onChange({{ selection: toolbarData.selection }})"></cs-input>
            </div>
          </div>
        </div>
      </content>
    </result>
  </xsl:template>

  <xsl:function name="msp:buildJSArray">
    <xsl:param name="input" as="element(*)*" />
    <xsl:variable name="objects" as="xs:string*">
      <xsl:for-each select="$input">
        <xsl:variable name="objMembers" as="xs:string*">
          <xsl:for-each select="@*">
            <xsl:sequence select="concat('''', local-name(), '''', ':', '''', current(), '''')" />
          </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="concat('{', string-join($objMembers, ','), '}')" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="string-join($objects, ',')" />
  </xsl:function>
</xsl:stylesheet>
