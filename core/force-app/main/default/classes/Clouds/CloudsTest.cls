@isTest
class CloudsTest {
    static final Blob csvBody = Blob.valueOf('first,last\nsky,morey\njoe,smith\n');
    static final Blob orderBody = Blob.valueOf('<orders><order id="1">Body1</order><order id="2">Body2</order><order id="3">Body3</order></orders>');
    static final Blob throwBody = Blob.valueOf('throw');

    //#region Setup

    static Cloud Aws_setup() {
        Blob csvList = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>csv.csv</Key><LastModified>2023-01-04T21:48:48.000Z</LastModified><ETag>&quot;0a0f8e3633a575d213aa23609af696e6&quot;</ETag><Size>4699674</Size><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>');
        Blob orderList = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>order_20230104_01.xml</Key><LastModified>2023-01-04T21:48:48.000Z</LastModified><ETag>&quot;0a0f8e3633a575d213aa23609af696e6&quot;</ETag><Size>4699674</Size><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>');
        Blob throwList = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>throw.xml</Key><Size>5</Size><LastModified>2023-01-04T21:48:42.000Z</LastModified></Contents></ListBucketResult>');
        Test.setMock(HttpCalloutMock.class, new HttpMultiMock(new Map<String, HttpCalloutMock> {
            'https://s3.amazonaws.com/bucket/?list-type=2&prefix=csv' => new HttpMock(200, csvList),
            'https://s3.amazonaws.com/bucket/?list-type=2&prefix=order' => new HttpMock(200, orderList),
            'https://s3.amazonaws.com/bucket/?list-type=2&prefix=throw' => new HttpMock(200, throwList),
            'https://s3.amazonaws.com/bucket/create' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/create2' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/newCreate' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/throw.xml' => new HttpMock(200, throwBody),
            'https://s3.amazonaws.com/bucket/err-throw%20(0-5).xml' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/throw%20(0-5).log' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/throw%20(0-5).err.xml' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/archive/csv.csv' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/working/csv.csv' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/csv.csv' => new HttpMock(200, csvBody),
            'https://s3.amazonaws.com/bucket/csv%20(0-11).err.csv' => new HttpMock(200, csvBody),
            'https://s3.amazonaws.com/bucket/order?uploads' => new HttpMock(200, Blob.valueOf('<InitiateMultipartUploadResult><Key>order</Key><UploadId>uploadId</UploadId></InitiateMultipartUploadResult>')),
            'https://s3.amazonaws.com/bucket/order?partNumber=1&uploadId=uploadId' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/order?uploadId=uploadId' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/archive/order_20230104_01.xml' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/working/order_20230104_01.xml' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/order_20230104_01%20(8-35).log' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/order_20230104_01%20(8-35).err.xml' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/order_20230104_01%20(35-62).log' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/order_20230104_01%20(62-89).log' => new HttpMock(200, null),
            'https://s3.amazonaws.com/bucket/order_20230104_01.xml' => new HttpMock(200, orderBody)
        }));
        new CloudAws(new NamedCredential__mdt(MasterLabel='Aws', Bucket__c='bucket', ClientId__c='awsKey', ClientSecret__c='awsSecret'));
        return new CloudAws('bucket', 'awsKey', 'awsSecret');
    }

