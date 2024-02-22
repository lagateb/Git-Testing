<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:flyer.generator.v2.util/storage/master/file"/>
  <!-- only in IDE -->
  <xsl:import href="../svtx_flyer.generator.v2.util.xsl" use-when="false()"/>

  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

  <!-- match product with excel sheet -->
  <xsl:template match="/asset">
    <xsl:variable name="jobGroup" as="element(asset)?">
      <xsl:variable name="jobGroupAsset" select="cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='group.']" as="element(asset)?"/>
      <xsl:choose>
        <xsl:when test="$jobGroupAsset">
          <xsl:copy-of select="$jobGroupAsset"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="assetXml" as="element(asset)">
            <asset type="group." name="Berufe" domain="root.flyer-generator.v2.">
              <parent_asset_rel parent_asset="{@id}" key="user."/>
            </asset>
          </xsl:variable>
          <xsl:copy-of select="svtx:checkInNew($assetXml)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="serviceDescriptions" select="cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='article.']/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type='text.']" as="element(asset)*"/>
    <xsl:apply-templates select="svtx:readExcel(storage_item[@key='master'], 0)">
      <xsl:with-param name="parentAsset" select="$jobGroup"/>
      <xsl:with-param name="serviceDescriptions" select="$serviceDescriptions"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- -->
  <xsl:template match="text()"/>

  <!-- -->
  <xsl:template match="row[@index gt 2 and count(cell) gt 8]">
    <xsl:param name="parentAsset" as="element(asset)?"/>
    <xsl:param name="serviceDescriptions" as="element(asset)*"/>
    <xsl:variable name="id" select="svtx:getCellData(cell[1])" as="xs:string?"/>
    <xsl:variable name="jobName" select="svtx:getCellData(cell[2])" as="xs:string?"/>
    <xsl:variable name="riskGroup" select="svtx:getCellData(cell[4])" as="xs:string?"/>
    <xsl:if test="$id and $jobName and $riskGroup">
      <xsl:variable name="basicSkills1" select="svtx:getCellData(cell[7])" as="xs:string?"/>
      <xsl:variable name="basicSkills2" select="svtx:getCellData(cell[8])" as="xs:string?"/>
      <xsl:variable name="basicSkills3" select="svtx:getCellData(cell[9])" as="xs:string?"/>
      <xsl:variable name="basicSkills4" select="svtx:getCellData(cell[10])" as="xs:string?"/>
      <xsl:variable name="basicSkillsAssets" as="element(asset)*">
        <xsl:for-each select="($basicSkills1, $basicSkills2, $basicSkills3, $basicSkills4)">
          <xsl:variable name="val" select="." as="xs:string?"/>
          <xsl:copy-of select="$serviceDescriptions[asset_feature[@feature='svtx:leistungsbeschreibung' and @value_string = $val]][1]"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="selectableProtection1" select="svtx:getCellData(cell[11])" as="xs:string?"/>
      <xsl:variable name="selectableProtection2" select="svtx:getCellData(cell[12])" as="xs:string?"/>
      <xsl:variable name="selectableProtection3" select="svtx:getCellData(cell[13])" as="xs:string?"/>
      <xsl:variable name="selectableProtection4" select="svtx:getCellData(cell[14])" as="xs:string?"/>
      <xsl:variable name="selectableProtectionAssets" as="element(asset)*">
        <xsl:for-each select="($selectableProtection1, $selectableProtection2, $selectableProtection3, $selectableProtection4)">
          <xsl:variable name="val" select="." as="xs:string?"/>
          <xsl:copy-of select="$serviceDescriptions[asset_feature[@feature='svtx:leistungsbeschreibung' and @value_string = $val]][1]"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="existingProfessionAsset" select="($parentAsset/cs:child-rel()[@key='user.']/cs:asset()[@censhare:asset.type = 'profession.' and @svtx:job-id = $id])[1]" as="element(asset)?"/>
      <xsl:choose>
        <xsl:when test="$existingProfessionAsset">
          <xsl:variable name="nameChanged" select="not($existingProfessionAsset/@name = $jobName)" as="xs:boolean?"/>
          <xsl:variable name="riskGroupChanged" select="not($existingProfessionAsset/asset_feature[@feature='svtx:flyer.generator.risk.group']/@value_string = $riskGroup)" as="xs:boolean?"/>
          <xsl:variable name="basicSkillsChanged" select="not(every $x in $basicSkillsAssets/@id satisfies $existingProfessionAsset/child_asset_rel[@key='user.basic-skills.' and @child_asset = $x and @sorting = index-of($basicSkillsAssets/@id, $x)])" as="xs:boolean"/>
          <xsl:variable name="protectionChanged" select="not(every $x in $selectableProtectionAssets/@id satisfies $existingProfessionAsset/child_asset_rel[@key='user.selectable-protection.' and @child_asset = $x and @sorting = index-of($selectableProtectionAssets/@id, $x)])" as="xs:boolean"/>
          <xsl:if test="$nameChanged or $riskGroupChanged or $basicSkillsChanged or $protectionChanged">
            <xsl:variable name="checkedOut" select="svtx:checkOutAsset($existingProfessionAsset)" as="element(asset)?"/>
            <xsl:variable name="assetXml" as="element(asset)">
              <asset name="{$jobName}">
                <xsl:copy-of select="$checkedOut/@* except $checkedOut/@name"/>
                <xsl:copy-of select="$checkedOut/node() except $checkedOut/(asset_feature[@feature = ('svtx:flyer.generator.risk.group','svtx:profession-pdf-rendering-pending')], child_asset_rel[@key=('user.basic-skills.', 'user.selectable-protection.')])"/>
                <asset_feature feature="svtx:flyer.generator.risk.group" value_string="{$riskGroup}"/>
                <xsl:for-each select="distinct-values($basicSkillsAssets/@id)">
                  <child_asset_rel child_asset="{.}" key="user.basic-skills." sorting="{position()}"/>
                </xsl:for-each>
                <xsl:for-each select="distinct-values($selectableProtectionAssets/@id)">
                  <child_asset_rel child_asset="{.}" key="user.selectable-protection." sorting="{position()}"/>
                </xsl:for-each>
                <asset_feature feature="svtx:profession-pdf-rendering-pending" value_long="1"/>
              </asset>
            </xsl:variable>
            <xsl:copy-of select="svtx:checkInAsset($assetXml)"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="assetXml" as="element(asset)">
            <asset name="{$jobName}" type="profession." domain="root.flyer-generator.v2.">
              <asset_feature feature="svtx:job-id" value_long="{$id}"/>
              <asset_feature feature="svtx:flyer.generator.risk.group" value_string="{$riskGroup}"/>
              <parent_asset_rel parent_asset="{$parentAsset/@id}" key="user."/>
              <xsl:for-each select="distinct-values($basicSkillsAssets/@id)">
                <child_asset_rel child_asset="{.}" key="user.basic-skills." sorting="{position()}"/>
              </xsl:for-each>
              <xsl:for-each select="distinct-values($selectableProtectionAssets/@id)">
                <child_asset_rel child_asset="{.}" key="user.selectable-protection." sorting="{position()}"/>
              </xsl:for-each>
              <asset_feature feature="svtx:profession-pdf-rendering-pending" value_long="1"/>
            </asset>
          </xsl:variable>
          <xsl:copy-of select="svtx:checkInNew($assetXml)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>