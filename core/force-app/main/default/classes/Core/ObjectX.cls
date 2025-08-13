/**
* Object method extensions
*/
global class ObjectX {
    //#region Iterable

    /*
    * the groupat iterable
    */
    global class GroupAtIterable implements Iterable<List<Object>> {
        List<Object> source;
        Integer size;
        global GroupAtIterable(String query, Integer size) {
            if (size <= 0) throw new HandledException('Size must be greater than 0');
            this.source = source;
            this.size = size;
        }
        global System.Iterator<List<Object>> Iterator() { return new GroupAtIterator(source, size); }
    }

    /*
    * the groupat iterator
    */
    global class GroupAtIterator implements Iterator<List<Object>> {
        List<Object> source;
        Integer size;
        Integer index = 0;
        global GroupAtIterator(List<Object> source, Integer size) {
            if (size <= 0) throw new HandledException('Size must be greater than 0');
            this.source = source;
            this.size = size;
        }
        global Boolean hasNext() { return source != null && !source.isEmpty() && index < source.size(); }
        global List<Object> next() {
            Integer endx = math.min(this.index + this.size, source.size());
            List<Object> items = new List<Object>();
            for (; this.index < endx; this.index++) items.add(source[this.index]);
            return items;
        }
    }

    //#endregion

    //#region Untype

    static Map<Object, Map<String, Object>> untypeCache = new Map<Object, Map<String, Object>>();

    /**
    * gets a object's value
    * @param obj the Object
    * @return Object
    */
    global static Map<String, Object> untype(Object obj) {
        if (obj == null) return null;
        Map<String, Object> s = untypeCache.get(obj);
        if (s == null) {
            if (untypeCache.size() > 3) {
                untypeCache.clear();
                // Set<Object> ks = getCache.keySet();
                // for (Integer i = 3; i < ks.size(); i++) { getCache.remove(ks[i]); }
            }
            s = Core.options.untype(obj);
            untypeCache.put(obj, s);
        }
        return s;
    }

    //#endregion

    //#region Get / Set
    
    /**
    * gets a object's value
    * @param obj the Object
    * @param field the field
    * @return Object
    */
    global static Object get(Object obj, String field) {
        if (obj == null) return null;
        else if (obj instanceof Map<String, Object>) return MapX.get((Map<String, Object>)obj, field);
        else if (obj instanceof SObject) return SObjectX.get((SObject)obj, field);
        Map<String, Object> s = Core.options.untype(obj);
        String[] arg = field.split('\\.', 2);
        return arg.size() > 1
             ? get(s.get(arg[0]), arg[1])
             : s.get(field);
    }

    /**
    * gets a sobject's value
    * @param obj the SObject
    * @param field the field
    * @param modifier the modifier
    * @return Object
    */
    global static Object get(Object obj, String field, String modifier) {
        return Core.options.funcValue(field.startsWith('.') ? Core.options.funcGlobal(field.substring(1)) : get(obj, field), modifier);
    }

    /**
    * gets all sobject's values
    * @param fields the fields
    * @return Map<String, Object>
    */
    global static Map<String, Object> get(Object obj, List<String> fields) {
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
    global static Object put(Object obj, String field, Object value) {
        if (obj == null) return null;
        else if (obj instanceof Map<String, Object>) return MapX.put((Map<String, Object>)obj, field, value);
        else if (obj instanceof SObject) return SObjectX.put((SObject)obj, field, value);
        String[] arg = field.split('\\.', 2);
        throw new HandledException('Not Implemented');
        // return arg.size() > 1
        //     ? put(obj.getSObject(arg[0]), arg[1], value)
        //     : Core.throwx('Invalid');
    }

    /**
    * sets all sobject's values
    * @param obj the SObject
    * @param values the values
    * @return SObject
    */
    global static Object put(Object obj, Map<String, Object> values) {
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
    * @return List<List<Object>>
    */
    global static List<List<Object>> groupAt(List<Object> source, Integer size) {
        if (size <= 0) throw new HandledException('Size must be greater than 0');
        List<List<Object>> r = new List<List<Object>>();
        if (source == null || source.isEmpty()) return r;
        Integer index = 0; List<Object> items = new List<Object>();
        for (Object s : source) {
            items.add(s);
            if (++index != size) continue;
            r.add(items);
            index = 0; items = new List<Object>();
        }
        if (items.size() > 0) r.add(items);
        return r;
    }

    //#endregion

    //#region Merge

    /**
    * merges a object and its values
    * @param obj the Object
    * @param value the value
    * @return Object
    */
    global static Object mergex(Object obj, Object value) {
        if (!(value instanceOf String && ((String)value).contains('{{'))) return value;
        List<String> r = ((String)value).replace('}}', '{{').split('\\{\\{');
        Integer partsSize = r.size(); Object v; String k, f;
        if (obj instanceof List<SObject>) {
            List<SObject> s = (List<SObject>)obj;
            if (partsSize == 2) {
                k = r[1].substringBefore(':'); f = r[1].substringAfter(':'); v = SObjectX.get(s[k != '' ? Integer.valueOf(k) : 0], f.substringBefore(';'), f.substringAfter(';')); return r[0] == '' ? v : r[0] + String.valueOf(v ?? '');
            }
            for (Integer i = 0; i < partsSize - 1; i += 2) {
                k = r[i + 1].substringBefore(':'); f = r[i + 1].substringAfter(':'); v = SObjectX.get(s[k != '' ? Integer.valueOf(k) : 0], f.substringBefore(';'), f.substringAfter(';')); r[i + 1] = String.valueOf(v ?? '');
            }
        }
        else if (obj instanceof List<Map<String, Object>>) {
            List<Map<String, Object>> s = (List<Map<String, Object>>)obj;
            if (partsSize == 2) {
                k = r[1].substringBefore(':'); f = r[1].substringAfter(':'); v = MapX.get(s[k != '' ? Integer.valueOf(k) : 0], f.substringBefore(';'), f.substringAfter(';')); return r[0] == '' ? v : r[0] + String.valueOf(v ?? '');
            }
            for (Integer i = 0; i < partsSize - 1; i += 2) {
                k = r[i + 1].substringBefore(':'); f = r[i + 1].substringAfter(':'); v = MapX.get(s[k != '' ? Integer.valueOf(k) : 0], f.substringBefore(';'), f.substringAfter(';')); r[i + 1] = String.valueOf(v ?? '');
            }
        }
        else if (obj instanceof List<Object>) {
            List<Object> s = (List<Object>)obj;
            if (partsSize == 2) {
                k = r[1].substringBefore(':'); f = r[1].substringAfter(':'); v = ObjectX.get(s[k != '' ? Integer.valueOf(k) : 0], f.substringBefore(';'), f.substringAfter(';')); return r[0] == '' ? v : r[0] + String.valueOf(v ?? '');
            }
            for (Integer i = 0; i < partsSize - 1; i += 2) {
                k = r[i + 1].substringBefore(':'); f = r[i + 1].substringAfter(':'); v = ObjectX.get(s[k != '' ? Integer.valueOf(k) : 0], f.substringBefore(';'), f.substringAfter(';')); r[i + 1] = String.valueOf(v ?? '');
            }
        }
        else if (obj instanceof SObject) {
            SObject s = (SObject)obj;
            if (partsSize == 2) {
                f = r[1]; v = SObjectX.get(s, f.substringBefore(';'), f.substringAfter(';')); return r[0] == '' ? v : r[0] + String.valueOf(v ?? '');
            }
            for (Integer i = 0; i < partsSize - 1; i += 2) {
                f = r[i + 1]; v = SObjectX.get(s, f.substringBefore(';'), f.substringAfter(';')); r[i + 1] = String.valueOf(v ?? '');
            }
        }
        else if (obj instanceof Map<String, Object>) {
            Map<String, Object> s = (Map<String, Object>)obj;
            if (partsSize == 2) {
                f = r[1]; v = MapX.get(s, f.substringBefore(';'), f.substringAfter(';')); return r[0] == '' ? v : r[0] + String.valueOf(v ?? '');
            }
            for (Integer i = 0; i < partsSize - 1; i += 2) {
                f = r[i + 1]; v = MapX.get(s, f.substringBefore(';'), f.substringAfter(';')); r[i + 1] = String.valueOf(v ?? '');
            }
        }
        else {
            Object s = (Object)obj;
            if (partsSize == 2) {
                f = r[1]; v = ObjectX.get(s, f.substringBefore(';'), f.substringAfter(';')); return r[0] == '' ? v : r[0] + String.valueOf(v ?? '');
            }
            for (Integer i = 0; i < partsSize - 1; i += 2) {
                f = r[i + 1]; v = ObjectX.get(s, f.substringBefore(';'), f.substringAfter(';')); r[i + 1] = String.valueOf(v ?? '');
            }
        }
        return String.join(r, '');
    }

    //#endregion
}