<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

 	<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

   <xsl:template match="/">
   	<html>
      <xsl:apply-templates/>
    </html>
   </xsl:template>
   
   <xsl:template match="head">
   	<head>
      <xsl:value-of select="title/maintitle/@id"/>
    </head>
   </xsl:template>
   
   
   
   
</xsl:stylesheet>