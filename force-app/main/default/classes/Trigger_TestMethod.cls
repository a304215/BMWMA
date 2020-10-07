@isTest 
public class Trigger_TestMethod 
{
	static testmethod void TestCarSelection()
    {
        //加入自訂設定檔。
        ZipCode__c zipCode = new ZipCode__c(Name='臺北市信義區', ZipCode__c ='110');
        ZipCode__c zipCode2 = new ZipCode__c(Name='臺北市中山區', ZipCode__c ='100');
		insert zipCode;
        insert zipCode2;
        //假的。
        ZipCodeMapping__c zipCodeMapping01 = new ZipCodeMapping__c(
            Name='Opp1', 
            ObjectAPI__c ='Opportunity', 
            CityAPI__c = 'ContactCity__c', 
            ZipeCodeAPI__c='ContactStree__c',
            AreaAPI__c='ContactDistrict__c'
       	);
        insert zipCodeMapping01;
        
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
    	Opportunity testRecord =  new Opportunity(
            AccountId = NewAcc.id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testRecord;
            
		testRecord.inputVIN__c = '5566';
        try{
        	update testRecord;  
        }
        catch (exception e)
        {
            
        }
        DealerMapping__c NewSetting = new DealerMapping__c(Name='19451', DealerName__c='台北依德');
        insert NewSetting;
        
        CarPhoto__c newCP01 = new CarPhoto__c(CarGeneration__c = 'E84');
        CarPhoto__c newCP02 = new CarPhoto__c(CarGeneration__c = 'E84', carType__c ='116i');
        insert newCP01;
        insert newCP02;
        
        NewCarPool__c newCar01 = new NewCarPool__c(Name = '5566', status__c = '新車', CarGeneration__c = 'E84', venderCode__c = '19451', FactoryYearMonth__c= '198801');
        NewCarPool__c newCar02 = new NewCarPool__c(Name = '55661', status__c = '新車', CarGeneration__c = 'E84', carType__c ='116i', venderCode__c = '19451', FactoryYearMonth__c= '201502');
        NewCarPool__c newCar03 = new NewCarPool__c(Name = '55662', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201503');
        NewCarPool__c newCar04 = new NewCarPool__c(Name = '55663', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201504');
        NewCarPool__c newCar05 = new NewCarPool__c(Name = '55664', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201505');
        NewCarPool__c newCar06 = new NewCarPool__c(Name = '55665', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201506');
        NewCarPool__c newCar07 = new NewCarPool__c(Name = '55666', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201507');
        NewCarPool__c newCar08 = new NewCarPool__c(Name = '55667', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201508');
        NewCarPool__c newCar09 = new NewCarPool__c(Name = '55668', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201509');
        NewCarPool__c newCar10 = new NewCarPool__c(Name = '55669', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201510');
        NewCarPool__c newCar11 = new NewCarPool__c(Name = '55660', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201511');
        NewCarPool__c newCar12 = new NewCarPool__c(Name = '556611', status__c = '新車', venderCode__c = '19451', FactoryYearMonth__c= '201512');
        
        list<NewCarPool__c> insertNCPList =  new list<NewCarPool__c>();
        insertNCPList.add(newCar01);
        insertNCPList.add(newCar02);
        insertNCPList.add(newCar03);
        insertNCPList.add(newCar04);
        insertNCPList.add(newCar05);
        insertNCPList.add(newCar06);
        insertNCPList.add(newCar07);
        insertNCPList.add(newCar08);
        insertNCPList.add(newCar09);
        insertNCPList.add(newCar10);
        insertNCPList.add(newCar11);
        insertNCPList.add(newCar12);
        
        insert insertNCPList;
        //更新
        testRecord.ContactDistrict__c = '中山區' ;
        update testRecord;  
    }
    
    //關聯
    static testmethod void TestRelationship()
    {
        //加入自訂設定檔。
        ZipCode__c zipCode = new ZipCode__c(Name='臺北市信義區', ZipCode__c ='110');
        ZipCode__c zipCode2 = new ZipCode__c(Name='臺北市中正區', ZipCode__c ='100');
		insert zipCode;
        insert zipCode2;
        ZipCodeMapping__c zipCodeMapping01 = new ZipCodeMapping__c(
            Name='Acc01', 
            ObjectAPI__c ='Account', 
            CityAPI__c = 'CompanyCity__c', 
            ZipeCodeAPI__c='CompanyPostCode__c',
            AreaAPI__c='CompanyDistrict__c'
       	);
        ZipCodeMapping__c zipCodeMapping02 = new ZipCodeMapping__c(
            Name='Acc02', 
            ObjectAPI__c ='Account', 
            CityAPI__c = 'HomeCity__c', 
            ZipeCodeAPI__c='HomePostCode__c',
            AreaAPI__c='HomeDistrict__c'
       	);
        insert zipCodeMapping01;
        insert zipCodeMapping02;
        
        //string RecTypeId = [select id from RecordType where developerName = 'PersonAccount' and SobjectType = 'Account'].id;
        //加入自訂設定檔。
    	Account testRecord =  new Account(
            LastName='Account01', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );//, recordtypeid = RecTypeId);
        insert testRecord;
        
        Account testRecord2 =  new Account(
            LastName='Account02',   MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;
            
		Relationship__c newRE = new Relationship__c();
        newRE.Keyman__c = testRecord.id;
        newRE.SecondMan__c = testRecord2.id;
        newRE.Relation__c = '同事';
        insert newRE;
        
        TriggerHandler.isRunning = false;
        newRE.Relation__c = '朋友';
        update newRE;
        
        testRecord2.CompanyDistrict__c = '中正區';
        update testRecord2;   
    }
    
    //潛客
    static testmethod void TestLead()
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
        
        Lead testRecord2 =  new Lead(
            LastName='Lead02',  phone = '0912345678', MobilePhone = '0912345678',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區', 
            HomeCity__c = '臺北市', HomeDistrict__c = '信義區'
        );//, recordtypeid = RecTypeId);
        insert testRecord2;
        
        testRecord.CompanyDistrict__c = '中正區';
        update testRecord;
    }
    
    //中古車
    static testmethod void UsedCar()
    {
        UsedCarPool__c UC = new UsedCarPool__c();
        insert UC;
        
        
        UC.inputVIN__c = '5566';
        try{
        	update UC;  
        }
        catch (exception e)
        {
            
        }
        DealerMapping__c NewSetting = new DealerMapping__c(Name='19451', DealerName__c='台北依德');
        insert NewSetting;
        NewCarPool__c newCar = new NewCarPool__c(Name = '5566', status__c = '新車出售', venderCode__c = '19451');
        insert newCar;
        //更新
        update UC;  
        
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567891', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
        Opportunity testRecord =  new Opportunity(
            AccountId = NewAcc.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        insert testRecord;
            
		testRecord.inputVIN__c = '5566';
        try{
        	update testRecord;  
        }
        catch (exception e)
        {
            
        }
    }
    
    
    //調撥單
    static testmethod void TransferCar()
    {
        DealerMapping__c NewSetting = new DealerMapping__c(Name='19451', DealerName__c='台北依德');
        insert NewSetting;
        NewCarPool__c newCar = new NewCarPool__c(Name = '5566', status__c = '新車', venderCode__c='19451');
        insert newCar;
        //更新
        CarTransferForm__c newTransfer = new CarTransferForm__c(InputVIN__c = '5566', TransferTo__c='台北依德');
        insert newTransfer;
    }
    
    //現有車款
    static testmethod void TestAsset()
    {
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
        Asset newASS = new Asset(AccountId = NewAcc.Id, Name='5566');
        insert newASS;
        newASS.Status = '交車';
        update newASS;
    }
    
    //Apex Sharing
    static testmethod void TestApexSharing()
    {
        list<Account> inserAccList = new list<Account>();
        Account testRecord1 =  new Account(
            LastName='Account01', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );
        Account testRecord2 =  new Account(
            LastName='Account02', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );
        Account testRecord3 =  new Account(
            LastName='Account03', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );
        Account testRecord4 =  new Account(
            LastName='Account04', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );
        Account testRecord5 =  new Account(
            LastName='Account05', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );
        Account testRecord6 =  new Account(
            LastName='Account06', MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號',
            CompanyCity__c = '臺北市', CompanyDistrict__c = '信義區'
        );
        inserAccList.add(testRecord1);
        inserAccList.add(testRecord2);
        inserAccList.add(testRecord3);
        inserAccList.add(testRecord4);
        inserAccList.add(testRecord5);
        inserAccList.add(testRecord6);
        insert inserAccList;
        
        list<Opportunity> inserOPPList = new list<Opportunity>();
        Opportunity testOPPRecord1 =  new Opportunity(
            AccountId = testRecord1.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        Opportunity testOPPRecord2 =  new Opportunity(
            AccountId = testRecord2.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        Opportunity testOPPRecord3 =  new Opportunity(
            AccountId = testRecord3.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        Opportunity testOPPRecord4 =  new Opportunity(
            AccountId = testRecord4.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        Opportunity testOPPRecord5 =  new Opportunity(
            AccountId = testRecord5.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        Opportunity testOPPRecord6 =  new Opportunity(
            AccountId = testRecord6.Id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsUsedCar__c = '是',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
        inserOPPList.add(testOPPRecord1);
        inserOPPList.add(testOPPRecord2);
        inserOPPList.add(testOPPRecord3);
        inserOPPList.add(testOPPRecord4);
        inserOPPList.add(testOPPRecord5);
        inserOPPList.add(testOPPRecord6);
        insert inserOPPList;

        DealerMapping__c NewSetting = new DealerMapping__c(Name='19451', DealerName__c='台北依德');
        insert NewSetting;

        NewCarPool__c newCar01 = new NewCarPool__c(Name = '5566', status__c = '新車', CarGeneration__c = 'E84', venderCode__c = '19451', FactoryYearMonth__c= '198801');
        insert newCar01;

        Asset testASSRecord1 =  new Asset(
            AccountId = testRecord1.Id,
            Name='testASS'
        );
        
        list<Asset> inserASSList = new list<Asset>();
        inserASSList.add(testASSRecord1);
        insert inserASSList;

        list<TestCar__c> insertCClist = new list<TestCar__c>();
        //for(integer i=0; i<inserOPPList.size(); i++)
        {
            TestCar__c myCar = new TestCar__c();
            myCar.Name = '阿斯拉';
            myCar.SourceAsset__c = inserASSList[0].id;
            myCar.VIN__c = newCar01.id;
            insertCClist.add(myCar);
        }
        insert insertCClist;
        
        
        //Relationship
		Relationship__c newRE = new Relationship__c();
        newRE.Keyman__c = testRecord1.id;
        newRE.SecondMan__c = testRecord2.id;
        newRE.Relation__c = '同事';
        insert newRE;

        list<user> uList = [select id from user where profileid = '00e7F000001m0BHQAY' and id !=: userinfo.getUserId()];
        
        //聯繫紀錄
        list<worklog__c> insertWLList =  new list<worklog__c>();
        
        //忠誠計劃申請
        list<LoyalProgramMember__c> insertMemberList =  new list<LoyalProgramMember__c>();
        
        //取還車
        list<TestDriveReservation__c> insertReserList = new list<TestDriveReservation__c>();
        
        //問卷
        list<SurveyTaker__c> insertSurveyList = new list<SurveyTaker__c>();
        
        
        test.startTest();
        //跑產生的acc list
        for(integer i=0; i < inserAccList.size(); i++)
        {
            inserAccList[i].OwnerId = uList[0].id;
            
            worklog__c tmpWL = new worklog__c();
            tmpWL.LogCust__c = inserAccList[i].id;
            tmpWL.Category__c = '客戶主檔';
            tmpWL.OwnerId = uList[0].id;
            insertWLList.add(tmpWL);
            
            LoyalProgramMember__c tmpMember = new LoyalProgramMember__c();
            tmpMember.CarOwner__c = inserAccList[i].id;
            tmpMember.Concierge_addno__c = '12345';
            tmpMember.OwnerId = uList[0].id;
            insertMemberList.add(tmpMember);
        }
        insert insertWLList;
        insert insertMemberList;
        
        //opplist
        for(integer i=0; i < inserOPPList.size(); i++)
        {
            TestDriveReservation__c tmpReser = new TestDriveReservation__c();
            tmpReser.Opportunity__c = inserOPPList[i].id;
            //tmpReser.OwnerId = uList[0].id;
            tmpReser.TestCar__c = insertCClist[0].id;
            tmpReser.TestDrivePerson__c = '123';
            tmpReser.TestDriveStatus__c = '已完成';
            tmpReser.ReturnTime__c = system.now();
            insertReserList.add(tmpReser);
        }
        insert insertReserList;
        
        //opplist
        for(integer i=0; i < inserOPPList.size(); i++)
        {
            SurveyTaker__c tmpSurvey = new SurveyTaker__c();
            tmpSurvey.Opportunity__c = inserOPPList[i].id;
            tmpSurvey.TestDriveReservation__c = insertReserList[i].id;
            tmpSurvey.OwnerId = uList[0].id;
            insertSurveyList.add(tmpSurvey);
        }
        insert insertSurveyList;
        

        update inserAccList;
        
        //跑刪除及產生的
        for(integer i=0; i < inserAccList.size(); i++)
        {
            inserAccList[i].OwnerId = userinfo.getUserId();
        }
        update inserAccList;
        
        //跑刪除及產生的
        for(integer i=0; i < insertWLList.size(); i++)
        {
            insertWLList[i].OwnerId = userinfo.getUserId();
        }
        update insertWLList;
        
        //跑刪除及產生的
        for(integer i=0; i < insertMemberList.size(); i++)
        {
            insertMemberList[i].OwnerId = userinfo.getUserId();
        }
        update insertMemberList;
        
        //跑刪除及產生的
        for(integer i=0; i < insertReserList.size(); i++)
        {
            insertReserList[i].OwnerId = userinfo.getUserId();
        }
        update insertReserList;
        
        //跑刪除及產生的
        for(integer i=0; i < insertSurveyList.size(); i++)
        {
            insertSurveyList[i].OwnerId = userinfo.getUserId();
        }
        update insertSurveyList;
        test.stopTest();
    }
}