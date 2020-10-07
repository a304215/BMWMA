public class SelectTestDriveReservationController {
    @AuraEnabled
	public static list<TestDriveReservation__c> getReservations()
    {
        list<TestDriveReservation__c> returnList = new list<TestDriveReservation__c>();
        for(TestDriveReservation__c loopReser: [
            select id, NewSurvey__c, Opportunity__c, Opportunity__r.Name, TestCar__r.Name, CarType__c, CarUseType__c, StartTime__c, EndTime__c, TestDriveStatus__c,
            UsedTime__c, ReturnTime__c
            from TestDriveReservation__c
            where TestDriveStatus__c = '已還車' and Opportunity__c != null
            order by StartTime__c desc
		])
        {
            returnList.add(loopReser);
        }
        
        return returnList;
    }
    
    
    @AuraEnabled
	public static list<string> getNextSubject()
    {        
        list<string> returnList = PicklistFieldController.getDependentOptionsImpl('WorkLog__c', 'Category__c', 'NextWorkType__c').get('有望客戶');

        return returnList;
    }
    
    @AuraEnabled
	public static void saveTheReservation(string inputId, string inputRating, string inputDescription, string inputDate, string inputSubject, boolean inputCheck, string inputReason)
    {    
        
        try 
        {
            TestDriveReservation__c tempRecord = new TestDriveReservation__c(id=inputId);
            tempRecord.sys_NextSubject__c = inputSubject;
            tempRecord.sys_ContactDescription__c = inputDescription;
            tempRecord.sys_CustomerRating__c = inputRating;
            tempRecord.sys_NextDate__c = Date.valueOf(inputDate);
            tempRecord.sys_NoChecking__c = (inputCheck==null)?false:inputCheck;
            tempRecord.sys_ReasonOfNonCheck__c = inputReason;
            update tempRecord;
        }
        catch (Exception e) 
        {
            string errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            	errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            }
            throw new AuraHandledException(errorMsg);
		}
    }
    
    //改用inputField 來抓。
    /*@AuraEnabled
	public static list<string> getRating()
    {   
        //'CustomerRating__c'
        list<string> returnList = PicklistFieldController.getDependentOptionsImpl('WorkLog__c', 'Category__c', 'NextWorkType__c').get('有望客戶');

        return returnList;
    }
	*/
}