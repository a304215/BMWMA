/******** 
 * Trigger 的TestMethod。
 * TriggerHandler_Line_Push、Trigger_Line_Push
 * 
 *********/
@isTest 


public with sharing class Trigger_TestMethod99 
{
    static testmethod void Test_LinePush()
    {
        Account ACC = new Account();
        ACC.Name = '5566';
        insert ACC;

        Line_Account__c LAccount = new Line_Account__c();
        insert LAccount;

        Line_User__c LUser = new Line_User__c();
        LUser.Account__c = ACC.id;
        LUser.UDID__c = '5566';
        LUser.Line_Account__c = LAccount.id;
        insert LUser;

        test.startTest();
        Line_Push__c thePush = new Line_Push__c();
        thePush.Account__c = ACC.id;
        thePush.Line_Account__c = LAccount.id;
        insert thePush;
        test.stopTest();
    }
}