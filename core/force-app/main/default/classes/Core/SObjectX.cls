/**
* Object method extensions
*/
global class SObjectX {
    //#region Iterable

    /*
    * the groupat iterable
    */
    global class GroupAtIterable implements Iterable<List<SObject>> {
        List<SObject> source;
        Integer size;
        global GroupAtIterable(String query, Integer size) {
            if (size <= 0) throw new HandledException('Size must be greater than 0');
            this.source = source;
            this.size = size;
        }
        global System.Iterator<List<SObject>> Iterator() { return new GroupAtIterator(source, size); }
    }

    /*
    * the groupat iterator
    */
    global class GroupAtIterator implements Iterator<List<SObject>> {
        List<SObject> source;
        Integer size;
        Integer index = 0;
        global GroupAtIterator(List<SObject> source, Integer size) {
            if (size <= 0) throw new HandledException('Size must be greater than 0');
            this.source = source;
            this.size = size;
        }
        global Boolean hasNext() { return source != null && !source.isEmpty() && index < source.size(); }
        global List<SObject> next() {
            Integer endx = math.min(this.index + this.size, source.size());
            List<SObject> items = new List<SObject>();
            for (; this.index < endx; this.index++) items.add(source[this.index]);
            return items;
        }
    }

    /*
    * the sobject iterable
    */
    global class QueryIterable implements Iterable<SObject> {
        String query;
        global QueryIterable(String query) { this.query = query; }
        global System.Iterator<SObject> Iterator() { return new QueryIterator(query); }
    }
 
    /*
    * the sobject iterator
    */
    global class QueryIterator implements Iterator<SObject> {
        SObject[] results; Integer index;
        global QueryIterator(String query) { results = Database.query(query); index = 0; }
        global Boolean hasNext() { return results != null && !results.isEmpty() && index < results.size(); }
        global SObject next() { return results[index++]; }
    }

    //#endregion

    //#region Get / Set

    /**
    * gets a sobject's value
    * @param obj the SObject
    * @param field the field
    * @return Object
    */
    global static Object get(SObject obj, String field) {
        if (obj == null) return null;
        String[] arg = field.split('\\.', 2);
        return arg.size() > 1
            ? get(obj.getSObject(arg[0]), arg[1])
            : obj.get(field);
    }

    /**
    * gets a sobject's value
    * @param obj the SObject
    * @param field the field
    * @param modifier the modifier
    * @return Object
    */
    global static Object get(SObject obj, String field, String modifier) {
        return Core.options.funcValue(field.startsWith('.') ? Core.options.funcGlobal(field.substring(1)) : get(obj, field), modifier);
    }

    /**
    * gets all sobject's values
    * @param fields the fields
    * @return Map<String, Object>
    */
    global static Map<String, Object> get(SObject obj, List<String> fields) {
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
    global static Object put(SObject obj, String field, Object value) {
        if (obj == null) return null;
        String[] arg = field.split('\\.', 2);
        return arg.size() > 1
            ? put(obj.getSObject(arg[0]), arg[1], value)
            : obj.put(field, value);
    }

    /**
    * sets all sobject's values
    * @param obj the SObject
    * @param values the values
    * @return SObject
    */
    global static SObject put(SObject obj, Map<String, Object> values) {
        if (obj == null) return null;
        for (String field : values.keySet()) put(obj, field, values.get(field));
        return obj;
    }

    //#endregion

    //#region GroupAt

    /**
    * groups source at size
    * @param source the source
    * @param size the size
    * @return List<List<SObject>>
    */
    global static List<List<SObject>> groupAt(List<SObject> source, Integer size) {
        if (size <= 0) throw new HandledException('Size must be greater than 0');
        List<List<SObject>> r = new List<List<SObject>>();
        if (source == null || source.isEmpty()) return r;
        Integer index = 0; List<SObject> items = new List<SObject>();
        for (SObject s : source) {
            items.add(s);
            if (++index != size) continue;
            r.add(items);
            index = 0; items = new List<SObject>();
        }
        if (items.size() > 0) r.add(items);
        return r;
    }

    //#endregion

    //#region Multi-Select

    /**
    * adds the values to the existing multi-select values
    * @param obj the Object
    * @param field the field
    * @param value the value
    * @return Object
    */
    global static String multiSelectValues(SObject obj, String field, List<String> addValues) {
        Set<String> r = new Set<String>(((String)ObjectX.get(obj, field))?.split(';') ?? new String[] { });
        r.addAll(addValues);
        return String.join(r, ';');
    }

    /**
    * adds the values to the existing multi-select values
    * @param values the fievaluesldValues
    * @param addValues the values
    * @return Object
    */
    global static String multiSelectValues(String values, String addValues) {
        Set<String> r = new Set<String>(values?.split(';') ?? new String[] { });
        if (String.isNotEmpty(addValues)) r.addAll(addValues.split(';'));
        return String.join(r, ';');
    }

    //#endregion
}