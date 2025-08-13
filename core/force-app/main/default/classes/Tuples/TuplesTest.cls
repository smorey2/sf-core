@isTest
class TuplesTest {
    @isTest static void Tuples_new() {
        ExObj actual = new ExObj(new HandledException('exception'), new Account());
        IdStr actual2 = new IdStr(UserInfo.getUserId(), 'string');
        IdObj actual3 = new IdObj(UserInfo.getUserId(), 'string');
        Range actual4 = new Range(0, 1);
        Tuple2 actual5 = new Tuple2(UserInfo.getUserId(), 'string');
        Tuple3 actual6 = new Tuple3(UserInfo.getUserId(), null, 'string');
        Tuple4 actual7 = new Tuple4(UserInfo.getUserId(), null, 'string', null);
    }
}