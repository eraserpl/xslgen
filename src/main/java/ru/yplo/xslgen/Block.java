package ru.yplo.xslgen;

import java.util.ArrayList;
import java.util.List;

public class Block {

    private final String title;
    private final String name;
    private final String baseXPath;
    private final List<BlockItem> items = new ArrayList<>();

    public Block(String title, String name) {
        this(title, name, null);
    }

    public Block(String title, String name, String baseXPath) {
        this.title = title;
        this.name = name;
        this.baseXPath = baseXPath;
    }

    public String getTitle() {
        return title;
    }

    public String getName() {
        return name;
    }

    public String getBaseXPath() {
        return baseXPath;
    }

    public void addItem(BlockItem i) {
        i.setParent(this);
        items.add(i);
    }

    public List<BlockItem> getItems() {
        return new ArrayList(items);
    }

    public void logValidationInfo() {
        Xsd xsd = new Xsd();
        for (BlockItem item : items) {
            System.out.format("validate %s  ======\n", item.getFullXPath());
            xsd.validateElement(item.getFullXPath());
            System.out.format("======\n\n\n");
        }
    }

    public String getBody() {
        StringBuilder b = new StringBuilder();
        b.append(String.format("<!--%s-->\n", title));
        b.append(String.format("    <xsl:template name=\"%s\">\n", name));
        b.append("        <xsl:call-template name=\"fTrace\">\n");
        b.append(String.format("            <xsl:with-param name=\"value\">%s</xsl:with-param>\n", name));
        b.append("        </xsl:call-template>\n");
        b.append("\n");
        b.append("        <!--Вычисление значений-->\n");
        for (BlockItem item : items)
            b.append(String.format("<xsl:variable name=\"%s\" select=\"%s\"/>\n", item.getName(), item.getFullXPath()));

        b.append("<!--Рендеринг-->'n");
        StringBuilder ifBuilder = new StringBuilder();
        ifBuilder.append("<xsl:if test=\"");
        for (int i = 0; i < items.size(); i++) {
            BlockItem item = items.get(i);
            ifBuilder.append("string-length($").append(item.getName()).append(") &gt; 0");
            if (i != items.size() - 1) ifBuilder.append(" or\n");
        }
        ifBuilder.append("\">").append("\n");
        b.append(ifBuilder);

        b.append("<table>\n")
                .append("                <xsl:call-template name=\"fSetStyle\">\n")
                .append("                    <xsl:with-param name=\"name\">table</xsl:with-param>\n")
                .append("                </xsl:call-template>\n")
                .append("                <thead>\n")
                .append("                    <tr>\n")
                .append(String.format("                        <th colspan=\"2\">%s</th>\n", title))
                .append("                    </tr>\n")
                .append("                </thead>\n")
                .append("                <tbody>");
        for (BlockItem item : items) {
            b.append(item.getRowOut());
        }
        b.append("</tbody>\n"
                + "            </table>\n"
                + "            <br/>");
        b.append("</xsl:if>");

        return b.toString();
    }

}
