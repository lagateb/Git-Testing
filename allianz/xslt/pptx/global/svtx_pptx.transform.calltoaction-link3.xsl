<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping"
        exclude-result-prefixes="xs map"
        version="2.0">

  <xsl:variable name="debug" select="true()" as="xs:boolean"/>

  <xsl:template match="asset[starts-with(@type, 'text.')]">
    <xsl:variable name="masterStorage" select="storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="storageConent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>

    <xsl:if test="$storageConent">
      <xsl:variable name="cta" select="$storageConent/article/content/calltoaction-link" as="element(calltoaction-link)?"/>
      <xsl:variable name="url" select="$cta/@url" as="xs:string?"/>
      <xsl:variable name="formatedUrl" select="concat('https://', replace($url, 'https://', ''))"/>
      <calltoaction-link>
        <color value="#113388" hyperlink="{$formatedUrl}">
          <bold>
            <xsl:value-of select="$cta"/>
          </bold>
        </color>
      </calltoaction-link>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
