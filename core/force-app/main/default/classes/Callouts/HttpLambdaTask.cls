/**
* http lambda task
*/
global virtual class HttpLambdaTask extends HttpTask {

    global HttpLambdaTask(Object request, Object arg, String successMessage, String errorMessage) { super(request, arg, successMessage, errorMessage); }

    //#region callout

    /**
    * callout
    * @param batch the batch
    * @return Object
    */
    global override Object callout(HttpBatch batch) { return null; }

    //#endregion
}