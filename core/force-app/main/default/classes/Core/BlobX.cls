/**
* Blob extensions
*/
global class BlobX {
    /**
    * returns a new Blob that begins at the specified zero-based startIndex and extends to the endIndex
    * @param source the source
    * @param range the range
    * @return Blob
    */
    global static Blob subblob(Blob source, Integer startIndex, Integer endIndex) {
        if (source == null) return null;
        String s = EncodingUtil.convertToHex(source);
        return EncodingUtil.convertFromHex(s.substring(startIndex << 1, Math.min(endIndex << 1, s.length())));
    }

    /**
    * returns a new Blob for the specified range
    * @param source the source
    * @param range the range
    * @return Blob
    */
    global static Blob subblob(Blob source, Range range) {
        if (source == null) return null;
        String s = EncodingUtil.convertToHex(source);
        return EncodingUtil.convertFromHex(s.substring(range.start << 1, Math.min(range.endx << 1, s.length())));
    }

    /**
    * decodes a blob
    * @param content the content
    * @return String
    */
    global static String decode(Blob content) {
        if (content == null) return null;
        try { return content.toString(); } catch (StringException e) { return StringX.decode(content, 'UTF-8'); }
    }

    /**
    * encodes a blob
    * @param content the content
    * @return Blob
    */
    global static Blob encode(String content) { return content != null ? Blob.valueOf(content) : null; }
}