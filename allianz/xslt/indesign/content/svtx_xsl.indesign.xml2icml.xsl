<?xml version="1.0" encoding="UTF-8"?>

<!--

    !!! DAS IST EINE ERWEITERTE KOPIE DES CS XML2ICML FRAMEWORKS !!!

-->

<!--
#########################################################
censhare standard ICML framework

Version 1.3.0 - May 2016
#########################################################
-->

<!-- changes:
mhe 2016-05-23
  - major refactoring of flattening functionality
  - improved handling of breaks (page, column etc.)
  - improved handling of character style ranges, local styles for nested ranges can be merged
mhe 2016-03-30
  - OPT set character style [none] for empty table cells
mhe 2016-02-17
  - FIX index entries including “:” need to be masked
mhe 2015-11-25
  - added possibility to add custom properties and attributes to textframes
mhe 2015-10-07
  - improved generation of tables and other inline elements > character style range is created
mhe 2014-10-20
  - added possibility to add custom properties and attributes to paragraph style ranges, character style ranges, tables and table cells
  - improved handling for anchored Illustrator graphics
  - fixed @Self attribute for stylenames including "%"
mhe 2014-08-20
  - fixed color handling for Swatch/None
mhe 2014-06-02
  - added possibility for user defined color values (FillColor, StrokeColor, GapColor)
mhe 2014-05-22
  - improved handling of object styles for different types of objects
mhe 2014-02-25
  - fixed unnecessary paragraph break at end of stories
mhe 2014-01-22
  - improved output details to validate against ICML schema
  - Hyperlinks are much more stable: Using reference to Object instead of DestinationUniqueKey
  - Content-in-Content placements in text assets create an XML tag by default (censhare:xi-marker with @href attribute from xi:include)
mhe 2014-01-07
  - improved handling of XMLElements within flattening
  - new templates: icml-xmlelement and icml-xmlattribute
mhe 2013-12-04
  - improved creation of <Br/> Elements within flattening:
  - avoids empty paragraphs at end of story
  - editable with censhare InCopy editor
