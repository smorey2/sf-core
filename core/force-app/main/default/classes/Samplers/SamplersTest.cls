@isTest
class SamplersTest {
    @isTest static void Account_createAccount() {
        Test.startTest();
        Account actual = AccountSampler.get.createAccount('John Doe');
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }

    @isTest static void User_createUser() {
        Test.startTest();
        Account account = new Account(Name='name'); insert account;
        Contact contact = new Contact(FirstName='first name', LastName = 'last name', Email='mail@mail.com'); insert contact;
        User actual = UserSampler.get.createUser(account, contact, 'Standard User');
        User actual2 = UserSampler.get.createUser('name', 'last name', 'Standard User');
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
        System.assert(actual2 != null, 'Should be value');
    }

    @isTest static void User_createEmail() {
        Test.startTest();
        String actual = UserSampler.get.createEmail('name', 'last name');
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }
    
    @isTest static void User_createAlias() {
        Test.startTest();
        String actual = UserSampler.get.createAlias('name', 'last name');
        Test.stopTest();
        System.assert(actual != null, 'Should be value');
    }
}