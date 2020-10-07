trigger Trigger_NewCarPool on NewCarPool__c (before insert, before update) {
	if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
        	TriggerHandler.newCarPoolYearMonth(trigger.new, trigger.old);
            TriggerHandler.TransferCarDealerMappign(trigger.new, trigger.old);
            TriggerHandler.newCarPoolImage(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
        	TriggerHandler.newCarPoolYearMonth(trigger.new, trigger.old);
            TriggerHandler.TransferCarDealerMappign(trigger.new, trigger.old);
            TriggerHandler.newCarPoolImage(trigger.new, trigger.old);
        }
    }
}