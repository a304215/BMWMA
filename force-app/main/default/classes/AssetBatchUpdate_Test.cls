@isTest
private class AssetBatchUpdate_Test {

	@testSetup
    static void setup() {

        DealerMapping__c dm = new DealerMapping__c();
        dm.Name='19476';
        dm.DealerName__c = '桃園大桐';
        insert dm;

        NewCarPool__c nc = new NewCarPool__c();
        nc.Name = 'AAAAAAA';
        nc.vin_short__c = 'AAAAAAA';
        nc.Dealer__c = '桃園大桐';
        nc.VenderCode__c = '19476';
        insert nc;

        Account acct = new Account();
        acct.FirstName = 'AAAAAAA';
        acct.LastName = 'CCCCC';
        acct.RecordTypeId = '0127F000000IAMXQA4';
        acct.Gender__pc = '男性';
        acct.MainContactNumber__c ='行動電話';
        acct.PersonMobilePhone = '0000000000';
        insert acct;

        Asset ast = new Asset();
        ast.Name =  ' BBBBB';
        ast.AccountId = acct.Id;
        ast.VIN__c = nc.Id;
        ast.InstallDate = date.Today();
        insert ast;

        list<opportunity> oppts = new list<opportunity>();
		for (Integer i = 0; i < 1; i++) {
		    oppts.add(
		        new opportunity(accountid=acct.Id, name='qqq', oldcustId__c='11111',
		                        HomePhone__c ='000', CompanyPhone__c ='000', Mobile__c='0001112223',
		                        stagename='來電',closedate=date.today(),
		                        SellingBrand__c='BMW',
		                        SellingGeneration__c='I12',
		                        SellingCarType__c='i8 Coupe',
		                        CurrentCarBrand__c='AUDI',
		                        LicensePlate__c='AAA-8888',
		                        SelectedCar__c=nc.Id,
		                        IsRenewal__c='否')
		    );
		}
		insert oppts;
    }

	@isTest static void test_method_two() {
		// Implement test code
		Test.startTest();
		AssetBatchUpdate lp = new AssetBatchUpdate();
		Id batchId = Database.executeBatch(lp);
		Test.stopTest();
	}

}