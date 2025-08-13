/**
* String method extensions
*/
global class StringX {
    /**
    * clamps a string
    * @param source the string to chunk
    * @param length the max length
    * @return String
    */
    global static String clamp(String source, Integer length) {
        return source != null && source.length() > length ? source.substring(0, length - 1) : source;
    }

    /**
    * clamps a string
    * @param source the string to chunk
    * @param length the max length
    * @return String
    */
    global static String clamp(String source, Integer length, String elipse) { // '...'
        return source != null && source.length() > length ? source.substring(0, length - elipse.length() - 1) + elipse : source;
    }

    /**
    * chunks a string at index
    * @param source the string to chunk
    * @param index the chunk index
    * @param size the chunk size
    * @return String
    */
    global static String chunkStringAt(String source, Integer index, Integer size) {
        if (size == null) size = 3950;
        Integer l = source?.length(), f = (index * size), t = ((index + 1) * size);
        return source == null || l < f ? null : source.substring(f, (t > l ? l : t));
    }

    /**
    * decodes a map
    * @param value the value
    * @param lower the make keys lowercase
    * @return Map<String, Object>
    */
    global static Map<String, Object> decodeMap(String values, Boolean lower) {
        if (String.isEmpty(values)) return null;
        Map<String, Object> r = new Map<String, Object>();
        for (String value : values.split(',')) {
            String type = value.substring(0, 1), key = value.substring(1, value.indexOf('=')), str = value.substring(value.indexOf('=') + 1);
            if (lower) key = key.toLowerCase();
            switch on type {
                when 's' { r.put(key, str); }
                when 'b' { r.put(key, Boolean.valueOf(str)); }
                when 'i' { r.put(key, Integer.valueOf(str)); }
                when 'l' { r.put(key, Long.valueOf(str)); }
                when 'd' { r.put(key, Double.valueOf(str)); }
                when 'y' { r.put(key, Date.valueOf(str)); }
                when 'z' { r.put(key, Datetime.valueOfGmt(str)); }
                when 'o' {
                    Object o;
                    if (str.startsWith('{') && str.endsWith('}')) {
                        str = str.substring(1, str.length() - 1).replaceAll('`', ',');
                        o = decodeMap(str, lower);
                    }
                    else if (str == '[]') o = new List<Map<String, Object>>();
                    else if (str.startsWith('[{') && str.endsWith('}]')) {
                        str = str.substring(2, str.length() - 2);
                        List<Map<String, Object>> b2 = new List<Map<String, Object>>();
                        for (String values2 : str.split('\\}`\\{')) b2.add(decodeMap(values2, lower));
                        o = b2;
                    }
                    else throw new HandledException('Unknown object: ' + str);
                    r.put(key, o);
                }
                when else { throw new HandledException('Unknown type for: ' + type + key); }
            }
        }
        return r;
    }

    /**
    * encodes a map
    * @param values the values
    * @param lower the make keys lowercase
    * @return String
    */
    global static String encodeMap(Map<String, Object> values, Boolean lower) {
        if (values == null) return null;
        List<String> r = new List<String>();
        for (String key : values.keySet()) {
            Object value = values.get(key);
            if (value == null) r.add('s' + key + '=');
            else if (value instanceOf String) r.add('s' + key + '=' + value);
            else if (value instanceOf Boolean) r.add('b' + key + '=' + String.valueOf(value));
            else if (value instanceOf Integer) r.add('i' + key + '=' + String.valueOf(value));
            else if (value instanceOf Long) r.add('l' + key + '=' + String.valueOf(value));
            else if (value instanceOf Double || value instanceOf Decimal) r.add('d' + key + '=' + String.valueOf(value));
            else if (value instanceOf Date) r.add('y' + key + '=' + String.valueOf(value).removeEnd(' 00:00:00'));
            else if (value instanceOf Datetime) r.add('z' + key + '=' + String.valueOfGmt((Datetime)value));
            else if (value instanceOf Map<String, Object> || value instanceOf List<Map<String, Object>>) {
                String str;
                if (value instanceOf Map<String, Object>) str = '{' + encodeMap((Map<String, Object>)value, lower).replaceAll(',', '`') + '}';
                else if (value instanceOf List<Map<String, Object>>) {
                    List<String> b2 = new List<String>();
                    for (Map<String, Object> s2 : (List<Map<String, Object>>)value) b2.add('{' + encodeMap(s2, lower).replaceAll(',', '`') + '}');
                    str = '[' + String.join(b2, '`') + ']';
                }
                r.add('o' + key + '=' + str);
            }
            else { throw new HandledException('Unknown type for: ' + key); }
        }
        return String.join(r, ',');
    }

    /**
    * encodes a string into bytes in charset
    * @param input string of Unicode characters
    * @param charset name according to http://www.iana.org/assignments/character-sets/character-sets.xhtml
    * @return Blob - binary characters in charset
    */
    global static Blob encode(String input, String charset) {
        String e = EncodingUtil.urlEncode(input, charset);
        e = e.replace('+', '%20');
        if (charset == 'UTF-16LE') e = e.replace('%20', '%20%00');
        Matcher m = Pattern.compile('(.*?)%([0-9A-F]{2})|(.+)').matcher(e);
        String r = '';
        while (m.find()) {
            if (!String.isBlank(m.group(1))) r += encode16LE(EncodingUtil.convertToHex(Blob.valueOf(m.group(1))), charset);
            if (!String.isBlank(m.group(2))) r += m.group(2);
            if (!String.isBlank(m.group(3))) r += encode16LE(EncodingUtil.convertToHex(Blob.valueOf(m.group(3))), charset);
        }
        return EncodingUtil.convertFromHex(r);
    }

    static final Pattern ByteRegex = Pattern.compile('([0-9A-Fa-f]{2})');

    /**
    * decodes bytes in charset into a string of Unicode characters
    * @param input binary characters in charset
    * @param charset name according to http://www.iana.org/assignments/character-sets/character-sets.xhtml
    * @return String - string of Unicode characters
    */
    global static String decode(Blob input, String charset) {
        return EncodingUtil.urlDecode(ByteRegex.matcher(EncodingUtil.convertToHex(input)).replaceAll('%$1'), charset);
    }

    /**
    * encodes to UTF-16LE
    * @param input string of Unicode characters
    * @param charset name according to http://www.iana.org/assignments/character-sets/character-sets.xhtml
    * @return String - Unicode characters in charset
    */
    global static String encode16LE(String input, String charset) {
        if (charset != 'UTF-16LE') return input;
        return ByteRegex.matcher(input).replaceAll('$100');
    }

    /**
    * combines blobs
    * @param blobs the blobs
    * @return Blob
    */
    global static Blob combine(Blob[] blobs) {
        List<String> r = new List<String>();
        for (Blob s : blobs) {
            if (s == null) continue;
            r.add(EncodingUtil.convertToHex(s));
        }
        return EncodingUtil.convertFromHex(String.join(r, ''));
    }
}