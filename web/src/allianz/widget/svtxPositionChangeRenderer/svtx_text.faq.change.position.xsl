<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:svtx="http://www.savotex.com"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                exclude-result-prefixes="#all"
                version="2.0">
    <!--   Wird von der Tabellefunction moveposition aufgerufen und verschiebt das FAQ-TextAsset in der Position -->

    <xsl:param name="move-up" select="'true'" as="xs:string"/>

    <xsl:function name="svtx:updateSorting">
        <xsl:param name="textFaqID" as="xs:integer"/>
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="articleFaqID" as="xs:integer"/>

        <xsl:message> === sort <xsl:value-of select="$textFaqID"/> =  <xsl:value-of select="$position"/>  =  <xsl:value-of select="$articleFaqID"/>  </xsl:message>
        <xsl:variable name="textAsset" select="$textFaqID/cs:asset()"/>

        <!-- Ohne Ändrungshistorie, da sonst etliche unnötige Trigger gestartet werden -->
        <cs:command name="com.censhare.api.assetmanagement.Update">
            <cs:param name="source">
                <asset>
                    <xsl:copy-of select="$textAsset/@*"/>
                    <xsl:copy-of select="$textAsset/node() except($textAsset/(parent_asset_rel[@key='user.main-content.']),$textAsset/asset_element )"/>
                    <asset_element idx="0" key="actual."/>

                    <parent_asset_rel key="user.main-content." parent_asset="{$articleFaqID}" sorting="{$position}"/>
                </asset>
            </cs:param>
        </cs:command>


    </xsl:function>

    <!-- Normaliesiert die Sortierreihenfolge der TextAsset wenn nötig und gibt die Anzahl zurück -->
    <xsl:function name="svtx:normalizeSorting" as="xs:integer">
        <xsl:param name="articleAsset" as="element(asset)"/>
        <xsl:for-each select="$articleAsset/child_asset_rel[@key='user.main-content.']">
            <xsl:sort select="./@sorting"/>
            <xsl:if test="position()!=./@sorting">
                <xsl:variable name="ret" select="svtx:updateSorting(./@child_asset,position(),$articleAsset/@id)"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="count($articleAsset/cs:child-rel()[@key='user.main-content.'])"/>
    </xsl:function>



    <xsl:function name="svtx:checkInAsset">
        <xsl:param name="asset" as="element(asset)"/>

        <cs:command name="com.censhare.api.assetmanagement.CheckIn" returning="result">

            <cs:param name="source">
                <asset>
                    <xsl:copy-of select="$asset/@*"/>
                    <xsl:copy-of select="$asset/node() except ($asset/asset_element)"/>
                    <asset_element idx="0" key="actual."/>
                </asset>
            </cs:param>
        </cs:command>
        <xsl:copy-of select="$result" />
    </xsl:function>

    <xsl:function name="svtx:checkOutAsset" as="element(asset)?">
        <xsl:param name="asset" as="element(asset)?"/>
        <cs:command name="com.censhare.api.assetmanagement.CheckOut">
            <cs:param name="source">
                <xsl:copy-of select="$asset"/>
            </cs:param>
        </cs:command>
    </xsl:function>






    <xsl:template match="asset[@type='text.faq.']">
        <result>
        <xsl:message>=== svtx:text.faq.change.position <xsl:value-of select="@id"/> UP=<xsl:value-of select="$move-up"/>  </xsl:message>
        <xsl:variable name="parent" select="(./cs:parent-rel()[@key='user.main-content.'])/cs:asset()"/>
        <xsl:variable name="count" select="svtx:normalizeSorting($parent)"/>

        <xsl:if test="$count>1" >
            <!-- Wenn welche geändert wurden ,dann speichern -->
            <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
                <cs:param name="flush" select="true()"/>
            </cs:command>



            <xsl:variable name="asset" select="cs:get-asset(@id)"/>


            <xsl:variable name="currentPos" select="$asset/parent_asset_rel[@key='user.main-content.']/@sorting" as="xs:integer"/>

            <xsl:variable name="asset2pos" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="$move-up = 'true'">
                        <xsl:choose>
                            <xsl:when test="$currentPos=1"><xsl:value-of select="$count"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="$currentPos - 1"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise><!-- => move down -->
                        <xsl:choose>
                            <xsl:when test="$currentPos=$count">1</xsl:when>
                            <xsl:otherwise><xsl:value-of select="$currentPos + 1"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="asset2" select="$parent/child_asset_rel[@key='user.main-content.' and @sorting=$asset2pos]/@child_asset/cs:asset()"/>

            <xsl:message>=== Haupt  <xsl:value-of select="$asset/@id"/> ==  <xsl:value-of select="$asset2/@id"/>llll</xsl:message>
            <!-- tauschen der sorting Positionen -->

            <xsl:variable name="ret" select="svtx:updateSorting($asset/@id,$asset2pos,$parent/@id)"/>
            <xsl:variable name="ret1" select="svtx:updateSorting($asset2/@id,$currentPos,$parent/@id)"/>

            <cs:command name="com.censhare.api.assetmanagement.CommitOrFlush">
                <cs:param name="flush" select="true()"/>
            </cs:command>

            <!-- der Erste mit Powerpoints erhält ein Update, damit diese neu erstellt werden -->
            <xsl:choose>
                <xsl:when test="count($ret/asset_feature[@feature='svtx:faq.medium'])>1">
                    <xsl:variable name="co" select="svtx:checkOutAsset($ret)"/>
                    <xsl:variable name="ci" select="svtx:checkInAsset($co)"/>

                    <!--
                    <xsl:variable name="ci" select="svtx:checkInNewAsset($co)"/>
                    <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans1">
                        <cs:param name="key" select="'svt:regenerate.pptx.faq.slide.on.text.changed'"/>
                        <cs:param name="source" select="$ret"/>
                    </cs:command>
                        -->
                </xsl:when>
                <xsl:when test="count($ret1/asset_feature[@feature='svtx:faq.medium'])>1">
                    <xsl:variable name="co" select="svtx:checkOutAsset($ret1)"/>
                    <xsl:variable name="ci" select="svtx:checkInAsset($co)"/>
                    <!--
                    <xsl:variable name="ci" select="svtx:checkInNewAsset($co)"/>
                    <cs:command name="com.censhare.api.transformation.AssetTransformation" returning="trans1">
                        <cs:param name="key" select="'svt:regenerate.pptx.faq.slide.on.text.changed'"/>
                        <cs:param name="source" select="$ret1"/>
                    </cs:command>
                    -->
                </xsl:when>
            </xsl:choose>


          <ret><xsl:value-of select="$asset2/@id"/> </ret>
        </xsl:if>
        </result>
    </xsl:template>



</xsl:stylesheet>