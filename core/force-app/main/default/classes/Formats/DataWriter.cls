/**
* a data writer
*/
global abstract class DataWriter {
    global Map<String, DataColumn> columns;
    global List<String> w = new List<String>(), b = new List<String>();

	/**
    * DataWriter
    * @param columns the columns
    */
    global DataWriter(Map<String, DataColumn> columns) { if (columns == null) throw new IllegalArgumentException('Required: columns'); this.columns = columns; }

    /**
    * writes the header
    * @return String
    */
    global abstract void writeHeader();

    /**
    * writes the next line
    * @param value the value
    */
    global abstract void writeNext(Object value);

    /**
    * returns the string
    * @return String
    */
    global override String toString() { return String.join(w, ''); }

    /**
    * writes the csv file
    * @param headerRow the headerRow
    * @param values the values
    * @return String
    */
    global String write(Boolean headerRow, List<Object> values) {
        if (headerRow) writeHeader();
        if (values != null) for (Object value : values) writeNext(value);
        return toString();
    }
}
