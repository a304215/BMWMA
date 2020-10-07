global class MarketingTargetBatchJob implements Database.Batchable<sObject> 
{
    String query;

    global MarketingTargetBatchJob(string qq) {
        query = qq;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        update scope;
        //Database.executeBatch(new RunThisBatch(), 500);        
    }

    global void finish(Database.BatchableContext BC) {

    }

}