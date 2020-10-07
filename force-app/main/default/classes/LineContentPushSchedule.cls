/* =======================================================================================================================
 * 每2分鐘跑一次。
 * 
 * 
 * ======================================================================================================================= */
global with sharing class LineContentPushSchedule implements Schedulable
{
	global LineContentPushSchedule()
	{
	}
	
	
	
    global void execute(SchedulableContext SC) 
    {
    	//一呼叫起來先把呼叫的sctrigger 砍掉
		list<CronTrigger> ct = [SELECT Id, CronExpression, StartTime, NextFireTime FROM CronTrigger WHERE Id = :SC.getTriggerId()];
    	
    	if(ct.size() >0)
		{
			try
			{
				System.abortJob(ct[0].id);

				list<string> allList = new list<string>();

				list<Line_Push__c> sendList = new list<Line_Push__c>();
				for(Line_Push__c loopPush: [
					select id, Line_Content__c
					from Line_Push__c 
					where IsPushed__c = false
					and IsExecuted__c = false
					and Line_Account__c != null
					and Line_User__c != null
					and Line_Content__c != null 
					and(
						SF_Push__c = false
						or
						(
							SF_Push__c = true
							and (Line_Content__r.SendNow__c = true 
								or  Line_Content__r.ScheduleTime__c <=: system.now()
							)
						)
					)
					order by Line_Content__r.ScheduleTime__c, Line_Content__r.createddate, Line_Content__c
					limit 10000
				])
				{
					allList.add(loopPush.id);
					loopPush.IsExecuted__c = true;
					sendList.add(loopPush);
				}

				if(sendList.size() >0)
				{
					update sendList;
					System.enqueueJob(new LineContentPushQueueable(allList, new list<string>()));
				}
				
				LineContentPushSchedule	r = new LineContentPushSchedule();
				String hour = String.valueOf(Datetime.now().addMinutes(2).hour());
				String min = String.valueOf(Datetime.now().addMinutes(2).minute());
				String ss = String.valueOf(Datetime.now().addMinutes(2).second());
				ss = '10'; 
				String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';   
				System.schedule('ScheduleLineContent main start at: ' + String.valueOf(Datetime.now()), nextFireTime, r);
			}
			catch (Exception e)
			{
			}
		}
    }
}

/*
LineContentPushSchedule	r = new LineContentPushSchedule();
String hour = String.valueOf(Datetime.now().addMinutes(1).hour());
String min = String.valueOf(Datetime.now().addMinutes(1).minute());
String ss = String.valueOf(Datetime.now().addMinutes(1).second()); 
ss = '10';
String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
System.schedule('LineContentPushSchedule main start at: ' + String.valueOf(Datetime.now()), nextFireTime, r);

*/