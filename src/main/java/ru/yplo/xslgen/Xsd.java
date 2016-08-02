package ru.yplo.xslgen;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

public class Xsd {

    private static final URL SCHEMA_URL = Xsd.class.getClassLoader().getResource("iso20022.xsd");
    private Document doc;
    private XPath xp;

    public Xsd() {
        try {
            DocumentBuilderFactory f = DocumentBuilderFactory.newInstance();
            DocumentBuilder b = f.newDocumentBuilder();
            doc = b.parse(SCHEMA_URL.getFile());

            XPathFactory xpf = XPathFactory.newInstance();
            xp = xpf.newXPath();
        } catch (SAXException | IOException | ParserConfigurationException ex) {
            throw new RuntimeException(ex);
        }
    }

    public void validateElement(String xpath) {

        List<String> subPaths = new ArrayList<>();
        for (String subPath : xpath.split("/")) {
            try {
                subPaths.add(subPath);
                String currentFullSubpath = String.join("/", subPaths);
                Node node = (Node) xp.evaluate(String.format("//*[xmlxpath='%s']/ancestor::element[1]", currentFullSubpath), doc, XPathConstants.NODE);
                if (node == null) {
                    System.out.format("no node for path %s\n", currentFullSubpath);
                    continue;
                }
                Node minOccursNode = node.getAttributes().getNamedItem("minOccurs");
                Node maxOccursNode = node.getAttributes().getNamedItem("maxOccurs");
                System.out.format("for element %s [%s, %s]\n", currentFullSubpath,
                        minOccursNode != null ? minOccursNode.getTextContent() : 1,
                        maxOccursNode != null ? maxOccursNode.getTextContent() : 1);
            } catch (XPathExpressionException ex) {
                Logger.getLogger(Xsd.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

    }

    public static void main(String[] args) throws Exception {

//        System.out.println(node);
//
//        TransformerFactory tf = TransformerFactory.newInstance();
//        Transformer transformer = tf.newTransformer();
//        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
//        StringWriter writer = new StringWriter();
//        transformer.transform(new DOMSource(node), new StreamResult(writer));
//        String output = writer.getBuffer().toString();
//        System.out.println(output);
    }
}
