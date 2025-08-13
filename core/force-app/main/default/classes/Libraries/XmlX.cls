/**
* Xml method extensions
*/
global class XmlX {
    /**
    * deserializes the specified XML string into an Apex object of the specified type
    * @param xmlString the xml string
    * @param apexType the apex type
    * @param rootElement the root element
    * @param nodesAsArray the nodes as array
    * @return Object
    */
    global static Object deserialize(String xmlString, Type apexType, String rootElement, Set<String> nodesAsArray) {
        return JSON.deserialize(JSON.serialize(xmlToUntyped(xmlString, rootElement, nodesAsArray)), apexType);
    }
    
    /**
    * deserializes the specified XML string into collections of primitive data types
    * @param xmlString the xml string
    * @param rootElement the root element
    * @param nodesAsArray the nodes as array
    * @return Object
    */
    global static Object deserializeUntyped(String xmlString, String rootElement, Set<String> nodesAsArray) {
        return xmlToUntyped(xmlString, rootElement, nodesAsArray);
    }

    /**
    * serializes Apex objects into XML content
    * @param objectToSerialize the object to serialize
    * @param rootElement the root element
    * @return String
    */
    global static String serialize(Object objectToSerialize, String rootElement) {
        String deserialized = serialize(false, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objectToSerialize)), false);
        return !String.isEmpty(rootElement)
            ? wrap(rootElement, deserialized, false)
            : deserialized;
    }

    /**
    * suppresses null values when serializing Apex objects into XML content
    * @param objectToSerialize the object to serialize
    * @param rootElement the root element
    * @param suppressApexObjectNulls suppress apex object nulls
    * @return String
    */
    global static String serialize(Object objectToSerialize, String rootElement, Boolean suppressApexObjectNulls) {
        String deserialized = serialize(false, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objectToSerialize)), suppressApexObjectNulls);
        return !String.isEmpty(rootElement)
            ? wrap(rootElement, deserialized, suppressApexObjectNulls)
            : deserialized;
    }

    /**
    * serializes Apex objects into XML content and generates indented content using the pretty-print format
    * @param objectToSerialize the object to serialize
    * @param rootElement the root element
    * @return String
    */
    global static String serializePretty(Object objectToSerialize, String rootElement) {
        String deserialized = serialize(true, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objectToSerialize)), false);
        return !String.isEmpty(rootElement)
            ? wrap(rootElement, deserialized, false)
            : deserialized;
    }

    /**
    * suppresses null values when serializing Apex objects into XML content and generates indented content using the pretty-print format
    * @param objectToSerialize the object to serialize
    * @param rootElement the root element
    * @param suppressApexObjectNulls suppress apex object nulls
    * @return String
    */
    global static String serializePretty(Object objectToSerialize, String rootElement, Boolean suppressApexObjectNulls) {
        String deserialized = serialize(true, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objectToSerialize)), suppressApexObjectNulls);
        return !String.isEmpty(rootElement)
            ? wrap(rootElement, deserialized, suppressApexObjectNulls)
            : deserialized;
    }

    /**
    * converts JSON string to XML String
    * @param jsonString the json string
    * @param rootElement the root element
    * @param suppressApexObjectNulls suppress apex object nulls
    * @return String
    */
    global static String jsonToXml(String jsonString, String rootElement, Boolean suppressApexObjectNulls) {
        String deserialized = serialize(false, (Map<String, Object>)JSON.deserializeUntyped(jsonString), suppressApexObjectNulls);
        return !String.isEmpty(rootElement)
            ? wrap(rootElement, deserialized, suppressApexObjectNulls)
            : deserialized;
    }
    
    /**
    * converts XML string to JSON string
    * @param xml the xml string
    * @param rootElement the root element
    * @param nodesAsArray the nodes as array
    * @return String
    */
    global static String xmlToJson(String xml, String rootElement, Set<String> nodesAsArray) {  
        return JSON.serialize(xmlToUntyped(xml, rootElement, nodesAsArray));
    }   

    /**
    * wraps the value with a key
    * @param key the key
    * @param value the value
    * @param suppressApexObjectNulls suppress apex object nulls
    * @return String
    */
    global static String wrap(String key, String value, Boolean suppressApexObjectNulls) {
        return String.isNotBlank(value) || !suppressApexObjectNulls
            ? ('<' + key + '>' + (String.isBlank(value) ? '' : value) + '</' + key + '>')
            : value;
    }

    //#region Core

    static Set<String> toLowerCase(Set<String> strings) {
        Set<String> r = new Set<String>();
        if (strings != null) for (String s : strings) r.add(s.toLowerCase());
        return r;
    }

    static String serialize(Boolean pretty, Map<String, Object> value, Boolean suppressApexObjectNulls) {
        List<String> b = new List<String>();
        for (String key : value.keySet()) {
            Object o = value.get(key);
            if (o == null) { if (!suppressApexObjectNulls) b.add(wrap(key, null, suppressApexObjectNulls)); }
            else if (o InstanceOf List<Object>) b.add(serialize(pretty, (List<Object>)o, key, suppressApexObjectNulls));
            else if (o InstanceOf Map<String, Object>) b.add(wrap(key, serialize(pretty, (Map<String, Object>)o, suppressApexObjectNulls), suppressApexObjectNulls));
            else b.add(wrap(key, String.valueOf(o), suppressApexObjectNulls));
        }
        return String.join(b, pretty ? '\n' : '');
    }

    static String serialize(Boolean pretty, List<Object> value, String key, Boolean suppressApexObjectNulls) {
        List<String> b = new List<String>();
        for (Object o : value) {
            if (o InstanceOf String) b.add(wrap(key, String.valueOf(o), suppressApexObjectNulls));
            else if (o InstanceOf List<Object>) b.add(wrap(key, serialize(pretty, (List<Object>)o, key, suppressApexObjectNulls), suppressApexObjectNulls));
            else b.add(wrap(key, serialize(pretty, (Map<String, Object>)o, suppressApexObjectNulls), suppressApexObjectNulls));
        }     
        return String.join(b, pretty ? '\n' : '');
    }

    static Object xmlToUntyped(String xml, String rootElement, Set<String> nodesAsArray) {
        if (!String.isEmpty(rootElement)) xml = wrap(rootElement, xml, false);
        nodesAsArray = toLowerCase(nodesAsArray);
        XmlDom xd = new XmlDom(); //xml);
        if (!xd.parseFromString(xml)) SystemX.debug(xml);
        XmlDom.Element doc = xd.ownerDocument();
        // get parsed node
        return doc.childNodes.isEmpty()
            ? (Object)doc.nodeValue
            : (Object)complexNodeToMapRecursive(doc, nodesAsArray, 0);
    }  

    static Map<String, Object> complexNodeToMapRecursive(XmlDom.Element e, Set<String> nodesAsArray, Integer level) {
        Map<String, Object> r = new Map<String, Object>();
        for (XmlDom.Element node : e.childNodes) {
            String nodeName = node.nodeName;
            // if (nodeName == 'custom-attributes') SystemX.debug(node);
            // get parsed node (recursive)
            Boolean hasChildNodes = node.childNodes.isEmpty();
            Object parsedNode = hasChildNodes
                ? (Object)node.nodeValue
                : (Object)complexNodeToMapRecursive(node, nodesAsArray, level + 1);
            // make new node
            if (!r.containsKey(nodeName))
                r.put(nodeName, nodesAsArray.contains(nodeName.toLowerCase())
                    ? new List<Object> { parsedNode }
                    : parsedNode);
            // add to existing node
            else {
                Object o = r.get(nodeName);
                if (o InstanceOf List<Object>) ((List<Object>)o).add(parsedNode);
                else r.put(nodeName, new List<Object> { o, parsedNode });
            }
            // add attributes
            if (hasChildNodes) {
                Map<String, String> attributes = node.attributes;
                for (String attribute : attributes.keySet()) r.put('@' + attribute, attributes.get(attribute));
            }
        }
        // add attributes
        Map<String, String> attributes = e.attributes;
        for (String attribute : attributes.keySet()) r.put('@' + attribute, attributes.get(attribute));
        return r;
    } 

    //#endregion
}