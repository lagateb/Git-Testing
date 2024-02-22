<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com" xmlns:sxl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">
    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:allianz.util.sorts/storage/master/file" />
  <!--<xsl:param name="text-ids" select="'56417,56426,56425,56413,56430,56421,56428,56415,56423,56419'"/>-->
  <xsl:param name="text-ids"  select="'28073,28079,28083'"/>
  <xsl:param name="render-new" select="'false'" as="xs:string"/>

  <xsl:param name="withMediachannels" select="'true'"/>



  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>

    <xsl:function name="svtx:fop-rendererJp">
        <xsl:param name="resource-key"/>
        <xsl:param name="xml"/>
        <xsl:param name="text-ids"/>
        <xsl:param name="document_type"/>

        <xsl:variable name="preUrl" select="'censhare:///service/assets/asset;censhare:resource-key='"/>
        <xsl:variable name="postUrl" select="'/storage/master/file'"/>
        <xsl:variable name="stylesheet" select="concat($preUrl, $resource-key, $postUrl)" as="xs:string"/>
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="dest" select="concat($out, 'temp-preview.pdf')" as="xs:string?"/>
        <xsl:variable name="result" as="element(fop)?">
            <cs:command name="com.censhare.api.transformation.FopTransformation">
                <cs:param name="stylesheet" select="$stylesheet"/>
                <cs:param name="source" select="$xml"/>
                <cs:param name="dest" select="$dest"/>
                <cs:param name="xsl-parameters">
                    <cs:param name="text-ids" select="$text-ids"/>
                    <cs:param name="document_type" select="$document_type"/>
                </cs:param>
            </cs:command>
        </xsl:variable>

        <xsl:if test="$result">
            <output href="{$dest}">
                <xsl:copy-of select="$result/@*"/>
            </output>
        </xsl:if>
    </xsl:function>


    <xsl:function name="svtx:mm2Pixel" as="xs:decimal">
        <xsl:param name="mm" as="xs:decimal"/>
        <xsl:value-of select="$mm * 2.796"/>
    </xsl:function>

    <!-- test with PDFMarks funktioniert leider nicht mit censhare, obwohl sie Ghostscript nutzen -->
    <xsl:function name="svtx:testPDFMarks">
        <xsl:param name="pagecounts" as="element(pagecount)*"/>
        <xsl:variable name="data" >
            <xsl:for-each select="tokenize($text-ids, ',')/cs:asset()">
                <xsl:sort select="svtx:sortValue(.)"/>
                <xsl:variable name="cl" select="position()"/>
                <xsl:variable name="pc" select="sum($pagecounts[position() lt $cl]/@count)"/>
                <xsl:variable name="ypos" select="svtx:mm2Pixel(200-($cl * 5.5))"/>
                <xsl:variable name="ypos2" select="$ypos+18"/>
                <!-- [ /Rect [100 $ypos 640 $ypos2]  /Border [0 0 2 [3]]  /SrcPg 1  /Color [0 1 0]  /Subtype /Link /Page $pc  /ANN pdfmark -->
                [ /Rect [100  <xsl:value-of select="$ypos"/> 500 <xsl:value-of select="$ypos2"/> ]  /SrcPg 1 /Color [0 1 0] /Subtype /Link /Page                <xsl:value-of select="$pc + 2"/>
                /ANN pdfmark
            </xsl:for-each>
        </xsl:variable>
        <xsl:message>D===
            <xsl:value-of select="$data"/>
        </xsl:message>

        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="filename" select="concat($out, 'temp-pdfmark')" as="xs:string?"/>


        <cs:command name="com.censhare.api.io.writeText">
            <cs:param name="source" select="$data" as="xs:string" />
            <cs:param name="dest" select="$filename"/>
            <cs:param name="unescape" select="false"/>
        </cs:command>

        <xsl:value-of select="$filename"/>
    </xsl:function>




    <xsl:function name="svtx:sortValue">
        <xsl:param name="currentText"/>
        <xsl:variable name="article" select="($currentText/parent_asset_rel[@key='user.main-content.']/@parent_asset)/cs:asset()"/>
        <xsl:copy-of select="svtx:getSortValueForAsset($article)"/>

    </xsl:function>


    
  <xsl:template match="/asset">
      <xsl:message>==== <xsl:copy-of select="$text-ids"/></xsl:message>
      <xsl:message>==== <xsl:copy-of select="$render-new"/></xsl:message>
      <xsl:message>====1wmc <xsl:copy-of select="$withMediachannels"/></xsl:message>

    <xsl:message>CREATE FOR TEXT IDS: <xsl:value-of select="$text-ids"/></xsl:message>

    <xsl:variable name="document_type" select="if($withMediachannels = 'true') then 'abstimmungsdokument' else 'abstimmungsdokument_short'"/>

    <!-- Dokumente zusammenfassen -->
    <xsl:variable name="sources1" as="element(source)*">
      <xsl:for-each select="tokenize($text-ids, ',')/cs:asset()">
          <xsl:sort select="svtx:sortValue(.)"/>
        <xsl:variable name="pdfStorage" select="storage_item[@key=$document_type]" as="element(storage_item)?"/>
        <xsl:choose>
          <xsl:when test="$pdfStorage and xs:boolean($render-new) = false()">
            <source href="{$pdfStorage/@url}"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="pdfResult">
              <cs:command name="com.censhare.api.transformation.AssetTransformation">
                <cs:param name="key" select="'svtx:fop.create.pdf'"/>
                <cs:param name="source" select="."/>
                <cs:param name="xsl-parameters">
                  <cs:param name="version" select="2"/>
                  <cs:param name="shortVersion" select="($withMediachannels = 'false')" as="xs:boolean" />
                </cs:param>
              </cs:command>
            </xsl:variable>
            <xsl:variable name="output" select="$pdfResult//output[1]" as="element(output)?"/>
            <xsl:if test="$output/@href">
              <source href="{$output/@href}" name="{@name}"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

      <!-- TOC einbinden -->
      <xsl:variable name="toc" select="svtx:fop-rendererJp('svtx:fop.toc.pdf',$rootAsset, $text-ids,$document_type  )" as="element(output)?"/>

      <xsl:variable name="sources" as="element(source)*">
        <xsl:if test="$toc/@href">
          <source href="{$toc/@href}" name="{@name}"/>
       </xsl:if>

        <xsl:copy-of select="$sources1"/>
      </xsl:variable>

      <xsl:variable name="pagecounts" as="element(pagecount)*">

          <xsl:for-each select="tokenize($text-ids, ',')/cs:asset()">
              <xsl:sort select="svtx:sortValue(.)"/>
              <xsl:variable name="cp" select="svtx:getPDFCountPages(.,$document_type)"/>
              <pagecount pos="{position()}" count="{$cp}">
                  <xsl:copy-of select="$cp"/>
              </pagecount>
          </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="pdfMarksFile" select="svtx:testPDFMarks($pagecounts)"/>
    <!-- für was ist das  ? -->
    <xsl:copy-of select="$sources"/>


    <xsl:choose>
      <xsl:when test="count($sources) eq 1">
        <output url="{$sources[1]/@href}"/>
      </xsl:when>
      <xsl:when test="count($sources) gt 1">
        <cs:command name="com.censhare.api.io.CreateVirtualFileSystem" returning="out"/>
        <xsl:variable name="dest" select="concat($out, 'temp-preview.pdf')"/>
        <cs:command name="com.censhare.api.pdf.CombinePDF" returning="pdfResult">
          <cs:param name="dest" select="$dest"/>
          <cs:param name="sources">
            <xsl:copy-of select="$sources"/>
          </cs:param>
        </cs:command>

          <!--- PDF Marks erzeugen -->
          <xsl:variable name="destWithMarks" select="concat($out, 'temp-preview2.pdf')"/>

          <xsl:variable name="pdfmardocument">
              <cs:command name="modules.com.savotex.utils.PDFMark.addMetadata">
                  <cs:param name="srcPDF" select="$pdfResult/@href"/>
                  <cs:param name="outPDF" select="$destWithMarks"/>
                  <cs:param name="pdfMarksFile" select="$pdfMarksFile"/>
              </cs:command>
          </xsl:variable>

        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="checkedInNew">
          <cs:param name="source">
            <asset name="{$destWithMarks}" type="module.">
              <asset_element idx="0" key="actual."/>
              <storage_item key="master" corpus:asset-temp-file-url="{$destWithMarks}" element_idx="0" mimetype="application/pdf"/>
            </asset>
          </cs:param>
        </cs:command>
        <xsl:variable name="masterStorage" select="$checkedInNew/storage_item[@key='master']" as="element(storage_item)?"/>
        <output url="{$masterStorage/@url}" id="{$checkedInNew/@id}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
