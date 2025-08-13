@isTest
public class XmlTest {
    static String xml1 = '<catalog><books><book><title>Advanced Apex Programming</title><subTitle>for Salesforce.com and Force.com</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
    static String xml2 = '<catalog id="id"><books><book><title>Advanced Apex Programming</title><subTitle>for Salesforce.com and Force.com</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
    static String json1 = '{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":"Dan Appleman"},"subTitle":"for Salesforce.com and Force.com","title":null},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';

    //#region XmlDom

    @isTest static void XmlDom_methods() {
        XmlDom xd = new XmlDom(xml1);
        XmlDom.Element doc = xd.ownerDocument();
        List<XmlDom.Element> elements = xd.getElementsByTagName('book');
        String s = xd.toXmlString();
        xd.dumpAll();
        xd.getElementByTagName('book');
        XmlDom.Element bookElement = doc.getElementByTagName('book');
        doc.removeChild(bookElement);
        doc.dump();
		doc.getElementsByPath('book/title');
        doc.getValue('title');
        doc.hasAttributes();
        doc.hasChildNodes();
        doc.firstChild();
        doc.cloneNode();
        doc.textContent();
        doc.isEqualNode(bookElement);
        doc.isSameNode(bookElement);
        doc.ownerDocument();
    }

    //#endregion

    //#region XmlX

    public class Library {
        public Catalog catalog;
    }
    public class Catalog {
        public Books books;
    }
    public class Books {
        public List<Book> book;
    }
    public class Book {
        public String title;
        public String subTitle;
        public Authors authors;
        public String price;
    }
    public class Authors {
        public List<String> author;
    }

    @isTest static void XmlX_serialize(){
        Library library = new Library();
        Catalog catalog = new Catalog();
        Books books = new Books();
        List<Book> book = new List<Book>();
        
        Book book1 = new Book();
        book1.title = 'Advanced Apex Programming';
        Authors apexAuthors = new Authors();
        List<String> apexAuthor = new List<String>();
        apexAuthor.add('Dan Appleman');
        apexAuthors.author = apexAuthor;
        book1.authors = apexauthors;
        book.add(book1);
        books.book = book;
        catalog.books = books;
        library.catalog = catalog;
        
        String serializedWithDefaultOptions = XmlX.serialize(library, null);
        System.debug('serializedWithDefaultOptions:' + serializedWithDefaultOptions);
        // properties with no value serialized with default options
        System.assert(serializedWithDefaultOptions.containsIgnoreCase('<subTitle></subTitle>'));
        
        String serializedXmlWithOptions = XmlX.serialize(library, 'Root', true);
        // properties without value (null or empty) are omitted with suppressApexObjectNulls setting to true
        System.assert(!serializedXmlWithOptions.containsIgnoreCase('<subTitle></subTitle>'));
        // check that the XML is wrapped with root element
        System.assert(serializedXmlWithOptions.contains('<Root>'));
        System.assert(serializedXmlWithOptions.contains('</Root>'));
        
        System.debug('serializedXmlWithOptions:' + serializedXmlWithOptions);
    }

    @isTest static void XmlX_deserialize() {
        Library library = (Library)XmlX.deserialize(xml2, Library.class, null, new Set<String> { 'author' });
        System.assertEquals(2, library.catalog.books.book.size());
        
        for (Book b : library.catalog.books.book) {
            if (b.title == 'Advanced Apex Programming') System.assertEquals(1, b.authors.author.size());
            else System.assertEquals(4, b.authors.author.size());
        }
    }
    
    @isTest static void XmlX_deserializeUntyped() {
        Map<String, Object> actual1 = (Map<String, Object>)XmlX.deserializeUntyped(xml2, null, new Set<String> { 'author' });
        Map<String, Object> actual2 = (Map<String, Object>)XmlX.deserializeUntyped(xml2, null, null);
        Map<String, Object> actual3 = (Map<String, Object>)XmlX.deserializeUntyped(xml2, null, new Set<String> { 'author' });
        System.assert(actual1.containsKey('catalog'));
        System.assert(actual2.containsKey('catalog'));
        System.assert(actual3.containsKey('catalog'));
    }
    
    @isTest static void XmlX_xmlToJson() {
        String expected1 = '{"catalog":{"@id":"id","books":{"book":[{"price":"39.95","authors":{"author":"Dan Appleman"},"subTitle":"for Salesforce.com and Force.com","title":"Advanced Apex Programming"},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
        String expected2 = '{"catalog":{"@id":"id","books":{"book":[{"price":"39.95","authors":{"author":["Dan Appleman"]},"subTitle":"for Salesforce.com and Force.com","title":"Advanced Apex Programming"},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
        System.assertEquals(expected1, XmlX.xmlToJson(xml2, null, null));
        System.assertEquals(expected2, XmlX.xmlToJson(xml2, null, new Set<String> { 'author' }));
    }
    
    @isTest static void XmlX_jsonToXml() {
        String expected1 = '<catalog><books><book><price>39.95</price><authors><author>Dan Appleman</author></authors><subTitle>for Salesforce.com and Force.com</subTitle><title></title></book><book><price>37.88</price><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><title>Design Patterns</title></book></books></catalog>';
        String expected2 = '<catalog><books><book><price>39.95</price><authors><author>Dan Appleman</author></authors><subTitle>for Salesforce.com and Force.com</subTitle></book><book><price>37.88</price><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><title>Design Patterns</title></book></books></catalog>';
        String expected3 = '{"root":{"@r":"1","books":{"@bs":"2","@b":"3","book":"Book"}}}';
        System.assertEquals(expected1, XmlX.jsonToXml(json1, null, false));
        System.assertEquals(expected2, XmlX.jsonToXml(json1, null, true));
        System.assertEquals(expected3, XmlX.xmlToJson('<root r="1"><books bs="2"><book b="3">Book</books>', null, null));
    }

    @isTest static void XmlX_wrap() {
        String xml1 = '<item></item><item></item>';
        String expected1 = '<root><item></item><item></item></root>';
        System.assertEquals(expected1, XmlX.wrap('root', xml1, false));
    }
    
    //#endregion
}