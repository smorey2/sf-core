/**
* OAuth
*/
global class CloudOauth extends Cloud {
    String endpoint;
    String contentType;
    String body;

    /**
    * creates a CloudOauth
    * @param namedCredential the namedCredential
    */
    global CloudOauth(String namedCredential) { this(NamedCredential__mdt.getInstance(namedCredential)); }
    /**
    * creates a CloudOauth
    * @param credential the NamedCredential__mdt
    */
    global CloudOauth(NamedCredential__mdt credential) { this(credential?.Endpoint__c, credential?.Bucket__c, credential?.ClientId__c, credential?.ClientSecret__c, credential?.Tag__c); }
    /**
    * creates a CloudOauth
    * @param endpoint the endpoint
    * @param bucket the bucket
    * @param clientId the clientId
    * @param clientSecret the clientSecret
    * @param scope the scope
    */
    global CloudOauth(String endpoint, String bucket, String clientId, String clientSecret, String scope) {
        if (String.isEmpty(clientId) && !Test.isRunningTest()) throw new IllegalArgumentException('Required: clientId');
        this.endpoint = endpoint;
        String kind = bucket.substringBefore(':').toLowerCase(), grantType = bucket.substringAfter(':');
        if (grantType == null) grantType = 'client_credentials';
        scope = scope == null ? 'null' : '"' + scope + '"';
        switch on kind {
            when 'json' { contentType = 'application/json'; body = '{"grant_type":"' + grantType + '","client_id":"' + clientId + '","client_secret":"' + clientSecret + '","scope":' + scope + '}'; }
            when 'json2' { contentType = 'application/json'; body = '{"grantType":"' + grantType +'","clientId":"' + clientId + '","clientIdentifier":"' + clientSecret + '","scope":' + scope + '}'; }
            when 'form' { contentType = 'application/x-www-form-urlencoded'; body = 'grant_type=' + grantType + '&client_id=' + clientId + '&client_secret=' + clientSecret; }
            when else { throw new HandledException('Unknown kind: ' + kind); }
        }
    }

    /**
    * accessToken
    * @param arg the arg
    * @return Map<String, Object>
    */
    global override Map<String, Object> accessToken(String arg) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Connection', 'keep-alive'); 
        req.setTimeout(120000);
        req.setBody(body);  
        HttpResponse res;
        if (Test.isRunningTest()) {
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"accessToken","token_type":"Bearer","expires_in":1079,"scope":"scope"}');
        }
        else res = new Http().send(req);
        if (res.getStatusCode() != 200) return null;
        Map<String, Object> r = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        if (!r.containsKey('access_token') && r.containsKey('token')) r.put('access_token', r.get('token'));
        if (!r.containsKey('token_type')) r.put('token_type', 'Bearer');
        r.put('Authorization', r.get('token_type') + ' ' + r.get('access_token'));
        return r;
    }
}