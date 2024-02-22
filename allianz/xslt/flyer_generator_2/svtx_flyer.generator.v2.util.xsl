<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:map="http://ns.censhare.de/mapping"
                exclude-result-prefixes="xs map"
                version="2.0">

  <!-- flyer-generator-render-pdf -->

  <!-- -->
  <xsl:function name="svtx:formatNumber">
    <xsl:param name="num"/>
    <xsl:if test="$num castable as xs:double">
      <xsl:value-of select="cs:localized-format-number('de', xs:double($num), '#,##0.00')"/>
    </xsl:if>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getUrlOfRenderCmd" as="xs:string">
    <xsl:param name="cmd"/>
    <xsl:variable name="fileSystem" select="$cmd/@corpus:asset-temp-filesystem"/>
    <xsl:variable name="filePath" select="$cmd/@corpus:asset-temp-filepath"/>
    <xsl:value-of select="concat('censhare:///service/filesystem/', $fileSystem, '/', if (starts-with($filePath, 'file:')) then substring-after($filePath, 'file:') else '')"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:readExcel">
    <xsl:param name="si" as="element(storage_item)?"/>
    <xsl:param name="sheet" as="xs:long?"/>
    <cs:command name="com.censhare.api.Office.ReadExcel">
      <cs:param name="source" select="$si"/>
      <cs:param name="sheet-index" select="xs:string($sheet)"/>
    </cs:command>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getCellData" as="xs:string?">
    <xsl:param name="cell" as="element(cell)?"/>
    <xsl:value-of select="normalize-space(string-join($cell//text(), ''))"/>
  </xsl:function>

  <xsl:function name="svtx:getNumericCellData" as="xs:string?">
    <xsl:param name="cell" as="element(cell)?"/>
    <xsl:value-of select="string-join(for $x in $cell/node() return if (local-name($x) eq 'decimal-sep') then '.' else if ($x castable as xs:long) then $x else '', '')"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:checkOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:if test="svtx:isCheckedOutAsset($asset)">
      <xsl:variable name="abortAsset" select="svtx:checkOutAbortAsset($asset)"/>
    </xsl:if>
    <cs:command name="com.censhare.api.assetmanagement.CheckOut" returning="result">
      <cs:param name="source" select="$asset" />
    </cs:command>
    <xsl:copy-of select="$result" />
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:isCheckedOutAsset" as="xs:boolean">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:value-of select="if ($asset/@checked_out_date) then true() else false()"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:checkOutAbortAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)"/>
    <cs:command name="com.censhare.api.assetmanagement.CheckOutAbort" returning="result">
      <cs:param name="source" select="$asset" />
    </cs:command>
    <xsl:copy-of select="$result" />
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:checkInAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)"/>
    <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="result">
      <cs:param name="source" select="$asset" />
    </cs:command>
    <xsl:copy-of select="$result" />
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:checkInNew" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
      <cs:param name="source">
        <xsl:copy-of select="$asset"/>
      </cs:param>
    </cs:command>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:updateAsset">
    <xsl:param name="asset" as="element(asset)"/>

    <cs:command name="com.censhare.api.assetmanagement.Update" returning="result">
      <cs:param name="source" select="$asset" />
    </cs:command>
    <xsl:copy-of select="$result" />
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getMainContentAsset" as="element(asset)?">
    <xsl:param name="article" as="element(asset)?"/>
    <xsl:copy-of select="($article/cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*'])[1]"/>
  </xsl:function>




</xsl:stylesheet>
