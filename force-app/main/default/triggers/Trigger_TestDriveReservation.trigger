/* 先假設一次只會動用一筆資料吧 */

trigger Trigger_TestDriveReservation on TestDriveReservation__c (before insert, before update, after insert, after update) 
{
	/* 先假設一次只會動用一筆資料吧 */
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.TestDriveOnlyOne(trigger.new, trigger.old);
            TriggerHandler_TestDriveceReservation.initialD(trigger.new);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.TestDriveOnlyOne(trigger.new, trigger.old);
        }
    }
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.TestDriveSharing(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.TestDriveSharing(trigger.new, trigger.old);
        }
    }
}