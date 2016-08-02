package ru.yplo.xslgen;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

public class PrintForm {

    private final String title;
    private final String name;
    private final String fullName;
    private final String xpath;
    private final List<Block> blocks = new ArrayList<>();

    public PrintForm(String title, String name, String fullName, String xpath) {
        this.title = title;
        this.name = name;
        this.fullName = fullName;
        this.xpath = xpath;
    }

    public List<Block> getBlocks() {
        return new ArrayList<>(blocks);
    }

    public void add(Block block) {
        blocks.add(block);
    }

    public String print() {
        try {
            URL templateUrl = PrintForm.class.getClassLoader().getResource("template.xsl");
            String template = new String(Files.readAllBytes(new File(templateUrl.getFile()).toPath()));
            return String.format(template, xpath, getBody());
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
    }

    private String getBody() {
        StringBuilder b = new StringBuilder();
        b
                .append("    <!--=======================================================================================-->\n")
                .append("    <!--=======================================================================================-->\n")
                .append("    <!--=======================================================================================-->\n")
                .append(String.format("    <!-- Шаблоны для %s (%s)-->\n", name, fullName))
                .append("    <!--=======================================================================================-->\n")
                .append("    <!--=======================================================================================-->\n")
                .append("    <!--=======================================================================================-->\n");
        b
                .append(String.format("    <xsl:template name=\"%s\">", xpath));
        for (Block block : blocks) {
            b.append(String.format("<xsl:call-template name=\"%s\"/>", block.getName()));
        }
        b
                .append("    </xsl:template>");
        for (Block block : blocks) b.append(block.getBody());
        return b.toString();
    }

}