    static Cloud Azure_setup() {
        Blob orderList = Blob.valueOf('<EnumerationResults ServiceEndpoint="https://darwinlstore.blob.core.windows.net/" ContainerName="testing"><Prefix>order</Prefix><Blobs><Blob><Name>order.xml</Name><Properties><Creation-Time>Wed, 01 Mar 2023 18:49:57 GMT</Creation-Time><Last-Modified>Wed, 01 Mar 2023 18:49:57 GMT</Last-Modified><Etag>0x8DB1A85C0D5FBF5</Etag><Content-Length>76</Content-Length><Content-Type>text/plain</Content-Type><Content-Encoding /><Content-Language /><Content-CRC64 /><Content-MD5 /><Cache-Control /><Content-Disposition /><BlobType>AppendBlob</BlobType><LeaseStatus>unlocked</LeaseStatus><LeaseState>available</LeaseState><ServerEncrypted>true</ServerEncrypted></Properties><OrMetadata /></Blob></Blobs><NextMarker /></EnumerationResults>');
        Blob throwList = Blob.valueOf('<EnumerationResults ServiceEndpoint="https://darwinlstore.blob.core.windows.net/" ContainerName="testing"><Prefix>throw</Prefix><Blobs><Blob><Name>throw.xml</Name><Properties><Creation-Time>Wed, 01 Mar 2023 18:49:57 GMT</Creation-Time><Last-Modified>Wed, 01 Mar 2023 18:49:57 GMT</Last-Modified><Etag>0x8DB1A85C0D5FBF5</Etag><Content-Length>76</Content-Length><Content-Type>text/plain</Content-Type><Content-Encoding /><Content-Language /><Content-CRC64 /><Content-MD5 /><Cache-Control /><Content-Disposition /><BlobType>AppendBlob</BlobType><LeaseStatus>unlocked</LeaseStatus><LeaseState>available</LeaseState><ServerEncrypted>true</ServerEncrypted></Properties><OrMetadata /></Blob></Blobs><NextMarker /></EnumerationResults>');
        Test.setMock(HttpCalloutMock.class, new HttpMultiMock(new Map<String, HttpCalloutMock> {
            'https://accountName.blob.core.windows.net/bucket/?restype=container&comp=list&prefix=order' => new HttpMock(200, orderList),
            'https://accountName.blob.core.windows.net/bucket/?restype=container&comp=list&prefix=throw' => new HttpMock(200, throwList),
            'https://accountName.blob.core.windows.net/bucket/create' => new HttpMock(200, null),
            'https://accountName.blob.core.windows.net/bucket/create2' => new HttpMock(200, null),
            'https://accountName.blob.core.windows.net/bucket/newCreate' => new HttpMock(200, null),
            'https://accountName.blob.core.windows.net/bucket/order?comp=block&blockid=BlGHTgE%3D' => new HttpMock(200, null),
            'https://accountName.blob.core.windows.net/bucket/order?comp=blocklist' => new HttpMock(200, null),
            'https://accountName.blob.core.windows.net/bucket/order.xml' => new HttpMock(200, orderBody)
        }));
        new CloudAzure(new NamedCredential__mdt(MasterLabel='Azure', Bucket__c='bucket', ClientId__c='accountName', ClientSecret__c='accessKey'));
        return new CloudAzure('bucket', 'accountName', 'accountKey');
    }

    static Cloud[] Oauth_setup() {
        new CloudOauth(new NamedCredential__mdt(MasterLabel='Oauth', Endpoint__c='https://endpoint', Bucket__c='json:bucket', ClientId__c='clientId', ClientSecret__c='clientSecret', Tag__c='scope'));
        return new Cloud[] {
            new CloudOauth('https://endpoint', 'json:bucket', 'clientId', 'clientSecret', 'scope'),
            new CloudOauth('https://endpoint', 'json2:bucket', 'clientId', 'clientSecret', 'scope'),
            new CloudOauth('https://endpoint', 'form:bucket', 'clientId', 'clientSecret', 'scope') };
    }

    static Cloud Sfcc_setup() {
        new CloudSfcc(new NamedCredential__mdt(MasterLabel='Sfcc', ClientId__c='clientId', ClientSecret__c='certificateName', Tag__c=null));
        return new CloudSfcc('clientId', 'certificateName', null);
    }

    static Cloud Sfmc_setup() {
        new CloudSfmc(new NamedCredential__mdt(MasterLabel='Sfmc', Bucket__c='stack:account', ClientId__c='clientId', ClientSecret__c='clientSecret', Tag__c='scope'));
        return new CloudSfmc('stack:account', 'clientId', 'clientSecret', 'scope');
    }

