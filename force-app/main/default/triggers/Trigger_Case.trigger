trigger Trigger_Case on Case (before insert, before update) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert || trigger.isUpdate)
        {
            TriggerHandler_Case.bindingCaseNAssetNAccount(trigger.new);
        }
    }
}