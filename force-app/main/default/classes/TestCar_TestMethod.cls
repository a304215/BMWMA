@isTest 
public class TestCar_TestMethod {
	static testmethod void TestCarSelection(){
        Account NewAcc = new Account(
            LastName='LUKE', PersonalID__c='A123456789', Gender__pc='男性', 
            MainContactNumber__c = '行動電話', PersonMobilePhone='1234567890', 
            MainAddress__c='住家', HomeCity__c='臺北市', HomeDistrict__c='信義區', HomeStreet__c ='基隆路一段333號'
        );
        insert NewAcc;
        
    	Opportunity testRecord =  new Opportunity(
            AccountId = NewAcc.id,
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
        
        TestCar__c data1 = new TestCar__c(SourceAsset__c = tempASS.id, TestDriveCarStatus__c = '可使用');
        insert data1;
        
        TestDriveReservation__c data2 = new TestDriveReservation__c(TestCar__c = data1.id, opportunity__c = testRecord.id);
        insert data2;

        TestCarSelectionController.getTestCars();
        TestCarReservationController.getReservations(data1.id, '');
        string dateString = string.valueOf(system.today().adddays(3));
        TestCarReservationController.upsertEvents('{"title":"dasdsad","startDateTime":"'+dateString+'T17:00:00+08:00","endDateTime":"'+dateString+'T19:00:00+08:00","description":"asdasd","OptId":"'+testRecord.id+'","testCardId":"'+data1.id+'"}');
        TestCarReservationController.cancelEvents('{"title":"dasdsad","startDateTime":"'+dateString+'T17:00:00+08:00","endDateTime":"'+dateString+'T19:00:00+08:00","description":"asdasd","OptId":"'+testRecord.id+'","testCardId":"'+data1.id+'"}');
        TestCarReservationController.showMeTheFieldLabel('Account');
        TestCarReservationController.getTestCarInfo('');

        PicklistFieldController.getDependentOptionsCard('TEST');
        TestCarReservationController.getReservations('', '');
        TestCarReservationController.getOPPName(testRecord.id, data2.id);
    }
    

}