/**
* a csv writer
*/
global virtual class CsvWriter extends DataWriter {
    global String COMMA = ',';
    global Map<String, DataColumn> columns;
    List<String> w = new List<String>();
    List<String> b = new List<String>();

	/**
    * CsvWriter
    * @param columns the columns
    */
    global CsvWriter(Map<String, DataColumn> columns) { if (columns == null) throw new IllegalArgumentException('Required: columns'); this.columns = columns; }

    /**
    * writes the csv header row
    * @param values the values
    * @param columns the columns
    * @return String
    */
    global virtual void writeHeader() {
        for (String key : columns.keySet()) {
            DataColumn column = columns.get(key);
            String name = column != null && !String.isEmpty(column.displayName) ? column.displayName : key;
            b.add(column == null || column.encode ? name.escapeCsv() : name);
        }
        w.add(String.join(b, COMMA) + '\n'); b.clear();
    }

    /**
    * writes the next line
    * @param value the value
    */
    global virtual void writeNext(Object value) {
        if (value instanceOf Map<String, Object>)
            for (String key : columns.keySet()) {
                DataColumn column = columns.get(key);
                Object v = ((Map<String, Object>)value).get(key);
                String val = v != null ? String.valueOf(v) : '';
                b.add(column == null || column.encode ? val.escapeCsv() : val);
            }
        else if (value instanceOf SObject)
            for (String key : columns.keySet()) {
                DataColumn column = columns.get(key);
                String field = column != null && !String.isEmpty(column.field) ? column.field : key;
                Object v = ObjectX.get((SObject)value, field);
                String val = v != null ? String.valueOf(v) : '';
                b.add(column == null || column.encode ? val.escapeCsv() : val);
            }
        else throw new HandledException('Unknown object type');
        w.add(String.join(b, COMMA) + '\n'); b.clear();
    }

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

    /**
    * writes the csv file
    * @param columns the columns
    * @param headerRow the headerRow
    * @param values the values
    * @return String
    */
    global static String write(Map<String, DataColumn> columns, Boolean headerRow, List<Object> values) { return new CsvWriter(columns).write(headerRow, values); }
}