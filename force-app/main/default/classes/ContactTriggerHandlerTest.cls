@isTest
private class ContactTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @isTest
    static void testInsertContact() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Contact c = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
        insert c;
        Test.stopTest();

        Account updatedAcc = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, updatedAcc.Number_of_Contacts__c, 'Should be 1 contact after insert');
    }

    @isTest
    static void testDeleteContact() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact c = new Contact(FirstName = 'Jane', LastName = 'Doe', AccountId = acc.Id);
        insert c;

        Test.startTest();
        delete c;
        Test.stopTest();

        Account updatedAcc = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, updatedAcc.Number_of_Contacts__c, 'Should be 0 contacts after delete');
    }

    @isTest
    static void testUpdateContactAccountChange() {
        Account acc1 = [SELECT Id FROM Account LIMIT 1];
        Account acc2 = new Account(Name = 'Test Account 2');
        insert acc2;

        Contact c = new Contact(FirstName = 'Bob', LastName = 'Smith', AccountId = acc1.Id);
        insert c;

        Test.startTest();
        c.AccountId = acc2.Id;
        update c;
        Test.stopTest();

        Account updatedAcc1 = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :acc1.Id];
        Account updatedAcc2 = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :acc2.Id];

        System.assertEquals(0, updatedAcc1.Number_of_Contacts__c, 'Old account should have 0 contacts');
        System.assertEquals(1, updatedAcc2.Number_of_Contacts__c, 'New account should have 1 contact');
    }

    @isTest
    static void testMultipleContacts() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(FirstName = 'Contact', LastName = 'Test' + i, AccountId = acc.Id));
        }
        insert contacts;
        Test.stopTest();

        Account updatedAcc = [SELECT Number_of_Contacts__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(5, updatedAcc.Number_of_Contacts__c, 'Should be 5 contacts after bulk insert');
    }
}
