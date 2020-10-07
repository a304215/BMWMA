public without sharing class TestCarReservationController 
{
	@AuraEnabled
    public static List<TestDriveReservation__c> getReservations(string TestCarID, string OpportunityId)
    {
        list<TestDriveReservation__c> returnList;
        if(string.isBlank(TestCarID))
        {
            returnList = TestCarHelper.getMyReservations();
        }
        else
        {
            returnList = TestCarHelper.getReservations(TestCarID, OpportunityId);
        }
        
        return returnList;
    }
    
    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        TestDriveReservation__c newRecord;
        
        if (upsertingEvent.Id != null)
        {
            newRecord = new TestDriveReservation__c(id = upsertingEvent.Id);
        }
        else
        {
            newRecord = new TestDriveReservation__c();
        }
       	newRecord.Title__c = upsertingEvent.title;
        newRecord.StartTime__c = upsertingEvent.startDateTime;
        newRecord.EndTime__c = upsertingEvent.endDateTime;
        newRecord.Description__c = upsertingEvent.description;
        if(!string.isBlank(upsertingEvent.testCardId) )
        {
        	newRecord.TestCar__c = upsertingEvent.testCardId;
        }
        if(!string.isBlank(upsertingEvent.OptId) )
        {
        	newRecord.Opportunity__c = upsertingEvent.OptId;
        }
        newRecord.CarUseType__c = upsertingEvent.carUseType;
        newRecord.TestDrivePerson__c = upsertingEvent.testDrivePerson;

        try {
            upsert newRecord;
            
            //重下Query，抓取OwnerName。
            String q = 'SELECT Id, Name, Title__c, StartTime__c, EndTime__c, Description__c, OwnerId, ' +
            ' TestCar__c, Opportunity__c, CarUseType__c, OwnerName__c, TestDriveStatus__c, TestDrivePerson__c ' + 
            ' FROM TestDriveReservation__c ' + 
            ' WHERE id = \'' +  newRecord.id + '\'' ;
            
            List<sObject> sObjectList = Database.query(q);
            sObject queryRecord = sObjectList[0];
            
            EventObj newEv = new EventObj(queryRecord.Id,
                                  String.valueOf(queryRecord.get('Title__c')),
                                  DateTime.valueOf(queryRecord.get('StartTime__c')),
                                  DateTime.valueOf(queryRecord.get('EndTime__c')),
                                  String.valueOf(queryRecord.get('Description__c')),
                                  String.valueOf(queryRecord.get('OwnerId')),
                                  String.valueOf(queryRecord.get('TestCar__c')),
                                  string.isBlank(upsertingEvent.OptId)?'':String.valueOf(queryRecord.get('Opportunity__c')),
                                  String.valueOf(queryRecord.get('CarUseType__c')),
                                  String.valueOf(queryRecord.get('OwnerName__c'))
                                 );
            newEv.driveStatus = String.valueOf(queryRecord.get('TestDriveStatus__c'));
            newEv.testDrivePerson = String.valueOf(queryRecord.get('TestDrivePerson__c'));
            return newEv;
		} catch (Exception e) {
            string errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            	errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            }
            throw new AuraHandledException(errorMsg);
            System.debug(e.getMessage());
            return null;
		}
    }
    
    @AuraEnabled
    public static EventObj cancelEvents(String sEventObj){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        TestDriveReservation__c newRecord;
        
        if (upsertingEvent.Id != null)
        {
            newRecord = new TestDriveReservation__c(id = upsertingEvent.Id);
        }
        else
        {
            newRecord = new TestDriveReservation__c();
        }
       	newRecord.Title__c = upsertingEvent.title;
        newRecord.StartTime__c = upsertingEvent.startDateTime;
        newRecord.EndTime__c = upsertingEvent.endDateTime;
        newRecord.Description__c = upsertingEvent.description;
        if(!string.isBlank(upsertingEvent.testCardId) )
        {
        	newRecord.TestCar__c = upsertingEvent.testCardId;
        }
        if(!string.isBlank(upsertingEvent.OptId) )
        {
        	newRecord.Opportunity__c = upsertingEvent.OptId;
        }
        newRecord.CarUseType__c = upsertingEvent.carUseType;
        newRecord.TestDriveStatus__c = '已取消';
        newRecord.TestDrivePerson__c = upsertingEvent.testDrivePerson;

        try {
            upsert newRecord;
            
            //重下Query，抓取OwnerName。
            String q = 'SELECT Id, Name, Title__c, StartTime__c, EndTime__c, Description__c, OwnerId, ' +
            ' TestCar__c, Opportunity__c, CarUseType__c, OwnerName__c, TestDriveStatus__c, TestDrivePerson__c ' + 
            ' FROM TestDriveReservation__c ' + 
            ' WHERE id = \'' +  newRecord.id + '\'' ;
            
            List<sObject> sObjectList = Database.query(q);
            sObject queryRecord = sObjectList[0];
            
            EventObj newEv = new EventObj(queryRecord.Id,
                                  String.valueOf(queryRecord.get('Title__c')),
                                  DateTime.valueOf(queryRecord.get('StartTime__c')),
                                  DateTime.valueOf(queryRecord.get('EndTime__c')),
                                  String.valueOf(queryRecord.get('Description__c')),
                                  String.valueOf(queryRecord.get('OwnerId')),
                                  String.valueOf(queryRecord.get('TestCar__c')),
                                  string.isBlank(upsertingEvent.OptId)?'':String.valueOf(queryRecord.get('Opportunity__c')),
                                  String.valueOf(queryRecord.get('CarUseType__c')),
                                  String.valueOf(queryRecord.get('OwnerName__c'))
                                 );
            newEv.driveStatus = String.valueOf(queryRecord.get('TestDriveStatus__c'));
            newEv.testDrivePerson = String.valueOf(queryRecord.get('TestDrivePerson__c'));
            return newEv;
		} catch (Exception e) {
            System.debug(e.getMessage());
            return null;
		}
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
    public static  TestCar__c getTestCarInfo(string TestCarId)
    {
        //一般而言會是只有一筆的啦。
        TestCar__c returnRecord = new TestCar__c();
        for(TestCar__c loopCars: [
            select 	id, UseStatus__c, Brand__c, Branch__c, 
            		CarType__c, VIN__c, VIN__r.Name, Name, CarGeneration__c, Mileage__c, 
            		CarColor__c, FactoryYearMonth__c 
            from TestCar__c
            where id=:TestCarId
        	order by Name])
        {
          	returnRecord = loopCars;
        }
        return returnRecord;
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
    
    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String testCardId {get;set;}
        @AuraEnabled
        public String OptId {get;set;}
        @AuraEnabled
        public String carUseType {get;set;}
        //使用偷吃步，後面再給值。
        @AuraEnabled
        public String driveStatus {get;set;}
        @AuraEnabled
        public String testDrivePerson {get;set;}
        
        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o, String tc, String oi, String cut, String oname){
            this.Id = i;
            //this.title = t+oname;
            this.title = oname;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
            this.owner = o;
            this.testCardId = tc;
            this.OptId = oi;
            this.carUseType = cut;
        }
    }
}