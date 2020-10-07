global class MonthlySalesTargetProcessor implements Database.Batchable<sObject> 
{

    String query;

    global MonthlySalesTargetProcessor() {}

    global Database.QueryLocator start(Database.BatchableContext BC) {
        string year = string.valueOf(date.today().addDays(-1).year());
        string month = string.valueOf(date.today().addDays(-1).month());
        month = month.length() < 2 ? '0' + month : month;
        query = 'select id, OwnerId, OpptyActual__c, DeliverActual__c, ContractActual__c, ' +
             	'	TestDriveActual__c, OpptyContactTimes__c, VisitTimes__c, TestDriveTimes__c, ' +
             	'	OwnerCaringTimes__c, TelephoneTimes__c ' +
	            ' from SalesTarget__c ' +
             	'where TargetYear__c = \'' + year + '\' and  TargetMonth__c = \'' + month + '\'';
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SalesTarget__c> scope) {
        updateMonthlySalesTarget u = new updateMonthlySalesTarget();
        u.rawData = scope;
        u.year = string.valueOf(date.today().addDays(-1).year());
        //偷改
        //u.month = string.valueOf(date.today().addDays(-1).month());
        u.month = string.valueOf(date.today().addDays(-1).month()+100).right(2);
        u.updateData();
    }

    global void finish(Database.BatchableContext BC) {

    }

}