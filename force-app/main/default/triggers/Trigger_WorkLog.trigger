trigger Trigger_WorkLog on WorkLog__c (after insert, after update) 
{
	if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            triggerHandler.WorkLogSharing(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            triggerHandler.WorkLogSharing(trigger.new, trigger.old);
        }
    }
}