public class SelectCarUserController {
	@AuraEnabled
    public static Opportunity getOpportunity(string OpportunityId)
    {
        Opportunity returnRecord;
        returnRecord = [
            select 	id, Name, LicensingOfPeople__c, 
            CarType__c, CarGeneration__c, CarColor__c, LicensePlate__c, 
            SelectedCar__r.Brand__c,
            Driver__c, Driver__r.Name, 
            SelectedCar__c, SelectedCar__r.Name, LicensingOfDate__c
            from opportunity 
			where id=:OpportunityId];
        
        return returnRecord;
    }
}