<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
    exclude-result-prefixes="#all"
    version="2.0">

    <!-- parameters -->
    <xsl:param name="transform"/>

    <!-- Defines a search for the main content assets -->
    <xsl:template match="asset">
    	<assets>
    		<xsl:copy-of select="(cs:child-rel()[@key='user.main-content.']/cs:asset()[@censhare:asset.type='text.*'])[1]"/>
    	</assets>    
    </xsl:template>

</xsl:stylesheet>
