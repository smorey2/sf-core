/**
* DoubleX extensions
*/
global class DoubleX {
    /**
    * formats a double value
    * @param value the double
    * @param format the format
    * @param arg the arg
    * @return String
    */
    global static String format(Object value, String format, Object arg) {
        if (value == null) return null;
        Double d = Double.valueOf(value); Decimal e = (Decimal)d;
        String cur = e.longValue().format() + '.' + e.setScale(2).toPlainString().split('\\.')[1];
        switch on format {
            when '$' { return cur; }
            when 'USD' { return '$' + cur; }
            when 'EUR' { return '€' + cur; }
            when 'GBP' { return '£' + cur; }
            when 'AUD' { return '$' + cur; }
            when 'CAD' { return '$' + cur; }
            when else { return d.format(); }
        }
    }
}