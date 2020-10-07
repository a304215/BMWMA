public without sharing class TriggerHandler_TestDriveceReservation {

    public static void initialD(list<TestDriveReservation__c> inputNew)
    {
        for(TestDriveReservation__c loopR: inputNew)
        {
            loopR.LineKey__c = loopR.Opp_LineKey__c;
        }
    }
}