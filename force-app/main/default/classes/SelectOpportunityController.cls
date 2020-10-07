public with sharing class SelectOpportunityController 
{	
    @AuraEnabled
    public static List<Opportunity> getOpportunities()
    {
    	list<Opportunity> returnList = new list<Opportunity>();
        for(Opportunity looopOpp: [
            select 	id, Name, LicensingOfPeople__c, 
            CarType__c, CarGeneration__c, CarColor__c, LicensePlate__c, 
            SelectedCar__r.Brand__c,
            Driver__c, Driver__r.Name, Driver__r.Id, Driver__r.LastName,
            selectedCar__c, selectedCar__r.Name, 
            Estimateddateofnew__c, DeliveryDate__c, LicensingOfDate__c
            from Opportunity
            where stageName = '領牌'
        	order by CloseDate
        ])
        {
            returnList.add(looopOpp);
        }
        
        return returnList;
    }
}