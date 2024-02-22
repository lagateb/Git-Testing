<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs censhare svtx xs">
  
  <!-- asset match -->
  <xsl:template match="asset">
    <result>
      <type>pie</type>
      <title>${workflowStates}</title>
      <!--<subTitle>Workflow Status der Textinhalte</subTitle>-->
      <legend censhare:_annotation.datatype="boolean">false</legend>
      <data censhare:_annotation.arraygroup="true">
        <xsl:variable name="textAssets" select="cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*'  and @censhare:asset.wf_id and @censhare:asset.wf_step]" as="element(asset)*"/>
        <xsl:for-each-group select="$textAssets" group-by="svtx:getWorkflowStateId(.)">
          <xsl:variable name="wfState" select="cs:master-data('workflow_state')[@id = current-grouping-key()][1]" as="element(workflow_state)?"/>
          <xsl:variable name="stateName" select="$wfState/@name" as="xs:string?"/>
          <xsl:variable name="assetIds" select="current-group()/@id" as="xs:string*"/>
          <group>
            <key><xsl:value-of select="$wfState/@name"/></key>
            <value><xsl:value-of select="count(current-group())"/></value>
            <color><xsl:value-of select="svtx:getWorkflowStateColor(current-grouping-key())"/></color>
            <pageParam><xsl:value-of select="concat('/search?queryString=', encode-for-uri('{&#34;condition&#34;: {&#34;name&#34;: &#34;censhare:asset.id&#34;, &#34;op&#34;: &#34;IN&#34;, &#34;sepchar&#34;: &#34;,&#34;, &#34;value&#34;: &#34;'), encode-for-uri(string-join($assetIds,',')), encode-for-uri('&#34;}}'), '&#38;sTitle=', encode-for-uri(concat(cs:master-data('feature')[@key='censhare:function.workflow-state']/@name, ': ', $stateName)))"/></pageParam>
          </group>
        </xsl:for-each-group>
      </data>
    </result>
  </xsl:template>
  
  <xsl:function name="svtx:integerToHex" as="xs:string">
    <xsl:param name="in" as="xs:integer"/>
    <xsl:sequence select="if ($in eq 0) then '0' else concat(if ($in gt 16) then svtx:integerToHex($in idiv 16) else '', substring('0123456789ABCDEF', ($in mod 16) + 1, 1))"/>
  </xsl:function>
  
  <xsl:function name="svtx:getWorkflowStateId" as="xs:long?">
    <xsl:param name="asset" as="element(asset)"/>
    <xsl:value-of select="if ($asset/@wf_id and $asset/@wf_step) then cs:master-data('workflow_step')[@wf_id=$asset/@wf_id and @wf_step=$asset/@wf_step]/@wf_state_id else ()"/>
  </xsl:function>
  
  <xsl:function name="svtx:getWorkflowStateColor" as="xs:string?">
    <xsl:param name="id" as="xs:integer"/>
    <xsl:variable name="intColor" select="cs:master-data('workflow_state')[@id=$id]/@color"/>
    <xsl:value-of select="svtx:integerToHtmlColor($intColor)"/>
  </xsl:function>
  
  <xsl:function name="svtx:integerToHtmlColor" as="xs:string">
    <xsl:param name="in" as="xs:integer"/>
    <xsl:variable name="hexString" select="svtx:integerToHex($in)"/>
    <xsl:value-of select="concat('#', substring('000000', 1, 6 - string-length($hexString)), $hexString)"/>
  </xsl:function>

</xsl:stylesheet>