/*
* the Lookup
*/
global virtual class Lookup {
    global final static Lookup get = (Lookup)Core.getSingleton(Lookup.class);
    global Map<String, Schema.Location> locations;
    global Map<String, NamedCredential> namedCredentials;
    global Map<String, Pricebook2> pricebooks;
    global Map<String, RecordType> recordTypes;

    /**
    * remap the sources
    * @param type the type
    * @param sources the sources
    * @return Object
    */
    static Object remap(Integer type, List<SObject> sources) {
        switch on type {
            when 0 { Map<String, Schema.Location> r = new Map<String, Schema.Location>(); for (SObject z : sources) { Schema.Location s = (Schema.Location)z; r.put(s.LocationType + '.' + s.ExternalReference, s); } return r; }
            when 1 { Map<String, NamedCredential> r = new Map<String, NamedCredential>(); for (SObject z : sources) { NamedCredential s = (NamedCredential)z; r.put(s.DeveloperName, s); } return r; }
            when 2 { Map<String, Pricebook2> r = new Map<String, Pricebook2>(); for (SObject z : sources) { Pricebook2 s = (Pricebook2)z; r.put(s.Name, s); } return r; }
            when 3 { Map<String, RecordType> r = new Map<String, RecordType>(); for (SObject z : sources) { RecordType s = (RecordType)z; r.put(s.SObjectType + '.' + s.Name, s); } return r; }
            when else { throw new HandledException('Unknown ' + type); }
        }
    }
    
    /**
    * gets the location
    * @param reference the reference
    * @param throwOnAdd the throwOnAdd
    * @return Location
    */
    global virtual Schema.Location getLocation(String locationType, String reference, Boolean throwOnAdd) {
        String newReference = locationType + '.' + reference;
        if (locations == null) locations = (Map<String, Schema.Location>)remap(0, [SELECT Id, Name, ExternalReference, LocationType FROM Location]);
        if (reference == null || locations.containsKey(newReference)) return locations.get(newReference);
        if (throwOnAdd == true) throw new HandledException('Location: ' + newReference);
        Schema.Location r = new Schema.Location(Name = reference, ExternalReference = reference, LocationType = locationType);
        locations.put(newReference, r);
        Dml.upserts.add(r);
        return r;
    }

    /**
    * gets the named credential
    * @param reference the reference
    * @param throwOnAdd the throwOnAdd
    * @return NamedCredential
    */
    global virtual NamedCredential getNamedCredential(String reference, Boolean throwOnAdd) {
        if (namedCredentials == null) namedCredentials = (Map<String, NamedCredential>)remap(1, [SELECT Id, DeveloperName, MasterLabel FROM NamedCredential]);
        if (reference == 'first' && !namedCredentials.isEmpty()) return namedCredentials.values()[0];
        else if (reference == null || namedCredentials.containsKey(reference)) return namedCredentials.get(reference);
        if (throwOnAdd == true) throw new HandledException('NamedCredential: ' + reference);
        return null;
    }

    /**
    * gets the pricebook
    * @param reference the reference
    * @param throwOnAdd the throwOnAdd
    * @return Pricebook2
    */
    global virtual Pricebook2 getPricebook(String reference, Boolean throwOnAdd) {
        if (pricebooks == null) pricebooks = (Map<String, Pricebook2>)remap(2, [SELECT Id, Name, IsActive FROM Pricebook2]);
        if (reference == 'first' && !pricebooks.isEmpty()) return pricebooks.values()[0];
        else if (reference == null || pricebooks.containsKey(reference)) return pricebooks.get(reference);
        if (throwOnAdd == true || !Test.isRunningTest()) throw new HandledException('Pricebook: ' + reference);
        Pricebook2 r = new Pricebook2(Name = reference, IsActive = true);
        pricebooks.put(reference, r); r.Id = Test.getStandardPricebookId();
        return r;
    }

    /**
    * gets the record type
    * @param objectType the objectType
    * @param reference the reference
    * @param throwOnAdd the throwOnAdd
    * @return RecordType
    */
    global virtual RecordType getRecordType(String objectType, String reference, Boolean throwOnAdd) {
        String newReference = objectType + '.' + reference;
        if (recordTypes == null) recordTypes = (Map<String, RecordType>)remap(3, [SELECT Id, SObjectType, Name FROM RecordType]);
        if (reference == 'first' && !recordTypes.isEmpty()) return recordTypes.values()[0];
        else if (reference == null || recordTypes.containsKey(newReference)) return recordTypes.get(newReference);
        if (throwOnAdd == true) throw new HandledException('RecordType: ' + newReference);
        return null;
    }

    global void flush() { Dml.flush(); }
}
