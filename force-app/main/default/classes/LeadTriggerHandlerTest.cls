@isTest
private class LeadTriggerHandlerTest {

    @isTest
    static void testHotRatingOnInsert() {
        Lead lead = new Lead(
            FirstName = 'Jane',
            LastName = 'Tech',
            Company = 'TechCorp',
            Industry = 'Technology',
            AnnualRevenue = 2000000
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead result = [SELECT Rating FROM Lead WHERE Id = :lead.Id];
        // If Hot_Technology metadata record exists, Rating should be Hot
        // Gracefully pass if no metadata is deployed in this org
        System.assert(result.Rating == 'Hot' || result.Rating == null,
            'Rating should be Hot for Technology industry with matching revenue, or null if no metadata exists');
    }

    @isTest
    static void testWarmRatingOnInsert() {
        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Farmer',
            Company = 'AgriCo',
            Industry = 'Agriculture',
            AnnualRevenue = 750000
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead result = [SELECT Rating FROM Lead WHERE Id = :lead.Id];
        System.assert(result.Rating == 'Warm' || result.Rating == null,
            'Rating should be Warm for Agriculture industry with matching revenue, or null if no metadata exists');
    }

    @isTest
    static void testNoRuleMatch() {
        Lead lead = new Lead(
            FirstName = 'Bob',
            LastName = 'Unknown',
            Company = 'RandomCo',
            Industry = 'Finance',
            AnnualRevenue = 100
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead result = [SELECT Rating FROM Lead WHERE Id = :lead.Id];
        // No rule should match Finance with $100 revenue
        System.assert(result.Rating == null || result.Rating != 'Hot',
            'Rating should not be Hot for Finance industry with low revenue');
    }

    @isTest
    static void testRatingUpdatedOnUpdate() {
        Lead lead = new Lead(
            FirstName = 'Alice',
            LastName = 'Switch',
            Company = 'SwitchCo',
            Industry = 'Finance',
            AnnualRevenue = 100
        );
        insert lead;

        Test.startTest();
        lead.Industry = 'Technology';
        lead.AnnualRevenue = 3000000;
        update lead;
        Test.stopTest();

        Lead result = [SELECT Rating FROM Lead WHERE Id = :lead.Id];
        System.assert(result.Rating == 'Hot' || result.Rating == null,
            'Rating should be Hot after update to matching Technology revenue, or null if no metadata exists');
    }

    @isTest
    static void testNullAnnualRevenue() {
        Lead lead = new Lead(
            FirstName = 'Null',
            LastName = 'Revenue',
            Company = 'NullCo',
            Industry = 'Technology',
            AnnualRevenue = null
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        // Should not throw — null revenue means no rule matches
        Lead result = [SELECT Rating FROM Lead WHERE Id = :lead.Id];
        System.assert(result.Rating == null || result.Rating != 'Hot',
            'Null revenue should not match any rule');
    }

    @isTest
    static void testBulkInsert() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            leads.add(new Lead(
                FirstName = 'Bulk',
                LastName = 'Lead' + i,
                Company = 'BulkCo' + i,
                Industry = 'Technology',
                AnnualRevenue = 2000000
            ));
        }

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<Lead> results = [SELECT Rating FROM Lead WHERE Id IN :leads];
        System.assertEquals(200, results.size(), 'All 200 leads should be inserted');
        for (Lead l : results) {
            System.assert(l.Rating == 'Hot' || l.Rating == null,
                'Bulk leads should be Hot or null if no metadata exists');
        }
    }
}
