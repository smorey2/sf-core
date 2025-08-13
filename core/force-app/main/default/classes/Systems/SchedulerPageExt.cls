public with sharing class SchedulerPageExt {
    final ApexPages.StandardSetController controller;
    final Set<Id> ids;

    public SchedulerPageExt(ApexPages.StandardSetController controller) {
        this.controller = controller;
        ids = new Set<Id>();
        for (SchedulerJob__c s : (List<SchedulerJob__c>)controller.getSelected()) ids.add(s.Id);
    }

    public PageReference run() {
        SystemX.debug(Scheduler.run(ids, true));
        return controller.cancel();
    }
}