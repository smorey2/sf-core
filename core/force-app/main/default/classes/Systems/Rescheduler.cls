/**
* @description
*/
global virtual class Rescheduler implements Schedulable {
    /**
    * @description
    */
    global class Job {
        global Double minutes;
        global Type klass;
        global Integer batchSize;
        global Map<String, Object> args;
        /**
        * creates the job
        * @param minutes the minutes
        * @param klass the klass
        */
        global Job(Double minutes, Type klass) { this(minutes, klass, 200, null); }
        /**
        * creates the job
        * @param minutes the minutes
        * @param klass the klass
        * @param batchSize the batchSize
        */
        global Job(Double minutes, Type klass, Integer batchSize) { this(minutes, klass, batchSize, null); }
        /**
        * creates the job
        * @param minutes the minutes
        * @param klass the klass
        * @param batchSize the batchSize
        * @param args the args
        */
        global Job(Double interval, Type klass, Integer batchSize, Map<String, Object> args) { this.minutes = minutes; this.klass = klass; this.batchSize = batchSize; this.args = args; }
    }

    global Double minutes;
    Double lapsed = 0;

    /**
    * creates the reschedule
    */
    global Rescheduler() { this.minutes = 5.0; }
    /**
    * creates the reschedule
    * @param minutes the minutes
    */
    global Rescheduler(Double minutes) { this.minutes = minutes; }

    /**
    * get the jobs from metadata
    * @return List<QuickScheduleJob>
    */
    global virtual List<Job> getJobs() {
        List<Job> jobs = new List<Job>();
        for (ReschedulerJob__mdt s : [SELECT Id, ApexAdapter__c, ApexArgs__c, BatchSize__c, Minutes__c FROM ReschedulerJob__mdt WHERE ApexAdapter__c != null]) {
            Double minutes = s.Minutes__c != null ? s.Minutes__c.doubleValue() : 1.0;
            Type type = TypeX.forName(s.ApexAdapter__c);
            if (type == null) { SystemX.debug('Missing ApexAdapter: ' + s.ApexAdapter__c); continue; }
            Integer batchSize = s.BatchSize__c != null ? s.BatchSize__c.intValue() : 200;
            Map<String, Object> args = String.isNotEmpty(s.ApexArgs__c) ? StringX.decodeMap(s.ApexArgs__c, False) : null;
            jobs.add(new Job(minutes, type, batchSize, args));
        }
        return jobs;
    }

    /**
    * Re-schedule ourself to run again in MINUTES
    * @return List<AsyncApexJob>
    */
    global List<AsyncApexJob> run() {
        // increment lapsed
        lapsed += minutes; if (lapsed >= 1440) lapsed = 0;
        // schedule job
        Datetime now = Datetime.now(), next = DatetimeX.addMinutes(now, minutes);
        String klass = String.valueOf(this).substringBefore(':');
        String cron = String.join(new Object[] { next.second(), next.minute(), next.hour(), next.day(), next.month(), '?', next.year() }, ' ');
        System.schedule(klass + ' : ' + (Test.isRunningTest() ? 'Test' : now.format('yyMMddHHmmss')), cron, this);
        // get running jobs
        return [
            SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' And (Status = 'Queued' Or Status = 'Processing' Or Status = 'Preparing')
            And ApexClassId In (SELECT Id FROM ApexClass WHERE Name = :klass)];
    }

    /**
    * abort job
    */
    global void abort() {
        String klass = String.valueOf(this).substringBefore(':') + ' : %';
        for (CronTrigger s : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name Like :klass])
            try { System.abortJob(s.id); } catch (Exception e) { }
    }

    /**
    * schedule execute
    * @param sc the SchedulableContext
    */
    global virtual void execute(SchedulableContext sc) {
        List<Job> jobs = getJobs();

        // Abort the current job
        if (sc != null) System.abortJob(sc.getTriggerId());

        // schedule next job
        List<AsyncApexJob> asyncApexJobs = run();

        // Launch a batch job, if ...enabled, apex jobs is not null, and no jobs currently running = 0
        if (jobs == null || jobs.isEmpty() || (asyncApexJobs != null && !asyncApexJobs.isEmpty())) return;

        // execute jobs
        for (Job job : jobs) {
            // skip based on minutes
            if (job == null || !shouldExecute(job.minutes)) continue;

            // check if schedule
            if (job.klass == Scheduler.class) { Scheduler.run(this); continue; }

            // create klass
            Type klass = job.klass;
            Object obj = klass.newInstance(); //String className = klass.getName();
            if (obj instanceOf SystemX.Args) ((SystemX.Args)obj).setArgs(job.args);

            // call klass
            SystemX.executeJob(obj, job.batchSize, job, null);
        }
    }

    /**
    * checks if job should execute
    * @param lapsed the lapsed
    * @param minutes the minutes
    * @return Boolean 
    */
    global virtual Boolean shouldExecute(Double minutes) { return minutes == 0.0 || Math.mod((Integer)(lapsed * 100.0), (Integer)(Math.abs(minutes) * 100.0)) == 0; }
}