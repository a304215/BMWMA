/* =======================================================================================================================
 * 每批最50筆送一次。
 * 
 * 
 * ======================================================================================================================= */

public without sharing class LinePushContentPushQueue implements Queueable, Database.AllowsCallouts
{
    public list<string> allList;
	public list<string> didList;

    public LinePushContentPushQueue(list<string> inpustList, list<string> inputList2) {
        allList = inpustList;
        didList = inputList2;
    }
    
    public void execute(QueueableContext context) {
    	map<string, list<Line_Push__c>> sendMap  =new map<string, list<Line_Push__c>>();
    	
    	//排除掉已經丟到future 的。
    	list<Line_Push__c> needSendList = [
            select id, Line_Content__c
            from Line_Push__c 
            where IsPushed__c = false
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
            and Line_Account__c != null
            and Line_User__c != null
            and id in: allList
            and id not in: didList
            order by Line_Content__r.ScheduleTime__c, Line_Content__r.createddate, Line_Content__c
            limit 50
        ];

		for(Line_Push__c loopRD: needSendList)
        {
            if(loopRD.Line_Content__c != null)
            {
                Callout_Line_API.sendMulticastSFFuture(string.valueOf(loopRD.id));
            }
            didList.add(loopRD.id);
        }
        
        //清單>1 才要寄送。代表有兩個不同的文字，總數>2000，代表還有下一批。
        if( needSendList.size() == 50)
        {
        	requeue();
        }
    }
    //如果要requeue，就要把參數代進去。QQ
    private void requeue() {
        if(!(Test.isRunningTest() && System.isQueueable())) {
            System.enqueueJob(new LineContentPushQueueable(allList, didList));
        }
    }
}