/**
* Database method extensions
*/
global class DatabaseX {
    /**
    * updatex
    * @param mergex the mergex
    * @param scope the scope
    * @param allOrNone specifies if all or nothing
    */
    global static void updatex(String mergex, List<SObject> scope, Boolean allOrNone) {
        if (mergex == null || scope == null) { Database.update(scope, allOrNone); return; }
        List<List<SObject>> scopes;
        switch on mergex {
            when 'first' {
                Map<Id, SObject> t = new Map<Id, SObject>();
                for (SObject s : scope) {
                    if (s.Id == null) throw new HandledException('Null Id in SObject: ' + s);
                    if (!t.containsKey(s.Id)) t.put(s.Id, s);
                }
                scopes = new List<List<SObject>> { t.values() };
            }
            when 'last' {
                Map<Id, SObject> t = new Map<Id, SObject>();
                for (SObject s : scope) {
                    if (s.Id == null) throw new HandledException('Null Id in SObject: ' + s);
                    t.put(s.Id, s);
                }
                scopes = new List<List<SObject>> { t.values() };
            }
            when 'all' {
                Integer c; List<SObject> v;
                Map<Id, Integer> t = new Map<Id, Integer>();
                scopes = new List<List<SObject>>();
                for (SObject s : scope) {
                    if (s.Id == null) throw new HandledException('Null Id in SObject: ' + s);
                    t.put(s.Id, c = (t.get(s.Id) ?? -1) + 1);
                    if (scopes.size() == c) scopes.add(new List<SObject>());
                    scopes[c].add(s);
                }
            }
            when else { throw new HandledException('Unknown mergex: ' + mergex); }
        }
        for (List<SObject> s : scopes) { s.sort(); Database.update(s, allOrNone); }
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

    /*
    * the query
    */
    global class Query {
        global List<String> fields = new List<String>();
        global String fromx;
        global String query;
        global String action;
        global Integer keyAt;
        global Query(List<String> source) {
            List<String> ws = new List<String>(), es = new List<String>();
            for (String f : source) {
                if (f.startsWithIgnoreCase('#')) fromx = f.substringAfter('#');
                else if (f.startsWithIgnoreCase('+')) action = f.substringAfter('+');
                else if (f.startsWithIgnoreCase(':')) ws.add(f.substringAfter(':'));
                else if (f.startsWithIgnoreCase('in:')) { ws.add('IN'); ws.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('and:')) { ws.add('AND'); ws.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('or:')) { ws.add('OR'); ws.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('and(:')) { ws.add('AND'); ws.add('('); ws.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('or(:')) { ws.add('OR'); ws.add('('); ws.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('):')) { ws.add(')'); ws.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('groupby:')) { es.add('GROUP BY'); es.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('having:')) { es.add('HAVING'); es.add(f.substringAfter(':')); }
                else if (f.startsWithIgnoreCase('limit:')) { es.add('LIMIT'); es.add(f.substringAfter(':')); }
                else fields.add(f);
            }
            String[] vs = new String[] { 'SELECT', String.join(fields, ', '), 'FROM', fromx };
            if (!ws.isEmpty()) { ws[0] = 'WHERE'; vs.addAll(ws); }
            if (!es.isEmpty()) vs.addAll(es);
            query = String.join(vs, ' ');
            keyAt = 0;
        }

        /**
        * to string
        * @return String
        */
        global override String toString() { return query; }

        global String keyField {
            get { return fields[keyAt]; }
        }

        /**
        * rel
        * @param source the source
        * @return SObject
        */
        global SObject rel(SObject source) {
            return source;
        }

        /**
        * get
        * @param source the source
        * @param index the index
        * @param modifier the modifier
        * @return Object
        */
        global Object get(SObject source, Integer index, String modifier) {
            String keyField = fields[index == -1 ? keyAt : index]; Boolean fast = modifier == null && !keyField.contains('.');
            return fast ? source.get(keyField) : SObjectX.get(source, keyField, modifier);
        }

        /**
        * get
        * @param source the source
        * @param index the index
        * @param modifier the modifier
        * @return Set<Object>
        */
        global Set<Object> get(List<SObject> source, Integer index, String modifier) {
            String keyField = fields[index == -1 ? keyAt : index]; Boolean fast = modifier == null && !keyField.contains('.');
            Set<Object> r = new Set<Object>();
            for (SObject s : source) r.add(fast ? s.get(keyField) : SObjectX.get(s, keyField, modifier));
            return r;
        }

        /**
        * queries the sobjects
        * @return List<SObject>
        */
        global List<SObject> query() { return Database.query(query); }
        /**
        * queries the sobjects by keys
        * @param keys the keys
        * @return List<SObject>
        */
        global List<SObject> query(List<String> keys) { return Database.query(query); }
        /**
        * queries the sobjects by keys
        * @param keys the keys
        * @return List<SObject>
        */
        global List<SObject> query(Set<String> keys) { return Database.query(query); }
        /**
        * queries the sobjects by keys
        * @param keys the keys
        * @return List<SObject>
        */
        global List<SObject> query(List<Id> keys) { return Database.query(query); }
        /**
        * queries the sobjects by keys
        * @param keys the keys
        * @return List<SObject>
        */
        global List<SObject> query(Set<Id> keys) { return Database.query(query); }
    }
}
