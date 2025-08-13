@isTest
class FormatsTest {
    //#region CsvReader

    @isTest static void CsvReader_parse() {
        Test.startTest();
        String source1 = 'first_name,last_name,email,test\nCodey,"",codey@salesforce.com,"Quote "" Quote"';
        String source2 = 'first_name,last_name,email,test\nCodey,"Bear, The",codey@salesforce.com,"Quote, "" Quote"';
        String source3 = 'first_name,last_name,email,test\nCodey,"Bear, The",codey@salesforce.com,"Quote, "" Quote"\n';
        String source4 = 'first_name,last_name,email,test\nCodey,"Bear, The",codey@salesforce.com,"Quote, "" Quote"\n"';
        String source5 = 'first_name,last_name,email,test\nCodey,"Bear, The",codey@salesforce.com,"Quote, "" Quote"\n"\n';
        List<List<String>> values1 = CsvReader.parse(source1, 0), values1a = CsvReader.parse(source1, 1);
        List<List<String>> values2 = CsvReader.parse(source2, 0);
        List<List<String>> values3 = CsvReader.parse(source3, 0), values3a = CsvReader.parse(source3, 1);
        List<List<String>> values4 = CsvReader.parse(source4, 0);
        List<List<String>> values5 = CsvReader.parse(source5, 0);
        Test.stopTest();
        System.assertEquals(2, values1.size(), 'Should be value'); System.assertEquals(1, values1a.size(), 'Should be value');
        System.assertEquals(2, values2.size(), 'Should be value');
        System.assertEquals(2, values3.size(), 'Should be value'); System.assertEquals(1, values3a.size(), 'Should be value');
        System.assertEquals(2, values4.size(), 'Should be value');
        System.assertEquals(2, values5.size(), 'Should be value');
    }

    //#endregion

    //#region CsvWriter
    
    @isTest static void CsvWriter_write() {
        List<Map<String, Object>> items1 = new List<Map<String, Object>> {
            new Map<String, Object> { 'one' => 'value1', 'two' => 'value2' }
        };
        List<SObject> items2 = new List<SObject> {
            new Account(Name='Name', Description='Desc')
        };
        Map<String, DataColumn> columns1 = new Map<String, DataColumn> {
            'one' => null,
            'two' => null
        };
        Map<String, DataColumn> columns2 = new Map<String, DataColumn> {
            'Name' => null,
            'Description' => new DataColumn(null, 'Desc')
        };
        Test.startTest();
        CsvWriter w;
        String actual1a = CsvWriter.write(columns1, true, items1);
        w = new CsvWriter(columns1); w.COMMA = '|'; String actual1b = w.write(true, items1);
        String actual2a = CsvWriter.write(columns2, true, items2);
        w = new CsvWriter(columns2); w.COMMA = '|'; String actual2b = w.write(true, items2);
        Test.stopTest();
        System.assertEquals('one,two\nvalue1,value2\n', actual1a, 'Should be value1a');
        System.assertEquals('one|two\nvalue1|value2\n', actual1b, 'Should be value1b');
        System.assertEquals('Name,Desc\nName,Desc\n', actual2a, 'Should be value2a');
        System.assertEquals('Name|Desc\nName|Desc\n', actual2b, 'Should be value2b');
    }

    //#endregion
}