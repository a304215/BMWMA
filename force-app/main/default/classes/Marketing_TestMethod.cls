@isTest 
public class Marketing_TestMethod {
	//行銷目標
    static testmethod void TestMarketingTarget()
    {
        TriggerHandler tr = new TriggerHandler();
        
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
            Mobile__c = '1234556789', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testOPP1;
        
        Opportunity testOPP2 =  new Opportunity(
            AccountId = NewAcc.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234556789', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是', LeadSource = '其它',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testOPP2;
        
        MarketingTargetY__c testTarget = new MarketingTargetY__c();
        testTarget.TargetYear__c = string.valueOf(system.today().year());
        insert testTarget;
        update testTarget;
    }
    
    
    //行銷活動
    static testmethod void TestMarketingCampaign()
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
        
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
        Opportunity testOPP1 =  new Opportunity(
            AccountId = NewAcc.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234556789', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testOPP1;
        
        Opportunity testOPP2 =  new Opportunity(
            AccountId = NewAcc.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234556789', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是', LeadSource = '其它',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testOPP2;
        
        Campaign newCam1 = new Campaign(name='CAM1', startdate=system.today(), enddate=system.today()+7, OpportunityTrackingEndDate__c=system.today()+20, Objective__c='Conquest New Lead 顧客開發');
        Campaign newCam2 = new Campaign(name='CAM2', startdate=system.today()+2, enddate=system.today()+4, OpportunityTrackingEndDate__c=system.today()+10, Objective__c='Conquest New Lead 顧客開發');
        list<campaign> insertCAMList = new list<campaign>();
        insertCAMList.add(newCam1);
        insertCAMList.add(newCam2);
        insert insertCAMList;
        
        //新增campaignMemberStatus
        CampaignMemberStatus newStatus1 = new CampaignMemberStatus(CampaignId=newCam1.id, Label= '已出席', HasResponded  =true );
        CampaignMemberStatus newStatus2 = new CampaignMemberStatus(CampaignId=newCam2.id, Label= '已出席', HasResponded  =true );
        list<CampaignMemberStatus> insertStatusList = new list<CampaignMemberStatus>();
        insertStatusList.add(newStatus1);
        insertStatusList.add(newStatus2);
        insert insertStatusList;
        
        //Leads 的
        CampaignMember newCM1 = new CampaignMember(LeadId = testRecord.id, campaignid = newCam1.id, status='已出席');
        CampaignMember newCM2 = new CampaignMember(LeadId = testRecord2.id, campaignid = newCam1.id, status='已出席');
        CampaignMember newCM3 = new CampaignMember(LeadId = testRecord.id, campaignid = newCam2.id, status='已出席');
        CampaignMember newCM4 = new CampaignMember(LeadId = testRecord2.id, campaignid = newCam2.id, status='已出席');
        
        list<CampaignMember> insertCMList = new list<CampaignMember>();
        insertCMList.add(newCM1);
        insertCMList.add(newCM2);
        insertCMList.add(newCM3);
        insertCMList.add(newCM4);
        
        for(account loopAcc: [select PersonContactId from Account])
        {
            CampaignMember tempCM1 = new CampaignMember(ContactId = loopAcc.PersonContactId, campaignid = newCam1.id, status='已出席');
            CampaignMember tempCM2 = new CampaignMember(ContactId = loopAcc.PersonContactId, campaignid = newCam2.id, status='已出席');
            insertCMList.add(tempCM1);
            insertCMList.add(tempCM2);
        }
        
        insert insertCMList;
        
        test.startTest();
        //update insertCAMList;
        testOPP1.SigningDate__c = system.today()+3;
        update testOPP1;
        testOPP2.SigningDate__c = system.today()+10;
        testOPP2.StageName = '戰敗';
        testOPP2.LostReason__c = '其它原因';
        testOPP2.LostKeyPoint__c = '價格因素';
        testOPP2.LostBrand__c = 'AUDI';
        update testOPP2;
        update insertCAMList;
        
        test.stopTest();
    }
    
    //Marketing Schedule
    static testmethod void TestMarketingSchedule()
    {
        Test.StartTest();
        MarketingSchedule sh1 = new MarketingSchedule();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    //Marketing Batch
    static testmethod void TestMarketingBatch()
    {
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
        Test.startTest();
        MarketingTargetBatchJob mst = new MarketingTargetBatchJob('select id from account');
        Id batchId = Database.executeBatch(mst);
        Test.stopTest();
    }
}