/**
* ReadSegment for ContentX
*/
global virtual class CloudReadBatch implements Database.Batchable<Range>, Database.Stateful, Database.AllowsCallouts {
    global transient Logger log = new Logger();
    global Cloud cloud;
    global Cloud.File file;
    global List<Range> ranges;
    global Map<String, Object> args;
    global Queueable finisher;
    global Blob[] metas;
    global Integer batch = 0;
    global Map<String, Object> state = new Map<String, Object> { };

    /**
    * Finalizer
    */
    global class Finalizer implements Queueable, Database.AllowsCallouts {
        Cloud cloud;
        String[] paths;
        String log;
        Boolean deleteErr;
        /**
        * finish
        * @param cloud the cloud
        * @param paths the paths
        * @param log the log
        * @param deleteErr the deleteErr
        */
        global Finalizer(Cloud cloud, String[] paths, String log, Boolean deleteErr) { this.cloud = cloud; this.paths = paths; this.log = log; this.deleteErr = deleteErr; }

        /**
        * execute
        * @param qc the queueable context
        */
        global void execute(QueueableContext qc) {
            if (String.isNotEmpty(log)) cloud.create(paths[0], log);
            if (deleteErr) cloud.deletex(paths[1]);
        }
    }

    /**
    * execute
    * @param cloud the cloud
    * @param file the file
    * @param ranges the ranges
    * @param args the args
    * @return CloudReadBatch
    */
    global CloudReadBatch args(Cloud cloud, Cloud.File file, List<Range> ranges, Map<String, Object> args) { this.cloud = cloud; this.file = file; this.ranges = ranges; this.args = args; return this; }

    /**
    * start
    * @param bc the batchable context
    * @return Iterable<Range>
    */
    global Iterable<Range> start(Database.BatchableContext bc) { return ranges; }

    /**
    * execute
    * @param bc the batchable context
    * @param scope the scope
    */
    global virtual void execute(Database.BatchableContext bc, List<Range> scope) {
        batch++;
        if (scope.size() == 0) return;
        else if (scope.size() > 1) throw new HandledException('Only batch size of 1 is supported');
        Range range = scope[0];
        String[] paths = PathX.pathsLogErr(file.path, range);
        Blob b = cloud.get(file.key, range);
        if (b != null) cloud.create(paths[1], metas != null && batch > 1 ? StringX.combine(new Blob[] { metas[0], b, metas[2] }) : b);
        Boolean deleteErr = true;
        try { execute(BlobX.decode(b)); }
        catch (Exception e) { deleteErr = false; SystemX.debug(e.getMessage() + '\n' + e.getStackTraceString()); log.logError(e, null); }
        if (!Test.isRunningTest()) System.enqueueJob(new Finalizer(cloud, paths, log.toString(), deleteErr));
    }

    /**
    * finish
    * @param bc the batchable context
    */
    global virtual void finish(Database.BatchableContext bc) { finisher?.execute(null); }

    /**
    * execute
    * @param content the content
    */
    global virtual void execute(String content) {
        if (Test.isRunningTest() && content == 'throw') throw new HandledException();
        SystemX.debug(content);
        log.logInfo('complete');
    }

    /**
    * sets a meta b
    * @param content the content
    * @param index the index
    */
    global virtual void setMeta(Blob content, Integer index) {
        if (metas == null) metas = new Blob[3];
        metas[index] = content;
    }

    /**
    * Queue
    */
    global virtual class Queue implements Queueable, System.Finalizer, Database.AllowsCallouts {
        global final Logger log = new Logger();
        global Cloud cloud;
        global Cloud.File file;
        global Range range;
        global Map<String, Object> args;
        global Blob[] metas;
        Blob b;
        /**
        * sets the arguments for the queue object
        * @param cloud the cloud
        * @param file the file
        * @param range the range
        * @param args the args
        * @return Queue
        */
        global Queue args(Cloud cloud, Cloud.File file, Range range, Map<String, Object> args) { this.cloud = cloud; this.file = file; this.range = range; this.args = args; return this; }
    
        /**
        * execute
        * @param qc the queueable context
        */
        global void execute(QueueableContext qc) {
            if (!Test.isRunningTest()) System.attachFinalizer(this);
            String[] paths = PathX.pathsLogErr(file.path, range);
            b = cloud.get(file.key, range);
            if (b != null) cloud.create(paths[1], metas != null ? StringX.combine(new Blob[] { metas[0], b, metas[2] }) : b);
            try { execute(BlobX.decode(b)); }
            catch (Exception e) { SystemX.debug(e.getMessage() + '\n' + e.getStackTraceString()); log.logError(e, null); if (!Test.isRunningTest()) throw e; }
        }
    
        /**
        * execute
        * @param fc the FinalizerContext
        */
        global void execute(FinalizerContext fc) {
            String[] paths = PathX.pathsLogErr(file.path, range);
            Boolean deleteErr = fc.getException() == null;
            if (!Test.isRunningTest()) System.enqueueJob(new Finalizer(cloud, paths, log.toString(), deleteErr));
        }

        /**
        * execute segment
        * @param content the content
        */
        global virtual void execute(String content) {
            if (Test.isRunningTest() && content == 'throw') throw new HandledException();
            SystemX.debug(content);
            log.logInfo('complete');
        }

        /**
        * sets a meta b
        * @param content the content
        * @param index the index
        */
        global virtual void setMeta(Blob content, Integer index) {
            if (metas == null) metas = new Blob[3];
            metas[index] = content;
        }
    }
}