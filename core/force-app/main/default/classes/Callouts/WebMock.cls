/**
* a Mock for WebMock
*/
@isTest
global class WebMock implements WebServiceMock {
    global Object responseBody;

    /**
    * creates a Mock
    */
    global WebMock() { }
    /**
    * creates a Mock
    * @param responseBody the response body
    */
    global WebMock(Object responseBody) { this.responseBody = responseBody; }

    /**
    * responds to a mock call
    * @param stub the stub
    * @param request the request
    * @param response the response
    * @param endpoint the endpoint
    * @param soapAction the soapAction
    * @param requestName the requestName
    * @param responseNS the responseNS
    * @param responseName the responseName
    * @param responseType the responseType
    */
    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
        if (responseBody instanceof Type)
            responseBody = Core.invoke((Type)responseBody, new Map<String, Object> {
                'request' => request,
                'soapAction' => soapAction,
                'requestName' => requestName,
                'responseName' => responseName,
                'responseType' => responseType
            });
        response.put('response_x', responseBody);
   }
}