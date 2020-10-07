@isTest
private class WaveSourceGenaratefromLead_test 
{
	@isTest static void test_method_one() 
	{
		//加入自訂設定檔。
        ZipCode__c zipCode = new ZipCode__c(Name='臺北市信義區', ZipCode__c ='110');
        ZipCode__c zipCode2 = new ZipCode__c(Name='臺北市中正區', ZipCode__c ='100');
		insert zipCode;
        insert zipCode2;
        ZipCodeMapping__c zipCodeMapping01 = new ZipCodeMapping__c(
            Name='Lead01', 
            ObjectAPI__c ='Lead', 
            CityAPI__c = 'CompanyCity__c', 
            ZipeCodeAPI__c='CompanyPostCode__c',
            AreaAPI__c='CompanyDistrict__c'
       	);
        ZipCodeMapping__c zipCodeMapping02 = new ZipCodeMapping__c(
            Name='Lead02', 
            ObjectAPI__c ='Lead', 
            CityAPI__c = 'HomeCity__c', 
            ZipeCodeAPI__c='HomePostCode__c',
            AreaAPI__c='HomeDistrict__c'
       	);
        insert zipCodeMapping01;
        insert zipCodeMapping02;
        
        //加入自訂設定檔。
    	Lead testRecord =  new Lead(
            LastName='Lead01', phone = '0912345678', 
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話', MobilePhone = '0912345678', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord;
        
        Lead testRecord2 =  new Lead(
            LastName='Lead02',  phone = '0912345678', 
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話', MobilePhone = '0912345678', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;

        Test.StartTest();
        string todayYear = string.valueof(system.today().year());
        string todayMonth = string.valueof(system.today().month()).length()<2 ? '0' + string.valueof(system.today().month()) : string.valueof(system.today().month());
		WaveSourceGenaratefromLead_schedule WaveSourceGenaratefromLead = new WaveSourceGenaratefromLead_schedule(todayYear, todayMonth); 
		String str = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
		string jobid = System.schedule('WaveSourceGenaratefromLead_schedule', str,WaveSourceGenaratefromLead);

		date date01 = WaveSourceGenaratefromLeadhandler.ConvertDate(todayYear,todayMonth);

		Test.StopTest();
	}

	@isTest static void test_method_two() 
	{
		//加入自訂設定檔。
        ZipCode__c zipCode = new ZipCode__c(Name='臺北市信義區', ZipCode__c ='110');
        ZipCode__c zipCode2 = new ZipCode__c(Name='臺北市中正區', ZipCode__c ='100');
		insert zipCode;
        insert zipCode2;
        ZipCodeMapping__c zipCodeMapping01 = new ZipCodeMapping__c(
            Name='Lead01', 
            ObjectAPI__c ='Lead', 
            CityAPI__c = 'CompanyCity__c', 
            ZipeCodeAPI__c='CompanyPostCode__c',
            AreaAPI__c='CompanyDistrict__c'
       	);
        ZipCodeMapping__c zipCodeMapping02 = new ZipCodeMapping__c(
            Name='Lead02', 
            ObjectAPI__c ='Lead', 
            CityAPI__c = 'HomeCity__c', 
            ZipeCodeAPI__c='HomePostCode__c',
            AreaAPI__c='HomeDistrict__c'
       	);
        insert zipCodeMapping01;
        insert zipCodeMapping02;
        
        //加入自訂設定檔。
    	Lead testRecord =  new Lead(
            LastName='Lead01', phone = '0912345678', 
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話', MobilePhone = '0912345678', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord;
        
        Lead testRecord2 =  new Lead(
            LastName='Lead02',  phone = '0912345678', 
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話', MobilePhone = '0912345678', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;

        Test.StartTest();

		WaveSourceGenaratefromLead_schedule WaveSourceGenaratefromLead2 = new WaveSourceGenaratefromLead_schedule(string.valueof(system.today().year()), null); 
		String str = Datetime.now().addMinutes(1).format('s m H d M ? yyyy'); 
		string jobid2 = System.schedule('WaveSourceGenaratefromLead_schedule2', str,WaveSourceGenaratefromLead2);

		date date02 = WaveSourceGenaratefromLeadhandler.ConvertDate('2018','3');

		Test.StopTest();
	}

    @isTest static void test_method_three() 
    {
        //加入自訂設定檔。
        ZipCode__c zipCode = new ZipCode__c(Name='臺北市信義區', ZipCode__c ='110');
        ZipCode__c zipCode2 = new ZipCode__c(Name='臺北市中正區', ZipCode__c ='100');
        insert zipCode;
        insert zipCode2;
        ZipCodeMapping__c zipCodeMapping01 = new ZipCodeMapping__c(
            Name='Lead01', 
            ObjectAPI__c ='Lead', 
            CityAPI__c = 'CompanyCity__c', 
            ZipeCodeAPI__c='CompanyPostCode__c',
            AreaAPI__c='CompanyDistrict__c'
        );
        ZipCodeMapping__c zipCodeMapping02 = new ZipCodeMapping__c(
            Name='Lead02', 
            ObjectAPI__c ='Lead', 
            CityAPI__c = 'HomeCity__c', 
            ZipeCodeAPI__c='HomePostCode__c',
            AreaAPI__c='HomeDistrict__c'
        );
        insert zipCodeMapping01;
        insert zipCodeMapping02;
        
        //加入自訂設定檔。
        Lead testRecord =  new Lead(
            LastName='Lead01', phone = '0912345678', 
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話', MobilePhone = '0912345678', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord;
        
        Lead testRecord2 =  new Lead(
            LastName='Lead02',  phone = '0912345678', 
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話', MobilePhone = '0912345678', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;

        Test.StartTest();

        WaveSourceGenaratefromLead_schedule WaveSourceGenaratefromLead2 = new WaveSourceGenaratefromLead_schedule(); 
        String str = Datetime.now().addMinutes(1).format('s m H d M ? yyyy'); 
        string jobid2 = System.schedule('WaveSourceGenaratefromLead_schedule2', str,WaveSourceGenaratefromLead2);

        date date02 = WaveSourceGenaratefromLeadhandler.ConvertDate('2018','3');

        Test.StopTest();
    }
}