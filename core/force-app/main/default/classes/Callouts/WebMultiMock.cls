/**
* a MultiMock for WebServiceMock
*/
@isTest
global class WebMultiMock implements WebServiceMock {
    global Map<String, WebServiceMock> mocks;
    global String variant;

    /**
    * creates a MultiMock
    */
    global WebMultiMock() { this(new Map<String, WebServiceMock>(), null); }
    /**
    * creates a MultiMock
    * @param mocks the callout mocks
    */
    global WebMultiMock(Map<String, WebServiceMock> mocks) { this(mocks, null); }
    /**
    * creates a MultiMock
    * @param mocks the callout mocks
    * @param variant the callout variant
    */
    global WebMultiMock(Map<String, WebServiceMock> mocks, String variant) { this.mocks = mocks ?? new Map<String, WebServiceMock>(); this.variant = variant; }

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
        String name, errorMessage;
        if (variant == null) {
            name = endpoint + '#' + soapAction;
            errorMessage = 'Mock not found for endpoint: ' + name;
        }
        else throw new HandledException('Unknown variant: ' + variant);
        WebServiceMock mock = mocks.get(name);
        if (mock != null) mock.doInvoke(stub, request, response, endpoint, soapAction, requestName, responseNS, responseName, responseType);
        else throw new HandledException(errorMessage);
    }
}