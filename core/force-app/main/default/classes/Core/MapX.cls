/**
* Map method extensions
*/
global class MapX {
    //#region Get / Set

    /**
    * gets a object's value
    * @param obj the Object
    * @param field the field
    * @return Object
    */
    global static Object get(Map<String, Object> obj, String field) {
        if (obj == null) return null;
        String[] arg = field.split('\\.', 2);
        return arg.size() > 1
             ? ObjectX.get(obj.get(arg[0]), arg[1])
             : obj.get(field);
    }

    /**
    * gets a sobject's value
    * @param obj the SObject
    * @param field the field
    * @param modifier the modifier
    * @return Object
    */
    global static Object get(Map<String, Object> obj, String field, String modifier) {
        return Core.options.funcValue(field.startsWith('.') ? Core.options.funcGlobal(field.substring(1)) : get(obj, field), modifier);
    }

    /**
    * gets all sobject's values
    * @param fields the fields
    * @return Map<String, Object>
    */
    global static Map<String, Object> get(Map<String, Object> obj, List<String> fields) {
        if (obj == null) return null;
        Map<String, Object> r = new Map<String, Object>();
        for (String field : fields) r.put(field, get(obj, field));
        return r;
    }

    /**
    * sets a sobject's value
    * @param obj the SObject
    * @param field the field
    * @param value the value
    * @return Object
    */
    global static Object put(Map<String, Object> obj, String field, Object value) {
        if (obj == null) return null;
        String[] arg = field.split('\\.', 2);
        return arg.size() > 1
            ? ObjectX.put(obj.get(arg[0]), arg[1], value)
            : obj.put(field, value);
    }

    /**
    * sets all sobject's values
    * @param obj the SObject
    * @param values the values
    * @return Map<String, Object>
    */
    global static Map<String, Object> put(Map<String, Object> obj, Map<String, Object> values) {
        if (obj == null) return null;
        for (String field : values.keySet()) put(obj, field, values.get(field));
        return obj;
    }

    //#endregion

    //#region Transpose

    /**
    * gets the sobject's ids
    * @param objs the SObjects
    * @param field the field
    * @return Map<Id, SObject>
    */
    global static Map<Id, SObject> getIds(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        Map<Id, SObject> r = new Map<Id, SObject>();
        if (fast) for (SObject s : objs) r.put((Id)s.get(field), s);
        else for (SObject s : objs) r.put((Id)ObjectX.get(s, field), s);
        return r;
    }

    /**
    * gets the sobject's ids as set
    * @param objs the SObjects
    * @param field the field
    * @return Map<Id, SObject>
    */
    global static Map<Id, List<SObject>> getIdSet(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        Map<Id, List<SObject>> r = new Map<Id, List<SObject>>();
        for (SObject s : objs) {
            Id key = (Id)(fast ? s.get(field) : ObjectX.get(s, field));
            if (!r.containsKey(key)) r.put(key, new List<SObject> { s });
            else r.get(key).add(s);
        }
        return r;
    }

    /**
    * gets the sobject's strings
    * @param objs the SObjects
    * @param field the field
    * @return Map<String, SObject>
    */
    global static Map<String, SObject> getStrings(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        Map<String, SObject> r = new Map<String, SObject>();
        if (fast) for (SObject s : objs) r.put((String)s.get(field), s);
        else for (SObject s : objs) r.put((String)ObjectX.get(s, field), s);
        return r;
    }

    /**
    * gets the sobject's strings as set
    * @param objs the SObjects
    * @param field the field
    * @return Map<String, SObject>
    */
    global static Map<String, List<SObject>> getStringSet(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        Map<String, List<SObject>> r = new Map<String, List<SObject>>();
        for (SObject s : objs) {
            String key = (String)(fast ? s.get(field) : ObjectX.get(s, field));
            if (!r.containsKey(key)) r.put(key, new List<SObject> { s });
            else r.get(key).add(s);
        }
        return r;
    }

    //#endregion

    //#region Invert

    /**
    * inverts the map
    * @param source the source
    * @return Map<String, String>
    */
    global static Map<String, String> invert(Map<String, String> source) {
        Map<String, String> r = new Map<String, String>();
        for (String s : source.keySet()) r.put(source.get(s), s);
        return r;
    }

    /**
    * inverts the map
    * @param source the source
    * @return Map<Id, String>
    */
    global static Map<Id, String> invert(Map<String, Id> source) {
        Map<Id, String> r = new Map<Id, String>();
        for (String s : source.keySet()) r.put(source.get(s), s);
        return r;
    }

    /**
    * inverts the map
    * @param source the source
    * @return Map<Id, String>
    */
    global static Map<String, Id> invert(Map<Id, String> source) {
        Map<String, Id> r = new Map<String, Id>();
        for (Id s : source.keySet()) r.put(source.get(s), s);
        return r;
    }

    /**
    * inverts the map
    * @param source the source
    * @return Map<Id, String>
    */
    global static Map<Id, String> invert(Map<String, IdObj> source) {
        Map<Id, String> r = new Map<Id, String>();
        for (String s : source.keySet()) r.put(source.get(s).id, s);
        return r;
    }

    /**
    * inverts the map
    * @param source the source
    * @return Map<Id, IString>
    */
    global static Map<Id, IString> invert(Map<IString, IdObj> source) {
        Map<Id, IString> r = new Map<Id, IString>();
        for (IString s : source.keySet()) r.put(source.get(s).id, s);
        return r;
    }

    //#endregion

    //#region Dump

    /**
    * return all key values in a String
    * @param type the type 
    * @param args the args
    * @return String
    */
    global static String dump(Map<String, String> value) { return dump(null, value); }

    /**
    * return all key values in a String
    * @param type the type 
    * @param args the args
    * @return String
    */
    global static String dump(String prefix, Map<String, String> value) {
        if (value == null || value.isEmpty()) return 'null';
        List<String> r = new List<String>();
        if (prefix == null) for (String key : value.keySet()) r.add(String.format('{1}:{2}', new Object[] { key, value.get(key) }));
        else for (String key : value.keySet()) r.add(String.format('{0} {1}:{2}', new Object[] { prefix, key, value.get(key) }));
        return String.join(r, ',\n');
    }
    
    //#endregion
}