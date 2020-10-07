@isTest

public with sharing class FbLead_TestMethod 
{
    static testmethod void FbLead_TestMethod() 
    {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponesLINE('fb'));
        Test.startTest();
        lead test1 = new lead(lastname='2131', leadcap__Facebook_Lead_ID__c='3211', fbMobilePhone__c ='+886911123456');
        lead test2 = new lead(lastname='2132', leadcap__Facebook_Lead_ID__c='3212', fbMobilePhone__c ='+8860911123456');
        lead test3 = new lead(lastname='2133', leadcap__Facebook_Lead_ID__c='3213', fbMobilePhone__c ='0911123456');
        list<lead> insertList = new list<lead>();
        insertList.add(test1);
        insertList.add(test2);
        insertList.add(test3);
        insert insertList;
        Test.stopTest();
    }
}