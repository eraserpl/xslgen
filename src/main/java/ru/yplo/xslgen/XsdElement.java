package ru.yplo.xslgen;

import org.w3c.dom.Node;

public class XsdElement {

    private String minOccurs, maxOccurs;
    private String type;
    private final String xpath;
    private boolean checked = false;

    public XsdElement(String xpath) {
        this.xpath = xpath;
    }

    public void loadFromNode(Node element) {
        if (element == null) return;
        Node minOccursNode = element.getAttributes().getNamedItem("minOccurs");
        Node maxOccursNode = element.getAttributes().getNamedItem("maxOccurs");
        Node typeNode = element.getAttributes().getNamedItem("type");

        minOccurs = minOccursNode != null ? minOccursNode.getTextContent() : "1";
        maxOccurs = maxOccursNode != null ? maxOccursNode.getTextContent() : "1";
        type = typeNode.getTextContent();
        checked = true;
    }

    public String getMinOccurs() {
        return minOccurs;
    }

    public String getMaxOccurs() {
        return maxOccurs;
    }

    public String getType() {
        return type;
    }

    public String getXpath() {
        return xpath;
    }

    public boolean isChecked() {
        return checked;
    }

}
