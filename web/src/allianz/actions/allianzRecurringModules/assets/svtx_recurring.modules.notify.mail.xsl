<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
        xmlns:my="http://www.censhare.com/xml/3.0.0/my-functions"
        xmlns:censhare="http://www.censhare.com/xml/3.0.0/censhare"
        xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
        exclude-result-prefixes="#all" version="2.0">

  <xsl:param name="product-ids" as="xs:string?"/>
  <xsl:param name="message" as="xs:string?"/>

  <xsl:variable name="sender-account" select="'corpus'"/>
  <xsl:variable name="sender-address" select="'allianz-cs@ort-online.net'"/>
  <xsl:variable name="replyto-address" select="'no-reply@censhare.com'"/>
  <xsl:variable name="env" select="system-property('censhare:server-name')" as="xs:string?"/>
  <xsl:variable name="prefix-url" select="if ($env = 'dev-contenthub') then 'https://allianz-cs.ort-online.net' else 'https://allianzlive-cs.ort-online.net'" as="xs:string?"/>

  <xsl:template match="/">
    <xsl:variable name="products" as="element(asset)*">
      <xsl:for-each select="tokenize($product-ids, ',')">
        <xsl:variable name="id" select="xs:long(.)"/>
        <xsl:copy-of select="cs:get-asset($id)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="sentMails">
      <xsl:if test="count($products) gt 0">
        <cs:command name="com.censhare.api.Mail.SendMail">
          <cs:param name="source">
            <mails account-name="{$sender-account}">
              <xsl:for-each-group select="$products" group-by="child_asset_rel[@key='user.responsible.']/@child_asset">
                <xsl:variable name="responsible" select="child_asset_rel[@key='user.responsible.']/@child_asset" as="xs:long?"/>
                <xsl:variable name="party" select="cs:master-data('party')[@party_asset_id=$responsible]"/>
                <xsl:variable name="mailTo" select="$party/@email"/>
                <xsl:if test="$mailTo">
                  <mail replyto-address="{$replyto-address}" sender-address="{$sender-address}" subject="Update wiederverwendbare Module">
                    <recipient type="to" address="{$mailTo}"/>
                    <content mimetype="text/html" transfer-charset="UTF-8">
                      <body>
                        <xsl:if test="$message">
                          <p>
                            <xsl:for-each select="tokenize($message, '\n\r?')">
                              <xsl:value-of select="."/><br/>
                            </xsl:for-each>
                          </p>
                        </xsl:if>
                        <xsl:apply-templates select="current-group()" mode="content"/>
                      </body>
                    </content>
                  </mail>
                </xsl:if>
              </xsl:for-each-group>
            </mails>
          </cs:param>
        </cs:command>
      </xsl:if>
    </xsl:variable>
  </xsl:template>

  <xsl:template match="asset" mode="content">
    <xsl:variable name="url" select="concat($prefix-url,'/censhare5/client/assetProduct/', @id)"/>
    <p><xsl:value-of select="@name"/>:<xsl:text> </xsl:text><a href="{$url}"><xsl:value-of select="$url"/></a></p>
    <br/>
  </xsl:template>

</xsl:stylesheet>
