@isTest
class CoreTest {
    //#region Setup

    public class AccountClass { public String Name; public String Description; }
    
    static Map<String, Object> StringT_Values() { return new Map<String, Object> {
        'String' => 'Value',
        'Boolean' => true,
        'Integer' => 1,
        'Long' => 1L,
        'Double' => 1.0,
        'Decimal' => (Decimal)1.0,
        'Date' => Date.newInstance(2020, 1, 1),
        'Datetime' => Datetime.newInstanceGmt(2020, 1, 1, 0, 0, 0),
        'Object' => new Map<String, Object> { 'A' => 'a', 'B' => 'b' },
        'Object2' => new List<Map<String, Object>> { new Map<String, Object> { 'A' => 'a' }, new Map<String, Object> { 'A' => 'a' } }
    }; }

    static String StringT_String() { return 'sString=Value,bBoolean=true,iInteger=1,lLong=1,dDouble=1.0,dDecimal=1.0,yDate=2020-01-01,zDatetime=2020-01-01 00:00:00,oObject={sA=a`sB=b},oObject2=[{sA=a}`{sA=a}]'; }

    //#endregion

    //#region BlobX

    @isTest static void BlobX_subblob() {
        Test.startTest();
        Blob actual1 = BlobX.subblob(Blob.valueOf('test'), 0, 4);
        Blob actual2 = BlobX.subblob(Blob.valueOf('test'), new Range(0, 4));
        Test.stopTest();
        System.assertEquals('test', actual1.toString(), 'should be value');
        System.assertEquals('test', actual2.toString(), 'should be value');
    }

    @isTest static void BlobX_decode() {
        Test.startTest();
        String actual = BlobX.decode(Blob.valueOf('test'));
        Test.stopTest();
        System.assertEquals('test', actual, 'should be value');
    }

    @isTest static void BlobX_encode() {
        Test.startTest();
        Blob actual = BlobX.encode('test');
        Test.stopTest();
        System.assertEquals('test', actual.toString(), 'should be value');
    }

    //#endregion

    //#region Combine

    @isTest static void Combine_crossJoin() {
        Account s; insert s = new Account(Name='AccountName');
        Case s2; insert s2 = new Case(AccountId=s.Id);
        Contract s3; insert s3 = new Contract(AccountId=s.Id, Name='ContractName');
        List<SObject> scope = [SELECT Id, (SELECT Id FROM Cases), (SELECT Id FROM Contracts) FROM Account WHERE Id = :s.Id LIMIT 1];
        Test.startTest();
        List<Object> actual1 = Combine.crossJoin(scope, new String[] { 'Cases' }, false);
        List<Object> actual2 = Combine.crossJoin(scope, new String[] { 'Cases', 'Contracts' }, false);
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
	}

    @isTest static void Combine_CrossJoinx() {
        Account s; insert s = new Account(Name='AccountName');
        Case s2; insert s2 = new Case(AccountId=s.Id);
        Contract s3; insert s3 = new Contract(AccountId=s.Id, Name='ContractName');
        List<SObject> scope = [SELECT Id, (SELECT Id FROM Cases), (SELECT Id FROM Contracts) FROM Account WHERE Id = :s.Id LIMIT 1];
        Test.startTest();
        List<Object> actual1 = Combine.crossJoinx(scope, new String[] { 'Cases' }, null);
        List<Object> actual2 = Combine.crossJoinx(scope, new String[] { 'Cases', 'Contracts' }, null);
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
	}
    
    @isTest static void Combine_crossJoinItems() {
        Account sA = new Account(Name='Account', Description='Desc'); insert sA; Case sAC = new Case(AccountId = sA.Id); insert sAC;
        Account sJ0 = new Account(Name='Account1', Description='{"single": "one"}');
        Account sJ1 = new Account(Name='Account2', Description='[{"name":"a"}, {"name":"b"}]');
        Account sJ2 = new Account(Name='Account3', Description='{"path": {"single": "one"}}');
        Account sJ3 = new Account(Name='Account4', Description='{"path": [{"name":"a"}, {"name":"b"}]}');
        Object s0 = [SELECT Id, Description, (SELECT Id FROM Cases) FROM Account WHERE Id = :sA.Id LIMIT 1][0];
        Map<String, Object> m0 = new Map<String, Object> { 'Name'=>'Account', 'Description'=>'Desc', 'Cases'=>new Object[] { new Map<String, Object> { 'Name'=>'a' } } };
        AccountClass o0 = new AccountClass(); o0.Name='Account'; o0.Description='Desc';
        Test.startTest();
        List<Object> actuals0 = Combine.crossJoinItems(s0, 'Cases', null);
        List<Object> actuals1 = Combine.crossJoinItems(s0, 'Description:get', null);
        List<Object> actualsJ0 = Combine.crossJoinItems(sJ0, 'Description:json', null);
        List<Object> actualsJ1 = Combine.crossJoinItems(sJ1, 'Description:json', null);
        List<Object> actualsJ2 = Combine.crossJoinItems(sJ2, 'Description:json;path', null);
        List<Object> actualsJ3 = Combine.crossJoinItems(sJ3, 'Description:json;path', null);
        List<Object> actualm0 = Combine.crossJoinItems(m0, 'Cases', null);
        List<Object> actualm1 = Combine.crossJoinItems(m0, 'Description', null);
        List<Object> actualo0 = Combine.crossJoinItems(o0, 'Description', null);
        Test.stopTest();
        System.assert(actuals0 != null, 'Should be value');
        System.assert(actuals1 != null, 'Should be value');
        System.assert(actualsJ0 != null, 'Should be value');
        System.assert(actualsJ1 != null, 'Should be value');
        System.assert(actualsJ2 != null, 'Should be value');
        System.assert(actualsJ3 != null, 'Should be value');
        System.assert(actualm0 != null, 'Should be value');
        System.assert(actualm1 != null, 'Should be value');
        System.assert(actualo0 != null, 'Should be value');
	}

    @isTest static void Combine_rescope() {
        Account s; insert s = new Account(Name='AccountName');
        Case s2; insert s2 = new Case(AccountId=s.Id);
        Contract s3; insert s3 = new Contract(AccountId=s.Id, Name='ContractName');
        List<SObject> scope = [SELECT Id, (SELECT Id FROM Cases), (SELECT Id FROM Contracts) FROM Account WHERE Id = :s.Id LIMIT 1];
        Test.startTest();
        List<Object> actual = Combine.rescope(scope, 'crossjoin:Cases,Contracts', null);
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
	}

    //#endregion

    //#region Core

    class TestFunc implements Core.Func { public Object func() { return 0; } }
    class TestFunc1 implements Core.Func1 { public Object func(Object arg1) { return 1; } }
    class TestFunc2 implements Core.Func2 { public Object func(Object arg1, Object arg2) { return 2; } }
    class TestFunc3 implements Core.Func3 { public Object func(Object arg1, Object arg2, Object arg3) { return 3; } }
    class TestFunc4 implements Core.Func4 { public Object func(Object arg1, Object arg2, Object arg3, Object arg4) { return 4; } }

