@isTest(seeAllData=true)
public class AnyEventCalCtrlTest {
	static testMethod void getEventsTest() {
        AnyEventCalCtrl.getEvents('TestDriveReservation__c', 'Title__c', 'StartTime__c', 'EndTime__c', 'Description__c', 'OwnerId', true, 'TestCar__c', 'Opportunity__c', '', 'CarUseType__c', 'OwnerName__c');
        AnyEventCalCtrl.getEvents('TestDriveReservation__c', 'Title__c', 'StartTime__c', 'EndTime__c', 'Description__c', 'OwnerId', false, 'TestCar__c', 'Opportunity__c', '', 'CarUseType__c', 'OwnerName__c');
    }
    static testMethod void upsertEventsTest() {
        AnyEventCalCtrl.upsertEvents('{"title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd"}', 'TestDriveReservation__c', 'Title__c', 'StartTime__c', 'EndTime__c', 'Description__c', 'OwnerId', 'TestCar__c', 'Opportunity__c', '', 'CarUseType__c', 'OwnerName__c');
    	AnyEventCalCtrl.upsertEvents('{"id":"sadad","title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd"}', 'TestDriveReservation__c', 'Title__c', 'StartTime__c', 'EndTime__c', 'Description__c', 'OwnerId', 'TestCar__c', 'Opportunity__c', '', 'CarUseType__c', 'OwnerName__c');
    }
    static testMethod void deleteEventTest() {
        AnyEventCalCtrl.deleteEvent('00U41000006bFIA', 'TestDriveReservation__c', 'Title__c', 'StartTime__c', 'EndTime__c', 'Description__c', 'OwnerId');
    }
    static testMethod void crudSecurityTest() {
        AnyEventCalCtrl.isAccessible('TestDriveReservation__c');
        AnyEventCalCtrl.isAccessible('TestDriveReservation__c','Title__c');
        AnyEventCalCtrl.isCreateable('TestDriveReservation__c');
        AnyEventCalCtrl.isDeletable('TestDriveReservation__c');
    }
}