trigger Trigger_LoyalProgramMember on LoyalProgramMember__c (after insert, after update) 
{
	if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.LoyalSharing(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.LoyalSharing(trigger.new, trigger.old);
        }
    }
}