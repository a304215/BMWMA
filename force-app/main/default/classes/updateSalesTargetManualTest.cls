@isTest
private class updateSalesTargetManualTest 
{
    @isTest static void test1()
    {
        SalesTarget__c st = new SalesTarget__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(st);
        updateSalesTargetManual u = new updateSalesTargetManual(sc);
        u.startCalculate();

        u.scheduleClearWaveSource();
        u.scheduleClearWaveSource();

        u.checkScheduleStatus();
    }
}