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
                <xsl:call-template name="CorporateActionMovementPreliminaryAdviceReport"/>
                <xsl:call-template name="printFloor"/>
            </body>
        </html>
    </xsl:template>
    
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!-- Шаблоны для CAPAR (Corporate Action Movement Preliminary Advice Report)-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <xsl:template name="CorporateActionMovementPreliminaryAdviceReport">
        <xsl:call-template name="CorporateActionDetails"/>
        <xsl:call-template name="Security">
            <xsl:with-param name="path" select="CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/CorpActnGnlInf/UndrlygScty/FinInstrmId"/>
        </xsl:call-template>        
        <xsl:call-template name="CAPAR_AcctList"/>        
        <xsl:for-each select="CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/MvmntRprt">
            <xsl:call-template name="CAPAR_CaMvmntRprt">
                <xsl:with-param name="path" select="."/>
            </xsl:call-template>
            <xsl:call-template name="CACO_CorporateActionVariant">
                <xsl:with-param name="path" select="./CorpActnMvmntDtls"/>
            </xsl:call-template>        
            <xsl:call-template name="CACO_ActionPeriod">
                <xsl:with-param name="path" select="./CorpActnMvmntDtls/PrdDtls/ActnPrd/Prd"/>
            </xsl:call-template> 
            <xsl:for-each select="./CorpActnMvmntDtls/SctiesMvmntDtls">
                <xsl:call-template name="CACO_SecuritiyMovement">
                    <xsl:with-param name="path" select="./SctyDtls"/>
                </xsl:call-template> 
            </xsl:for-each>            
        </xsl:for-each>        
        <xsl:call-template name="CAPAR_Registrar"/>    
    </xsl:template>
    
    <!--Информация об остатках ценных бумаг на счете депо-->
    <xsl:template name="CAPAR_AcctList">
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CAPAR_AcctList</xsl:with-param>
        </xsl:call-template>

        <!--Вычисление значений-->
        <xsl:variable name="СчетДепо" select="CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/AcctsListAndBalDtls/SfkpgAcct"/>
        <xsl:variable name="Остаток" select="CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/AcctsListAndBalDtls/Bal/TtlElgblBal/QtyChc/SgndQty/Qty/Unit"/>
        <!--Рендеринг-->
        <xsl:if test="string-length($СчетДепо) &gt; 0 or
		string-length($Остаток) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Информация об остатках ценных бумаг на счете депо</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Счет депо</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$СчетДепо"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Остаток</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$Остаток"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>
    
    <!--Ведомость предварительных извещений о движении-->
    <xsl:template name="CAPAR_CaMvmntRprt">
        <xsl:param name="path"/>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CAPAR_CaMvmntRprt</xsl:with-param>
        </xsl:call-template>

        <!--Вычисление значений-->
        <xsl:variable name="РеференсВедомости" select="$path/SfkpgAcct"/>
        <xsl:variable name="РеференсИнструкции" select="$path/InstrId/Id"/>
            
        <!--Рендеринг-->
        <xsl:if test="string-length($РеференсВедомости) &gt; 0 or
		string-length($РеференсИнструкции) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Ведомость предварительных извещений о движении</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Референс ведомости</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$РеференсВедомости"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Референс инструкции</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$РеференсИнструкции"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>
    
    <!--Регистратор-->
    <xsl:template name="CAPAR_Registrar">
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CAPAR_Registrar</xsl:with-param>
        </xsl:call-template>

        <!--Вычисление значений-->
        <xsl:variable name="Наименование" select="CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/Regar/NmAndAdr/Nm"/>
        <xsl:variable name="Адрес" select="CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/Regar/NmAndAdr/Adr/AdrLine"/>
        <!--Рендеринг-->
        <xsl:if test="string-length($Наименование) &gt; 0 or
		string-length($Адрес) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Регистратор</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Наименование</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$Наименование"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Адрес</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$Адрес"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>