/**
* Blobable
*/
global interface Blobable {
    /**
    * accepts-ranges
    * @return String
    */
    String acceptRanges();

    /**
    * limit on
    * @return String[]
    */
    String[] limitOn();

    /**
    * gets an object
    * @param key the key
    * @param range the range
    * @return Blob
    */
    Blob get(String path, Range range);
}
