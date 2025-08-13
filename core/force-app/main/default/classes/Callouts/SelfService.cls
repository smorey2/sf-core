/**
* an endpoint for tokens
*/
@RestResource(urlMapping='/self/*')
global class SelfService {
    /**
    * get handler
    */
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		res.headers.put('Content-Type', 'application/json');
		res.statusCode = 200;
        try {
			String action = req.params.get('a');
			switch on action {
				when 'sessionId' { res.responseBody = Blob.valueOf(UserInfo.getSessionId()); }
				when else { throw new HandledException('Unknown action: ' + action); }
			}
        }
		catch (Exception e) {
            String body = e.getMessage() + '\n' + e.getStackTraceString();
            // System.debug(body);
			res.statusCode = 500;
			res.responseBody = Blob.valueOf(body);
        }
	}

    /**
    * gets a sessionId
    * @return String
    */
    public static String getSessionId() { return get('sessionId'); }

    /**
    * gets a value
    * @return String
    */
    public static String get(String action) {
        HttpRequest req = new HttpRequest();
		req.setMethod('GET');
        req.setHeader('Accept', '*/*');
		req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		req.setHeader('User-Agent', 'Rest/v1.0 (Language=Apex)');
        req.setEndpoint('callout:Self/services/apexrest/self?a=' + action);
		req.setTimeout(120000);
        HttpResponse res = new Http().send(req);
		return res.getBody();
    }
}