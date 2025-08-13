/**
* http task
*/
global abstract class HttpTask {
    global Object request;
    global Object response;
    global Object arg;
    global String successMessage;
    global String errorMessage;
    global List<Tuple2> pragmas;
    global String proxy;
    global Tuple4 log;
    global HttpTask rollbackx;
    global IHttpLambda thenx;
    global IHttpLambda endx;
    global String debug;
    // log
    global Object logRequest;
    global Object logResponse;
    // bind
    global Map<String, Object> values;
    global Object id;
    global Object path;

    /**
    * constructor
    */
    global HttpTask(Object request, Object arg, String successMessage, String errorMessage) { this.request = request; this.arg = arg; this.successMessage = successMessage; this.errorMessage = errorMessage; }

    /**
    * Empty
    */
    global class Empty extends HttpTask {
        global Empty(Object request) { super(request, null, null, null); }
        global override Object callout(HttpBatch batch) { return null; }
    }

    //#region fluent

    /**
    * sets the pragma
    * @param name the name
    * @param value the value
    * @return HttpTask
    */
    global HttpTask pragma(String name, Object value) { pragmas = pragmas ?? new List<Tuple2>(); pragmas.add(new Tuple2(name, value)); return this; }

    /**
    * proxy
    * @param proxy the proxy
    * @return HttpRestTask
    */
    global HttpTask proxy(String proxy) { this.proxy = proxy; return this; }

    /**
    * sets the log
    * @param interactionType the interactionType
    * @param relatedTo the relatedTo
    * @param relatedTo2 the relatedTo2
    * @param message the message
    * @return HttpTask
    */
    global HttpTask log(String interactionType, Id relatedTo, Id relatedTo2, String message) { log = new Tuple4(interactionType, relatedTo, relatedTo2, message); return this; }

    /**
    * sets the rollsback
    * @param task the task
    * @return HttpTask
    */
    global HttpTask rollback(HttpTask task) { rollbackx = task; return this; }

    /**
    * sets the then
    * @param lambda the lambda
    * @return HttpTask
    */
    global HttpTask then(IHttpLambda lambda) { thenx = lambda; return this; }

    /**
    * sets the end
    * @param lambda the lambda
    * @return HttpTask
    */
    global HttpTask end(IHttpLambda lambda) { endx = lambda; return this; }

    /**
    * sets the debug
    * @param msg the msg
    * @return HttpTask
    */
    global HttpTask debug(String msg) { debug = msg; return this; }

    /**
    * binds the task
    * @param values the values
    * @param id the id
    * @param path the path
    * @return HttpTask
    */
    global HttpTask bind(Map<String, Object> values, Object id, Object path) { this.values = values; this.id = id; this.path = path; return this; }

    //#endregion

    //#region bind

    /**
    * rebinds the values
    * @param value the value
    * @return Object
    */
    global Object rebind(Object value) { return values != null ? ObjectX.mergex(values, value) : value; }

    //#endregion

    //#region result

    /**
    * returns the result
    * @return Object
    */
    global Object result() { return response ?? call(null); }
    /**
    * returns the result
    * @param batch the batch
    * @return Object
    */
    global Object result(HttpBatch batch) { return response ?? call(batch); }

    /**
    * returns the result and ends
    * @param batch the batch
    * @param success the success
    * @return Object
    */
    global Object result(HttpBatch batch, Boolean success) { Object s = response ?? call(batch); endx?.end(this, batch, success); return s; }

    /**
    * waits for the call
    */
    global void wait() { Object s = response ?? call(null); }
    /**
    * waits for the call
    * @param batch the batch
    */
    global void wait(HttpBatch batch) { Object s = response ?? call(batch); }

    //#endregion

    //#region callout

    /**
    * native callout
    * @param batch the batch
    * @return Object
    */
    global abstract Object callout(HttpBatch batch);

    /**
    * makes the call
    * @param batch the batch
    * @return Object
    */
    Object call(HttpBatch batch) {
        String gatewayMessage = null, errorMessage = null;
        try {
            response = callout(batch);
            gatewayMessage = this.successMessage; errorMessage = '';
            if (thenx != null) SystemX.debug('then: ' + String.valueOf(thenx).substringBefore(':'));
            thenx?.then(this, batch, response);
            if (debug != null) SystemX.debug(debug.replace('{0}', response?.toString() ?? 'null'));
        }
        catch (Exception e) {
            gatewayMessage = this.errorMessage; errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
            SystemX.debug(System.LoggingLevel.ERROR, errorMessage);
            throw e;
        }
        finally { logCall(log, logRequest, logResponse, gatewayMessage, errorMessage); }
        return response;
    }

    /**
    * calloutLimit
    * @return Integer
    */
    global virtual Integer calloutLimit() { return 3; }

    /**
    * calloutRetry
    * @param limitx the limitx
    * @param res the response
    */
    global virtual Boolean calloutRetry(Integer limitx, HttpResponse res) { return false; }

    //#endregion

    //#region handlers

    /**
    * logs the call
    * @param log the log
    * @param request the request
    * @param response the response
    * @param gatewayMessage the gatewayMessage
    * @param errorMessage the errorMessage
    */
    global virtual void logCall(Tuple4 log, Object request, Object response, String gatewayMessage, String errorMessage) { }

    //#endregion
}