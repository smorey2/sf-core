/**
* Set extensions
*/
global class SetX {
    /**
    * gets the sobject's ids as set
    * @param objs the IdObjs
    * @return Set<Id>
    */
    global static Set<Id> getIds(List<IdObj> objs) {
        Set<Id> r = new Set<Id>();
        for (IdObj s : objs) r.add(s.Id);
        return r;
    }
    /**
    * gets the sobject's ids as set
    * @param objs the SObjects
    * @return Set<Id>
    */
    global static Set<Id> getIds(List<SObject> objs) {
        Set<Id> r = new Set<Id>();
        for (SObject s : objs) r.add(s.Id);
        return r;
    }
    /**
    * gets the sobject's ids as set
    * @param objs the SObjects
    * @param field the field
    * @return Set<Id>
    */
    global static Set<Id> getIds(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        Set<Id> r = new Set<Id>();
        if (fast) for (SObject s : objs) r.add((Id)s.get(field));
        else for (SObject s : objs) r.add((Id)SObjectX.get(s, field));
        return r;
    }

    /**
    * gets the sobject's strings as set
    * @param objs the SObjects
    * @return Set<String>
    */
    global static Set<String> getStrings(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        Set<String> r = new Set<String>();
        if (fast) for (SObject s : objs) r.add((String)s.get(field));
        else for (SObject s : objs) r.add((String)SObjectX.get(s, field));
        return r;
    }
}