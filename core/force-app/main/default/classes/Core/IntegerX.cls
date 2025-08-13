/**
* IntegerX extensions
*/
global class IntegerX {
    static String[] hexs;

    /**
    * converts an hex string to an integer
    * @param value the value
    * @return Integer
    */
    global static Integer hexToInt(String value) {
        if (hexs == null) hexs = '0123456789abcdef'.split('');
        Integer r = 0;
        String[] hexValue = value.toLowerCase().split('');
        for (Integer i = 0; i < hexValue.size(); i++) r = (r << 4) + hexs.indexOf(hexValue[i]);
        return r;
    }

    /**
    * converts an integer to a hex string
    * @param value the value
    * @param pad should pad the value
    * @return String
    */
    global static String intToHex(Integer value, Boolean pad) {
        if (hexs == null) hexs = '0123456789abcdef'.split('');
        String[] b = new String[32]; Integer i = 32;
        do { b[--i] = hexs[value & 15]; value >>>= 4; } while (value != 0);
        String r = String.join(b, '');
        return r.leftPad(pad ? Math.max(r.length() + Math.mod(r.length(), 2), 1) : 1, '0');
    }
}