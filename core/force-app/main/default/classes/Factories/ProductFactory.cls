/*
* the ProductFactory
*/
global virtual class ProductFactory {
    global static ProductFactory get = (ProductFactory)Core.getSingleton(ProductFactory.class);
    static final Lookup lookupx = Lookup.get;
    
    //#region Interfaces

    /*
    * the IProductContainer
    */
    global interface IProductContainer {
        /**
        * gets the products
        * @return List<Object>
        */
        List<Object> getProducts();
    }

    /*
    * the IProduct
    */
    global interface IProduct {
        /**
        * gets the product options
        * @return Tuple2
        */
        Tuple2 getProductOptions();
        /**
        * gets the product key
        * @return IString
        */
        IString getProductKey();
        /**
        * gets the product tags
        * @param method the method
        * @param keys the keys
        * @return Map<String, Object>
        */
        Map<IString, Object> getProductTags(String method, Set<String> keys);

        // Product
        /**
        * gets the product
        * @param key the key
        * @param pricebook2Id the pricebook2Id
        * @param tags the tags
        * @return Tuple2
        */
        Tuple2 getProduct(IString key, Id pricebook2Id, Map<IString, Object> tags);
    }

    /*
    * the IProductCustom
    */
    global interface IProductCustom extends IProduct {
        /**
        * customizes the product
        * @param sources the sources
        * @param updates the updates
        * @param inserts the inserts
        */
        void customProduct(Map<IString, Object[]> sources, List<Product2> updates, List<Product2> inserts);
    }

    /*
    * the IProductMerge
    */
    global interface IProductMerge extends IProduct {
        /**
        * merges the product
        * @param record the record
        * @param prior the prior
        * @return Product2
        */
        Product2 mergeProduct(Product2 record, Product2 prior);
    }

    /*
    * the IProductMerge2
    */
    global interface IProductMerge2 extends IProduct {
        /**
        * merges the product
        * @param record the record
        * @param prior the prior
        * @return Tuple2
        */
        Tuple2 mergeProduct(Tuple2 record, Tuple2 prior);
    }

    /*
    * the IProductUpsert
    */
    global interface IProductUpsert extends IProduct {
        /**
        * updates the product
        * @param record the record
        * @param prior the prior
        * @return Product2
        */
        Product2 updateProduct(Product2 record, Product2 prior);
        /**
        * inserts the product
        * @param record the record
        * @return Product2
        */
        Product2 insertProduct(Product2 record);
    }

    //#endregion

    /**
    * Creates the products
    * @param log the log
    * @param sources the sources
    * @param extraProducts the extraProducts
    * @return Map<IString, Tuple3>
    */
    global virtual Map<IString, Tuple3> createProducts(Logger log, List<Object> sources, List<String> extraProducts) {
        // get sources
        if (sources.isEmpty() || !(sources[0] instanceof IProductContainer)) return new Map<IString, Tuple3>();
        log?.logInfo('products #' + sources.size());

        // get first
        IProductContainer first = ((IProductContainer)sources[0]);
        IProduct product = ((IProduct)first.getProducts()[0]);

        // get options
        Tuple2 o = (Tuple2)product.getProductOptions() ?? new Tuple2(null, null);
        DatabaseX.Query productQuery = (DatabaseX.Query)o.item1;
        Object productArg = o.item2;

        // get tags
        Set<String> keys = new Set<String>();
        // for (Object s : sources) { keys.add(((IProduct)s).getProductKey()?.s); }
        Map<IString, Object> tags = product.getProductTags('create', keys);

        // get/add products
        Pricebook2 pricebook = lookupx.getPricebook('Standard Price Book', false);
        Map<IString, Object[]> newSources = getProducts(sources, tags, pricebook.Id);
        newSources.putAll(getProducts(extraProducts, pricebook.Id));
        return addProducts(log, newSources, productQuery, productArg);
    }

    /**
    * adds the products
    * @param log the log
    * @param sources the sources
    * @param fields the fields
    * @param arg the arg
    * @return Map<IString, Tuple3>
    * @see keyFields: ProductCode, StockKeepingUnit
    */
    global virtual Map<IString, Tuple3> addProducts(Logger log, Map<IString, Object[]> sources, DatabaseX.Query query, Object arg) {
        Map<IString, Tuple3> r = new Map<IString, Tuple3>();
        if (sources.isEmpty()) return r;

        // values
        List<Product2> updates = new List<Product2>(), inserts = new List<Product2>(); Set<IString> removeKeys = new Set<IString>();
        List<PricebookEntry> pricebookUpdates = new List<PricebookEntry>();
        Set<IString> pricebookOnlys = new Set<IString>();
        query = query ?? new DatabaseX.Query(new String[] { 'ProductCode', '#Product2' });
        query.fields.add('(SELECT Id, IsActive FROM PricebookEntries ORDER BY IsActive)');
        String keyField = query.keyField; Boolean fast = !keyField.contains('.');

        // get existing products
        for (SObject q : query.query(IString.set(sources.keySet()))) {
            Product2 s = (Product2)query.rel(q);
            IString key = new IString(fast ? s.get(keyField) : SObjectX.get(s, keyField));
            Object[] z = sources.get(key); removeKeys.add(key);
            if (z == null) throw new HandledException('Unable to update Product2: ' + key);
            Tuple2 t = (Tuple2)z[0];
            Product2 n = (Product2)t.item1; n.Id = s.Id;

            // product exists
            log?.logInfo(s.Id, 'product exists: ' + key);
            Object source = z[1];
            if (source instanceof IProductUpsert) { n = ((IProductUpsert)source).updateProduct(n, s); if (n != null) updates.add(n); }
            // price book
            PricebookEntry pe = s.PricebookEntries.isEmpty() ? null : s.PricebookEntries[0];
            if (pe == null) { 
                log?.logInfo(s.Id, 'product semi-exists: ' + key);
                pricebookOnlys.add(key);
                continue;
            }
            else if (pe.IsActive == false) pricebookUpdates.add(new PricebookEntry(Id = pe.Id, IsActive = true));
            if (s.PricebookEntries.size() > 1) throw new HandledException('Multiple: PricebookEntries ' + key);
            r.put(key, new Tuple3(s.Id, pe.Id, source));
        }
        for (IString key : removeKeys) sources.remove(key);

        // reactivate pricebook entries
        if (!pricebookUpdates.isEmpty()) Database.update(pricebookUpdates, true);

        // deconstruct sources
        Object last;
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Object[] z : sources.values()) {
            Tuple2 s = (Tuple2)z[0];
            if (s == null) continue;
            Product2 n = (Product2)s.item1;
            IString key = new IString(fast ? n.get(keyField) : SObjectX.get(n, keyField));
            Object source = last = z[1];

            // pricebook only
            if (pricebookOnlys.contains(key)) ((PricebookEntry)s.item2).Product2Id = n.Id;
            else {
                if (source instanceof IProductUpsert) { n = ((IProductUpsert)source).insertProduct(n); if (n != null) inserts.add(n); }
                else inserts.add(n);
            }
            pricebookEntries.add((PricebookEntry)s.item2);
        }

        // product updated
        if (!updates.isEmpty()) {
            Database.update(updates, true);
            for (Product2 s : updates) {
                IString key = new IString(fast ? s.get(keyField) : SObjectX.get(s, keyField));
                log?.logInfo(s.Id, 'product updated: ' + key);
            }
        }

        // product inserted
        if (!inserts.isEmpty()) {
            Database.insert(inserts, true);
            for (Product2 s : inserts) {
                IString key = new IString(fast ? s.get(keyField) : SObjectX.get(s, keyField));
                // update reference
                Tuple2 k = (Tuple2)sources.get(key)[0];
                ((PricebookEntry)k.item2).Product2Id = s.Id;
            }
        }
        if (!pricebookEntries.isEmpty()) {
            Database.insert(pricebookEntries, true);
        }
        for (Object[] value : sources.values()) {
            Tuple2 s = (Tuple2)value[0];
            Product2 p = (Product2)s.item1;
            PricebookEntry pe = (PricebookEntry)s.item2;
            IString key = new IString(fast ? p.get(keyField) : SObjectX.get(p, keyField));
            // product inserted
            log?.logInfo(p.Id, 'product inserted: ' + key);
            Object x = sources.get(key)[0];
            r.put(key, new Tuple3(p.Id, pe.Id, x));
        }

        // product customized
        if (last instanceof IProductCustom) ((IProductCustom)last).customProduct(sources, updates, inserts);

        sources.clear();
        return r;
    }

    /**
    * gets the products
    * @param sources the sources
    * @param sources the sources
    * @param pricebookId the pricebookId
    * @return Map<IString, Object[]>
    */
    global virtual Map<IString, Object[]> getProducts(List<String> sources, Id pricebookId) {
        Map<IString, Object[]> r = new Map<IString, Object[]>();
        if (sources.isEmpty()) return r;

        // add shipping products
        for (String source : sources) {
            if (String.isEmpty(source)) continue;
            IString key = new IString(source);
            // add value
            Product2 p = new Product2(
                ProductCode = source,
                StockKeepingUnit = source,
                Name = source,
                IsActive = true);
            PricebookEntry e = new PricebookEntry(
                Product2Id = null, //: reference
                Pricebook2Id = pricebookId,
                UnitPrice = 0.0,
                IsActive = true);
            Object[] value = new Object[] { new Tuple2(p, e), null };
            if (r.containsKey(key)) throw new HandledException('Product duplicate: ' + key);
            r.put(key, value);
        }
        return r;
    }

    /**
    * gets the products
    * @param sources the sources
    * @param tags the tags
    * @param pricebookId the pricebookId
    * @return Map<IString, Object[]>
    */
    global virtual Map<IString, Object[]> getProducts(List<Object> sources, Map<IString, Object> tags, Id pricebookId) {
        Map<IString, Object[]> r = new Map<IString, Object[]>();
        if (sources.isEmpty()) return r;

        // add sources
        for (Object z : sources) {
            for (Object y : ((IProductContainer)z).getProducts()) {
                IProduct s = (IProduct)y;
                IString key = s.getProductKey();
                if (IString.isEmpty(key)) { SystemX.debug('Skipping keyless product: ' + s); continue; }

                // add value
                Object[] value = new Object[] { s.getProduct(key, pricebookId, tags), s };
                if (r.containsKey(key)) {
                    if (s instanceof IProductMerge) {
                        Tuple2 value0 = (Tuple2)value[0];
                        value[0] = new Tuple2(((IProductMerge)s).mergeProduct((Product2)value0.item1, (Product2)((Tuple2)r.get(key)[0]).item1), value0.item2);
                    }
                    else if (s instanceof IProductMerge2) value[0] = ((IProductMerge2)s).mergeProduct((Tuple2)value[0], (Tuple2)r.get(key)[0]);
                    else throw new HandledException('Product duplicate: ' + key);
                }
                r.put(key, value);
            }
        }
        return r;
    }
}