    @isTest static void Core_getSingleton() {
        Test.startTest();
        DefaultOptions actual = (DefaultOptions)Core.getSingleton(DefaultOptions.class);
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }

    @isTest static void Core_triggerDatetime() {
        Test.startTest();
        Boolean actual1 = Core.triggerDatetime(null, '*');
        Boolean actual2 = Core.triggerDatetime(null, 'min:1,2');
        Boolean actual3 = Core.triggerDatetime(null, 'hour:1');
        Boolean actual4 = Core.triggerDatetime(null, 'day:1');
        Boolean actual5 = Core.triggerDatetime(null, 'dow:Mon');
        Boolean actual6 = Core.triggerDatetime(null, 'dow:Mon;hour:1');
        Test.stopTest();
    }

    @isTest static void Core_threadSleep() {
        Test.startTest();
        Core.threadSleep(1);
        Test.stopTest();
    }

    @isTest static void Core_lambda() {
        Test.startTest();
        Object actual0 = Core.invoke(TestFunc.class);
        Object actual1 = Core.invoke(TestFunc1.class, null);
        Object actual2 = Core.invoke(TestFunc2.class, null, null);
        Object actual3 = Core.invoke(TestFunc3.class, null, null, null);
        Object actual4 = Core.invoke(TestFunc4.class, null, null, null, null);
        Test.stopTest();
        System.assert(actual0 != null, 'Should be value');
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
        System.assert(actual3 != null, 'Should be value');
        System.assert(actual4 != null, 'Should be value');
    }

    //#endregion

    //#region DatabaseX

    @isTest static void DatabaseX_updatex() {
        Account account = new Account(Name='Test'); insert account;
        List<SObject> scope = new SObject[] { account, account };
        Test.startTest();
        DatabaseX.updatex('first', scope, true);
        DatabaseX.updatex('last', scope, true);
        DatabaseX.updatex('all', scope, true);
        Test.stopTest();
	}

    //#endregion

    //#region DatetimeX

    @isTest static void DatetimeX_addMinutes() {
        Test.startTest();
        Datetime actual1 = DatetimeX.addMinutes(Datetime.newInstanceGmt(2001, 1, 1), (Double)1.5);
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
    }

    @isTest static void DatetimeX_format() {
        System.assertEquals('2001-01-01T00:00:00Z000', DatetimeX.format(Datetime.newInstanceGmt(2001, 1, 1), 'iso', 'GMT'));
        System.assertEquals('ZL2649600000', DatetimeX.format(Datetime.newInstanceGmt(2001, 1, 1), 'stamp', null));
    }
    
    @isTest static void DatetimeX_parseDatetimeGmt() {
        Test.startTest();
        Datetime actual1 = DatetimeX.parse('2022-09-26 14:57:52', null);
        Datetime actual2 = DatetimeX.parse('2022-09-26 14:57:52', 'gmt');
        Datetime actual3 = DatetimeX.parse('2022-09-26T14:57:52', 'iso');
        Datetime actual4 = DatetimeX.parse('2022-09-26T14:57:52Z', 'iso');
        Datetime actual5 = DatetimeX.parse('Wed, 01 Mar 2023 18:14:23 GMT', 'azure');
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
        System.assert(actual3 != null, 'Should be value');
        System.assert(actual4 != null, 'Should be value');
        System.assert(actual5 != null, 'Should be value');
    }

    //#endregion

    //#region DefaultOptions

    @isTest static void DefaultOptions_new() {
        Test.startTest();
        DefaultOptions option = new DefaultOptions();
        option.serviceUserAlias(null);
        DefaultOptions actual = Core.options;
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }

    //#endregion

    //#region Dml

    @isTest static void Dml_all() {
        Dml.clear();
        Dml.flush();
        Dml.flush(null);
        Dml.flush(null, true);
    }

    //#endregion

    //#region DoubleX

    @isTest static void DoubleX_format() {
        System.assertEquals(null, DoubleX.format(null, 'USD', null));
        System.assertEquals('1.50', DoubleX.format(1.5, '$', null));
        System.assertEquals('$1.50', DoubleX.format(1.5, 'USD', null));
        System.assertEquals('€1.50', DoubleX.format(1.5, 'EUR', null));
        System.assertEquals('£1.50', DoubleX.format(1.5, 'GBP', null));
        System.assertEquals('$1.50', DoubleX.format(1.5, 'AUD', null));
        System.assertEquals('$1.50', DoubleX.format(1.5, 'CAD', null));
    }

    //#endregion

    //#region EventBusX

    @isTest static void EventBusX_publish() {
        EventBusX.publish(new SObject[] { new BatchApexErrorEvent() });
    }

    //#endregion

    //#region FString

    @isTest static void AString_new() {
        FString src0 = new FString(); src0.Key='sKey'; src0.S='Test';
        FString src1 = new FString(); src1.Key='sKey'; src1.S='Test';
        FString src2 = new FString(); src2.Key='sKey'; src2.S='Test';
        Test.startTest();
        // Operation: Add
        FString.Input in0 = new FString.Input();
        in0.Source = src0;
        in0.Operation = 'Add';
        in0.Key = 'oObject';
        FString value0 = new FString(); value0.Key='sValue'; value0.S='Value'; in0.Value = new List<FString> { value0 };
        FString.Output out0 = FString.execute(new List<FString.Input> { in0 })[0];
        // Operation: Set
        FString.Input in1 = new FString.Input();
        in1.Source = src1;
        in1.Operation = 'Set';
        in0.Key = 'oObject';
        FString value1 = new FString(); value1.Key='sValue'; value1.S='Value'; in1.Value = new List<FString> { value1 };
        FString.Output out1 = FString.execute(new List<FString.Input> { in1 })[0];
        // Operation: Debug
        FString.Input in2 = new FString.Input();
        in2.Source = src2;
        in2.Operation = 'Debug';
        FString.Output out2 = FString.execute(new List<FString.Input> { in2 })[0];
        Test.stopTest();
	    System.assert(src0.O != null, 'Should be value');
        System.assert(src1.O != null, 'Should be value');
        System.assert(src2.O == null, 'Should be value');
    }

