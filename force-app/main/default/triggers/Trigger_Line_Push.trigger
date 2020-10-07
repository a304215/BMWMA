trigger Trigger_Line_Push on Line_Push__c (before insert)
{
	if(trigger.isBefore)
	{
		if(trigger.isInsert)
		{
			//在Before 的時候，把LINE_User 代出來。
			TriggerHandler_Line_Push.checkLineUser(trigger.new);
			
		}
	}
}