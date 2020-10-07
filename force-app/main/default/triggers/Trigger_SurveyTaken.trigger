trigger Trigger_SurveyTaken on SurveyTaker__c (after insert, after update) 
{
	if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.SurveySharing(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.SurveySharing(trigger.new, trigger.old);
        }
    }
}