    @isTest static void AString_decodeMap() {
        List<FString> actual1 = FString.decodeMap(StringT_String(), false);
        Map<String, Object> actual2 = FString.decodeMap(actual1, false);
        System.assert(actual1.size() == 10, 'Should be value');
        System.assert(actual2.get('String') instanceOf String, 'Should be value');
        System.assert(actual2.get('Integer') instanceOf Integer, 'Should be value');
        System.assert(actual2.get('Boolean') instanceOf Boolean, 'Should be value');
        System.assert(actual2.get('Double') instanceOf Double, 'Should be value');
        System.assert(actual2.get('Decimal') instanceOf Decimal, 'Should be value');
        System.assert(actual2.get('Datetime') instanceOf Datetime, 'Should be value');
        System.assert(actual2.get('Date') instanceOf Date, 'Should be value');
        System.assert(actual2.get('Object') instanceOf Map<String, Object>, 'Should be value');
        System.assert(actual2.get('Object2') instanceOf List<Map<String, Object>>, 'Should be value');
    }

    @isTest static void AString_encodeMap() {
        List<FString> actual1 = FString.encodeMap(StringT_Values(), false);
        String actual2 = FString.encodeMap(actual1, false);
        System.assertEquals(StringT_String(), actual2, 'Should be value');
    }

    //#endregion

    //#region GrammerX

    @isTest static void GrammerX_validEmail() {
        Test.startTest();
        Boolean actual1 = GrammerX.validEmail('test');
        Boolean actual2 = GrammerX.validEmail('test@email');
        Boolean actual3 = GrammerX.validEmail('test-me@email.com');
        Boolean actual4 = GrammerX.validEmail('test\\me@email.com');
        Boolean actual5 = GrammerX.validEmail('Test.ME@email.com');
        Boolean actual6 = GrammerX.validEmail('test,me@email.com');
        Test.stopTest();
        System.assert(!actual1, 'Should be value');
        System.assert(!actual2, 'Should be value');
        System.assert(actual3, 'Should be value');
        System.assert(!actual4, 'Should be value');
        System.assert(actual5, 'Should be value');
        System.assert(!actual6, 'Should be value');
	}

    @isTest static void GrammerX_cleanEmail() {
        Test.startTest();
        String actual1 = GrammerX.cleanEmail('test');
        String actual2 = GrammerX.cleanEmail('test@email');
        String actual3 = GrammerX.cleanEmail('test-me@email.com');
        String actual4 = GrammerX.cleanEmail('test\\me@email.com');
        String actual5 = GrammerX.cleanEmail('Test@email.com');
        String actual6 = GrammerX.cleanEmail('test,me@email.com');
        Test.stopTest();
        System.assertEquals('test', actual1, 'Should be value');
        System.assertEquals('test@email', actual2, 'Should be value');
        System.assertEquals('test-me@email.com', actual3, 'Should be value');
        System.assertEquals('testme@email.com', actual4, 'Should be value');
        System.assertEquals('Test@email.com', actual5, 'Should be value');
        System.assertEquals('testme@email.com', actual6, 'Should be value');
	}

    @isTest static void GrammerX_ensureEmail() {
        GrammerX grammer = new GrammerX();
        Test.startTest();
        String actual1 = grammer.ensureEmail('test', 'bad');
        String actual2 = grammer.ensureEmail('test@email', 'bad');
        String actual3 = grammer.ensureEmail('test@email.com', 'bad');
        String actual4 = grammer.ensureEmail('test\\me@email.com', 'bad');
        String actual5 = grammer.ensureEmail('Test@email.com', 'bad');
        String actual6 = grammer.ensureEmail('test,this@email.com', 'bad');
        Test.stopTest();
        System.assertEquals('bad@bademail.com', actual1, 'Should be value');
        System.assertEquals('bad@bademail.com', actual2, 'Should be value');
        System.assertEquals('test@email.com', actual3, 'Should be value');
        System.assertEquals('bad@bademail.com', actual4, 'Should be value');
        System.assertEquals('Test@email.com', actual5, 'Should be value');
        System.assertEquals('bad@bademail.com', actual6, 'Should be value');
	}

    @isTest static void GrammerX_makeBadEmail() {
        GrammerX grammer = new GrammerX();
        Test.startTest();
        String actual1 = grammer.makeBadEmail('bad');
        String actual2 = grammer.makeBadEmail('bad email');
        String actual3 = grammer.makeBadEmail('bad.email');
        String actual4 = grammer.makeBadEmail('bad-email');
        String actual5 = grammer.makeBadEmail('bad,email');
        Test.stopTest();
        System.assertEquals('bad@bademail.com', actual1, 'Should be value');
        System.assertEquals('bad.email@bademail.com', actual2, 'Should be value');
        System.assertEquals('bad.email@bademail.com', actual3, 'Should be value');
        System.assertEquals('bad-email@bademail.com', actual4, 'Should be value');
        System.assertEquals('bademail@bademail.com', actual5, 'Should be value');
	}

    //#endregion

    //#region IntegerX

    @isTest static void IntegerX_hexToInt_intToHex() {
        Test.startTest();
        Integer actual1 = IntegerX.hexToInt('ff');
        String actual2 = IntegerX.intToHex(255, true);
        String actual3 = IntegerX.intToHex(256, true);
        String actual4 = IntegerX.intToHex(256, false);
        Test.stopTest();
        System.assert(actual1 == 255, 'Should be value');
        System.assert(actual2 == 'ff', 'Should be value');
        System.assert(actual3 == '0100', 'Should be value');
        System.assert(actual4 == '100', 'Should be value');
    }

    //#endregion

    //#region IString

    @isTest static void IString_new() {
        IString actual1 = new IString('str');
        IString actual2 = new IString((Object)'str');
        IString actual3 = new IString((String)null);
        IString actual4 = new IString(123);
        System.assertEquals('str', actual1?.str, 'Should be value');
        System.assertEquals('str', actual2?.str, 'Should be value');
        System.assertEquals(null, actual3?.str, 'Should be value');
        System.assertEquals('123', actual4?.str, 'Should be value');
    }

    @isTest static void IString_equals_hashCode_isEmpty() {
        IString str1 = new IString('str');
        IString str2 = new IString((Object)'str');
        IString str3 = new IString((String)null);
        IString str4 = new IString('');
        Test.startTest();
        Boolean actual_equals1 = str1.equals(str2);
        Boolean actual_equals2 = str3.equals(str4);
        Boolean actual_hashCode1 = str1.hashCode() == str2.hashCode();
        Boolean actual_hashCode2 = str3.hashCode() == str4.hashCode();
        Boolean actual_isempty1 = IString.isEmpty(str1);
        Boolean actual_isempty2 = IString.isEmpty(str2);
        Boolean actual_isempty3 = IString.isEmpty(str3);
        Boolean actual_isempty4 = IString.isEmpty(str3);
        Test.stopTest();
        System.assertEquals(true, actual_equals1, 'Should be value');
        System.assertEquals(false, actual_equals2, 'Should be value');
        System.assertEquals(true, actual_hashCode1, 'Should be value');
        System.assertEquals(true, actual_hashCode2, 'Should be value');
        System.assertEquals(false, actual_isempty1, 'Should be value');
        System.assertEquals(false, actual_isempty2, 'Should be value');
        System.assertEquals(true, actual_isempty3, 'Should be value');
        System.assertEquals(true, actual_isempty4, 'Should be value');
    }

