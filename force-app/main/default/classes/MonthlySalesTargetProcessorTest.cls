@isTest
private class MonthlySalesTargetProcessorTest {

    @testSetup
    static void setup() {
        List<SalesTarget__c> STs = new List<SalesTarget__c>();
        // insert 10 SalesTarget__c
        for (Integer i=0;i<10;i++) {
            STs.add(new SalesTarget__c());
        }
        insert STs;
    }
    @isTest static void test_method_one() {
        Test.startTest();
        MonthlySalesTargetProcessor mst = new MonthlySalesTargetProcessor();
        Id batchId = Database.executeBatch(mst);
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from lead where LeadSource = 'Dreamforce']);
    }
}