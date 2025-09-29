/**
* WriteSegment for ContentX
*/
global virtual class CloudWriteBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts {
    global Logger log = new Logger();
    global Cloud cloud;
    global String path;
    global Map<String, Object> args;
    global String moveTo;
    global String openTag;
    global String closeTag;
    public Queueable finisher;
    global Integer batch = 0;
    global List<Object> parts = new List<Object>();
    global Map<String, Object> state = new Map<String, Object> { };
    global Cloud.File file;
    global Type lambda;
    global Blob b;

    /**
    * Finalizer
    */
    global class Finalizer implements Queueable, Database.AllowsCallouts {
        Cloud cloud;
        String[] paths;
        String log;
        /**
        * finalizer
        * @param cloud the cloud
        * @param paths the paths
        * @param log the log
        */
        global Finalizer(Cloud cloud, String[] paths, String log) { this.cloud = cloud; this.paths = paths; this.log = log; }

        /**
        * execute
        * @param qc the queueable context
        */
        global void execute(QueueableContext qc) {
            if (String.isNotEmpty(log)) cloud.create(paths[0], log);
        }
    }

    /**
    * sets the scope lambda
    * @param lambda the scope lambda
    * @return CloudWriteBatch
    */
    global CloudWriteBatch lambda(Type lambda) { this.lambda = lambda; return this; }

    /**
    * sets the arguments
    * @param cloud the cloud
    * @param path the path
    * @param args the args
    * @param moveTo the move to
    * @param openTag the open tag
    * @param closeTag the close tag
    * @return CloudWriteBatch
    */
    global CloudWriteBatch args(Cloud cloud, String path, Map<String, Object> args, String moveTo, String openTag, String closeTag) { this.cloud = cloud; this.path = path; this.args = args; this.moveTo = moveTo; this.openTag = openTag; this.closeTag = closeTag; return this; }

    /**
    * start
    * @param bc the batchable context
    * @return Iterable<Object>
    */
    global virtual Iterable<Object> start(Database.BatchableContext bc) {
        Iterable<Object> scope = (Iterable<Object>)Core.invoke(lambda);
        file = cloud.createMultipart(path);
        return scope;
    }

    /**
    * execute
    * @param bc the batchable context
    * @param scope the scope
    */
    global virtual void execute(Database.BatchableContext bc, List<Object> scope) {
        batch++;
        try {
            SystemX.debug('Batch: ' + batch + ' #' + scope.size());
            Blob content = BlobX.encode(execute(scope));
            if (content != null) flush(content);
        }
        catch (Exception e) { SystemX.debug(e.getMessage() + '\n' + e.getStackTraceString()); log.logError(e, null); }
    }

    /**
    * finish
    * @param bc the batchable context
    */
    global virtual void finish(Database.BatchableContext bc) {
        String[] paths = PathX.pathsLogErr(file.path, null);
        flush(null);
        if (!Test.isRunningTest()) file = cloud.completeMultipart(file, parts);
        if (moveTo != null) cloud.move(file, moveTo + '/' + PathX.getFileName(file.path));
        if (!Test.isRunningTest()) System.enqueueJob(new Finalizer(cloud, paths, log.toString()));
        finisher?.execute(null);
    }

    global virtual void flush(Blob content) {
        b = StringX.combine(new Blob[] { b, content });
        if (b == null || (content != null && b.size() < cloud.flushOn())) return;
        if (!Test.isRunningTest()) parts.add(cloud.uploadPart(file, parts.size() + 1, b));
        b = null;
    }

    /**
    * execute segment
    * @param scope the scope
    * @return String
    */
    global virtual String execute(List<Object> scope) {
        if (Test.isRunningTest() && scope[0] == 'throw') throw new HandledException();
        List<String> b = new List<String>();
        for (Object s : scope) {
            if (openTag != null) b.add(openTag);
            b.add(s.toString());
            if (closeTag != null) b.add(closeTag);
        }
        // complete
        log.logInfo('complete');
        return String.join(b, '');
    }

    /**
    * Queue and Finalizer
    */
    global virtual class Queue implements Queueable, System.Finalizer, Database.AllowsCallouts {
        global final Logger log = new Logger();
        global Cloud cloud;
        global String path;
        global Map<String, Object> args;
        global String moveTo;
        global String openTag;
        global String closeTag;
        global Type lambda;
        global Cloud.File file;

        /**
        * sets the scope
        * @param scope the scope
        * @return CloudWriteBatch.Queue
        */
        global Queue lambda(Type lambda) { this.lambda = lambda; return this; }

        /**
        * sets the arguments
        * @param cloud the cloud
        * @param path the path
        * @param args the args
        * @param moveTo the move to
        * @param openTag the open tag
        * @param closeTag the close tag
        * @return CloudWriteBatch.Queue
        */
        global Queue args(Cloud cloud, String path, Map<String, Object> args, String moveTo, String openTag, String closeTag) { this.cloud = cloud; this.path = path; this.args = args; this.moveTo = moveTo; this.openTag = openTag; this.closeTag = closeTag; return this; }
    
        /**
        * execute
        * @param qc the queueable context
        */
        global void execute(QueueableContext qc) {
            List<Object> scope = (List<Object>)Core.invoke(lambda);
            if (!Test.isRunningTest()) System.attachFinalizer(this);
            try { file = cloud.create(path, BlobX.encode(execute(scope))); }
            catch (Exception e) { SystemX.debug(e.getMessage() + '\n' + e.getStackTraceString()); log.logError(e, null); if (!Test.isRunningTest()) throw e; }
        }
    
        /**
        * execute
        * @param fc the FinalizerContext
        */
        global void execute(FinalizerContext fc) {
            String[] paths = PathX.pathsLogErr(file.path, null);
            // Boolean deleteErr = fc.getException() == null;
            String logString = log?.toString();
            if (String.isNotEmpty(logString)) cloud.create(paths[0], logString);
            if (moveTo != null) cloud.move(file, moveTo + '/' + PathX.getFileName(file.path));
        }
    
        /**
        * execute segment
        * @param scope the scope
        * @return String
        */
        global virtual String execute(List<Object> scope) {
            if (Test.isRunningTest() && scope[0] == 'throw') throw new HandledException();
            List<String> b = new List<String>();
            for (Object s : scope) {
                if (openTag != null) b.add(openTag);
                b.add(s.toString());
                if (closeTag != null) b.add(closeTag);
            }
            log.logInfo('complete');
            return String.join(b, '');
        }
    }
}