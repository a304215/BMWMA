public class updateMonthlySalesTarget {
    public string month{set;get;}
    public string year{set;get;}
    
    public list<SalesTarget__c> rawData{set;get;}
    
    public updateMonthlySalesTarget()
    {
        //month = '01';
        //year = '2018';
    }
    
    public static list<SalesTarget__c> loadData(string year, string month)
    {
        list<SalesTarget__c> result = 
            [select id, OwnerId, OpptyActual__c, DeliverActual__c, ContractActual__c, 
             		TestDriveActual__c, OpptyContactTimes__c, VisitTimes__c, TestDriveTimes__c, 
             		OwnerCaringTimes__c, TelephoneTimes__c
             from SalesTarget__c 
             where TargetYear__c =: year and TargetMonth__c =: month];
        return result;
    }
    
    public void convertScope(list<sobject> scope)
    {
        list<SalesTarget__c> temp = new list<SalesTarget__c>();
        for(sobject s : scope)
        {
            temp.add((SalesTarget__c)s);
        }
        rawData = temp;
    }
    
    public boolean updateData()
    {
        if( rawData == null)
        {
            rawData = updateMonthlySalesTarget.loadData(year, month);
        }

        //1. fetch 當月業務銷售目標 - mapTarget
        map<string,SalesTarget__c> sTargets = new map<string,SalesTarget__c>();
        for (SalesTarget__c sT : rawData)
        {
            system.debug(sT);
            initST(sT);
            sTargets.put(sT.OwnerId, sT);
        }
        
        //2. fetch 當月有望客戶 - mapOppt
        //從這裡開始偷改。20180522 by LUKE~。
        /*
        map<string,list<Opportunity>> mOppts = new map<string,list<Opportunity>>();
        for(Opportunity oppt : [select id, OwnerId, StageName
                                from opportunity
                                where CALENDAR_YEAR(createddate) =: integer.valueOf(year) 
                                and CALENDAR_MONTH(createddate) =: integer.valueOf(month) ])
        {
            if( mOppts.keySet().contains(string.valueOf(oppt.OwnerId)) )
            {
                mOppts.get(oppt.OwnerId).add(oppt);
            }
            else
            {
                list<opportunity> tmpOppt = new list<opportunity>{oppt};
                mOppts.put(oppt.OwnerId,tmpOppt);
            }
        }
        //3. fetch 當月聯繫紀錄 - mapConn
        map<string,list<worklog__c>> mworklogs = new map<string,list<worklog__c>>();
        for(worklog__c log : [select id, OwnerId, WorkType__c
                              from worklog__c
                              where CALENDAR_YEAR(createddate) =: integer.valueOf(year) 
                              and CALENDAR_MONTH(createddate) =: integer.valueOf(month) ])
        {
            //worklogs.put(log.OwnerId, log);
            if( mworklogs.keySet().contains(string.valueOf(log.OwnerId)) )
            {
                mworklogs.get(log.OwnerId).add(log);
            }
            else
            {
                list<worklog__c> tmplog = new list<worklog__c>{log};
                mworklogs.put(log.OwnerId,tmpLog);
            }
        }

        for(string SalesId : sTargets.keySet() )
        {
            SalesTarget__c sT = sTargets.get(SalesId);
            list<Opportunity> oppts = mOppts.get(SalesId);

            if(oppts != null)
            {
                for(Opportunity oppt : oppts)
                {
                    system.debug(oppts);
                    //實際有望客戶數 :: 取當月有望客戶總數
                    sT.OpptyActual__c = checkNull(sT.OpptyActual__c);
                    
                    //實際交車數 :: 取當月有望客戶且階段是交車
                    if(oppt.StageName == '交車')
                    {
                        sT.DeliverActual__c = checkNull(sT.DeliverActual__c);
                    }
                    //實際訂單數 :: 取當月有望客戶且階段是簽約
                    if(oppt.StageName == '簽約') //worklog__c : 簽訂合約
                    {
                        sT.ContractActual__c = checkNull(sT.ContractActual__c);
                    }
                    //實際試車數 :: 取當月有望客戶且階段是試駕
                    if(oppt.StageName == '試駕') //worklog__c : 試駕
                    {
                        sT.TestDriveActual__c = checkNull(sT.TestDriveActual__c);
                    }
                }
            }
            list<worklog__c> logs = mworklogs.get(SalesId);
            if(logs != null )
            {
                for(worklog__c log : logs)
                {
                    //本月有望聯繫次數 :: 取當月聯繫記錄總數
                    sT.OpptyContactTimes__c = checkNull(sT.OpptyContactTimes__c);
                    
                    //實際訂單數 :: 取當月有望客戶且階段是簽約 - 由 oppt 移到 worklog
                    //if(oppt.StageName == '簽約') //worklog__c : 簽訂合約
                    if(log.WorkType__c == '簽訂合約')
                    {
                        sT.ContractActual__c = checkNull(sT.ContractActual__c);
                    }
                    //實際試車數 :: 取當月有望客戶且階段是試駕 - 由 oppt 移到 worklog
                    //if(oppt.StageName == '試駕') //worklog__c : 試駕
                    if(log.WorkType__c == '試駕')
                    {
                        sT.TestDriveActual__c = checkNull(sT.TestDriveActual__c);
                    }
                    
                    //本月親訪次數 :: 取當月聯繫記錄且聯繫主題 (WorkType__c) 是親訪
                    if(log.WorkType__c == '親訪')
                    {
                        sT.VisitTimes__c = checkNull(sT.VisitTimes__c);
                    }
                    //本月試車次數 :: 取當月聯繫記錄且聯繫主題 (WorkType__c) 是試駕
                    if(log.WorkType__c == '試駕')
                    {
                        sT.TestDriveTimes__c = checkNull(sT.TestDriveTimes__c);
                    }
                    //本月車主關懷次數 :: 取當月聯繫記錄且聯繫主題 (WorkType__c) 是車主關懷
                    if(log.WorkType__c == '車主關懷')
                    {
                        sT.OwnerCaringTimes__c = checkNull(sT.OwnerCaringTimes__c);
                    }
                    //本月電訪次數 :: 取當月聯繫記錄且聯繫主題 (WorkType__c) 是電訪
                    if(log.WorkType__c == '電訪')
                    {
                        sT.TelephoneTimes__c = checkNull(sT.TelephoneTimes__c);
                    }
                }
            } 
            sTargets.put(SalesId,sT);
        }
        */
        //抓取本月交車的有望。
        map<string, integer> deliveryOPPMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from Opportunity 
			 where CALENDAR_YEAR(LicensingOfDate__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(LicensingOfDate__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             group by OwnerId])
        {
            deliveryOPPMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月簽約的有望，即訂單。
        map<string, integer> signingOPPMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from Opportunity 
			 where CALENDAR_YEAR(SigningDate__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(SigningDate__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             group by OwnerId])
        {
            signingOPPMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月新增的有望。
        map<string, integer> newOPPMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from Opportunity 
			 where CALENDAR_YEAR(createddate) =: integer.valueOf(year) 
             and CALENDAR_MONTH(createddate) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             group by OwnerId])
        {
            newOPPMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月的試駕紀錄。使用還車時間，且已完成，且有有望客戶的。
        list<string> testDriveCompletedStatus = Label.Cons_SalesTargetTestDriveStatus.split(';');
        map<string, integer> testDriveMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from TestDriveReservation__c 
			 where CALENDAR_YEAR(ReturnTime__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(ReturnTime__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             and TestDriveStatus__c in:testDriveCompletedStatus
             and Opportunity__c != null
             group by OwnerId])
        {
            testDriveMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月的電訪的聯繫紀錄。使用聯繫日期，且主管簽核。
        list<string> OppCatogoryStatus = Label.Cons_SalesTargetOppCatogory.split(';');
        list<string> OppPhoneStatus = Label.Cons_SalesTargetPhoneStatus.split(';');
        map<string, integer> phoneMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from WorkLog__c 
			 where CALENDAR_YEAR(ContactDate__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(ContactDate__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             and LogApproved__c = true
             and Category__c in: OppCatogoryStatus
             and WorkType__c in: OppPhoneStatus
             group by OwnerId])
        {
            phoneMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月的親訪的聯繫紀錄。使用聯繫日期，且主管簽核。
        list<string> OppVisitStatus = Label.Cons_SalesTargetVisitStatus.split(';');
        map<string, integer> faceMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from WorkLog__c 
			 where CALENDAR_YEAR(ContactDate__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(ContactDate__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             and LogApproved__c = true
             and Category__c in: OppCatogoryStatus
             and WorkType__c in: OppVisitStatus
             group by OwnerId])
        {
            faceMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月的有望的聯繫紀錄。使用聯繫日期，且主管簽核。
        map<string, integer> oppContactMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from WorkLog__c 
			 where CALENDAR_YEAR(ContactDate__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(ContactDate__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             and LogApproved__c = true
             and Category__c in:OppCatogoryStatus
             group by OwnerId])
        {
            oppContactMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        //抓取本月的現客的聯繫紀錄。使用聯繫日期，狀態已完成或已批准。
        list<string> AccCatogoryStatus = Label.Cons_SalesTargetAccCatogory.split(';');
        list<string> AccCountStatus = Label.Cons_SalesTargetAccCountStatus.split(';');
        map<string, integer> accContactMap = new map<string, integer>();
        for(aggregateResult loopAR: 
            [select OwnerId mySales, count(id) myCount 
             from WorkLog__c 
			 where CALENDAR_YEAR(ContactDate__c) =: integer.valueOf(year) 
             and CALENDAR_MONTH(ContactDate__c) =: integer.valueOf(month)
			 and ownerId in: sTargets.keyset()
             and Category__c in:AccCatogoryStatus
             and WorkLogStatus__c in: AccCountStatus
             group by OwnerId])
        {
            accContactMap.put(string.valueOf(loopAR.get('mySales')), integer.valueOf(loopAR.get('myCount')));
        }
        
        for(string SalesId : sTargets.keySet() )
        {
            SalesTarget__c sT = sTargets.get(SalesId);
            //交車
            if(deliveryOPPMap.containsKey(SalesId))
            {
                sT.DeliverActual__c = deliveryOPPMap.get(SalesId);
            }
            //簽約/訂單
            if(signingOPPMap.containsKey(SalesId))
            {
                sT.ContractActual__c = signingOPPMap.get(SalesId);
            }
            //新增有望
            if(newOPPMap.containsKey(SalesId))
            {
                sT.OpptyActual__c = newOPPMap.get(SalesId);
            }
            //試駕紀錄
            if(testDriveMap.containsKey(SalesId))
            {
                sT.TestDriveActual__c = testDriveMap.get(SalesId);
                sT.TestDriveTimes__c = testDriveMap.get(SalesId);
            }
            //電訪
            if(phoneMap.containsKey(SalesId))
            {
                sT.TelephoneTimes__c = phoneMap.get(SalesId);
            }
            //親訪
            if(faceMap.containsKey(SalesId))
            {
                sT.VisitTimes__c = faceMap.get(SalesId);
            }
            //有望聯繫
            if(oppContactMap.containsKey(SalesId))
            {
                sT.OpptyContactTimes__c = oppContactMap.get(SalesId);
            }
            //車主關懷
            if(accContactMap.containsKey(SalesId))
            {
                sT.OwnerCaringTimes__c = accContactMap.get(SalesId);
            }
        }
        
        system.debug(sTargets.values());
        update sTargets.values();
        return true;
    }
    private void initST(SalesTarget__c st)
    {
        sT.OpptyActual__c = 0;
        sT.DeliverActual__c = 0;
        sT.ContractActual__c = 0;
        sT.TestDriveActual__c = 0;
        sT.OpptyContactTimes__c = 0;
        sT.VisitTimes__c = 0;
        sT.TestDriveTimes__c = 0; 
        sT.OwnerCaringTimes__c = 0;
        sT.TelephoneTimes__c = 0;
    }
    private decimal checkNull(decimal num)
    {
        if( num == null )
        {
            num = 0 ;
        }
        else
        {
        	//num = 0;
            num = num + 1;
        }
        return num;
    }
}