trigger Trigger_Asset on Asset (before insert, before update, after insert, after update) 
{
	if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler.AssetFindVIN(trigger.new, trigger.old);
            TriggerHandler_Asset.syncEntity(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            TriggerHandler.AssetFindVIN(trigger.new, trigger.old);
            TriggerHandler_Asset.syncEntity(trigger.new, trigger.old);
        }
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            //function加入計算現有車輛數
            TriggerHandlerWithoutSharing.changeCarUserStatus(trigger.new, trigger.old);
            TriggerHandler.AssetSharing(trigger.new, trigger.old);
        }
        if(trigger.isUpdate)
        {
            //function加入計算現有車輛數
			TriggerHandlerWithoutSharing.changeCarUserStatus(trigger.new, trigger.old);
            TriggerHandler.AssetSharing(trigger.new, trigger.old);
        }
    }
}