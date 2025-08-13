/**
* Cloud
*/
global abstract class Cloud implements Database.AllowsCallouts {
    /**
    * a file entry in a content provider
    */
    global class File {
        global String key;
        global String path;
        global final Integer size;
        global final Datetime lastModified;
        global String tag;
        /**
        * creates the content read segments by tag
        * @param key the key
        * @param path the path
        * @param size the size
        * @param lastModified the lastModified
        */
        global File(String key, String path, Integer size, Datetime lastModified) { this.key = key; this.path = path; this.size = size; this.lastModified = lastModified; }
    }

    /**
    * accessToken
    * @param arg the arg
    * @return Map<String, Object>
    */
    global Map<String, Object> accessToken() { return accessToken(null); }
    /**
    * accessToken
    * @param arg the arg
    * @return Map<String, Object>
    */
    global virtual Map<String, Object> accessToken(String arg) { return null; }

    /**
    * endpoint
    * @param type the type
    * @param endpoint the endpoint
    * @return String
    */
    global virtual String endpoint(String type, String endpoint) { throw new HandledException('Unknown type: ' + type); }

    /**
    * accepts-ranges
    * @return String
    */
    global virtual String acceptRanges() { return null; }

    /**
    * limit on
    * @return String[]
    */
    global virtual String[] limitOn() { return null; }

    /**
    * creates an entry
    * @param path the path
    * @param content the content
    * @return File
    */
    global virtual File create(String path, Object content) { put(path, null, content); return new File(path, path, 0, null); }

    /**
    * copies an object
    * @param path the path
    * @param newPath the new path
    */
    global virtual void copy(String path, String newPath) { }

    /**
    * deletes an object
    * @param path the path
    */
    global virtual void deletex(String path) { }

    /**
    * gets an object
    * @param key the key
    * @param range the range
    * @return Blob
    */
    global virtual Blob get(String path, Range range) { return null; }

    /**
    * moves an object
    * @param path the path
    * @param newPath the new path
    */
    global virtual void move(String path, String newPath) { }

    /**
    * moves an object
    * @param entry the entry
    * @param newPath the new path
    */
    global virtual void move(File entry, String newPath) { move(entry.key, newPath); entry.key = entry.path = newPath; }

    /**
    * lists all objects
    * @param prefix the prefix
    * @param filters the filters
    * @return List<ContentX.File>
    */
    global virtual List<File> listx(String prefix, String filters) { return null; }

    /**
    * puts an object
    * @param key the key
    * @param range the range
    * @param content the content
    */
    global virtual void put(String path, Range range, Object content) { }

    /**
    * flush on
    * @return Integer
    */
    global virtual Integer flushOn() { return 0; }

    /**
    * aborts a multipart upload
    * @param entry the entry
    * @param parts the parts
    */
    global virtual void abortMultipart(File entry, List<Object> parts) { }

    /**
    * creates a multipart upload
    * @param path the path
    */
    global virtual File createMultipart(String path) { return null; }
    
    /**
    * completes a multipart upload
    * @param entry the entry
    * @param parts the parts
    * @return ContentX.File
    */
    global virtual File completeMultipart(File entry, List<Object> parts) { return null; }
    
    /**
    * uploads a part
    * @param entry the entry
    * @param part the part
    * @param content the content
    * @return Object
    */
    global virtual Object uploadPart(File entry, Object part, Object content) { return null; }
}