    static Cloud Gcp_setup() {
        Blob orderList = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>order_20230104_01.xml</Key><LastModified>2023-01-04T21:48:48.000Z</LastModified><ETag>&quot;0a0f8e3633a575d213aa23609af696e6&quot;</ETag><Size>4699674</Size><StorageClass>STANDARD</StorageClass></Contents></ListBucketResult>');
        Blob throwList = Blob.valueOf('<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Contents><Key>throw.xml</Key><Size>5</Size><LastModified>2023-01-04T21:48:42.000Z</LastModified></Contents></ListBucketResult>');
        Test.setMock(HttpCalloutMock.class, new HttpMultiMock(new Map<String, HttpCalloutMock> {
            'https://storage.googleapis.com/bucket/?list-type=2&prefix=order' => new HttpMock(200, orderList),
            'https://storage.googleapis.com/bucket/?list-type=2&prefix=throw' => new HttpMock(200, throwList),
            'https://storage.googleapis.com/bucket/create' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/create2' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/newCreate' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/throw.xml' => new HttpMock(200, throwBody),
            'https://storage.googleapis.com/bucket/err-throw%20(0-5).xml' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/throw%20(0-5).log' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/throw%20(0-5).err.xml' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order?uploads' => new HttpMock(200, Blob.valueOf('<InitiateMultipartUploadResult><Key>order</Key><UploadId>uploadId</UploadId></InitiateMultipartUploadResult>')),
            'https://storage.googleapis.com/bucket/order?partNumber=1&uploadId=uploadId' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order?uploadId=uploadId' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/archive/order_20230104_01.xml' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/working/order_20230104_01.xml' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order_20230104_01%20(8-35).log' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order_20230104_01%20(8-35).err.xml' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order_20230104_01%20(35-62).log' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order_20230104_01%20(62-89).log' => new HttpMock(200, null),
            'https://storage.googleapis.com/bucket/order_20230104_01.xml' => new HttpMock(200, orderBody)
        }));
        new CloudGcp(new NamedCredential__mdt(MasterLabel='Gcp', Bucket__c='bucket', ClientId__c='accessKey', ClientSecret__c='secret'));
        return new CloudGcp('bucket', 'googleKey', 'googleSecret');
    }

    static Cloud Sfp_setup() {
        insert new ContentVersion[] {
            new ContentVersion(PathOnClient = 'csv.csv', VersionData = csvBody),
            new ContentVersion(PathOnClient = 'order.xml', VersionData = orderBody),
            new ContentVersion(PathOnClient = 'throw.xml', VersionData = throwBody)
        };
        return new CloudSfp();
    }

    //#endregion

    //#region CloudAws

    @isTest static void CloudAws_all() {
        Cloud cloud = Aws_setup();
        Test.startTest();
        HttpRequest signReq = new HttpRequest();
        signReq.setMethod('GET');
        signReq.setEndpoint('https://s3.amazonaws.com/bucket/key');
        CloudAws.signRequest(signReq, null, 'bucket', 'path', 'awsKey', 'awsSecret');
        String actualA = cloud.acceptRanges();
        String[] actualI = cloud.limitOn();
        Cloud.File actualC = cloud.create('create', 'test');
        cloud.copy('create', 'newCreate');
        List<Cloud.File> actualL = cloud.listx('order', 'file;size');
        Blob actualB1 = cloud.get(actualL[0].key, null);
        Blob actualB2 = cloud.get(actualL[0].key, new Range(0, 25));
        cloud.move('newCreate', 'create2');
        cloud.move(actualC, 'create2');
        cloud.deletex('create');
        cloud.put(actualC.key, null, 'Change');
        Integer actualF = cloud.flushOn();
        cloud.abortMultipart(cloud.createMultipart('order'), new List<Object>());
        Cloud.File actualM = cloud.createMultipart('order');
        List<Object> parts = new List<Object> { cloud.uploadPart(actualM, 1, 'content') };
        Cloud.File actualMZ = cloud.completeMultipart(actualM, parts);
        Test.stopTest();
        System.assert(signReq.getHeader('Authorization') != null, 'Should be value');
        System.assertEquals('bytes', actualA, 'should have value');
        System.assertNotEquals(null, actualI, 'should have value');
        System.assertNotEquals(null, actualC, 'should have value');
        System.assertEquals(1, actualL.size(), 'should have value');
        System.assertNotEquals(null, actualB1, 'should have value');
        System.assertNotEquals(null, actualB2, 'should have value');
        System.assertEquals(5242880, actualF, 'should have value');
        System.assertNotEquals(null, actualM, 'should have value');
        System.assertNotEquals(null, actualMZ, 'should have value');
    }

    //#endregion

    //#region CloudAzure

