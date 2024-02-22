<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="cs censhare xs">

    <xsl:template match="/" >
        <xsl:variable name="asset" select="./asset"/>

        <xsl:variable name="print-number" select="$asset/asset_feature[@feature='svtx:layout-print-number']/@value_string"/>

        <xsl:variable name="storage-items">
            <xsl:if test="starts-with($asset/@type, 'layout.') and $asset/@wf_id='80' and ($asset/@wf_step='60' or $asset/@wf_step='90')">
                <xsl:variable name="filename">
                    <xsl:choose>
                        <xsl:when test="$print-number">
                            <xsl:value-of select="concat($print-number, '_print.pdf')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($asset/@name, '.pdf')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="storage-item-pdf" select="$asset/storage_item[@key='pdf-drbk-x4']"/>
                <xsl:if test="exists($storage-item-pdf)">
                    <storageitem>
                        <name><xsl:value-of select="$filename"/></name>
                        <mimetype>Druck-PDF</mimetype>
                        <key><xsl:value-of select="$storage-item-pdf/@key"/></key>
                        <filesize><xsl:value-of select="$storage-item-pdf/@filelength"/></filesize>
                        <storageUrl><xsl:value-of select="$storage-item-pdf/@url"/></storageUrl>
                        <filename><xsl:value-of select="$filename"/></filename>
                        <icon>pdf</icon>
                    </storageitem>
                </xsl:if>
            </xsl:if>

            <xsl:if test="starts-with($asset/@type, 'layout.') and exists($asset/storage_item[@key='pdf-online'])">
                <xsl:variable name="rootLayoutKey" as="xs:string?">
                    <xsl:variable name="variantOf" select="($asset/cs:parent-rel()[@key='variant.0.']/cs:asset()[@censhare:asset.type='layout.*'])[1]" as="element(asset)?"/>
                    <xsl:variable name="contextAsset" select="if ($variantOf) then $variantOf else $asset" as="element(asset)?"/>
                    <xsl:variable name="rootLayout" select="$contextAsset/cs:feature-ref-reverse()[@key='svtx:layout-template']" as="element(asset)?"/>
                    <xsl:value-of select="$rootLayout/asset_feature[@feature='censhare:resource-key']/@value_string"/>
                </xsl:variable>
                <xsl:variable name="postfix" select="if ($rootLayoutKey = 'svtx:indd.template.flyer.allianz') then '_W2P27' else if ($rootLayoutKey = 'svtx:indd.template.twopager.allianz') then '_W2P1' else ()"/>
                <xsl:variable name="filename">
                    <xsl:choose>
                        <xsl:when test="$print-number">
                            <xsl:value-of select="concat('F_', $print-number, $postfix ,'.pdf')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('F_', $asset/@name, $postfix ,'.pdf')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="storage-item-online-pdf" select="$asset/storage_item[@key='pdf-online']"/>
                <xsl:variable name="feature-barrier-free" select="$asset/asset_feature[@feature='allianz:barrier-free-pdf-in-creation']"/>
                <xsl:variable name="barrier-free-in-creation">
                    <xsl:choose>
                        <xsl:when test="exists($feature-barrier-free)">
                            <xsl:value-of select="$feature-barrier-free/@value_long"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'0'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:if test="exists($storage-item-online-pdf) and $barrier-free-in-creation='0'">
                    <storageitem>
                        <name><xsl:value-of select="$filename"/></name>
                        <mimetype>Online-PDF</mimetype>
                        <key><xsl:value-of select="$storage-item-online-pdf/@key"/></key>
                        <filesize><xsl:value-of select="$storage-item-online-pdf/@filelength"/></filesize>
                        <storageUrl><xsl:value-of select="$storage-item-online-pdf/@url"/></storageUrl>
                        <filename><xsl:value-of select="$filename"/></filename>
                        <icon>pdf</icon>
                    </storageitem>
                </xsl:if>
            </xsl:if>

        </xsl:variable>

        <storageitems>
            <xsl:copy-of select="$storage-items"/>
        </storageitems>
    </xsl:template>
</xsl:stylesheet>