    @isTest static void IString_listx_set() {
        List<IString> str_list = new List<IString> { new IString('str'), new IString('str2') };
        Set<IString> str_set = new Set<IString> { new IString('str'), new IString('str2') };
        Test.startTest();
        List<String> actual_list = IString.listx(str_list);
        Set<String> actual_set = IString.set(str_set);
        Test.stopTest();
        System.assertEquals(2, actual_list.size(), 'Should be value');
        System.assertEquals(2, actual_set.size(), 'Should be value');
    }

    //#endregion

    //#region LimitsX

    @isTest static void LimitsX_asyncApex() {
        Boolean allowed = LimitsX.asyncApex(0, false);
        System.assert(allowed, 'Should be value');
	}

    @isTest static void LimitsX_get() {
        Test.startTest();
        Map<String, Integer> actual = LimitsX.get(new List<String> {
            'aggregateQueries',
            'asyncCalls',
            'callouts',
            'cpuTime',
            'dmlRows',
            'dmlStatements',
            'emailInvocations',
            'heapSize',
            'mobilePushApexCalls',
            'publishImmediateDML',
            'queries',
            'queryLocatorRows',
            'queryRows',
            'queueableJobs',
            'soslQueries'
        });
        Test.stopTest();
        System.assertEquals(15, actual.size(), 'Should be value');
    }

    @isTest static void LimitsX_reached() {
        Test.startTest();
        Boolean actual = LimitsX.reached(new List<String> {
            'aggregateQueries',
            'asyncCalls',
            'callouts',
            'cpuTime',
            'dmlRows',
            'dmlStatements',
            'emailInvocations',
            'heapSize',
            'mobilePushApexCalls',
            'publishImmediateDML',
            'queries',
            'queryLocatorRows',
            'queryRows',
            'queueableJobs',
            'soslQueries'
        });
        Test.stopTest();
        System.assertEquals(false, actual, 'Should be value');
    }

    //#endregion

    //#region ListX

    @isTest static void ListX_getIds() {
        Account obj = new Account(Name='Account'); insert obj;
        IdObj obj2 = new IdObj(obj.Id, obj);
        Test.startTest();
        List<Id> actual1 = ListX.getIds(new IdObj[] { obj2 });
        List<Id> actual2 = ListX.getIds(new SObject[] { obj });
        List<Id> actual3 = ListX.getIds(new SObject[] { obj }, 'Id');
        Test.stopTest();
        System.assertEquals(1, actual1.size(), 'Should be value');
        System.assertEquals(1, actual2.size(), 'Should be value');
        System.assertEquals(1, actual3.size(), 'Should be value');
    }

    @isTest static void ListX_getStrings() {
        Account obj = new Account(Name='Account');
        Test.startTest();
        List<String> actual1 = ListX.getStrings(new SObject[] { obj }, 'Name');
        Test.stopTest();
        System.assertEquals(1, actual1.size(), 'Should be value');
    }

    //#endregion

    //#region MapX

    @isTest static void MapX_get() {
        Map<String, Object> parent = new Map<String, Object> { 'Name'=>'Parent' };
        Map<String, Object> obj = new Map<String, Object> { 'Name'=>'Account', 'Parent'=>parent };
        Map<String, Object> s0 = new Map<String, Object> { 'Name'=>'Account', 'Parent'=>parent };
        Test.startTest();
        String actual1a = (String)ObjectX.get(s0, 'Name');
        String actual1b = (String)ObjectX.get(s0, 'Parent.Name');
        String actual2a = (String)ObjectX.get(obj, new List<String> { 'Name' }).get('Name');
        String actual2b = (String)ObjectX.get(obj, new List<String> { 'Parent.Name' }).get('Parent.Name');
        Test.stopTest();
        System.assertEquals('Account', actual1a, 'Should be value');
        System.assertEquals('Parent', actual1b, 'Should be value');
        System.assertEquals('Account', actual2a, 'Should be value');
        System.assertEquals('Parent', actual2b, 'Should be value');
    }

    @isTest static void MapX_put() {
        Map<String, Object> parent = new Map<String, Object> { 'Name'=>'Parent' };
        Map<String, Object> obj1 = new Map<String, Object> { 'Name'=>'Account', 'Parent'=>parent };
        Map<String, Object> obj2 = new Map<String, Object> { 'Name'=>'Account', 'Parent'=>parent };
        Test.startTest();
        ObjectX.put(obj1, 'Name', 'Account2');
        ObjectX.put(obj1, 'Parent.Name', 'Parent2');
        ObjectX.put(obj2, new Map<String, Object> { 'Name' => 'Account2' });
        ObjectX.put(obj2, new Map<String, Object> { 'Parent.Name' => 'Parent2' });
        String actual1a = (String)obj1.get('Name');
        String actual1b = (String)((Map<String, Object>)obj1.get('Parent')).get('Name');
        String actual2a = (String)obj2.get('Name');
        String actual2b = (String)((Map<String, Object>)obj2.get('Parent')).get('Name');
        Test.stopTest();
        System.assertEquals('Account2', actual1a, 'Should be value');
        System.assertEquals('Parent2', actual1b, 'Should be value');
        System.assertEquals('Account2', actual2a, 'Should be value');
        System.assertEquals('Parent2', actual2b, 'Should be value');
    }

    @isTest static void MapX_getIds() {
        Account obj = new Account(Name='Account'); insert obj;
        Map<Id, SObject> actual1 = MapX.getIds(new SObject[] { obj }, 'Id');
        Map<Id, List<SObject>> actual2 = MapX.getIdSet(new SObject[] { obj }, 'Id');
        System.assertEquals(1, actual1.size(), 'Should be value');
        System.assertEquals(1, actual2.size(), 'Should be value');
    }

    @isTest static void MapX_getStrings() {
        Account obj = new Account(Name='Account');
        Map<String, SObject> actual1 = MapX.getStrings(new SObject[] { obj }, 'Name');
        Map<String, List<SObject>> actual2 = MapX.getStringSet(new SObject[] { obj }, 'Name');
        System.assertEquals(1, actual1.size(), 'Should be value');
        System.assertEquals(1, actual2.size(), 'Should be value');
    }

