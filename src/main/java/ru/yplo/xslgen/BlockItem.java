package ru.yplo.xslgen;

public class BlockItem {

    private final String title;
    private final String xpath;
    private final String name;
    private Block parent;

    public BlockItem(String title) {
        this(title, null);
    }

    public BlockItem(String title, String xpath) {
        this.title = title;
        this.xpath = xpath;
        this.name = Utils.toCamelCase(title);
    }

    public String getTitle() {
        return title;
    }

    public String getXpath() {
        return xpath;
    }

    public String getName() {
        return name;
    }

    public Block getParent() {
        return parent;
    }

    public void setParent(Block parent) {
        this.parent = parent;
    }

    public String getFullXPath() {
        if (xpath == null) return null;
        if (parent == null || parent.getBaseXPath() == null) return xpath;
        String base = parent.getBaseXPath();
        for (int i = xpath.length(); i > 0; i--) {
            String substr = xpath.substring(0, i);
            if (base.contains(substr) && base.lastIndexOf(substr) + substr.length() == base.length() - 1) {
                return mkXpath(base, xpath.substring(i));
            }
        }
        return mkXpath(base, xpath);
    }

    private String mkXpath(String... elements) {
        return String.join("/", elements).replaceAll("/{1,}", "/");
    }

    public String getRowOut() {
        return String.format("<xsl:call-template name=\"fRenderNameValueTableRow\">\n"
                + "                        <xsl:with-param name=\"name\">%s</xsl:with-param>\n"
                + "                        <xsl:with-param name=\"scalarValue\" select=\"$%s\"/>\n"
                + "                    </xsl:call-template>\n", title, name);
    }

}
