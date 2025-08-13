/**
* Microsoft Azure (Azure)
* @see https://learn.microsoft.com/en-us/rest/api/storageservices/operations-on-blobs
*/
global class CloudAzure extends Cloud {
    String bucket;
    String accountName;
    String accessKey;
    String host;

    /**
    * creates a CloudAzure
    * @param namedCredential the namedCredential
    */
    global CloudAzure(String namedCredential) { this(NamedCredential__mdt.getInstance(namedCredential)); }
    /**
    * creates a CloudAzure
    * @param credential the NamedCredential__mdt
    */
    global CloudAzure(NamedCredential__mdt credential) { this(credential?.Bucket__c, credential?.ClientId__c, credential?.ClientSecret__c); }
    /**
    * creates a CloudAzure
    * @param bucket the bucket
    * @param accountName the accountName
    * @param accessKey the accessKey
    */
    global CloudAzure(String bucket, String accountName, String accessKey) {
        if (String.isEmpty(accountName) && !Test.isRunningTest()) throw new IllegalArgumentException('Required: accountName');
        this.bucket = bucket;
        this.accountName = accountName;
        this.accessKey = accessKey;
        this.host = accountName + '.blob.core.windows.net';
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
    * copies an object
    * @param path the path
    * @param newPath the new path
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/copy-blob
    */
    global override void copy(String path, String newPath) {
        SystemX.debug('copy: ' + path + ', ' + newPath);
        path = urlEncode(path);
        HttpRequest req = createRequest('PUT', newPath, null, null, new Map<String, String> { 'x-ms-copy-source' => 'https://' + host + '/' + bucket + '/' + path });
        req.setHeader('Content-Length', '0');
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * deletes an object
    * @param path the path
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/delete-blob
    */
    global override void deletex(String path) {
        SystemX.debug('deletex: ' + path);
        HttpRequest req = createRequest('DELETE', path, null, null, null);
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode == 404) { }
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * gets an object
    * @param path the path
    * @param range the range
    * @return Blob
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/get-blob
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
    */
    global override void move(String path, String newPath) {
        SystemX.debug('move: ' + path + ', ' + newPath);
        path = urlEncode(path);
        HttpRequest req = createRequest('PUT', newPath, null, null, new Map<String, String> { 'x-ms-copy-source' => 'https://' + host + '/' + bucket + '/' + path });
        req.setHeader('Content-Length', '0');
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        // second call
        req = createRequest('DELETE', path, null, null, null);
        res = new Http().send(req);
        statusCode = res.getStatusCode();
        if (statusCode == 404) { }
        else if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
    }

    /**
    * lists all objects
    * @param prefix the prefix
    * @param filters the filters
    * @return List<File>
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/list-blobs
    */
    global override List<File> listx(String prefix, String filters) {
        List<File> r = new List<File>();
        HttpRequest req = createRequest('GET', '?restype=container&comp=list' + (!String.isEmpty(prefix) ? '&prefix=' + prefix : ''), null, null, null);
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        Dom.Document doc = res.getBodyDocument();
        Dom.XmlNode root = doc.getRootElement();
        String ns = root.getNamespace();
        Dom.XmlNode blobs = root.getChildElement('Blobs', ns);
        if (blobs == null) return r;
        Boolean filterFile = filters?.contains('file') == true, filterSize = filters?.contains('size') == true;
        for (Dom.XmlNode child : blobs.getChildElements()) {
            if (child.getName() != 'Blob') continue;
            String key = child.getChildElement('Name', ns).getText();
            Dom.XmlNode properties = child.getChildElement('Properties', ns);
            Integer size = Integer.valueOf(properties.getChildElement('Content-Length', ns).getText());
            Datetime lastModified = DatetimeX.parse(properties.getChildElement('Last-Modified', ns).getText(), 'azure');
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
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/put-blob
    */
    global override void put(String path, Range range, Object content) {
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('PUT', path, contentType, range, new Map<String, String> { 'x-ms-blob-type' => 'BlockBlob' });
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
    global override Integer flushOn() { return 0; }

    /**
    * aborts a multipart upload
    * @param entry the entry
    * @param parts the parts
    * @see https://learn.microsoft.com/en-us/answers/questions/1194952/how-to-upload-large-files-in-chunks-using-rest-api
    */
    global override void abortMultipart(File entry, List<Object> parts) {
        SystemX.debug('abortMultipart: ' + entry.path);
    }

    /**
    * creates a multipart upload
    * @param path the path
    */
    global override File createMultipart(String path) {
        SystemX.debug('createMultipart: ' + path);
        return new File(path, path, 0, null);
    }
    
    /**
    * completes a multipart upload
    * @param entry the entry
    * @param parts the parts
    * @return File
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/put-block-list?tabs=microsoft-entra-id
    */
    global override File completeMultipart(File entry, List<Object> parts) {
        SystemX.debug('completeMultipart: ' + entry.path);
        String path = entry.path;
        String contentType = PathX.guessContentType(path);
        HttpRequest req = createRequest('PUT', path + '?comp=blocklist', contentType, null, null);
        List<String> b = new List<String>();
        b.add('<?xml version="1.0" encoding="UTF-8"?>');
        b.add('<BlockList>');
        for (Object part : parts) b.add((String)part);
        b.add('</BlockList>');
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
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/put-block?tabs=microsoft-entra-id
    */
    global override Object uploadPart(File entry, Object part, Object content) {
        SystemX.debug('uploadPart: ' + entry.path + '@' + part);
        String path = entry.path;
        Integer partNumber = Integer.valueOf(part);
        String contentType = PathX.guessContentType(path);
        String id = EncodingUtil.base64Encode(EncodingUtil.convertFromHex(IntegerX.intToHex(path.hashCode(), true) + IntegerX.intToHex(partNumber, true)));
        HttpRequest req = createRequest('PUT', path + '?comp=block&blockid=' + EncodingUtil.urlEncode(id, 'UTF-8'), contentType, null, null);
        if (content == null) { }
        else if (content instanceOf Blob) req.setBodyAsBlob((Blob)content);
        else if (content instanceOf String) req.setBody((String)content);
        else req.setBody(content.toString());
        HttpResponse res = new Http().send(req);
        Integer statusCode = res.getStatusCode();
        if (statusCode < 200 || statusCode > 210) throw new HandledException(res.toString() + '\n' + res.getBody());
        return '<Latest>' + id + '</Latest>';
    }

    HttpRequest createRequest(String method, String key, String contentType, Range range, Map<String, String> headers) {
        if (headers == null) headers = new Map<String, String>();
        headers.put('x-ms-version', '2021-12-02');
        key = urlEncode(key);
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + host + '/' + bucket + '/' + key);
        req.setHeader('Host', host);
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Connection', 'keep-alive');
        if (contentType != null) req.setHeader('Content-Type', contentType);
        if (range != null) req.setHeader('Range', 'bytes=' + range.start + '-' + range.endx);
        Set<String> headerKeys;
        if (headers != null) for (String s : headerKeys = headers.keySet()) req.setHeader(s, headers.get(s));
        signRequest(req, headerKeys, bucket, key, accountName, accessKey);
        return req;
    }

    static String urlEncode(String value) { return value.replace(' ', '%20'); }

    /**
    * signs an Azure request
    * @param req the req
    * @param headers the headers
    * @param bucket the bucket
    * @param key the key
    * @param accountName the accountName
    * @param accessKey the accessKey
    * @see https://learn.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
    */
    global static void signRequest(HttpRequest req, Set<String> headers, String bucket, String key, String accountName, String accessKey) {
        if (req.getHeader('Date') == null) { req.setHeader('Date', Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z')); }
        Integer keyIndex = key.indexOf('?');
        List<String> signValues = new List<String> {
            req.getMethod(),
            req.getHeader('Content-Md5'),
            req.getHeader('Content-Type'),
            req.getHeader('Date')
        };
        // canonicalized headers
        if (headers != null && !headers.isEmpty()) {
            List<String> canHeaders = new List<String>();
            for (String k : headers) { k = k.toLowerCase(); if (k.startsWith('x-ms-')) canHeaders.add(k); }
            if (!canHeaders.isEmpty()) { canHeaders.sort(); for (String k : canHeaders) signValues.add(k + ':' + req.getHeader(k)); }
        }
        // canonicalized resource
        String query = '';
        if (keyIndex != -1) {
            List<String> keys = new List<String>();
            Map<String, String> values = new Map<String, String>();
            for (String z : key.substring(keyIndex + 1).split('&')) {
                String[] split = z.split('=', 2);
                String k = split[0].toLowerCase(), v = split.size() > 1 ? split[1] : null;
                // The query string should include the question mark and the comp parameter
                if (k != 'comp') continue;
                keys.add(k);
                values.put(k, v);
            }
            keys.sort();
            for (String k : keys) { query += '&' + k + (values.get(k) != null ? '=' + values.get(k) : ''); }
            query = query.replaceFirst('\\?|&', '?');
            // remove query
            key = key.left(keyIndex);
        }
        signValues.add('/' + accountName + '/' + bucket + '/' + key + query);

        // sign authorization
        if (accessKey != null) {
            String stringToSign = String.join(signValues, '\n');
            Blob mac = Crypto.generateMac('HMAC-SHA256', Blob.valueOf(stringToSign), EncodingUtil.base64Decode(accessKey));
            String signature = EncodingUtil.base64Encode(mac);
            String authorization = 'SharedKeyLite ' + accountName + ':' + signature;
            req.setHeader('Authorization', authorization);
        }
    }
}
