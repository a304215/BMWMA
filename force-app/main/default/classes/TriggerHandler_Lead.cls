public without sharing class TriggerHandler_Lead 
{
    //Lead
    public static void syncEntity(list<Lead> newList, list<Lead> oldList)
    {
        map<string, Entity__c> entityMap = new map<string, Entity__c>();
        
        if(oldList == null)
        {
            for(Lead loopLead: newList)
            {
                if(! string.isBlank(loopLead.MobilePhone))
                {
                    entityMap.put(loopLead.MobilePhone, new Entity__c(Name =loopLead.MobilePhone, Mobile__c = loopLead.MobilePhone));    
                }
            }
        }
        else 
        {
            for(integer i=0; i<newList.size(); i++)
            {
                //有可能會有null
                if(! string.isBlank(newList[i].MobilePhone) && newList[i].MobilePhone != oldList[i].MobilePhone)
                {
                    entityMap.put(newList[i].MobilePhone, new Entity__c(Name =newList[i].MobilePhone, Mobile__c = newList[i].MobilePhone));
                }
            }
        }

        if(entityMap.values().size() >0)
        {
            upsert entityMap.values() Mobile__c;
        }
        
        if(oldList == null)
        {
            for(Lead loopLead: newList)
            {
                if(! string.isBlank(loopLead.MobilePhone))
                {
                    loopLead.Entity__c = entityMap.get(loopLead.MobilePhone).id;
                }
            }
        }
        else 
        {
            for(integer i=0; i<newList.size(); i++)
            {
                //有可能會有null
                if( newList[i].MobilePhone != oldList[i].MobilePhone)
                {
                    if(! string.isBlank(newList[i].MobilePhone))
                    {
                        newList[i].Entity__c = entityMap.get(newList[i].MobilePhone).id;
                    }
                    else 
                    {
                        newList[i].Entity__c = null;
                    }
                }
            }
        }
    }

    //Lead change mobile
    public static void changeMobile(list<Lead> newList)
    {
        for(lead loopLead: newList)
        {
            if(loopLead.MobilePhone.StartsWith('+886'))
            {
                string tempMobile  = loopLead.MobilePhone.remove('+886');
                if(tempMobile.StartsWith('09'))
                {
                    loopLead.MobilePhone = tempMobile;
                }
                else
                {
                    loopLead.MobilePhone = '0'+tempMobile;
                }
                
            }
        }
    }

    //Lead
    public static void syncToFB(list<Lead> newList)
    {
        list<string> leadList = new list<string>();
        for(lead loopLead: newList)
        {
            if(loopLead.leadcap__Facebook_Lead_ID__c != null)
            {
                leadList.add(loopLead.id);
            }
        }

        if(leadList.size() > 0)
        {
            TriggerHandler_Lead.syncToBrendme(leadList);
        }
    }

    @future(callout=true)
    public static void syncToBrendme(list<string> inputList)
    {
        datetime current = system.now();
        FB2WebSetting__c theSetting = FBConnector.theOrgSetting;
        //token 過期
        if(FBConnector.theOrgSetting.Token__c == null || FBConnector.theOrgSetting.TokenTime__c == null || FBConnector.theOrgSetting.TokenTime__c.addhours(1) < current)
        {
            FBConnector.isNewToken = true;
        }
        else 
        {
            FBConnector.tempToken = FBConnector.theOrgSetting.Token__c;
        }

        if(FBConnector.isNewToken)
        {
            FBConnector.tempToken = FBConnector.FBToken(FBConnector.theOrgSetting);
        }

        list<lead> updateList = new list<lead>();
        for(lead loopLead: [
            select id, lastname, firstname, gender__c, opptyage__c, fbMobilePhone__c, Email, 
                ProjectName__c, fbSaleStore__c
            from lead where id in: inputList
        ])
        {
            updateList.add(FBConnector.FBPusher(loopLead));
        }

        if(FBConnector.isNewToken)
        {
            FBConnector.theOrgSetting.Token__c = FBConnector.tempToken;
            FBConnector.theOrgSetting.TokenTime__c = current;
            upsert FBConnector.theOrgSetting;
        }

        if(updateList.size() > 0)
        {
            update updateList;
        }
    }
}