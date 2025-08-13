/**
* Http extensions
*/
global class HttpX implements Database.AllowsCallouts {
    /**
    * sends a request
    * @param endpoint the endpoint
    * @param accessToken the accessToken
    * @param args the args
    * @return HttpResponse
    */
    global static HttpResponse send(String endpoint, Map<String, Object> accessToken, Map<String, Object> args) {
        if (endpoint == null) throw new HandledException('Required: endpoint');
        endpoint = endpoint.startsWithIgnoreCase('http') ? endpoint : 'callout:' + endpoint;
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        if (accessToken != null && accessToken.containsKey('Authorization')) req.setHeader('Authorization', (String)accessToken.get('Authorization'));
        for (String key : args.keySet()) {
            Object value = args.get(key);
            switch on key {
                when 'method' { req.setMethod(String.valueOf(value)); }
                when 'endpoint' { req.setEndpoint(endpoint + String.valueOf(value)); }
                when 'body' {
                    if (value instanceOf String) req.setBody((String)value);
                    else req.setBody(JSON.serialize(value, true));
                }
                when else { req.setHeader(key, String.valueOf(value)); }
            }
        }
        HttpResponse res;
        try { res = new Http().send(req); }
        catch (Exception e) {
            String errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
            SystemX.debug(errorMessage);
            res = new HttpResponse();
            res.setBody(errorMessage);
            res.setStatusCode(500);
        }
		return res;
    }
}
