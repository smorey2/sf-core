/**
* a Mock for HttpCalloutMock
*/
@isTest
global class HttpMock implements System.HttpCalloutMock {
    global HttpResponse response;
    global Integer responseCode;
    global Blob responseBodyAsBlob; String responseBody;
    global String responseStatus;
    global Map<String, String> responseHeaders = new Map<String, String>();

    /**
    * creates a Mock
    */
    global HttpMock() { }
    /**
    * creates a Mock
    * @param responseCode the response code
    * @param responseBody the response body
    */
    global HttpMock(Integer responseCode, Object responseBody) {
        this.responseCode = responseCode;
        if (responseBody == null) { }
        else if (responseBody instanceOf Blob) this.responseBodyAsBlob = (Blob)responseBody;
        else if (responseBody instanceOf String) this.responseBody = (String)responseBody;
        else this.responseBody = responseBody.toString();
    }

    /**
    * responds to a mock call
    * @param request the request
    */
    global HttpResponse respond(HttpRequest request) {
        response = new HttpResponse();
        if (responseCode != null) response.setStatusCode(responseCode);
        if (responseStatus != null) response.setStatus(responseStatus);
        if (responseBodyAsBlob != null) response.setBodyAsBlob(responseBodyAsBlob); else if (responseBody != null) response.setBody(responseBody);
        if (responseHeaders?.size() > 0) for (String headerKey : responseHeaders.keySet()) response.setHeader(headerKey, responseHeaders.get(headerKey));
        String range = request.getHeader('Range');
        if (String.isNotEmpty(range)) {
            if (!range.startsWithIgnoreCase('bytes=')) throw new HandledException('Only bytes range supported');
            Blob body = response.getBodyAsBlob();
            if (body != null) {
                String[] values = range.substring(6).split('-', 2);
                body = BlobX.subblob(body, Integer.valueOf(values[0]), range.length() > 1 ? Integer.valueOf(values[1]) : 0);
                response.setBodyAsBlob(body);
            }
        }
        return response;
    }
}