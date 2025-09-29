/**
* a csv reader
*/
global virtual class DataReaderCsv extends DataReader {
	global static final String LINE = '\n', QUOTE = '"', DOUBLE_QUOTE = '""';
	global String COMMA = ',';
	
	/**
    * DataReaderCsv
    * @param source the source
    */
    global DataReaderCsv(String source) { super(source); }

    /**
    * reads the next line
    * @return List<String>
    */
    global override List<String> readNext() {
        List<String> values = new List<String>();
		Integer startPos = position;
		String value;
		Integer i0, endx, padd, index;
		while (position < length) {
			i0 = source.indexOf(COMMA, position);
			endx = source.indexOf(LINE, position); if (endx != -1 && source.charAt(endx - 1) == 13) { endx--; padd = 1; } else padd = 0;
			index = Math.min(i0, endx); if (index == -1) index = Math.max(i0, endx);
			if (index == -1) { value = source.substring(startPos); position = length; }
			else { value = source.substring(startPos, index); position = index + 1 + (index == endx ? padd : 0); }
			if (!value.startsWith(QUOTE)) {
				values.add(value);
				if (index == endx) break;
				startPos = position;
			}
			else if (value.endsWith(QUOTE) && (value == DOUBLE_QUOTE || !value.endsWith(DOUBLE_QUOTE))) {
				String val = value.substring(1, value.length() - 1);
                values.add(val.indexOf(DOUBLE_QUOTE) == -1 ? val : val.replace(DOUBLE_QUOTE, QUOTE));
				if (index == endx) break;
				startPos = position;
			}
		}
		return values;
	}

    /**
    * parses a csv
    * @param source the source
    * @param startRow the startRow
    * @return List<List<String>>
    */
	global static List<List<String>> parse(String source, Integer startRow) { return new DataReaderCsv(source).parse(startRow); }
}