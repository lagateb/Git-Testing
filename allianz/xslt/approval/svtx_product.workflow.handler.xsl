<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="cs censhare xs">

  <xsl:template match="/asset">
    <xsl:variable name="product" select="cs:parent-rel()[@key='user.*']/cs:asset()[@censhare:asset.type='product.*']"/>
    <xsl:if test="$product">
      <xsl:variable name="allArticle" select="$product/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.*']" as="element(asset)*"/>
      <xsl:variable name="allArticleDone" select="every $a in $allArticle satisfies svtx:isWfStateDone($a) eq true()"/>
      <xsl:variable name="productIsDone" select="svtx:isWfStateDone($product)" as="xs:boolean?"/>
      <wf><xsl:value-of select="$allArticleDone"/></wf>
      <xsl:variable name="updatedProduct" as="element(asset)?">
        <asset>
          <xsl:choose>
            <xsl:when test="$allArticleDone eq true() and $productIsDone eq false()">
              <xsl:copy-of select="$product/@* except $product/(@wf_id, @wf_step)"/>
              <xsl:attribute name="wf_id" select="30"/>
              <xsl:attribute name="wf_step" select="80"/>
              <xsl:copy-of select="$product/node()"/>
            </xsl:when>
            <xsl:when test="$allArticleDone eq false() and $productIsDone eq true()">
              <xsl:copy-of select="$product/@* except $product/(@wf_id, @wf_step)"/>
              <xsl:attribute name="wf_id" select="30"/>
              <xsl:attribute name="wf_step" select="20"/>
              <xsl:copy-of select="$product/node()"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- nope -->
            </xsl:otherwise>
          </xsl:choose>
        </asset>
      </xsl:variable>
      <xsl:if test="$updatedProduct/@id">
        <cs:command name="com.censhare.api.assetmanagement.Update">
          <cs:param name="source" select="$updatedProduct"/>
        </cs:command>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:function name="svtx:isWfStateDone" as="xs:boolean?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="id" select="$asset/@wf_id" as="xs:long?"/>
    <xsl:variable name="step" select="$asset/@wf_step" as="xs:long?"/>
    <xsl:variable name="workflowStep" select="cs:master-data('workflow_step')[@wf_id=$id and @wf_step=$step]" as="element(workflow_step)?"/>
    <xsl:choose>
      <xsl:when test="$workflowStep">
        <xsl:value-of select="$workflowStep/@wf_state_id eq 30"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
