/**
* Salesforce Platform (SFP)
*/
global class CloudSfp extends Cloud {
    /**
    * accept-ranges
    * @return String
    */
    global override String acceptRanges() { return null; }

    /**
    * limit on
    * @return String[]
    */
    global override String[] limitOn() { return null; }

    /**
    * creates an entry
    * @param path the path
    * @param content the content
    * @return File
    */
    global override File create(String path, Object content) {
        ContentVersion s = new ContentVersion(PathOnClient = path);
        if (content == null) { }
        else if (content instanceOf Blob) s.VersionData = (Blob)content;
        else if (content instanceOf String) s.VersionData = Blob.valueOf((String)content);
        else s.VersionData = Blob.valueOf(content.toString());
        Database.insert(s, true);
        return new File(s.Id, s.PathOnClient, s.ContentSize, s.ContentModifiedDate);
    }

    /**
    * copies an object
    * @param path the path
    * @param newPath the new path
    */
    global override void copy(String path, String newPath) {
        SystemX.debug('copy: ' + path + ', ' + newPath);
        List<ContentVersion> inserts = new List<ContentVersion>();
        for (ContentVersion s : [SELECT VersionData, PathOnClient, ContentModifiedDate FROM ContentVersion WHERE IsLatest = true And PathOnClient = :path])
            inserts.add(new ContentVersion(VersionData = s.VersionData, PathOnClient = newPath, ContentModifiedDate = s.ContentModifiedDate));
        if (!inserts.isEmpty()) Database.insert(inserts, true);
    }

    /**
    * deletes an object
    * @param path the path
    */
    global override void deletex(String path) {
        SystemX.debug('deletex: ' + path);
        List<ContentVersion> versions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsLatest = true And PathOnClient = :path];
        if (versions == null || versions.size() == 0) return;
        List<ContentDocument> deletes = new List<ContentDocument>();
        for (ContentVersion s : versions)
            deletes.add(new ContentDocument(Id = s.ContentDocumentId));
        if (!deletes.isEmpty()) Database.delete(deletes, true);
    }

    /**
    * gets an object
    * @param path the path
    * @param range the range
    * @return Blob
    */
    global override Blob get(String path, Range range) {
        Id id = (Id)path;
        List<ContentVersion> versions = [SELECT VersionData FROM ContentVersion WHERE IsLatest = true And Id = :id LIMIT 1];
        if (versions == null || versions.size() == 0) return null;
        Blob versionData = versions[0].VersionData;
        if (versionData == null || range == null) return versionData;
        return BlobX.subblob(versionData, range);
    }

    /**
    * lists the content entries by prefix
    * @param prefix the prefix
    * @param filters the filters
    * @return List<File>
    */
    global override List<File> listx(String prefix, String filters) {
        prefix += '%';
        List<File> r = new List<File>();
        Boolean filterSize = filters?.contains('size') == true;
        for (ContentVersion s : [SELECT Id, Title, FileExtension, ContentSize, ContentModifiedDate FROM ContentVersion WHERE IsLatest = true And Title Like :prefix]) {
            if (filterSize && s.ContentSize == 0) continue;
            r.add(new File(s.Id, s.Title + (String.isNotEmpty(s.FileExtension) ? '.' + s.FileExtension : ''), s.ContentSize, s.ContentModifiedDate));
        }
        return r;
    }

    /**
    * moves a content entry
    * @param path the path
    * @param newPath the new path
    */
    global override void move(String path, String newPath) {
        SystemX.debug('move: ' + path + ', ' + newPath);
        String newFileExtension = PathX.getExtension(newPath);
        newFileExtension = newFileExtension != '' ? newFileExtension.substring(1, newFileExtension.length()) : null;
        List<ContentVersion> versions = [SELECT Id, FileExtension FROM ContentVersion WHERE IsLatest = true And PathOnClient = :path];
        for (ContentVersion s : versions) {
            if (s.FileExtension != newFileExtension) throw new HandledException('Moving file extensions not supported');
            s.Title = PathX.getFileNameWithoutExtension(newPath);
        }
        if (!versions.isEmpty()) Database.update(versions, true);
    }

    /**
    * moves a content entry
    * @param entry the entry
    * @param newPath the new path
    */
    global override void move(File entry, String newPath) {
        move((String)entry.key, newPath);
        entry.path = newPath;
    }

    /**
    * puts an object
    * @param path the path
    * @param range the range
    * @param content the content
    */
    global override void put(String path, Range range, Object content) {
        if (range != null) throw new HandledException('Range not supported');
        ContentVersion s = new ContentVersion(Id = (Id)path);
        if (content == null) { }
        else if (content instanceOf Blob) s.VersionData = (Blob)content;
        else if (content instanceOf String) s.VersionData = Blob.valueOf((String)content);
        else s.VersionData = Blob.valueOf(content.toString());
        Database.update(s, true);
    }

    /**
    * flush on
    * @return Integer
    */
    global override Integer flushOn() { return 5242880; }
}
