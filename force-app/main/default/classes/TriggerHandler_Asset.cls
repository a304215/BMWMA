public with sharing class TriggerHandler_Asset 
{
    //Asset
    public static void syncEntity(list<Asset> newList, list<Asset> oldList)
    {
        map<string, Account> accountMap = new map<string, Account>();
        
        if(oldList == null)
        {
            for(Asset loopAss: newList)
            {
                if(! string.isBlank(loopAss.UserMobile__c))
                {
                    accountMap.put(loopAss.AccountId, null);    
                }
            }
        }
        else 
        {
            for(integer i=0; i<newList.size(); i++)
            {
                //有可能會有null
                if(! string.isBlank(newList[i].UserMobile__c) && newList[i].UserMobile__c != oldList[i].UserMobile__c)
                {
                    accountMap.put(newList[i].AccountId, null);  
                }
            }
        }

        if(accountMap.size() >0)
        {
            for(Account loopAcc: [
                select id, Entity__c
                from Account
                where id in: accountMap.keyset()
            ])
            {
                accountMap.put(loopAcc.id, loopAcc);
            }
        }
        
        if(oldList == null)
        {
            for(Asset loopAss: newList)
            {
                if(! string.isBlank(loopAss.UserMobile__c))
                {
                    loopAss.Entity__c = accountMap.get(loopAss.AccountId).Entity__c;
                }
            }
        }
        else 
        {
            for(integer i=0; i<newList.size(); i++)
            {
                //有可能會有null
                if( newList[i].UserMobile__c != oldList[i].UserMobile__c)
                {
                    if(! string.isBlank(newList[i].UserMobile__c))
                    {
                        newList[i].Entity__c = accountMap.get(newList[i].AccountId).Entity__c;
                    }
                    else 
                    {
                        newList[i].Entity__c = null;
                    }
                }
            }
        }
    }    
}