    @isTest static void MapX_invert() {
        Id fakeId = SystemX.fakeId(Account.SObjectType, 1);
        Map<String, String> test1 = new Map<String, String> { fakeId => 'value' };
        Map<Id, String> test2 = new Map<Id, String> { fakeId => 'value' };
        Map<String, Id> test3 = new Map<String, Id> { 'key' => fakeId };
        Map<String, IdObj> test4 = new Map<String, IdObj> { 'key' => new IdObj(fakeId, 'value') };
        Map<IString, IdObj> test5 = new Map<IString, IdObj> { new IString('key') => new IdObj(fakeId, 'value') };
        Map<String, String> actual1 = MapX.invert(test1);
        Map<String, Id> actual2 = MapX.invert(test2);
        Map<Id, String> actual3 = MapX.invert(test3);
        Map<Id, String> actual4 = MapX.invert(test4);
        Map<Id, IString> actual5 = MapX.invert(test5);
        System.assertEquals(fakeId, actual1.get('value'), 'Should be value1');
        System.assertEquals(fakeId, actual2.get('value'), 'Should be value2');
        System.assertEquals('key', actual3.get(fakeId), 'Should be value3');
        System.assertEquals('key', actual4.get(fakeId), 'Should be value4');
        System.assertEquals('key', actual5.get(fakeId).toString(), 'Should be value4');
    }

    @isTest static void MapX_dump() {
        String actual1 = MapX.dump('prefix', new Map<String, String> {
            'key1' => 'val1',
            'key2' => 'val2',
            '' => 'body'
        });
        String actual2 = MapX.dump(new Map<String, String> {
            'key1' => 'val1',
            'key2' => 'val2',
            '' => 'body'
        });
    }

    //#endregion

    //#region ObjectX

    @isTest static void ObjectX_GroupAtIterator() {
        Integer[] objs = new Integer[] { 1, 2, 3, 4 };
        Integer[] objs2 = new Integer[] { 1, 2, 3, 4, 5 };
        ObjectX.GroupAtIterator actual = new ObjectX.GroupAtIterator(null, 2);
        ObjectX.GroupAtIterator actual2 = new ObjectX.GroupAtIterator(objs, 2);
        ObjectX.GroupAtIterator actual3 = new ObjectX.GroupAtIterator(objs2, 2);
        Integer actualSize = 0; while (actual.hasNext()) { actual.next(); actualSize++; }
        Integer actual2Size = 0; while (actual2.hasNext()) { actual2.next(); actual2Size++; }
        Integer actual3Size = 0; while (actual3.hasNext()) { actual3.next(); actual3Size++; }
        System.assertEquals(0, actualSize, 'Should be value');
        System.assertEquals(2, actual2Size, 'Should be value');
        System.assertEquals(3, actual3Size, 'Should be value');
    }

    @isTest static void ObjectX_groupAt() {
        Integer[] objs = new Integer[] { 1, 2, 3, 4 };
        Integer[] objs2 = new Integer[] { 1, 2, 3, 4, 5 };
        List<List<Object>> actual = ObjectX.groupAt(null, 2);
        List<List<Object>> actual2 = ObjectX.groupAt(objs, 2);
        List<List<Object>> actual3 = ObjectX.groupAt(objs2, 2);
        System.assertEquals(0, actual.size(), 'Should be value');
        System.assertEquals(2, actual2.size(), 'Should be value');
        System.assertEquals(3, actual3.size(), 'Should be value');
    }

    @isTest static void ObjectX_untype() {
        AccountClass s0 = new AccountClass(); s0.Name='Account'; s0.Description='Desc';
        Test.startTest();
        Map<String, Object> actual1 = ObjectX.untype(s0);
        Test.stopTest();
        System.assertEquals('Account', actual1.get('Name'), 'Should be value');
    }

    @isTest static void ObjectX_get() {
        Account parent = new Account(Name='Parent');
        Account obj = new Account(Name='Account', Parent=parent);
        Account s0 = new Account(Name='Account', Parent=parent);
        AccountClass o0 = new AccountClass(); o0.name = 'Account';
        Test.startTest();
        String actual1a = (String)ObjectX.get(s0, 'Name');
        String actual1b = (String)ObjectX.get(s0, 'Parent.Name');
        String actual1c = (String)ObjectX.get(o0, 'Name');
        String actual2a = (String)ObjectX.get(obj, new List<String> { 'Name' }).get('Name');
        String actual2b = (String)ObjectX.get(obj, new List<String> { 'Parent.Name' }).get('Parent.Name');
        Test.stopTest();
        System.assertEquals('Account', actual1a, 'Should be value');
        System.assertEquals('Parent', actual1b, 'Should be value');
        System.assertEquals('Account', actual1c, 'Should be value');
        System.assertEquals('Account', actual2a, 'Should be value');
        System.assertEquals('Parent', actual2b, 'Should be value');
    }

    @isTest static void ObjectX_put() {
        Account parent = new Account(Name='Parent');
        Account obj1 = new Account(Name='Account', Parent=parent);
        Account obj2 = new Account(Name='Account', Parent=parent);
        Test.startTest();
        ObjectX.put(obj1, 'Name', 'Account2');
        ObjectX.put(obj1, 'Parent.Name', 'Parent2');
        ObjectX.put(obj2, new Map<String, Object> { 'Name' => 'Account2' });
        ObjectX.put(obj2, new Map<String, Object> { 'Parent.Name' => 'Parent2' });
        String actual1a = obj1.Name;
        String actual1b = obj1.Parent.Name;
        String actual2a = obj2.Name;
        String actual2b = obj2.Parent.Name;
        Test.stopTest();
        System.assertEquals('Account2', actual1a, 'Should be value');
        System.assertEquals('Parent2', actual1b, 'Should be value');
        System.assertEquals('Account2', actual2a, 'Should be value');
        System.assertEquals('Parent2', actual2b, 'Should be value');
    }

