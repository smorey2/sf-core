/**
* SFMC triggered email
*/
global abstract class CloudSfmcTrigger implements Schedulable, Database.AllowsCallouts {
    CloudSfmc cloud;
    Map<String, Object> args;

    /**
    * constructor
    * @param accessToken the access token
    * @param args the args
    */ 
    // global CloudSfmcTrigger(Map<String, Object> accessToken, Map<String, Object> args) {
    //     this.accessToken = accessToken;
    //     this.args = args;
    // }

    /**
    * trigger payload
    */
    class Payload {
        PayloadTo To;
        PayloadOptions OPTIONS;
    }

    /**
    * payload to
    */
    class PayloadTo {
        String Address;
        String SubscriberKey;
        Object ContactAttributes;
    }

    /**
    * payload options
    */
    class PayloadOptions {
        String RequestType = 'ASYNC';
    }

    /**
    * Context
    * @param endpoint the endpoint
    * @param accessToken the accessToken
    * @param args the args
    */  
    global class Context {
        global Context(String endpoint, Map<String, Object> accessToken, Map<String, Object> args) {
            this.endpoint = endpoint;
            this.accessToken = accessToken;
            this.args = args ?? new Map<String, Object>();
        }
        global String endpoint;
        global Map<String, Object> accessToken;
        global Map<String, Object> args;
        global String address;
        global String subscriberKey;
        global Object contactAttributes;
        global Object tag;
    }

    /**
    * accessToken support
    * @returns the access token
    */ 
    global Map<String, Object> accessToken {
        get { if (this.accessToken == null) this.accessToken = cloud.accessToken(); return this.accessToken; }
        set;
    }

    /**
    * execute
    * @param ctx the ctx
    */
    global void execute(SchedulableContext ctx) { execute(new Context(null, accessToken, null)); }

    /**
    * posts an item
    * @param ctx the trigger context
    */ 
    global virtual HttpResponse post(Context ctx) {
        String errorMessage = null;
        HttpResponse res = null;
        Map<String, Object> req;
        try {
            Payload p = new Payload();
            p.To = new PayloadTo();
            p.To.Address = ctx.address;
            p.To.SubscriberKey = ctx.subscriberKey;
            p.To.ContactAttributes = ctx.contactAttributes;
            p.OPTIONS = new PayloadOptions();
            // SystemX.debug(JSON.serialize(p));

            // send
            req = ctx.args;
            req.put('method', 'POST');
            req.put('endpoint', cloud.endpoint('trigger', ctx.endpoint));
            req.put('body', p);
            
            // res = CloudX.callout((String)ctx.accessToken.get('rest_instance_url'), ctx.accessToken, req);
            // if (res != null) { SystemX.debug(res.getStatus() + ': ' + res.getBody()); }
        }
        catch (Exception e) { errorMessage = e.getMessage() + '\n' + e.getStackTraceString(); SystemX.debug(System.LoggingLevel.ERROR, errorMessage); }
        finally { postProcess(ctx, req, res, errorMessage); }
        return res;
    }

    /**
    * execute
    * @param ctx the context
    */ 
    global virtual void execute(Context ctx) { }

    /**
    * post request
    * @param ctx the context
    * @param req the http request
    * @param res the http response
    * @param errorMessage the error message
    */ 
    global virtual void postProcess(Context ctx, Map<String, Object> req, HttpResponse res, String errorMessage) { }
}