mhe 2013-08-16:
  - refactoring of image captions per $category: moved to structure.xsl
  - improvements in icml-table
  - fixed an issue with crossreferences to same target
  - smaller bugfixes and improvements
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://ns.censhare.de/assets"
                xmlns:map="http://ns.censhare.de/mapping"
                xmlns:temp="http://ns.censhare.de/elements"
                xmlns:func="http://ns.censhare.de/functions"
                exclude-result-prefixes="xs xd fn cs censhare xi xlink map temp func"
                version="2.0">


    <!-- ########################################## -->
    <!-- ########################################## -->

    <!-- Basic funcionality for ICML creation from xml assets  -->

    <!-- this XSLT doesn’t work standalone -->
    <!-- include into individual xslt (xsl:include) -->

    <!-- don’t change anything if you’re not 100% sure ... -->

    <!-- ########################################## -->
    <!-- ########################################## -->


    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>This XSLT is used as a framework to create ICML from XML Content or asset data, which can be placed into InDesign Layouts. The required ICML structure is build automatically.</xd:p>
            <xd:p><xd:b>Usually this XSLT will be includes as it is, without any modifications</xd:b></xd:p>
            <xd:p>The XSLT doesn’t work standalone. It will be included in another XSLT (xsl:include) where some required configuration should be placed</xd:p>
            <xd:p>Running on a censhare server with version &gt; 4.3 it starts with the asset xml, in default configuration reads the master storage and performs the matching templates</xd:p>
            <xd:p><xd:i>XInclude</xd:i> elements (content-in-content placements) are resolved automatically, considering alternativ content (<xd:i>cs:override</xd:i>)</xd:p>
            <xd:p>Running on a censhare server with version &lt; 4.3, or during local testing, it starts just with the given xml and performs the matching templates</xd:p>
            <xd:p>The following variables or parameters are required:</xd:p>
            <xd:p>In <xd:ref name="PSMapping" type="variable"/> and <xd:ref name="CSMapping" type="variable"/> mappings of elements to InDesign paragraph or character styles can be defined. For that to work, matching xslt-templates with a call to appropriate named templates have to be defined.</xd:p>
            <xd:p><xd:b>Handling a block element with a paragraph style:</xd:b></xd:p>
            <xd:ul>
                <xd:li>1. Insert the desired mapping entry into <xd:ref name="PSMapping" type="variable"/></xd:li>
                <xd:li>2. Define a template matching the element, with a call to <xd:ref name="icml-paragraph" type="template"/></xd:li>
            </xd:ul>
            <xd:p><xd:b>Handling a inline element with a character style:</xd:b></xd:p>
            <xd:ul>
                <xd:li>1. Insert the desired mapping entry into <xd:ref name="CSMapping" type="variable"/></xd:li>
                <xd:li>2. Define a template matching the element, with a call to <xd:ref name="icml-inline" type="template"/></xd:li>
            </xd:ul>
            <xd:p><xd:b>changing order of elements etc.:</xd:b></xd:p>
            <xd:ul>
                <xd:li>create a template for containing element (e.g. root-element of content) and define calls of &lt;xsl:apply-templates select="xy"/&gt; in desired order</xd:li>
            </xd:ul>
            <xd:p>Several other text and layout elements (like tables, anchored frames, crossreferences etc.) can also be created easily with calls of named templates, names starting with <xd:b>"icml-"</xd:b> </xd:p>
        </xd:desc>
    </xd:doc>


    <xsl:param name="transform"/>
    <!-- parameters for category, group and index from group metadata -->
    <xsl:param name="category" select="'default'"/>
    <xsl:param name="index" select="1"/>
    <xsl:param name="group-name"/>

    <xsl:variable name="index-self" select="'u_index1'"/>
    <xsl:variable name="xref-format-self" select="'u_xref'"/>

    <!-- Bug in 4.7.x ?? -->
    <!--  <xsl:param name="story-title" select="(/asset/@name, 'Story')[1]" />-->
    <xsl:param name="story-title" as="xs:string">Story</xsl:param>

    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- Main Template, creates ICML document  -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template match="/" priority="10.0">
        <xsl:call-template name="icml-document"/>
    </xsl:template>



    <xsl:template name="icml-document">
        <xsl:param name="main-content">
            <xsl:apply-templates select="./*" />
        </xsl:param>

        <xsl:processing-instruction name="aid"><xsl:text>style="50" type="snippet" readerVersion="6.0" featureSet="257" product="7.0(535)"</xsl:text></xsl:processing-instruction>
        <xsl:processing-instruction name="aid"><xsl:text>SnippetType="InCopyInterchange"</xsl:text></xsl:processing-instruction>

        <Document>
            <xsl:attribute name="DOMVersion">7.0</xsl:attribute>
            <xsl:attribute name="Self">d</xsl:attribute>

            <xsl:variable name="main-story">
                <temp:story Self="{generate-id(./*)}" title="{$story-title}">
                    <XMLElement MarkupTag="Story" XMLContent="{generate-id(./*)}">
                        <xsl:copy-of select="$main-content"/>
                    </XMLElement>
                </temp:story>
            </xsl:variable>

            <xsl:variable name="stories">
                <temp:stories>
                    <xsl:copy-of select="$main-story" />
                    <xsl:apply-templates select="$main-story//temp:frame-content" mode="textframe-stories" />
                </temp:stories>
            </xsl:variable>

            <xsl:apply-templates select="$stories/*" mode="colors" />

            <!-- styles -->
            <xsl:apply-templates select="$stories/*" mode="styles" />

            <xsl:call-template name="TextVariable" />

            <!-- xml tags -->
            <xsl:apply-templates select="$stories/*" mode="xmltags" />

            <xsl:call-template name="CrossRefFormats" />

            <!-- Index (from stories’ PageReferences) -->
            <xsl:apply-templates select="$stories/*" mode="index" />

            <!-- output all stories: flatten nested styles -->
            <xsl:apply-templates select="$stories/*" mode="flatten" />

            <xsl:apply-templates select="$stories/*" mode="hyperlinks" />
        </Document>
    </xsl:template>



    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- Precalculation of Main Story (StyleRanges still nested)  -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->


    <!-- preloading storage -->
    <xsl:variable name="storage">
        <xsl:choose>
            <!-- kytence -->
            <xsl:when test="exists($content/content)">
                <xsl:copy-of select="$content/content/node()" />
            </xsl:when>
            <xsl:when test="/asset/storage_item[@key='master'][@mimetype='text/xml']">
                <xsl:copy-of select="doc(concat('censhare:///service/assets/asset/id/', /asset/@id, '/version/', /asset/@version, '/storage/master/file'))"/>
            </xsl:when>
            <!-- local testing -->
            <xsl:otherwise>
                <xsl:copy-of select="/" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>



    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- layout and issue (for crossreferences) -->

    <xsl:variable name="layout">
        <xsl:choose>
            <xsl:when test="$transform/@target-asset-id">
                <xsl:copy-of select="cs:get-asset($transform/@target-asset-id)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="cs:get-asset( (/asset/cs:parent-rel()[@key='actual.']/cs:asset()[@censhare:asset.type='layout.'])[1]/@id)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="issue" select="($layout/asset/cs:parent-rel()[@key='target.']/cs:asset()[@censhare:asset.type='issue.'])[1]"/>

    <xsl:variable name="referencetargets-layout">
        <xsl:if test="($transform-key-referencetargets != '') and $layout/asset/@id">
            <xsl:copy-of select="doc(concat('censhare:///service/assets/asset/id/', $layout/asset/@id, '/version/', $layout/asset/@version, '/transform;key=', $transform-key-referencetargets))"/>
        </xsl:if>
    </xsl:variable>

    <xsl:variable name="referencetargets-issue">
        <xsl:if test="($transform-key-referencetargets != '') and $issue/@id">
            <xsl:copy-of select="doc(concat('censhare:///service/assets/asset/id/', $issue/@id, '/version/', $issue/@version, '/transform;key=', $transform-key-referencetargets))"/>
        </xsl:if>
    </xsl:variable>



    <!-- preprocess asset’s master storage: replacing xincludes -->
    <xsl:template match="/asset" priority="1.0">
        <!-- parse xincludes -->
        <xsl:variable name="preprocessed">
            <xsl:for-each select="$storage/*">
                <xsl:apply-templates select="." mode="preprocess"/>
            </xsl:for-each>
        </xsl:variable>
        <!-- handle content -->
        <xsl:for-each select="$preprocessed/*">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>

    <!-- preprocessing xincludes -->
    <xsl:template match="xi:include" mode="preprocess" priority="1.0">
        <censhare:xi-marker href="{@href}"/>
        <xsl:apply-templates select="doc(@href)" mode="#current"/>
    </xsl:template>

    <!-- XIncludes generate an asset marker as InDesign tag -->
    <xsl:template match="censhare:xi-marker" priority="0.5">
        <xsl:call-template name="icml-xmlelement">
            <xsl:with-param name="element-name">censhare:xi-asset-ref</xsl:with-param>
            <xsl:with-param name="attributes">
                <xsl:call-template name="icml-xmlattribute">
                    <xsl:with-param name="attr-name" >href</xsl:with-param>
                    <xsl:with-param name="attr-value" select="@href"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="xi:include[cs:override]" mode="preprocess" priority="2.0">
        <xsl:element name="{@element-name}">
            <xsl:apply-templates select="cs:override" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="cs:override" mode="preprocess" priority="1.0">
        <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:template>

    <!-- preprocessing other nodes -->
    <xsl:template match="@*|node()" mode="preprocess" priority="0.5">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>



    <xsl:variable name="PSMappingFiltered">
        <xsl:call-template name="filter-mapping">
            <xsl:with-param name="map" select="$PSMapping"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="CSMappingFiltered">
        <xsl:call-template name="filter-mapping">
            <xsl:with-param name="map" select="$CSMapping"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:template name="filter-mapping">
        <xsl:param name="map"/>
        <xsl:for-each select="$map/*">
            <xsl:choose>
                <xsl:when test="fn:name(.) = 'map:entry'">
                    <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:when test="(fn:name(.) = 'map:group') and (@root-element = fn:name($storage/*))">
                    <xsl:copy-of select="./map:entry"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- Flattening of nested styles  -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:template match="temp:stories" mode="flatten" priority="0.0">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="temp:story" mode="flatten" priority="0.0">
        <Story>
            <xsl:attribute name="Self" select="./@Self"/>
            <xsl:attribute name="StoryTitle" select="./@title"/>

            <StoryPreference FrameType="TextFrameType" StoryOrientation="Horizontal" StoryDirection="LeftToRightDirection"/>
            <xsl:apply-templates mode="#current"/>

        </Story>
    </xsl:template>

    <!-- Elemente: inkl. Attribute kopieren, Templates anwenden -->
    <xsl:template match="*" mode="flatten" priority="-0.5" name="deep-copy-flatten">
        <xsl:param name="csgroup"/>
        <xsl:param name="csname"/>
        <xsl:param name="csr-attributes" as="attribute()*" />
        <xsl:param name="csr-properties" as="element()*" />
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="csgroup" select="$csgroup"/>
                <xsl:with-param name="csname" select="$csname"/>
                <xsl:with-param name="csr-attributes" select="$csr-attributes"/>
                <xsl:with-param name="csr-properties" select="$csr-properties"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*" mode="flatten" priority="0.5">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="@temp:*" mode="flatten" priority="1.0"/>

    <xsl:template match="@stylegroup | @stylename | @stylename-postfix | CrossReferenceSource/@key | HyperlinkTextSource/@url | Table/@table-width" mode="flatten" priority="1.0"/>

    <xsl:template match="temp:Properties" mode="flatten" priority="1.0" />

    <xsl:template match="PageReference/@topic1 | PageReference/@topic2 | PageReference/@topic3 | PageReference/@topic4" mode="flatten" priority="1.0"/>


    <xsl:template match="Footnote" mode="flatten" priority="0.5">
        <xsl:param name="csgroup" />
        <xsl:param name="csname" />
        <xsl:param name="csr-attributes" as="attribute()*" />
        <xsl:param name="csr-properties" as="element()*" />
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates mode="#current" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="temp:separator" mode="flatten" priority="1.0"/>


    <xsl:template match="TextFrame | Rectangle | Polygon | Oval | Graphic | Image | EPS | WMF | PICT | PDF | GraphicLine | Group" mode="flatten" priority="0.5">
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="AppliedObjectStyle" select="func:icml-style-self('object', @stylegroup, @stylename)" />
            <xsl:attribute name="Self" select="concat('Obj', generate-id(.))"/>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates mode="#current" />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="Table" mode="flatten">
        <xsl:variable name="col-count" select="(max(Row/Cell/func:tablecell-colindex(.)) +1, 0)[1]" as="xs:integer?"/>
        <xsl:variable name="row-count" select="(max(Row/Cell/func:tablecell-rowindex(.)) +1, 0)[1]" as="xs:integer?"/>
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="AppliedTableStyle" select="func:icml-style-self('table', @stylegroup, @stylename)"/>
            <xsl:attribute name="BodyRowCount" select="$row-count - xs:integer(@HeaderRowCount) - xs:integer(@FooterRowCount)"/>
            <xsl:attribute name="ColumnCount" select="$col-count"/>

            <xsl:apply-templates select="attribute::*" mode="#current"/>

            <xsl:if test="temp:Properties/*">
                <Properties>
                    <xsl:copy-of select="temp:Properties/*" copy-namespaces="no"/>
                </Properties>
            </xsl:if>

            <xsl:call-template name="table-columns">
                <xsl:with-param name="col-count" select="$col-count"/>
            </xsl:call-template>
            <xsl:call-template name="table-rows">
                <xsl:with-param name="row-count" select="$row-count"/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="Table/Column" mode="flatten"/>

    <xsl:template match="Table/Row" mode="flatten">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template name="table-columns">
        <xsl:param name="col-count" as="xs:integer"/>
        <xsl:variable name="Self" select="@Self"/>
        <xsl:variable name="default-width" select="if ($col-count gt count(Column/@SingleColumnWidth[number(.) gt 0])) then (@table-width - sum(Column/number(@SingleColumnWidth)[. gt 0])) div ($col-count - count(Column/@SingleColumnWidth[number(.) gt 0])) else (@table-width div $col-count)"/>
        <xsl:variable name="col-widths" select="for $c in (0 to $col-count -1) return max(((Column[@Name = $c]/number(@SingleColumnWidth)[. gt 0], $default-width)[1], 3))" />

        <xsl:for-each select="0 to ($col-count -1)">
            <Column Self="{$Self}Column{.}" Name="{.}" SingleColumnWidth="{$col-widths[current() +1]}"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="table-rows">
        <xsl:param name="row-count" as="xs:integer"/>
        <xsl:variable name="Self" select="@Self"/>
        <xsl:for-each select="Row">
            <xsl:copy copy-namespaces="no">
                <xsl:attribute name="Self" select="concat(parent::Table/@Self, 'Row', position() -1)"/>
                <xsl:attribute name="Name" select="(position() -1)"/>
                <xsl:choose>
                    <xsl:when test="@fixed-height">
                        <xsl:attribute name="MinimumHeight" select="3"/>
                        <xsl:attribute name="SingleRowHeight" select="@fixed-height"/>
                        <xsl:attribute name="AutoGrow">false</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="MinimumHeight" select="@min-height"/>
                        <xsl:attribute name="AutoGrow">true</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="Cell" mode="flatten">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:if test="not(@Self)">
                <xsl:attribute name="Self" select="generate-id(.)"/>
            </xsl:if>
            <xsl:attribute name="AppliedCellStyle" select="func:icml-style-self('cell', @stylegroup, @stylename)"/>
            <xsl:attribute name="Name" select="concat (func:tablecell-colindex(.), ':', func:tablecell-rowindex(.))"/>

            <xsl:if test="temp:Properties/*">
                <Properties>
                    <xsl:copy-of select="temp:Properties/*" copy-namespaces="no"/>
                </Properties>
            </xsl:if>

            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>



    <xsl:function name="func:tablecell-rowindex" as="xs:integer">
        <xsl:param name="cell" as="element(Cell)"/>
        <xsl:value-of select="$cell/(count(parent::Row/preceding-sibling::Row))"/>
    </xsl:function>

    <xsl:function name="func:tablecell-colindex" as="xs:integer">
        <xsl:param name="cell" as="element(Cell)"/>
        <xsl:variable name="rowindex" select="func:tablecell-rowindex($cell)"/>

        <xsl:variable name="colindex-pre" select="xs:integer($cell/sum(preceding-sibling::Cell/xs:integer(@ColumnSpan)))" as="xs:integer"/>

        <xsl:value-of select="$colindex-pre + xs:integer($cell/sum(parent::Row/preceding-sibling::Row/Cell[xs:integer(@RowSpan) gt ($rowindex - func:tablecell-rowindex(.))][func:tablecell-colindex(.) le $colindex-pre]/xs:integer(@ColumnSpan)))" />
    </xsl:function>



    <xsl:template match="CrossReferenceSource" mode="flatten" priority="0.5">
        <xsl:choose>
            <!-- target in same xml source -->
            <xsl:when test="ancestor::temp:stories//HyperlinkTextDestination[@DestinationUniqueKey = func:make-destination-key(current()/@key)]">
                <xsl:call-template name="deep-copy-flatten"/>
            </xsl:when>
            <!-- target in same layout -->
            <xsl:when test="$referencetargets-layout/targets/item[@key = func:make-destination-key(current()/@key)]/@page-number">
                <xsl:call-template name="deep-copy-flatten"/>
            </xsl:when>
            <!-- target in issue -->
            <xsl:when test="$referencetargets-issue/targets/item[@key = func:make-destination-key(current()/@key)]/@page-number">
                <xsl:apply-templates mode="#current">
                    <xsl:with-param name="ext-reference" select="$referencetargets-issue/targets/item[@key = func:make-destination-key(current()/@key)][1]/@page-number"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="deep-copy-flatten"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="TextVariableInstance" mode="flatten" priority="0.5">
        <xsl:param name="csgroup" />
        <xsl:param name="csname" />
        <xsl:param name="csr-attributes" as="attribute()*"/>
        <xsl:param name="csr-properties" as="element()*" />
        <xsl:param name="ext-reference"/>

        <xsl:choose>
            <xsl:when test="$ext-reference">
                <CharacterStyleRange>
                    <xsl:attribute name="AppliedCharacterStyle" select="func:icml-style-name('character', $csgroup, $csname)"/>
                    <Content>
                        <xsl:value-of select="if ($ext-reference) then $ext-reference else '?'"/>
                    </Content>
                </CharacterStyleRange>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="deep-copy-flatten"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Text und PIs kopieren -->
    <xsl:template match="text() | processing-instruction()" mode="flatten" priority="-0.5">
        <xsl:copy/>
    </xsl:template>


    <xsl:template match="temp:PSR" mode="flatten" priority="0.0">
        <xsl:variable name="psr" select="."/>
        <xsl:for-each-group select="node() except temp:Properties" group-adjacent="boolean(self::temp:PSR)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:apply-templates select="current-group()" mode="#current"/>
                </xsl:when>
                <xsl:otherwise>
                    <ParagraphStyleRange>
                        <xsl:attribute name="AppliedParagraphStyle" select="func:icml-style-self('paragraph', $psr/@stylegroup, $psr/@stylename, $psr/@stylename-postfix)"/>
                        <xsl:apply-templates select="$psr/@*" mode="#current"/>

                        <xsl:if test="$psr/temp:Properties/*">
                            <Properties>
                                <xsl:copy-of select="$psr/temp:Properties/*" copy-namespaces="no"/>
                            </Properties>
                        </xsl:if>

                        <xsl:variable name="content">
                            <!-- if part of a footnote: insert number marker -->
                            <xsl:if test="$psr[not(preceding-sibling::temp:PSR)]/parent::Footnote/temp:separator">
                                <CharacterStyleRange AppliedCharacterStyle="CharacterStyle/$ID/[No character style]">
                                    <Content><xsl:processing-instruction name="ACE">4</xsl:processing-instruction><xsl:copy-of select="$psr/parent::Footnote/temp:separator/text()"/></Content>
                                </CharacterStyleRange>
                            </xsl:if>

                            <xsl:call-template name="flatten-group-content">
                                <xsl:with-param name="nodes" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:variable>

                        <xsl:copy-of select="$content"/>
                        <xsl:if test="not($content/node())">
                            <CharacterStyleRange AppliedCharacterStyle="CharacterStyle/$ID/[No character style]" />
                        </xsl:if>

                    </ParagraphStyleRange>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <!-- omit last <Br/> in story, cell or foonote -->
    <xsl:template match="Br" mode="flatten" priority="1.0">
        <xsl:if test="not(
      (. is (ancestor::temp:story//temp:PSR)[last()]/Br[last()])
      or (. is (ancestor::Cell//temp:PSR)[last()]/Br[last()])
      or (. is (ancestor::Footnote//temp:PSR)[last()]/Br[last()])
      )">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>



    <xsl:template match="temp:CSR" mode="flatten" priority="0.0">
        <xsl:param name="csgroup"/>
        <xsl:param name="csname"/>
        <xsl:param name="csr-attributes" as="attribute()*"/>
        <xsl:param name="csr-properties" as="element()*"/>
        <xsl:param name="ext-reference"/>

        <xsl:variable name="set-attributes" select="@* except (@stylegroup | @stylename)"/>
        <xsl:variable name="set-properties" select="temp:Properties/*"/>

        <xsl:call-template name="flatten-group-content">
            <xsl:with-param name="csgroup" select="if (@stylename) then (@stylegroup) else $csgroup" />
            <xsl:with-param name="csname" select="if (@stylename) then (@stylename) else $csname" />
            <!-- ToDo: reset attributes and properties if a character style is used – or make that optional? -->
            <xsl:with-param name="csr-attributes" select="$csr-attributes[not(local-name(.) = $set-attributes/local-name(.) )], $set-attributes" />
            <xsl:with-param name="csr-properties" select="$csr-properties[not(local-name(.) = $set-properties/local-name(.) )], $set-properties"/>
            <xsl:with-param name="ext-reference" select="$ext-reference" />
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="temp:PSR//XMLElement" mode="flatten" priority="0.0">
        <xsl:param name="csgroup"/>
        <xsl:param name="csname"/>
        <xsl:param name="csr-attributes" as="attribute()*"/>
        <xsl:param name="csr-properties" as="element()*" />
        <xsl:param name="ext-reference"/>

        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:call-template name="flatten-group-content">
                <xsl:with-param name="csgroup" select="if (@stylename) then (@stylegroup) else $csgroup" />
                <xsl:with-param name="csname" select="if (@stylename) then (@stylename) else $csname" />
                <xsl:with-param name="ext-reference" select="$ext-reference" />
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="XMLElement/@MarkupTag" mode="flatten" priority="1.0">
        <xsl:attribute name="MarkupTag" select="concat('XMLTag/', encode-for-uri(.))"/>
        <xsl:if test="not(parent::XMLElement/@Self)">
            <xsl:attribute name="Self" select="generate-id(parent::XMLElement)"/>
        </xsl:if>
    </xsl:template>


    <xsl:template name="flatten-group-content">
        <xsl:param name="csgroup" />
        <xsl:param name="csname" />
        <xsl:param name="csr-attributes" as="attribute()*" />
        <xsl:param name="csr-properties" as="element()*" />
        <xsl:param name="ext-reference"/>

        <xsl:param name="nodes" select="node()"/>

        <xsl:for-each-group select="$nodes" group-adjacent="
      if ((name() = '') or (. instance of processing-instruction())
        or (self::Br | self::Table | self::TextFrame | self::Rectangle | self::Polygon | self::Oval | self::Graphic | self::GraphicLine | self::Group | self::Footnote | self::Note)
        or (self::HyperlinkTextDestination | self::CrossReferenceSource | HyperlinkTextSource)) then 'content'
      else ''">
            <xsl:choose>
                <!-- known inline element > create a character style range with inherited parameters -->
                <xsl:when test="current-grouping-key() = 'content'">
                    <CharacterStyleRange>
                        <xsl:attribute name="AppliedCharacterStyle" select="func:icml-style-self('character', $csgroup, $csname)"/>
                        <xsl:apply-templates select="$csr-attributes" mode="flatten" />
                        <xsl:if test="$csr-properties">
                            <Properties>
                                <xsl:copy-of select="$csr-properties"/>
                            </Properties>
                        </xsl:if>
                        <xsl:for-each-group select="current-group()" group-adjacent="(name() = '') or (. instance of processing-instruction())">
                            <xsl:choose>
                                <!-- text content > create Content element -->
                                <xsl:when test="current-grouping-key()">
                                    <Content>
                                        <xsl:apply-templates select="current-group()" mode="#current" />
                                    </Content>
                                </xsl:when>
                                <!-- element content > process elements -->
                                <xsl:otherwise>
                                    <xsl:apply-templates select="current-group()" mode="#current">
                                        <xsl:with-param name="ext-reference" select="$ext-reference" />
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group>
                    </CharacterStyleRange>
                </xsl:when>
                <!-- OPT: group similar temp:csr? -->
                <!-- other element, e.g. nested temp:CSR, XMLElement temporary container element -->
                <xsl:otherwise>
                    <xsl:apply-templates select="current-group()" mode="#current">
                        <xsl:with-param name="csgroup" select="$csgroup" />
                        <xsl:with-param name="csname" select="$csname" />
                        <xsl:with-param name="csr-attributes" select="$csr-attributes" />
                        <xsl:with-param name="csr-properties" select="$csr-properties" />
                        <xsl:with-param name="ext-reference" select="$ext-reference" />
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template match="temp:frame-content" mode="flatten"/>

    <xsl:template match="temp:frame-content" mode="textframe-stories" priority="0.5">
        <temp:story>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*"/>
        </temp:story>
    </xsl:template>

    <xsl:template match="node()" mode="textframe-stories" priority="-0.5">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>


    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- Ende Flattening        -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->




    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- general templates for different types of elements   -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->


    <!-- ICML Paragraph -->
    <xd:doc>
        <xd:desc>
            <xd:p>Creates an InDesign Paragraph</xd:p>
            <xd:p>Looks for a matching entry in $PSMapping and applies the appropriate paragraph style if present</xd:p>
        </xd:desc>
        <xd:param name="insert-at-begin">ICML-Content to be inserted at the beginning of the paragraph. Usually text or inline styles</xd:param>
        <xd:param name="insert-at-end">ICML-Content to be inserted at the end of the paragraph. Usually text or inline styles</xd:param>
        <xd:param name="force-style-group">Name of a group of the paragraph style which will be applied. Only used if $force-style-name ist present.</xd:param>
        <xd:param name="force-style-name">Name of a paragraph style which will be applied instead of the normal style mapping</xd:param>
        <xd:param name="use-mapping">Determines whether the style mapping in <xd:ref name="PSMapping" type="variable"/> will be used for the applied paragraph style. – <xd:i>default: </xd:i>depends on global setting by variable <xd:ref name="default-use-mapping" type="variable"/>
        </xd:param>
        <xd:param name="use-autostyle">Determines whether the paragraph style and style-group structure should be build automatically from the element’s xml path. If param $use-mapping is true(), the auto-style will only be used if no matching mapping is found <xd:i>default: </xd:i>depends on global setting by variable <xd:ref name="default-use-autostyle" type="variable"/>
        </xd:param>
        <xd:param name="use-cs-mapping">Determines whether <xd:ref name="CSMapping" type="variable"/> (for character style) will be used in addition to paragraph style. – <xd:i>true(): </xd:i>use <xd:ref name="CSMapping" type="variable"/>, <xd:i>false(): </xd:i>don’t use <xd:ref name="CSMapping" type="variable"/>, <xd:i>empty: </xd:i>@add-charstyle of <xd:ref name="PSMapping" type="variable"/> will decide
        </xd:param>
        <xd:param name="name-postfix">Adds a postfix to the name of the paragraph style (only for auto-styles)</xd:param>
        <xd:param name="add-attributes">directly add arbitrary ICML properties represented as attributes of the result</xd:param>
        <xd:param name="add-properties">directly add arbitrary ICML properties represented as children of the Properties element of the result</xd:param>
        <xd:param name="content">Declare some specific ICML content. only needed in special cases</xd:param>
        <xd:param name="break-type">type of end break of this paragraph, defines beginning of the next paragraph. See <xd:ref name="icml-break" type="template"/>.</xd:param>
    </xd:doc>
    <xsl:template name="icml-paragraph">
        <xsl:param name="insert-at-begin" select="()" />
        <xsl:param name="insert-at-end" select="()" />
        <xsl:param name="force-style-group" as="xs:string?"></xsl:param>
        <xsl:param name="force-style-name" as="xs:string?"/>
        <xsl:param name="use-mapping" select="$default-use-mapping"/>
        <xsl:param name="use-autostyle" select="$default-use-autostyle"/>
        <xsl:param name="use-cs-mapping" as="xs:boolean?" select="()"/>
        <xsl:param name="name-postfix"/>
        <xsl:param name="add-attributes" as="attribute()*"/>
        <xsl:param name="add-properties" as="element()*"/>
        <xsl:param name="content" select="()"/>
        <xsl:param name="break-type" as="xs:string?" select="()"/>

        <xsl:variable name="mapping" select="if ($use-mapping) then func:get-mapping-entry($PSMappingFiltered, .) else ()"/>

        <temp:PSR>
            <xsl:choose>
                <!-- forced style -->
                <xsl:when test="$force-style-name">
                    <xsl:attribute name="stylegroup" select="$force-style-group"/>
                    <xsl:attribute name="stylename" select="$force-style-name"/>
                    <xsl:if test="$force-style-name != ''">
                        <xsl:attribute name="stylename-postfix" select="$name-postfix"/>
                    </xsl:if>
                </xsl:when>
                <!-- style from mapping table -->
                <xsl:when test="$use-mapping and $mapping/@stylename">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                    <xsl:if test="$mapping/@stylename != ''">
                        <xsl:attribute name="stylename-postfix" select="$name-postfix"/>
                    </xsl:if>
                </xsl:when>
                <!-- autostyle: stylegroup/name from element path -->
                <xsl:when test="$use-autostyle">
                    <xsl:attribute name="stylegroup" select="func:stylegroup-from-path(.)"/>
                    <xsl:attribute name="stylename" select="local-name(.)"/>
                    <xsl:attribute name="stylename-postfix" select="$name-postfix"/>
                </xsl:when>
                <!-- no style -->
                <xsl:otherwise>
                    <xsl:attribute name="stylegroup" select="''"/>
                    <xsl:attribute name="stylename" select="''"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:copy-of select="$add-attributes"/>
            <temp:Properties>
                <xsl:copy-of select="$add-properties"/>
            </temp:Properties>
            <xsl:copy-of select="$insert-at-begin"/>

            <!-- xml tag for toc entry -->
            <xsl:if test="$mapping/toc">
                <xsl:variable name="text-value">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:variable>
                <xsl:for-each select="$mapping/toc">
                    <XMLElement MarkupTag="XMLTag/toc">
                        <XMLAttribute Name="text" Value="{(@text, $text-value)[1]}"/>
                        <XMLAttribute Name="key" Value="{@key}"/>
                    </XMLElement>
                </xsl:for-each>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="$content">
                    <xsl:copy-of select="$content"/>
                </xsl:when>
                <xsl:when test="empty($use-cs-mapping) and $mapping/@add-charstyle">
                    <xsl:call-template name="icml-inline"/>
                </xsl:when>
                <xsl:when test="$use-cs-mapping">
                    <xsl:call-template name="icml-inline"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="$insert-at-end"/>
            <xsl:call-template name="icml-break">
                <xsl:with-param name="type" select="$break-type"/>
            </xsl:call-template>
        </temp:PSR>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>adds an InDesign break character</xd:p>
        </xd:desc>
        <xd:param name="type">type of break. Possible values are: <xd:i>NextColumn</xd:i>, <xd:i>NextFrame</xd:i>, <xd:i>NextPage</xd:i>, <xd:i>NextOddP</xd:i>, <xd:i>NextEvenPage</xd:i></xd:param>
    </xd:doc>
    <xsl:template name="icml-break">
        <xsl:param name="type" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$type = ('NextColumn', 'NextFrame', 'NextPage', 'NextOddP', 'NextEvenPage')">
                <temp:CSR ParagraphBreakType="{$type}">
                    <Br/>
                </temp:CSR>
            </xsl:when>
            <xsl:otherwise>
                <Br/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Creates an InDesign inline style</xd:p>
            <xd:p>Looks for a matching entry in $CSMapping and applies the appropriate character style if present</xd:p>
        </xd:desc>
        <xd:param name="insert-at-begin">ICML-Content to be inserted at the beginning (styled in the same way). Usually text or other inline styles</xd:param>
        <xd:param name="insert-at-end">ICML-Content to be inserted at the end (styled in the same way). Usually text or other inline styles</xd:param>
        <xd:param name="force-style-name">Name of a character style which will be applied instead of the normal style mapping (<xd:ref name="CSMapping" type="template"/>)</xd:param>
        <xd:param name="force-style-group">Name of a group of the character style which will be applied. Only used if force-style-name ist present.</xd:param>
        <xd:param name="use-mapping">Determines whether the style mapping in <xd:ref name="CSMapping" type="template"/> will be used for the applied character style. – <xd:i>default: </xd:i>depends on global setting by variable <xd:ref name="default-use-mapping" type="variable"/>
        </xd:param>
        <xd:param name="use-autostyle">Determines whether the character style and style-group structure should be build automatically from the element’s xml path. If param $use-mapping is true(), the auto-style will only be used if no matching mapping is found <xd:i>default: </xd:i>depends on global setting by variable <xd:ref name="default-use-autostyle" type="variable"/>
        </xd:param>
        <xd:param name="name-postfix">Adds a postfix to the name of the character style (only for auto-styles)</xd:param>
        <xd:param name="add-attributes">directly add arbitrary ICML properties represented as attributes of the result</xd:param>
        <xd:param name="add-properties">directly add arbitrary ICML properties represented as children of the Properties element of the result</xd:param>
        <xd:param name="content">Declare some specific ICML content. only needed in special cases</xd:param>
    </xd:doc>
    <xsl:template name="icml-inline">
        <xsl:param name="insert-at-begin" select="()" />
        <xsl:param name="insert-at-end" select="()" />
        <xsl:param name="force-stylegroup" as="xs:string?"></xsl:param>
        <xsl:param name="force-stylename" as="xs:string?"/>
        <xsl:param name="use-mapping" select="$default-use-mapping"/>
        <xsl:param name="use-autostyle" select="$default-use-autostyle"/>
        <xsl:param name="name-postfix"/>
        <xsl:param name="add-attributes" as="attribute()*"/>
        <xsl:param name="add-properties" as="element()*"/>
        <xsl:param name="content" as="node()*">
            <xsl:apply-templates/>
        </xsl:param>

        <xsl:variable name="mapping" select="if ($use-mapping) then func:get-mapping-entry($CSMappingFiltered, .) else ()"/>

        <temp:CSR>
            <xsl:choose>
                <!-- forced style -->
                <xsl:when test="$force-stylename">
                    <xsl:attribute name="stylegroup" select="$force-stylegroup"/>
                    <xsl:attribute name="stylename" select="$force-stylename"/>
                </xsl:when>
                <!-- style from mapping table -->
                <xsl:when test="$use-mapping and $mapping/@stylename">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                </xsl:when>
                <!-- autostyle: stylegroup/name from element path -->
                <xsl:when test="$use-autostyle">
                    <xsl:attribute name="stylegroup" select="func:stylegroup-from-path(.)"/>
                    <xsl:attribute name="stylename" select="local-name(.)"/>
                    <xsl:attribute name="stylename-postfix" select="$name-postfix"/>
                </xsl:when>
                <!-- no style -->
                <!--<xsl:otherwise>
                  <xsl:attribute name="stylegroup" select="''"/>
                  <xsl:attribute name="stylename" select="''"/>
                </xsl:otherwise>-->
            </xsl:choose>
            <xsl:copy-of select="$add-attributes"/>
            <temp:Properties>
                <xsl:copy-of select="$add-properties"/>
            </temp:Properties>
            <xsl:copy-of select="$insert-at-begin"/>
            <xsl:copy-of select="$content"/>
            <xsl:copy-of select="$insert-at-end" />
        </temp:CSR>
    </xsl:template>


    <!-- ICML textanchor -->
    <xd:doc>
        <xd:desc>
            <xd:p>Creates an InDesign textanchor as target for crossreferences</xd:p>
        </xd:desc>
        <xd:param name="key">unique id of this target. Is converted to integer, any content not matching numbers is stripped</xd:param>
        <xd:param name="name">Display name of the target in InDesign. Defaults to key.</xd:param>
    </xd:doc>
    <xsl:template name="icml-textanchor">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="name" select="$key" />

        <HyperlinkTextDestination Hidden="false">
            <xsl:attribute name="Self" select="fn:concat('HyperlinkTextDestination/', $name)"/>
            <xsl:attribute name="Name" select="$name"/>
            <xsl:attribute name="DestinationUniqueKey" select="func:make-destination-key($key)"/>
        </HyperlinkTextDestination>
    </xsl:template>


    <!-- ICML crossreference -->
    <xd:doc>
        <xd:desc>Creates a dynamic crossreference (page number) to a textanchor. Matching character style from $CSMapping will be applied (as <xd:ref name="icml-inline" type="template"/>)</xd:desc>
        <xd:param name="key">unique id of the reference textanchor. Is converted to integer, any content not matching numbers is stripped</xd:param>
        <xd:param name="name">If needed, a name of the corssreference which will be displayed in InDesign. Defaults to key.</xd:param>
        <xd:param name="self">A unique Self attribute can be set. Usually leave with default, will be created from element</xd:param>
        <xd:param name="insert-at-begin">ICML-Content to be inserted at the beginning (styled in the same way). Usually text or inline styles</xd:param>
        <xd:param name="insert-at-end">ICML-Content to be inserted at the end (styled in the same way). Usually text or inline styles</xd:param>
    </xd:doc>
    <xsl:template name="icml-crossreference">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="name" select="$key" />
        <xsl:param name="self" select="generate-id(.)" />
        <xsl:param name="insert-at-begin" select="()" />
        <xsl:param name="insert-at-end" select="()" />


        <xsl:variable name="mapping" select="func:get-mapping-entry($CSMappingFiltered, .)"/>

        <xsl:if test="$insert-at-begin">
            <temp:CSR>
                <xsl:if test="$mapping">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                </xsl:if>
                <xsl:copy-of select="$insert-at-begin"/>
            </temp:CSR>
        </xsl:if>

        <CrossReferenceSource Self="{$self}" AppliedFormat="{$xref-format-self}" Name="{$name}" key="{$key}" Hidden="false" AppliedCharacterStyle="n">
            <temp:CSR>
                <xsl:if test="$mapping">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                </xsl:if>
                <xsl:attribute name="PageNumberType">TextVariable</xsl:attribute>
                <TextVariableInstance ResultText="?" Self="inst_{$self}" Name="&lt;?AID 001b?&gt;TV XRefPageNumber" AssociatedTextVariable="dTextVariablen&lt;?AID 001b?&gt;TV XRefPageNumber"/>
            </temp:CSR>
        </CrossReferenceSource>

        <xsl:if test="$insert-at-end">
            <temp:CSR>
                <xsl:if test="$mapping">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                </xsl:if>
                <xsl:copy-of select="$insert-at-end"/>
            </temp:CSR>
        </xsl:if>

    </xsl:template>


    <!-- ICML hyperlink -->
    <xd:doc>
        <xd:desc>Creates a hyperlink to an URL. Matching character style from $CSMapping will be applied (as <xd:ref name="icml-inline" type="template"/>)</xd:desc>
    </xd:doc>
    <xsl:template name="icml-hyperlink">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="name" as="xs:string" select="." />
        <xsl:param name="self" select="generate-id(.)" />
        <xsl:param name="insert-at-begin" select="()" />
        <xsl:param name="insert-at-end" select="()" />

        <xsl:variable name="mapping" select="func:get-mapping-entry($CSMappingFiltered, .)"/>

        <xsl:if test="$insert-at-begin">
            <temp:CSR>
                <xsl:if test="$mapping">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                </xsl:if>
                <xsl:copy-of select="$insert-at-begin"/>
            </temp:CSR>
        </xsl:if>

        <HyperlinkTextSource Self="{$self}" Name="{$name}" url="{$url}" Hidden="false" AppliedCharacterStyle="n">
            <xsl:call-template name="icml-inline"/>
        </HyperlinkTextSource>

        <xsl:if test="$insert-at-end">
            <temp:CSR>
                <xsl:if test="$mapping">
                    <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                    <xsl:attribute name="stylename" select="$mapping/@stylename"/>
                </xsl:if>
                <xsl:copy-of select="$insert-at-end"/>
            </temp:CSR>
        </xsl:if>

    </xsl:template>


    <!-- ICML index reference -->
    <xd:doc>
        <xd:desc>Creates an InDesign index reference (index entry)</xd:desc>
        <xd:param name="topic">sequence of hierarchical entry strings (or just a single one)</xd:param>
        <xd:param name="main">if true: entry will be applied an character style</xd:param>
    </xd:doc>
    <xsl:template name="icml-indexreference">
        <xsl:param name="topics" as="xs:string*"/>
        <xsl:param name="main" as="xs:boolean" select="false()"/>

        <PageReference PageReferenceType="CurrentPage">
            <xsl:attribute name="ReferencedTopic" select="func:icml-topic-self($topics)"/>
            <xsl:for-each select="$topics">
                <xsl:if test="normalize-space(.) != ''">
                    <xsl:attribute name="{concat('topic', position())}" select="."/>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="$main">
                <xsl:attribute name="PageNumberStyleOverride" select="func:icml-style-self('character', 'Standardformate', 'Hervorhebung, bold')"/>
            </xsl:if>
        </PageReference>
        <!-- Damit der CharacterStyle mit aufgenommen wird: -->
        <temp:CSR stylegroup="Standardformate" stylename="Hervorhebung, bold"/>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p>Creates an InDesign footnote</xd:p>
        </xd:desc>
        <xd:param name="separator">Character between (automatic) numbering and content. Default: &amp;#x09; (tab).</xd:param>
        <xd:param name="content">Content of the footnote. Should include one or more paragraphs (usually created by <xd:ref name="icml-paragraph" type="template"/> ).</xd:param>
    </xd:doc>
    <xsl:template name="icml-footnote">
        <xsl:param name="separator"><xsl:text>&#x09;</xsl:text></xsl:param>
        <xsl:param name="content"/>
        <temp:CSR Position="Superscript">
            <Footnote>
                <temp:separator><xsl:copy-of select="$separator"/></temp:separator>
                <xsl:copy-of select="$content"/>
            </Footnote>
        </temp:CSR>
    </xsl:template>


    <xd:doc>
        <xd:desc>Creates an InDesign anchored textframe </xd:desc>
        <xd:param name="framewidth">width of the frame, in pt. Use <xd:ref name="func:mm2pt" type="function"/> or <xd:ref name="func:measurement2pt" type="function"/> if needed.</xd:param>
        <xd:param name="frameheight">height of the frame, in pt. Use <xd:ref name="func:mm2pt" type="function"/> <xd:ref name="func:mm2pt" type="function"/> if needed.</xd:param>
        <xd:param name="content">ICML content of the frame. Usually paragraphs.</xd:param>
        <xd:param name="objectstyle-name">Name of a object style which will be applied to the frame</xd:param>
        <xd:param name="objectstyle-group">Name of a group of the object style which will be applied to the frame. Only used if objectstyle-name ist present.</xd:param>
        <xd:param name="add-attributes">directly add arbitrary ICML properties represented as attributes of the result</xd:param>
        <xd:param name="add-properties">directly add arbitrary ICML properties represented as children of the Properties element of the result</xd:param>
        <xd:param name="transform">A transformation matrix. Can be used for special needs like mirroring the content. Usually leave with default "1 0 0 1 0 0".</xd:param>
        <xd:param name="script-label">Adds a script label to the frame. Can be helful for javascripts.</xd:param>
    </xd:doc>
    <xsl:template name="icml-textframe">
        <xsl:param name="framewidth" select="150" as="xs:double"/>
        <xsl:param name="frameheight" select="18" as="xs:double"/>
        <xsl:param name="content"/>
        <xsl:param name="objectstyle-group" as="xs:string?"/>
        <xsl:param name="objectstyle-name" as="xs:string?"/>
        <xsl:param name="add-attributes" as="attribute()*"/>
        <xsl:param name="add-properties" as="element()*"/>
        <xsl:param name="transform" as="xs:string">1 0 0 1 0 0</xsl:param>
        <xsl:param name="script-label" as="xs:string?"/>

        <TextFrame ParentStory="{generate-id(.)}" PreviousTextFrame="n" NextTextFrame="n">
            <xsl:attribute name="stylegroup" select="$objectstyle-group" />
            <xsl:attribute name="stylename" select="$objectstyle-name" />
            <xsl:attribute name="ItemTransform" select="$transform" />
            <xsl:copy-of select="$add-attributes"/>
            <Properties>
                <PathGeometry>
                    <GeometryPathType PathOpen="false">
                        <PathPointArray>
                            <PathPointType Anchor="0 0" LeftDirection="0 0" RightDirection="0 0"/>
                            <PathPointType Anchor="{fn:concat('0 ', $frameheight)}" LeftDirection="{fn:concat('0 ', $frameheight)}" RightDirection="{fn:concat('0 ', $frameheight)}"/>
                            <PathPointType Anchor="{fn:concat($framewidth, ' ', $frameheight)}" LeftDirection="{fn:concat($framewidth, ' ', $frameheight)}" RightDirection="{fn:concat($framewidth, ' ', $frameheight)}"/>
                            <PathPointType Anchor="{fn:concat($framewidth, ' 0')}" LeftDirection="{fn:concat($framewidth, ' 0')}" RightDirection="{fn:concat($framewidth, ' 0')}"/>
                        </PathPointArray>
                    </GeometryPathType>
                </PathGeometry>
                <xsl:if test="$script-label">
                    <Label>
                        <KeyValuePair Key="Label" Value="{$script-label}"/>
                    </Label>
                </xsl:if>
                <xsl:copy-of select="$add-properties"/>
            </Properties>
            <temp:frame-content Self="{generate-id(.)}" title="$ID">
                <xsl:copy-of select="$content"/>
            </temp:frame-content>
        </TextFrame>
    </xsl:template>


    <xd:doc>
        <xd:desc>places an image</xd:desc>
        <xd:param name="asset-id">ID of the image asset</xd:param>
        <xd:param name="objectstyle-name">Name of a object style which will be applied to the image frame</xd:param>
        <xd:param name="objectstyle-group">Name of a group of the object style which will be applied to the image frame. Only used if objectstyle-name ist present.</xd:param>
        <xd:p><xd:b>Measurements</xd:b></xd:p>
        <xd:param name="frame-width">width of the frame, in pt. Use <xd:ref name="func:mm2pt" type="function"/> if needed.</xd:param>
        <xd:param name="frame-height">height of the frame, in pt. Use <xd:ref name="func:mm2pt" type="function"/> if needed.</xd:param>
        <xd:param name="image-width">width of the image content, in pt. Use <xd:ref name="func:mm2pt" type="function"/> if needed.</xd:param>
        <xd:param name="image-height">height of the image content, in pt. Use <xd:ref name="func:mm2pt" type="function"/> if needed.</xd:param>
        <xd:ul>
            <xd:li>If no value for the frame are specified, the frame will fit the image measures</xd:li>
            <xd:li>If no value for the image are specified, measure will be taken from asset attributes</xd:li>
            <xd:li>If only image-width <xd:i>or</xd:i> image-height are specified, the other one will be calculated to keep the ratio.</xd:li>
        </xd:ul>
    </xd:doc>
    <xsl:template name="icml-image">
        <xsl:param name="asset-id" as="xs:integer?"/>
        <xsl:param name="href" as="xs:string" select="concat('censhare:///service/assets/asset/id/', $asset-id)"/>
        <xsl:param name="objectstyle-name" as="xs:string?"/>
        <xsl:param name="objectstyle-group" as="xs:string?"/>
        <xsl:param name="image-width" as="xs:double?"/>
        <xsl:param name="image-height" as="xs:double?"/>
        <xsl:param name="frame-width" as="xs:double?"/>
        <xsl:param name="frame-height" as="xs:double?"/>

        <xsl:variable name="image-asset">
            <xsl:copy-of select="doc($href)"/>
        </xsl:variable>

        <xsl:if test="$image-asset/asset/storage_item[@key='master']">
            <xsl:variable name="mimetype" select="$image-asset/asset/storage_item[@key='master'][1]/@mimetype"/>

            <xsl:variable name="act-w" select="func:mm2pt($image-asset/asset/asset_element[1]/@width_mm)"/>
            <xsl:variable name="act-h" select="func:mm2pt($image-asset/asset/asset_element[1]/@height_mm)"/>
            <xsl:variable name="ratio" select="$act-w div $act-h"/>

            <xsl:variable name="iw" select="if ($image-width) then $image-width else (if ($image-height) then ($image-height * $ratio) else $act-w)"/>
            <xsl:variable name="ih" select="if ($image-height) then $image-height else (if ($image-width) then ($image-width div $ratio) else $act-h)"/>
            <xsl:variable name="fw" select="if ($frame-width) then $frame-width else $iw"/>
            <xsl:variable name="fh" select="if ($frame-height) then $frame-height else $ih"/>

            <Rectangle ContentType="GraphicType" ItemTransform="1 0 0 1 0 0"  Self="rect_{fn:generate-id(.)}" >
                <xsl:attribute name="stylegroup" select="$objectstyle-group" />
                <xsl:attribute name="stylename" select="$objectstyle-name" />
                <Properties>
                    <PathGeometry>
                        <GeometryPathType PathOpen="false">
                            <PathPointArray>
                                <PathPointType Anchor="0 0" LeftDirection="0 0" RightDirection="0 0"/>
                                <PathPointType Anchor="0 {$fh}" LeftDirection="0 {$fh}" RightDirection="0 {$fh}"/>
                                <PathPointType Anchor="{$fw} {$fh}" LeftDirection="{$fw} {$fh}" RightDirection="{$fw} {$fh}"/>
                                <PathPointType Anchor="{$fw} 0" LeftDirection="{$fw} 0" RightDirection="{$fw} 0"/>
                            </PathPointArray>
                        </GeometryPathType>
                    </PathGeometry>
                </Properties>
                <FrameFittingOption AutoFit="false" LeftCrop="0" TopCrop="0" RightCrop="0" BottomCrop="0" FittingOnEmptyFrame="Proportionally" FittingAlignment="CenterAnchor"/>
                <xsl:element name="{if ($mimetype = ('application/pdf', 'application/illustrator')) then 'PDF' else 'Image'}">
                    <xsl:attribute name="Self" select="fn:concat('img_', fn:generate-id(.))"/>
                    <Properties>
                        <GraphicBounds
                                Left="{(($fw - $iw) div 2)}"
                                Top="0"
                                Right="{($fw - ($fw - $iw) div 2)}"
                                Bottom="{$ih}"/>
                    </Properties>
                    <xsl:if test="$mimetype = ('application/pdf', 'application/illustrator')">
                        <PDFAttribute PageNumber="1" PDFCrop="CropTrim" TransparentBackground="true"/>
                    </xsl:if>
                    <!--<Link LinkResourceURI="{$relpath}" Self="link_{fn:generate-id(.)}"/>-->
                    <Link Self="link_{fn:generate-id(.)}">
                        <xsl:attribute name="LinkResourceURI" select="concat($href, '/storage/master/file/')"/>
                    </Link>
                </xsl:element>
            </Rectangle>
        </xsl:if>

    </xsl:template>


    <xd:doc>
        <xd:desc>Creates an InDesign table. Content should be created by calling <xd:ref name="icml-tablerow" type="template"/> and <xd:ref name="icml-tablecell" type="template"/>. The Number of rows and columns will be calculated automatically.</xd:desc>
        <xd:param name="tablestyle-name">Name of a table style which is applied to the table</xd:param>
        <xd:param name="tablestyle-group">Name of group of the table style which is applied to the table</xd:param>
        <xd:param name="header-rows">Number of rows which build a header (repeated on top of every frame/page)</xd:param>
        <xd:param name="footer-rows">Number of rows which build a footer (repeated on bottom of every frame/page)</xd:param>
        <xd:param name="content">ICML content of the table, usually only cells. Default behaviour, if not present, children of the element will be processed and can create rows and cells in matching templates.</xd:param>
        <xd:param name="table-width">width of the table, in pt. Use <xd:ref name="func:mm2pt" type="function"/> or <xd:ref name="func:measurement2pt" type="function"/> if needed.</xd:param>
        <xd:param name="col-widths">widths of the columns, in pt (as sequence). Use <xd:ref name="func:mm2pt" type="function"/> or <xd:ref name="func:measurement2pt" type="function"/> if needed. If less col-widths (or none) are specified than columns in the table, the remaining columns, as well as columns with width=0, will be distributed equally across the table-width.
            <xd:p><xd:i>Either <xd:b>table-width</xd:b> or <xd:b>col-widths</xd:b> for all columns should be specified</xd:i></xd:p>
        </xd:param>
        <xd:param name="add-attributes">directly add arbitrary ICML properties represented as attributes of the result</xd:param>
        <xd:param name="add-properties">directly add arbitrary ICML properties represented as children of the Properties element of the result</xd:param>
        <xd:param name="paragraphstyle-name">Name of a paragraph style for the paragraph the table is part of</xd:param>
        <xd:param name="paragraphstyle-group">Name of a group of the paragraph style for the paragraph the table is part of</xd:param>
    </xd:doc>
    <xsl:template name="icml-table">
        <xsl:param name="tablestyle-group" as="xs:string?"/>
        <xsl:param name="tablestyle-name" as="xs:string?"/>
        <xsl:param name="header-rows" select="0" as="xs:integer?"/>
        <xsl:param name="footer-rows" select="0" as="xs:integer?"/>
        <xsl:param name="table-width" select="300" as="xs:double"/>
        <xsl:param name="col-widths" as="xs:double*" />
        <xsl:param name="add-attributes" as="attribute()*"/>
        <xsl:param name="add-properties" as="element()*"/>
        <xsl:param name="content" as="node()*">
            <xsl:apply-templates mode="#current"/>
        </xsl:param>
        <xsl:param name="create-paragraph" as="xs:boolean" select="true()"/>
        <xsl:param name="paragraphstyle-group" as="xs:string?"/>
        <xsl:param name="paragraphstyle-name" as="xs:string?"/>

        <xsl:variable name="table">
            <Table Self="{generate-id(.)}" HeaderRowCount="{($header-rows, 0)[1]}" FooterRowCount="{($footer-rows, 0)[1]}" TableDirection="LeftToRightDirection">
                <xsl:attribute name="stylegroup" select="$tablestyle-group"/>
                <xsl:attribute name="stylename" select="$tablestyle-name"/>
                <xsl:attribute name="table-width" select="$table-width"/>
                <xsl:copy-of select="$add-attributes"/>
                <temp:Properties>
                    <xsl:copy-of select="$add-properties"/>
                </temp:Properties>
                <xsl:if test="count($col-widths) gt 0">
                    <xsl:for-each select="$col-widths">
                        <Column Name="{position() -1}" SingleColumnWidth="{.}"/>
                    </xsl:for-each>
                </xsl:if>
                <xsl:copy-of select="$content"/>
            </Table>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$create-paragraph">
                <temp:PSR>
                    <xsl:attribute name="stylegroup" select="$paragraphstyle-group"/>
                    <xsl:attribute name="stylename" select="$paragraphstyle-name"/>
                    <xsl:copy-of select="$table"/>
                    <Br/>
                </temp:PSR>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$table"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- ICML table row -->
    <xd:doc>
        <xd:desc>Creates an InDesign table row. Used inside a table, created by <xd:ref name="icml-table" type="template"/></xd:desc>
        <xd:param name="min-height">Minimum height of the row (in pt)</xd:param>
        <xd:param name="fixed-height">Fixed height of the row (in pt)</xd:param>
        <xd:param name="cells">ICML content of the table row, consisting of cells, usually created by <xd:ref name="icml-tablecell" type="template"/>. Default behaviour: children of the element will be processed and can create cells in matching templates.</xd:param>
    </xd:doc>
    <xsl:template name="icml-tablerow">
        <xsl:param name="min-height" select="3"/>
        <xsl:param name="fixed-height" as="xs:double?"/>
        <xsl:param name="cells" as="node()*">
            <xsl:apply-templates mode="#current"/>
        </xsl:param>

        <Row min-height="{$min-height}">
            <xsl:if test="$fixed-height">
                <xsl:attribute name="fixed-height" select="$fixed-height"/>
            </xsl:if>
            <xsl:copy-of select="$cells"/>
        </Row>
    </xsl:template>


    <!-- ICML table cell -->
    <xd:doc>
        <xd:desc>Creates an InDesign table cell. Used inside a table, created by <xd:ref name="icml-table" type="template"/></xd:desc>

        <xd:param name="cellstyle-name">Name of a cell style which is applied to the cell. Can be empty to be defined just by table style.</xd:param>
        <xd:param name="cellstyle-group">Name of group of the cell style which is applied to the cell</xd:param>
        <xd:param name="row-span">row span, number of rows combined by this cell (default: 1 = no span)</xd:param>
        <xd:param name="col-span">col span, number of rows combined by this cell (default: 1 = no span)</xd:param>
        <xd:param name="add-attributes">directly add arbitrary ICML properties represented as attributes of the result</xd:param>
        <xd:param name="add-properties">directly add arbitrary ICML properties represented as children of the Properties element of the result</xd:param>
        <xd:param name="content">ICML content of the cell, usually paragraphs. Default behaviour: children of the element will be processed and should create one or more paragraphs in matching templates.</xd:param>
    </xd:doc>
    <xsl:template name="icml-tablecell">
        <!-- cell style (group/name) -->
        <xsl:param name="cellstyle-group" as="xs:string?"/>
        <xsl:param name="cellstyle-name" as="xs:string?"/>
        <!-- column and/or row span (1 = no span) -->
        <xsl:param name="col-span" as="xs:integer?" select="1"/>
        <xsl:param name="row-span" as="xs:integer?" select="1"/>
        <xsl:param name="add-attributes" as="attribute()*"/>
        <xsl:param name="add-properties" as="element()*"/>
        <!-- content of the cell, only if special handling is needed -->
        <!-- default: apply templates -->
        <xsl:param name="content" as="node()*">
            <xsl:apply-templates mode="#current"/>
        </xsl:param>

        <Cell>
            <xsl:attribute name="stylegroup" select="$cellstyle-group"/>
            <xsl:attribute name="stylename" select="$cellstyle-name"/>

            <xsl:attribute name="ColumnSpan" select="($col-span, 1)[1]" />
            <xsl:attribute name="RowSpan" select="($row-span, 1)[1]" />
            <xsl:copy-of select="$add-attributes"/>
            <temp:Properties>
                <xsl:copy-of select="$add-properties"/>
            </temp:Properties>

            <xsl:copy-of select="$content" />
        </Cell>
    </xsl:template>


    <xd:doc>
        <xd:desc>Creates an InDesign xml tag</xd:desc>
    </xd:doc>
    <xsl:template name="icml-xmlelement">
        <xsl:param name="element-name" as="xs:string"/>
        <xsl:param name="attributes" as="node()*"/>
        <xsl:param name="content" as="node()*">
            <xsl:apply-templates/>
        </xsl:param>
        <XMLElement MarkupTag="{$element-name}">
            <xsl:copy-of select="$attributes" />
            <xsl:copy-of select="$content" />
        </XMLElement>
    </xsl:template>

    <xd:doc>
        <xd:desc>Creates an attribute for an InDesign xml tag, created by <xd:ref name="icml-xmlelement" type="template"/></xd:desc>
    </xd:doc>
    <xsl:template name="icml-xmlattribute">
        <xsl:param name="attr-name" as="xs:string"/>
        <xsl:param name="attr-value" as="xs:string"/>
        <XMLAttribute Name="{$attr-name}" Value="{$attr-value}"/>
    </xsl:template>



    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- default templates  -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->


    <xsl:template match="*" priority="-0.5">
        <xsl:apply-templates select="@*|node()" />
    </xsl:template>

    <xsl:template match="@*" priority="-0.5"/>

    <xsl:template match="processing-instruction()" priority="-0.5">
        <xsl:copy/>
    </xsl:template>


    <xd:doc>
        <xd:desc>default text handling: Looks for a matching entry in $Replacements and performs these RegExp-replacements</xd:desc>
        <xd:param name="strip-start">If true, whitespace at beginning will be deleted. Default: false()</xd:param>
        <xd:param name="strip-end">If true, whitespace at end will be deleted. Default: false()</xd:param>
    </xd:doc>
    <xsl:template match="text()" priority="-0.5" name="text">
        <xsl:param name="strip-start" as="xs:boolean" select="false()"/>
        <xsl:param name="strip-end" as="xs:boolean" select="false()"/>

        <xsl:variable name="mapping" select="func:get-mapping-entry($Replacements, parent::*, true())"/>

        <xsl:variable name="replacements">
            <xsl:call-template name="TextReplacements">
                <xsl:with-param name="mapping" select="$mapping"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="stripped-start" select="if ($strip-start) then (replace(xs:string($replacements), '^\s+', '')) else ($replacements)" />
        <xsl:variable name="stripped-end" select="if ($strip-end) then (replace(xs:string($stripped-start), '\s+$', '')) else ($stripped-start)" />

        <xsl:value-of select="$stripped-end" />

    </xsl:template>



    <xsl:template name="TextReplacements">
        <xsl:param name="input" select="."/>
        <xsl:param name="mapping"/>

        <xsl:choose>
            <xsl:when test="$mapping/@search and $mapping/@replace">
                <xsl:value-of select="
          if ($mapping/@flags) then fn:replace($input, $mapping/@search, $mapping/@replace, $mapping/@flags)
          else fn:replace($input, $mapping/@search, $mapping/@replace)"/>
            </xsl:when>
            <xsl:when test="$mapping/map:entry">
                <xsl:call-template name="TextReplacements">
                    <xsl:with-param name="input" select="$input"/>
                    <xsl:with-param name="mapping" select="$mapping/map:entry"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count($mapping/map:replace) gt 1">
                <xsl:call-template name="TextReplacements">
                    <xsl:with-param name="input" >
                        <xsl:call-template name="TextReplacements">
                            <xsl:with-param name="input" select="$input"/>
                            <xsl:with-param name="mapping">
                                <map:entry>
                                    <xsl:for-each select="fn:remove($mapping/map:replace, xs:integer(count($mapping/map:replace)))">
                                        <xsl:copy-of select="." />
                                    </xsl:for-each>
                                </map:entry>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="mapping" select="$mapping/map:replace[last()]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$mapping/map:replace">
                <xsl:call-template name="TextReplacements">
                    <xsl:with-param name="input" select="$input" />
                    <xsl:with-param name="mapping" select="$mapping/map:replace"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- apply appropriate styles     -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <!-- get the appropriate Stylename and group, for a given mapping and element -->
    <xsl:template name="StyleByElement">
        <xsl:param name="map"/>
        <xsl:param name="omit-empty"/>

        <xsl:variable name="mapping" select="func:get-mapping-entry($map, .)"/>

        <xsl:choose>
            <xsl:when test="$mapping">
                <xsl:attribute name="stylegroup" select="$mapping/@stylegroup"/>
                <xsl:attribute name="stylename" select="$mapping/@stylename"/>
            </xsl:when>
            <xsl:when test="$omit-empty = '1'"/>
            <xsl:otherwise>
                <xsl:attribute name="stylegroup" select="''"/>
                <xsl:attribute name="stylename" select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- fixed templates   -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->


    <xsl:template match="temp:stories" mode="colors" priority="0.0">
        <Color Self="Color/Black" Model="Process" Space="CMYK" ColorValue="0 0 0 100" ColorOverride="Specialblack" AlternateSpace="NoAlternateColor" AlternateColorValue="" Name="Black" ColorEditable="false" ColorRemovable="false" Visible="true"/>
        <Color Self="Color/Paper" Model="Process" Space="CMYK" ColorValue="0 0 0 0" ColorOverride="Specialpaper" AlternateSpace="NoAlternateColor" AlternateColorValue="" Name="Paper" ColorEditable="true" ColorRemovable="false" Visible="true"/>
        <xsl:for-each-group select=".//@FillColor | .//@StrokeColor | .//@GapColor" group-by=".">
            <xsl:choose>
                <xsl:when test="matches(., 'Color/C=\d+ M=\d+ Y=\d+ K=\d+')">
                    <xsl:variable name="values" select="tokenize( replace(., 'Color/C=', ''), ' ?[A-Z]=')" />
                    <Color Self="{.}" Model="Process" Space="CMYK" ColorValue="{string-join($values, ' ')}" Name="C={$values[1]} M={$values[2]} Y={$values[3]} K={$values[4]}" />
                </xsl:when>
                <xsl:when test=". = ('Color/Black', 'Color/Paper', 'Swatch/None')"/>
                <xsl:otherwise>
                    <Color Self="{.}" Name="{replace(., 'Color/', '')}" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
        <Swatch ColorEditable="false" ColorRemovable="false" Name="None" Self="Swatch/None" Visible="true"/>
    </xsl:template>


    <xsl:function name="func:cmyk-color" as="xs:string">
        <xsl:param name="c"/>
        <xsl:param name="m"/>
        <xsl:param name="y"/>
        <xsl:param name="k"/>
        <xsl:value-of select="concat('Color/C=', $c, ' M=', $m, ' Y=', $y, ' K=', $k)" />
    </xsl:function>



    <!--Template: styles – styles used in document-->
    <xsl:template match="temp:stories" mode="styles" priority="0.0">
        <xsl:call-template name="RootCharacterStyleGroup" />
        <xsl:call-template name="RootParagraphStyleGroup" />
        <xsl:call-template name="RootCellStyleGroup" />
        <xsl:call-template name="RootTableStyleGroup" />
        <xsl:call-template name="RootObjectStyleGroup" />
    </xsl:template>


    <xsl:template name="RootParagraphStyleGroup">
        <xsl:call-template name="RootStyleGroup">
            <xsl:with-param name="type">ParagraphStyle</xsl:with-param>
            <xsl:with-param name="style-elements" select=".//temp:PSR" />
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="RootCharacterStyleGroup">
        <xsl:call-template name="RootStyleGroup">
            <xsl:with-param name="type">CharacterStyle</xsl:with-param>
            <xsl:with-param name="style-elements" select=".//temp:CSR" />
        </xsl:call-template>
    </xsl:template>



    <xsl:template name="RootObjectStyleGroup">
        <xsl:call-template name="RootStyleGroup">
            <xsl:with-param name="type">ObjectStyle</xsl:with-param>
            <xsl:with-param name="style-elements" select=".//TextFrame | .//Rectangle | .//Polygon | .//Oval | .//Graphic | .//Image | .//EPS | .//WMF | .//PICT | .//PDF | .//GraphicLine | .//Group" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="RootCellStyleGroup">
        <xsl:call-template name="RootStyleGroup">
            <xsl:with-param name="type">CellStyle</xsl:with-param>
            <xsl:with-param name="style-elements" select=".//Cell" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="RootTableStyleGroup">
        <xsl:call-template name="RootStyleGroup">
            <xsl:with-param name="type">TableStyle</xsl:with-param>
            <xsl:with-param name="style-elements" select=".//Table" />
        </xsl:call-template>
    </xsl:template>



    <xsl:template name="RootStyleGroup">
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="style-elements" as="element()*"/>

        <xsl:variable name="styles">
            <xsl:for-each-group select="$style-elements[@stylename != '']" group-by="@stylegroup">
                <xsl:for-each-group select="current-group()" group-by="@stylename">
                    <xsl:for-each-group select="current-group()" group-by="normalize-space(@stylename-postfix)">
                        <style>
                            <xsl:copy-of select="@stylegroup"/>
                            <xsl:copy-of select="@stylename"/>
                        </style>
                        <xsl:if test="normalize-space(@stylename-postfix) != ''">
                            <style>
                                <xsl:copy-of select="@stylegroup"/>
                                <xsl:copy-of select="@stylename"/>
                                <xsl:copy-of select="@stylename-postfix"/>
                            </style>
                        </xsl:if>
                    </xsl:for-each-group>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:variable>

        <xsl:element name="Root{$type}Group">
            <xsl:attribute name="Self" select="concat($type, 'Root', generate-id(.))"/>

            <xsl:choose>
                <xsl:when test="$type = 'CharacterStyle'">
                    <CharacterStyle Self="CharacterStyle/$ID/[No character style]" Imported="false" Name="$ID/[No character style]"/>
                </xsl:when>
                <xsl:when test="$type = 'ParagraphStyle'">
                    <ParagraphStyle Self="ParagraphStyle/$ID/[No paragraph style]" Imported="false" Name="$ID/[No paragraph style]"/>
                </xsl:when>
            </xsl:choose>

            <xsl:for-each-group select="$styles/*[@stylegroup = '' or not(@stylegroup)]" group-by="@stylename">
                <xsl:for-each-group select="current-group()" group-by="normalize-space(@stylename-postfix)">
                    <xsl:element name="{$type}">
                        <xsl:attribute name="Self" select="func:icml-style-self($type, @stylegroup, @stylename, @stylename-postfix)" />
                        <xsl:attribute name="Name" select="func:icml-style-name($type, @stylegroup, @stylename, @stylename-postfix)" />
                        <xsl:if test="$type = ('CharacterStyle', 'ParagraphStyle')">
                            <xsl:attribute name="Imported">true</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@stylename-postfix">
                            <Properties>
                                <BasedOn type="object">
                                    <xsl:value-of select="func:icml-style-self($type, @stylegroup, @stylename)"/>
                                </BasedOn>
                            </Properties>
                        </xsl:if>
                    </xsl:element>
                </xsl:for-each-group>
            </xsl:for-each-group>

            <xsl:for-each-group select="$styles/*[@stylegroup != '']" group-by="tokenize(@stylegroup, $stylegroup-separator)[1]">
                <xsl:call-template name="StyleGroup">
                    <xsl:with-param name="type" select="$type" />
                    <xsl:with-param name="styles" select="current-group()"/>
                    <xsl:with-param name="name-path" select="current-grouping-key()"/>
                </xsl:call-template>
            </xsl:for-each-group>

        </xsl:element>
    </xsl:template>


    <xsl:template name="StyleGroup">
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="styles" as="element()*"/>
        <xsl:param name="name-path" as="xs:string"/>

        <xsl:element name="{$type}Group">
            <xsl:attribute name="Self" select="concat($type, 'Group/', replace($name-path, $stylegroup-separator, '%3a'))" />
            <xsl:attribute name="Name" select="replace($name-path, $stylegroup-separator, ':')" />

            <xsl:for-each-group select="$styles[@stylegroup = $name-path]" group-by="@stylename">
                <xsl:for-each-group select="current-group()" group-by="normalize-space(@stylename-postfix)">
                    <xsl:element name="{$type}">
                        <xsl:attribute name="Self" select="func:icml-style-self($type, @stylegroup, @stylename, @stylename-postfix)" />
                        <xsl:attribute name="Name" select="func:icml-style-name($type, @stylegroup, @stylename, @stylename-postfix)" />
                        <xsl:attribute name="Imported">true</xsl:attribute>
                        <xsl:if test="@stylename-postfix">
                            <Properties>
                                <BasedOn type="object">
                                    <xsl:value-of select="func:icml-style-self($type, @stylegroup, @stylename)"/>
                                </BasedOn>
                            </Properties>
                        </xsl:if>
                    </xsl:element>
                </xsl:for-each-group>
            </xsl:for-each-group>

            <xsl:variable name="level" select="count(tokenize($name-path, $stylegroup-separator))"/>
            <xsl:for-each-group select="$styles[matches(@stylegroup, concat('^', $name-path, $stylegroup-separator))]" group-by="tokenize(@stylegroup, $stylegroup-separator)[$level +1]">
                <xsl:call-template name="StyleGroup">
                    <xsl:with-param name="type" select="$type" />
                    <xsl:with-param name="styles" select="current-group()"/>
                    <xsl:with-param name="name-path" select="concat($name-path, $stylegroup-separator, current-grouping-key())"/>
                </xsl:call-template>
            </xsl:for-each-group>

        </xsl:element>
    </xsl:template>



    <xsl:template name="TextVariable">
        <TextVariable Self="dTextVariablen&lt;?AID 001b?&gt;TV XRefPageNumber" Name="&lt;?AID 001b?&gt;TV XRefPageNumber" VariableType="XrefPageNumberType"/>
    </xsl:template>

    <xsl:template name="CrossRefFormats">
        <CrossReferenceFormat Self="{$xref-format-self}" Name="Seitenzahl" AppliedCharacterStyle="n">
            <BuildingBlock Self="u9b30bBuildingBlock1" BlockType="PageNumberBuildingBlock" AppliedCharacterStyle="n" CustomText="$ID/" AppliedDelimiter="$ID/" IncludeDelimiter="false"/>
        </CrossReferenceFormat>
    </xsl:template>


    <xsl:template match="temp:stories" mode="xmltags" priority="0.0">
        <xsl:for-each-group select=".//XMLElement" group-by="@MarkupTag">
            <XMLTag Self="XMLTag/{encode-for-uri(@MarkupTag)}" Name="{@MarkupTag}"/>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template match="temp:stories" mode="index" priority="0.0">
        <Index Self="{$index-self}">
            <!--<xsl:for-each-group select=".//PageReference" group-by="@ReferencedTopic">
              <Topic Self="{@ReferencedTopic}" SortOrder="" Name="{substring-after(@ReferencedTopic, 'Topicn')}"/>
            </xsl:for-each-group>-->
            <xsl:for-each-group select=".//PageReference" group-by="@topic1">
                <Topic Self="{func:icml-topic-self(@topic1)}" SortOrder="" Name="{@topic1}">
                    <xsl:for-each-group select="current-group()" group-by="@topic2">
                        <Topic Self="{func:icml-topic-self((@topic1, @topic2))}" SortOrder="" Name="{@topic2}">
                            <xsl:for-each-group select="current-group()" group-by="@topic3">
                                <Topic Self="{func:icml-topic-self((@topic1, @topic2, @topic3))}" SortOrder="" Name="{@topic3}">
                                    <xsl:for-each-group select="current-group()" group-by="@topic4">
                                        <Topic Self="{func:icml-topic-self((@topic1, @topic2, @topic3, @topic4))}" SortOrder="" Name="{@topic4}"/>
                                    </xsl:for-each-group>
                                </Topic>
                            </xsl:for-each-group>
                        </Topic>
                    </xsl:for-each-group>
                </Topic>
            </xsl:for-each-group>
        </Index>
    </xsl:template>


    <xsl:template match="temp:stories" mode="hyperlinks">
        <xsl:for-each select=".//HyperlinkTextSource">
            <xsl:variable name="unique-key" select="10 + position()"/>
            <HyperlinkURLDestination Self="hypurl_{@Self}" Name="{@url}" DestinationURL="{@url}" Hidden="true"/>
            <Hyperlink Source="{@Self}" Self="hyp_{@Self}" Visible="true" Highlight="None" Width="Thin" BorderStyle="Solid" Hidden="false" Name="{@Name}">
                <Properties>
                    <Destination type="object">hypurl_<xsl:value-of select="@Self"/></Destination>
                </Properties>
            </Hyperlink>
        </xsl:for-each>
        <xsl:for-each select=".//CrossReferenceSource">
            <xsl:call-template name="xref-hyperlink">
                <xsl:with-param name="self" select="@Self" />
                <xsl:with-param name="key" select="@key" />
                <xsl:with-param name="name" select="@Name" />
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>


    <!-- wird beim "flattening" für CrossReferenceSource erzeugt -->
    <xsl:template name="xref-hyperlink">
        <xsl:param name="key"/>
        <xsl:param name="name" select="$key" />
        <xsl:param name="self"/>
        <Hyperlink Source="{$self}" Self="hyp_{$self}" Visible="false" Highlight="None" Width="Thin" BorderStyle="Solid" Hidden="false">
            <xsl:attribute name="DestinationUniqueKey" select="func:make-destination-key($key)"/>
            <xsl:attribute name="Name" select="$name"/>
        </Hyperlink>
    </xsl:template>



    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
    <!-- functions  -->
    <!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

    <xsl:variable name="stylegroup-separator">/</xsl:variable>


    <xsl:function name="func:get-mapping-entry">
        <xsl:param name="map"/>
        <xsl:param name="element"/>
        <xsl:sequence select="func:get-mapping-entry($map, $element, false())"/>
    </xsl:function>

    <xsl:function name="func:get-mapping-entry">
        <xsl:param name="map"/>
        <xsl:param name="element"/>
        <xsl:param name="find-children"/>

        <xsl:variable name="matches">
            <xsl:for-each select="$map/map:entry">
                <xsl:sort select="func:path-match($element, @element, $find-children)" order="descending"/>
                <xsl:sort select="if (@attr-name) then 1 else 0" order="descending"/>
                <!--        <xsl:sort select="fn:position()" order="descending"/>-->

                <xsl:variable name="entry" select="."/>

                <xsl:choose>
                    <xsl:when test="$entry/@element = '/'">
                        <xsl:copy-of select="$entry"/>
                    </xsl:when>
                    <xsl:when test="(func:path-match($element, $entry/@element, $find-children) gt 0) and ($entry/@attr-name)">
                        <!-- censhare doesn’t support xpath @*[fn:name = 'x'] yet - workaround: -->
                        <xsl:for-each select="$element/@*">
                            <xsl:if test="(fn:name(.) = $entry/@attr-name) and (. = $entry/@attr-value)">
                                <xsl:copy-of select="$entry"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="func:path-match($element, $entry/@element, $find-children) gt 0">
                        <xsl:copy-of select="$entry"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="$matches/map:entry[1]"/>

    </xsl:function>


    <xsl:function name="func:path-match">
        <xsl:param name="element"/>
        <xsl:param name="path"/>
        <xsl:sequence select="func:path-match($element, $path, false())"/>
    </xsl:function>

    <xsl:function name="func:path-match">
        <xsl:param name="element"/>
        <xsl:param name="path"/>
        <xsl:param name="find-children"/>

        <xsl:variable name="fullpath" select="func:get-full-path($element)"/>
        <xsl:choose>
            <xsl:when test="fn:matches($fullpath, fn:concat('^((/.*/)|/)?', $path, if ($find-children) then '(.*?)$' else '$'))">
                <xsl:variable name="pre" select="if (starts-with($path, '/')) then '' else fn:replace($fullpath, fn:concat('^/(.*)/', $path, '(.*?)$'), '$1')"/>
                <xsl:variable name="count-pre" select="fn:count(fn:tokenize($pre, '/'))"/>

                <xsl:variable name="count-path" select="fn:count(fn:tokenize($path, '/'))"/>

                <xsl:sequence select="func:power(2, $count-pre + $count-path) - func:power(2, $count-pre)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>


    <!-- returns full path of given element, including names of all parent nodes -->
    <xsl:function name="func:get-full-path">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="count" select="count($element/ancestor-or-self::node())" as="xs:integer" />
        <!-- replace() Workaround for 4.5.1 (document-node not contained in ancestor-or-self::node() )-->
        <!--<xsl:value-of select="for $i in reverse(1 to $count) return local-name($element/ancestor-or-self::node()[$i])" separator="/"/>-->
        <xsl:value-of select="replace( string-join(for $i in reverse(1 to $count) return local-name($element/ancestor-or-self::node()[$i]), '/'), '^([^/])', '/$1')"/>
    </xsl:function>


    <xsl:variable name="stylegroup-path-replacement" as="xs:string*">
        <xsl:choose>
            <xsl:when test="$autostyle-path-strip/map:entry/text()">
                <xsl:value-of select="for $x in $autostyle-path-strip/map:entry/text() return concat('^', replace($x, '/', $stylegroup-separator), $stylegroup-separator, '|^', replace($x, '/', $stylegroup-separator), '$')" separator="|"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('^', $stylegroup-separator)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:function name="func:stylegroup-from-path">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="count" select="count($element/ancestor-or-self::*)" as="xs:integer" />
        <xsl:variable name="path" select="string-join(for $i in reverse(2 to $count) return local-name($element/ancestor-or-self::*[$i]), $stylegroup-separator)" />
        <xsl:value-of select="replace($path, $stylegroup-path-replacement, '')" />
    </xsl:function>


    <!-- Self attribute for ICML-Styles -->
    <!-- used for referencing of styles inside ICML -->
    <xsl:function name="func:icml-style-self">
        <xsl:param name="type"/>
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:param name="name-postfix"/>

        <xsl:sequence select="func:icml-style-self($type, $group, concat($name, $name-postfix) )" />
    </xsl:function>

    <!-- Self attribute for ICML-Styles -->
    <!-- used for referencing of styles inside ICML -->
    <xsl:function name="func:icml-style-self">
        <xsl:param name="type"/>
        <xsl:param name="group"/>
        <xsl:param name="name"/>

        <xsl:variable name="typevalue">
            <xsl:choose>
                <xsl:when test="$type = ('cell', 'CellStyle')">CellStyle</xsl:when>
                <xsl:when test="$type = ('table', 'TableStyle')">TableStyle</xsl:when>
                <xsl:when test="$type = ('paragraph', 'ParagraphStyle')">ParagraphStyle</xsl:when>
                <xsl:when test="$type = ('character', 'CharacterStyle')">CharacterStyle</xsl:when>
                <xsl:when test="$type = ('object', 'ObjectStyle')">ObjectStyle</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="namevalue">
            <xsl:choose>
                <xsl:when test="fn:normalize-space($name) = ''">
                    <xsl:choose>
                        <xsl:when test="$type = ('cell', 'CellStyle')">$ID/[None]</xsl:when>
                        <xsl:when test="$type = ('table', 'TableStyle')">$ID/[Basic Table]</xsl:when>
                        <xsl:when test="$type = ('paragraph', 'ParagraphStyle')">$ID/[No paragraph style]</xsl:when>
                        <xsl:when test="$type = ('character', 'CharacterStyle')">$ID/[No character style]</xsl:when>
                        <xsl:when test="$type = ('object', 'ObjectStyle')">$ID/[None]</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="(fn:normalize-space($group)) = '' or (fn:normalize-space($name) = '')">
                <xsl:sequence select="fn:concat($typevalue, '/', $namevalue)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="fn:concat($typevalue, '/', replace(replace($group, '%', '%25'), $stylegroup-separator, '%3a'), '%3a', replace($namevalue, '%', '%25'))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>





    <!-- Name attribute for ICML-Styles -->
    <!-- used inside style declarations -->
    <xsl:function name="func:icml-style-name">
        <xsl:param name="type"/>
        <xsl:param name="group"/>
        <xsl:param name="name"/>
        <xsl:param name="name-postfix"/>

        <xsl:choose>
            <xsl:when test="(fn:normalize-space($group)) = '' or (fn:normalize-space($name) = '')">
                <xsl:value-of select="concat($name, $name-postfix)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(replace($group, $stylegroup-separator, ':'), ':', $name, $name-postfix)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="func:icml-style-name">
        <xsl:param name="type"/>
        <xsl:param name="group"/>
        <xsl:param name="name"/>

        <xsl:sequence select="func:icml-style-name($type, $group, $name, '')" />
    </xsl:function>


    <xsl:function name="func:icml-topic-self">
        <xsl:param name="topics" as="xs:string*"/>
        <xsl:value-of select="string-join( ($index-self, replace($topics[position() lt 5], ':', '-')), 'Topicn')"/>
    </xsl:function>


    <xsl:function name="func:make-destination-key">
        <xsl:param name="source"/>
        <xsl:sequence select="fn:replace($source, '\D|^0+', '')"/>
    </xsl:function>


    <xd:doc>
        <xd:desc>Converts measurements, including unit, to pt-values</xd:desc>
        <xd:param name="input">input value (string)</xd:param>
    </xd:doc>
    <xsl:function name="func:measurement2pt" as="xs:double?">
        <xsl:param name="input" as="xs:string?"/>
        <xsl:variable name="regexp-number">\d+(\.\d+)?</xsl:variable>
        <xsl:choose>
            <xsl:when test="empty($input)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="matches($input, concat('^', $regexp-number, 'mm$'))">
                <xsl:value-of select="func:mm2pt(number(replace($input, 'mm', '')))"/>
            </xsl:when>
            <xsl:when test="matches($input, concat('^', $regexp-number, 'pt$'))">
                <xsl:value-of select="number(replace($input, 'pt', ''))"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:desc>Converts pt to mm</xd:desc>
        <xd:param name="pt">input value, pt</xd:param>
    </xd:doc>
    <xsl:function name="func:pt2mm" as="xs:double">
        <xsl:param name="pt" as="xs:double"/>
        <xsl:sequence select="$pt * 0.3527777778"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Converts mm to pt</xd:desc>
        <xd:param name="mm">input value, mm</xd:param>
    </xd:doc>
    <xsl:function name="func:mm2pt" as="xs:double">
        <xsl:param name="mm" as="xs:double"/>
        <xsl:sequence select="$mm div 0.3527777778"/>
    </xsl:function>

    <xsl:function name="func:power" as="xs:integer">
        <xsl:param name="base" as="xs:integer"/>
        <xsl:param name="exponent" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$exponent gt 1">
                <xsl:sequence select="$base * func:power($base, $exponent - 1)"/>
            </xsl:when>
            <xsl:when test="$exponent eq 1">
                <xsl:sequence select="$base"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
