package ru.yplo.xslgen;

/**
 *
 * @author YPlotnikov
 */
public class Utils {

    public static String toCamelCase(String s) {
        String[] words = s.split("[.,\\- /]");
        StringBuilder b = new StringBuilder();
        for (String word : words) {
            if (!word.isEmpty()) {
                b.append(word.substring(0, 1).toUpperCase());
                if (word.length() > 1) b.append(word.substring(1));
            }
        }
        return b.toString().replaceAll("[,-]", "");
    }
}
