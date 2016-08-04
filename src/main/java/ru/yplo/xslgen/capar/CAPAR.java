package ru.yplo.xslgen.capar;

import java.util.ArrayList;
import java.util.List;
import ru.yplo.xslgen.Block;
import ru.yplo.xslgen.BlockItem;
import ru.yplo.xslgen.PrintForm;

public class CAPAR {

    private static final String CA_DETAILS_ITEMS_DESC
            = "Референс корпоративного действия=/CorpActnEvtId\n"
            + "Тип обработки информации о корпоративном действии=/EvtPrcgTp/Cd\n"
            + "Код типа корпоративного действия=/EvtTp/Cd\n"
            + "Признак добровольности/обязательности=/MndtryVlntryEvtTp/Cd";
    private static final String SECURITY_ITEMS_DESC = "Наименование=FinInstrmId/Desc\n"
            + "ISIN=FinInstrmId/ISIN\n"
            + "Депозитарный код=FinInstrmId/OthrId/Id\n"
            + "Гос рег. номер/идентификационный код=FinInstrmId/OthrId/Id\n"
            + "Дата выпуска=IsseDt";
    private static final String ACCT_LIST_ITEMS_DESC = "Счет депо=SfkpgAcct\n"
            + "Остаток=Bal/TtlElgblBal/QtyChc/SgndQty/Qty/Unit";
    private static final String CA_MVMNT_RPRT_ITEMS_DESC = "Референс ведомости=SfkpgAcct\n"
            + "Референс инструкции=InstrId/Id";
    private static final String REGISTRAR_ITEMS_DESC = "Наименование=NmAndAdr/Nm\n"
            + "Адрес=NmAndAdr/Adr/AdrLine";

    public static void main(String[] args) {
        PrintForm pf = new PrintForm("Уведомление о системном событии", "CAPAR", "Corporate Action Movement Preliminary Advice Report", "CorporateActionMovementPreliminaryAdviceReport");
        Block caDetails = new Block("Реквизиты корпоративного действия", "CorporateActionDetails", "CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/CorpActnGnlInf");
        pf.add(caDetails);
        for (BlockItem item : getItems(CA_DETAILS_ITEMS_DESC))
            caDetails.addItem(item);
        caDetails.setCommon(true);

        Block security = new Block("Ценная бумага", "CAPAR_Security", "CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/CorpActnGnlInf/UndrlygScty");
        pf.add(security);
        for (BlockItem item : getItems(SECURITY_ITEMS_DESC))
            security.addItem(item);

        Block acctListBlock = new Block("Информация об остатках ценных бумаг на счете депо", "CAPAR_AcctList", "CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/AcctsListAndBalDtls");
        pf.add(acctListBlock);
        for (BlockItem item : getItems(ACCT_LIST_ITEMS_DESC))
            acctListBlock.addItem(item);

        Block caMvmntRprt = new Block("Ведомость предварительных извещений о движении", "CAPAR_CaMvmntRprt", "CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/MvmntRprt");
        pf.add(caMvmntRprt);
        for (BlockItem item : getItems(CA_MVMNT_RPRT_ITEMS_DESC))
            caMvmntRprt.addItem(item);

        Block registrar = new Block("Регистратор", "CAPAR_Registrar", "CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/Regar");
        pf.add(registrar);
        for (BlockItem item : getItems(REGISTRAR_ITEMS_DESC))
            registrar.addItem(item);

        pf.print();
//        pf.validate();
    }

    private static List<BlockItem> getItems(String itemsDesc) {
        List<BlockItem> items = new ArrayList<>();
        for (String itemDesc : itemsDesc.split("\n")) {
            String[] itemParts = itemDesc.split("=");
            items.add(new BlockItem(itemParts[0], itemParts[1]));
        }
        return items;
    }
}
