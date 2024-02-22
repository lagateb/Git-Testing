<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>
  <xsl:import href="svtx_flyer.generator.v2.util.xsl" use-when="false()"/>

  <xsl:param name="risk-group" select="'A'" as="xs:string?"/>
  <xsl:param name="age" as="xs:long?"/>

  <!-- ### RESULT
    <customer age="20">
      <offer id="0" type="basic" gross="46.22" net="39.29" pension="1000.00"/>
      <offer id="1" type="basic+s" gross="54.99" net="46.74" pension="1000.00"/>
      <offer id="2" type="basic+s+p" gross="75.00" net="63.00" pension="1000.00"/>
      <offer id="0" type="basic" gross="91.19" net="77.51" pension="2000.00"/>
    </customer>
    <customer age="21">
      <offer id="0" type="basic" gross="46.22" net="39.29" pension="1000.00"/>
      <offer id="1" type="basic+s" gross="54.99" net="46.74" pension="1000.00"/>
      <offer id="2" type="basic+s+p" gross="75.00" net="63.00" pension="1000.00"/>
      <offer id="0" type="basic" gross="91.19" net="77.51" pension="2000.00"/>
    </customer>
  -->
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:template match="/asset">
    <xsl:variable name="storage" select="$rootAsset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="index" select="if (upper-case($risk-group) eq 'A') then 2 else 4" as="xs:long"/>
    <xsl:variable name="excel2xml" as="element(entry)*">
      <xsl:apply-templates select="svtx:readExcel($storage, $index)"/>
    </xsl:variable>
    <xsl:for-each-group select="$excel2xml" group-by="@age">
      <xsl:if test="current-grouping-key()">
        <customer age="{current-grouping-key()}">
          <xsl:copy-of select="current-group()/*"/>
        </customer>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>

  <!-- -->
  <xsl:template match="row[@index gt 8 and count(cell) gt 4]">
    <entry age="{svtx:getCellData(cell[1])}" duration="{svtx:getNumericCellData(cell[2])}">
      <offer id="0" type="basic" gross="{svtx:getNumericCellData(cell[3])}" net="{svtx:getNumericCellData(cell[4])}" pension="{svtx:getNumericCellData(cell[5])}"/>
      <xsl:if test="every $x in 6 to 9 satisfies exists(cell[$x])">
        <offer id="1" type="basic+s" gross="{svtx:getNumericCellData(cell[6])}" net="{svtx:getNumericCellData(cell[7])}" pension="{svtx:getNumericCellData(cell[9])}"/>
      </xsl:if>
      <xsl:if test="every $x in 10 to 13 satisfies exists(cell[$x])">
        <offer id="2" type="basic+s+p" gross="{svtx:getNumericCellData(cell[10])}" net="{svtx:getNumericCellData(cell[11])}" pension="{svtx:getNumericCellData(cell[13])}"/>
      </xsl:if>
    </entry>
  </xsl:template>

  <!-- -->
  <xsl:template match="text()"/>

</xsl:stylesheet>



