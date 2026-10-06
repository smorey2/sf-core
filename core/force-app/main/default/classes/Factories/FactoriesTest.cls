@isTest
class FactoriesTest {
    static final AccountFactory accountF = AccountFactory.get;
    static final ProductFactory productF = ProductFactory.get;
    static Logger setup() { return new Logger(); }

    //#region ACCOUNTX

    static Object[] createAccounts() {
        AccountX s = new AccountX();
        s.fullName = 'Full Name';
        s.email = 'email@email.com';
        s.phone = '808-555-1212';
        return new Object[] { s };
    }

    // AccountX
    class AccountX implements AccountFactory.IAccountUpsert, AccountFactory.IAccountCustom, AccountFactory.IAccountMerge {
        public String fullName;
        public String email;
        public String phone;
        
        //#region AccountFactory.IAccountUpsert

        /**
        * gets the account options
        * @return Tuple2
        */
        public Tuple2 getAccountOptions() { return null; }
        /**
        * gets the account key
        * @return IString
        */
        public IString getAccountKey() { return new IString(email); }
        /**
        * gets the account tags
        * @param method the method
        * @param keys the keys
        * @return Map<IString, Object>
        */
        public Map<IString, Object> getAccountTags(String method, Set<String> keys) { return null; }

        // Account
        /**
        * gets the account
        * @param key the key
        * @param tags the tags
        * @return Account
        */
        public Account getAccount(IString key, Map<IString, Object> tags) {
            AccountX s = this;
            List<String> names = s.fullName.split(' ');
            String lastName = names.remove(names.size() - 1);
            String firstName = String.join(names, ' ').trim();
            Account account = new Account(Phone = s.phone);
            if (UserInfoX.isPersonAccountOrganization()) {
                account.put('FirstName', firstName);
                account.put('LastName', lastName);
                account.put('PersonEmail', key.toString());
            }
            else account.put('Name', key.toString());
            return account;
        }
        /**
        * updates the account
        * @param record the record
        * @param prior the prior
        * @return Account
        */
        public Account updateAccount(Account record, Account prior) { return record; }
        /**
        * inserts the account
        * @param record the record
        * @return Account
        */
        public Account insertAccount(Account record) { return record; }

        //#endregion

        //#region AccountFactory.IAccountCustom

        /**
        * customizes the account
        * @param accounts the accounts
        * @param sources the sources
        * @param updates the updates
        * @param inserts the inserts
        */
        public void customAccount(Map<IString, IdObj> accounts, Map<IString, List<Object>> sources, List<Account> updates, List<Account> inserts) { }

        //#endregion

        //#region AccountFactory.IAccountMerge

        /**
        * merges the account
        * @param record the record
        * @param prior the prior
        * @return Account
        */
        public Account mergeAccount(Account record, Account prior) { return record; }

        //#endregion
    }

    //#endregion

    @isTest static void Account_createAccounts() {
        Logger log = setup();
        Object[] sources = createAccounts();
        Test.startTest();
        Map<IString, IdObj> accounts1 = accountF.createAccounts(log, sources);
        Map<IString, IdObj> accounts2 = accountF.createAccounts(log, sources);
        Test.stopTest();
        System.assert(accounts1 != null, 'Should be value');
        System.assert(accounts2 != null, 'Should be value');
        System.debug(log.toString());
    }

    //#region ORDERX

    static Object[] createOrders() {
        OrderXItem l = new OrderXItem();
        l.sku = 'SKU';
        l.productName = 'Product Name';
        l.unitPrice = 1.0;
        OrderX s = new OrderX();
        s.fullName = 'Full Name';
        s.orderItems = new OrderXItem[] { l };
        return new Object[] { s };
    }

    // OrderX
    class OrderX implements ProductFactory.IProductContainer {
        public String fullName;
        public List<OrderXItem> orderItems;

        //#region ProductFactory.IProductContainer

        /**
        * gets the products
        * @return List<Object>
        */
        public List<Object> getProducts() { return orderItems; }

        //#endregion
    }

    // OrderXItem
    class OrderXItem implements ProductFactory.IProductUpsert, ProductFactory.IProductCustom, ProductFactory.IProductMerge {
        public String sku;
        public String productName;
        public Decimal unitPrice;
        
        //#region ProductFactory.IProductUpsert

        /**
        * gets the product options
        * @return Tuple2
        */
        public Tuple2 getProductOptions() { return null; }
        /**
        * gets the product key
        * @return IString
        */
        public IString getProductKey() { return new IString(sku); }
        /**
        * gets the product tags
        * @param method the method
        * @param keys the keys
        * @return Map<IString, Object>
        */
        public Map<IString, Object> getProductTags(String method, Set<String> keys) { return null; }

        /**
        * gets the product
        * @param key the key
        * @param pricebook2Id the pricebook2Id
        * @param tags the tags
        * @return Tuple2
        */
        public Tuple2 getProduct(IString key, Id pricebook2Id, Map<IString, Object> tags) {
            OrderXItem s = this;
            return new Tuple2(new Product2(
                ProductCode = key.toString(),
                // StockKeepingUnit = key,
                Name = s.productName,
                IsActive = true), new PricebookEntry(
                Product2Id = null, //: reference
                Pricebook2Id = pricebook2Id,
                UnitPrice = s.unitPrice ?? 0.0,
                IsActive = true));
        }
        /**
        * updates the product
        * @param record the record
        * @param prior the prior
        * @return Product2
        */
        public Product2 updateProduct(Product2 record, Product2 prior) { return record; }
        /**
        * inserts the product
        * @param record the record
        * @return Product2
        */
        public Product2 insertProduct(Product2 record) { return record; }

        //#endregion

        //#region ProductFactory.IProductCustom

        /**
        * customizes the product
        * @param sources the sources
        * @param updates the updates
        * @param inserts the inserts
        */
        public void customProduct(Map<IString, Object[]> sources, List<Product2> updates, List<Product2> inserts) { }

        //#endregion

        //#region ProductFactory.IProductMerge

        /**
        * merges the product
        * @param record the record
        * @param prior the prior
        * @return Product2
        */
        public Product2 mergeProduct(Product2 record, Product2 prior) { return record; }

        //#endregion
    }

    //#endregion


    @isTest static void Product_createProducts() {
        Logger log = setup();
        List<String> shippingProducts = new List<String> { 'DELIVERYMETHOD' };
        Object[] sources = createOrders();
        Test.startTest();
        Map<IString, Tuple3> products1 = productF.createProducts(log, sources, shippingProducts);
        Map<IString, Tuple3> products2 = productF.createProducts(log, sources, shippingProducts);
        Test.stopTest();
        System.assert(products1 != null, 'Should be value');
        System.assert(products2 != null, 'Should be value');
        System.debug(log.toString());
    }
}