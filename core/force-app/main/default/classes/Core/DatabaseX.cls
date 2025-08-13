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
}
