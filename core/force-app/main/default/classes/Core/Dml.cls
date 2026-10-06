/*
* the Dml library
*/
global class Dml {
    global static List<SObject> deletes = new List<SObject>(), upserts = new List<SObject>();

    /**
    * clears the dmls
    */
    global static void clear() {
        deletes.clear(); upserts.clear();
    }

    /**
    * flushs the dmls
    */
    global static void flush() { flush(true); }
    /**
    * flushs the dmls
    * @param allOrNothing the allOrNothing
    */
    global static void flush(Boolean allOrNothing) {
        if (!deletes.isEmpty()) { deletes.sort(); Database.delete(deletes, allOrNothing); deletes.clear(); }
        if (!upserts.isEmpty()) { upserts.sort(); Database.upsert(upserts, allOrNothing); upserts.clear(); }
    }
}