    @isTest static void ObjectX_mergex() {
        Map<String, Object> m = new Map<String, Object> { 'Name' => 'AccountName' };
        Account s = new Account(Name='AccountName'); insert s; s = [SELECT Name, Owner.Name FROM Account WHERE Id = :s.Id LIMIT 1];
        AccountClass o = new AccountClass(); o.name = 'AccountName';
        Test.startTest();
        // Map<String, Object>
        Object actualM1 = ObjectX.mergex(m, null);
        Object actualM2 = ObjectX.mergex(m, 0);
        Object actualM3 = ObjectX.mergex(m, 'string');
        Object actualM4 = ObjectX.mergex(m, '{{Name}}');
        Object actualM5 = ObjectX.mergex(m, 'x{{Name}}');
        Object actualM6 = ObjectX.mergex(m, '|{{Name}}-{{Name}}|');
        // Object actualM7 = ObjectX.mergex(m, '{{Owner.Name}}');
        // Object actualM8 = ObjectX.mergex(m, '{{Name}}: {{Owner.Name}}');
        // List<SObject>
        Object actualL1 = ObjectX.mergex(new SObject[] { s }, null);
        Object actualL2 = ObjectX.mergex(new SObject[] { s }, 0);
        Object actualL3 = ObjectX.mergex(new SObject[] { s }, 'string');
        Object actualL4 = ObjectX.mergex(new SObject[] { s }, '{{0:Name}}');
        Object actualL5 = ObjectX.mergex(new SObject[] { s }, 'x{{0:Name}}');
        Object actualL6 = ObjectX.mergex(new SObject[] { s }, '|{{0:Name}}-{{0:Name}}|');
        Object actualL7 = ObjectX.mergex(new SObject[] { s }, '{{0:Owner.Name}}');
        Object actualL8 = ObjectX.mergex(new SObject[] { s }, '{{0:Name}}: {{0:Owner.Name}}');
        // List<Object>
        Object actualP1 = ObjectX.mergex(new Object[] { o }, null);
        Object actualP2 = ObjectX.mergex(new Object[] { o }, 0);
        Object actualP3 = ObjectX.mergex(new Object[] { o }, 'string');
        Object actualP4 = ObjectX.mergex(new Object[] { o }, '{{0:Name}}');
        Object actualP5 = ObjectX.mergex(new Object[] { o }, 'x{{0:Name}}');
        Object actualP6 = ObjectX.mergex(new Object[] { s }, '|{{0:Name}}-{{0:Name}}|');
        // Object actualP7 = ObjectX.mergex(new Object[] { s }, '{{0:Owner.Name}}');
        // Object actualP8 = ObjectX.mergex(new Object[] { s }, '{{0:Name}}: {{0:Owner.Name}}');
        // SObject
        Object actualS1 = ObjectX.mergex(s, null);
        Object actualS2 = ObjectX.mergex(s, 0);
        Object actualS3 = ObjectX.mergex(s, 'string');
        Object actualS4 = ObjectX.mergex(s, '{{Name}}');
        Object actualS5 = ObjectX.mergex(s, 'x{{Name}}');
        Object actualS6 = ObjectX.mergex(s, '|{{Name}}-{{Name}}|');
        Object actualS7 = ObjectX.mergex(s, '{{Owner.Name}}');
        Object actualS8 = ObjectX.mergex(s, '{{Name}}: {{Owner.Name}}');
        // Object
        Object actualO1 = ObjectX.mergex(o, null);
        Object actualO2 = ObjectX.mergex(o, '0');
        Object actualO3 = ObjectX.mergex(o, 'string');
        Object actualO4 = ObjectX.mergex(o, '{{Name}}');
        Object actualO5 = ObjectX.mergex(o, 'x{{Name}}');
        Object actualO6 = ObjectX.mergex(o, '|{{Name}}-{{Name}}|');
        // Object actualO7 = ObjectX.mergex(o, '{{Owner.Name}}');
        // Object actualO8 = ObjectX.mergex(o, '{{Name}}: {{Owner.Name}}');
        Test.stopTest();
        // Map<String, Object>
        System.assertEquals(null, actualM1, 'Should be value :M1');
        System.assertEquals(0, actualM2, 'Should be value :M2');
        System.assertEquals('string', actualM3, 'Should be value :M3');
        System.assertEquals('AccountName', actualM4, 'Should be value :M4');
        System.assertEquals('xAccountName', actualM5, 'Should be value :M5');
        System.assertEquals('|AccountName-AccountName|', actualM6, 'Should be value :M6');
        // System.assert(actualM7 != null, 'Should be value :M7');
        // System.assert(actualM8 != null, 'Should be value :M8');
        // List<SObject>
        System.assertEquals(null, actualL1, 'Should be value :L1');
        System.assertEquals(0, actualL2, 'Should be value :L2');
        System.assertEquals('string', actualL3, 'Should be value :L3');
        System.assertEquals('AccountName', actualL4, 'Should be value :L4');
        System.assertEquals('xAccountName', actualL5, 'Should be value :L5');
        System.assertEquals('|AccountName-AccountName|', actualL6, 'Should be value :L6');
        System.assert(actualL7 != null, 'Should be value :L7');
        System.assert(actualL8 != null, 'Should be value :L8');
        // List<Object>
        System.assertEquals(null, actualP1, 'Should be value :P1');
        System.assertEquals(0, actualP2, 'Should be value :P2');
        System.assertEquals('string', actualP3, 'Should be value :P3');
        System.assertEquals('AccountName', actualP4, 'Should be value :P4');
        System.assertEquals('xAccountName', actualP5, 'Should be value :P5');
        System.assertEquals('|AccountName-AccountName|', actualP6, 'Should be value :P6');
        // System.assert(actualP7 != null, 'Should be value :P7');
        // System.assert(actualP8 != null, 'Should be value :P8');
        // SObject
        System.assertEquals(null, actualS1, 'Should be value :S1');
        System.assertEquals(0, actualS2, 'Should be value :S2');
        System.assertEquals('string', actualS3, 'Should be value :S3');
        System.assertEquals('AccountName', actualS4, 'Should be value :S4');
        System.assertEquals('xAccountName', actualS5, 'Should be value :S5');
        System.assertEquals('|AccountName-AccountName|', actualS6, 'Should be value :S6');
        System.assert(actualS7 != null, 'Should be value :S7');
        System.assert(actualS8 != null, 'Should be value :S8');
        // Object
        System.assertEquals(null, actualO1, 'Should be value :O1');
        System.assertEquals('0', actualO2, 'Should be value :O2');
        System.assertEquals('string', actualO3, 'Should be value :O3');
        System.assertEquals('AccountName', actualO4, 'Should be value :O4');
        System.assertEquals('xAccountName', actualO5, 'Should be value :O5');
        System.assertEquals('|AccountName-AccountName|', actualO6, 'Should be value :O6');
        // System.assert(actualO7 != null, 'Should be value :O7');
        // System.assert(actualO8 != null, 'Should be value :O8');
	}

    //#endregion

    //#region PathX

    @isTest static void PathX_guessContentType() {
        Test.startTest();
        String actual1 = PathX.guessContentType('.docx');
        String actual2 = PathX.guessContentType('.xml');
        String actual3 = PathX.guessContentType('.csv');
        String actual4 = PathX.guessContentType('.wav');
        String actual5 = PathX.guessContentType('.wmv');
        String actual6 = PathX.guessContentType('.mp3');
        String actual7 = PathX.guessContentType('.mp4');
        String actual8 = PathX.guessContentType('.png');
        String actual9 = PathX.guessContentType('.pdf');
        String actual10 = PathX.guessContentType('.jpg');
        String actual11 = PathX.guessContentType('.bin');
        Test.stopTest();
        System.assertEquals('application/vnd.openxmlformats-officedocument.wordprocessingml.document', actual1, 'should be value');
        System.assertEquals('text/xml', actual2, 'should be value');
        System.assertEquals('text/csv', actual3, 'should be value');
        System.assertEquals('audio/wav', actual4, 'should be value');
        System.assertEquals('video/x-ms-wmv', actual5, 'should be value');
        System.assertEquals('audio/mpeg', actual6, 'should be value');
        System.assertEquals('video/mp4', actual7, 'should be value');
        System.assertEquals('image/png', actual8, 'should be value');
        System.assertEquals('application/pdf', actual9, 'should be value');
        System.assertEquals('image/jpeg', actual10, 'should be value');
        System.assertEquals('application/binary', actual11, 'should be value');
    }

