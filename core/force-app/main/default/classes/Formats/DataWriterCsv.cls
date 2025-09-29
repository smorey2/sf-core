/**
* a csv writer
*/
global virtual class DataWriterCsv extends DataWriter {
    global String COMMA = ',';

	/**
    * DataWriterCsv
    * @param columns the columns
    */
    global DataWriterCsv(Map<String, DataColumn> columns) { super(columns); }

    /**
    * writes the header
    * @return String
    */
    global override void writeHeader() {
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
    global override void writeNext(Object value) {
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
    * writes the csv file
    * @param columns the columns
    * @param headerRow the headerRow
    * @param values the values
    * @return String
    */
    global static String write(Map<String, DataColumn> columns, Boolean headerRow, List<Object> values) { return new DataWriterCsv(columns).write(headerRow, values); }
}