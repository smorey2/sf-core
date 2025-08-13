/**
* System method extensions
*/
global class SystemX {
    //#region Interfaces
    
    /**
    * sub-interface with args()
    */
    global interface Args {
        void setArgs(Map<String, Object> args);
    }

    /**
    * sub-interface with log get/set
    */
    global interface Log {
        Object getLog();
        void setLog(Object value);
    }

    //#endregion

    static Integer enqueueCount = 0;

    /**
    * writes to the execution debug log
    * @param level the level
    * @param msg the msg
    */
    global static void debug(Object msg) { Core.options.debug(LoggingLevel.DEBUG, msg); }

    /**
    * writes to the execution debug log
    * @param level the level
    * @param msg the msg
    */
    global static void debug(LoggingLevel logLevel, Object msg) { Core.options.debug(logLevel, msg); }

    /**
    * writes to the execution debug log with multi line
    * @param msg the msg
    */
    global static void debugMulti(Object msg) {
        if (msg == null) { Core.options.debug(LoggingLevel.DEBUG, 'null'); return; }
        String str = msg.toString();
        Integer l = str.length(), c = 365;
        for (Integer i = 0; i < l; i += c) Core.options.debug(LoggingLevel.DEBUG, str.substring(i, Math.min(i + c, l)));
    }

    /**
    * gets a fake id
    * @param type the SObjectType
    * @return Id
    */
    global static Id fakeId(Schema.SObjectType type, Integer num) { String s = String.valueOf(num); return type.getDescribe().getKeyPrefix() + '0'.repeat(12 - s.length()) + s; }

    /**
    * checks if the context is asynchronous
    * @return Boolean
    */
    global static Boolean isAsyncContext() { return Limits.getLimitQueries() > 100; }

    /**
    * executes the source
    * @param source the source
    * @param batchSize the batch size
    */
    global static void executeJob(Object source, Integer batchSize) { executeJob(source, batchSize, null, null); }
    /**
    * executes the source
    * @param source the source
    * @param batchSize the batch size
    * @param parent the parent
    * @param arg the arg
    */
    global static void executeJob(Object source, Integer batchSize, Object parent, Object arg) {
        Boolean test1; if (test1 = Test.isRunningTest() && arg == 'scheduled') arg = null;
        if (source instanceOf List<Object>) for (Object s : ( List<Object>)source) executeJob(s, batchSize, parent, arg);
        else if (source instanceOf Database.Batchable<SObject>) Database.executeBatch((Database.Batchable<SObject>)source, batchSize);
        else if (source instanceOf Database.Batchable<Object>) Database.executeBatch((Database.Batchable<Object>)source, batchSize);
        else if ((System.isScheduled() || test1) && source instanceOf Database.AllowsCallouts) System.enqueueJob(new Core.ExecuteJob(source, batchSize, parent, arg));
        else if (source instanceOf Schedulable && batchSize < 0) {
            Datetime now = Datetime.now(), next = now.addSeconds(Math.abs(batchSize));
            String klass = parent != null ? String.valueOf(parent).substringBefore(':') : 'SystemX';
            String cron = String.join(new Object[] { next.second(), next.minute(), next.hour(), next.day(), next.month(), '?', next.year() }, ' ');
            System.schedule(klass + ' : ' + (Test.isRunningTest() ? 'Test' : now.format('yyMMddHHmmss')), cron, (Schedulable)source);
        }
        else if (source instanceOf Schedulable) {
            Exception ex; try { ((Schedulable)source).execute(null); } catch (Exception e) { ex = e; }
            if (parent instanceOf Finalizer) System.enqueueJob(new Core.FinalizerContext((Finalizer)parent, (String)arg, ex));
        }
        else if (source instanceOf Queueable) { if (parent instanceOf Finalizer) System.attachFinalizer(parent); System.enqueueJob((Queueable)source); }
        else throw new HandledException('Unknown execution type: ' + source);
    }

    /**
    * enqueues the job
    * @param sources the sources
    */
    global static void enqueueJob(Object source) { enqueueJob(source, null); }
    /**
    * enqueues the job
    * @param sources the sources
    * @param parent the parent
    */
    global static void enqueueJob(Object source, Object parent) {
        List<Object> sources = source instanceOf List<Object> ? (List<Object>)source : new List<Object> { source };
        if (sources.size() <= Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) {
            Tuple2 t;
            for (Object z : sources)
                if (z instanceof Queueable) System.enqueueJob(z);
                else if (z instanceof Tuple2 && (t = (Tuple2)z).item1 instanceof Queueable) System.enqueueJob(t.item1, (Integer)t.item2);
                else throw new HandledException('Not Queueable');
            return;
        }
        Integer addInSeconds = 1; 
        Datetime now = Datetime.now(), next = now.addSeconds(addInSeconds);
        String klass = parent != null ? String.valueOf(parent).substringBefore(':') : 'SystemX';
        String cron = String.join(new Object[] { next.second(), next.minute(), next.hour(), next.day(), next.month(), '?', next.year() }, ' ');
        String name = klass + '.{0} : ' + (Test.isRunningTest() ? 'Test' : now.format('yyMMddHHmmss'));
        List<Object> b = new List<Object>();
        for (Object s : sources) {
            if (b.size() == 50) { System.schedule(name.replace('{0}', String.valueOf(enqueueCount++)), cron, new Core.EnqueueJob(b)); b.clear(); }
            b.Add(s);
        }
        if (b.size() > 0) System.schedule(name.replace('{0}', String.valueOf(enqueueCount++)), cron, new Core.EnqueueJob(b));
    }
}