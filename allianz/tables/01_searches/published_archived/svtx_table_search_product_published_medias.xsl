<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:censhare="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com">

    <xsl:import href="censhare:///service/assets/asset;censhare:resource-key=svtx:public.archive.utils/storage/master/file"/>
    <xsl:param name="context-id"/>
    <xsl:param name="filterAssetName" select="''"/>
    <xsl:param name="assetType" select="'all'"/>
    <xsl:param name="workflowStepID" select="'all'"/>
    <!-- root match -->
    <xsl:template match="/">
        <query type="asset">
            <or>
                <and>
                    <condition name="censhare:asset.type" partial-load-tree="true" value="article.*" expanded-nodes="article."/>
                    <relation target="child" type="user.*">
                        <target>
                            <condition name="censhare:asset.type" value="text.*"/>
                            <or>
                                <and>
                                    <condition name="censhare:asset.domain" value="root.allianz-leben-ag.contenthub.public.*"/>
                                    <condition name="censhare:output-channel" op="NOTNULL"/>
                                </and>
                                <and>
                                    <condition name="censhare:asset.wf_id" value="10"/>
                                    <condition name="censhare:function.workflow-step" value="30"/>
                                </and>
                            </or>
                        </target>
                    </relation>
                </and>
                <and>
                    <or>
                        <condition name="censhare:asset.type" value="layout.*"/>
                        <condition name="censhare:asset.type" value="presentation.*"/>
                    </or>
                    <condition name="censhare:asset.wf_id" value="80"/>
                    <or>
                        <condition name="censhare:function.workflow-step" value="30"/>
                        <condition name="censhare:function.workflow-step" value="60"/>
                        <condition name="censhare:function.workflow-step" value="55"/>
                        <condition name="censhare:function.workflow-step" value="90"/>
                    </or>
                </and>
            </or>
            <relation target="parent" type="user.*">
                <target>
                    <condition name="censhare:asset.id" value="{$context-id}"/>
                </target>
            </relation>
        </query>
    </xsl:template>
</xsl:stylesheet>
