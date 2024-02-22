<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions">

  <xsl:template match="/asset">
    <query>
      <condition name="censhare:asset.type" value="product.*"/>
		  <relation target="child" type="user.*">
    		<target>
		      <condition name="censhare:asset.type" value="article.*"/>
		      <condition name="svtx:recurring-module-of" value="{@id}"/>
    		</target>
		  </relation>
    </query>
  </xsl:template>

</xsl:stylesheet>
