trigger Trigger_SurveyCake on Survey_Cake__c (after insert) 
{
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler_SurveyCake.sentRequest(trigger.new);
        }
    }
}