/*
* the IString for case-insensitive compares
*/
global class IString {
    global String str;

    /**
    * constructor
    * @param obj the obj
    */
    global IString(Object obj) {
        this.str = obj == null ? null
            : obj instanceof String ? (String)obj
            : obj.toString();
    }
    /**
    * constructor
    * @param str the str
    */
    global IString(String str) { this.str = str; }

    /**
    * object equals
    * @param obj the obj
    * @return Boolean
    */
    global Boolean equals(Object obj) {
        return obj instanceof IString ? str != null ? str.equalsIgnoreCase(((IString)obj).str) : ((IString)obj).str == null
            : obj instanceof String ? str.equalsIgnoreCase((String)obj)
            : false;
    }

    /**
    * gets the hashcode
    * @return Integer
    */
    global override Integer hashCode() { return str != null ? str.toLowerCase().hashCode() : 0; }

    /**
    * gets the string
    * @return String
    */
    global override String toString() { return str; }

    /**
    * checks if empty
    * @param source the source
    * @return Boolean
    */
    global static Boolean isEmpty(IString source) { return String.isEmpty(source?.str); }

    /**
    * makes the list
    * @param source the source
    * @return List<String>
    */
    global static List<String> listx(List<IString> source) {
        List<String> r = new List<String>();
        for (IString s : source) r.add(s.str);
        return r;
    }

    /**
    * makes the set
    * @param source the source
    * @return Set<String>
    */
    global static Set<String> set(Set<IString> source) {
        Set<String> r = new Set<String>();
        for (IString s : source) r.add(s.str);
        return r;
    }
}