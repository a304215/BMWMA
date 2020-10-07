global class MarketingSchedule implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        //改使用queue 計算。
        /*
        string query = 'select id '+
            ' from MarketingTargetY__c ' +
            'where TargetYear__c = \'' + string.valueOf(system.today().addDays(-1).year()) +'\'';
        
        MarketingTargetBatchJob be = new MarketingTargetBatchJob(query);
        database.executeBatch(be,1);
        */
        System.enqueueJob(new MarketingTarget_Method());
        
        string query2 = 'select id '+
            ' from Campaign ' +
            'where StartDate <= ' + string.valueOf(system.today().addDays(-1)) + ' and  OpportunityTrackingEndDate__c >='  + string.valueOf(system.today().addDays(-1));
        
        MarketingTargetBatchJob be2 = new MarketingTargetBatchJob(query2);
        database.executeBatch(be2,1);
    }
}