/**
* the schedule
*/
global class Scheduler implements Schedulable, System.Finalizer, SystemX.Log {
    Id id;
    Object obj;
    Object log;
    Datetime onx;
    Datetime pendingOn;
    List<String> dependencies;

    /**
    * creates the schedule
    * @param id the id
    * @param obj the obj
    */
    global Scheduler(Id id, Object obj) { this.id = id; this.obj = obj; }

    /**
    * sub-class to enqueue
    */
    class Execute implements Queueable, Database.AllowsCallouts {
        Scheduler s;
        public Execute(Scheduler s) { this.s = s; }
        /**
        * executes
        * @param qc the QueueableContext
        */
        public void execute(QueueableContext qc) { s.execute(); }
    }

    /**
    * gets the log
    * @return Object
    */
    global Object getLog() { return log; }

    /**
    * sets the log
    */
    global void setLog(Object value) { log = value; }

    /**
    * executes from a schedule
    * @param sc the SchedulableContext
    */
    global void execute(SchedulableContext sc) { execute(); }

    /**
    * executes
    */
    global void execute() {
        SchedulerJob__c s = getJob(id);
        if (s == null) return;
        String apexJobId = s.CronTriggerId__c;
        Integer batchSize = s.BatchSize__c != null ? (Integer)s.BatchSize__c : 200;
        onx = s.On__c;
        pendingOn = Datetime.now();
        if (obj instanceOf SystemX.Log) ((SystemX.Log)obj).setLog(log);
        SystemX.executeJob(obj, batchSize, this, apexJobId);
    }

    /**
    * executes the finalizer
    * @param ctx the FinalizerContext
    */
    global void execute(FinalizerContext ctx) {
        Exception ex = ctx.getException();
        String log = StringX.clamp((ex != null ? ex.getMessage() + '\n' + ex.getStackTraceString() + '\n' : '') + (this.log ?? ''), 100000, '...');
        SchedulerJob__c s = new SchedulerJob__c(Id = id, Log__c = log);
        if (ctx.getResult() == System.ParentJobResult.SUCCESS) s.On__c = pendingOn;
        Database.update(s, false);
        if (dependencies != null) run(dependencies, true);
    }

    /**
    * executes the schedule
    */
    global static List<String> run(Rescheduler rs) {
        return run([
            SELECT Id, Name, CronExpression__c, CronTriggerId__c, State__c, On__c, Dependencies__c, Provider__r.ApexAdapter__c, Provider__r.ApexArgs__c, Provider__r.Body__c
            FROM SchedulerJob__c WHERE CronTriggerId__c = 'Scheduler' And State__c = 'Enabled'
            ], null, '*', rs, true);
    }

    /**
    * schedules any pending jobs
    * @return List<String>
    */
    global static List<String> run() {
        return run([
            SELECT Id, Name, CronExpression__c, CronTriggerId__c, State__c, On__c, Dependencies__c, Provider__r.ApexAdapter__c, Provider__r.ApexArgs__c, Provider__r.Body__c
            FROM SchedulerJob__c WHERE CronTriggerId__c = null And State__c = 'Enabled'
            ], null, null, null, false);
    }

    /**
    * executes jobs by ids
    * @param ids the ids
    * @param enqueueJob the enqueueJob
    * @return List<String>
    */
    global static List<String> run(Set<Id> ids, Boolean enqueueJob) {
        return run([
            SELECT Id, Name, CronExpression__c, CronTriggerId__c, State__c, On__c, Dependencies__c, Provider__r.ApexAdapter__c, Provider__r.ApexArgs__c, Provider__r.Body__c
            FROM SchedulerJob__c WHERE Id in :ids Or (CronTriggerId__c = null And State__c = 'Enabled')
            ], ids, null, null, enqueueJob);
    }

    /**
    * executes jobs by name
    * @param name the name
    * @param enqueueJob the enqueueJob
    * @return List<String>
    */
    global static List<String> run(String name, Boolean enqueueJob) {
        return run([
            SELECT Id, Name, CronExpression__c, CronTriggerId__c, State__c, On__c, Dependencies__c, Provider__r.ApexAdapter__c, Provider__r.ApexArgs__c, Provider__r.Body__c
            FROM SchedulerJob__c WHERE Name Like :name Or (CronTriggerId__c = null And State__c = 'Enabled')
            ], null, name, null, enqueueJob);
    }

    /**
    * executes jobs by names
    * @param names the names
    * @param enqueueJob the enqueueJob
    * @return List<String>
    */
    global static List<String> run(List<String> names, Boolean enqueueJob) {
        return run([
            SELECT Id, Name, CronExpression__c, CronTriggerId__c, State__c, On__c, Dependencies__c, Provider__r.ApexAdapter__c, Provider__r.ApexArgs__c, Provider__r.Body__c
            FROM SchedulerJob__c WHERE Name In :names Or (CronTriggerId__c = null And State__c = 'Enabled')
            ], null, '*', null, enqueueJob);
    }

    static List<String> run(List<SchedulerJob__c> jobs, Set<Id> ids, String name, Rescheduler rs, Boolean enqueueJob) {
        updatex();
        List<String> r = new List<String>();
        List<SchedulerJob__c> updates = new List<SchedulerJob__c>();
        for (SchedulerJob__c s : jobs) {
            // make service
            Object z = makeService(s);
            if (z instanceOf String) {
                String msg = (String)z;
                updates.add(new SchedulerJob__c(Id = s.Id, Log__c = StringX.clamp(msg, 100000, '...')));
                r.add(msg);
                continue;
            }
            Scheduler obj = (Scheduler)z;
            if (!String.isEmpty(s.Dependencies__c)) obj.dependencies = s.Dependencies__c.split(',');
            
            // schedule svc
            if (s.CronTriggerId__c == null && s.State__c == 'Enabled') {
                String triggerId = s.CronExpression__c.startsWithIgnoreCase('R:')
                    ? 'Rescheduler'
                    : System.schedule(s.Name, s.CronExpression__c, obj);
                updates.add(new SchedulerJob__c(Id = s.Id, CronTriggerId__c = triggerId));
            }

            // execute svc
            if ((ids != null && ids.contains(s.Id)) || (name != null && s.Name.startsWithIgnoreCase(name)) || name == '*') {
                // handle quick scheduled
                if (s.CronExpression__c.startsWithIgnoreCase('R:')) {
                    Double minutes = Double.valueOf(s.CronExpression__c.substring(2));
                    if (rs == null || !rs.shouldExecute(minutes)) continue;
                }

                // execute
                if (enqueueJob) { SystemX.debug('Enqueue: ' + s.Name); System.enqueueJob(new Execute(obj)); }
                else { SystemX.debug('Execute: ' + s.Name); obj.execute(); }
            }
        }
        if (!updates.isEmpty()) Database.update(updates, false);
        return r;
    }

    static Object makeService(SchedulerJob__c s) {
        SchedulerProvider__c provider = s.Provider__r;
        Type type = TypeX.forName(provider.ApexAdapter__c);
        Object obj = type != null ? type.newInstance() : null;
        if (type == null || obj == null) { SystemX.debug('Missing ApexAdapter: ' + provider.ApexAdapter__c); return 'Missing ApexAdapter: ' + provider.ApexAdapter__c; }
        Datetime onx = s.On__c != null ? s.On__c.addHours(-1) : null;
        Map<String, Object> args = MapX.put(new Map<String, Object> {
            'onx' => onx,
            'body' => provider.Body__c
        }, StringX.decodeMap(provider.ApexArgs__c, true));
        Scheduler r;
        try {
            if (obj instanceOf SystemX.Args) ((SystemX.Args)obj).setArgs(args);
            r = new Scheduler(s.Id, obj);
            // if (obj instanceOf SystemX.HasFinalizer) { ((SystemX.HasFinalizer)obj).setFinalizer(r); }
        }
        catch (Exception e) {
            String errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
            SystemX.debug(errorMessage);
            return errorMessage;
        }
        return r;
    }

    static SchedulerJob__c getJob(Id id) {
        List<SchedulerJob__c> sources = [
            SELECT Id, State__c, CronExpression__c, CronTriggerId__c, On__c, BatchSize__c
            FROM SchedulerJob__c WHERE Id = :id LIMIT 1];
        if (sources.size() != 1) return null;
        SchedulerJob__c s = sources[0];
        if (s.State__c != 'Enabled') {
            // abort triggered if disabled
            if (String.isNotEmpty(s.CronTriggerId__c)) {
                if (!s.CronExpression__c.startsWithIgnoreCase('R:')) System.abortJob(s.CronTriggerId__c);
                Database.update(new SchedulerJob__c(Id = s.Id, CronTriggerId__c = null), false);
                return null;
            }
            return s;
        }
        return s;
    }

    /**
    * updates any cron triggers
    */
    global static void updatex() {
        Map<Id, Id> r = new Map<Id, Id>();
        for (SchedulerJob__c s : [SELECT Id, CronTriggerId__c FROM SchedulerJob__c WHERE CronTriggerId__c != null And (Not CronTriggerId__c Like 'R%')]) r.put(s.CronTriggerId__c, s.Id);
        if (r.isEmpty()) return;
        for (CronTrigger s : [SELECT Id FROM CronTrigger WHERE Id In :r.keySet()]) r.remove(s.Id);
        if (r.isEmpty()) return;
        List<SchedulerJob__c> updates = new List<SchedulerJob__c>();
        for (Id id : r.values()) updates.add(new SchedulerJob__c(Id = id, CronTriggerId__c = null));
        Database.update(updates, false);
    }
}