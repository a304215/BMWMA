@isTest
private class eSignController_Test {

	@isTest static void test_method_one() {
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
            LastName='Lead01', phone = '0912345678', MobilePhone = '0912345678',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區'
        );//, recordtypeid = RecTypeId);
        insert testRecord;
        
        
		//lead a = new lead();
		//a.LastName = 'aa';
		//insert a;
		eSignController.saveSignature(testRecord.Id, 'dskjahlfawf');

		ApexPages.StandardController ctrler = new ApexPages.StandardController(new opportunity());
		eSignController c = new eSignController(ctrler);
		c.cancel();
	}
}