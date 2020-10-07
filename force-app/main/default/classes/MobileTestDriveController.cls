public with sharing class MobileTestDriveController {
    
    @AuraEnabled  //門市跟車。
    public static Map<string,List<TestCar__c>> getDependentOptionsCard(string objApiName){
        Map<string,List<TestCar__c>> objResults = new Map<string,List<TestCar__c>>();
        list<string> StatusList = Label.Cons_TestDriveStatus.split(';');
        
        for(TestCar__c loopCar: [select id, UseStatus__c, Brand__c, Branch__c, 
                                 CarType__c, VIN__c, Name, CarGeneration__c, Mileage__c, 
                                 CarColor__c, FactoryYearMonth__c
                                 from TestCar__c
                                 where (RetireDate__c = null or RetireDate__c >= today) and (TestDriveCarStatus__c IN: StatusList)
                                 order by Branch__c, VIN__r.CarGeneration__c])
        {
            List<TestCar__c> AllList = objResults.get('所有門市');
            if(AllList == null)
            {
                AllList = new list<TestCar__c>();
                objResults.put('所有門市', AllList);                
            }
            AllList.add(loopCar);
            
            List<TestCar__c> BranchList = objResults.get(loopCar.Branch__c);
            if(BranchList == null)
            {
                BranchList = new list<TestCar__c>();
                objResults.put(loopCar.Branch__c, BranchList);
            }
            BranchList.add(loopCar);
        }
        
        system.debug('objResults--->' + objResults);
        return objResults;
    }
    
    @AuraEnabled  //試駕預約。 呼叫without sharing 的method。
    public static List<TestDriveReservation__c> getDateNCar(string inputDate, string TestCarID, string OpportunityId){
        List<TestDriveReservation__c> returnList = TestCarHelper.getDateNCar(inputDate, TestCarID, OpportunityId);
        return returnList;
    }
    
    @AuraEnabled  //試駕預約。
    public static List<string> getMyDay(string inputDate){
        list<string>returnList = new list<string>();
        
        if(inputDate == null)
        {
            inputDate = string.valueOf(system.today());
        }
        
        date tempDate = date.valueOf(inputDate);
        
        for(integer i=0; i<7; i++)
        {
        	returnList.add(string.valueOf(tempDate.toStartofWeek().adddays(i)));
        }
        
        system.debug('===luke: ' + returnList.size());
        return returnList;
    }
    
    @AuraEnabled
    public static  map<string, string> showMeTheFieldLabel(string objectAPI)
    {
        map<string, string> returnMap = new map<string, string>();
        Map<String , Schema.SObjectField> fieldNameMap = Schema.getGlobalDescribe().get(objectAPI).getDescribe().fields.getMap();
        for(string fieldName: fieldNameMap.keyset())
        {
          	returnMap.put(fieldName,fieldNameMap.get(fieldName).getDescribe().getLabel());
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static string upsertEvents(string inputId, string testCarId, string OppId, string carUseType, string description, string startDate, string startTime, string endDate, string endTime, string testDrivePerson)
    {
        string returnString = '';
        TestDriveReservation__c newRecord;
        
        if (string.isBlank(inputId) )
        {
           newRecord = new TestDriveReservation__c();
        }
        else
        {
            newRecord = new TestDriveReservation__c(id = inputId);
        }
		//title 無用處。
        //newRecord.Title__c = upsertingEvent.title;
        //
        //
        system.debug(startDate);
        system.debug(endDate);
        newRecord.StartTime__c = datetime.valueOf(startDate+' '+startTime+':00+08:00');
        newRecord.EndTime__c = datetime.valueOf(endDate+' '+endTime+':00+08:00');
        newRecord.Description__c = description;
        newRecord.TestDrivePerson__c = testDrivePerson;
        if(!string.isBlank(testCarId) )
        {
            newRecord.TestCar__c = testCarId;
        }
        if(!string.isBlank(OppId) )
        {
            newRecord.Opportunity__c = OppId;
        }
        newRecord.CarUseType__c = carUseType;  
        
        try {
            upsert newRecord;
        } catch (Exception e) {
            string errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            }
            throw new AuraHandledException(errorMsg);
            System.debug( e.getMessage() );
            return null;
        }
        return returnString;
    }
    
    @AuraEnabled
    public static string cancelEvents(String inputId){
        TestDriveReservation__c newRecord;
        newRecord = new TestDriveReservation__c(id = inputId);
        newRecord.TestDriveStatus__c = '已取消';

        try {
            upsert newRecord;
		} catch (Exception e) {
            System.debug(e.getMessage());
		}
        return null;
    }
    
    @AuraEnabled
    public static  String getOPPName(string OPPId, string TDRID)
    {
        Opportunity tempOPP = new Opportunity(Name = '');

        //一般而言會是只有一筆的啦。
		for(Opportunity loopOPP: [
            select 	id, Name
            from Opportunity
            where id=:OPPId])
        {
          	tempOPP = loopOPP;
        }
        
        //一般而言會是只有一筆的啦。
        //因為會有時間差，所以這裡改由這個值代替。
        for(TestDriveReservation__c loopTDR: [
            select 	id, Name, TestDrivePerson__c
            from TestDriveReservation__c
            where id=:TDRID])
        {
          	tempOPP.Name = loopTDR.TestDrivePerson__c;
        }
        
        return tempOPP.Name;
    }
}