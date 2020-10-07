@isTest 
public class MigrationHelper_TestMethod {
	//Migration。
    static testmethod void TestMarketingTarget()
    {
    	DearInfo__c NewDear = new DearInfo__c(
            CustomerName__c = 'LUKE', CustomerNO__c = '5566', 
            CraetedDate__c = '2010-01-01T00:00:00.000GMT+08:00'
        );
        insert NewDear;
        list<string> tempList = new list<string>();
        tempList.add(NewDear.id);
        
        Test.startTest();
        MigrationHelper.newAll(tempList);
        
        MigrationHelper mst = new MigrationHelper('select id from DearInfo__c');
        Id batchId = Database.executeBatch(mst);
        Test.stopTest();
    }
}