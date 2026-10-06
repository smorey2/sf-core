/**
* data file reader
*/
global virtual class FileDataReaderWeave extends FileReader {
    global Integer startRow = 1;
    global String scriptNamespace;
    global String scriptName;

    /**
    * execute segment
    * @param content the content
    */
    global virtual override void execute(String text) {
        DataWeave.Script script = DataWeave.Script.createScript(scriptNamespace, scriptName);
        DataWeave.Result result = script.execute(new Map<String, Object> { 'records' => text, 'startRow' => startRow });
        List<Object> values = (List<Object>)result.getValue();
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