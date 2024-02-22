<?xml version="1.0" encoding="UTF-8"?>
<!--
   Diese Transformation wird automatisch im PPTX-Modul PPCapsulate aufgerufen
   - ersetzt die Fussnoten zusammen,die der Censhare Editor auseinander nimmt.
     <footnote>H</footnote><footnote><sub>2</sub></footnote><footnote>O</footnote>
      => <footnote>H<sub>2</sub>O</footnote>
   - erweitert das Strukturelement Footnote um die im Text vorhandenen Footnote Texte mit Nummerierung
   - ersetzt im Text alle Element-Footnotes gehen die Nummerierung => <sup>1</sup> ....

   SETZEN JETZT FONTSIZE => 8 WEGEN ORTCONTENT-713 PROBLEM
-->
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:svtx="http://www.savotex.com"
        xmlns:map="http://ns.censhare.de/mapping" xmlns:xls="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="#all"
        version="2.0">

    <xsl:variable name="debug" select="true()" as="xs:boolean"/>

    <xsl:variable name="masterStorage" select="asset/storage_item[@key='master']" as="element(storage_item)?"/>
    <xsl:variable name="storageContent" select="if ($masterStorage) then doc($masterStorage/@url) else ()"/>
    <xsl:variable name="transformedStoragecontent"><xsl:apply-templates select="$storageContent/*" mode="mergefootnotes"/></xsl:variable>
    <xsl:variable name="groupedFootnotes">
        <xsl:copy-of select="svtx:groupedFootnotes($transformedStoragecontent)"/>
    </xsl:variable>




    <xsl:template match="asset[starts-with(@type, 'text.')]">
        <xsl:message>TR ==== <xsl:copy-of select="$transformedStoragecontent"/> </xsl:message>
        <xsl:message>GF ==== <xsl:copy-of select="$groupedFootnotes"/> </xsl:message>
        <xsl:variable name="toConvert">
            <article>
                <content>
                    <xsl:apply-templates select="$transformedStoragecontent/article/content/*" />
                    <footnote> <font-size value="8.0">
                        <xsl:if test="$storageContent/article/content/footnote[text()]">
                            <xsl:copy-of select="concat($storageContent/article/content/footnote,' ')"/>
                        </xsl:if>
                        <xsl:apply-templates select="$groupedFootnotes/footnotes/footnote"  mode="numbered" />
                    </font-size>
                    </footnote>
                </content>
            </article>
        </xsl:variable>
        <!--            <xls:copy-of select="$toConvert"/>-->
        <xls:copy-of select="svtx:implodeSiblingFoonotes($toConvert)"/>
    </xsl:template>





    <xsl:template match="footnote" mode="mergefootnotes" priority="1">
        <xsl:variable name="hasSub" select="svtx:hasSubEl(.)" as="xs:boolean"/>
        <xsl:variable name="prevFootnote" select="preceding-sibling::footnote[1]"/>
        <xsl:variable name="nextFootnote" select="following-sibling::footnote[1]"/>
        <xsl:if test="not($prevFootnote) or (exists($prevFootnote) and svtx:hasSubEl($prevFootnote) = $hasSub)">
            <footnote><xsl:copy-of select="node()"/>
                <xsl:if test="(exists($nextFootnote) and svtx:hasSubEl($nextFootnote) != $hasSub)">
                    <xsl:apply-templates select="following-sibling::footnote[1]" mode="custom"/>
                </xsl:if>
            </footnote>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()" mode="mergefootnotes" priority="0.1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="mergefootnotes"/>
        </xsl:copy>
    </xsl:template>




    <xsl:template match="footnote" mode="custom">
        <xsl:variable name="hasSub" select="svtx:hasSubEl(.)" as="xs:boolean"/>
        <xsl:variable name="nextFootnote" select="following-sibling::footnote[1]"/>
        <xsl:copy-of select="node()"/>
        <xsl:if test="(exists($nextFootnote) and svtx:hasSubEl($nextFootnote) != $hasSub)">
            <xsl:apply-templates select="following-sibling::footnote[1]" mode="custom"/>
        </xsl:if>
    </xsl:template>


    <xsl:function name="svtx:hasSubEl" as="xs:boolean*">
        <xsl:param name="el"/>
        <xsl:value-of select="exists($el/sub)"/>
    </xsl:function>




    <xsl:template match="@*|node()"  >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="footnote"  >
        <xsl:apply-templates select="svtx:getFootnoteNumber($groupedFootnotes,.)" />
    </xsl:template>

    <xsl:template match="footnote" mode="numbered" >
        <!--<sup><xsl:value-of select="./@no"/></sup><xsl:value-of select="concat(normalize-space(*|node()),' ')"/>-->
        <sup><xsl:value-of select="./@no"/>&#xA0;</sup><xsl:copy-of select="."/>&#xA0;
    </xsl:template>


    <xsl:function name="svtx:getFootnoteNumber">
        <xsl:param name="groupedFootnotes"/>
        <xsl:param name="toSearch"/>
        <xsl:for-each select="$groupedFootnotes/footnotes/footnote">
            <xsl:if test=". = $toSearch"><supfootnote><xsl:value-of  select="./@no"/></supfootnote></xsl:if>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="svtx:groupedFootnotes">
        <xsl:param name="content"/>
        <xsl:element name="footnotes" >
            <xsl:for-each-group select="$content//footnote/." group-by=".">
                <xsl:if test="name(parent::node()) != 'content'">
                    <footnote no="{position()}">
                        <xsl:copy-of  select="." />
                    </footnote>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:element>
    </xsl:function>


    <xsl:template match="@*|node()"  mode="m2" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="m2"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="@*|node()"  mode="m3" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="m3"/>
        </xsl:copy>
    </xsl:template>


    <xsl:function name="svtx:implodeSiblingFoonotes">
        <xsl:param name="content"/>
        <!-- zusammenfassen -->
        <xsl:variable name="content2"><xsl:apply-templates select="$content/*" mode="m2"/></xsl:variable>
        <!-- und dann supfootnote => sup-->
        <xsl:apply-templates select="$content2/*" mode="m3"/>
    </xsl:function>


    <xsl:template match="supfootnote" mode="m3" >
        <sup><xsl:value-of select="."/></sup>
    </xsl:template>

    <!-- Diese beiden setzen die Fussnoten-Zahlen mit Komma zusammen -->
    <xsl:template match="supfootnote" mode="m2" >
        <xsl:if test="exists(preceding-sibling::node()[1][local-name()='supfootnote']) eq false()">
            <xsl:copy>
                <xsl:apply-templates/>
                <xsl:if test="exists(following-sibling::node()[1][local-name()='supfootnote'])">
                    <xsl:apply-templates select="following-sibling::node()[1][local-name()='supfootnote']" mode="merge"/>
                </xsl:if>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="supfootnote" mode="merge">
        <xsl:text>,</xsl:text><xsl:apply-templates/>
        <xsl:apply-templates select="following-sibling::node()[1][local-name()='supfootnote']" mode="merge"/>
    </xsl:template>



</xsl:stylesheet>
