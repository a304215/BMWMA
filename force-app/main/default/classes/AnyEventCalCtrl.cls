/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Get, Upsert and Delete relevent sObject declared in the Lightning and Community Builder
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Randy Grewal   <rgrewal@salesfore.com>
* @modifiedBy     Randy Grewal   <rgrewal@salesfore.com>
* @maintainedBy   Randy Grewal   <rgrewal@salesfore.com>
* @version        1.1
* @created        2017-05-01
* @modified       2017-06-12
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            rgrewal@salesfore.com
* 2017-06-08     	Added option to filter query by logged in user and removed System.debug logs
* 2017-06-12		Security Review Fixes:
*					Added isAccessible(), isCreateable(), isDeletable() for CRUD/FLS Enforcement fix
*					Added Typecasting to all injected field API names for SOQL Injection fix
*					Added "with sharing" keyword to Class for Sharing Violation Fix
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class AnyEventCalCtrl {
    @AuraEnabled
    public static List<EventObj> getEvents(String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, Boolean filterByUserField, String lookupTestCarField, String lookupOptField, String myRecordId, String carUseTypeField, String ownerNameField){
        String q = 'SELECT Id,' + 
            String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +
            String.valueOf(lookupTestCarField) + ',' +
            String.valueOf(lookupOptField) + ',' +
            String.valueOf(carUseTypeField) + ',' +
            String.valueOf(ownerNameField) + ',' +
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName) + ' WHERE ' +
            ' (' +String.valueOf(lookupOptField) + ' = \'' + String.valueOf(myRecordId) + '\' OR ' +
            String.valueOf(lookupTestCarField) + ' = \'' + String.valueOf(myRecordId) + '\' ) AND ' +
            String.valueOf(userField) + ' = \'' + UserInfo.getUserId() + '\'' ;
        if (!filterByUserField) {
            q = 'SELECT Id,' + 
                String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +
            String.valueOf(lookupTestCarField) + ',' +
            String.valueOf(lookupOptField) + ',' +
            String.valueOf(carUseTypeField) + ',' +
            String.valueOf(ownerNameField) + ',' +
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName) +
            ' WHERE (' +String.valueOf(lookupOptField) + ' = \'' + String.valueOf(myRecordId) + '\' OR ' +
            String.valueOf(lookupTestCarField) + ' = \'' + String.valueOf(myRecordId) + '\' )';
        } 
        system.debug('====luke1: ' + myRecordId);
        system.debug('====luke2: ' + q);
        
        List<sObject> sObjectList = Database.query(q);
        
        List<EventObj> eventRecords = new List<EventObj>();
        if(isAccessible(sObjectName)) {
            for (sObject obj : sObjectList) {
                EventObj newEv = new EventObj(obj.Id,
                                              String.valueOf(obj.get(titleField)),
                                              DateTime.valueOf(obj.get(startDateTimeField)),
                                              DateTime.valueOf(obj.get(endDateTimeField)),
                                              String.valueOf(obj.get(descriptionField)),
                                              String.valueOf(obj.get(userField)),
                                              String.valueOf(obj.get(lookupTestCarField)),
                                              String.valueOf(obj.get(lookupOptField)),
                                              String.valueOf(obj.get(carUseTypeField)),
                                              String.valueOf(obj.get(ownerNameField))
                                             );
                system.debug('===luke : ' + newEv);
                eventRecords.add(newEv);
            }
        }
        return eventRecords;
    }
    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, String lookupTestCarField, String lookupOptField, String myRecordId, String carUseTypeField, String ownerNameField){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        system.debug('=====luke: ' + myRecordId);
        sObject newRecord = Schema.getGlobalDescribe().get(sObjectName).newSObject(); 
        if (upsertingEvent.Id != null && isAccessible(sObjectName,'Id')){
            newRecord.put('Id',upsertingEvent.Id);
        } 
        if (isAccessible(sObjectName,titleField)) {
            newRecord.put(titleField, upsertingEvent.title);
        }
        if (isAccessible(sObjectName,startDateTimeField)) {
            newRecord.put(startDateTimeField, upsertingEvent.startDateTime);
        }
        if (isAccessible(sObjectName,endDateTimeField)) {
            newRecord.put(endDateTimeField, upsertingEvent.endDateTime);
        }
        if (isAccessible(sObjectName,descriptionField)) {
            newRecord.put(descriptionField, upsertingEvent.description);
        }
        if(!string.isBlank(upsertingEvent.testCardId) )
        {	
         	if (isAccessible(sObjectName,lookupTestCarField)) {
                newRecord.put(lookupTestCarField, upsertingEvent.testCardId);
            }    
        }
        if(!string.isBlank(upsertingEvent.OptId) )
        {
            if (isAccessible(sObjectName,lookupOptField)) {
                newRecord.put(lookupOptField, upsertingEvent.OptId);
            }
        }
		system.debug('====luke: ' + upsertingEvent.carUseType);
        if(upsertingEvent.carUseType != 'undifined')
        {
            if (isAccessible(sObjectName,carUseTypeField)) {
                newRecord.put(carUseTypeField, upsertingEvent.carUseType);
            }
        }

        try {
            upsert newRecord;
            system.debug('====luke11: ' + carUseTypeField);
            system.debug('====luke21: ' + ownerNameField);
            system.debug('====luke1: ' + newRecord.get(carUseTypeField));
            system.debug('====luke2: ' + newRecord.get(ownerNameField));
            
            //重下Query，抓取OwnerName。
            String q = 'SELECT Id,' + 
            String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +
            String.valueOf(lookupTestCarField) + ',' +
            String.valueOf(lookupOptField) + ',' +
            String.valueOf(carUseTypeField) + ',' +
            String.valueOf(ownerNameField) + ',' +
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName) + ' WHERE ' +
            ' id = \'' + newRecord.id + '\'' ;
            
            List<sObject> sObjectList = Database.query(q);
            sObject queryRecord = sObjectList[0];
            
            EventObj newEv = new EventObj(queryRecord.Id,
                                  String.valueOf(queryRecord.get(titleField)),
                                  DateTime.valueOf(queryRecord.get(startDateTimeField)),
                                  DateTime.valueOf(queryRecord.get(endDateTimeField)),
                                  String.valueOf(queryRecord.get(descriptionField)),
                                  String.valueOf(queryRecord.get(userField)),
                                  String.valueOf(queryRecord.get(lookupTestCarField)),
                                  string.isBlank(upsertingEvent.OptId)?'':String.valueOf(queryRecord.get(lookupOptField)),
                                  String.valueOf(queryRecord.get(carUseTypeField)),
                                  String.valueOf(queryRecord.get(ownerNameField))
                                 );
            
            /*
            EventObj newEv = new EventObj(newRecord.Id,
                                  String.valueOf(newRecord.get(titleField)),
                                  DateTime.valueOf(newRecord.get(startDateTimeField)),
                                  DateTime.valueOf(newRecord.get(endDateTimeField)),
                                  String.valueOf(newRecord.get(descriptionField)),
                                  String.valueOf(newRecord.get(userField)),
                                  String.valueOf(newRecord.get(lookupTestCarField)),
                                  string.isBlank(upsertingEvent.OptId)?'':String.valueOf(newRecord.get(lookupOptField)),
                                  String.valueOf(newRecord.get(carUseTypeField)),
                                  String.valueOf(newRecord.get(ownerNameField))
                                 );
			*/
            return newEv;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
    }
    @AuraEnabled
    public static String deleteEvent(String eventId, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField){
        String q = 'SELECT Id,' + 
                titleField + ',' + 
                startDateTimeField + ',' +
                endDateTimeField + ',' +
                descriptionField + ',' +
                userField + ' FROM ' + 
                sObjectName + ' WHERE Id = \'' + eventId  + '\'';
        List<sObject> sObjectList = Database.query(q);
        try {
            if(isDeletable(sObjectName)) {
                delete sObjectList;
            }
            return eventId;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
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
        @AuraEnabled
        public String ownerName {get;set;}

        
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
            //this.ownerName = oname;
        }
        
        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
            this.owner = o;
        }
        
    }
    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }
    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }
    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }
    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }
    
    @AuraEnabled
    public static  map<string, string> showMeTheFieldLabel(string objectAPI)
    {
        map<string, string> returnMap = new map<string, string>();
        Map<String , Schema.SObjectField> fieldNameMap = Schema.getGlobalDescribe().get(objectAPI).getDescribe().fields.getMap();
        for(string fieldName: fieldNameMap.keyset())
        {
            //System.debug('===luke ##Field API Name='+fieldName + ': ' +fieldNameMap.get(fieldName).getDescribe().getLabel());// list of all field API name
          	returnMap.put(fieldName,fieldNameMap.get(fieldName).getDescribe().getLabel());
        }
        return returnMap;
    }
    
    @AuraEnabled
    public static  string doNothing(string inputString)
    {
        return 'good';
    }
    
    
    @AuraEnabled
    public static  list<string> doMyCarType(string inputString)
    {
        List<String> returnList = new List<String>();
		//Schema.DescribeFieldResult fieldResult = ObjectApiName.FieldApiName.getDescribe();
		//
		//Map<String , Schema.SObjectField> fieldNameMap = Schema.getGlobalDescribe().get('TestDriveReservation__c').getDescribe().fields.get('carUseType__c').getDescribe().getPicklistValues();
		//SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
		for( Schema.PicklistEntry pickListVal : TestDriveReservation__c.carUseType__c.getDescribe().getPicklistValues()){
			returnList.add(pickListVal.getLabel());
		}     
		return returnList;
    }
}