trigger Trigger_MarketingTarget on MarketingTargetY__c (after insert, after update, before insert, before update) 
{   
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.marketingTargetYear(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.marketingTargetYear(trigger.new, trigger.old);
        }
    }
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.calcularMarketingExactly(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.calcularMarketingExactly(trigger.new, trigger.old);
        }
    }
}