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

    //#region Scan

    global class ScanOptions {
        global String open, close;
        global Integer scan = SystemX.isAsyncContext() ? 2900000 : 1400000, atsize = 0, atcount = 500;
        global ScanOptions(String open, String close) { this.open = open; this.close = close; }
    }

    // public class Scanner {
    //     public Scanner() {

    //     }
    //     public Boolean nextPage() {
    //         if (LimitsX.reached(limitOn)) return false;
    //         if (false) scanRange = new Range(scanRange.endx - overlap, scanRange.endx + scan);
    //         Blob b = source.get(key, scanRange); 
    //         if (b == null) return null;
    //         String content = b != null ? EncodingUtil.convertToHex(b) : null; Integer contentLen = content.length() >> 1;
    //         // SystemX.debug('Content: ' + scanRange + ', Heap: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());

    //         b = source.get(key, scanRange); content = b != null ? EncodingUtil.convertToHex(b) : null;
    //         SystemX.debug('Content: ' + scanRange + ', Heap: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
    //         endOffset = 0;
    //     }
    // }

    /**
    * hack: limit
    */
    global static Integer XSubcount = 0;

    /**
    * scans the blob
    * @param source the source
    * @param key the key
    * @param options the options
    * @return List<Range>
    */
    global static List<Range> scan(Blobable source, String key, ScanOptions options) {
        if (LimitsX.reached(source.limitOn())) return null;
        String open = options.open != null ? EncodingUtil.convertToHex(Blob.valueOf(options.open)) : null, close = options.close != null ? EncodingUtil.convertToHex(Blob.valueOf(options.close)) : null, next = close ?? open;
        Integer openLen = open != null ? open.length() >> 1 : 0, closeLen = close != null ? close.length() >> 1 : 0, nextLen = next.length() >> 1, overlap = nextLen - 1;
        Integer scan = options.scan, atsize = options.atsize, atcount = options.atcount, subcount = atcount > 0 ? XSubcount : 0;
        Range range, scanRange = scan != null && source.acceptRanges() == 'bytes' ? new Range(0, scan) : null;

        Blob b = source.get(key, scanRange); 
        if (b == null) return null;
        String content = b != null ? EncodingUtil.convertToHex(b) : null; Integer contentLen = content.length() >> 1;
        // SystemX.debug('Content: ' + scanRange + ', Heap: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        // find first open or exit early
        Integer index = open != null ? (Integer)(content.indexOf(open) >> 1).round(RoundingMode.FLOOR) : 0, rangeStart = index;
        if (index < 0) return null;

        // search for tags
        Integer size = 0, count = 0, startOffset = 0, endOffset = 0;
        List<Range> r = new List<Range>();
        while (true) {
            Integer contentRangeStart = scanRange != null ? scanRange.start : 0;

            // find next
            Integer endx = (Integer)(content.indexOf(next, (index + 1) * 2) / 2.0).round(RoundingMode.FLOOR);
            if (endx >= 0) {
                size += endx - index; count++;
                index = endx;
                // size/count limit reached, add to results
                if ((atsize != 0 && size >= atsize) || (atcount != 0 && count >= atcount)) { 
                    size = count = 0;
                    // reduced limits
                    if (subcount > 0) { countLimit -= subcount; subcount = 0; }
                    // dangling close
                    if (close != null) {
                        endOffset = (Integer)(content.lastIndexOf(close, endx * 2) / 2.0).round(RoundingMode.FLOOR) + closeLen;
                        endOffset = endOffset > closeLen ? endx - endOffset : 0;
                    }
                    // add range to results
                    range = new Range(rangeStart + startOffset, contentRangeStart + endx - endOffset); if (range.start < range.endx) { r.add(range); }
                    rangeStart = range.endx + endOffset;
                    // dangling open
                    if (open == null) startOffset = closeLen;
                }
                continue;
            }
            endx = contentLen;

            // complete if ranges not supported or content is less than range size
            if (scanRange == null || endx < scan) {
                if (close != null) {
                     endOffset = (Integer)(content.lastIndexOf(close, endx * 2) / 2.0).round(RoundingMode.FLOOR) + closeLen;
                     endOffset = endOffset > closeLen ? endx - endOffset : 0;
                }
                content = null;
            }
            // fetch next chunk
            else {
                if (LimitsX.reached(limitOn)) return null;
                scanRange = new Range(scanRange.endx - overlap, scanRange.endx + scan);
                b = source.get(key, scanRange); content = b != null ? EncodingUtil.convertToHex(b) : null;
                SystemX.debug('Content: ' + scanRange + ', Heap: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
                endOffset = 0;
            }

            // last segment, add and break
            if (content == null) {
                range = new Range(rangeStart + startOffset, contentRangeStart + endx - endOffset); if (range.start < range.endx) r.add(range);
                break;
            }
            contentLen = content.length();
            size = index = 0;
        }
        return r;
    }

    //#endregion
}