package ru.yplo.xslgen;

import java.util.ArrayList;
import java.util.List;

public class SEN {

    private static final String itemsDesc
            = "Код события=EvtCd\n"
            + "Параметр события=EvtParam\n"
            + "Время события=EvtTm";

    public static void main(String[] args) {
        PrintForm pf = new PrintForm("Уведомление о системном событии", "SEN", "System Event Notification", "SystemEventNotification");
        Block sen = new Block("Уведомление о системном событии", "SEN", "SystemEventNotification/Document/EvtInf");
        pf.add(sen);
        for (BlockItem item : getItems()) sen.addItem(item);
//        sen.validate();
        pf.print();
    }

    private static List<BlockItem> getItems() {
        List<BlockItem> items = new ArrayList<>();
        for (String itemDesc : itemsDesc.split("\n")) {
            String[] itemParts = itemDesc.split("=");
            items.add(new BlockItem(itemParts[0], itemParts[1]));
        }
        return items;
    }
}
