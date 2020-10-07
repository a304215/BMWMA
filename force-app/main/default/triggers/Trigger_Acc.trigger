trigger Trigger_Acc on Account (before insert, before update, after update) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.AccountQueryZipCode(trigger.new, trigger.old);
            TriggerHandler.combinecontrolduplicateAccount(trigger.new, trigger.old);
            TriggerHandler_Account.syncEntity(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.AccountQueryZipCode(trigger.new, trigger.old);
            TriggerHandler.combinecontrolduplicateAccount(trigger.new, trigger.old);
            TriggerHandler_Account.syncEntity(trigger.new, trigger.old);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
            TriggerHandler.AccountSharing(trigger.new, trigger.old);
        }
    }
}