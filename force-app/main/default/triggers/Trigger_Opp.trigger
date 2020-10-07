trigger Trigger_Opp on Opportunity (before insert, before update) 
{    
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.FillOppInfoByAcc(trigger.new, trigger.old);
            TriggerHandler.OpportunityFindVIN(trigger.new, trigger.old);
            TriggerHandler.OpportunityQueryZipCode(trigger.new, trigger.old);
            TriggerHandler.OpportunityUpdateFContactRecord(trigger.new, trigger.old);
            TriggerHandler.OpportunityUpperCase(trigger.new, trigger.old);
            TriggerHandler.marketingTargetOpportunity(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.OpportunityFindVIN(trigger.new, trigger.old);
            TriggerHandler.OpportunityQueryZipCode(trigger.new, trigger.old);
            TriggerHandler.OpportunityUpdateFContactRecord(trigger.new, trigger.old);
            TriggerHandler.OpportunityUpperCase(trigger.new, trigger.old);
            TriggerHandler.marketingTargetOpportunity(trigger.new, trigger.old);
        }
    }
}