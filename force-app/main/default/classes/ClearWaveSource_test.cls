@isTest
private class ClearWaveSource_test 
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
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', MainPhoneNumber__c = '行動電話' , MobilePhone = '0912345679', ContactMethod__c = '電話聯絡'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;

        Test.StartTest();
		WaveSourceGenaratefromLead_schedule WaveSourceGenaratefromLead2 = new WaveSourceGenaratefromLead_schedule(string.valueof(system.today().year()), string.valueof(system.today().month())); 
		String sch2 ='0 48 * * * ?'; 
		string jobid2 = System.schedule('WaveSourceGenaratefromLead_schedule2', sch2,WaveSourceGenaratefromLead2);

		date date02 = WaveSourceGenaratefromLeadhandler.ConvertDate('2018','3');

		ClearWaveSource_schedule ClearWaveSource = new ClearWaveSource_schedule(string.valueof(system.today().year()), string.valueof(system.today().month()));

		ClearWaveSource_schedule ClearWaveSource2 = new ClearWaveSource_schedule(string.valueof(system.today().year()), null);

		ClearWaveSource_schedule ClearWaveSource3 = new ClearWaveSource_schedule(null, null);

		string jobid3 = System.schedule('ClearWaveSource', sch2, ClearWaveSource);
		system.abortJob(jobid3);
		string jobid4 = System.schedule('ClearWaveSource2', sch2, ClearWaveSource2);
		system.abortJob(jobid4);
		string jobid5 = System.schedule('ClearWaveSource3', sch2, ClearWaveSource3);

		list<wavekpisource__c> WKPIS_L = new list<wavekpisource__c>();

		WKPIS_L.add(new wavekpisource__c());

		insert WKPIS_L;

		ClearWaveSourcehandler.doClearWaveSource(WKPIS_L);

		Test.StopTest();
	}
}