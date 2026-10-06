/**
* a content write job 
*/
global virtual class FileWriteJob implements Schedulable, SystemX.Args, Database.AllowsCallouts {
    Type writerType;
    String openTag;
    String closeTag;
    Type scopeLambda;
    Map<String, Object> args;

    /**
    * creates a FileWriteJob
    */
    // global ContentXWriteJob() { this(FileDataWriterCsv.class, new WriterOptions(null, '\n')); }
    global FileWriteJob() { this(FileWriter.class, null, '\n'); }
    /**
    * creates a FileWriteJob
    * @param writerType the writerType
    */
    global FileWriteJob(Type writerType) { this(writerType, null, '\n'); }
    /**
    * creates a FileWriteJob
    * @param writeSegmentType the writeSegmentType
    * @param openTag the openTag
    * @param closeTag the closeTag
    */
    global FileWriteJob(Type writerType, String openTag, String closeTag) {
        this.writerType = writerType;
        this.openTag = openTag;
        this.closeTag = closeTag;
    }

    /**
    * sets the args
    * @param args the args
    */
    global virtual void setArgs(Map<String, Object> args) {
        this.args = args = (args ?? new Map<String, Object>());
        if (!args.containsKey('path')) throw new HandledException('Required: path');
        if (args.containsKey('path')) args.put('path', (String)ObjectX.mergex(null, (String)args.get('path')));
        if (args.containsKey('moveto')) args.put('moveto', (String)ObjectX.mergex(null, (String)args.get('moveto')));
    }

    /**
    * sets the scope Func
    * @param scopeLambda the scopeLambda
    * @return ContentXWriteJob
    */
    global FileWriteJob scopeLambda(Type scopeLambda) {
        this.scopeLambda = scopeLambda;
        return this;
    }

    /**
    * execute
    * @param sc the SchedulableContext
    */
    global virtual void execute(SchedulableContext sc) {
        // List<Object> segments = ContentX.createContentWriteSegments(writeSegmentType,
        //     scopeLambda,
        //     args,
        //     (ContentX.IProvider2)(args.get('provider') ?? options.provider(this)),
        //     (String)args.get('path'),
        //     (String)args.get('moveto'),
        //     openTag, closeTag);
        // Integer batchSize = (Integer)SystemX.ifNull(args.get('countlimit'), (Object)options.countLimit(this));
        // SystemX.executeBatches(this, segments, batchSize);
    }

    //#region Test

    // public static void test() {
    //     CustomContentXWriteJob job = new CustomContentXWriteJob();
    //     job.scopeLambda(CustomLambda.class).setArgs(new Map<String, Object> {
    //         'path' => 'export.txt'
    //         // 'moveto' => 'done',
    //         // 'countlimit' => 5
    //     });
    //     job.execute(null);
    // }
    // class CustomLambda implements SystemX.Lambda {
    //     public Object lambda() { return Database.getQueryLocator('SELECT Id, Name FROM User'); }
    //     // public Object lambda() { return Database.getQueryLocator('SELECT Id, LogUserId, LogLength, LastModifiedDate, Request, Operation, Application, Status, DurationMilliseconds, SystemModstamp, StartTime, Location, RequestIdentifier FROM ApexLog'); }
    // }
    // class CustomContentXWriteJob extends ContentXWriteJob {
    // }

    //#endregion
}
