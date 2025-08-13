global class XmlDom {
    global XmlDom() { }
    global XmlDom(String str) { parseFromString(str); }

    global Boolean parseFromString(String str) {
        XmlStreamReader r = new XmlStreamReader(str);
        r.setCoalescing(true);
        return parseXmlReader(root, r);
    }
     
    // debugging assistance
    global void dumpAll() { root.dumpAll(); }
    global void dumpList(Element[] l) { for (Element e : l) e.dump(); }
    Integer count = 0;

    // given a parent node and a stream reader, populates the tree below here (recursive)
    Boolean parseXmlReader(Element parent, XmlStreamReader r) {
        try {
            while (r.hasNext()) {
                if (r.getEventType() == XmlTag.START_ELEMENT) {
                    Element child = new Element(r.getLocalName());
                    
                    // add all attributes from this element
                    for (Integer i = 0; i < r.getAttributeCount(); i++) child.attributes.put(r.getAttributeLocalName(i), r.getAttributeValueAt(i));

                    // add namespace info to each node/element ( for now storing on attributes map)
                    for (Integer j = 0; j < r.getNamespaceCount(); j++) {
                        String prefix = 'xmlns';
                        if (r.getnamespaceprefix(j) != null) prefix = r.getNamespacePrefix(j);
                        child.attributes.put(prefix, r.getNamespaceUriAt(j));
                    } 

                    // add the new element to current parent
                    parent.appendChild(child); 

                    if (child.nodeName == 'item' || child.nodeName == 'entry') count++;
                    if (count > 10) return true; // avoid a bug in xmlstream reader
                    
                    // SystemX.debug(count + ' '+ r.getLocation() + ' ' + child.nodeName);
                    if (r.hasNext()) r.next(); else return true;
                    parseXmlReader(child, r); // recurse
                }
                else if (r.getEventType() == XmlTag.END_ELEMENT) { r.next(); return true; }
                else if (r.getEventType() == XmlTag.CHARACTERS) { if (!r.isWhitespace()) parent.nodeValue += r.getText(); r.next(); } // add text to current element
                else r.next();
            }
        } catch (Exception e) { // ParseError if we get a truncated response, allow it
            SystemX.debug('CAUGHT: ' + e);
            // parent.dumpAll();
            return false;
        }
        return true;
    }   
    
    // access nodes in the tree using these getters
    global List<Element> getElementsByTagName(String nam) { return root.getElementsByTagName(nam); }

    global Element getElementByTagName(String nam) {
        List<Element> r = root.getElementsByTagName(nam);
        if (r.size() == 0) return null;
        return r[0];
    }

    // utility dom functions
    global Element ownerDocument() { return root; }

    // everything in the dom is found as childNodes under this root element
    global Element root = new Element('#document');
    global Integer debug = 0;
    // dump out the element tree
    global String toXmlString() { return root.toXmlString(); }
    
    global class Element {
        // properties
        global Element parentNode = null; // only root has a null parent 
        global String nodeName = '';
        global String nodeValue = '';
        global List<Element> childNodes = new List<Element>();
        global Map<String, String> attributes = new Map<String, String>();

        //  Element(Element p, String n) { parentNode = p; nodeName = n; }
        global Element(String n) { nodeName = n; }
        global Element() { }
        
        // utility methods
        global Element firstChild() { return this.childNodes.size() == 0 ? null : this.childNodes[0]; }
        global String textContent() { return this.nodeValue; }
        global Boolean hasChildNodes() { return !childNodes.isEmpty(); }
        global Boolean isEqualNode(Element comp) { return this.nodeName == comp.nodeName; }
        global Element cloneNode() { return this.clone(); }
        global Boolean hasAttributes() { return !attributes.isEmpty(); }
        global Boolean isSameNode(Element comp) { return this === comp; }
        global Element ownerDocument() { Element r = this; while (r.parentNode != null) r = r.parentNode; return r; }

        // methods
        global String getAttribute(String name) { return attributes.get(name); }
        global void appendChild(Element e) { e.ParentNode = this; this.childNodes.add(e); }
        global void removeChild(Element e) {
            Element p = e.parentNode;
            List<Element> kids = new List<Element> { };
            for (Element ee : e.parentNode.childNodes) if (ee != e) kids.add(ee);
            p.childNodes = kids;
        }
        // traverse below this node, returning all matching nodes by name
        global List<Element> getElementsByTagName(String nam) {
            List<Element> r = new List<Element>{};
            if (nam == this.nodeName) r.add(this);
            for (Element c : this.childNodes) r.addAll(c.getElementsByTagName(nam)); // decend tree
            return r;
        }
        // like above, but just returns the first one that matches  
        global Element getElementByTagName(String nam) {
            List<Element> r = getElementsByTagName(nam);
            if (r.size() == 0) return null;
            return r[0];
        }
        // first one that matches, just return the nodeValue
        global String getValue(String nam) {
            Element e = getElementByTagName(nam);
            return e == null ? null : e.nodeValue;
        }

        // some debugging help  
        global void dump() { dump(''); }
        global void dump(String pre) { SystemX.debug(pre + ' ' +this.nodeName + '->' + this.nodeValue + ' ' + this.attributes); } // just current node
        global void dumpAll() { dumpAll(''); }
        global void dumpAll(String pre) { // node and all children
            SystemX.debug(pre + this.nodeName + '->' + this.nodeValue + ' ' + this.attributes);
            for (Element c : this.childNodes) c.dumpAll(pre + '   ');
        }
        global String toXmlString() {
            String r = '<' + this.nodeName + ' ';
            for (String a : attributes.keySet()) r += a + '=\'' + attributes.get(a) + '\' ';
            r += '>';
            if (nodeValue == '') r += '\n';
            for (Element c : this.childNodes) r += c.toXmlString(); //+ '\n';
            if (nodeValue != '') r += nodeValue;
            //else r += '\n';
            return r + '</' + this.nodeName + '>\n';
        }
        /* 
        * experimental path based patern matching, sort of like xpath, 
        * but simpler, just matches a path() String with the pattern supplied
        */
        // * /bookstore/book/.*
        // /.*book/.*
        // /.*/book$
        global List<Element> getElementsByPath(String path) {
            List<Element> r = new List<Element> { };
            // SystemX.debug(path + ' ' + this.path());
            if (Pattern.matches(path, this.path())) r.add(this);
            for (Element c : this.childNodes) r.addAll(c.getElementsByPath(path));
            return r;
        }    
        global String path() {
            Element t = this;
            String r = t.nodeName;
            while (t.parentNode != null && t.parentNode.nodeName != '#document') { t = t.parentNode; r = t.nodeName + '/' + r; }
            return '/' + r;
        }
    }
}