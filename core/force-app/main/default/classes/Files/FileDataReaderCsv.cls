/**
* data file reader
*/
global virtual class FileDataReaderCsv extends FileReader {
    global Integer startRow = 1;
    global Map<String, Integer> header; //: REMOVE

    /**
    * gets a csvreader
    * @param text the text
    * @return DataReaderCsv
    */
    global virtual DataReaderCsv getReader(String text) { return new DataReaderCsv(text); }

    /**
    * gets a header
    * @param header the header
    * @return Map<String, Integer>
    */
    global virtual Map<String, Integer> getHeader(String[] header) {
        Map<String, Integer> r = new Map<String, Integer>();
        if (header == null) return r;
        for (Integer i = 0; i < header.size(); i++) r.put(header[i]?.toLowerCase(), i);
        return r;
    }

    /**
    * execute segment
    * @param text the text
    */
    global virtual override void execute(String text) {
        Integer startRow = this.batch == 1 ? this.startRow : 0;
        if (this.batch == 1 && startRow > 0) {
            String line = (String.isNotEmpty(text) ? text.substring(0, text.indexOf(DataReaderCsv.LINE)) : 'Header') + DataReaderCsv.LINE;
            setMeta(Blob.valueOf(line.repeat(startRow)), 0);
        }
        DataReaderCsv reader = getReader(text);
        List<Object> values = reader.parse(startRow);
        if (reader.header != null) state.put('header', getHeader(reader.header));
        execute(values);
    }

    /**
    * execute segment
    * @param values the values
    */
    global virtual void execute(List<Object> values) {
        SystemX.debug(values);
        log.logInfo('complete');
    }
}