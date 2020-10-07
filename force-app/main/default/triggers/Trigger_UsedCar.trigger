trigger Trigger_UsedCar on UsedCarPool__c (before insert, before update) 
{
	if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.UsedCarFindVIN(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.UsedCarFindVIN(trigger.new, trigger.old);
        }
    }
}