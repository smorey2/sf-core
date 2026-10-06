@isTest
class FilesTest {
/*
    static final Blob csvBody = Blob.valueOf('first,last\nsky,morey\njoe,smith\n');

    static Cloud setupXAws() {
        Blob csvList = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>csv.csv</Key><LastModified>2023-01-04T21:48:48.000Z</LastModified><ETag>&quot;0a0f8e3633a575d213aa23609af696e6&quot;</ETag><Size>4699674</Size><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceMultiMock(new Map<String, HttpCalloutMock> {
            'https://s3.amazonaws.com/bucket/?list-type=2&prefix=csv' => new HttpCalloutServiceMock(200, csvList),
            'https://s3.amazonaws.com/bucket/csv.csv' => new HttpCalloutServiceMock(200, csvBody),
            'https://s3.amazonaws.com/bucket/order?uploads' => new HttpCalloutServiceMock(200, Blob.valueOf('<InitiateMultipartUploadResult><Key>order</Key><UploadId>uploadId</UploadId></InitiateMultipartUploadResult>')),
            'https://s3.amazonaws.com/bucket/order?partNumber=1,uploadId=uploadId' => new HttpCalloutServiceMock(200, null),
            'https://s3.amazonaws.com/bucket/order?uploadId=uploadId' => new HttpCalloutServiceMock(200, null),
            'https://s3.amazonaws.com/bucket/csv%20(0-31).err.csv' => new HttpCalloutServiceMock(200, null)
        }));
        return new CloudAws('bucket', 'awsKey', 'awsSecret');
    }

    @isTest
    static void shouldContentXReadJob() {
        Cloud cloud = setupXAws();
        Test.startTest();
        CustomContentXReadJob job = new CustomContentXReadJob();
        job.setArgs(new Map<String, Object> { 'provider' => provider, 'prefix' => 'csv' });
        job.execute(null);
        Test.stopTest();
    }
    
    class CustomContentXReadJob extends ContentXReadJob {
        // public CustomContentXReadJob() { super(CustomXReadSegment.class); }
    }
    // class CustomXReadSegment extends CsvContentXReadSegment {
    // }

    @isTest
    static void shouldContentXWriteJob() {
        ContentX.IProvider provider = setupXAws();
        Test.startTest();
        CustomContentXWriteJob job = new CustomContentXWriteJob();
        job.scopeLambda(ContentXWriteJobLambda.class).setArgs(new Map<String, Object> { 'provider' => provider, 'path' => 'order' });
        job.execute(null);
        Test.stopTest();
    }
    class ContentXWriteJobLambda implements SystemX.Lambda {
        public Object lambda() { return Database.getQueryLocator('SELECT Id, Name FROM User'); }
    }
    class CustomContentXWriteJob extends ContentXWriteJob {
        // public CustomContentXWriteJob() { super(CustomXWriteSegment.class); }
    }
    // class CustomXWriteSegment extends CsvContentXWriteSegment {
    //     public CustomXWriteSegment() {
    //         csvColumns = new Map<String, CsvColumn> {
    //             'Name' => new CsvColumn(null, 'N')
    //         };
    //     }
    // }





    static ContentX.IProvider setupXAws() {
        SystemX.disableAppFactory = true;
        Blob file = Blob.valueOf(TEST_FILE);
        Blob csvListXml = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>csv.csv</Key><LastModified>2023-01-04T21:48:48.000Z</LastModified><ETag>&quot;0a0f8e3633a575d213aa23609af696e6&quot;</ETag><Size>4699674</Size><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>');
        Test.setMock(HttpCalloutMock.class, new HttpCalloutServiceMultiMock(new Map<String, HttpCalloutMock> {
            'https://s3.amazonaws.com/bucket/?list-type=2&prefix=csv' => new HttpCalloutServiceMock(200, csvListXml),
            'https://s3.amazonaws.com/bucket/archive/csv.csv' => new HttpCalloutServiceMock(200, null),
            'https://s3.amazonaws.com/bucket/csv%20(0-61).log' => new HttpCalloutServiceMock(200, null),
            'https://s3.amazonaws.com/bucket/csv%20(0-61).err.csv' => new HttpCalloutServiceMock(200, null),
            'https://s3.amazonaws.com/bucket/csv.csv' => new HttpCalloutServiceMock(200, file)
        }));
        return new ContentXAws('bucket', 'awsKey', 'awsSecret');
    }

    @isTest static void shouldCreateDefaultContentXOptions() {
        IContentXOptions option = (IContentXOptions)new DefaultContentXOptions();
        System.assert(option.provider(null) != null, 'Should be value');
        System.assert(option.rangeSize(null) != null, 'Should be value');
        System.assert(option.sizeLimit(null) != null, 'Should be value');
        System.assert(option.countLimit(null) != null, 'Should be value');
    }

    @isTest static void shouldExecuteCsvContentXReadSegment() {
        ContentX.IProvider provider = setupXAws();
        List<ContentX.Entry> entries = provider.listContentEntriesByPrefix('csv', true, true);
        List<Range> ranges = new Range[] { new Range(0, 61) };
        Map<String, Object> args = new Map<String, Object>();
        Test.startTest();
        ContentXReadSegment segment = new CsvContentXReadSegment().args(provider, entries[0], ranges, args);
        segment.execute(null, ranges);
        Test.stopTest();
    }

    @isTest static void shouldCreateContentReadSegmentsByTag() {
        ContentX.IProvider provider = setupXAws();
        IContentXOptions options = (IContentXOptions)SystemX.getOptions(DefaultContentXOptions.class);
        Map<String, Object> args = new Map<String, Object>();
        Test.startTest();
        List<Object> segments = ContentX.createContentReadSegmentsByTag(CsvContentXReadSegment.class,
            null, args, provider, 'csv', null,
            null, '\n', options.rangeSize(null), options.sizeLimit(null), options.countLimit(null));
        SystemX.executeBatches(null, segments, 1);
        Test.stopTest();
    }

    // @isTest static void shouldContentXReadJob() {
    //     ContentX.IProvider provider = setupXAws();
    //     Test.startTest();
    //     ContentXReadJob job = new ContentXReadJob();
    //     job.setArgs(new Map<String, Object> { 'provider' => provider, 'prefix' => 'csv' });
    //     job.execute(null);
    //     Test.stopTest();
    // }
    
    //#region TEST_FILE

    @testVisible static final String TEST_FILE =
    'first,second,third\n' +
    '1,2,3\n' +
    '4,5,6\n' +
    '7,8,9\n' +
    'a,b,c\n' +
    'd,e,f\n' +
    'A,B,C\n' +
    'D,E,F\n';

    //#endregion
*/
}