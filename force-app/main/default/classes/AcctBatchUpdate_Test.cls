@isTest
private class AcctBatchUpdate_Test {

	@testSetup
    static void setup() {
    	Account acct1 = new Account();
    	acct1.FirstName = 'AAAAAAA';
    	acct1.LastName = 'CCCCC';
    	acct1.RecordTypeId = '0127F000000IAMXQA4';
    	acct1.Gender__pc = '男性';
    	acct1.MainContactNumber__c ='行動電話';
    	acct1.PersonMobilePhone = '0000000000';
    	insert acct1;

    	Account acct2 = new Account();
    	acct2.Name = 'Business Account';
    	acct2.RecordTypeId = '0127F000000IABeQAO';
    	acct2.MainContactNumber__c ='住宅電話';
    	acct2.Phone = '0000000000';
    	insert acct2;
    }

	@isTest static void test_method_two() {
		// Implement test code
		Test.startTest();
		AcctBatchUpdate lp = new AcctBatchUpdate();
		Id batchId = Database.executeBatch(lp);
		Test.stopTest();
	}

}