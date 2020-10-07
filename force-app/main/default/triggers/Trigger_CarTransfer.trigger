trigger Trigger_CarTransfer on CarTransferForm__c (before insert, before update) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.TransferCarFindVIN(trigger.new, null);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.TransferCarFindVIN(trigger.new, trigger.old);
        }
    }
}