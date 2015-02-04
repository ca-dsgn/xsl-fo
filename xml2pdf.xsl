<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:fo="http://www.w3.org/1999/XSL/Format">

   <!-- Attribut-Sets fuer Tabellenzellen -->
   <xsl:attribute-set name="cell-style">
      <xsl:attribute name="border-width">0.5pt</xsl:attribute>
      <xsl:attribute name="border-style">solid</xsl:attribute>
      <xsl:attribute name="border-color">black</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="block-style">
      <xsl:attribute name="font-size">  10pt</xsl:attribute>
      <xsl:attribute name="line-height">15pt</xsl:attribute>
      <xsl:attribute name="start-indent">1mm</xsl:attribute>
      <xsl:attribute name="end-indent">  1mm</xsl:attribute>
   </xsl:attribute-set>

   <!-- Seitenaufteilung -->
   <xsl:template match="/">
      <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
         <fo:layout-master-set>
            <fo:simple-page-master master-name="DIN-A4"
                  page-height="29.7cm" page-width="21cm"
                  margin-top="2cm"     margin-bottom="2cm"
                  margin-left="2cm"  margin-right="2cm">
               <fo:region-body
                  margin-top="8cm" margin-bottom="1.8cm"
                  margin-left="0"  margin-right="0"/>
               <fo:region-before region-name="header" extent="0cm"/>
               <fo:region-after  region-name="footer" extent="0cm"/>
               <fo:region-start  region-name="left"   extent="0cm"/>
               <fo:region-end    region-name="right"  extent="0cm"/>
            </fo:simple-page-master>
         </fo:layout-master-set>
         <fo:page-sequence master-reference="DIN-A4">
            <fo:static-content flow-name="header">
            	<fo:block font-size="8pt" text-align="left" margin-bottom="0.2cm">
                	<fo:inline border-after-width="1pt" border-after-style="solid">
                		Naisone UG (haftungsbeschränk), Sandweg 5, 74613 Öhringen
                    </fo:inline>
                </fo:block>
                <fo:block-container position="absolute" left="15cm">
                    <fo:block>
                            <fo:external-graphic src="url(file:logo.png)" content-width="2cm" />
                    </fo:block>
                </fo:block-container>
                <xsl:call-template name="address"/>
            </fo:static-content>
            <fo:static-content flow-name="footer">
               <fo:block text-align="right">
                  Seite <fo:page-number/> von <fo:page-number-citation ref-id="LastPage"/>
               </fo:block>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body">
               <xsl:apply-templates/>
               <fo:block id="LastPage"/>
            </fo:flow>
         </fo:page-sequence>
      </fo:root>
   </xsl:template>
   
   <xsl:template name="address">
	  <fo:table table-layout="fixed" width="50%">
         <fo:table-body>
            <xsl:apply-templates select="current()/*" mode="call"/>
         </fo:table-body>
      </fo:table>
   </xsl:template>
   
   <xsl:template match="address/*" mode="call">
   	 <fo:table-row>
         <fo:table-cell>
            <fo:block>
              <xsl:value-of select="."/>
            </fo:block>
         </fo:table-cell>
      </fo:table-row>
   </xsl:template>
   
   <xsl:template match="address/name" mode="call">
   	 <fo:table-row>
         <fo:table-cell>
            <fo:block>
              <xsl:value-of select="firstname"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="lastname"/>
            </fo:block>
         </fo:table-cell>
      </fo:table-row>
   </xsl:template>

   <!-- Rechnungsdaten-Template -->
   <xsl:template match="bill_data">
      <fo:block font-size="10pt" text-align="left">
          Rechnung: <xsl:value-of select="current()/num"/>
      </fo:block>
      <fo:block-container position="absolute">
          <fo:block font-size="10pt" text-align="right">
            Datum: <xsl:value-of select="current()/date"/>
          </fo:block>
      </fo:block-container>
      <fo:table margin-top="0.5cm" border-style="solid" table-layout="fixed" width="100%">
         <fo:table-column column-width="64%"/>
         <fo:table-column column-width="12%"/>
         <fo:table-column column-width="12%"/>
         <fo:table-column column-width="12%"/>
         <fo:table-header>
            <xsl:call-template name="table-head"/>
         </fo:table-header>
         <fo:table-body>
            <xsl:apply-templates select="position"/>
            
            <!-- Darstellung und Berechnung der Gesamtsumme -->
            <xsl:call-template name="sumProducts">
                <xsl:with-param name="pList" select="current()/position"/>
            </xsl:call-template>
         </fo:table-body>
      </fo:table>
   </xsl:template>
   
   <xsl:template name="sumProducts">
        <xsl:param name="pList"/>
        <xsl:param name="pAccum" select="0"/>

        <xsl:choose>
          <xsl:when test="$pList">
            <xsl:variable name="vHead" select="$pList[1]"/>

            <xsl:call-template name="sumProducts">
              <xsl:with-param name="pList" select="$pList[position() > 1]"/>
              <xsl:with-param name="pAccum"
               select="$pAccum + $vHead/value * $vHead/amount"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="sumView">
                <xsl:with-param name="sum" select="$pAccum"/>
                <xsl:with-param name="tax" select="round($pAccum * 0.19 * 100) div 100"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
   <xsl:template name="sumView">
   	  <xsl:param name="sum"/>
   	  <xsl:param name="tax"/>
      <fo:table-row>
        <fo:table-cell xsl:use-attribute-sets="cell-style" number-columns-spanned="3">
          <fo:block xsl:use-attribute-sets="block-style">
             Nettogesamt
          </fo:block>
        </fo:table-cell>
        <fo:table-cell xsl:use-attribute-sets="cell-style">
          <fo:block xsl:use-attribute-sets="block-style">
             <xsl:value-of select="translate(format-number($sum,'#.00'),'.',',')"/>
             <xsl:text> &#8364;</xsl:text>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
      <fo:table-row>
        <fo:table-cell xsl:use-attribute-sets="cell-style" number-columns-spanned="3">
          <fo:block xsl:use-attribute-sets="block-style">
             MwSt 19%
          </fo:block>
        </fo:table-cell>
        <fo:table-cell xsl:use-attribute-sets="cell-style">
          <fo:block xsl:use-attribute-sets="block-style">
             <xsl:value-of select="translate(format-number($tax,'#.00'),'.',',')"/>
             <xsl:text> &#8364;</xsl:text>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
      <fo:table-row>
        <fo:table-cell xsl:use-attribute-sets="cell-style" number-columns-spanned="3">
          <fo:block xsl:use-attribute-sets="block-style">
             Bruttogesamt
          </fo:block>
        </fo:table-cell>
        <fo:table-cell xsl:use-attribute-sets="cell-style">
          <fo:block xsl:use-attribute-sets="block-style">
             <xsl:value-of select="translate(format-number($sum + $tax,'#.00'),'.',',')"/>
             <xsl:text> &#8364;</xsl:text>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
   </xsl:template>
   
   <!-- Tabellenkopf -->
   <xsl:template name="table-head">
      <fo:table-row>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">Aufwandsbeschreibung</fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">Menge</fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">EP</fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">GP</fo:block>
         </fo:table-cell>
      </fo:table-row>
   </xsl:template>
   
   <!-- Template der 'position'-Elemente -->
   <xsl:template match="position">
      <fo:table-row>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">
               <xsl:value-of select="title"/>
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">
               <xsl:value-of select="amount"/>
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">
               <xsl:value-of select="translate(value,'.',',')"/>
               <xsl:text> &#8364;</xsl:text>
            </fo:block>
         </fo:table-cell>
         <fo:table-cell xsl:use-attribute-sets="cell-style">
            <fo:block xsl:use-attribute-sets="block-style">
               <xsl:value-of select="format-number(number(value) * number(amount),'#.00')"/>
               <xsl:text> &#8364;</xsl:text>
            </fo:block>
         </fo:table-cell>
      </fo:table-row>
   </xsl:template>

</xsl:stylesheet>