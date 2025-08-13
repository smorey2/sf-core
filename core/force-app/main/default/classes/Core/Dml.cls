/*
* the Dml library
*/
global class Dml {
    global static List<SObject> deletes = new List<SObject>();
    global static List<SObject> updates = new List<SObject>();
    global static List<SObject> inserts = new List<SObject>();
    global static List<SObject> upserts = new List<SObject>();
    global static Boolean allOrNothing = true;
    global static String mergex;

    /**
    * clears the dmls
    */
    global static void clear() {
        deletes.clear();
        updates.clear();
        inserts.clear();
        upserts.clear();
    }

    /**
    * flushs the dmls
    */
    global static void flush() {
        if (!deletes.isEmpty()) { deletes.sort(); Database.delete(deletes, allOrNothing); deletes.clear(); }
        if (!updates.isEmpty()) { updates.sort(); if (mergex == null) Database.update(updates, allOrNothing); else DatabaseX.updatex(mergex, updates, allOrNothing); updates.clear(); }
        if (!inserts.isEmpty()) { inserts.sort(); Database.insert(inserts, allOrNothing); inserts.clear(); }
        if (!upserts.isEmpty()) { upserts.sort(); Database.upsert(upserts, allOrNothing); upserts.clear(); }
    }
}
