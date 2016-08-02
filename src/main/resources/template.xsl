<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="http://exslt.org/common" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.nrd.ru" version="1.0">
    
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/">
        <html>
            <xsl:call-template name="htmlHead"/>
            <body>
                <xsl:call-template name="header"/>
                <xsl:call-template name="%s"/>
                <xsl:call-template name="printFloor"/>
            </body>
        </html>
    </xsl:template>
    
%s
</xsl:stylesheet>