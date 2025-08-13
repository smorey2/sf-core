/**
* DatetimeX extensions
*/
global class DatetimeX {
    static Map<String, Integer> months;

    /**
    * adds the specified number of minutes to a Datetime
    * @param source the source
    * @param additionalMinutes the additionalMinutes
    * @return Datetime
    */
    global static Datetime addMinutes(Datetime s, Double additionalMinutes) {
        Integer minutes = (Integer)additionalMinutes, seconds = (Integer)(Math.abs(additionalMinutes - additionalMinutes.intValue()) * 60.0);
        if (minutes != 0) s.addMinutes(minutes);
        if (seconds != 0) s.addSeconds(seconds);
        return s;
    }

    /**
    * formats a datetime value
    * @param value the datetime
    * @param format the format
    * @param arg the arg
    * @return String
    */
    global static String format(Object value, String format, Object arg) {
        if (value == null) return null;
        Datetime d = Datetime.valueOf(value);
        switch on format {
            when 'sql' { return d.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); }
            when 'iso' { return d.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'SSS', (String)arg); } //: PST/GMT
            when 'stamp' { return String.fromCharArray(new Integer[] { (Integer)(arg ?? 2025) - d.year() + 65 }) +
                String.fromCharArray(new Integer[] { d.month() - 1 + 65 }) +
                String.valueOf(d.getTime() - Datetime.newInstance(d.year(), d.month(), 1).getTime()).leftPad(10, '0'); }
            when else { return d.format(format, (String)arg); }
        }
    }

    /**
    * parses the datetimeGmt
    * @param value the value
    * @param format the format
    * @return Datetime
    */
    global static Datetime parse(String value, String format) {
        if (format == 'azure' && months == null) months = new Map<String, Integer> { 'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12 };
        switch on format {
            when null, '' { return Datetime.valueOf(value); }
            when 'gmt' { return Datetime.valueOfGmt(value); }
            when 'iso' { return Datetime.valueOfGmt(value.replace('T', ' ')); }
            when 'iso8601' { Datetime dt = (Datetime)JSON.deserialize('"' + value + '"', Datetime.class); return Datetime.newInstance(dt.getTime()); }
            when 'azure' { 
                List<String> strings = value.split(' '), times = strings[4].split(':');
                return Datetime.newInstanceGmt(Integer.valueOf(strings[3]), months.get(strings[2]), Integer.valueOf(strings[1]), Integer.valueOf(times[0]), Integer.valueOf(times[1]), Integer.valueOf(times[2]));
            }
            when else { throw new HandledException('Unknown format: ' + format); }
        }
    }
}