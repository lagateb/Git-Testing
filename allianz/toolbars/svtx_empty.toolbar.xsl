<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:csc="http://www.censhare.com/censhare-custom"
                exclude-result-prefixes="cs corpus csc">

  <!-- import -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=censhare:transformation.include/storage/master/file"/>

  <!-- output -->
  <xsl:output method="html" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- root match -->
  <xsl:template match="/">
    <result>
      <!-- config contains default values -->
      <config>
        <defaultValues>{"assetName": "", "assetType": "all", "assetWorkflowId": "all"}</defaultValues>
      </config>
      <!-- content expects html snippet that is rendered in the widget -->
      <content>

      </content>
    </result>
  </xsl:template>

</xsl:stylesheet>
