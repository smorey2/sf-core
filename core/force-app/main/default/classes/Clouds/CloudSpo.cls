/**
* SharePoint Online (SPO)
*/
global class CloudSpo extends Cloud {
    String endpoint;
    String bucket;
    String clientId;
    String awsclientSecretSecret;

    /**
    * creates a CloudSpo
    * @param namedCredential the namedCredential
    */
    global CloudSpo(String namedCredential) { this(NamedCredential__mdt.getInstance(namedCredential)); }
    /**
    * creates a CloudSpo
    * @param credential the NamedCredential__mdt
    */
    global CloudSpo(NamedCredential__mdt credential) { this(credential?.Endpoint__c, credential?.Bucket__c, credential?.ClientId__c, credential?.ClientSecret__c); }
    /**
    * creates a CloudSpo
    * @param site the site
    * @param bucket the bucket
    * @param clientId the clientId
    * @param clientSecret the clientSecret
    */
    global CloudSpo(String site, String bucket, String clientId, String clientSecret) {
        if (String.isEmpty(clientId) && !Test.isRunningTest()) throw new IllegalArgumentException('Required: clientId');
        this.bucket = bucket;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.endpoint = 'https://' + site + '/_api/web';
    }

    /**
    * copies an object
    * @param path the path
    * @param newPath the new path
    * @see https://sharepoint.stackexchange.com/questions/152936/rest-call-to-move-a-file-folder-to-another-location
    */
    global override void copy(String path, String newPath) {
        SystemX.debug('copy: ' + path + ', ' + newPath);
        path = urlEncode(path);
        HttpRequest req = createRequest(null, '/GetFileByServerRelativeUrl(' + str(bucket + '/' + path) + ')/CopyTo(' + str(bucket + '/' + newPath) + ')', null, null, null);
        req.setBody('');
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * deletes an object
    * @param path the path
    */
    global override void deletex(String path) {
        SystemX.debug('deletex: ' + path);
        HttpRequest req = createRequest('DELETE', '/GetFileByServerRelativeUrl(' + str(bucket + '/' + path) + ')', null, null, null);
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode == 404) { }
        else if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * gets an object
    * @param path the path
    * @param range the range
    * @return Blob
    */
    global override Blob get(String path, Range range) {
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('GET', path, contentType, range, null);
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode == 416) return null;
        else if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        return res.getBodyAsBlob();
    }

    /**
    * moves an object
    * @param path the path
    * @param newPath the new path
    * @see https://sharepoint.stackexchange.com/questions/152936/rest-call-to-move-a-file-folder-to-another-location
    */
    global override void move(String path, String newPath) {
        SystemX.debug('move: ' + path + ', ' + newPath);
        path = urlEncode(path);
        HttpRequest req = createRequest(null, '/GetFileByServerRelativeUrl(' + str(bucket + '/' + path) + ')/MoveTo(' + str(bucket + '/' + newPath) + ')', null, null, null);
        req.setBody('');
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * lists all objects
    * @param prefix the prefix
    * @param filters the filters
    * @return List<File>
    */
    global override List<File> listx(String prefix, String filters) {
        List<File> r = new List<File>();
        HttpRequest req = createRequest(null, '?list-type=2' + (!String.isEmpty(prefix) ? '&prefix=' + prefix : ''), null, null, null);
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        Dom.Document doc = res.getBodyDocument();
        Dom.XmlNode root = doc.getRootElement();
        String ns = root.getNamespace();
        Boolean filterFile = filters?.contains('file') == true, filterSize = filters?.contains('size') == true;
        for (Dom.XmlNode child : root.getChildElements()) {
            if (child.getName() != 'Contents') continue;
            String key = child.getChildElement('Key', ns).getText();
            Integer size = Integer.valueOf(child.getChildElement('Size', ns).getText());
            Datetime lastModified = Datetime.valueOfGmt(child.getChildElement('LastModified', ns).getText().replace('T',' '));
            if ((filterFile && key.endsWith('/')) || (filterSize && size == 0)) continue;
            r.add(new File(key, key, size, lastModified));
        }
        return r;
    }

    /**
    * puts and object
    * @param path the path
    * @param range the range
    * @param content the content
    */
    global override void put(String path, Range range, Object content) {
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest(null, path, contentType, range, new Map<String, String> { 'ACL' => 'public-read' });
        if (content == null) { }
        else if (content instanceOf Blob) req.setBodyAsBlob((Blob)content);
        else if (content instanceOf String) req.setBody((String)content);
        else req.setBody(content.toString());
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * flush on
    * @return Integer
    */
    global override Integer flushOn() { return 5242880; }

    /**
    * aborts a multipart upload
    * @param entry the entry
    * @param parts the parts
    * @see https://learn.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_post_content?view=odsp-graph-online
    */
    global override void abortMultipart(File entry, List<Object> parts) {
        SystemX.debug('abortMultipart: ' + entry.path);
        String path = entry.path;
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('DELETE', path + '&uploadId=' + entry.tag, contentType, null, null);
        req.setBody('');
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * creates a multipart upload
    * @param path the path
    * @see https://learn.microsoft.com/en-us/onedrive/developer/rest-api/api/driveitem_post_content?view=odsp-graph-online
    */
    global override File createMultipart(String path) {
        SystemX.debug('createMultipart: ' + path);
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest(null, path + '&uploads', contentType, null, null);
        req.setBody('');
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        Dom.Document doc = res.getBodyDocument();
        Dom.XmlNode root = doc.getRootElement();
        String ns = root.getNamespace();
        if (root.getName() != 'InitiateMultipartUploadResult') throw new HandledException('Unable to createMultipart');
        String key = root.getChildElement('Key', ns).getText();
        String uploadId = root.getChildElement('UploadId', ns).getText();
        File entry = new File(key, key, 0, null);
        entry.tag = uploadId;
        return entry;
    }
    
    /**
    * completes a multipart upload
    * @param entry the entry
    * @param parts the parts
    * @return File
    */
    global override File completeMultipart(File entry, List<Object> parts) {
        SystemX.debug('completeMultipart: ' + entry.path);
        String path = entry.path;
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest(null, path + '&uploadId=' + entry.tag, contentType, null, null);
        List<String> b = new List<String>();
        b.add('<?xml version="1.0" encoding="UTF-8"?>');
        b.add('<CompleteMultipartUpload xmlns="http://s3.amazonaws.com/doc/2006-03-01/">');
        for (Object part : parts) b.add((String)part);
        b.add('</CompleteMultipartUpload>');
        req.setBody(String.join(b, ''));
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        return entry;
    }
    
    /**
    * uploads a part
    * @param entry the entry
    * @param part the part
    * @param content the content
    * @return Object
    */
    global override Object uploadPart(File entry, Object part, Object content) {
        SystemX.debug('uploadPart: ' + entry.path + '@' + part);
        String path = entry.path;
        Integer partNumber = Integer.valueOf(part);
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest(null, path + '&partNumber=' + partNumber + '&uploadId=' + entry.tag, contentType, null, null);
        if (content == null) { }
        else if (content instanceOf Blob) req.setBodyAsBlob((Blob)content);
        else if (content instanceOf String) req.setBody((String)content);
        else req.setBody(content.toString());
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        String etag = res.getHeader('ETag');
        return '<Part><PartNumber>' + partNumber + '</PartNumber><ETag>' + etag + '</ETag></Part>';
    }

    HttpRequest createRequest(String method, String key, String contentType, Range range, Map<String, String> headers) {
        String digest = '';
        key = urlEncode(key);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint + '/' + key.replaceFirst('\\?|&', '?'));
        req.setHeader('Host', host);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('X-RequestDigest', digest);
        if (method != null) req.setHeader('X-HTTP-Method', method);
        if (contentType != null) req.setHeader('Content-Type', contentType);
        if (range != null) req.setHeader('Range', 'bytes=' + range.start + '-' + range.endx);
        Set<String> headerKeys;
        if (headers != null) for (String s : headerKeys = headers.keySet()) req.setHeader(s, headers.get(s));
        return req;
    }

    static String urlEncode(String value) { return value.replace(' ', '%20'); }
    static String str(String value) { return '\'' + value.replace('\'', '\'\'') + '\''; }
}