    @isTest static void CloudAzure_all() {
        Cloud cloud = Azure_setup();
        Test.startTest();
        HttpRequest signReq = new HttpRequest();
        signReq.setMethod('GET');
        signReq.setEndpoint('https://accountName.blob.core.windows.net/');
        CloudAzure.signRequest(signReq, null, 'bucket', 'path', 'accountName', 'accessKey');
        String actualA = cloud.acceptRanges();
        String[] actualI = cloud.limitOn();
        Cloud.File actualC = cloud.create('create', 'test');
        cloud.copy('create', 'newCreate');
        List<Cloud.File> actualL = cloud.listx('order', 'file;size');
        Blob actualB1 = cloud.get(actualL[0].key, null);
        Blob actualB2 = cloud.get(actualL[0].key, new Range(0, 25));
        cloud.move('newCreate', 'create2');
        cloud.move(actualC, 'create2');
        cloud.deletex('create');
        cloud.put(actualC.key, null, 'Change');
        Integer actualF = cloud.flushOn();
        cloud.abortMultipart(cloud.createMultipart('order'), new List<Object>());
        Cloud.File actualM = cloud.createMultipart('order');
        List<Object> parts = new List<Object> { cloud.uploadPart(actualM, 1, 'content') };
        Cloud.File actualMZ = cloud.completeMultipart(actualM, parts);
        Test.stopTest();
        System.assert(signReq.getHeader('Authorization') != null, 'Should be value');
        System.assertEquals('bytes', actualA, 'should have value');
        System.assertNotEquals(null, actualI, 'should have value');
        System.assertNotEquals(null, actualC, 'should have value');
        System.assertEquals(1, actualL.size(), 'should have value');
        System.assertNotEquals(null, actualB1, 'should have value');
        System.assertNotEquals(null, actualB2, 'should have value');
        System.assertEquals(0, actualF, 'should have value');
        System.assertNotEquals(null, actualM, 'should have value');
        System.assertNotEquals(null, actualMZ, 'should have value');
    }

    //#endregion

    //#region CloudGcp

    @isTest static void CloudGcp_all() {
        Cloud cloud = Gcp_setup();
        Test.startTest();
        HttpRequest signReq = new HttpRequest();
        signReq.setMethod('GET');
        signReq.setEndpoint('https://s3.amazonaws.com/bucket/key');
        CloudAws.signRequest(signReq, null, 'bucket', 'path', 'awsKey', 'awsSecret');
        String actualA = cloud.acceptRanges();
        String[] actualI = cloud.limitOn();
        Cloud.File actualC = cloud.create('create', 'test');
        cloud.copy('create', 'newCreate');
        List<Cloud.File> actualL = cloud.listx('order', 'file;size');
        Blob actualB1 = cloud.get(actualL[0].key, null);
        Blob actualB2 = cloud.get(actualL[0].key, new Range(0, 25));
        cloud.move('newCreate', 'create2');
        cloud.move(actualC, 'create2');
        cloud.deletex('create');
        cloud.put(actualC.key, null, 'Change');
        Integer actualF = cloud.flushOn();
        cloud.abortMultipart(cloud.createMultipart('order'), new List<Object>());
        Cloud.File actualM = cloud.createMultipart('order');
        List<Object> parts = new List<Object> { cloud.uploadPart(actualM, 1, 'content') };
        Cloud.File actualMZ = cloud.completeMultipart(actualM, parts);
        Test.stopTest();
        System.assert(signReq.getHeader('Authorization') != null, 'Should be value');
        System.assertEquals('bytes', actualA, 'should have value');
        System.assertNotEquals(null, actualI, 'should have value');
        System.assertNotEquals(null, actualC, 'should have value');
        System.assertEquals(1, actualL.size(), 'should have value');
        System.assertNotEquals(null, actualB1, 'should have value');
        System.assertNotEquals(null, actualB2, 'should have value');
        System.assertEquals(5242880, actualF, 'should have value');
        System.assertNotEquals(null, actualM, 'should have value');
        System.assertNotEquals(null, actualMZ, 'should have value');
    }

    //#endregion

    //#region CloudOauth

    @isTest static void CloudOauth_all() {
        Cloud[] cloud = Oauth_setup();
        Test.startTest();
        Map<String, Object> actual1 = cloud[0].accessToken();
        Map<String, Object> actual2 = cloud[1].accessToken();
        Map<String, Object> actual3 = cloud[2].accessToken();
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
        System.assert(actual3 != null, 'Should be value');
    }

    //#endregion

    //#region CloudSfcc

    @isTest static void CloudSfcc_all() {
        Cloud cloud = Sfcc_setup();
        Test.startTest();
        Map<String, Object> actual1 = cloud.accessToken();
        String actual2 = cloud.endpoint('data', 'endpoint');
        String actual3 = cloud.endpoint('shop', 'endpoint');
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
        System.assert(actual3 != null, 'Should be value');
    }

