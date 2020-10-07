trigger Trigger_Campaign on Campaign (after insert, after update)
{    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.calcularCampaign(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.calcularCampaign(trigger.new, trigger.old);
        }
    }
}