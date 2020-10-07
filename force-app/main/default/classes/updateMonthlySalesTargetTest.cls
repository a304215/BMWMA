@isTest
private class updateMonthlySalesTargetTest 
{
    @testSetup
    static void setup() 
    {
    }   
    @isTest
    static void test1()
    {
        SalesTarget__c tempSalesTarget = new SalesTarget__c(
            TargetYear__c = string.valueOf(date.today().addDays(-1).year()), 
            TargetMonth__c= string.valueOf(date.today().addDays(-1).month()+100).right(2)
        );
        insert tempSalesTarget;
        
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
            Name='Account02', 
            ObjectAPI__c ='Account', 
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
        );
        insert testRecord;
        
        Lead testRecord2 =  new Lead(
            LastName='Lead02',  phone = '0912345678', MobilePhone = '0912345678',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區', LeadSource = '其它'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;
        update testRecord2;
        
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
        Opportunity testOPP1 =  new Opportunity(
            AccountId = NewAcc.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567899', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '否', 
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testOPP1;
        
        Opportunity testOPP2 =  new Opportunity(
            AccountId = NewAcc.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234554321', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '否', 
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI',
            DeliveryDate__c = system.today(), SigningDate__c = system.today()
        );
        insert testOPP2;

        Asset myAsset = new Asset();
        myAsset.Accountid = NewAcc.id;
        myAsset.Name = '123';
        insert myAsset;

        TestCar__c myCar = new TestCar__c();
        myCar.Name = '阿斯拉';
        myCar.SourceAsset__c = myAsset.id;
        insert myCar;
        
        TestDriveReservation__c tempTDR1 = new TestDriveReservation__c(
            Opportunity__c = testOPP1.id,
            ReturnTime__c = system.now(),
            TestDriveStatus__c = '已完成',
            TestCar__c = myCar.id
        );
        insert tempTDR1;
        
        WorkLog__c tempWL1 =  new WorkLog__c(
            Category__c = '有望客戶',
            WorkType__c = '電訪',
            contactDate__c = system.today(), 
            logCust__c = NewAcc.id,
            logOppty__c = testOPP1.id
        );
        
        WorkLog__c tempWL2 =  new WorkLog__c(
            Category__c = '有望客戶',
            WorkType__c = '親訪',
            contactDate__c = system.today(), 
            logCust__c = NewAcc.id,
            logOppty__c = testOPP1.id
        );
        
        WorkLog__c tempWL3 =  new WorkLog__c(
        	
            Category__c = '客戶主檔',
            WorkType__c = '車主關懷',
            contactDate__c = system.today(), 
            logCust__c = NewAcc.id
        );
        
        list<WorkLog__c> insertWLList = new list<WorkLog__c>();
        insertWLList.add(tempWL1);
        insertWLList.add(tempWL2);
        insertWLList.add(tempWL3);
        insert insertWLList;
		tempWL1.LogApproved__c = true;
		tempWL2.LogApproved__c = true;
		tempWL3.LogApproved__c = true;
		update insertWLList;
		
		
        Test.startTest();
        updateMonthlySalesTarget u = new updateMonthlySalesTarget();
        u.year = string.valueOf(date.today().addDays(-1).year());
        u.month = string.valueOf(date.today().addDays(-1).month()+100).right(2);
        u.updateData();
        
        u.convertScope(u.rawData);
        
        
        Test.stopTest();
    }

}