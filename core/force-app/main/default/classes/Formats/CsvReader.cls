/**
* a csv reader
*/
global virtual class CsvReader extends DataReader {
	global static final String LINE = '\n';
	global static final String QUOTE = '"';
	global static final String DOUBLE_QUOTE = '""';
	global String COMMA = ',';
	global String source;
	global Integer length;
	global Integer position = 0;
	global List<String> header;
	
	/**
    * CsvReader
    * @param source the source
    */
    global CsvReader(String source) { if (source == null) throw new IllegalArgumentException('Required: source'); this.source = trim(source); length = source.length(); }

	/**
    * trims
    * @param source the source
    * @return String
    */
	global virtual String trim(String source) {
        source = source.trim();
        Integer sourceLength = source.length();
        if (sourceLength > 2 && source.substring(sourceLength - 2) == '\n"') { source = source.substring(0, sourceLength - 1).trim(); }
		return source;
	}

    /**
    * is eof
    * @return Boolean
    */
    global Boolean Eof {
		get { return position >= length; }
	}

    /**
    * reads the next line
    * @return List<String>
    */
    global virtual List<String> readNext() {
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
	global virtual List<List<String>> parse(Integer startRow) {
		List<List<String>> values = new List<List<String>>();
		if (startRow > 0) while (!Eof && startRow-- > 0) header = readNext();
		while (!Eof) values.Add(readNext());
		return values;
	}

    /**
    * parses a csv
    * @param source the source
    * @param startRow the startRow
    * @return List<List<String>>
    */
	global static List<List<String>> parse(String source, Integer startRow) { return new CsvReader(source).parse(startRow); }
}