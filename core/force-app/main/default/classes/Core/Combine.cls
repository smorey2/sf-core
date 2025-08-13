/**
* Join method extensions
*/
global class Combine {
    //#region Joins

    /**
    * cross joins an sobject with its relationships
    * @param scope the scope
    * @param fields the fields
    * @param fullJoin the fullJoin
    * @return List<List<SObject>>
    * note: combine crossJoin and Json into a single parser? also add More than SObject
    */
    global static List<List<SObject>> crossJoin(List<SObject> scope, List<String> fields, Boolean fullJoin) {
        if (fullJoin == true) throw new HandledException('Full join not implemented');
        List<SObject> empty = new List<SObject>();
        List<List<SObject>> r = new List<List<SObject>>();
        switch on fields.size() {
            when 1 {
                for (SObject s : scope) for (SObject t : s.getSObjects(fields[0]) ?? empty) {
                    r.add(new SObject[] { s, t });
                }
            }
            when 2 {
                for (SObject s : scope) for (SObject t : s.getSObjects(fields[0]) ?? empty) for (SObject u : s.getSObjects(fields[1]) ?? empty) {
                    r.add(new SObject[] { s, t, u });
                }
            }
            when else { throw new HandledException('Unable to handle: size ' + fields.size()); }
        }
        return r;
    }

    global static List<Object> crossJoinItems(Object s, String field, Object arg) {
        Object o;
        List<Object> empty = new List<Object>();
        String v = field.substringBefore(':'), t = field.substringAfter(':');
        if (t.startsWithIgnoreCase('json')) {
            if (s instanceof SObject) v = (String)((SObject)s).get(v);
            else if (s instanceof Map<String, Object>) v = (String)((Map<String, Object>)s).get(v);
            else v = (String)ObjectX.get(s, v);
            String u = t.substringAfter(';'); o = null;
            try { o = String.isNotEmpty(v) ? JSON.deserializeUntyped(v) : null; }
            catch (Exception e) { SystemX.debug('JSON: ' + e.getMessage()); }
            if (String.isNotEmpty(u) && o != null && o instanceof Map<String, Object>) { o = ((Map<String, Object>)o).get(u); }
        }
        else {
            if (s instanceof SObject) o = (t != 'get' ? ((SObject)s).getSObjects(v) : ((SObject)s).get(v)) ?? empty;
            else if (s instanceof Map<String, Object>) o = ((Map<String, Object>)s).get(v) ?? empty;
            else o = ObjectX.get(s, v) ?? empty;
        }
        return o == null ? empty : o instanceof List<Object> ? (List<Object>)o : new Object[] { o };
    }

    /**
    * cross joins an sobject with its relationships
    * @param scope the scope
    * @param fields the fields
    * @param args the args
    * @return List<List<Object>>
    */
    global static List<List<Object>> crossJoinx(List<Object> scope, List<String> fields, Object args) {
        List<List<Object>> r = new List<List<Object>>();
        switch on fields.size() {
            when 1 {
                for (Object s : scope) for (Object t : crossJoinItems(s, fields[0], args)) {
                    r.add(new Object[] { s, t });
                }
            }
            when 2 {
                for (Object s : scope) for (Object t : crossJoinItems(s, fields[0], args)) for (Object u : crossJoinItems(s, fields[1], args)) {
                    r.add(new Object[] { s, t, u });
                }
            }
            when else { throw new HandledException('Unable to handle: size ' + fields.size()); }
        }
        return r;
    }

    /**
    * rescope
    * @param scope the scope
    * @param code the fields
    * @param codargse the args
    * @return List<Object>
    */
    global static List<Object> rescope(List<Object> scope, String code, Object args) {
        String v = code.substringBefore(':').toLowerCase(), t = code.substringAfter(':');
        switch on v {
            when 'crossjoin' { return crossJoinx(scope, t.split(','), args); }
            when else { return scope; }
        }
    }

    //#endregion
}