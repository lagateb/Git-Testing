<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">
  <!-- ========== Imports ========== -->
  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer-generator.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="../svtx_flyer-generator.util.xsl" use-when="false()"/>

  <!-- global -->

  <xsl:variable name="debug" select="false()" as="xs:boolean"/>

  <xsl:template match="/asset">
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>
    <xsl:message>### Export PDF Master Storage Item of Asset <xsl:value-of select="string-join((@name, @id), ' - ')"/> </xsl:message>
    <!-- move file-->
    <xsl:variable name="pdfStorage" select="storage_item[@key='master' and @mimetype=$PDF_MIME_TYPE]" as="element(storage_item)?"/>
    <xsl:variable name="profession" select="(cs:parent-rel()[@key='user.']/cs:asset()[@censhare:asset.type=$PROFESSION_ASSET_TYPE])[1]" as="element(asset)?"/>
    <xsl:variable name="professionId" select="$profession/asset_feature[@feature=$PROFESSION_ID_FEAT]/@value_long" as="xs:long?"/>
    <xsl:variable name="age" select="$profession/child_asset_rel[@key='user.' and @child_asset=$rootAsset/@id]/asset_rel_feature[@feature=$AGE_FEAT]/@value_long" as="xs:long?"/>
    <xsl:choose>
      <xsl:when test="exists($pdfStorage) eq false()">
        <xsl:message>### Skip Export ### Reason ### No PDF Storage found on Asset</xsl:message>
      </xsl:when>
      <xsl:when test="exists($profession) eq false()">
        <xsl:message>### Skip Export ### Reason ### No Related Profession Asset found</xsl:message>
      </xsl:when>
      <xsl:when test="exists($age) eq false()">
        <xsl:message>### Skip Export ### Reason ### No Age Feature found in Asset Relation</xsl:message>
      </xsl:when>
      <xsl:when test="exists($professionId) eq false()">
        <xsl:message>### Skip Export ### Reason ### No Profession ID Feature found Profession Asset</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="fileName" select="concat($age, '.pdf')" as="xs:string"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="destFile" select="concat($out, $fileName)"/>
        <cs:command name="com.censhare.api.io.Copy">
          <cs:param name="source" select="storage_item[@key='master'][1]"/>
          <cs:param name="dest" select="$destFile"/>
        </cs:command>
        <xsl:variable name="path" select="concat('censhare:///service/filesystem/interfaces/flyerpdf/', $professionId, '/', $age)" as="xs:string?"/>
        <cs:command name="com.censhare.api.io.Move">
          <cs:param name="source" select="$destFile"/>
          <cs:param name="dest" select="$path"/>
        </cs:command>
        <xsl:if test="$debug">
          <debug url="{$pdfStorage/@url}" profession="{string-join($profession/(@name,@id), ' - ')}" id="{$professionId}" age="{$age}" path="{$path}/{$fileName}"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>