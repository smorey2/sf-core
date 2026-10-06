/*
* the AccountFactory
*/
global virtual class AccountFactory {
    global static AccountFactory get = (AccountFactory)Core.getSingleton(AccountFactory.class);

    //#region Interface

    /*
    * the IAccount
    */
    global interface IAccount {
        /**
        * gets the account options
        * @return Tuple2
        */
        Tuple2 getAccountOptions();
        /**
        * gets the account key
        * @return IString
        */
        IString getAccountKey();
        /**
        * gets the account tags
        * @param method the method
        * @param keys the keys
        * @return Map<IString, Object>
        */
        Map<IString, Object> getAccountTags(String method, Set<String> keys);

        // Account
        /**
        * gets the account
        * @param key the key
        * @param tags the tags
        * @return Account
        */
        Account getAccount(IString key, Map<IString, Object> tags);
    }

    /*
    * the IAccountCustom
    */
    global interface IAccountCustom extends IAccount {
        /**
        * customizes the account
        * @param accounts the accounts
        * @param sources the sources
        * @param updates the updates
        * @param inserts the inserts
        */
        void customAccount(Map<IString, IdObj> accounts, Map<IString, Object[]> sources, List<Account> updates, List<Account> inserts);
    }

    /*
    * the IAccountMerge
    */
    global interface IAccountMerge extends IAccount {
        /**
        * merges the account
        * @param record the record
        * @param prior the prior
        * @return Account
        */
        Account mergeAccount(Account record, Account prior);
    }

    /*
    * the IAccountUpsert
    */
    global interface IAccountUpsert extends IAccount {
        /**
        * updates the account
        * @param record the record
        * @param prior the prior
        * @return Account
        */
        Account updateAccount(Account record, Account prior);
        /**
        * inserts the account
        * @param record the record
        * @return Account
        */
        Account insertAccount(Account record);
    }

    //#endregion

    /**
    * Creates the accounts
    * @param log the log
    * @param sources the sources
    * @return Map<String, IdObj>
    */
    global virtual Map<IString, IdObj> createAccounts(Logger log, List<Object> sources) {
        // get sources
        if (sources.isEmpty() || !(sources[0] instanceof IAccount)) return new Map<IString, IdObj>();
        log?.logInfo('accounts #' + sources.size());

        // get first source
        IAccount first = ((IAccount)sources[0]);

        // get options
        Tuple2 o = (Tuple2)first.getAccountOptions() ?? new Tuple2(null, null);
        DatabaseX.Query accountQuery = (DatabaseX.Query)o.item1;
        Object accountArg = o.item2;

        // get tags
        Set<String> keys = new Set<String>();
        for (Object s : sources) keys.add(((IAccount)s).getAccountKey()?.str);
        Map<IString, Object> tags = first.getAccountTags('create', keys);

        // get/add accounts
        return addAccounts(log, getAccounts(sources, tags), accountQuery, accountArg);
    }

    /**
    * adds the accounts
    * @param log the log
    * @param sources the sources
    * @param fields the fields
    * @param arg the arg
    * @return Map<IString, IdObj>
    * @see keyFields: PersonEmail, AccountNumber
    */
    global virtual Map<IString, IdObj> addAccounts(Logger log, Map<IString, Object[]> sources, DatabaseX.Query query, Object arg) {
        SystemX.debug('addAccounts: ' + sources.size());
        Map<IString, IdObj> r = new Map<IString, IdObj>();
        if (sources.isEmpty()) return r;

        // values
        List<Account> updates = new List<Account>(), inserts = new List<Account>(); Set<IString> removeKeys = new Set<IString>();
        query = query ?? new DatabaseX.Query(new String[] { UserInfoX.isPersonAccountOrganization() ? 'PersonEmail' : 'Name', '#Account' });
        String keyField = query.keyField; Boolean fast = !keyField.contains('.');
        Object last;

        // get existing accounts
        for (SObject q : query.query(IString.set(sources.keySet()))) {
            Account s = (Account)query.rel(q);
            IString key = new IString(fast ? s.get(keyField) : SObjectX.get(s, keyField));
            Object[] z = sources.get(key); removeKeys.add(key);
            if (z == null) throw new HandledException('Unable to update Account: ' + key);
            Account n = (Account)z[0]; n.Id = s.Id;

            // account exists
            log?.logInfo(s.Id, 'account exists: ' + key);
            Object source = last = z[1];
            if (source instanceof IAccountUpsert) { n = ((IAccountUpsert)source).updateAccount(n, s); if (n != null) updates.add(n); }
            r.put(key, new IdObj(s.Id, source));
        }
        for (IString key : removeKeys) sources.remove(key);

        // deconstruct sources
        for (Object[] z : sources.values()) {
            Account n = (Account)z[0];
            Object source = last = z[1];
            if (source instanceof IAccountUpsert) { n = ((IAccountUpsert)source).insertAccount(n); if (n != null) inserts.add(n); }
            else inserts.add(n);
        }
        
        // update accounts
        if (!updates.isEmpty()) DatabaseX.updatex('all', updates, true);

        // insert accounts + contacts
        if (!inserts.isEmpty()) {
            Database.insert(inserts, true);
            for (Account s : inserts) {
                IString key = new IString(fast ? s.get(keyField) : SObjectX.get(s, keyField));
                log?.logInfo(s.Id, 'account inserted: ' + key);
                Object x = sources.get(key)[1];
                r.put(key, new IdObj(s.Id, x));
            }
        }

        // account customized
        if (last instanceof IAccountCustom) ((IAccountCustom)last).customAccount(r, sources, updates, inserts);

        sources.clear();
        return r;
    }

    /**
    * gets the accounts
    * @param sources the sources
    * @param tags the tags
    * @return Map<IString, Object[]>
    */
    global virtual Map<IString, Object[]> getAccounts(List<Object> sources, Map<IString, Object> tags) {
        Map<IString, Object[]> r = new Map<IString, Object[]>();
        if (sources.isEmpty()) return r;

        // add sources
        for (Object z : sources) {
            IAccount s = (IAccount)z;
            IString key = s.getAccountKey();
            if (IString.isEmpty(key)) { SystemX.debug('Skipping keyless account: ' + s); continue; }

            // add value
            Object[] value = new Object[] { s.getAccount(key, tags), s };
            if (r.containsKey(key))
                if (s instanceof IAccountMerge) value[0] = ((IAccountMerge)s).mergeAccount((Account)value[0], (Account)r.get(key)[0]);
                else throw new HandledException('Account duplicate: ' + key);
            r.put(key, value);
        }
        return r;
    }
}
