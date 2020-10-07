trigger Trigger_Lead on Lead (before insert, before update, after insert) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            for(lead loopLead: trigger.new)
            {
                loopLead.SellingGeneration__c = null;
            }
            TriggerHandler.LeadQueryZipCode(trigger.new, trigger.old);
            TriggerHandler.combinecontrolduplicateLead(trigger.new, trigger.old);
            TriggerHandler.marketingTargetLead(trigger.new, trigger.old);
            //TriggerHandler_Lead.changeMobile(trigger.new);
            TriggerHandler_Lead.syncEntity(trigger.new, trigger.old);
            
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.LeadQueryZipCode(trigger.new, trigger.old);
            TriggerHandler.combinecontrolduplicateLead(trigger.new, trigger.old);
            TriggerHandler.marketingTargetLead(trigger.new, trigger.old);
            TriggerHandler_Lead.syncEntity(trigger.new, trigger.old);
        }
    }

    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler_Lead.syncToFB(trigger.new);
        }
    }
}