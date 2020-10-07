trigger Trigger_RE on Relationship__c (before insert, before update, after insert, after update) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.syncRelationship(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.syncRelationship(trigger.new, trigger.old);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.RelationSharing(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.RelationSharing(trigger.new, trigger.old);
        }
    }
}