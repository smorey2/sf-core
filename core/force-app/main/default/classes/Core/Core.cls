/**
* System method extensions
*/
global class Core {
    global static Boolean disableAppSingleton;
    global static final Map<Type, Object> singletons = new Map<Type, Object>();
    global static DefaultOptions options = (DefaultOptions)getSingleton(DefaultOptions.class);

    /**
    * an internal class used by ExecuteJob()
    */
    global class ExecuteJob implements Queueable, Database.AllowsCallouts {
        Object source;
        Integer batchSize;
        Object parent;
        Object arg;
        global ExecuteJob(Object source, Integer batchSize, Object parent, Object arg) { this.source = source; this.batchSize = batchSize; this.parent = parent; this.arg = arg; }
        public void execute(QueueableContext qc) { SystemX.executeJob(source, batchSize, parent, arg); }
    }

    /**
    * an internal class used by EnqueueJob()
    */
    global class EnqueueJob implements Schedulable {
        List<Object> sources;
        global EnqueueJob(List<Object> sources) { this.sources = sources; }

        /**
        * executes
        * @param sc the schedulable context
        */
        public void execute(SchedulableContext sc) {
            System.abortJob(sc.getTriggerId());
            Tuple2 t;
            for (Object z : sources)
                if (z instanceof Queueable) System.enqueueJob(z);
                else if (z instanceof Tuple2 && (t = (Tuple2)z).item1 instanceof Queueable) System.enqueueJob(t.item1, (Integer)t.item2);
                else throw new HandledException('Not Queueable');
        }
    }

    /**
    * an internal class used by FinalizerContext()
    */
    global class FinalizerContext implements Queueable, System.FinalizerContext {
        System.Finalizer source;
        String requestId;
        Id apexJobId;
        Exception ex;
        /**
        * constructs a FinalizerContext
        * @param source the source
        * @param requestId the requestId
        * @param ex the ex
        */
        global FinalizerContext(System.Finalizer source, String requestId, Exception ex) { this.source = source; this.requestId = requestId; this.ex = ex; }
        public String getRequestId() { return requestId; }
        public Id getAsyncApexJobId() { return apexJobId; }
        public System.ParentJobResult getResult() { return ex != null ? System.ParentJobResult.UNHANDLED_EXCEPTION : System.ParentJobResult.SUCCESS; }
        public Exception getException() { return ex; }
        public void execute(QueueableContext qc) { apexJobId = qc.getJobId(); source.execute(this); }
    }

    /**
    * throws
    * @param message the message
    * @return Object
    */
    global static Object throwx(String message) { throw new HandledException(message); }

    /**
    * str
    * @param source the source
    * @return String
    */
    global static String strval(String source) { return source != null ? '\'' + source.replace('\'', '\'\'') + '\'' : 'null'; }

    /**
    * spinlocks the thread
    * @param milliseconds the duration in milliseconds
    */
    global static void threadSleep(Integer milliseconds) {
        Long timeDiff = 0;
        Datetime firstTime = System.now();
        do { timeDiff = System.now().getTime() - firstTime.getTime(); }
        while (timeDiff <= milliseconds); 
    }

    //#region Func

    /**
    * sub-interface with lambda()
    */
    global interface Func { Object func(); }

    /**
    * sub-interface with lambda(arg1)
    */
    global interface Func1 { Object func(Object arg1); }

    /**
    * sub-interface with lambda(arg1, arg2)
    */
    global interface Func2 { Object func(Object arg1, Object arg2); }

    /**
    * sub-interface with lambda(arg1, arg2, arg3)
    */
    global interface Func3 { Object func(Object arg1, Object arg2, Object arg3); }

    /**
    * sub-interface with lambda(arg1, arg2, arg3, arg4)
    */
    global interface Func4 { Object func(Object arg1, Object arg2, Object arg3, Object arg4); }

    /**
    * invokes
    * @param source the source
    * @return Object
    */
    global static Object invoke(Object source) {
        if (source instanceof Type) source = ((Type)source).newInstance();
        return ((Func)source).func();
    }

    /**
    * invokes
    * @param source the source
    * @param arg1 the arg1
    * @return Object
    */
    global static Object invoke(Object source, Object arg1) {
        if (source instanceof Type) source = ((Type)source).newInstance();
        return ((Func1)source).func(arg1);
    }

    /**
    * invokes
    * @param source the source
    * @param arg1 the arg1
    * @param arg2 the arg2
    * @return Object
    */
    global static Object invoke(Object source, Object arg1, Object arg2) {
        if (source instanceof Type) source = ((Type)source).newInstance();
        return ((Func2)source).func(arg1, arg2);
    }

    /**
    * invokes
    * @param source the source
    * @param arg1 the arg1
    * @param arg2 the arg2
    * @param arg3 the arg3
    * @return Object
    */
    global static Object invoke(Object source, Object arg1, Object arg2, Object arg3) {
        if (source instanceof Type) source = ((Type)source).newInstance();
        return ((Func3)source).func(arg1, arg2, arg3);
    }

    /**
    * invokes
    * @param source the source
    * @param arg1 the arg1
    * @param arg2 the arg2
    * @param arg3 the arg3
    * @param arg3 the arg4
    * @return Object
    */
    global static Object invoke(Object source, Object arg1, Object arg2, Object arg3, Object arg4) {
        if (source instanceof Type) source = ((Type)source).newInstance();
        return ((Func4)source).func(arg1, arg2, arg3, arg4);
    }

    //#endregion

    //#region Singleton
    
    /**
    * gets the factory (singleton)
    * @param klass the klass
    * @return Object
    */
    global static Object getSingleton(Type klass) {
        Object r = singletons.get(klass);
        if (r != null) return r;
        String clsName = 'App' + klass.getName().replace('xs.', '').replace('Default', '');
        Type t = disableAppSingleton != true ? Type.forName(null, clsName) ?? Type.forName(clsName) ?? klass : klass;
        if (t == null) throw new HandledException('getSingleton(type) requires a class named "' + clsName + '" to exist, please create.');
        r = t.newInstance();
        singletons.put(klass, r);
        return r;
    }

    //#endregion

    //#region Trigger

    /**
    * trigger on a datetime value
    * @param value the datetime
    * @param conditions the conditions
    * @return Boolean
    */
    global static Boolean triggerDatetime(Object value, String format) {
        Datetime d = value == null ? Datetime.now() : Datetime.valueOf(value);
        if (format == null) throw new HandledException('Required: format');
        for (String s : format.split(';')) {
            String op = s.substringBefore(':'); Set<String> vals = new Set<String>(s.substringAfter(':').split(','));
            Boolean v;
            switch on op.toLowerCase() {
                when '*', 'every' { v = true; }
                when 'minute' { v = vals.contains(String.valueOf(d.minute())); }
                when 'hour' { v = vals.contains(String.valueOf(d.hour())); }
                when 'day' { v = vals.contains(String.valueOf(d.day())); }
                when 'dow' { v = vals.contains(String.valueOf(d.format('EE'))); }
                when else { v = false; }
            }
            if (!v) { return false; }
        }
        return true;
    }

    //#endregion
}