    @isTest static void PathX_getDirectoryName() {
        Test.startTest();
        String actual = PathX.getDirectoryName('folder/test.csv');
        Test.stopTest();
        System.assertEquals('folder', actual, 'should be value');
    }
    
    @isTest static void PathX_getExtension() {
        Test.startTest();
        String actual = PathX.getExtension('test.csv');
        Test.stopTest();
        System.assertEquals('.csv', actual, 'should be value');
    }

    @isTest static void PathX_getFileName() {
        Test.startTest();
        String actual = PathX.getFileName('folder/test.csv');
        Test.stopTest();
        System.assertEquals('test.csv', actual, 'should be value');
    }

    @isTest static void PathX_getFileNameWithoutExtension() {
        Test.startTest();
        String actual = PathX.getFileNameWithoutExtension('folder/test.csv');
        Test.stopTest();
        System.assertEquals('test', actual, 'should be value');
    }

    //#endregion

    //#region SetX

    @isTest static void SetX_getIds() {
        Account obj = new Account(Name='Account'); insert obj;
        IdObj obj2 = new IdObj(obj.Id, obj);
        Test.startTest();
        Set<Id> actual1 = SetX.getIds(new IdObj[] { obj2 });
        Set<Id> actual2 = SetX.getIds(new SObject[] { obj });
        Set<Id> actual3 = SetX.getIds(new SObject[] { obj }, 'Id');
        Test.stopTest();
        System.assertEquals(1, actual1.size(), 'Should be value');
        System.assertEquals(1, actual2.size(), 'Should be value');
        System.assertEquals(1, actual3.size(), 'Should be value');
    }

    @isTest static void SetX_getStrings() {
        Account obj = new Account(Name='Account');
        Set<String> actual1 = SetX.getStrings(new SObject[] { obj }, 'Name');
        System.assertEquals(1, actual1.size(), 'Should be value');
    }

    //#endregion

    //#region SObjectX

    @isTest static void SObjectX_GroupAtIterator() {
        Account[] objs = new Account[] { new Account(Name='1'), new Account(Name='2'), new Account(Name='3'), new Account(Name='4') };
        Account[] objs2 = new Account[] { new Account(Name='1'), new Account(Name='2'), new Account(Name='3'), new Account(Name='4'), new Account(Name='5') };
        SObjectX.GroupAtIterator actual = new SObjectX.GroupAtIterator(null, 2);
        SObjectX.GroupAtIterator actual2 = new SObjectX.GroupAtIterator(objs, 2);
        SObjectX.GroupAtIterator actual3 = new SObjectX.GroupAtIterator(objs2, 2);
        Integer actualSize = 0; while (actual.hasNext()) { actual.next(); actualSize++; }
        Integer actual2Size = 0; while (actual2.hasNext()) { actual2.next(); actual2Size++; }
        Integer actual3Size = 0; while (actual3.hasNext()) { actual3.next(); actual3Size++; }
        System.assertEquals(0, actualSize, 'Should be value');
        System.assertEquals(2, actual2Size, 'Should be value');
        System.assertEquals(3, actual3Size, 'Should be value');
    }

    @isTest static void SObjectX_QueryItera() {
        Iterable<SObject> actual1 = new SObjectX.QueryIterable('SELECT Id FROM ApexClass LIMIT 1');
        Iterator<SObject> actual2 = new SObjectX.QueryIterator('SELECT Id FROM ApexClass LIMIT 1');
        System.assert(actual1.Iterator() != null, 'Should be value');
        System.assert(actual2.hasNext() == true, 'Should be value');
        System.assert(actual2.next() != null, 'Should be value');
    }

    @isTest static void SObjectX_GroupAt() {
        Account[] objs = new Account[] { new Account(Name='1'), new Account(Name='2'), new Account(Name='3'), new Account(Name='4') };
        Account[] objs2 = new Account[] { new Account(Name='1'), new Account(Name='2'), new Account(Name='3'), new Account(Name='4'), new Account(Name='5') };
        List<List<SObject>> actual = SObjectX.groupAt(null, 2);
        List<List<SObject>> actual2 = SObjectX.groupAt(objs, 2);
        List<List<SObject>> actual3 = SObjectX.groupAt(objs2, 2);
        System.assertEquals(0, actual.size(), 'Should be value');
        System.assertEquals(2, actual2.size(), 'Should be value');
        System.assertEquals(3, actual3.size(), 'Should be value');
    }

    @isTest static void SObjectX_multiSelectValues() {
        Account s; insert s = new Account(Name='AccountName', Description='Value1', SicDesc='Value1');
        Test.startTest();
        String actual1 = SObjectX.multiSelectValues(s, 'Description', new String[] { 'Value2' });
        String actual2 = SObjectX.multiSelectValues(s.SicDesc, 'Value2');
        Test.stopTest();
        System.assertEquals('Value1;Value2', actual1, 'Should be value');
        System.assertEquals('Value1;Value2', actual2, 'Should be value');
	}

    @isTest static void SObjectX_get() {
        Account parent = new Account(Name='Parent');
        Account obj = new Account(Name='Account', Parent=parent);
        Account s0 = new Account(Name='Account', Parent=parent);
        Test.startTest();
        String actual1a = (String)SObjectX.get(s0, 'Name');
        String actual1b = (String)SObjectX.get(s0, 'Parent.Name');
        String actual2a = (String)SObjectX.get(obj, new List<String> { 'Name' }).get('Name');
        String actual2b = (String)SObjectX.get(obj, new List<String> { 'Parent.Name' }).get('Parent.Name');
        Test.stopTest();
        System.assertEquals('Account', actual1a, 'Should be value');
        System.assertEquals('Parent', actual1b, 'Should be value');
        System.assertEquals('Account', actual2a, 'Should be value');
        System.assertEquals('Parent', actual2b, 'Should be value');
    }

    @isTest static void SObjectX_put() {
        Account parentObj = new Account(Name='Parent');
        Account obj1 = new Account(Name='Account', Parent = parentObj);
        Account obj2 = new Account(Name='Account', Parent = parentObj);
        Test.startTest();
        SObjectX.put(obj1, 'Name', 'Account2');
        SObjectX.put(obj1, 'Parent.Name', 'Parent2');
        SObjectX.put(obj2, new Map<String, Object> { 'Name' => 'Account2' });
        SObjectX.put(obj2, new Map<String, Object> { 'Parent.Name' => 'Parent2' });
        String actual1a = obj1.Name;
        String actual1b = obj1.Parent.Name;
        String actual2a = obj2.Name;
        String actual2b = obj2.Parent.Name;
        Test.stopTest();
        System.assertEquals('Account2', actual1a, 'Should be value');
        System.assertEquals('Parent2', actual1b, 'Should be value');
        System.assertEquals('Account2', actual2a, 'Should be value');
        System.assertEquals('Parent2', actual2b, 'Should be value');
    }
    
