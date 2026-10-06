/**
* a content read job 
*/
global virtual class FileReadJob implements Schedulable, SystemX.Args, Database.AllowsCallouts {
    Type readerType;
    BlobX.ScanOptions scanOptions;
    Map<String, Object> args;

    /**
    * creates a FileReadJob
    */
    global FileReadJob() { this(FileDataReaderCsv.class, new BlobX.ScanOptions(null, '\n')); }
    /**
    * creates a FileReadJob
    * @param readerType the readerType
    */
    global FileReadJob(Type readerType) { this(readerType, new BlobX.ScanOptions(null, '\n')); }
    /**
    * creates a FileReadJob
    * @param readerType the readerType
    * @param scanOptions the scanOptions
    */
    global FileReadJob(Type readerType, BlobX.ScanOptions scanOptions) {
        this.readerType = readerType;
        this.scanOptions = scanOptions;
    }

    /**
    * sets the args
    * @param args the args
    */
    global virtual void setArgs(Map<String, Object> args) {
        this.args = args = (args ?? new Map<String, Object>());
        if (!args.containsKey('prefix')) throw new HandledException('Required: prefix');
        if (args.containsKey('prefix')) args.put('prefix', (String)ObjectX.mergex(null, (String)args.get('prefix')));
        if (args.containsKey('archive')) args.put('archive', (String)ObjectX.mergex(null, (String)args.get('archive')));
        if (args.containsKey('moveto')) args.put('moveto', (String)ObjectX.mergex(null, (String)args.get('moveto')));
    }

    /**
    * execute
    * @param sc the SchedulableContext
    */
    global virtual void execute(SchedulableContext sc) {
        // ContentX.XCountLimitReduce = 1;
        // CoreOptions options = CoreOptions.get;
        // BlobX.ScanOptions scanOptions = new BlobX.ScanOptions(open, close);
        // List<Object> segments = BlobX.scan(readSegmentType,
        //     args.containsKey('archive') ? ContentXReadFinish.class : null,
        //     args,
        //     (ContentX.IProvider)(args.get('provider') ?? options.provider(this)),
        //     (String)args.get('prefix'),
        //     (String)args.get('moveto'),
        //     openTag, closeTag,
        //     (Integer)SystemX.ifNull(args.get('rangesize')?? options.rangeSize(this)),
        //     (Integer)SystemX.ifNull(args.get('sizelimit')?? options.sizeLimit(this)),
        //     (Integer)SystemX.ifNull(args.get('countlimit')?? options.countLimit(this)));
        // SystemX.executeBatches(this, segments, 1);
    }

    //#region Test

    // public static void test() {
    //     CustomContentXReadJob job = new CustomContentXReadJob();
    //     job.setArgs(new Map<String, Object> {
    //         'prefix' => 'import',
    //         'archive' => 'archivex',
    //         'moveto' => 'working',
    //         'countlimit' => 10
    //     });
    //     job.execute(null);
    // }
    // class CustomContentXReadJob extends ContentXReadJob {
    // }

    //#endregion
}
