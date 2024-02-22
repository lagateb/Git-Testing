<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:template match="/asset[@type = 'layout.']">
    <xsl:variable name="indesignStorageItem" select="storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:if test="$indesignStorageItem">
      <xsl:variable name="appVersion" select="concat('indesign-', $indesignStorageItem/@app_version)" as="xs:string"/>
      <xsl:variable name="renderResult">
        <cs:command name="com.censhare.api.Renderer.Render">
          <cs:param name="facility" select="$appVersion"/>
          <cs:param name="instructions">
            <cmd>
              <renderer>
                <command method="open" asset_id="{ @id }" document_ref_id="1"/>
                <command document_ref_id="1" method="report" expand="geometry" structure="content"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <xsl:copy-of select="."/>
              </assets>
            </cmd>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:copy-of select="$renderResult/cmd/report"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
