/**
* ReadFinish for ContentX
*/
global virtual class FileReadComplete implements Queueable, Database.AllowsCallouts {
    global Cloud cloud;
    global Cloud.File file;
    global Map<String, Object> args;

    /**
    * sets the arguments for the read finish object
    * @param cloud the cloud
    * @param file the file
    * @param args the args
    * @return FileReadComplete
    */
    global FileReadComplete args(Cloud cloud, Cloud.File file, Map<String, Object> args) {
        this.cloud = cloud;
        this.file = file;
        this.args = args;
        return this;
    }

    /**
    * execute
    * @param qc the queueable context
    */
    global virtual void execute(QueueableContext qc) {
        String archive = args != null ? (String)args.get('archive') : null;
        execute(archive);
    }

    /**
    * execute finish
    * @param archive the archive path
    */
    global virtual void execute(String archive) {
        if (cloud == null) return;
        if (String.isNotEmpty(archive)) cloud.move(file.path, archive + '/' + PathX.getFileName(file.path));
        else cloud.deletex(file.path);
    }
}