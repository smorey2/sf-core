/*
* the Dml library
*/
global class Dml {
    global static List<SObject> updates = new List<SObject>(), inserts = new List<SObject>();
    global static List<SObject> deletes = new List<SObject>(), upserts = new List<SObject>();
    global static Map<Id, SObject> updatex;

    /**
    * clears the dmls
    */
    global static void clear() {
        updates.clear(); inserts.clear();
        deletes.clear(); upserts.clear();
        updatex?.clear();
    }

    /**
    * flushs the dmls
    */
    global static void flush() { flush(null, true); }
    /**
    * flushs the dmls
    * @param mergex the mergex
    */
    global static void flush(String mergex) { flush(mergex, true); }
    /**
    * flushs the dmls
    * @param mergex the mergex
    * @param allOrNothing the allOrNothing
    */
    global static void flush(String mergex, Boolean allOrNothing) {
        if (!deletes.isEmpty()) { deletes.sort(); Database.delete(deletes, allOrNothing); deletes.clear(); }
        if (!updates.isEmpty()) { updates.sort(); if (mergex == null) Database.update(updates, allOrNothing); else DatabaseX.updatex(mergex, updates, allOrNothing); updates.clear(); }
        if (!inserts.isEmpty()) { inserts.sort(); Database.insert(inserts, allOrNothing); inserts.clear(); }
        if (!upserts.isEmpty()) { upserts.sort(); Database.upsert(upserts, allOrNothing); upserts.clear(); }
        if (updatex != null && !updatex.isEmpty()) { Database.update(updatex.values(), allOrNothing); updatex.clear(); }
    }

    /**
    * updates an sobject
    * @param source the source
    * @return SObject
    */
    global static SObject updatex(SObject source) {
        if (updatex == null) updatex = new Map<Id, SObject>();
        Id id = source.Id;
        if (id == null) throw new HandledException('updatex id null');
        else if (!updatex.containsKey(id)) { updatex.put(id, source); return source; }
        return updatex.get(id);
    }
}
