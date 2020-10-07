/******** 
 * Survey Cake Test Method
 * SurveyHook
 * Trigger_SurveyCake
 * TriggerHandler_SurveyCake
 *
 *********/
@isTest
public with sharing class SurveyCake_TestMethod 
{
    static testmethod void  SurveyCake_TestMethod() 
    {
        Campaign tempCA = new Campaign();
        tempCA.Name = '55556655665566556666';
        tempCA.svid__c = '5566';
        tempCA.IV_Key__c = '5566556655665566';
        tempCA.Hash_Key__c = '5566556655665566';
        tempCA.Objective__c = 'Conquest New Lead 顧客開發';
        insert tempCA;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponesSurveyCake());
        RestRequest req  = new RestRequest();
    	RestResponse res  = new RestResponse();
    	req.requestURI = '/service/apexrest/Surveyhook/12345';
        req.addParameter('callback', 'test');
        req.addParameter('svid', '5566');
        req.addParameter('hash', '5566556655665566');
    	req.httpMethod = 'POST';
    	req.requestBody = blob.valueOf(''); 
    	RestContext.request = req;
    	RestContext.response = res;
    	Test.startTest();
    	SurveyHook.doPost();
        Test.stopTest();
    }
}