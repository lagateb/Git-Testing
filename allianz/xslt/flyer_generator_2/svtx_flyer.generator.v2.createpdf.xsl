<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="svtx_flyer.generator.v2.util.xsl" use-when="false()"/>

  <xsl:template match="/asset[starts-with(@type, 'layout.')]">
    <xsl:variable name="storageItem" select="storage_item[@key='master' and @mimetype='application/indesign']" as="element(storage_item)?"/>
    <xsl:if test="$storageItem">
      <xsl:variable name="appVersion" select="concat('indesign-', $storageItem/@app_version)"/>
      <xsl:variable name="renderResult" as="element(cmd)">
        <cs:command name="com.censhare.api.Renderer.Render">
          <cs:param name="facility" select="$appVersion"/>
          <cs:param name="instructions">
            <cmd>
              <renderer>
                <command method="open" asset_id="{@id}" document_ref_id="1"/>
                <command method="pdf" spread="true" document_ref_id="1"/>
                <command method="close" document_ref_id="1"/>
              </renderer>
              <assets>
                <xsl:copy-of select="."/>
              </assets>
            </cmd>
          </cs:param>
        </cs:command>
      </xsl:variable>
      <xsl:variable name="pdfResult" select="$renderResult[@statename='completed all']/renderer/command[@method='pdf']" as="element(command)?"/>

      <xsl:if test="exists($pdfResult)">
        <xsl:variable name="newAssetXml">
          <asset name="{@name} - PDF" type="document." domain="root.flyer-generator.v2.">
            <asset_element key="actual." idx="0"/>
            <parent_asset_rel key="user." parent_asset="{@id}"/>
            <storage_item corpus:asset-temp-file-url="{svtx:getUrlOfRenderCmd($pdfResult)}" element_idx="0" key="master" mimetype="application/pdf" />
          </asset>
        </xsl:variable>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew">
          <cs:param name="source">
            <xsl:copy-of select="$newAssetXml"/>
          </cs:param>
        </cs:command>
      </xsl:if>


    </xsl:if>
  </xsl:template>

</xsl:stylesheet>