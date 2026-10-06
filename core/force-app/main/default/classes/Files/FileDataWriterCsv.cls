/**
* data file writer
*/
global virtual class FileDataWriterCsv extends FileWriter {
    global Map<String, DataColumn> columns;

    /**
    * execute segment
    * @param scope the scope
    * @return String
    */
    global override String execute(List<Object> scope) {
        Boolean hasHeader = this.batch == 1;
        Object value = DataWriterCsv.write(columns, hasHeader, scope);
        return execute(value);
    }

    /**
    * execute csv segment
    * @param values the values
    */
    global virtual String execute(Object value) {
        SystemX.debug(value);
        log.logInfo('complete');
        return (String)value;
    }
}