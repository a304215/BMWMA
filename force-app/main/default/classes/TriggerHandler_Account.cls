public without sharing class TriggerHandler_Account 
{
    //Account
    public static void syncEntity(list<Account> newList, list<Account> oldList)
    {
        map<string, Entity__c> entityMap = new map<string, Entity__c>();
        set<string> accSet = new set<string>();
        
        if(oldList == null)
        {
            for(account loopAcc: newList)
            {
                if(! string.isBlank(loopAcc.PersonMobilePhone))
                {
                    entityMap.put(loopAcc.PersonMobilePhone, new Entity__c(Name =loopAcc.PersonMobilePhone, Mobile__c = loopAcc.PersonMobilePhone));    
                }
            }
        }
        else 
        {
            for(integer i=0; i<newList.size(); i++)
            {
                //有可能會有null
                if(! string.isBlank(newList[i].PersonMobilePhone) && newList[i].PersonMobilePhone != oldList[i].PersonMobilePhone)
                {
                    entityMap.put(newList[i].PersonMobilePhone, new Entity__c(Name =newList[i].PersonMobilePhone, Mobile__c = newList[i].PersonMobilePhone));
                }
            }
        }

        if(entityMap.values().size() >0)
        {
            upsert entityMap.values() Mobile__c;
        }
        
        if(oldList == null)
        {
            for(account loopAcc: newList)
            {
                if(! string.isBlank(loopAcc.PersonMobilePhone))
                {
                    loopAcc.Entity__c = entityMap.get(loopAcc.PersonMobilePhone).id;
                }
            }
        }
        else 
        {
            for(integer i=0; i<newList.size(); i++)
            {
                //有可能會有null
                if( newList[i].PersonMobilePhone != oldList[i].PersonMobilePhone)
                {
                    if(! string.isBlank(newList[i].PersonMobilePhone))
                    {
                        newList[i].Entity__c = entityMap.get(newList[i].PersonMobilePhone).id;
                    }
                    else 
                    {
                        newList[i].Entity__c = null;
                    }

                    accSet.add(newList[i].id);
                }
            }
            
            if(accSet.size() >0)
            {
                changeAsset(accSet);
            }
            
        }
    }

    @future 
    public static void changeAsset(set<string> inputIds)
    {
        list<Asset> updateList = [
            select id, Account.Entity__c
            from asset
            where AccountId in: inputIds
        ];

        for(Asset loopAsset: updateList)
        {
            loopAsset.Entity__c = loopAsset.Account.Entity__c;
        }

        if(updateList.size() >0)
        {
            update updateList;    
        }
    }
}