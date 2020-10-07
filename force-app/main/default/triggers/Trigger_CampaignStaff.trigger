/*==============================================================
 * CampaignStaff的Trigger。
 *
 *
 *==============================================================*/

trigger Trigger_CampaignStaff on CampaignStaff__c (before insert, after update) 
{
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            TriggerHandler_CampaignStaff.generateVerifyCode(trigger.new);
        }
    }
}