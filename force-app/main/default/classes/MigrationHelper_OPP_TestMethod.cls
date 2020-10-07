@isTest
public class MigrationHelper_OPP_TestMethod {
	//Migration。
    static testmethod void TestMigration()
    {
    	MigrationOppty__c NewOPP = new MigrationOppty__c(
            AccountName__c = 'LUKE', OpptyNo__c = '5566', 
            CreatDateTime__c = '01/01/201000:00:00',
            BDAY__c = '2018/1/1',
            CompetitorBrand1__c = 'NULL'
        );
        insert NewOPP;
        list<string> tempList = new list<string>();
        tempList.add(NewOPP.id);
        
        Test.startTest();
        MigrationHelper_OPP.newAll(tempList);
        
        MigrationHelper_OPP mst = new MigrationHelper_OPP('select id from MigrationOppty__c');
        Id batchId = Database.executeBatch(mst);
        Test.stopTest();
    }
}