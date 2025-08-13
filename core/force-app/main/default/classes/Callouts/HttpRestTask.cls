/**
* http rest task
*/
global virtual class HttpRestTask extends HttpTask {
    String newToken;
    String base;
    Type responseType;
    global HttpRestTask(Object request, Type responseType, String endpoint, String successMessage, String errorMessage) { super(request, endpoint, successMessage, errorMessage); this.responseType = responseType; }

    //#region Callable

    /**
    * parses the response
    * @param s the HttpResponse
    * @param body the body
    * @return Object
    */
    global virtual Object parseResponse(HttpResponse s, String body) {
		return responseType != null
            ? JSON.deserialize(body, responseType)
            : JSON.deserializeUntyped(body);
	}

	/**
    * errors the response
    * @param s the HttpResponse
    * @param body the body
    * @param errorMessage the errorMessage
    * @return Object
    */
    global virtual Object errorResponse(HttpResponse s, String body, String errorMessage) {
        SystemX.debug(body + '\n' + errorMessage);
        throw new HandledException(errorMessage ?? body);
    }

    /**
    * callout
    * @param batch the batch
    * @return Object
    * @see https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4FgWSAV
    * @see https://www.salesforceben.com/how-to-set-up-persisting-oauth-tokens-in-salesforce/
    */
    global override Object callout(HttpBatch batch) {
        HttpRequest req = new HttpRequest(); logRequest = req;
        String endpoint = base != null && base != 'sites' ? base : Url.getOrgDomainUrl().toExternalForm(), token, authorization = 'Bearer ' + (token = token());
        if (base == 'sites') endpoint = endpoint.replace('my.salesforce.com', 'my.salesforce-sites.com');
		req.setMethod('POST');
        req.setHeader('Accept', '*/*');
		req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		req.setHeader('User-Agent', 'Rest/v1.0 (Language=Apex)');
		req.setHeader('Authorization', authorization);
		req.setHeader('Authorization2', authorization);
        if (proxy != null) { req.setEndpoint(proxy); req.setHeader('Endpoint', endpoint + arg); }
        else req.setEndpoint(endpoint + arg);
		req.setBody(JSON.serialize(request, true));
		req.setTimeout(120000);

		// send request
        HttpResponse res; String body = null;
		try {
            for (Integer call = 2; call > 0; call--) {
			    res = new Http().send(req); logResponse = res;
                body = res.getBody();
                if (body.contains('[{"message":"INVALID_AUTH_HEADER","errorCode":"INVALID_AUTH_HEADER"}]') ||
                    body.contains('[{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}]')) {
                    if (call == 2) {
                        authorization = 'Bearer ' + (token = newToken = refreshToken(token));
                        req.setHeader('Authorization', authorization);
                        req.setHeader('Authorization2', authorization);
                        continue;
                    }
                    else throw new HandledException('Pending: Session expired or invalid');
                }
                else if (body.startsWith('RejectedCallException:')) throw new HandledException(body);
                break;
            }
            Object obj = res.getStatusCode() == 200
                ? parseResponse(res, body)
                : errorResponse(res, body, null);
            if (path == null) { }
            else if (path instanceof String) values.put((String)id, obj);
			return obj;
		} 
		catch (Exception e) {
            return errorResponse(res, body, e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
	
    public virtual String token() { return newToken ?? UserInfo.getSessionId(); }
    public virtual String refreshToken(String token) { return SelfService.getSessionId(); }

    //#endregion
}