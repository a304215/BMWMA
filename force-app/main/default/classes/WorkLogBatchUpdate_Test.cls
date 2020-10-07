@isTest
private class WorkLogBatchUpdate_Test {
    @testSetup
    static void setup() {

        list<account> accts = new list<account>();
        for (Integer i = 0; i < 2; i++) {
            accts.add(
                new account(lastname='qqq', MainContactNumber__c ='行動電話', PersonMobilePhone = '000000000'+string.valueOf(i))
            );
        }
        insert accts;
        
        list<worklog__c> worklogs = new list<worklog__c>();
        integer k = 0;
        for (Integer i = 0; i < 10; i++) {
        	if(i>5)
        	{
        		k=1;
        	}
            worklogs.add(
                new worklog__c(
                	OldCustomerNo__c='111115'+string.valueOf(i), 
                	contactDate__c = system.today(),
                    Category__c = '客戶主檔',
                	LogCust__c = accts[k].id
                )
            );
        }
        insert worklogs;

		list<opportunity> oppts = new list<opportunity>();
		for (Integer i = 0; i < 2; i++) {
		    oppts.add(
		        new opportunity(accountid=accts[0].Id, name='qqq', oldcustId__c='111115'+string.valueOf(i),
		                        HomePhone__c ='000', CompanyPhone__c ='000', Mobile__c='0001234567',
		                        stagename='來電',closedate=date.today(),
		                        SellingBrand__c='BMW',
		                        SellingGeneration__c='I12',
		                        SellingCarType__c='i8 Coupe',
		                        CurrentCarBrand__c='AUDI',
		                        IsRenewal__c='否')
		    );
		}
		insert oppts;
    }
    @isTest static void test_method_one() {
        Test.startTest();
        WorkLogBatchUpdate lp = new WorkLogBatchUpdate();
        Id batchId = Database.executeBatch(lp);
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from lead where LeadSource = 'Dreamforce']);
    }
}