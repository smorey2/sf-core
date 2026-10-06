public with sharing class TaskManagerPageExt {
    final ApexPages.StandardSetController controller;
    final Set<Id> ids;

    public TaskManagerPageExt(ApexPages.StandardSetController controller) {
        this.controller = controller;
        ids = new Set<Id>();
        for (Task__c s : (List<Task__c>)controller.getSelected()) ids.add(s.Id);
    }

    public PageReference run() {
        SystemX.debug(TaskManager.run(ids, true));
        return controller.cancel();
    }
}