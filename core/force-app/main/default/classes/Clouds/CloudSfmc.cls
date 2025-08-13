/**
* SFMC implementation of cloud methods
*/
global class CloudSfmc extends Cloud {
    String accountId;
    String endpoint;
    String body;

    /**
    * creates a CloudSfmc
    * @param namedCredential the namedCredential
    */
    global CloudSfmc(String namedCredential) { this(NamedCredential__mdt.getInstance(namedCredential)); }
    /**
    * creates a CloudSfmc
    * @param credential the NamedCredential__mdt
    */
    global CloudSfmc(NamedCredential__mdt credential) { this(credential?.Bucket__c, credential?.ClientId__c, credential?.ClientSecret__c, credential?.Tag__c); }
    /**
    * creates a CloudSfmc
    * @param stackAccountId the stackAccountId
    * @param clientId the clientId
    * @param clientSecret the clientSecret
    * @param scope the scope
    */
    global CloudSfmc(String stackAccountId, String clientId, String clientSecret, String scope) {
        String stack = stackAccountId.substringBefore(':').toLowerCase(), accountId = stackAccountId.substringAfter(':');
        if (String.isEmpty(clientId) && !Test.isRunningTest()) throw new IllegalArgumentException('Required: clientId');
        this.accountId = accountId;
        scope = scope == null ? 'null' : '"' + scope + '"';
        endpoint = 'https://' + stack + '.auth.marketingcloudapis.com/v2/token';
        body = '{"grant_type":"client_credentials","client_id":"' + clientId + '","client_secret":"' + clientSecret + '","scope":' + scope + ',"account_id":"{accountId}"}';
    }

    /**
    * endpoint
    * @param type the type
    * @param endpoint the endpoint
    * @return String
    */
    global override String endpoint(String type, String endpoint) {
        switch on type {
            when 'trigger' { return 'messaging/v1/messageDefinitionSends/key:' + endpoint + '/send'; }
            when else { throw new HandledException('Unknown type: ' + type); }
        }
    }

    /**
    * gets a SFMC access token
    * @param arg the account id
    * @return Map<String, Object>
    */
    global override Map<String, Object> accessToken(String arg) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Connection', 'keep-alive'); 
        req.setTimeout(120000);
        req.setBody(body.replace('{accountId}', arg ?? this.accountId));  
        HttpResponse res;
        if (Test.isRunningTest()) {
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"accessToken","token_type":"Bearer","expires_in":1079,"scope":"scope",' +
                '"soap_instance_url":"https://x.soap.marketingcloudapis.com/","rest_instance_url":"https://x.rest.marketingcloudapis.com/"}');
        }
        else res = new Http().send(req);
        if (res.getStatusCode() != 200) return null;
        Map<String, Object> r = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        r.put('Authorization', r.get('token_type') + ' ' + r.get('access_token'));
        return r;
    }
}