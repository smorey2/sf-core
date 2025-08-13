/**
* Salesforce Commerce Cloud (SFCC)
*/
global class CloudSfcc extends Cloud {
    String clientId;
    String certificateName;
    String version;

    /**
    * creates a CloudSfcc
    * @param namedCredential the namedCredential
    */
    global CloudSfcc(String namedCredential) { this(NamedCredential__mdt.getInstance(namedCredential)); }
    /**
    * creates a CloudSfcc
    * @param credential the NamedCredential__mdt
    */
    global CloudSfcc(NamedCredential__mdt credential) { this(credential?.ClientId__c, credential?.ClientSecret__c, credential?.Tag__c); }
    /**
    * creates a CloudSfcc
    * @param clientId the clientId
    * @param certificateName the certificateName
    * @param version the version
    */
    global CloudSfcc(String clientId, String certificateName, String version) {
        if (String.isEmpty(clientId) && !Test.isRunningTest()) throw new IllegalArgumentException('Required: clientId');
        this.clientId = clientId;
        this.certificateName = certificateName;
        this.version = String.valueOf(version != null ? Decimal.valueOf(version) : 24.1).replace('.', '_');
    }

    /**
    * endpoint
    * @param type the type
    * @param endpoint the endpoint
    * @return String
    */
    global override String endpoint(String type, String endpoint) {
        String site = endpoint.substringBefore(':'); endpoint = endpoint.substringAfter(':');
        if (String.isEmpty(endpoint)) { endpoint = site; site = ''; }
        else if (String.isNotEmpty(site)) site = '/sites/' + site;
        switch on type {
            when 'data' { return '/s/-/dw/data/v' + version + site + '/' + endpoint; }
            when 'shop' { return '/s/-/dw/shop/v' + version + site + '/' + endpoint; }
            when else { throw new HandledException('Unknown type: ' + type); }
        }
    }

    /**
    * gets a SFCC access token
    * @param arg the arg
    * @return Map<String, Object>
    */
    global override Map<String, Object> accessToken(String arg) {
        // constructing the header and claims
        String endpoint = 'https://account.demandware.com:443/dwsso/oauth2/access_token';
        String iss = clientId, sub = clientId, aud = endpoint;
        Long exp = Datetime.now().addMinutes(29).getTime() / 1000;
        String jwtHeader = '{"typ":"JWT","alg":"RS256"}';
        String jwtClaims = '{"iss":"' + iss + '","sub":"' + sub + '","aud":"' + aud + '","exp":' + exp + '}';
        String jwtRequest = System.EncodingUtil.base64Encode(Blob.valueOf(jwtHeader)).replace('+', '-').replace('/', '_') + '.' +
            System.EncodingUtil.base64Encode(Blob.valueOf(jwtClaims)).replace('+', '-').replace('/', '_');
        Blob signatureBlob = Test.isRunningTest()
            ? Blob.valueOf('signed')
            : Crypto.signWithCertificate('RSA-SHA256', Blob.valueOf(jwtRequest), certificateName);
        String signature = System.EncodingUtil.base64Encode(signatureBlob).replace('+', '-').replace('/', '_');
        String signedJwtRequest = jwtRequest + '.' + signature;
        // The JWT is fully constructed, now it's time to make the call to get the access token.
        String body = 'grant_type=client_credentials&client_assertion_type=' +
            System.EncodingUtil.urlEncode('urn:ietf:params:oauth:client-assertion-type:jwt-bearer', 'UTF-8') +
            '&client_assertion=' + signedJwtRequest;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Connection', 'keep-alive'); 
        req.setTimeout(120000);
        req.setBody(body);
        HttpResponse res;
        if (Test.isRunningTest()) {
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"accessToken","token_type":"Bearer"}');
        }
        else res = new Http().send(req);
        if (res.getStatusCode() != 200) return null;
        Map<String, Object> r = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        r.put('Authorization', r.get('token_type') + ' ' + r.get('access_token'));
        return r;
    }

    // /**
    // * makes a SFCC batched callout
    // * @param callout the callout
    // * @param accessToken the accessToken
    // * @param batch the batch
    // * @param headerArgs the header Args
    // * @param args the args
    // * @return HttpResponse[]
    // */
    // global static HttpResponse[] callout(String callout, Map<String, Object> accessToken, List<Map<String, Object>> batch, Map<String, Object> headerArgs, Map<String, Object> args) {
    //     if (callout == null) throw new HandledException('Required: callout');
    //     // batch and return
    //     Integer batchSize = headerArgs.containsKey('batchSize') ? (Integer)headerArgs.get('batchSize') : 50;
    //     if (args != null) { batch.add(args); if (batch.size() < batchSize) { return null; } }
    //     if (batch.isEmpty()) { return null; }

    //     // submit batch
    //     String boundary = '23dh3f9f4';
    //     callout = callout.startsWithIgnoreCase('http') ? callout : 'callout:' + callout;
    //     HttpRequest req = new HttpRequest();
    //     req.setTimeout(120000);
    //     req.setMethod('POST');
    //     req.setEndpoint(callout);
    //     req.setHeader('Content-Type', 'multipart/mixed; boundary=' + boundary);
    //     if (accessToken != null && accessToken.containsKey('Authorization')) req.setHeader('Authorization', (String)accessToken.get('Authorization'));
    //     req.setEndpoint(callout + '/s/-/dw/batch');
    //     for (String key : headerArgs.keySet()) {
    //         Object value = headerArgs.get(key);
    //         switch on key {
    //             when 'method' { req.setHeader('x-dw-http-method', String.valueOf(value)); }
    //             when 'method-override' { req.setHeader('x-dw-http-method-override', String.valueOf(value)); }
    //             when 'endpoint' { req.setHeader('x-dw-resource-path', String.valueOf(value)); }
    //             when else { req.setHeader(key, String.valueOf(value)); }
    //         }
    //     }
	// 	List<String> body = new List<String>(); Integer r = 0;
	// 	for (Map<String, Object> s : batch) {
    //         body.add('--' + boundary);
    //         body.add('x-dw-content-id: r' + String.valueOf(++r));
    //         if (s.containsKey('method')) { body.add('x-dw-http-method: ' + String.valueOf(s.get('method'))); }
    //         if (s.containsKey('endpoint')) { body.add('x-dw-resource-path-extension: ' + String.valueOf(s.get('endpoint'))); }
    //         body.add('');
    //         if (s.containsKey('body')) {
    //             Object value = s.get('body');
    //             if (value instanceOf String) { body.add((String)value); }
    //             else { body.add(JSON.serialize(value, true)); }
    //         }
    //     }
    //     body.add('--' + boundary + '--');
	// 	req.setBody(String.join(body, '\n'));
    //     batch.clear();

    //     // make callout
    //     Integer retries = headerArgs.containsKey('retries') ? (Integer)headerArgs.get('retries') : 0;
    //     Http http = new Http();
    //     HttpResponse[] r = new HttpResponse[0];
    //     try {
    //         String rep;
    //         while (retries-- >= 0)
    //             try { rep = http.send(req).getBody(); break; }
    //             catch (CalloutException e) { if (retries >= 0 && e.getMessage().startsWith('Exceeded maximum time allotted for callout')) { SystemX.debug('RETRY ' + retries + ' ' + e.getMessage()); continue; } throw e; }
    //         // SystemX.debug('REP:' + rep);
    //         if (batchSize == 0) {
    //             HttpResponse res = new HttpResponse();
    //             res.setBody(rep);
    //             res.setStatusCode(200);
    //             r.add(res);
    //             return r;
    //         }
    //         for (String part : rep.split('--' + boundary)) {
    //             Integer partIndex = part.indexOf('\n\n');
    //             if (partIndex == -1) continue;
    //             HttpResponse res = new HttpResponse();
    //             for (String headerBody : part.substring(1, partIndex).split('\n')) {
    //                 String[] header = headerBody.split(': ');
    //                 String headerKey = header[0];
    //                 String headerValue = header[1];
    //                 if (headerKey == 'x-dw-content-id') continue;
    //                 else if (headerKey == 'x-dw-status-code') { res.setStatusCode(Integer.valueOf(headerValue)); continue; }
    //                 res.setHeader(headerKey, headerValue);
    //             }
    //             res.setBody(part.substring(partIndex + 2));
    //             r.add(res);
    //         }
    //     }
    //     catch (Exception e) {
    //         String errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
    //         SystemX.debug(errorMessage);
    //         HttpResponse res = new HttpResponse();
    //         res.setBody(errorMessage);
    //         res.setStatusCode(500);
    //         r.add(res);
    //     }
    //     return r;
    // }
}