    //#endregion

    //#region StringX

    @isTest static void StringX_decodeMap() {
        Map<String, Object> actual = StringX.decodeMap(StringT_String(), false);
        System.assert(actual.get('String') instanceOf String, 'Should be value');
        System.assert(actual.get('Integer') instanceOf Integer, 'Should be value');
        System.assert(actual.get('Boolean') instanceOf Boolean, 'Should be value');
        System.assert(actual.get('Double') instanceOf Double, 'Should be value');
        System.assert(actual.get('Decimal') instanceOf Decimal, 'Should be value');
        System.assert(actual.get('Datetime') instanceOf Datetime, 'Should be value');
        System.assert(actual.get('Date') instanceOf Date, 'Should be value');
        System.assert(actual.get('Object') instanceOf Map<String, Object>, 'Should be value');
        System.assert(actual.get('Object2') instanceOf List<Map<String, Object>>, 'Should be value');
    }

    @isTest static void StringX_encodeMap() {
        String actual = StringX.encodeMap(StringT_Values(), false);
        System.assertEquals(StringT_String(), actual, 'Should be value');
    }

    @isTest static void StringX_clamp() {
        StringX.clamp('123', 3);
        StringX.clamp('123', 3, '..');
    }

    @isTest static void StringX_chunkStringAt() {
        String body = ''.leftPad(6000, '0');
	    System.assert(StringX.chunkStringAt(body, 0, 4000) != null, 'Should be value');
	    System.assert(StringX.chunkStringAt(body, 1, 4000) != null, 'Should be value');
	    System.assert(StringX.chunkStringAt(body, 2, 4000) == null, 'Should be value');
	    System.assert(StringX.chunkStringAt(body, 3, 4000) == null, 'Should be value');
    }

    @isTest static void StringX_encode() {
        System.assertEquals('2b3a418f8e99', EncodingUtil.convertToHex(StringX.encode('+:AÅÄÖ',  'cp437')));
    }

    @isTest static void StringX_decode() {
        System.assertEquals('+:AÅÄÖ', StringX.decode(EncodingUtil.convertFromHex('2b3a418f8e99'), 'cp437'));
    }

    @isTest static void StringX_combine() {
        Blob b1 = Blob.valueOf('s1');
        Blob b2 = Blob.valueOf('s2');
        Blob b3 = Blob.valueOf('s3');
        Test.startTest();
        Blob actual = StringX.combine(new Blob[] { b1, b2, b3 });
        Test.stopTest();
        System.assertEquals('s1s2s3', actual.toString(), 'should be value');
    }

    //#endregion

    //#region SystemX
    
    @isTest static void SystemX_debug() {
        Test.startTest();
        SystemX.debug(null);
        SystemX.debug('String');
        SystemX.debug(123);
        SystemX.debug(LoggingLevel.DEBUG, null);
        SystemX.debug(LoggingLevel.DEBUG, 'String');
        SystemX.debug(LoggingLevel.DEBUG, 123);
        Test.stopTest();
    }
    
    @isTest static void SystemX_debugMulti() {
        Test.startTest();
        SystemX.debugMulti(null);
        SystemX.debugMulti('String');
        SystemX.debugMulti(123);
        Test.stopTest();
    }

    @isTest static void SystemX_fakeId() {
        Test.startTest();
        Id actual = SystemX.fakeId(Account.SObjectType, 0);
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }

    @isTest static void SystemX_isAsyncContext() {
        Test.startTest();
        Boolean actual = SystemX.isAsyncContext();
        Test.stopTest();
    }


    class TestSchedulable implements Schedulable, Database.AllowsCallouts {
        public void execute(SchedulableContext sc) { }
    }

    class TestQueueable implements Queueable {
        public void execute(QueueableContext qc) { }
    }

    @isTest static void SystemX_executeJob() {
        List<Object> batch = new List<Object>();
        for (Integer i = 0; i < 50; i++) { batch.add(new CoreTestBatchable()); }
        Test.startTest();
        SystemX.executeJob(batch, 1);
        SystemX.executeJob(new TestSchedulable(), -2);
        SystemX.executeJob(new TestSchedulable(), 1, null, 'scheduled');
        SystemX.executeJob(new TestSchedulable(), 1);
        SystemX.executeJob(new TestQueueable(), 1);
        SystemX.executeJob(new CoreTestBatchable(), 1);
        Test.stopTest();
    }

    @isTest static void SystemX_enqueueJob() {
        Object q = new TestQueueable();
        List<Object> batch = new List<Object>(), batch2 = new List<Object> { };
        for (Integer i = 0; i < 50; i++) { batch.add(q); batch2.add(q); }
        for (Integer i = 0; i < 10; i++) batch2.add(q);
        Test.startTest();
        SystemX.enqueueJob(batch);
        SystemX.enqueueJob(batch2);
        SystemX.enqueueJob(new Tuple2(new TestQueueable(), 1));
        Test.stopTest();
    }

    //#endregion

    //#region TypeX

    @isTest static void TypeX_forName() {
        Test.startTest();
        Type t = TypeX.forName('TypeX');
        Test.stopTest();
    }
    
    @isTest static void TypeX_decode() {
        Object actual = TypeX.decode('List<SObject>:[{"attributes":{"type":"BatchApexErrorEvent"}}]');
        System.assert(actual instanceOf List<SObject>, 'Should be value');
    }

    @isTest static void TypeX_encode() {
        SObject[] events = new SObject[] { new BatchApexErrorEvent() };
        String actual = TypeX.encode(List<SObject>.class, events);
        System.assertEquals('List<SObject>:[{"attributes":{"type":"BatchApexErrorEvent"}}]', actual, 'Should be value');
    }

    //#endregion

    //#region UserInfoX

    // @isTest static void UserInfo_isMultiCurrencyOrganization() {
    //     Test.startTest();
    //     Boolean actual = UserInfo.isMultiCurrencyOrganization();
    //     Test.stopTest();
    // }

    @isTest static void UserInfoX_isPersonAccountOrganization() {
        Test.startTest();
        Boolean actual = UserInfoX.isPersonAccountOrganization();
        Test.stopTest();
    }

    @isTest static void UserInfoX_isSandboxOrganization() {
        Test.startTest();
        Boolean actual = UserInfoX.isSandboxOrganization();
        Test.stopTest();
    }
    
    @isTest static void UserInfoX_isStateAndCountryPicklistOrganization() {
        Test.startTest();
        Boolean actual = UserInfoX.isStateAndCountryPicklistOrganization();
        Test.stopTest();
    }

    @isTest static void UserInfoX_getServiceUser() {
        Test.startTest();
        User actual = UserInfoX.getServiceUser(null);
        Test.stopTest();
    }

    //#endregion
}