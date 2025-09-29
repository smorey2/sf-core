/**
* a data reader
*/
global abstract class DataReader {
	global String source;
	global Integer length, position = 0;
	global List<String> header;
	
	/**
    * DataReader
    * @param source the source
    */
    global DataReader(String source) { if (source == null) throw new IllegalArgumentException('Required: source'); this.source = trim(source); length = source.length(); }

	/**
    * trims
    * @param source the source
    * @return String
    */
	global virtual String trim(String source) {
        source = source.trim();
        Integer sourceLength = source.length();
        if (sourceLength > 2 && source.substring(sourceLength - 2) == '\n"') source = source.substring(0, sourceLength - 1).trim();
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
    global abstract List<String> readNext();
	
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
}
