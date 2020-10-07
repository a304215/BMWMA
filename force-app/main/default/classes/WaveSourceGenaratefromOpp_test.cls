@isTest
private class WaveSourceGenaratefromOpp_test
{
	@isTest static void test_method_one()
	{
		list<DealerMapping__c> DM_L = new list<DealerMapping__c>();
		DM_L.add(new DealerMapping__c(Name='95271', DealerName__c='台北依德'));
		DM_L.add(new DealerMapping__c(Name='95272', DealerName__c='台北依德'));
		DM_L.add(new DealerMapping__c(Name='95273', DealerName__c='台北依德'));
		insert DM_L;

        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性',
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890',
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;

        list<NewCarPool__c> NC_L = new list<NewCarPool__c>();
        NC_L.add(new NewCarPool__c(Name='LUKE56', venderCode__c='95271', Status__c = '新車'));
        NC_L.add(new NewCarPool__c(Name='LUKE57', venderCode__c='95272', Status__c = '新車'));
        NC_L.add(new NewCarPool__c(Name='LUKE58', venderCode__c='95273', Status__c = '新車'));
        insert NC_L;

        list<Opportunity> testRecord_L = new list<Opportunity>();
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[0].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
		));
		testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[1].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
		));
		testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[2].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
		));
        insert testRecord_L;

	    Test.StartTest();
		WaveSourceGenaratefromOpp_schedule WaveSourceGenaratefromOpp = new WaveSourceGenaratefromOpp_schedule();
		String sch ='0 48 * * * ?';
		string jobid = System.schedule('WaveSourceGenaratefromOpp_schedule', sch,WaveSourceGenaratefromOpp);

		date date01 = WaveSourceGenaratefromOpphandler.ConvertDate('2018','3');
		Test.stopTest();
	}

    @isTest static void test_method_two()
    {
        list<DealerMapping__c> DM_L = new list<DealerMapping__c>();
        DM_L.add(new DealerMapping__c(Name='95271', DealerName__c='台北依德'));
        DM_L.add(new DealerMapping__c(Name='95272', DealerName__c='台北依德'));
        DM_L.add(new DealerMapping__c(Name='95273', DealerName__c='台北依德'));
        insert DM_L;

        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性',
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890',
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;

        list<NewCarPool__c> NC_L = new list<NewCarPool__c>();
        NC_L.add(new NewCarPool__c(Name='LUKE56', venderCode__c='95271', Status__c = '新車'));
        NC_L.add(new NewCarPool__c(Name='LUKE57', venderCode__c='95272', Status__c = '新車'));
        NC_L.add(new NewCarPool__c(Name='LUKE58', venderCode__c='95273', Status__c = '新車'));
        insert NC_L;

        list<Opportunity> testRecord_L = new list<Opportunity>();
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[0].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
        ));
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[1].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
        ));
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[2].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
        ));
        insert testRecord_L;

        Test.StartTest();
        WaveSourceGenaratefromOpp_schedule WaveSourceGenaratefromOpp2 = new WaveSourceGenaratefromOpp_schedule(string.valueof(system.today().year()), string.valueof(system.today().month()));
        String sch2 ='0 48 * * * ?';
        string jobid2 = System.schedule('WaveSourceGenaratefromOpp_schedule', sch2, WaveSourceGenaratefromOpp2);

        date date02 = WaveSourceGenaratefromOpphandler.ConvertDate('2018','3');
        Test.stopTest();
    }

    @isTest static void test_method_three()
    {
        list<DealerMapping__c> DM_L = new list<DealerMapping__c>();
        DM_L.add(new DealerMapping__c(Name='95271', DealerName__c='台北依德'));
        DM_L.add(new DealerMapping__c(Name='95272', DealerName__c='台北依德'));
        DM_L.add(new DealerMapping__c(Name='95273', DealerName__c='台北依德'));
        insert DM_L;

        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性',
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890',
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;

        list<NewCarPool__c> NC_L = new list<NewCarPool__c>();
        NC_L.add(new NewCarPool__c(Name='LUKE56', venderCode__c='95271', Status__c = '新車'));
        NC_L.add(new NewCarPool__c(Name='LUKE57', venderCode__c='95272', Status__c = '新車'));
        NC_L.add(new NewCarPool__c(Name='LUKE58', venderCode__c='95273', Status__c = '新車'));
        insert NC_L;

        list<Opportunity> testRecord_L = new list<Opportunity>();
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[0].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
        ));
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[1].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
        ));
        testRecord_L.add(new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '報價', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa',
            MainAddress__c = '公司',
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56', SelectedCar__c = NC_L[2].id,
            SellingBrand__c='BMW', SellingGeneration__c='I12', SellingCarType__c='i8 Coupe', CurrentCarBrand__c='AUDI',IsRenewal__c='否'
        ));
        insert testRecord_L;

        Test.StartTest();
        WaveSourceGenaratefromOpp_schedule WaveSourceGenaratefromOpp2 = new WaveSourceGenaratefromOpp_schedule(string.valueof(system.today().year()), null);
        String sch2 ='0 48 * * * ?';
        string jobid2 = System.schedule('WaveSourceGenaratefromOpp_schedule', sch2, WaveSourceGenaratefromOpp2);

        date date02 = WaveSourceGenaratefromOpphandler.ConvertDate('2018','3');
        Test.stopTest();
    }
}