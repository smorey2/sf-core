/**
* List method extensions
*/
global class ListX {
    //#region Transpose

    /**
    * gets the sobject's ids
    * @param objs the IdObjs
    * @return List<Id>
    */
    global static List<Id> getIds(List<IdObj> objs) {
        List<Id> r = new List<Id>();
        for (IdObj s : objs) r.add(s.Id);
        return r;
    }

    /**
    * gets the sobject's ids
    * @param objs the SObjects
    * @return List<Id>
    */
    global static List<Id> getIds(List<SObject> objs) {
        List<Id> r = new List<Id>();
        for (SObject s : objs) r.add(s.Id);
        return r;
    }
    
    /**
    * gets the sobject's ids
    * @param objs the SObjects
    * @param field the field
    * @return List<Id>
    */
    global static List<Id> getIds(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        List<Id> r = new List<Id>();
        if (fast) for (SObject s : objs) r.add((Id)s.get(field));
        else for (SObject s : objs) r.add((Id)SObjectX.get(s, field));
        return r;
    }

    /**
    * gets the sobject's strings
    * @param objs the SObjects
    * @param field the field
    * @return List<String>
    */
    global static List<String> getStrings(List<SObject> objs, String field) {
        Boolean fast = !field.contains('.');
        List<String> r = new List<String>();
        if (fast) for (SObject s : objs) r.add((String)s.get(field));
        else for (SObject s : objs) r.add((String)SObjectX.get(s, field));
        return r;
    }
    
    //#endregion
}