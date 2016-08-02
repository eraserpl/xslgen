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
                <xsl:call-template name="SystemEventNotification"/>
                <xsl:call-template name="printFloor"/>
            </body>
        </html>
    </xsl:template>
    
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!-- Шаблоны для SEN (System Event Notification)-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <xsl:template name="SystemEventNotification">
        <xsl:call-template name="SEN"/><!--Уведомление о системном событии-->
    </xsl:template>
    
    <xsl:template name="SEN">
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">SEN</xsl:with-param>
        </xsl:call-template>

        <!--Вычисление значений-->
        <xsl:variable name="КодСобытия" select="SystemEventNotification/Document/EvtInf/EvtCd"/>
        <xsl:variable name="ПараметрСобытия" select="SystemEventNotification/Document/EvtInf/EvtParam"/>
        <xsl:variable name="ВремяСобытия" select="SystemEventNotification/Document/EvtInf/EvtTm"/>

        <!--Рендеринг-->
        <xsl:if test="string-length($КодСобытия) &gt; 0 or
                string-length($ПараметрСобытия) &gt; 0 or
                string-length($ВремяСобытия) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Уведомление о системном событии</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Код события</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$КодСобытия"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Параметр события</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ПараметрСобытия"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Время события</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ВремяСобытия"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>    
    </xsl:template>
</xsl:stylesheet>