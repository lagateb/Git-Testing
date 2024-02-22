<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:svtx="http://www.savotex.com"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">


  <xsl:template match="/asset[starts-with(@type, 'text.')]">
    <xsl:variable name="rootAsset" select="."/>
    <xsl:variable name="article" select="cs:parent-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='article.*']"/>
    <xsl:variable name="productQuery" as="element(query)">
      <query type="asset">
        <condition name="censhare:asset.type" value="product.*"/>
        <relation target="child" type="user.*">
          <target>
            <condition name="censhare:asset.type" value="article.*"/>
            <condition name="svtx:recurring-module-of" value="{$article/@id}"/>
            <relation target="child" type="user.main-content.">
              <target>
                <condition name="censhare:asset.type" value="{$rootAsset/@type}"/>
              </target>
            </relation>
          </target>
        </relation>
      </query>
    </xsl:variable>

    <result>
      <options censhare:_annotation.arraygroup="true">
        <xsl:for-each select="cs:asset($productQuery)">
          <xsl:variable name="responsible" select="(cs:child-rel()[@key='user.responsible.'])[1]" as="element(asset)?"/>
          <xsl:variable name="party" select="if (exists($responsible)) then cs:master-data('party')[@party_asset_id=$responsible/@id] else ()"/>
          <xsl:if test="$party">
            <option>
              <name censhare:_annotation.datatype="string"><xsl:value-of select="@name"/></name>
              <type censhare:_annotation.datatype="string"><xsl:value-of select="@type"/></type>
              <id censhare:_annotation.datatype="number"><xsl:value-of select="@id"/></id>
              <display_name censhare:_annotation.datatype="string"><xsl:value-of select="concat(@name, ' (', $party/@firstname, ' ', $party/@name, ' - ', $party/@email, ')')"/></display_name>
              <xsl:if test="$party">
                <responsible>
                  <xsl:copy-of select="$party"/>
                  <mail censhare:_annotation.datatype="string"><xsl:value-of select="$party/@name"/></mail>
                  <name censhare:_annotation.datatype="string"><xsl:value-of select="$party/@email"/></name>
                  <display_name censhare:_annotation.datatype="string"><xsl:value-of select="$party/@display_name"/></display_name>
                </responsible>
              </xsl:if>
            </option>
          </xsl:if>
        </xsl:for-each>
      </options>
    </result>
  </xsl:template>
</xsl:stylesheet>
