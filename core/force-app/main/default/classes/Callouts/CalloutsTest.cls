@isTest
class CalloutsTest {
    //#region Setup

    public class TestTask extends HttpTask {
        public TestTask() { super(null, 'url', 'successMessage', 'errorMessage'); }
        public override Object callout(HttpBatch batch) { return 'OK'; }
    }

	public class TestLambda implements IHttpLambda {
		public void then(HttpTask task, HttpBatch batch, Object response) { }
        public void end(HttpTask task, HttpBatch batch, Boolean success) { }
	}

    //#endregion

    //#region HttpBatch

    @isTest static void HttpBatch_new() {
        HttpBatch batch1 = new HttpBatch();
        HttpBatch batch2 = new HttpBatch(null, null);
    }

    @isTest static void HttpBatch_values() {
        HttpBatch batch = new HttpBatch();
        batch.put('x', 1);
        Test.startTest();
        Integer actual = (Integer)batch.get('x');
        Test.stopTest();
    }

    @isTest static void HttpBatch_fluent() {
        HttpBatch batch = new HttpBatch();
        HttpTask task = new TestTask()
            .rollback(new TestTask())
            .end(new TestLambda());
        Test.startTest();
        batch
            .clear('name')
            .clearEnds()
            .removeEnds(0)
            .removeEnds(task)
            .add(task)
            .logInformation('message')
            .call(task)
            .call(task, 'key', 'value')
            .checkpoint()
            .exception(null)
            .put('x', 1);
        Test.stopTest();
    }

    @isTest static void HttpBatch_flush() {
        HttpBatch batch = new HttpBatch();
        HttpTask task = new TestTask();
        Test.startTest();
        batch
            .logInformation('message')
            .call(task)
            .flush()
            .flushEnd(true)
            .flushDml();
        Test.stopTest();
    }

    @isTest static void HttpBatch_actions() {
        HttpBatch batch = new HttpBatch();
        HttpTask task = new TestTask();
        Test.startTest();
        batch
            .call(task)
            .end(true);
        Test.stopTest();
    }

    //#endregion

    //#region HttpLambdaTask

    @isTest static void HttpLambdaTask_new() {
        HttpTask task = new HttpLambdaTask('request', 'arg', 'successMessage', 'errorMessage');
        task.callout(null);
    }

    //#endregion

    //#region HttpRestTask

    @isTest static void HttpRestTask_new() {
        Test.setMock(HttpCalloutMock.class, new HttpMock(200, '{}'));
        HttpTask task = new HttpRestTask('request', null, 'arg', 'successMessage', 'errorMessage');
        task.callout(null);
    }

    @isTest static void HttpRestTask_retry() {
        Test.setMock(HttpCalloutMock.class, new HttpMock(200, '[{"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}]'));
        HttpTask task = new HttpRestTask('request', null, 'arg', 'successMessage', 'errorMessage');
        try { task.callout(null); } catch (Exception e) { }
    }

    //#endregion

    //#region HttpTask

    @isTest static void HttpTask_new() {
        HttpTask task = new TestTask();
    }

    @isTest static void HttpTask_fluent() {
        Id accountId = SystemX.fakeId(Account.SObjectType, 0);
        HttpTask task = new TestTask();
        Test.startTest();
        task
            .pragma('name', '^value')
            .log('interactionType', accountId, null, 'message')
            .rollback(task)
            .then(new TestLambda())
            .end(new TestLambda())
            .debug('{0}')
            .bind(null, 'id', 'path');
        Test.stopTest();
    }

    @isTest static void HttpTask_rebind() {
        HttpTask task = new TestTask();
        Test.startTest();
        Object actual = task.rebind('value');
        Test.stopTest();
    }

    @isTest static void HttpTask_result() {
        HttpBatch batch = new HttpBatch();
        HttpTask task1 = new TestTask(), task2 = new TestTask(), task3 = new TestTask(), task4 = new TestTask(), task5 = new TestTask();
        Test.startTest();
        Object actual1 = task1.result();
        Object actual2 = task2.result(batch);
        Object actual3 = task3.result(batch, true);
        task4.wait();
        task5.wait(batch);
        Test.stopTest();
    }

    @isTest static void HttpTask_callout() {
        HttpTask task = new TestTask();
        Test.startTest();
        task.callout(null);
        task.calloutLimit();
        task.calloutRetry(0, null);
        Test.stopTest();
    }

    //#endregion

    //#region HttpX

    @isTest static void HttpX_send() {
        Test.setMock(HttpCalloutMock.class, new HttpMock(200, 'httpResponse'));
        Map<String, Object> accessToken = new Map<String, Object> { 'Authorization' => 'Authorization' };
        Test.startTest();
        HttpResponse actual = HttpX.send('callout', accessToken, new Map<String, Object> {
		    'method' => 'PUT',
		    'endpoint' => 'endpoint',
            'body' => 'body'
        });
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }

    //#endregion

    //#region SelfService

    @isTest static void SelfService_doGet() {
		RestRequest req = RestContext.request = new RestRequest();
		RestResponse res = RestContext.response = new RestResponse();
		Test.startTest();
		SelfService.doGet();
		Test.stopTest();
	}

	@isTest static void SelfService_get() {
		Test.setMock(HttpCalloutMock.class, new HttpMock(200, ''));
		Test.startTest();
		SelfService.getSessionId();
		SelfService.get('sessionId');
		Test.stopTest();
	}

    //#endregion
}