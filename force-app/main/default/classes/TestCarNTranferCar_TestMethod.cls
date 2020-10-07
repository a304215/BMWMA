@isTest
public class TestCarNTranferCar_TestMethod 
{
    static testmethod void SelectTestDriveReservation()
    {
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
        Opportunity testRecord =  new Opportunity(
            AccountId=newAcc.id,
            Name='testOPP', closeDate = system.today(), stageName = '簽約', CustomerRating__c = 'A',
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
        );
            insert testRecord;
        
        asset tempASS = new asset(name = '5566', accountid = NewAcc.id);
        insert tempASS;
        
        TestCar__c data1 = new TestCar__c(SourceAsset__c = tempASS.id);
        insert data1;
        
        TestDriveReservation__c data2 = new TestDriveReservation__c(TestCar__c = data1.id, opportunity__c = testRecord.id, TestDriveStatus__c  = '已還車');
        insert data2;
        
        SelectTestDriveReservationController.getReservations();
        SelectTestDriveReservationController.getNextSubject();
        SelectTestDriveReservationController.saveTheReservation(data2.id,'A','很好開',string.valueOf(system.today()),'簽訂合約', null, '');
    }
    
    
    static testmethod void SelectOpportunity()
    {
        DealerMapping__c NewSetting = new DealerMapping__c(Name='19451', DealerName__c='台北依德');
        insert NewSetting;
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        NewCarPool__c NewCar = new NewCarPool__c(Name='LUKE56', venderCode__c='19451', Status__c = '新車');
        insert NewCar;
        Opportunity testRecord =  new Opportunity(
            Name='testOPP', closeDate = system.today(), stageName = '領牌', AccountId = NewAcc.Id,
            Mobile__c = '1234567890', HomePhone__c = '1234', CompanyPhone__c = '12345', Fax__c = '1234',
            ContactMethod__c = '電子郵件', Email__c = 'aaa@aa.aa', 
            MainAddress__c = '公司', 
            ContactCity__c = '臺北市', ContactDistrict__c = '信義區', ContactStree__c  ='基隆路一段',
            CustomerRating__c = 'E', inputVIN__c = 'LUKE56',
            IsRenewal__c = '否', SellingBrand__c = 'BMW', SellingGeneration__c = 'F48', SellingCarType__c = 'X1 sDrive20i', 
            CurrentCarBrand__c = 'AUDI'
		);
        insert testRecord;
        
        SelectCarUserController.getOpportunity(testRecord.id);
        SelectOpportunityController.getOpportunities();
        CarUserModifiedController.getAccount(NewAcc.Id);
        CarUserModifiedController.saveTheWorld(
        	testRecord.id, '2018-01-01', '2018-01-01', '', 'LUKK', 'KUO', 'A987654321', '男性', 
            '電話聯絡', '行動電話', '1234567890', '1234567890', '1234567890', '1234567890', '2000-01-01', 'false','aaa@aaa.aa',
            '住家', '臺北市', '信義區', '基隆路一段', '臺北市', '信義區', '基隆路一段'
        );
        CarUserModifiedController.saveTheWorld(
        	testRecord.id, '2018-01-01', '2018-01-01', NewAcc.Id, 'LUKK2', 'KUO2', 'A987654320', '男性', 
            '電話聯絡', '行動電話', '1234567890', '1234567890', '1234567890', '1234567890', '2000-01-01', 'false','aaa@aaa.aa',
            '住家', '臺北市', '信義區', '基隆路一段', '臺北市', '信義區', '基隆路一段'
        );
        
        PicklistFieldController.getAccountInfo(NewAcc.Id);
        CarRelationshipController.getOpportunity(testRecord.id);
        list<account> theList = [select id from Account];
        CarRelationshipController.saveRelation('', '', '', '', '', '父子', theList[0].id,theList[1].id);
        CarRelationshipController.getRelationship(theList[0].id,theList[1].id);
    }
}