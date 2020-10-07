@isTest
private class OpportunityBatchUpdate_Test {

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

        list<user> Users = new list<user>();
        Users.add(
        	new User(
        		LastName='BPS',Brand__c='BPS',
        		Username='BPS@test.demo', Email='BPS@test.demo', Alias='BPS',
        		CommunityNickname='BPS', TimeZoneSidKey='Asia/Taipei',
        		LocaleSidKey='zh_TW', EmailEncodingKey='Big5',
        		ProfileId='00e7F000001m0BHQAY', LanguageLocaleKey='zh_TW'
        		)
        	);
        Users.add(
        	new User(LastName='MINI',Brand__c='MINI',
        		Username='MINI@test.demo', Email='MINI@test.demo', Alias='MINI',
        		CommunityNickname='MINI', TimeZoneSidKey='Asia/Taipei',
        		LocaleSidKey='zh_TW', EmailEncodingKey='Big5',
        		ProfileId='00e7F000001m0BHQAY', LanguageLocaleKey='zh_TW'
        		)
        	);
        insert Users;

        list<opportunity> oppts = new list<opportunity>();
		//for (Integer i = 0; i < 1; i++) {
		//}
	    oppts.add(
	        new opportunity(accountid=acct.Id, name='qqq', oldcustId__c='111113',
	                        HomePhone__c ='000', CompanyPhone__c ='000', Mobile__c='0001234566',
	                        stagename='來電',closedate=date.today(),
	                        SellingBrand__c='BMW',
	                        CurrentCarBrand__c='AUDI',
	                        LicensePlate__c='AAA-8888',
	                        IsRenewal__c='否',
	                        OwnerId=Users[0].Id)
	    );
	    oppts.add(
	        new opportunity(accountid=acct.Id, name='qqq', oldcustId__c='111111',
	                        HomePhone__c ='000', CompanyPhone__c ='000', Mobile__c='0001234567',
	                        stagename='來電',closedate=date.today(),
	                        SellingBrand__c='BMW',
	                        CurrentCarBrand__c='AUDI',
	                        LicensePlate__c='AAA-8888',
	                        IsRenewal__c='否',
	                        OwnerId=Users[1].Id)
	    );
	    oppts.add(
	        new opportunity(accountid=acct.Id, name='qqq', oldcustId__c='111112',
	                        HomePhone__c ='000', CompanyPhone__c ='000', Mobile__c='0001234568',
	                        stagename='試駕',closedate=date.today(),
	                        SellingBrand__c='MINI',
	                        CurrentCarBrand__c='AUDI',
	                        LicensePlate__c='AAA-8888',
	                        SelectedCar__c =nc.id,
	                        IsRenewal__c='否')
	    );
		insert oppts;
	}

	@isTest static void test_method_two() {
		Test.startTest();
		OpportunityBatchUpdate lp = new OpportunityBatchUpdate();
		Id batchId = Database.executeBatch(lp);
		Test.stopTest();
	}

}