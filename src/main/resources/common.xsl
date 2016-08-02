<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:msxsl="http://exslt.org/common" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.nrd.ru" version="1.0">
    
    <!-- 
        в зависимости от xslt движка, возможно необходимо заменить атрибут xmlns:msxsl скрипта на один из двух ниже 
xmlns:msxsl="urn:schemas-microsoft-com:xslt"
xmlns:msxsl="http://exslt.org/common"     
   -->

    <!-- Тип вывода -->
    <xsl:output method="html" doctype-public="html" encoding="UTF-8"/>

    <!--  Если вызвать скрипт с этим параметром, установленным в true, то в html выведется доп. отладочная информация  -->
    <xsl:param name="debug">true1</xsl:param>

    <!--Использовать внешний css-->
    <xsl:param name="useExternalCss">true1</xsl:param>

    <!--  Версия скрипта  -->
    <xsl:variable name="version">41.1</xsl:variable>

    <!-- История изменений 41.2 -->

    <!--Глобальные переменные-->
    <xsl:variable name="br">&lt;br/&gt;</xsl:variable>
    <xsl:variable name="xsd" select="document('iso20022.xsd')"/>
    <xsl:variable name="root" select="((/*[name()!='xml-stylesheet']))[1]"/>
    <xsl:variable name="rootName" select="name(((/*[name()!='xml-stylesheet'])/*)[1])"/>
    <xsl:variable name="formCode">
        <xsl:choose>
            <xsl:when test="//BizSvc">
                <xsl:value-of select="//BizSvc"/>
            </xsl:when>
            <xsl:when test="//MsgDefIdr">
                <xsl:value-of select="//MsgDefIdr"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="title">
        <xsl:call-template name="getGlobalVars">
            <xsl:with-param name="varName">title</xsl:with-param>
            <xsl:with-param name="formCode" select="$formCode"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="operationName">
        <xsl:call-template name="getGlobalVars">
            <xsl:with-param name="varName">operationName</xsl:with-param>
            <xsl:with-param name="formCode" select="$formCode"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="codeName">
        <xsl:call-template name="getGlobalVars">
            <xsl:with-param name="varName">codeName</xsl:with-param>
            <xsl:with-param name="formCode" select="$formCode"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="senterCode">
        <xsl:choose>
            <xsl:when test="//Fr/OrgId/Id/OrgId/Othr/Id">
                <xsl:value-of select="//Fr/OrgId/Id/OrgId/Othr/Id"/>
            </xsl:when>
            <xsl:when test="//Fr/OrgId/Id/PrvtId/Othr/Id">
                <xsl:value-of select="//Fr/OrgId/Id/PrvtId/Othr/Id"/>
            </xsl:when>
            <xsl:when test="//Fr/FIId/FinInstnId/Othr/Id">
                <xsl:value-of select="//Fr/FIId/FinInstnId/Othr/Id"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="senderName">
        <xsl:choose>
            <xsl:when test="//Fr/FIId/FinInstnId/Nm">
                <xsl:value-of select="//Fr/FIId/FinInstnId/Nm"/>
            </xsl:when>
            <xsl:when test="//Fr/OrgId/Nm">
                <xsl:value-of select="//Fr/OrgId/Nm"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="receiverCode">
        <xsl:choose>
            <xsl:when test="//To/OrgId/Id/OrgId/Othr/Id">
                <xsl:value-of select="//To/OrgId/Id/OrgId/Othr/Id"/>
            </xsl:when>
            <xsl:when test="//To/OrgId/Id/PrvtId/Othr/Id">
                <xsl:value-of select="//To/OrgId/Id/PrvtId/Othr/Id"/>
            </xsl:when>
            <xsl:when test="//To/FIId/FinInstnId/Othr/Id">
                <xsl:value-of select="//To/FIId/FinInstnId/Othr/Id"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="receiverName">
        <xsl:choose>
            <xsl:when test="//To/OrgId/Nm">
                <xsl:value-of select="//To/OrgId/Nm"/>
            </xsl:when>
            <xsl:when test="//To/FIId/FinInstnId/Nm">
                <xsl:value-of select="//To/FIId/FinInstnId/Nm"/>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="number" select="//BizMsgIdr"/>
    <xsl:variable name="creationTime" select="//CreDt"/>

    <xsl:template name="header">
        <xsl:call-template name="fSetStyle"/>

        <!--выводим версию скрипта в html, чтобы тестировщики могли прикладывать её к талону-->
        <xsl:comment>#<xsl:value-of select="$version"/>
        </xsl:comment>

        <!--Вывод шапки-->
        <xsl:call-template name="printHat"/>
    </xsl:template>

    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!-- Общие блоки -->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->

    <!--Реквизиты корпоративного действия-->
    <xsl:template name="CorporateActionDetails">
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CorporateActionDetails</xsl:with-param>
        </xsl:call-template>

        <!--Вычисление значений-->
        <xsl:variable name="РеференсКорпоративногоДействия" select="//CorpActnEvtId"/>
        <xsl:variable name="КодТипаКД" select="//EvtTp/Cd"/>

        <!--Рендеринг-->
        <xsl:if
                test="string-length($РеференсКорпоративногоДействия) &gt; 0 or
            string-length($КодТипаКД) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Реквизиты корпоративного действия</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Референс корпоративного действия</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$РеференсКорпоративногоДействия"
                                />
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Код типа корпоративного действия</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$КодТипаКД"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>

    <!-- Ценная бумага (Передавать FinInstrmId) -->
    <xsl:template name="Security">
        <xsl:param name="path"/>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">Security</xsl:with-param>
        </xsl:call-template>

        <!--Вычисление значений-->
        <xsl:variable name="Наименование">
            <xsl:call-template name="fValueAfter3rdHash">
                <xsl:with-param name="value"
                                select="$path/Desc"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ISIN"
                      select="$path/ISIN"/>
        <xsl:variable name="ДепозитарныйКод"
                      select="$path/OthrId/Id[../Tp/Prtry = 'NSDR']"/>
        <xsl:variable name="ГосРегНомерИдентификационныйКод"
                      select="$path/OthrId/Id[../Tp/Prtry = 'RU']"/>

        <!--Рендеринг-->
        <xsl:if
                test="string-length($Наименование) &gt; 0 or
            string-length($ISIN) &gt; 0 or
            string-length($ДепозитарныйКод) &gt; 0 or
            string-length($ГосРегНомерИдентификационныйКод) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Ценная бумага</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Депозитарный код</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ДепозитарныйКод"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">ISIN</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ISIN"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Гос. рег. номер/ идентификационный код</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ГосРегНомерИдентификационныйКод"
                                />
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Наименование</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$Наименование"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>
    
    <!--Вариант корпоративного действия-->
    <xsl:template name="CACO_CorporateActionVariant">
        <xsl:param name="path"/>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CACO_CorporateActionVariant</xsl:with-param>
        </xsl:call-template>

        <xsl:variable name="НомерВарианта" select="$path/OptnNb"/>
        <xsl:variable name="ПризнакВарианта" select="$path/OptnTp/Cd"/>
        <xsl:variable name="ДатаФиксации">
            <xsl:choose>
                <xsl:when test="$path/DtDtls/MktDdln/Dt/Dt">
                    <xsl:value-of select="$path/DtDtls/MktDdln/Dt/Dt"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$path/DtDtls/MktDdln/Dt/DtTm"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--Рендеринг-->
        <xsl:if
                test="string-length($НомерВарианта) &gt; 0 or
            string-length($ПризнакВарианта) &gt; 0 or
            string-length($ДатаФиксации) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Вариант корпоративного действия</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Номер Варианта</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$НомерВарианта"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Признак Варианта</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ПризнакВарианта"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Дата Фиксации</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ДатаФиксации"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>

    <!--Период действия-->
    <xsl:template name="CACO_ActionPeriod">
        <xsl:param name="path"/>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CACO_ActionPeriod</xsl:with-param>
        </xsl:call-template>

        <xsl:variable name="ДатаНачала">
            <xsl:choose>
                <xsl:when test="$path/StartDt/Dt/Dt">
                    <xsl:value-of select="$path/StartDt/Dt/Dt"/>
                </xsl:when>
                <xsl:when test="$path/StartDt/Dt/DtTm">
                    <xsl:value-of select="$path/StartDt/Dt/DtTm"/>
                </xsl:when>
                <xsl:when test="$path/StartDt/Dt/NotSpcfdDt">
                    <xsl:text>Дата не определена</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ДатаОкончания">
            <xsl:choose>
                <xsl:when test="$path/EndDt/Dt/Dt">
                    <xsl:value-of select="$path/StartDt/Dt/Dt"/>
                </xsl:when>
                <xsl:when test="$path/EndDt/Dt/DtTm">
                    <xsl:value-of select="$path/StartDt/Dt/DtTm"/>
                </xsl:when>
                <xsl:when test="$path/EndDt/Dt/NotSpcfdDt">
                    <xsl:text>Дата не определена</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ПериодДействия">
            <xsl:if test="$path/PrdCd">
                <xsl:call-template name="fGetEnumDescriptionFromXsd">
                    <xsl:with-param name="value" select="$path/PrdCd"/>
                    <xsl:with-param name="simpleTypeName">DateType8Code</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:variable>

        <!--Рендеринг-->
        <xsl:if
                test="string-length($ДатаНачала) &gt; 0 or
            string-length($ДатаОкончания) &gt; 0 or
            string-length($ПериодДействия) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Период действия</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                        <xsl:when test="string-length($ПериодДействия) &gt; 0">
                            <xsl:call-template name="fRenderNameValueTableRow">
                                <xsl:with-param name="name">Период Действия</xsl:with-param>
                                <xsl:with-param name="scalarValue" select="$ПериодДействия"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="fRenderNameValueTableRow">
                                <xsl:with-param name="name">Дата Начала</xsl:with-param>
                                <xsl:with-param name="scalarValue" select="$ДатаНачала"/>
                            </xsl:call-template>
                            <xsl:call-template name="fRenderNameValueTableRow">
                                <xsl:with-param name="name">Дата Окончания</xsl:with-param>
                                <xsl:with-param name="scalarValue" select="$ДатаОкончания"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>

    <!--Движение ценных бумаг-->
    <xsl:template name="CACO_SecuritiyMovement">
        <xsl:param name="path"/>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CACO_SecuritiesMovement</xsl:with-param>
        </xsl:call-template>

        <xsl:variable name="ISIN">
            <xsl:value-of select="$path/FinInstrmId/ISIN"/>
        </xsl:variable>
        <xsl:variable name="НаимЦенБумаги">
            <xsl:call-template name="fValueAfter3rdHash">
                <xsl:with-param name="value" select="$path/FinInstrmId/Desc"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ДепозитарныйКод"
                      select="$path/FinInstrmId/OthrId/Id[../Tp/Prtry = 'NSDR']"/>
        <xsl:variable name="ГосРегНомерИдентификационныйКод"
                      select="$path/FinInstrmId/OthrId/Id[../Tp/Prtry = 'RU']"/>
        <xsl:variable name="ДатаВыпуска" select="$path/SctyDtls/IsseDt"/>
        <xsl:variable name="priceDtlsCount">
            <xsl:value-of select="count($path/PricDtls/*)"/>
        </xsl:variable>
        <xsl:variable name="ДатаПлатежа">
            <xsl:call-template name="getPayDate">
                <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ЗачислениеСписание">
            <xsl:call-template name="getEnrollCancel">
                <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>

        <!--Рендеринг-->
        <xsl:if
                test="string-length($НаимЦенБумаги) &gt; 0
            or string-length($ISIN) &gt; 0
            or count($ДепозитарныйКод) &gt; 0
            or count($ГосРегНомерИдентификационныйКод) &gt; 0
            or string-length($ДатаВыпуска) &gt; 0
            or $priceDtlsCount &gt; 0
            or string-length($ДатаПлатежа) &gt; 0
            or string-length($ЗачислениеСписание) &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Движение ценных бумаг</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:if test="string-length($ISIN) &gt; 0">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">ISIN</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$ISIN"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="string-length($НаимЦенБумаги) &gt; 0">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Наименование ценной бумаги</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$НаимЦенБумаги"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="count($ДепозитарныйКод) &gt; 0">
                        <xsl:for-each select="$ДепозитарныйКод">
                            <xsl:call-template name="fRenderNameValueTableRow">
                                <xsl:with-param name="name">Депозитарный Код</xsl:with-param>
                                <xsl:with-param name="scalarValue">
                                    <xsl:value-of select="."/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="count($ГосРегНомерИдентификационныйКод) &gt; 0">
                        <xsl:for-each select="$ГосРегНомерИдентификационныйКод">
                            <xsl:call-template name="fRenderNameValueTableRow">
                                <xsl:with-param name="name">Гос рег. номер/идентификационный
                                    код</xsl:with-param>
                                <xsl:with-param name="scalarValue">
                                    <xsl:value-of select="."/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="string-length($ДатаВыпуска) &gt; 0">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Дата выпуска</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$ДатаВыпуска"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="$priceDtlsCount &gt; 0">
                        <xsl:call-template name="printPriceDetails">
                            <xsl:with-param name="path" select="$path"/>
                            <xsl:with-param name="priceDtlsCount" select="$priceDtlsCount"/>
                            <xsl:with-param name="nameField" select="'Цена выпуска'"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="string-length($ДатаПлатежа) &gt; 0">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Дата платежа</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$ДатаПлатежа"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="string-length($ЗачислениеСписание) &gt; 0">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Зачисление/списание</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$ЗачислениеСписание"/>
                        </xsl:call-template>
                    </xsl:if>

                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>

    <!--Движение денежных средств-->
    <xsl:template name="CACO_CashMovement">
        <xsl:param name="path"/>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value">CACO_CashMovement</xsl:with-param>
        </xsl:call-template>
        
        <xsl:variable name="ЗачислениеСписание">
            <xsl:call-template name="getEnrollCancel">
                <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="ДатаПлатежа">
            <xsl:call-template name="getPayDate">
                <xsl:with-param name="path" select="$path"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="СтавкаУдерживаемогоНалога">
            <xsl:choose>
                <xsl:when test="$path/RateAndAmtDtls/WhldgTaxRate/NotSpcfdRate">
                    <xsl:call-template name="fGetEnumDescriptionFromXsd">
                        <xsl:with-param name="value"
                            select="$path/RateAndAmtDtls/WhldgTaxRate/NotSpcfdRate"/>
                        <xsl:with-param name="simpleTypeName">RateValueType7Code</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$path/RateAndAmtDtls/WhldgTaxRate/Rate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="Комиссия">
            <xsl:choose>
                <xsl:when test="$path/RateAndAmtDtls/ChrgsFees/NotSpcfdRate">
                    <xsl:call-template name="fGetEnumDescriptionFromXsd">
                        <xsl:with-param name="value"
                            select="$path/RateAndAmtDtls/ChrgsFees/NotSpcfdRate"/>
                        <xsl:with-param name="simpleTypeName">RateValueType7Code</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$path/RateAndAmtDtls/ChrgsFees/Rate">
                            <xsl:value-of select="$path/RateAndAmtDtls/ChrgsFees/Rate"/>
                        </xsl:when>
                        <xsl:when test="$path/RateAndAmtDtls/ChrgsFees/Amt">
                            <xsl:value-of select="$path/RateAndAmtDtls/ChrgsFees/Amt"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ПрименяемаяСтавка">
            <xsl:choose>
                <xsl:when test="$path/RateAndAmtDtls/AplblRate/NotSpcfdRate">
                    <xsl:call-template name="fGetEnumDescriptionFromXsd">
                        <xsl:with-param name="value"
                            select="$path/RateAndAmtDtls/AplblRate/NotSpcfdRate"/>
                        <xsl:with-param name="simpleTypeName">RateValueType7Code</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$path/RateAndAmtDtls/AplblRate/Rate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="priceDtlsCount">
            <xsl:value-of select="count($path/PricDtls/*)"/>
        </xsl:variable>
        
        <!--Рендеринг-->
        <xsl:if
            test="string-length($ЗачислениеСписание) &gt; 0 or
            string-length($ДатаПлатежа) &gt; 0 or
            string-length($СтавкаУдерживаемогоНалога) &gt; 0 or
            string-length($Комиссия) &gt; 0 or
            string-length($ПрименяемаяСтавка) &gt; 0 or
            $priceDtlsCount &gt; 0">
            <table>
                <xsl:call-template name="fSetStyle">
                    <xsl:with-param name="name">table</xsl:with-param>
                </xsl:call-template>
                <thead>
                    <tr>
                        <th colspan="2">Движение денежных средств</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Зачисление/списание</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ЗачислениеСписание"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Дата Платежа</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ДатаПлатежа"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Ставка Удерживаемого Налога</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$СтавкаУдерживаемогоНалога"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Комиссия</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$Комиссия"/>
                    </xsl:call-template>
                    <xsl:call-template name="fRenderNameValueTableRow">
                        <xsl:with-param name="name">Применяемая Ставка</xsl:with-param>
                        <xsl:with-param name="scalarValue" select="$ПрименяемаяСтавка"/>
                    </xsl:call-template>
                    <xsl:call-template name="printPriceDetails">
                        <xsl:with-param name="path" select="$path"/>
                        <xsl:with-param name="priceDtlsCount" select="$priceDtlsCount"/>
                        <xsl:with-param name="nameField" select="'Цена'"/>
                    </xsl:call-template>
                </tbody>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>
    
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!-- Общие шаблоны -->
    <!--=======================================================================================-->
    <!--=======================================================================================-->
    <!--=======================================================================================-->

    <!--Добавление классов и стилей к html элементу, имена классов перечисляются через пробел-->
    <xsl:template name="fSetStyle">
        <xsl:param name="name"/>

        <xsl:attribute name="class">printform</xsl:attribute>

        <!--Дополнительная кастомизация для некотрых элементов-->
        <xsl:choose>
            <xsl:when test="$name='table'">
                <xsl:attribute name="cellspacing">1</xsl:attribute>
                <xsl:attribute name="cellpadding">0</xsl:attribute>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <!--Вывод head-->
    <xsl:template name="htmlHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>
            <xsl:if test="$useExternalCss!='true'">
                <style type="text/css">

                    body.printform{
                    width:100%;
                    background-color:#ffffff;
                    font-family:Arial;
                    font-size: 10pt;
                    }

                    table.printform{
                    width:100%;
                    border: 1px black solid;
                    border-collapse:collapse;
                    }

                    table.printform td{
                    border: 1px black solid;
                    padding: 5px;
                    width: 50%;
                    }

                    table.printform tbody td{
                    }

                    table.printform tbody th{
                    background-color:#bbbbbb;
                    text-align:center;
                    font-weight: bold;
                    border: 1px black solid;
                    padding: 5px;
                    }

                    table.printform thead th{
                    background-color:#bbbbbb;
                    text-align:center;
                    font-weight: bold;
                    border: 1px black solid;
                    padding: 5px;
                    }

                    div.formCode{
                    text-align:right;
                    width:100%;
                    <!--background-color:#ffffee;-->
                    }

                    div.hat{
                    width:100%;
                    }

                    div.hat table{
                    width:100%;
                    }

                    div.hat table td.left{
                    width:8%;
                    }

                    div.hat table td.center{
                    width:15%;
                    }

                    div.hat table td.right{
                    width:70%;
                    }

                    div.title{
                    text-align:center;
                    width:100%;
                    <!--background-color:#ffffdd;-->
                    }

                    div.timestamp{
                    text-align:center;
                    width:100%;
                    font-size:15px;
                    }

                    table.footer{
                    width:100%;
                    border:0px;
                    font-size:12pt;
                    }

                    table.footer tbody td{
                    width:25%;
                    border:0px;
                    padding-top:10px;
                    }

                    div.debug{
                    color:#ff00ff;
                    font-size:9pt;
                    font-family:Courier New;
                    margin:10px 0 0 0;
                    }

                    span.debug{
                    color:#ff0000;
                    font-size:19pt;
                    font-family:Courier New;
                    margin:10px 0 0 0;
                    }

                    table.debug{
                    color:#ff00ff;
                    font-size:9pt;
                    font-family:Courier New;
                    border-collapse:collapse;
                    }
                    table.debug td.left{
                    text-align:left;
                    border:1px solid #ff00ff;
                    padding:5px 10px 5px 10px;
                    }

                    table.debug td.middle{
                    text-align:center;
                    border:1px solid #ff00ff;
                    padding:5px 10px 5px 10px;
                    }

                    table.debug td.right{
                    text-align:left;
                    border:1px solid #ff00ff;
                    padding:5px 10px 5px 10px;
                    }

                    td.border-bottom{
                    border-bottom:1px;
                    border-bottom-style:solid;
                    }

                    td.interlinear{
                    font-size:12px;
                    }

                    .under-line{
                    text-decoration:underline;
                    }

                    .border-dash{
                    border-bottom:2px black;
                    border-bottom-style:dashed;
                    }</style>
            </xsl:if>
        </head>
    </xsl:template>

    <!--Форматировать дату с заголовок-->
    <xsl:template name="dateHead">
        <xsl:param name="date"/>
        <xsl:variable name="D" select="substring-before($date,' ')"/>
        <xsl:variable name="MY" select="substring-after($date,' ')"/>
        <xsl:variable name="M" select="substring-before($MY,' ')"/>
        <xsl:variable name="YT" select="substring-after($MY,' ')"/>
        <xsl:variable name="Y" select="substring($YT,1,7)"/>
        <xsl:variable name="T" select="substring-after($YT,'г. ')"/> &#171; <span class="under-line">
        <xsl:value-of select="$D"/>
    </span> &#187; <span class="under-line">
        <xsl:value-of select="$M"/>
    </span>
        <xsl:text> </xsl:text>
        <xsl:value-of select="substring($Y,1,2)"/>
        <span class="under-line">
            <xsl:value-of select="substring($Y,3,2)"/>
        </span>
        <xsl:value-of select="substring($Y,5,3)"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$T"/>
    </xsl:template>

    <!--Печать шапки формы-->
    <xsl:template name="printHat">
        <div class="formCode">
            <p>
                <xsl:text>Форма </xsl:text>
                <span class="under-line">
                    <xsl:value-of select="$formCode"/>
                </span>
            </p>
        </div>

        <div class="title">
            <h1>
                <xsl:value-of select="$title"/>
                <xsl:text> № </xsl:text>
                <xsl:value-of select="$number"/>
            </h1>
        </div>

        <div class="timestamp">
            <xsl:text>от </xsl:text>
            <xsl:variable name="printDate">
                <xsl:call-template name="fPrintDate">
                    <xsl:with-param name="value" select="$creationTime"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:call-template name="dateHead">
                <xsl:with-param name="date" select="$printDate"/>
            </xsl:call-template>

        </div>
        <br/>
        <div class="hat">
            <table>
                <tbody>
                    <tr>
                        <td class="left">Отправитель</td>
                        <td class="center">
                            <span class="border-dash">
                                <xsl:value-of select="$senterCode"/>
                            </span>
                        </td>
                        <td class="rigth border-bottom">
                            <xsl:value-of select="$senderName"/>
                        </td>
                    </tr>
                    <tr>
                        <td/>
                        <td class="center interlinear">&#60;Код анкеты&#62;</td>
                        <td/>
                    </tr>
                    <tr>
                        <td class="left">Получатель</td>
                        <td class="center">
                            <span class="border-dash">
                                <xsl:value-of select="$receiverCode"/>
                            </span>
                        </td>
                        <td class="rigth border-bottom">
                            <xsl:value-of select="$receiverName"/>
                        </td>
                    </tr>
                    <tr>
                        <td/>
                        <td class="center interlinear">&#60;Код анкеты&#62;</td>
                        <td/>
                    </tr>
                </tbody>
            </table>
        </div>

    </xsl:template>

    <!--Вывод подвала-->
    <xsl:template name="printFloor">
        <table class="footer">
            <tbody>
                <tr align="center">
                    <td style="width:50%">
                        <div style="border-top:1px solid black;">(должность)</div>
                    </td>
                    <td style="padding-left:20px; padding-right:20px;width:25%">
                        <div style="border-top:1px solid black;">(Ф.И.О)</div>
                    </td>
                    <td style="width:25%">
                        <div style="border-top:1px solid black;">(подпись)</div>
                    </td>
                </tr>
                <tr align="right">
                    <td colspan="2" style="padding:10px">М.П.</td>
                </tr>
            </tbody>
        </table>
        <h2 style="font-style:italic">Заполняется работником Депозитария</h2>
        <hr/>
        <table class="footer">
            <tbody>
                <tr>
                    <td>Регистрационный номер документа</td>
                    <td>_____________________</td>
                    <td/>
                    <td/>
                </tr>
                <tr>
                    <td>Дата приема документа</td>
                    <td>«__» ____________ 20__г.</td>
                    <td>Дата ввода документа</td>
                    <td>«__» ____________ 20__г.</td>
                </tr>
                <tr>
                    <td>Время приема документа</td>
                    <td>_____________________</td>
                    <td/>
                    <td/>
                </tr>
                <tr>
                    <td>Операционист</td>
                    <td/>
                    <td>Оператор</td>
                    <td/>
                </tr>
                <tr>
                    <td colspan="2" style="padding-right:20px;padding-top:20px;">
                        <div style="border-top:1px solid black;"/>
                    </td>
                    <td colspan="2" style="padding-top:20px;">
                        <div style="border-top:1px solid black;"/>
                    </td>
                </tr>
                <tr>
                    <td style="padding-top:40px;">Подпись</td>
                    <td/>
                    <td style="padding-top:40px;">Подпись</td>
                    <td/>
                </tr>
                <tr>
                    <td>
                        <div style="float:right">________________</div>
                    </td>
                    <td/>
                    <td>
                        <div style="float:right">________________</div>
                    </td>
                    <td/>
                </tr>
                <tr>
                    <td>М.П.</td>
                    <td/>
                    <td/>
                    <td/>
                </tr>
            </tbody>
        </table>
    </xsl:template>

    <!--Рендерит строку таблицы из двух колонок-->
    <xsl:template name="fRenderNameValueTableRow">
        <xsl:param name="name"/>
        <xsl:param name="scalarValue"/>
        <!--Передаётся для вывода одного значения-->
        <xsl:param name="nodeSet"/>
        <!--Передаётся для вывода массива-->
        <xsl:param name="drawIfEmptyValue">false</xsl:param>

        <xsl:choose>
            <!--Выводим единичное значение, если оно передано-->
            <xsl:when test="$scalarValue">
                <xsl:if test="string-length($scalarValue) &gt; 0 or $drawIfEmptyValue='true'">
                    <tr>
                        <td>
                            <xsl:value-of select="$name"/>
                        </td>
                        <td>
                            <xsl:value-of select="$scalarValue"/>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:when>

            <!--Если не передано единичное значение, но передан массив, то выводим его-->
            <xsl:when test="$nodeSet">
                <tr>
                    <td>
                        <xsl:value-of select="$name"/>
                    </td>
                    <td>
                        <xsl:value-of select="$scalarValue"/>
                        <xsl:for-each select="msxsl:node-set($nodeSet)">
                            <xsl:value-of select="."/>
                            <xsl:if test="position()!=count(msxsl:node-set($nodeSet))">
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <!--Вывод отладочной информации-->
    <xsl:template name="fTrace">
        <xsl:param name="value"/>
        <xsl:if test="$debug='true'">
            <div class="debug">
                <xsl:copy-of select="$value"/>
            </div>
        </xsl:if>
    </xsl:template>

    <!--Печать br-->
    <xsl:template name="fBr">
        <xsl:value-of disable-output-escaping="yes" select="$br"/>
    </xsl:template>

    <xsl:template name="fValueBefore1stHash">
        <xsl:param name="value"/>
        <xsl:value-of select="substring-before($value,'#')"/>
    </xsl:template>

    <xsl:template name="fValueBetween1and2Hashs">
        <xsl:param name="value"/>
        <xsl:value-of select="substring-before(substring-after($value,'#'),'#')"/>
    </xsl:template>

    <xsl:template name="fValueBetween2and3Hashs">
        <xsl:param name="value"/>
        <xsl:value-of
                select="substring-before(substring-after(substring-after($value,'#'),'#'),'#')"/>
    </xsl:template>

    <xsl:template name="fValueAfter3rdHash">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="contains($value,'#')">
                <xsl:value-of
                        select="substring-after(substring-after(substring-after($value,'#'),'#'),'#')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--Из схемы достаёт расшифровку кода. Находит нужным simpleType с enum-ом, там ищёт нужное значение и берёт его аннотацию-->
    <xsl:template name="fGetEnumDescriptionFromXsd">
        <xsl:param name="simpleTypeName"/>
        <xsl:param name="value"/>
        <xsl:param name="annotationSource">PRNT</xsl:param>

        <xsl:variable name="trimValue">
            <xsl:call-template name="string-trim">
                <xsl:with-param name="string">
                    <xsl:value-of select="$value"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$trimValue"/>
        <xsl:text> - </xsl:text>
        <xsl:value-of
                select="$xsd//xsd:simpleType[@name=$simpleTypeName]//xsd:enumeration[@value=$trimValue]//xsd:documentation[@source=$annotationSource and @xml:lang='Rus']"
                />
    </xsl:template>

    <xsl:template name="fPrintDate">
        <xsl:param name="value"/>
        <xsl:param name="dateonly"/>
        <xsl:param name="utc"/>
        <xsl:param name="name"/>
        <xsl:choose>
            <xsl:when test="$value='UKWN'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">Неизвестно</xsl:with-param>
                    <xsl:with-param name="en">Unknown</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$value='ONGO'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">Определяется в процессе</xsl:with-param>
                    <xsl:with-param name="en">Ongoing</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$value and string-length($value)&gt;0">
                <xsl:choose>
                    <!-- Если это datetime -->
                    <xsl:when test="string-length($value)&gt;10">
                        <xsl:choose>
                            <xsl:when test="contains($value,'T')">
                                <xsl:variable name="date" select="substring-before($value,'T')"/>
                                <xsl:if test="string-length($date) &gt; 0">
                                    <xsl:call-template name="fPrintDate10chars">
                                        <xsl:with-param name="date" select="$date"/>
                                    </xsl:call-template>
                                </xsl:if>
                                <xsl:variable name="time" select="substring-after($value,'T')"/>
                                <xsl:if test="string-length($time) &gt; 0">
                                    <xsl:text> </xsl:text>
                                    <xsl:if test="$time!='00:00:00' and $dateonly!='true'">
                                        <xsl:call-template name="fPrintTime">
                                            <xsl:with-param name="time" select="$time"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="contains($value,' ')">
                                <xsl:variable name="date" select="substring-before($value,' ')"/>
                                <xsl:call-template name="fPrintDate10chars">
                                    <xsl:with-param name="date" select="$date"/>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="fPrintDate10chars">
                            <xsl:with-param name="date" select="$value"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:call-template name="fTrace">
            <xsl:with-param name="value" select="$name"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="fPrintTime">
        <xsl:param name="time"/>
        <xsl:variable name="H" select="substring-before($time,':')"/>
        <xsl:variable name="MS" select="substring-after($time,':')"/>
        <xsl:variable name="M" select="substring-before($MS,':')"/>
        <xsl:variable name="S" select="substring-after($MS,':')"/>
        <xsl:value-of select="$H"/>
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$M"/>
    </xsl:template>
    <xsl:template name="fPrintDate10chars">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="contains($date, '-')">
                <xsl:call-template name="fPrintDate10chars-hyphen">
                    <xsl:with-param name="date" select="$date"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($date, '.')">
                <xsl:call-template name="fPrintDate10chars-dots">
                    <xsl:with-param name="date" select="$date"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="fPrintDate10chars-hyphen">
        <xsl:param name="date"/>
        <xsl:variable name="Y" select="substring-before($date,'-')"/>
        <xsl:variable name="MD" select="substring-after($date,'-')"/>
        <xsl:variable name="M" select="substring-before($MD,'-')"/>
        <xsl:variable name="D" select="substring-after($MD,'-')"/>
        <xsl:value-of select="$D"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="$M='01'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">января</xsl:with-param>
                    <xsl:with-param name="en">jan</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='02'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">февраля</xsl:with-param>
                    <xsl:with-param name="en">feb</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='03'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">марта</xsl:with-param>
                    <xsl:with-param name="en">march</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='04'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">апреля</xsl:with-param>
                    <xsl:with-param name="en">april</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='05'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">мая</xsl:with-param>
                    <xsl:with-param name="en">may</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='06'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">июня</xsl:with-param>
                    <xsl:with-param name="en">june</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='07'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">июля</xsl:with-param>
                    <xsl:with-param name="en">july</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='08'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">августа</xsl:with-param>
                    <xsl:with-param name="en">aug</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='09'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">сентября</xsl:with-param>
                    <xsl:with-param name="en">sep</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='10'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">октября</xsl:with-param>
                    <xsl:with-param name="en">oct</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='11'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">ноября</xsl:with-param>
                    <xsl:with-param name="en">nov</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='12'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">декабря</xsl:with-param>
                    <xsl:with-param name="en">dec</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$Y"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="fRuen">
            <xsl:with-param name="ru">г.</xsl:with-param>
            <xsl:with-param name="en"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="fPrintDate10chars-dots">
        <xsl:param name="date"/>
        <xsl:variable name="D" select="substring-before($date,'.')"/>
        <xsl:variable name="MY" select="substring-after($date,'.')"/>
        <xsl:variable name="Y" select="substring-after($MY,'.')"/>
        <xsl:variable name="M" select="substring-before($MY,'.')"/>

        <xsl:value-of select="$D"/>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="$M='01'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">января</xsl:with-param>
                    <xsl:with-param name="en">jan</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='02'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">февраля</xsl:with-param>
                    <xsl:with-param name="en">feb</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='03'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">марта</xsl:with-param>
                    <xsl:with-param name="en">march</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='04'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">апреля</xsl:with-param>
                    <xsl:with-param name="en">april</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='05'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">мая</xsl:with-param>
                    <xsl:with-param name="en">may</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='06'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">июня</xsl:with-param>
                    <xsl:with-param name="en">june</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='07'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">июля</xsl:with-param>
                    <xsl:with-param name="en">july</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='08'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">августа</xsl:with-param>
                    <xsl:with-param name="en">aug</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='09'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">сентября</xsl:with-param>
                    <xsl:with-param name="en">sep</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='10'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">октября</xsl:with-param>
                    <xsl:with-param name="en">oct</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='11'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">ноября</xsl:with-param>
                    <xsl:with-param name="en">nov</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$M='12'">
                <xsl:call-template name="fRuen">
                    <xsl:with-param name="ru">декабря</xsl:with-param>
                    <xsl:with-param name="en">dec</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$Y"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="fRuen">
            <xsl:with-param name="ru">г.</xsl:with-param>
            <xsl:with-param name="en"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="fRuen">
        <xsl:param name="ru"/>
        <xsl:param name="en"/>
        <xsl:value-of select="$ru"/>
        <!--<xsl:choose>
            <xsl:when test="$lang='en'">
                <xsl:value-of select="$en"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$ru"/>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>

    <xsl:template name="getGlobalVars">
        <xsl:param name="formCode"/>
        <xsl:param name="varName"/>

        <xsl:choose>
            <xsl:when test="$formCode='CA021'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление об отмене собрания</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA011'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление о собрании по существенному факту</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA012'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Сообщение о собрании</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA013'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Напоминание о собрании</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA014'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Информация из бюллетеня</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA081'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление об итогах собрания по существенному факту</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA082'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление об итогах собрания</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA311'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление о КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA312'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Напоминание о КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA391'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление об отмене КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA351'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Предварительное извещение о движении</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA061'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Статус инструкции по собранию</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA044'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Указание о голосовании;</xsl:text>
                    </xsl:when>
                    <xsl:when test="$varName='operationName'">
                        <xsl:text>Участие в собрании</xsl:text>
                    </xsl:when>
                    <xsl:when test="$varName='codeName'">
                        <xsl:text>68/MEET</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA045'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Список лиц, осуществляющих права по ценным бумагам</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='SN041'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление о приеме сообщения</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='AM021'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление об отказе в приеме сообщения</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='SN042'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Сообщение о присвоении НРД референса КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA331'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Инструкция по КД</xsl:text>
                    </xsl:when>
                    <xsl:when test="$varName='codeName'">
                        <xsl:text>68/CAIN</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA401'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Запрос на отмену инструкции по КД</xsl:text>
                    </xsl:when>
                    <xsl:when test="$varName='codeName'">
                        <xsl:text>68/CAIC</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA411'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление о статусе запроса на отмену инструкции по КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA341'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Статус инструкции по КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA342'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Отчет о приеме информации о владельцах ценных бумаг по запросу Депозитария</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA321'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Сообщение о статусе КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA361'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Подтверждение движения ценных бумаг по КД</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='ND001'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Ведомость предварительных извещений о движении по КД BIDS и TEND</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='ND003'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Ведомость предварительных извещений о движении по КД PRIO</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='ND002'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Статус ведомости предварительных извещений о движении</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='ND004'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Требование созыва</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='ND005'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Статус требования созыва</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA381'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Сообщение свободного формата</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='CA382'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Сообщение об оплате</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='SM151'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Сообщение об исполнении инструкции на сохранение блокировки или на отмену сохранения
                    блокировки ц/б
                </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='SM131'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Инструкция на сохранение блокировки</xsl:text>
                    </xsl:when>
                    <xsl:when test="$varName='operationName'">
                        <xsl:text>Арест ценных бумаг в депозитарии Депонента</xsl:text>
                    </xsl:when>
                    <xsl:when test="$varName='codeName'">
                        <xsl:text>80/3</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$formCode='SM141'">
                <xsl:choose>
                    <xsl:when test="$varName='title'">
                        <xsl:text>Уведомление о статусе инструкции на сохранение блокировки;</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$formCode"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--    Печать деталей по ценам-->
    <xsl:template name="printPriceDetails">
        <xsl:param name="path"/>
        <xsl:param name="priceDtlsCount"/>
        <xsl:param name="nameField"/>

        <xsl:if test="$priceDtlsCount &gt; 0">
            <xsl:for-each select="$path/PricDtls/*">
                <xsl:choose>
                    <xsl:when test="./PctgPric/PricVal">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Цена в процентах</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="./PctgPric/PricVal"/>
                        </xsl:call-template>
                        <xsl:variable name="scalarValue">
                            <xsl:call-template name="fGetEnumDescriptionFromXsd">
                                <xsl:with-param name="value" select="./PctgPric/PctgPricTp"/>
                                <xsl:with-param name="simpleTypeName"
                                        >PriceRateType3Code</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Код типа процентов</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$scalarValue"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./AmtPric/PricVal">
                        <xsl:variable name="PricVal">
                            <xsl:value-of select="./AmtPric/PricVal"/>
                        </xsl:variable>
                        <xsl:variable name="Ccy">
                            <xsl:value-of select="./AmtPric/PricVal/@Ccy"/>
                        </xsl:variable>
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name" select="$nameField"/>
                            <xsl:with-param name="scalarValue">
                                <xsl:value-of select="concat($PricVal, ' ', $Ccy)"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:variable name="scalarValue">
                            <xsl:call-template name="fGetEnumDescriptionFromXsd">
                                <xsl:with-param name="value" select="./AmtPric/AmtPricTp"/>
                                <xsl:with-param name="simpleTypeName"
                                        >AmountPriceType1Code</xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name">Код типа суммы</xsl:with-param>
                            <xsl:with-param name="scalarValue" select="$scalarValue"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./IndxPts">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name" select="$nameField"/>
                            <xsl:with-param name="scalarValue" select="./IndxPts"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="./NotSpcfdPric">
                        <xsl:call-template name="fRenderNameValueTableRow">
                            <xsl:with-param name="name" select="$nameField"/>
                            <xsl:with-param name="scalarValue">
                                <xsl:text>Цена не определена</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!--    Получение поля "Дата платежа"-->
    <xsl:template name="getPayDate">
        <xsl:param name="path"/>

        <xsl:choose>
            <xsl:when test="$path/DtDtls/PmtDt/DtCd/Cd">
                <xsl:call-template name="fGetEnumDescriptionFromXsd">
                    <xsl:with-param name="value" select="$path/DtDtls/PmtDt/DtCd/Cd"/>
                    <xsl:with-param name="simpleTypeName">DateType8Code</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$path/DtDtls/PmtDt/Dt/Dt">
                        <xsl:value-of select="$path/DtDtls/PmtDt/Dt/Dt"/>
                    </xsl:when>
                    <xsl:when test="$path/DtDtls/PmtDt/Dt/DtTm">
                        <xsl:value-of select="$path/DtDtls/PmtDt/Dt/DtTm"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--    Получение поля "Зачисление\списание"-->
    <xsl:template name="getEnrollCancel">
        <xsl:param name="path"/>
        <xsl:if test="$path/CdtDbtInd">
            <xsl:call-template name="fGetEnumDescriptionFromXsd">
                <xsl:with-param name="value" select="$path/CdtDbtInd"/>
                <xsl:with-param name="simpleTypeName">CreditDebitCode</xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:variable name="whitespace" select="'&#09;&#10;&#13; '"/>
    <!-- Возвращает строку с удаленными пробелами справа -->
    <xsl:template name="string-rtrim">
        <xsl:param name="string"/>
        <xsl:param name="trim" select="$whitespace"/>

        <xsl:variable name="length" select="string-length($string)"/>

        <xsl:if test="$length &gt; 0">
            <xsl:choose>
                <xsl:when test="contains($trim, substring($string, $length, 1))">
                    <xsl:call-template name="string-rtrim">
                        <xsl:with-param name="string" select="substring($string, 1, $length - 1)"/>
                        <xsl:with-param name="trim" select="$trim"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$string"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Возвращает строку с удаленными пробелами слева -->
    <xsl:template name="string-ltrim">
        <xsl:param name="string"/>
        <xsl:param name="trim" select="$whitespace"/>

        <xsl:if test="string-length($string) &gt; 0">
            <xsl:choose>
                <xsl:when test="contains($trim, substring($string, 1, 1))">
                    <xsl:call-template name="string-ltrim">
                        <xsl:with-param name="string" select="substring($string, 2)"/>
                        <xsl:with-param name="trim" select="$trim"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$string"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!-- Возвращает строку с удаленными пробелами слева и справа -->
    <xsl:template name="string-trim">
        <xsl:param name="string"/>
        <xsl:param name="trim" select="$whitespace"/>
        <xsl:call-template name="string-rtrim">
            <xsl:with-param name="string">
                <xsl:call-template name="string-ltrim">
                    <xsl:with-param name="string" select="$string"/>
                    <xsl:with-param name="trim" select="$trim"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="trim" select="$trim"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>