    //#endregion

    //#region CloudSfmc

    @isTest static void CloudSfmc_all() {
        Cloud cloud = Sfmc_setup();
        Test.startTest();
        Map<String, Object> actual1 = cloud.accessToken();
        Map<String, Object> actual2 = cloud.accessToken('0');
        String actual3 = cloud.endpoint('trigger', 'endpoint');
        Test.stopTest();
        System.assert(actual1 != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
        System.assert(actual3 != null, 'Should be value');
    }

    public class TestSfmcTrigger extends CloudSfmcTrigger implements SystemX.Args {
        public String value;
        
        public void setArgs(Map<String, Object> args) {
            for (String key : args.keySet()) switch on key {
                when 'value' { value = (String)args.get(key); }
            }
        }

        public override void execute(Context ctx) {
            ctx.endpoint = 'endpoint';
            ctx.address = 'address';
            ctx.subscriberKey = 'subscriberKey';
            ctx.contactAttributes = new Map<String, Object> {
                'key1' => value,
                'key2' => value
            };
            post(ctx);
        }
    }

    @isTest public static void CloudSfmc_trigger() {
        Test.setMock(HttpCalloutMock.class, new HttpMultiMock(new Map<String, HttpCalloutMock> {
            'https://x.rest.marketingcloudapis.com/messaging/v1/messageDefinitionSends/key:endpoint/send' => new HttpMock(200, '{}')
        }));
        Test.startTest();
        // TestSfmcTrigger actual1 = new TestSfmcTrigger(null, new Map<String, Object> {
        //     'value' => 'value'
        // });
        // actual1.execute(null);
        Test.stopTest();
        // System.assert(actual1 != null, 'Should be value');
    }

    //#endregion

    //#region CloudSfp

    @isTest static void CloudSfp_all() {
        new CloudSfp();
        Cloud cloud = Sfp_setup();
        Test.startTest();
        String actualA = cloud.acceptRanges();
        String[] actualI = cloud.limitOn();
        Cloud.File actualC = cloud.create('create', 'test');
        cloud.copy('create', 'newCreate');
        List<Cloud.File> actualL = cloud.listx('order', 'file;size');
        Blob actualB1 = cloud.get(actualL[0].key, null);
        Blob actualB2 = cloud.get(actualL[0].key, new Range(0, 25));
        cloud.move('newCreate', 'create2');
        cloud.move(actualC, 'create2');
        cloud.put(actualC.key, null, 'Change');
        cloud.deletex('create');
        Test.stopTest();
        System.assertEquals(null, actualA, 'should have value');
        System.assertEquals(null, actualI, 'should have value');
        System.assertNotEquals(null, actualC, 'should have value');
        System.assertEquals(1, actualL.size(), 'should have value');
        System.assertNotEquals(null, actualB1, 'should have value');
        System.assertNotEquals(null, actualB2, 'should have value');
    }

    //#endregion

    
    // @isTest static void shouldCreateContentXReadFinish() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     ContentXReadFinish actual1 = new ContentXReadFinish();
    //     actual1.args(cloud, entry, null);
    //     actual1.execute(null);
    //     ContentXReadFinish actual2 = new ContentXReadFinish();
    //     actual2.args(cloud, entry, new Map<String, Object> { 'archive' => 'archive' });
    //     actual2.execute(null);
    //     Test.stopTest();
    //     System.assert(actual1 != null, 'should have value');
    //     System.assert(actual2 != null, 'should have value');
    // }

    // @isTest static void shouldCreateContentXReadSegment() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entriesOrder = cloud.listx('order', 'file;size');
    //     List<Cloud.File> entriesCsv = cloud.listx('csv', 'file;size');
    //     Test.startTest();
    //     ContentXReadSegment actualOrder = new ContentXReadSegment();
    //     ContentXReadSegment actualCsv = new ContentXReadSegment();
    //     actualOrder.args(cloud, entriesOrder[0], new Range[] { new Range(0, 98) }, null);
    //     actualCsv.args(cloud, entriesCsv[0], new Range[] { new Range(0, 10) }, null);
    //     Test.stopTest();
    //     System.assert(actualOrder != null, 'should have value');
    //     System.assert(actualCsv != null, 'should have value');
    // }

    // @isTest static void shouldCreateContentXReadSegment_Queue() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entriesOrder = cloud.listx('order', 'file;size');
    //     List<Cloud.File> entriesCsv = cloud.listx('csv', 'file;size');
    //     Test.startTest();
    //     ContentXReadSegment.Queue actualOrder = new ContentXReadSegment.Queue();
    //     ContentXReadSegment.Queue actualCsv = new ContentXReadSegment.Queue();
    //     actualOrder.args(cloud, entriesOrder[0], new Range(0, 98), null);
    //     actualCsv.args(cloud, entriesCsv[0], new Range(0, 10), null);
    //     SystemX.finish(actualOrder, null, null, null, null);
    //     SystemX.finish(actualCsv, null, null, null, null);
    //     Test.stopTest();
    //     System.assert(actualOrder != null, 'should have value');
    //     System.assert(actualCsv != null, 'should have value');
    // }


    // @isTest static void shouldCreateContentReadSegments() {
    //     Cloud cloud = setupXAws();
    //     Test.startTest();
    //     List<Object> actualOrder = createContentReadSegmentsByTag(ContentXReadSegment.class, ContentXReadFinish.class, null, cloud, 'order', null, '<order id="', '</order>', 1000, 0, 1);
    //     List<Object> actualCsv = createContentReadSegmentsByTag(ContentXReadSegment.class, ContentXReadFinish.class, null, cloud, 'csv', null, null, '\n', 1000, 0, 1);
    //     SystemX.executeBatches(null, actualOrder, 1);
    //     SystemX.executeBatches(null, actualCsv, 1);
    //     Test.stopTest();
    //     System.assertEquals(1, actualOrder.size(), 'should be value');
    //     System.assertEquals(1, actualCsv.size(), 'should be value');
    // }

    // class CreateContentWriteSegmentsLambda implements SystemX.Lambda {
    //     public Object lambda() { return Database.getQueryLocator('SELECT Id, Name FROM User LIMIT 1'); }
    // }

    // class CreateContentWriteSegmentsSoqlLambda implements SystemX.Lambda {
    //     public Object lambda() { return [SELECT Id, Name FROM User LIMIT 1]; }
    // }

    // @isTest static void shouldCreateContentWriteSegments() {
    //     IProvider2 cloud = setupXAws();
    //     Test.startTest();
    //     List<Object> actual = createContentWriteSegments(ContentXWriteSegment.class, CreateContentWriteSegmentsLambda.class, null, cloud, 'order', null, '<order id="', '</order>');
    //     List<Object> actualSoql = createContentWriteSegments(ContentXWriteSegment.class, CreateContentWriteSegmentsSoqlLambda.class, null, cloud, 'order', null, '<order id="', '</order>');
    //     List<Object> actualQueue = createContentWriteSegments(ContentXWriteSegment.Queue.class, CreateContentWriteSegmentsSoqlLambda.class, null, cloud, 'order', null, '<order id="', '</order>');
    //     SystemX.executeBatches(null, actual, 1);
    //     SystemX.executeBatches(null, actualSoql, 1);
    //     SystemX.enqueueJobs(null, actualQueue);
    //     Test.stopTest();
    //     System.assertEquals(1, actual.size(), 'should be value');
    //     System.assertEquals(1, actualSoql.size(), 'should be value');
    //     System.assertEquals(1, actualQueue.size(), 'should be value');
    // }

    // @isTest static void shouldCreateContentReadSegments_Aws() {
    //     Cloud cloud = setupXAws();
    //     Test.startTest();
    //     List<Object> actualOrder = createContentReadSegmentsByTag(ContentXReadSegment.class, ContentXReadFinish.class, new Map<String, Object> { 'archive' => 'archive' }, cloud, 'order', 'working', '<order id="', '</order>', 1000, 0, 1);
    //     List<Object> actualThrow = createContentReadSegmentsByTag(ContentXReadSegment.class, null, null, cloud, 'throw', null, 'throw', null, 1000, 0, 1);
    //     List<Object> actualOrderQueue = createContentReadSegmentsByTag(ContentXReadSegment.Queue.class, ContentXReadFinish.Queue.class, new Map<String, Object> { 'archive' => 'archive' }, cloud, 'order', 'working', '<order id="', '</order>', 1000, 0, 1);
    //     List<Object> actualThrowQueue = createContentReadSegmentsByTag(ContentXReadSegment.Queue.class, null, null, cloud, 'throw', null, 'throw', null, 1000, 0, 1);
    //     SystemX.executeBatches(null, actualOrder, 1);
    //     SystemX.executeBatches(null, actualThrow, 1);
    //     SystemX.enqueueJobs(null, actualOrderQueue);
    //     SystemX.enqueueJobs(null, actualThrowQueue);
    //     Test.stopTest();
    //     System.assertEquals(1, actualOrder.size(), 'should be value');
    //     System.assertEquals(1, actualThrow.size(), 'should be value');
    //     System.assertEquals(4, actualOrderQueue.size(), 'should be value');
    //     System.assertEquals(1, actualThrowQueue.size(), 'should be value');
    // }

    // @isTest static void shouldCreateContentReadSegments_Sfdc() {
    //     Cloud cloud = setupXSfdc();
    //     Test.startTest();
    //     List<Object> actualOrder = createContentReadSegmentsByTag(ContentXReadSegment.class, ContentXReadFinish.class, new Map<String, Object> { 'archive' => 'archive' }, cloud, 'order', 'working', '<order id="', '</order>', 25, 0, 1);
    //     List<Object> actualThrow = createContentReadSegmentsByTag(ContentXReadSegment.class, ContentXReadFinish.class, null, cloud, 'throw', null, 'throw', null, 25, 0, 1);
    //     List<Object> actualOrderQueue = createContentReadSegmentsByTag(ContentXReadSegment.Queue.class, ContentXReadFinish.Queue.class, new Map<String, Object> { 'archive' => 'archive' }, cloud, 'order', 'working', '<order id="', '</order>', 25, 0, 1);
    //     List<Object> actualThrowQueue = createContentReadSegmentsByTag(ContentXReadSegment.Queue.class, ContentXReadFinish.Queue.class, null, cloud, 'throw', null, 'throw', null, 25, 0, 1);
    //     SystemX.executeBatches(null, actualOrder, 1);
    //     SystemX.executeBatches(null, actualThrow, 1);
    //     SystemX.enqueueJobs(null, actualOrderQueue);
    //     SystemX.enqueueJobs(null, actualThrowQueue);
    //     Test.stopTest();
    //     System.assertEquals(1, actualOrder.size(), 'should be value');
    //     System.assertEquals(1, actualThrow.size(), 'should be value');
    //     System.assertEquals(4, actualOrderQueue.size(), 'should be value');
    //     System.assertEquals(2, actualThrowQueue.size(), 'should be value');
    // }

    // @isTest static void shouldFindContentBlobSegmentsByTag() {
    //     Cloud cloud = setupXAws();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     List<Range> actual1 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 10); //: no ranges
    //     List<Range> actual2 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 1); //: no ranges
    //     String content2a = decodeBlob(cloud.get(entry.key, actual2[0]));
    //     String content2b = decodeBlob(cloud.get(entry.key, actual2[1]));
    //     List<Range> actual3 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', 1000, 0, 1); //: full result in first page
    //     List<Range> actual4 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', 25, 0, 1); //: multiple pages
    //     List<Range> actual5 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', orderBody.size(), 0, 1); //: full page + extra page
    //     Test.stopTest();
    //     System.assertEquals(1, actual1.size(), 'should be value');
    //     System.assertEquals(3, actual2.size(), 'should be value');
    //     System.assert(content2a.startsWith('<order ') && content2a.endsWith('</order>'), 'should be value');
    //     System.assert(content2b.startsWith('<order ') && content2b.endsWith('</order>'), 'should be value');
    //     System.assertEquals(3, actual3.size(), 'should be value');
    //     System.assertEquals(3, actual4.size(), 'should be value');
    //     System.assertEquals(3, actual5.size(), 'should be value');
    // }

    // @isTest static void shouldFindContentBlobSegmentsByTag_Aws() {
    //     Cloud cloud = setupXAws();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     List<Range> actual1 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 10); //: no ranges
    //     List<Range> actual2 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 1); //: no ranges
    //     List<Range> actual3 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', 1000, 0, 1); //: full result in first page
    //     List<Range> actual4 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', 25, 0, 1); //: multiple pages
    //     List<Range> actual5 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', orderBody.size(), 0, 1); //: full page + extra page
    //     Test.stopTest();
    //     System.assertEquals(1, actual1.size(), 'should be value');
    //     System.assertEquals(3, actual2.size(), 'should be value');
    //     System.assertEquals(3, actual3.size(), 'should be value');
    //     System.assertEquals(3, actual4.size(), 'should be value');
    //     System.assertEquals(3, actual5.size(), 'should be value');
    // }

    // @isTest static void shouldFindContentStringSegmentsByTag_Aws() {
    //     Cloud cloud = setupXAws();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     // List<Range> actual1 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 10); //: no ranges
    //     // List<Range> actual2 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 1); //: no ranges
    //     // List<Range> actual3 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', 1000, 0, 1); //: full result in first page
    //     List<Range> actual4 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', 25, 0, 1); //: multiple pages
    //     // List<Range> actual5 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', orderBody.size(), 0, 1); //: full page + extra page
    //     Test.stopTest();
    //     // System.assertEquals(1, actual1.size(), 'should be value1');
    //     // System.assertEquals(3, actual2.size(), 'should be value2');
    //     // System.assertEquals(3, actual3.size(), 'should be value3');
    //     System.assertEquals(3, actual4.size(), 'should be value4');
    //     // System.assertEquals(3, actual5.size(), 'should be value5');
    // }

    // @isTest static void shouldFindContentBlobSegmentsByTag_Sfdc() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     List<Range> actual1 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 10); //: no ranges (10 group)
    //     List<Range> actual2 = findContentBlobSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 1); //: no ranges
    //     Test.stopTest();
    //     System.assertEquals(1, actual1.size(), 'should be value');
    //     System.assertEquals(3, actual2.size(), 'should be value');
    // }

    // @isTest static void shouldFindContentStringSegmentsByTag_Sfdc() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     List<Range> actual1 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 10); //: no ranges (10 group)
    //     List<Range> actual2 = findContentStringSegmentsByTag(cloud, entry.key, '<order id="', '</order>', null, 0, 1); //: no ranges
    //     Test.stopTest();
    //     System.assertEquals(1, actual1.size(), 'should be value');
    //     System.assertEquals(3, actual2.size(), 'should be value');
    // }

    // @isTest static void shouldCountContentBlobTags_Aws() {
    //     Cloud cloud = setupXAws();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     Integer actual1 = countContentBlobTags(cloud, entry.key, '<order id="', null); //: no ranges
    //     Integer actual2 = countContentBlobTags(cloud, entry.key, '<order id="', 1000); //: full result in first page
    //     Integer actual3 = countContentBlobTags(cloud, entry.key, '<order id="', 25); //: multiple pages
    //     Integer actual4 = countContentBlobTags(cloud, entry.key, '<order id="', orderBody.size()); //: full page + extra page
    //     Test.stopTest();
    //     System.assertEquals(3, actual1, 'should be value');
    //     System.assertEquals(3, actual2, 'should be value');
    //     System.assertEquals(3, actual3, 'should be value');
    //     System.assertEquals(3, actual4, 'should be value');
    // }

    // @isTest static void shouldCountContentStringTags_Aws() {
    //     Cloud cloud = setupXAws();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     Integer actual1 = countContentStringTags(cloud, entry.key, '<order id="', null); //: no ranges
    //     Integer actual2 = countContentStringTags(cloud, entry.key, '<order id="', 1000); //: full result in first page
    //     Integer actual3 = countContentStringTags(cloud, entry.key, '<order id="', 25); //: multiple pages
    //     Integer actual4 = countContentStringTags(cloud, entry.key, '<order id="', orderBody.size()); //: full page + extra page
    //     Test.stopTest();
    //     System.assertEquals(3, actual1, 'should be value');
    //     System.assertEquals(3, actual2, 'should be value');
    //     System.assertEquals(3, actual3, 'should be value');
    //     System.assertEquals(3, actual4, 'should be value');
    // }

    // @isTest static void shouldCountContentBlobTags_Sfdc() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     Integer actual1 = countContentBlobTags(cloud, entry.key, '<order id="', null);
    //     Test.stopTest();
    //     System.assertEquals(3, actual1, 'should be value');
    // }

    // @isTest static void shouldCountContentStringTags_Sfdc() {
    //     Cloud cloud = setupXSfdc();
    //     List<Cloud.File> entries = cloud.listx('order', 'file;size');
    //     Cloud.File entry = entries[0];
    //     Test.startTest();
    //     Integer actual1 = countContentStringTags(cloud, entry.key, '<order id="', null);
    //     Test.stopTest();
    //     System.assertEquals(3, actual1, 'should be value');
    // }
}