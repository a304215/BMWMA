// 主要計算的class
public without sharing class MarketingTarget_Method implements Queueable
{
    public static boolean isRunning = false;
    public list<MarketingTargetY__c> targetList;

    public MarketingTarget_Method()
    {
        targetList = [
            select id 
            from MarketingTargetY__c
            where TargetYear__c =: string.valueOf(system.today().addDays(-1).year())
        ];
    }
    public MarketingTarget_Method(list<MarketingTargetY__c> inputList)
    {
        targetList = inputList;
    }

    public void execute(QueueableContext context) {
        if(targetList.size() >0)
        {
            calculateYearTarget(targetList[0].id);
            targetList.remove(0);
            if(targetList.size() >0)
            {
                requeue();
            }
        }
    }

    private void requeue() {
        if(!(Test.isRunningTest() && System.isQueueable())) {
            System.enqueueJob(new MarketingTarget_Method(targetList));
        }
    }
    
    
    //一個一個算，照道理，他會找到值的。
    //搭配trigger 計算。
	//public static void calculateYearTarget(MarketingTargetY__c myMarketingTargetList)
    public static void calculateYearTarget(string  inputIDString)
    {
        MarketingTargetY__c thisTarget = 
            [select id, TargetYear__c, sys_f_MarketingYearValue__c from MarketingTargetY__c where id=: inputIDString];
		
        string QueryPAPA = thisTarget.sys_f_MarketingYearValue__c + '%';
        integer myYear = integer.valueOf(thisTarget.TargetYear__c);
        date queryDateBegin = date.newInstance(myYear, 1, 1);
        date queryDateEnd = date.newInstance(myYear+1, 1, 1); 
        //有望-排除Lead converted的。
        //超過20 萬筆，修改
        map<string, integer> OpportunityMap = new map<string, integer>();
        for(aggregateResult loopResult: 
            [select 
             sys_MarketingValue__c MonthValue, 
             count(id) QTY 
             from Opportunity
             where 
             //CALENDAR_YEAR(createddate) =: myYear and 
             id not in(select ConvertedOpportunityId from lead)
             and sys_MarketingValue__c like: QueryPAPA
             and createddate >=: queryDateBegin
             and createddate <:queryDateEnd
             group by 
             sys_MarketingValue__c
            ]
        )
        {
            system.debug('MonthValue: ' + loopResult.get('MonthValue'));
            system.debug('QTY: ' + loopResult.get('QTY'));
            OpportunityMap.put(string.valueOf(loopResult.get('MonthValue')), integer.valueOf(loopResult.get('QTY')));
            system.debug(OpportunityMap);
        }

        //潛客
        
        map<string, integer> LeadMap = new map<string, integer>();
        for(aggregateResult loopResult: 
            [select 
             	sys_MarketingValue__c MonthValue, 
             	count(id) QTY 
             from Lead
             where 
             //CALENDAR_YEAR(createddate) =: myYear and 
             sys_MarketingValue__c like: QueryPAPA
             and createddate >=: queryDateBegin
             and createddate <:queryDateEnd
             group by 
             sys_MarketingValue__c
            ]
        )
        {
            system.debug('MonthValue: ' + loopResult.get('MonthValue'));
            system.debug('QTY: ' + loopResult.get('QTY'));
            LeadMap.put(string.valueOf(loopResult.get('MonthValue')), integer.valueOf(loopResult.get('QTY')));
            system.debug(LeadMap);
        }
        
        list<MarketingM__c> upsertMonthList = new list<MarketingM__c>();
        list<MarketingTrgtDet__c> upsertDetailList = new list<MarketingTrgtDet__c>();
        //先產生12個月的月資料及底下細項。
        for(integer i=1; i<=12; i++)
        {
            MarketingTargetY__c tempYear = new MarketingTargetY__c();
			tempYear.RetailerYear__c = thisTarget.sys_f_MarketingYearValue__c;
                
            MarketingM__c tempMonth = new MarketingM__c(
                MarketTargetY__r = tempYear, 
                MarketM__c = string.valueOf(i+100).right(2),
                RetailerPeriod__c= thisTarget.sys_f_MarketingYearValue__c + string.valueOf(i+100).right(2)
            );
            upsertMonthList.add(tempMonth);
        }
        
        upsert upsertMonthList RetailerPeriod__c;
        
        //要分開給才會assign 到值。囧。
        for(MarketingM__c loopM: upsertMonthList)
        {
            MarketingM__c tempMonth = new MarketingM__c();
			tempMonth.RetailerPeriod__c = loopM.RetailerPeriod__c;
            
            for (Schema.PicklistEntry a : Opportunity.getSObjectType().getDescribe().fields.getMap().get('LeadSource').getDescribe().getPickListValues())
            {
                MarketingTrgtDet__c tempDetail = new MarketingTrgtDet__c();
                tempDetail.TargetM__r = tempMonth;
                tempDetail.RetailerPeriodSource__c = tempMonth.RetailerPeriod__c + a.getValue();
                tempDetail.LeadsSource__c = a.getValue();
                if(OpportunityMap.containsKey(tempDetail.RetailerPeriodSource__c))
                {
                    tempDetail.NewCreateOpportunity__c = OpportunityMap.get(tempDetail.RetailerPeriodSource__c);
                    system.debug(tempDetail.RetailerPeriodSource__c);
                }
                else
                {
                    tempDetail.NewCreateOpportunity__c = 0;
                }
                if(LeadMap.containsKey(tempDetail.RetailerPeriodSource__c))
                {
                    tempDetail.NewCreateLead__c = LeadMap.get(tempDetail.RetailerPeriodSource__c);
                    system.debug(tempDetail.RetailerPeriodSource__c);
                }
                else
                {
                    tempDetail.NewCreateLead__c = 0;
                }
                upsertDetailList.add(tempDetail);
            }
        }
        
        upsert upsertDetailList RetailerPeriodSource__c;
    }
    
    //一個一個算，照道理，他會找到值的。
    //搭配trigger 計算。
    //呼叫future call。
	public static void calculateCampaignResult(list<Campaign> myCampaign)
    {
        if(MarketingTarget_Method.isRunning == false)
        {
            for(Campaign loopCam: myCampaign)
            {
                MarketingTarget_Method.calculateExistOPP(loopCam.id);
            }  
        }
    }
    
    //應該不會有多個活動一起更新的情況。先把future 拔掉。
    //@future
    public static void calculateExistOPP(string myCampaignId)
    {
        //計算實際聯繫人數
        Campaign MyCampaign = [select id, StartDate, endDate, OpportunityTrackingEndDate__c from Campaign where id=:myCampaignId];
        system.debug('MyCampaign: ' + MyCampaign);
        
        //要更新flag 用的。
        map<string, CampaignMember> MemberMap = new map<string, CampaignMember>();
        
        integer allMember = 0;
        for(AggregateResult loopResult: [
            select count(id) QTY 
            from CampaignMember 
            where CampaignId =: MyCampaign.id
        ])
        {
            allMember = integer.valueOf(loopResult.get('QTY'));
        }
        
        //已出席的狀態。
        ////修改抓取hasResponsed 欄位。
        ////list<string> CMJoinStatus = Label.Cons_CampaignMemberJoin.split(';');
        //計算已出席的既有客戶，這是抓取關聯到的所有Account。包含converted 的。
        list<account> allAccList = [
            select id, PersonContactId, 
            (
                select id from opportunities where createddate <=: MyCampaign.OpportunityTrackingEndDate__c
                order by createddate desc limit 1
            )
            from account 
            where PersonContactId in (select contactid from CampaignMember where campaignid =:MyCampaign.id and HasResponded = true)////修改抓取hasResponsed Status in: CMJoinStatus)
        ];
        
        map<string, string> lastOppMap = new map<string, string>();
        //20181206 用allAcc 來計算。
        for(account loopACC: allAccList)
        {
            if(loopACC.opportunities.size() >0)
            {
                lastOppMap.put(loopACC.PersonContactId, loopACC.opportunities[0].id);
            }
            else
            {
                lastOppMap.put(loopACC.PersonContactId, null);
            }
        }
        
        //既有Lead
        //要有真正出席的才算。
        integer ExistingLead = 0;
        for(aggregateResult loopResult:[
            select count(id) QTY from Lead 
            where id in (select leadid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true) ////修改抓取hasResponsed Status in: CMJoinStatus)
            and createddate <: MyCampaign.StartDate])
        {
            ExistingLead = integer.valueOf(loopResult.get('QTY'));
        }
        
        //既有Lead Flag
        for(CampaignMember loopMember: [
            select id, contactid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true 
            and Lead.createddate <: MyCampaign.StartDate 
        ])
        {
            CampaignMember tempMember = MemberMap.get(loopMember.id);
            if(tempMember == null)
            {
                tempMember = new CampaignMember(id=loopMember.id);
            }
            tempMember.MemberCategory__c = '既有潛在客戶';
            //20181206 加入最後有望。
            if(lastOppMap.containskey(loopMember.contactid))
            {
                tempMember.LastOpportunity__c = lastOppMap.get(loopMember.contactid);
            }
            
            MemberMap.put(loopMember.id, tempMember);
        }
        
        //新增Lead
        //要有真正出席的才算。
        integer NewLead = 0;
        for(aggregateResult loopResult:[
            select count(id) QTY from Lead 
            where id in (select leadid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true) ////修改抓取hasResponsed Status in: CMJoinStatus)
            and createddate >: MyCampaign.StartDate])
        {
            NewLead = integer.valueOf(loopResult.get('QTY'));
        }
        
        //新增Lead Flag
        for(CampaignMember loopMember: [
            select id, contactid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true 
            and Lead.createddate >: MyCampaign.StartDate
        ])
        {
            CampaignMember tempMember = MemberMap.get(loopMember.id);
            if(tempMember == null)
            {
                tempMember = new CampaignMember(id=loopMember.id);
            }
            tempMember.MemberCategory__c = '新增潛在客戶';
            //20181206 加入最後有望。
            if(lastOppMap.containskey(loopMember.contactid))
            {
                tempMember.LastOpportunity__c = lastOppMap.get(loopMember.contactid);
            }
            
            MemberMap.put(loopMember.id, tempMember);
        }
        
        //客戶群BASE。排除converted。
        list<account> existingAccList = [
            select id from account 
            where PersonContactId in (select contactid from CampaignMember where campaignid =:MyCampaign.id and HasResponded = true and leadid = null )////修改抓取hasResponsed Status in: CMJoinStatus)
        ];
        
        set<string> existingOPP = new set<string>();
        //計算既有有望。及簽約。//只抓取closed 的紀錄。不管closed won or closed lost。
        list<string> closedStage = Label.Cons_ClosedStage.split(';');
        list<Opportunity> existingOPPClosed = new list<Opportunity>();
        set<string> existCon = new set<string>();
        set<string> existOPPACC = new set<string>();
        
        for(Opportunity loopOpp: [
            select id, AccountId, SigningDate__c, Account.PersonContactId,
            (select StageName, CreatedDate from OpportunityHistories where stageName in:closedStage ) 
            from Opportunity
            where createddate <:MyCampaign.StartDate and AccountId in:existingAccList
        ])
        {
            boolean isExisting = true;
            for(OpportunityHistory loopStage: loopOpp.OpportunityHistories)
            {
                //如果在活動開始之前，已存在結案的，就不算。
                if(loopStage.CreatedDate < MyCampaign.StartDate)
                {
                    isExisting = false;
                }
                //如果在活動開始之後才結案的，就加1。
                else
                {
                    isExisting = true;
                }
            }
                
			if(isExisting)
            {
                //先合併。以人為主。
                existingOPP.add(loopOpp.AccountId);
                existOPPACC.add(loopOpp.AccountId);
                //如果既有有望，且簽約日在活動效期內。
                if(loopOpp.SigningDate__c >= MyCampaign.StartDate && loopOpp.SigningDate__c <= MyCampaign.OpportunityTrackingEndDate__c)
                {
                    existingOPPClosed.add(loopOpp);
                    existCon.add(loopOpp.Account.PersonContactId);
                }
            }
        }
        
        //既有有望 Flag
        for(CampaignMember loopMember: [
            select id, contactid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true 
            and Contact.AccountId in: existingOPP
        ])
        {
            CampaignMember tempMember = MemberMap.get(loopMember.id);
            if(tempMember == null)
            {
                tempMember = new CampaignMember(id=loopMember.id);
            }
            tempMember.MemberCategory__c = '既有有望客戶';
            //20181206 加入最後有望。
            if(lastOppMap.containskey(loopMember.contactid))
            {
                tempMember.LastOpportunity__c = lastOppMap.get(loopMember.contactid);
            }
            
            MemberMap.put(loopMember.id, tempMember);
        }

        //抓取這些簽約的OPP，在活動期間內的。
        //起日在區間內，或結算日在區間內或整個都在區間內的。
        map<string, list<campaignMember>> existOPPcloseMap = new map<string, list<campaignMember>>();
        for(campaignMember loopCM: [
            select id, campaign.StartDate, campaign.OpportunityTrackingEndDate__c, campaign.EndDate, campaign.CreatedDate, campaignId, contactid
            from campaignMember 
            where contactid in:existCon and HasResponded = true ////修改抓取hasResponsed Status in: CMJoinStatus 
            and (
                (campaign.StartDate <=:MyCampaign.StartDate and campaign.OpportunityTrackingEndDate__c >=: MyCampaign.StartDate)
            	or(campaign.StartDate <=:MyCampaign.OpportunityTrackingEndDate__c and campaign.OpportunityTrackingEndDate__c >=: MyCampaign.OpportunityTrackingEndDate__c)
                or(campaign.StartDate >=:MyCampaign.StartDate and campaign.OpportunityTrackingEndDate__c <=: MyCampaign.OpportunityTrackingEndDate__c)
            )
            order by campaign.EndDate desc, campaign.CreatedDate
        ])
        {
            list<campaignMember> tempList = existOPPcloseMap.get(loopCM.contactid);
            if(tempList == null)
            {
                tempList = new list<campaignMember>();
            }
            tempList.add(loopCM);
            existOPPcloseMap.put(loopCM.contactid, tempList);
        }
        
        integer existOPPclosed = 0;
        set<string> existOPPClosedOPP = new set<string>();
        for(Opportunity loopOPP: existingOPPClosed)
        {
            //預設第一筆是最新的。假設行銷活動不會用匯入的。
            //要再判斷是否在計算區間內。
            for(campaignMember loopCM: existOPPcloseMap.get(loopOPP.Account.PersonContactId))
            {
				if(loopOPP.SigningDate__c >= loopCM.campaign.StartDate && loopOPP.SigningDate__c <= loopCM.campaign.OpportunityTrackingEndDate__c) 
                {
                    if(loopCM.campaignId == MyCampaign.id)
                    {
                        existOPPclosed++;
                        
                        //既有有望銷售台數
                        CampaignMember tempMember = MemberMap.get(loopCM.id);
                        if(tempMember == null)
                        {
                            tempMember = new CampaignMember(id=loopCM.id);
                        }
                        if(tempMember.Purchased_ExistOppty__c == null)
                        {
                            tempMember.Purchased_ExistOppty__c = 0;
                        }
                        tempMember.Purchased_ExistOppty__c++;
                        //20181206 加入最後有望。
                        if(lastOppMap.containskey(loopCM.contactid))
                        {
                            tempMember.LastOpportunity__c = lastOppMap.get(loopCM.contactid);
                        }
                        
                        MemberMap.put(loopCM.id, tempMember);
                        
                    }
                    break;
                }
            }
        }
        
        
        //計算已出席的既有客戶
        //closeWon的有望(交車日期在活動StartDate 以前)及有現車。
        set<string> existAccSet = new set<string>();
        list<string> closeWonStage = Label.Cons_CloseWonStage.split(';');
        
        //有現車。排除既有有望。
        for(Account loopACC: [
            select id from account 
            where PersonContactId in (select contactid from CampaignMember where campaignid =:MyCampaign.id and HasResponded = true and leadid = null)////修改抓取hasResponsed Status in: CMJoinStatus)
            and id not in :existOPPACC
            and carOwner__c = true
        ])
        {
            existAccSet.add(loopACC.id);
        }
        
        //有結案的有望。排除既有有望。
        //筆數超過20萬，修改
        for(Account loopACC: [
            select id, (
            	select id from opportunities where stageName in:closeWonStage and DeliveryDate__c <: MyCampaign.StartDate limit 1
            ) from account 
            where PersonContactId in (select contactid from CampaignMember where campaignid =:MyCampaign.id and HasResponded = true and leadid = null)////修改抓取hasResponsed Status in: CMJoinStatus)
            //and id in (select accountId from opportunity where stageName in:closeWonStage and DeliveryDate__c <: MyCampaign.StartDate) 
            and id not in :existOPPACC
        ])
        {
        	if(loopACC.opportunities.size() >0)
        	{
        		existAccSet.add(loopACC.id);	
        	}
        }
        
        //既有客戶 Flag
        for(CampaignMember loopMember: [
            select id, contactid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true 
            and Contact.AccountId in: existAccSet
        ])
        {
            CampaignMember tempMember = MemberMap.get(loopMember.id);
            if(tempMember == null)
            {
                tempMember = new CampaignMember(id=loopMember.id);
            }
            tempMember.MemberCategory__c = '既有客戶';
            //20181206 加入最後有望。
            if(lastOppMap.containskey(loopMember.contactid))
            {
                tempMember.LastOpportunity__c = lastOppMap.get(loopMember.contactid);
            }
            
            MemberMap.put(loopMember.id, tempMember);
        }
        
        //計算已出席的其他客戶
        set<string> otherAccSet = new set<string>();
        for(Account loopACC: [
            select id from account 
            where PersonContactId in (select contactid from CampaignMember where campaignid =:MyCampaign.id and HasResponded = true and leadid = null)////修改抓取hasResponsed Status in: CMJoinStatus)
            and id not in: existOPPACC
            and id not in: existAccSet
        ])
        {
            otherAccSet.add(loopACC.id);
        }
        
        //其他客戶 Flag
        for(CampaignMember loopMember: [
            select id, contactid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true 
            and Contact.AccountId in: otherAccSet
        ])
        {
            CampaignMember tempMember = MemberMap.get(loopMember.id);
            if(tempMember == null)
            {
                tempMember = new CampaignMember(id=loopMember.id);
            }
            tempMember.MemberCategory__c = '其他客戶';
            //20181206 加入最後有望。
            if(lastOppMap.containskey(loopMember.contactid))
            {
                tempMember.LastOpportunity__c = lastOppMap.get(loopMember.contactid);
            }
            
            MemberMap.put(loopMember.id, tempMember);
        }

        //新增Opportunity
        integer NewOPP = 0;
        for(aggregateResult loopResult:[
            select count(id) QTY from Opportunity 
            where accountId in: allAccList
            and createddate >: MyCampaign.StartDate and createddate <:(MyCampaign.endDate==null?null:MyCampaign.endDate+3)])
        {
            NewOPP = integer.valueOf(loopResult.get('QTY'));
        }
        
        //新增有望 Flag
        map<string, integer>NewOPPACCMap = new map<string, integer>();
        for(opportunity loopOPP: [
            select accountid from opportunity where AccountId in: allAccList
            	and createddate >: MyCampaign.StartDate and createddate <:(MyCampaign.endDate==null?null:MyCampaign.endDate+3)
        ])
        {
            integer tempI = NewOPPACCMap.get(loopOPP.accountid);
            if(tempI == null)
            {
                tempI = 0;
            }
            tempI++;
            NewOPPACCMap.put(loopOPP.accountid, tempI);
        }
		//新增有望 Flag
        for(CampaignMember loopMember: [
            select id, Contact.AccountId, contactid from CampaignMember where campaignId =:MyCampaign.id and HasResponded = true 
            and Contact.AccountId in :NewOPPACCMap.KeySet()
        ])
        {
            CampaignMember tempMember = MemberMap.get(loopMember.id);
            if(tempMember == null)
            {
                tempMember = new CampaignMember(id=loopMember.id);
            }
            integer tempI = NewOPPACCMap.get(loopMember.Contact.AccountId);
            if(tempI == null)
            {
                tempI = 0;
            }
            tempMember.NewOpptyQty__c = tempI;
            //20181206 加入最後有望。
            if(lastOppMap.containskey(loopMember.contactid))
            {
                tempMember.LastOpportunity__c = lastOppMap.get(loopMember.contactid);
            }
            
            MemberMap.put(loopMember.id, tempMember);
        }
        
        //新增Opportunity，且簽約的
        //加入條件建立日期<活動結束日期+3天，20190626
        list<Opportunity> newOPPClosedList = new list<Opportunity>();
        set<string> newCon = new set<string>();
        
        for(Opportunity loopOpp: [
            select id, AccountId, SigningDate__c, Account.PersonContactId
            from Opportunity
            where createddate >=:MyCampaign.StartDate and createddate <=:(MyCampaign.endDate==null?null:MyCampaign.endDate+3) and AccountId in:allAccList
            and SigningDate__c >=: MyCampaign.StartDate and SigningDate__c <=: MyCampaign.OpportunityTrackingEndDate__c
        ])
        {
            newOPPClosedList.add(loopOpp);
            newCon.add(loopOpp.Account.PersonContactId);
        }
        
        //抓取這些簽約的OPP，在活動期間內的。
        //起日在區間內，或結算日在區間內或整個都在區間內的。
        map<string, list<campaignMember>> newOPPcloseMap = new map<string, list<campaignMember>>();
        for(campaignMember loopCM: [
            select id, campaign.StartDate, campaign.OpportunityTrackingEndDate__c, campaign.EndDate, campaign.CreatedDate, campaignId, contactid
            from campaignMember 
            where contactid in:newCon and HasResponded = true ////修改抓取hasResponsed Status in: CMJoinStatus  
            and (
                (campaign.StartDate <=:MyCampaign.StartDate and campaign.OpportunityTrackingEndDate__c >=: MyCampaign.StartDate)
            	or(campaign.StartDate <=:MyCampaign.OpportunityTrackingEndDate__c and campaign.OpportunityTrackingEndDate__c >=: MyCampaign.OpportunityTrackingEndDate__c)
                or(campaign.StartDate >=:MyCampaign.StartDate and campaign.OpportunityTrackingEndDate__c <=: MyCampaign.OpportunityTrackingEndDate__c)
            )
            order by campaign.EndDate desc, campaign.CreatedDate
        ])
        {
            list<campaignMember> tempList = newOPPcloseMap.get(loopCM.contactid);
            if(tempList == null)
            {
                tempList = new list<campaignMember>();
            }
            tempList.add(loopCM);
            
            newOPPcloseMap.put(loopCM.contactid, tempList);
        }
        
		integer NewOPPClosed = 0;
        for(Opportunity loopOPP: newOPPClosedList)
        {
            //預設第一筆是最新的。假設行銷活動不會用匯入的。
            //要再判斷是否在計算區間內。
            for(campaignMember loopCM: newOPPcloseMap.get(loopOPP.Account.PersonContactId))
            {
				if(loopOPP.SigningDate__c >= loopCM.campaign.StartDate && loopOPP.SigningDate__c <= loopCM.campaign.OpportunityTrackingEndDate__c) 
                {
                    if(loopCM.campaignId == MyCampaign.id)
                    {
                        NewOPPClosed++;
                        
                        //新增有望銷售台數。
                        CampaignMember tempMember = MemberMap.get(loopCM.id);
                        if(tempMember == null)
                        {
                            tempMember = new CampaignMember(id=loopCM.id);
                        }
                        if(tempMember.Purchased_NewOppty__c == null)
                        {
                            tempMember.Purchased_NewOppty__c = 0;
                        }
                        tempMember.Purchased_NewOppty__c++;
                        //20181206 加入最後有望。
                        if(lastOppMap.containskey(loopCM.contactid))
                        {
                            tempMember.LastOpportunity__c = lastOppMap.get(loopCM.contactid);
                        }
                        
                        MemberMap.put(loopCM.id, tempMember);
                    }
                    break;
                }
            }
        }

        //allMember>所有活動成員。NP
        //existingOPP.size()>既有有望。
        //existAccSet.size()>既有客戶。有結案的有望or現車。
        //ExistingLead>既有潛客。NP
        //NewLead>新增潛客。NP
        //NewOPP>新增有望。NP
        //NewOPPClosed>新增有望簽約。
        //existingOPPClosed.size()>既有有望簽約。
        system.debug('allMember: 全出席：' + allMember);
        system.debug('existingOPP.size(): 既有有望：' + existingOPP.size());
        system.debug('existAccSet.size(): 現有車主：' + existAccSet.size());
        system.debug('otherAccSet.sze: 其他客戶：' + otherAccSet.size());
        system.debug('ExistingLead: 既有潛客：' + ExistingLead);
        system.debug('NewLead: 新增潛客：' + NewLead);
        system.debug('NewOPP: 新增有望：' + NewOPP);
        system.debug('NewOPPClosed: 新增有望結案：' + NewOPPClosed);
        system.debug('existOPPclosed: 既有有望結案：' + existOPPclosed);
        
        MarketingTarget_Method.isRunning = true;
        Campaign tempCam = new Campaign(id=myCampaignId);
        //改用Roll-up Summary。
        //temPCam.NumberContact__c = allMember;
        temPCam.ExistingOpportunityNumber__c = existingOPP.size();
        temPCam.AccountNumber__c = existAccSet.size();
        temPCam.OtherAttendee__c = otherAccSet.size();
        temPCam.ExistingLeadsNumber__c = ExistingLead;
        temPCam.NewLeadNumber__c = NewLead;
        temPCam.NewOpportunityNumber__c = NewOPP;
        temPCam.NumberOfSigningNewOppotFromCampaign__c = NewOPPClosed;
        temPCam.NumberOfSigningExistingOpptInCampaign__c = existOPPclosed;
        
        update tempCam;
        
        update MemberMap.values();
        MarketingTarget_Method.isRunning = false;
    }
    
    
    
}