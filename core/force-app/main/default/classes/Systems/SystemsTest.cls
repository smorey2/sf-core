@isTest
class SystemsTest {
     static final String CRON = '0 0 23 * * ?';

     //#region Batch

     class MyAction extends Batch.Action {
          public override void execute(Object ctx, List<SObject> scope, Boolean allOrNone, List<ExObj> exceptions) { }
     }

     static void Batch_setup() {
          Account parent = new Account(Name='ParentTest'); insert parent;
          Account account = new Account(Name='Test', ParentId=parent.Id); insert account;
          Contact contact = new Contact(FirstName='Test', LastName='Test', AccountId=parent.Id); insert contact;
     }

     @isTest static void Batch_new() {
          Batch_setup();
          Test.startTest();
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new MyAction()).run();
          new Batch.Schedule('SELECT Id FROM Account WHERE Name = \'Test\'',
               new MyAction()).run();
          new Batch.Queue('SELECT Id FROM Account WHERE Name = \'Test\'',
               new MyAction()).run();
          Test.stopTest();
	}

	@isTest static void Batch_Actions() {
          Batch_setup();
          Test.startTest();
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Flow('SomeFlow.AccountId')).run();
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Flow('SomeFlow.AccountId', new Map<String, Object> {
                    'Description' => 'Updated'
               }).mergex('last')).run();
          new Batch('SELECT Id, Name FROM Account WHERE Name = \'Test\'',
               new Batch.Insertx(Contact.class, new Map<String, Object> { 
                    'AccountId' => '{{Id}}',
                    'FirstName' => '{{Name}} Postfix',
                    'LastName' => 'Last Name',
                    'Description' => 'Test'
               })).run();
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Updatex(new Map<String, Object> {
                    'Description' => 'Test {{Id}}'
               }).mergex('first')).run();
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Deletex()).run();
          Test.stopTest();
     }

	@isTest static void Batch_ActionRels() {
          Batch_setup();
          Test.startTest();
          new Batch('SELECT Id, Parent.OwnerId FROM Account WHERE Name = \'Test\'',
               new Batch.FlowRel(User.class, 'Parent.OwnerId', 'SomeFlow.AccountId')).run();
          new Batch('SELECT Id, Parent.OwnerId FROM Account WHERE Name = \'Test\'',
               new Batch.FlowRel(User.class, 'Parent.OwnerId', 'SomeFlow.AccountId', new Map<String, Object> {
                    'AboutMe' => 'Updated'
               }).mergex('first')).run();
          new Batch('SELECT Id, Name FROM Account WHERE Name = \'Test\'',
               new Batch.InsertRel(Contact.class, 'Id', new Map<String, Object> { 
                    'AccountId' => '{{Id}}',
                    'FirstName' => '{{Name}} Postfix',
                    'LastName' => 'Last Name',
                    'Description' => 'Test'
               })).run();
          new Batch('SELECT Id, Name, Parent.OwnerId FROM Account WHERE Name = \'Test\'',
               new Batch.UpdateRel(User.class, 'Parent.OwnerId', new Map<String, Object> {
                    'AboutMe' => 'Prefix {{Name}}'
               }).mergex('first')).run();
          new Batch('SELECT Id, AccountId FROM Contact WHERE FirstName = \'Test\'',
               new Batch.DeleteRel(Account.class, 'AccountId')).run();
          Test.stopTest();
	}

	@isTest static void Batch_then() {
          Batch_setup();
          Test.startTest();
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Updatex(new Map<String, Object> {
                    'Description' => 'Test 1'
               })).then(
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Updatex(new Map<String, Object> {
                    'Description' => 'Test 2'
               })).then(
          new Batch('SELECT Id FROM Account WHERE Name = \'Test\'',
               new Batch.Updatex(new Map<String, Object> {
                    'Description' => 'Test 3'
               })))).run();
          Test.stopTest();
	}

     //#endregion

     //#region GatewayLogger

     public class TestGatewayLogger extends GatewayLogger {
          public TestGatewayLogger() {
               makeRelated();
               makeFields();
          }
          public override Map<Schema.SObjectType, String> makeRelated() {
               return new Map<Schema.SObjectType, String> { Schema.User.SObjectType => 'OwnerId' };
          }
          public override Map<Field, String> makeFields() {
               return new Map<Field, String> {
                    Field.InteractionType => 'Name',
                    Field.GatewayMessage => 'Description',
                    Field.ErrorMessage => 'Description',
                    Field.Request => 'Description',
                    Field.Response => 'Description',
                    Field.ResultCode => 'NumberOfEmployees'
               };
          }
          public override SObject createLog() { return new Account(); }
     }

     @isTest static void GatewayLogger_new() {
          Test.startTest();
          User user = [SELECT Id FROM User LIMIT 1];
          Map<String, Object> reqM = new Map<String, Object>();
          HttpRequest reqH = new HttpRequest();
          RestRequest reqR = new RestRequest();
          Map<String, Object> resM = new Map<String, Object>();
          HttpResponse resH = new HttpResponse();
          RestResponse resR = new RestResponse();
          GatewayLogger b = new TestGatewayLogger()
               .relatedTo(user.Id)
               .level(1)
               .value('Name', 50, 'Name')
               //.value('Name', 'Name')
               .interactionType('interaction')
               .withGatewayMessage('gatewayMessage')
               .withErrorMessage('errorMessage')
               //.withRequest(reqM, 0)
               .withRequest(reqM)
               .withRequest(reqH)
               .withRequest(reqR)
               //.withResponse(resM, 200)
               .withResponse(resH)
               .withResponse(resR);
          b.build();
          b.buildAndLog();
     }

     //#endregion

     //#region Logger

     @isTest static void Logger_log() {
          Test.startTest();
          Logger log = new Logger(); Object z;
          // core
          log.add('message');
          log.clear();
          // LoggingLevel
          log.log(LoggingLevel.NONE, 'message');
          log.log(LoggingLevel.NONE, 'message', new Object[] { 1 });
          log.log(LoggingLevel.NONE, 'eventId', 'message');
          log.log(LoggingLevel.NONE, 'eventId', 'message', new Object[] { 1 });
          log.log(LoggingLevel.NONE, new HandledException(), 'message');
          log.log(LoggingLevel.NONE, new HandledException(), 'message', new Object[] { 1 });
          log.log(LoggingLevel.NONE, 'eventId', new HandledException(), 'message');
          log.log(LoggingLevel.NONE, 'eventId', new HandledException(), 'message', new Object[] { 1 });
          // TimeX
          z = new Logger.Timex('message');
          log.log(z, 'message');
          log.log(z, 'message', new Object[] { 1 });
          log.log(z, 'eventId', 'message');
          log.log(z, 'eventId', 'message', new Object[] { 1 });
          log.log(z, new HandledException(), 'message');
          log.log(z, new HandledException(), 'message', new Object[] { 1 });
          log.log(z, 'eventId', new HandledException(), 'message');
          log.log(z, 'eventId', new HandledException(), 'message', new Object[] { 1 });
          // Debug
          log.logDebug('message');
          log.logDebug('message', new Object[] { 1 });
          log.logDebug('eventId', 'message');
          log.logDebug('eventId', 'message', new Object[] { 1 });
          log.logDebug(new HandledException(), 'message');
          log.logDebug(new HandledException(), 'message', new Object[] { 1 });
          log.logDebug('eventId', new HandledException(), 'message');
          log.logDebug('eventId', new HandledException(), 'message', new Object[] { 1 });
          // Error
          log.logError('message');
          log.logError('message', new Object[] { 1 });
          log.logError('eventId', 'message');
          log.logError('eventId', 'message', new Object[] { 1 });
          log.logError(new HandledException(), 'message');
          log.logError(new HandledException(), 'message', new Object[] { 1 });
          log.logError('eventId', new HandledException(), 'message');
          log.logError('eventId', new HandledException(), 'message', new Object[] { 1 });
          // Info
          log.logInfo('message');
          log.logInfo('message', new Object[] { 1 });
          log.logInfo('eventId', 'message');
          log.logInfo('eventId', 'message', new Object[] { 1 });
          log.logInfo(new HandledException(), 'message');
          log.logInfo(new HandledException(), 'message', new Object[] { 1 });
          log.logInfo('eventId', new HandledException(), 'message');
          log.logInfo('eventId', new HandledException(), 'message', new Object[] { 1 });
          // Fine
          log.logFine('message');
          log.logFine('message', new Object[] { 1 });
          log.logFine('eventId', 'message');
          log.logFine('eventId', 'message', new Object[] { 1 });
          log.logFine(new HandledException(), 'message');
          log.logFine(new HandledException(), 'message', new Object[] { 1 });
          log.logFine('eventId', new HandledException(), 'message');
          log.logFine('eventId', new HandledException(), 'message', new Object[] { 1 });
          // Finer
          log.logFiner('message');
          log.logFiner('message', new Object[] { 1 });
          log.logFiner('eventId', 'message');
          log.logFiner('eventId', 'message', new Object[] { 1 });
          log.logFiner(new HandledException(), 'message');
          log.logFiner(new HandledException(), 'message', new Object[] { 1 });
          log.logFiner('eventId', new HandledException(), 'message');
          log.logFiner('eventId', new HandledException(), 'message', new Object[] { 1 });
          // Finest
          log.logFinest('message', new Object[] { 1 });
          log.logFinest('eventId', 'message');
          log.logFinest('eventId', 'message', new Object[] { 1 });
          log.logFinest(new HandledException(), 'message');
          log.logFinest(new HandledException(), 'message', new Object[] { 1 });
          log.logFinest('eventId', new HandledException(), 'message');
          log.logFinest('eventId', new HandledException(), 'message', new Object[] { 1 });
          // Warn
          log.logWarn('message');
          log.logWarn('message', new Object[] { 1 });
          log.logWarn('eventId', 'message');
          log.logWarn('eventId', 'message', new Object[] { 1 });
          log.logWarn(new HandledException(), 'message');
          log.logWarn(new HandledException(), 'message', new Object[] { 1 });
          log.logWarn('eventId', new HandledException(), 'message');
          log.logWarn('eventId', new HandledException(), 'message', new Object[] { 1 });
          Test.stopTest();
     }

     //#endregion

     //#region Lookup

     @isTest static void Lookup_getLocation() {
        Test.startTest();
        Object actual = Lookup.get.getLocation('Site', 'test', false);
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
     }

     @isTest static void Lookup_getNamedCredential() {
        Test.startTest();
        Object actual = Lookup.get.getNamedCredential('first', false);
        Test.stopTest();
     }

     @isTest static void Lookup_getPricebook() {
        Test.startTest();
        Object actual = Lookup.get.getPricebook('test', false);
        Test.stopTest();
     }

     @isTest static void Lookup_getRecordType() {
        Test.startTest();
        Object actual = Lookup.get.getRecordType('Account', 'first', false);
        Test.stopTest();
     }

     @isTest static void Lookup_flush() {
        Test.startTest();
        Lookup.get.flush();
        Test.stopTest();
     }

     //#endregion

     //#region Reanimater

     public class ReanimaterMock extends Reanimater {
          public ReanimaterMock() { super(3); }
          public override void execute() { }
     }

     @isTest static void Reanimater_schedule() {
          ReanimaterMock job = new ReanimaterMock();
          Test.startTest();
          System.schedule('Test Sched', '0 0 23 * * ?', job);
          Test.stopTest();
     }

     @isTest static void Reanimater_run() {
          ReanimaterMock job = new ReanimaterMock();
          Test.startTest();
          job.run();
          Test.stopTest();
     }

     @isTest static void Reanimater_abort() {
          ReanimaterMock job = new ReanimaterMock();
          job.run();
          Test.startTest();
          job.abort();
          Test.stopTest();
     }

     @isTest static void Reanimate_execute() {
          ReanimaterMock job = new ReanimaterMock();
          Test.startTest();
          job.execute(null);
          job.execute();
          Test.stopTest();
     }

     //#endregion

     //#region Rescheduler

     public class TestRescheduler extends Rescheduler {
          public override List<Job> getJobs() {
               return new List<Job> {
                    new Job(-5, TestSchedulable.class),
                    new Job(5, TestSchedulable.class),
                    new Job(5, TestQueueable.class),
                    new Job(5, CoreTestBatchable.class, 1)
               };
          }
     }

     class TestSchedulable implements Schedulable {
          public void execute(SchedulableContext sc) { }
     }

     class TestQueueable implements Queueable {
          public void execute(QueueableContext qc) { }
     }

     @isTest static void Rescheduler_schedule() {
          Test.startTest();
          String jobId = System.schedule('Test Sched', CRON, new TestRescheduler());
          Test.stopTest();
     }

     @isTest static void Rescheduler_run() {
          Test.startTest();
          new TestRescheduler().run();
          Test.stopTest();
     }

     @isTest static void Rescheduler_abort() {
          new TestRescheduler().run();
          Test.startTest();
          new TestRescheduler().abort();
          Test.stopTest();
     }
     
     @isTest static void Rescheduler_getJobs() {
          Test.startTest();
          List<Rescheduler.Job> jobs = new Rescheduler().getJobs();
          Test.stopTest();
     }

     //#endregion

     //#region TaskManager

     static Task__c[] TaskManager_setup() {
          Task__c[] tasks = new Task__c[] {
               new Task__c(Name='Throw', ApexAdapter__c='TransferServiceTest', ApexArgs__c='sThrow=exception', Reference__c='Throw', State__c='Enabled', CronExpression__c=CRON, CronTriggerId__c=SystemX.fakeId(CronTrigger.SObjectType, 0)),
               new Task__c(Name='NoAdapter', ApexAdapter__c='NoAdapter', Reference__c='NoAdapter', State__c='Enabled', CronExpression__c=CRON),
               new Task__c(Name='CTest', ApexAdapter__c='TransferServiceTest', Reference__c='CReference', State__c='Enabled', CronExpression__c=CRON),
               new Task__c(Name='QTest', ApexAdapter__c='TransferServiceTest', Reference__c='QReference', State__c='Enabled', CronExpression__c='R:5')
          };
          insert tasks;
          return tasks;
    }
    
    @isTest static void TaskManager_all() {
          Task__c[] tasks = TaskManager_setup();
          Test.startTest();
          List<String> actual1 = TaskManager.run();
          List<String> actual2 = TaskManager.run(new Set<Id> { tasks[0].Id }, false);
          List<String> actual3 = TaskManager.run(tasks[0].Name, false);
          List<String> actual4 = TaskManager.run(tasks[0].Name, true);
          List<String> actual5 = TaskManager.run('CTest', true);
          List<String> actual6 = TaskManager.run('QTest', true);
          TaskManager.updatex();
          Test.stopTest();
          System.assertEquals(1, actual1.size(), 'Should be value');
          System.assertEquals(2, actual2.size(), 'Should be value');
          System.assertEquals(2, actual3.size(), 'Should be value');
          System.assertEquals(2, actual4.size(), 'Should be value');
     }

    @isTest static void TaskManager_ext() {
          Task__c[] tasks = TaskManager_setup();
	     ApexPages.StandardSetController controller = new ApexPages.StandardSetController(tasks);
          Test.startTest();
	     new TaskManagerPageExt(controller).run();
          Test.stopTest();
          System.assert([SELECT CronTriggerId__c FROM Task__c WHERE Name = 'CTest' LIMIT 1].CronTriggerId__c != null, 'Should be value');
          System.assert([SELECT CronTriggerId__c FROM Task__c WHERE Name = 'QTest' LIMIT 1].CronTriggerId__c == 'QuickSchedule', 'Should be value');
     }

     //#endregion
}