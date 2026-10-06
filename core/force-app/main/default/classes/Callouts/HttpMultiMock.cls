/**
* a MultiMock for HttpCalloutMock
*/
@isTest
global class HttpMultiMock implements System.HttpCalloutMock {
    global Map<String, System.HttpCalloutMock> mocks;
    global String variant;

    /**
    * creates a MultiMock
    */
    global HttpMultiMock() { this(new Map<String, System.HttpCalloutMock>(), null); }
    /**
    * creates a MultiMock
    * @param mocks the callout mocks
    */
    global HttpMultiMock(Map<String, System.HttpCalloutMock> mocks) { this(mocks, null); }
    /**
    * creates a MultiMock
    * @param mocks the callout mocks
    * @param variant the callout variant
    */
    global HttpMultiMock(Map<String, System.HttpCalloutMock> mocks, String variant) { this.mocks = mocks ?? new Map<String, System.HttpCalloutMock>(); this.variant = variant; }

    /**
    * responds to a mock call
    * @param request the request
    */
    global HttpResponse respond(HttpRequest request) {
        String name, msg;
        if (variant == null) {
            name = request.getEndpoint(); msg = 'Mock not found for endpoint: ' + name;
        }
        else if (variant.startsWithIgnoreCase('header:')) {
            String header = variant.substring(7);
            name = request.getHeader(header); msg = 'Mock not found for header: ' + header + ':' + name;
        }
        else throw new HandledException('Unknown variant: ' + variant);
        System.HttpCalloutMock mock = mocks.get(name);
        if (mock != null) return mock.respond(request);
        else throw new HandledException(msg);
    }
}