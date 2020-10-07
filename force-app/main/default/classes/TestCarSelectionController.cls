public with sharing class TestCarSelectionController 
{
	@AuraEnabled
    public static List<TestCar__c> getTestCars()
    {
    	list<TestCar__c> returnList = new list<TestCar__c>();
        for(TestCar__c loopCars: [
            select 	id, UseStatus__c, Brand__c, Branch__c, 
            		CarType__c, VIN__c, Name, CarGeneration__c, Mileage__c, 
            		CarColor__c, FactoryYearMonth__c
            from TestCar__c
            where RetireDate__c = null or RetireDate__c >= today
        	order by Branch__c, VIN__r.CarGeneration__c
        ])
        {
            returnList.add(loopCars);
        }
        
        return returnList;
    }
}