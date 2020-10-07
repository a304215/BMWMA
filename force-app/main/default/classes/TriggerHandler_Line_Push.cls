public without sharing class TriggerHandler_Line_Push 
{
	//加入LINE User
	public static void checkLineUser(list<Line_Push__c> newList)
	{
		set<string> allQuerySet = new set<string>();
		set<string> points = new set<string>();
		set<string> valides = new set<string>();
		for(integer i=0; i<newList.size(); i++)
		{
			allQuerySet.add(newList[i].Account__c);
			allQuerySet.add(newList[i].Line_Account__c);
		}
		
		map<string, account> accMap = new map<string, account>();
		for(Account loopAccount: [
			select id, (
				select id from Line_User__r
				where Line_Account__c in:allQuerySet
			)
			from Account
			where id in:allQuerySet
		])
		{
			accMap.put(loopAccount.id, loopAccount);
		}

		for(integer i=0; i<newList.size(); i++)
		{
            account tempAccount  = accMap.get(newList[i].Account__c);
            
            if(tempAccount != null)
            {
                //抓其中一個就好。qq
                for(Line_User__c loopUser: tempAccount.Line_User__r)
                {
                    newList[i].Line_User__c = loopUser.id;
                }
            }
		}
	}
}