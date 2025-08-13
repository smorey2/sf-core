/**
* Google Cloud Platform (GCP)
* @see https://medium.com/@rosyparmar/google-cloud-storage-use-hmac-to-authenticate-requests-to-cloud-storage-aa8ed859be33
* @see https://cloud.google.com/storage/docs/interoperability
*/
global class CloudGcp extends Cloud {
    String bucket;
    String accessKey;
    String secret;
    String host;

    /**
    * creates a CloudGcp
    * @param namedCredential the namedCredential
    */
    global CloudGcp(String namedCredential) { this(NamedCredential__mdt.getInstance(namedCredential)); }
    /**
    * creates a CloudGcp
    * @param credential the NamedCredential__mdt
    */
    global CloudGcp(NamedCredential__mdt credential) { this(credential?.Bucket__c, credential?.ClientId__c, credential?.ClientSecret__c); }
    /**
    * creates a CloudGcp
    * @param bucket the bucket
    * @param accessKey the accessKey
    * @param secret the secret
    */
    global CloudGcp(String bucket, String accessKey, String secret) {
        if (String.isEmpty(accessKey) && !Test.isRunningTest()) throw new IllegalArgumentException('Required: accessKey');
        this.bucket = bucket;
        this.accessKey = accessKey;
        this.secret = secret;
        this.host = 'storage.googleapis.com';
    }

    /**
    * accepts-ranges
    * @return String
    */
    global override String acceptRanges() { return 'bytes'; }

    /**
    * limit on
    * @return String[]
    */
    global override String[] limitOn() { return new String[] { 'callouts' }; }

    /**
    * copies a object
    * @param path the path
    * @param newPath the new path
    * @see https://cloud.google.com/storage/docs/copying-renaming-moving-objects
    */
    global override void copy(String path, String newPath) {
        SystemX.debug('copy: ' + path + ', ' + newPath);
        path = urlEncode(path);
        HttpRequest req = createRequest('PUT', newPath, null, null, new Map<String, String> { 'x-amz-copy-source' => bucket + '/' + path });
        req.setBody('');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * deletes an object
    * @param path the path
    * @see https://cloud.google.com/storage/docs/deleting-objects
    */
    global override void deletex(String path) {
        SystemX.debug('deletex: ' + path);
        HttpRequest req = createRequest('DELETE', path, null, null, null);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * gets an object
    * @param path the kepathy
    * @param range the range
    * @return Blob
    * @see https://cloud.google.com/storage/docs/downloading-objects
    */
    global override Blob get(String path, Range range) {
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('GET', path, contentType, range, null);
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 416) { return null; }
        else if (res.getStatusCode() < 200 || res.getStatusCode() > 210) { throw new HandledException(res.toString() + '\n' + res.getBody()); }
        return res.getBodyAsBlob();
    }

    /**
    * moves an object
    * @param path the path
    * @param newPath the new path
    * @see https://cloud.google.com/storage/docs/copying-renaming-moving-objects
    */
    global override void move(String path, String newPath) {
        SystemX.debug('move: ' + path + ', ' + newPath);
        path = urlEncode(path);
        HttpRequest req = createRequest('PUT', newPath, null, null, new Map<String, String> { 'x-amz-copy-source' => bucket + '/' + path });
        req.setBody('');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        // second call
        req = createRequest('DELETE', path, null, null, null);
        res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * lists all objects
    * @param prefix the prefix
    * @param filters the filters
    * @return List<File>
    * @see https://cloud.google.com/storage/docs/listing-objects
    */
    global override List<File> listx(String prefix, String filters) {
        List<File> r = new List<File>();
        HttpRequest req = createRequest('GET', '?list-type=2' + (!String.isEmpty(prefix) ? '&prefix=' + prefix : ''), null, null, new Map<String, String> { 'ACL' => 'public-read' });
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
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
    * puts an object
    * @param path the path
    * @param range the range
    * @param content the content
    * @see https://cloud.google.com/storage/docs/uploading-objects
    */
    global override void put(String path, Range range, Object content) {
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('PUT', path, contentType, range, new Map<String, String> { 'ACL' => 'public-read' });
        if (content == null) { }
        else if (content instanceOf Blob) req.setBodyAsBlob((Blob)content);
        else if (content instanceOf String) req.setBody((String)content);
        else req.setBody(content.toString());
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
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
    * @see https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html
    */
    global override void abortMultipart(File entry, List<Object> parts) {
        SystemX.debug('abortMultipart: ' + entry.path);
        String path = entry.path;
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('DELETE', path + '&uploadId=' + entry.tag, contentType, null, null);
        req.setBody('');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * creates a multipart upload
    * @param path the path
    * @return File
    */
    global override File createMultipart(String path) {
        SystemX.debug('createMultipart: ' + path);
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('POST', path + '&uploads', contentType, null, null);
        req.setBody('');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
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
    * @return Storage.File
    */
    global override File completeMultipart(File entry, List<Object> parts) {
        SystemX.debug('completeMultipart: ' + entry.path);
        String path = entry.path;
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('POST', path + '?uploadId=' + entry.tag, contentType, null, null);
        List<String> b = new List<String>();
        b.add('<?xml version="1.0" encoding="UTF-8"?>');
        b.add('<CompleteMultipartUpload xmlns="http://s3.amazonaws.com/doc/2006-03-01/">');
        for (Object part : parts) b.add((String)part);
        b.add('</CompleteMultipartUpload>');
        req.setBody(String.join(b, ''));
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
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
        HttpRequest req = createRequest('PUT', path + '?partNumber=' + partNumber + '&uploadId=' + entry.tag, contentType, null, null);
        if (content == null) { }
        else if (content instanceOf Blob) req.setBodyAsBlob((Blob)content);
        else if (content instanceOf String) req.setBody((String)content);
        else req.setBody(content.toString());
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        String etag = res.getHeader('ETag');
        return '<Part><PartNumber>' + partNumber + '</PartNumber><ETag>' + etag + '</ETag></Part>';
    }

    HttpRequest createRequest(String method, String key, String contentType, Range range, Map<String, String> headers) {
        key = urlEncode(key);
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + host + '/' + bucket + '/' + key.replaceFirst('\\?|&', '?'));
        req.setHeader('Host', host);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Connection', 'keep-alive');
        if (contentType != null) req.setHeader('Content-Type', contentType);
        if (range != null) req.setHeader('Range', 'bytes=' + range.start + '-' + range.endx);
        Set<String> headerKeys;
        if (headers != null) for (String s : headerKeys = headers.keySet()) req.setHeader(s, headers.get(s));
        CloudAws.signRequest(req, headerKeys, bucket, key, accessKey, secret);
        return req;
    }

    static String urlEncode(String value) { return value.replace(' ', '%20'); }
}
