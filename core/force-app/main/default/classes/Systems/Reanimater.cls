/**
* reanimate
*/
global abstract class Reanimater implements Schedulable {
    global Integer addInSeconds;
    global String name;
    global Boolean overlap;
    global Integer interval = 0;

    /**
    * constructor
    * @param addInSeconds the addInSeconds
    */
    global Reanimater(Integer addInSeconds) { this(null, addInSeconds, false); }
    /**
    * constructor
    * @param name the name
    * @param addInSeconds the addInSeconds
    * @param overlap the overlap
    */
    global Reanimater(String name, Integer addInSeconds, Boolean overlap) {
        this.name = name; this.addInSeconds = addInSeconds; this.overlap = overlap;
    }

    /**
    * Re-schedule ourself to run again in MINUTES
    * @return List<AsyncApexJob>
    */
    global List<AsyncApexJob> run() {
        this.interval++; if (this.interval > 10000) this.interval = 0;
        Datetime now = Datetime.now(), next = now.addSeconds(addInSeconds);
        String klass = String.valueOf(this).substringBefore(':');
        String cron = String.join(new Object[] { next.second(), next.minute(), next.hour(), next.day(), next.month(), '?', next.year() }, ' ');
        System.schedule((this.name ?? klass) + ' : ' + (Test.isRunningTest() ? 'Test' : now.format('yyMMddHHmmss')), cron, this);
        List<AsyncApexJob> jobs = [
            SELECT Id FROM AsyncApexJob WHERE JobType != 'ScheduledApex' And (Status = 'Queued' Or Status = 'Processing' Or Status = 'Preparing')
            And ApexClassId In (SELECT Id FROM ApexClass WHERE Name = :klass)];
        return jobs;
    }

    /**
    * abort job
    */
    global void abort() {
        String klass = String.valueOf(this).substringBefore(':');
        String namePattern = (this.name ?? klass) + ' : %';
        for (CronTrigger s : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name Like :namePattern])
            try { System.abortJob(s.Id); } catch (Exception e) { }
    }

    /**
    * schedule execute
    * @param sc the SchedulableContext
    */
    global virtual void execute(SchedulableContext sc) {
        if (sc != null) System.abortJob(sc.getTriggerId());
        List<AsyncApexJob> jobs = run();
        if (!this.overlap && !jobs.isEmpty()) return;
        execute();
    }

    /**
    * schedule execute
    */
    global abstract void execute();
}