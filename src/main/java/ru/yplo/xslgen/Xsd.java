package ru.yplo.xslgen;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
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

    public List<XsdElement> validateAllPaths(String xpath) {
        List<XsdElement> result = new ArrayList<>();

        List<String> subPaths = new ArrayList<>();
        for (String subPath : xpath.split("/")) {
            try {
                subPaths.add(subPath);
                String currentFullSubpath = String.join("/", subPaths);
                XsdElement xsdElement = new XsdElement(currentFullSubpath);
                result.add(xsdElement);

                Node element = (Node) xp.evaluate(String.format("//*[xmlxpath='%s']/ancestor::element[1]", currentFullSubpath), doc, XPathConstants.NODE);
                xsdElement.loadFromNode(element);
            } catch (XPathExpressionException ex) {
                throw new RuntimeException(ex);
            }
        }
        return result;
    }

    public static void main(String[] args) throws Exception {

        
        
//        xsd.validateElement("CorporateActionMovementPreliminaryAdviceReport/Document/CorpActnMvmntRprt/CorpActnGnlInf/EvtPrcgTp/Cd");
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
