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

  <xsl:template match="/asset[starts-with(@type, $TEXT_ASSET_TYPE)]">
    <xsl:variable name="rootAsset" select="." as="element(asset)?"/>

    <!--
    Suche alle Berufe, welche keine PDF Rendering Flag haben

    +

    1) Der Text ist direkt mit einem Beruf verknüpft
    2) Der Text ist mit einem produkt verknüpft,
       welches mit einem weiteren Produkt verknüpft ist
       welches eine Gruppe als Kind Verknüpfung hat
       welches Kindverknüpfungen für Berufe hat
    -->

    <xsl:variable name="professionAssetQuery" as="element(query)">
      <query>
        <condition name="censhare:asset.type" value="{$PROFESSION_ASSET_TYPE}"/>
        <condition name="censhare:asset.domain" value="{$FLYER_GENERATOR_DOMAIN}"/>
        <or>
          <and>
            <or>
              <condition name="{$PDF_RENDERING_PENDING}" value="0"/>
              <condition name="{$PDF_RENDERING_PENDING}" op="ISNULL"/>
            </or>
            <relation target="child" type="user.article-pos-*">
              <target>
                <condition name="censhare:asset.id" value="{$rootAsset/@id}"/>
              </target>
            </relation>
          </and>
          <and>
            <or>
              <condition name="{$PDF_RENDERING_PENDING}" value="0"/>
              <condition name="{$PDF_RENDERING_PENDING}" op="ISNULL"/>
            </or>
            <relation target="parent" type="user.*">
              <target>
                <condition name="censhare:asset.type" value="group.*"/>
                <relation target="parent" type="target.*">
                  <target>
                    <condition name="censhare:asset.type" value="product.*"/>
                    <relation target="child" type="user.product.*">
                      <target>
                        <condition name="censhare:asset.type" value="product.*"/>
                        <relation target="child" type="user.*">
                          <target>
                            <condition name="censhare:asset.type" value="article.*"/>
                            <relation target="child" type="user.main-content.*">
                              <target>
                                <condition name="censhare:asset.id" value="{$rootAsset/@id}"/>
                              </target>
                            </relation>
                          </target>
                        </relation>
                      </target>
                    </relation>
                  </target>
                </relation>
              </target>
            </relation>
          </and>
        </or>
      </query>
    </xsl:variable>
    <xsl:apply-templates select="cs:asset($professionAssetQuery)" mode="update"/>
  </xsl:template>

  <xsl:template match="asset[@type=$PROFESSION_ASSET_TYPE]" mode="update">
    <xsl:copy-of select="svtx:setRenderFlagIfNotExist(.)"/>
  </xsl:template>
</xsl:stylesheet>