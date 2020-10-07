public without sharing class TriggerHandlerWithoutSharing 
{
    @future 
    public static void AccountSharing(list<string> inputList)
    {
        //抓取Account 資料。
        map<Id, Account> accMap = new map<Id, Account>([select id, ownerId from Account where id in: inputList]);
        //抓取OPP
        map<id, opportunity> OPPMap = new map<id, opportunity>([select id, AccountId from Opportunity where AccountId in: accMap.keyset()]);
        
        //聯繫紀錄
        list<WorkLog__c> workList = [select id, LogCust__c from WorkLog__c where LogCust__c in: accMap.keyset()];
        //Id, ParentId, UserOrGroupId, AccessLevel, RowCause
        list<WorkLog__Share> deleteWorkShareList = [select Id from WorkLog__Share where ParentId in:workList and RowCause = 'ApexWorkLogSharing__c'];
        //先把原本的砍掉。
        if(deleteWorkShareList.size() > 0)
        {
            delete deleteWorkShareList;
        }
        list<WorkLog__Share> insertWorkShareList = new list<WorkLog__Share>();
        for(WorkLog__c loopWork: workList)
        {
            WorkLog__Share tempShare = new WorkLog__Share();
            tempShare.UserOrGroupId =accMap.get(loopWork.LogCust__c).ownerId;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopWork.id;
            tempShare.RowCause = 'ApexWorkLogSharing__c';
            insertWorkShareList.add(tempShare);
        }
        if(insertWorkShareList.size() > 0)
        {
            insert insertWorkShareList;
        }
        
        //有望客戶：因為會讓手動share 的也被砍掉。
        list<Opportunity> OPPList = [select id, AccountId, OwnerId from Opportunity where AccountId in: accMap.keyset()];
        //Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause
        list<OpportunityShare> deleteOPPShareList = [select Id from OpportunityShare where OpportunityId in:OPPList and RowCause = 'Manual'];
        //先把原本的砍掉。
        if(deleteOPPShareList.size() > 0)
        {
            delete deleteOPPShareList;
        }
   
        list<OpportunityShare> insertOPPShareList = new list<OpportunityShare>();
        for(Opportunity loopOPP: OPPList)
        {
            //只有Owner 不同才加入。
            if(accMap.get(loopOPP.AccountId).ownerId != loopOPP.OwnerId)
            {
                OpportunityShare tempShare = new OpportunityShare();
                tempShare.UserOrGroupId =accMap.get(loopOPP.AccountId).ownerId;
                tempShare.OpportunityAccessLevel='Edit';
                tempShare.OpportunityId = loopOPP.id;
                tempShare.RowCause = 'Manual';
                insertOPPShareList.add(tempShare);
            }
            
        }
        if(insertOPPShareList.size() > 0)
        {
            insert insertOPPShareList;
        }
        
        //現有車款：因為會讓手動share 的也被砍掉。
        list<Asset> AssetList = [select id, AccountId, OwnerId from Asset where AccountId in: accMap.keyset()];
        //Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause
        list<AssetShare> deleteAssetShareList = [select Id from AssetShare where AssetId in:AssetList and RowCause = 'Manual'];
        //先把原本的砍掉。
        if(deleteAssetShareList.size() > 0)
        {
            delete deleteAssetShareList;
        }
        list<AssetShare> insertAssetShareList = new list<AssetShare>();
        for(Asset loopASS: AssetList)
        {
            //只有Owner 不同才加入。
            if(accMap.get(loopASS.AccountId).ownerId != loopASS.OwnerId)
            {
                AssetShare tempShare = new AssetShare();
                tempShare.UserOrGroupId =accMap.get(loopASS.AccountId).ownerId;
                tempShare.AssetAccessLevel='Edit';
                tempShare.AssetId = loopASS.id;
                tempShare.RowCause = 'Manual';
                insertAssetShareList.add(tempShare);
            }
        }
        if(insertAssetShareList.size() > 0)
        {
            insert insertAssetShareList;
        }
        
        //客戶間關係
        list<Relationship__c> relList = [select id, Keyman__c from Relationship__c where Keyman__c in: accMap.keyset()];
        //Id, ParentId, UserOrGroupId, AccessLevel, RowCause
        list<Relationship__Share> deleteRelShareList = [select Id from Relationship__Share where ParentId in:relList and RowCause = 'ApexRelationshipSharing__c'];
        //先把原本的砍掉。
        if(deleteRelShareList.size() > 0)
        {
            delete deleteRelShareList;
        }
        list<Relationship__Share> insertRelShareList = new list<Relationship__Share>();
        for(Relationship__c loopRel: relList)
        {
            Relationship__Share tempShare = new Relationship__Share();
            tempShare.UserOrGroupId =accMap.get(loopRel.Keyman__c).ownerId;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopRel.id;
            tempShare.RowCause = 'ApexRelationshipSharing__c';
            insertRelShareList.add(tempShare);
        }
        if(insertRelShareList.size() > 0)
        {
            insert insertRelShareList;
        }
        
        //忠誠會員申請
        list<LoyalProgramMember__c> memberList = [select id, CarOwner__c from LoyalProgramMember__c where CarOwner__c in: accMap.keyset()];
        //Id, ParentId, UserOrGroupId, AccessLevel, RowCause
        list<LoyalProgramMember__Share> deleteMemberShareList = [select Id from LoyalProgramMember__Share where ParentId in:memberList and RowCause = 'ApexMemberSharing__c'];
        //先把原本的砍掉。
        if(deleteMemberShareList.size() > 0)
        {
            delete deleteMemberShareList;
        }
        list<LoyalProgramMember__Share> insertMemberShareList = new list<LoyalProgramMember__Share>();
        for(LoyalProgramMember__c loopMember: memberList)
        {
            LoyalProgramMember__Share tempShare = new LoyalProgramMember__Share();
            tempShare.UserOrGroupId =accMap.get(loopMember.CarOwner__c).ownerId;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopMember.id;
            tempShare.RowCause = 'ApexMemberSharing__c';
            insertMemberShareList.add(tempShare);
        }
        if(insertMemberShareList.size() > 0)
        {
            insert insertMemberShareList;
        }
        
        //取還車管理(預約紀錄)
        list<TestDriveReservation__c> reserList = [select id, Opportunity__c from TestDriveReservation__c where Opportunity__c in: OPPMap.keyset()];
        //Id, ParentId, UserOrGroupId, AccessLevel, RowCause
        list<TestDriveReservation__Share> deleteReserShareList = [select Id from TestDriveReservation__Share where ParentId in:reserList and RowCause = 'ApexReservationSharing__c'];
        //先把原本的砍掉。
        if(deleteReserShareList.size() > 0)
        {
            delete deleteReserShareList;
        }
        list<TestDriveReservation__Share> insertReserShareList = new list<TestDriveReservation__Share>();
        for(TestDriveReservation__c loopReser: reserList)
        {
            TestDriveReservation__Share tempShare = new TestDriveReservation__Share();
            tempShare.UserOrGroupId =accMap.get(OPPMap.get(loopReser.Opportunity__c).AccountId).ownerId;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopReser.id;
            tempShare.RowCause = 'ApexReservationSharing__c';
            insertReserShareList.add(tempShare);
        }
        if(insertReserShareList.size() > 0)
        {
            insert insertReserShareList;
        }
        
        //問卷結果(含交車及試駕問卷的結果)
        list<SurveyTaker__c> serveyList = [select id, Opportunity__c from SurveyTaker__c where Opportunity__c in: OPPMap.keyset()];
        //Id, ParentId, UserOrGroupId, AccessLevel, RowCause
        list<SurveyTaker__Share> deleteSurveyShareList = [select Id from SurveyTaker__Share where ParentId in:serveyList and RowCause = 'ApexSurveySharing__c'];
        //先把原本的砍掉。
        if(deleteSurveyShareList.size() > 0)
        {
            delete deleteSurveyShareList;
        }
        list<SurveyTaker__Share> insertSurveyShareList = new list<SurveyTaker__Share>();
        for(SurveyTaker__c loopSurvey: serveyList)
        {
            SurveyTaker__Share tempShare = new SurveyTaker__Share();
            tempShare.UserOrGroupId =accMap.get(OPPMap.get(loopSurvey.Opportunity__c).AccountId).ownerId;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopSurvey.id;
            tempShare.RowCause = 'ApexSurveySharing__c';
            insertSurveyShareList.add(tempShare);
        }
        if(insertSurveyShareList.size() > 0)
        {
            insert insertSurveyShareList;
        }
    }
    
    @future 
    public static void WorkLogSharing(list<string> inputList)
    {
        //聯繫紀錄
        list<WorkLog__Share> deleteWorkShareList = [select Id from WorkLog__Share where ParentId in:inputList and RowCause in ('WorkLogAccount__c', 'WorkLogOpportunity__c')];
        //先把原本的砍掉。
        if(deleteWorkShareList.size() > 0)
        {
            delete deleteWorkShareList;
        }
        
        list<WorkLog__Share> insertWorkShareList = new list<WorkLog__Share>();
        
        for(WorkLog__c loopWL: [select id, LogOppty__c, LogOppty__r.OwnerId, LogCust__c, LogCust__r.OwnerId from WorkLog__c where id in: inputList])
        {
            //如果有關聯到有望。
            if(loopWL.LogOppty__c != null)
            {
                WorkLog__Share tempShare = new WorkLog__Share();
                tempShare.UserOrGroupId = loopWL.LogOppty__r.OwnerId;
                tempShare.AccessLevel='Edit';
                tempShare.ParentId = loopWL.id;
                tempShare.RowCause = 'WorkLogOpportunity__c';
                insertWorkShareList.add(tempShare);
            }
            //如果有關聯到客戶。
            if(loopWL.LogCust__c != null)
            {
                WorkLog__Share tempShare = new WorkLog__Share();
                tempShare.UserOrGroupId = loopWL.LogCust__r.OwnerId;
                tempShare.AccessLevel='Edit';
                tempShare.ParentId = loopWL.id;
                tempShare.RowCause = 'WorkLogAccount__c';
                insertWorkShareList.add(tempShare);
            }
        }
		
        if(insertWorkShareList.size() > 0)
        {
            insert insertWorkShareList;
        }
    }
    
    /* 不用這一段。因為Account 會自動共用OPP。
    OPP 不用
	*/
    
    @future 
    public static void AssetSharing(list<string> inputList)
    {
        //現有車款：因為會讓手動share 的也被砍掉。
        list<AssetShare> deleteAssetShareList = [select Id from AssetShare where AssetId in:inputList and RowCause = 'Manual'];
        //先把原本的砍掉。
        if(deleteAssetShareList.size() > 0)
        {
            delete deleteAssetShareList;
        }
        list<AssetShare> insertAssetShareList = new list<AssetShare>();
        for(Asset loopASS: [select id, Account.OwnerId, OwnerId from Asset where id in: inputList])
        {
            //只有Owner 不同才加入。
            if(loopASS.Account.ownerId != loopASS.OwnerId)
            {
                AssetShare tempShare = new AssetShare();
                tempShare.UserOrGroupId =loopASS.Account.ownerId ;
                tempShare.AssetAccessLevel='Edit';
                tempShare.AssetId = loopASS.id;
                tempShare.RowCause = 'Manual';
                insertAssetShareList.add(tempShare);
            }
        }
        if(insertAssetShareList.size() > 0)
        {
            insert insertAssetShareList;
        }
    }
    
    @future 
    public static void RelactionSharing(list<string> inputList)
    {
        //客戶間關係
        list<Relationship__Share> deleteRelShareList = [select Id from Relationship__Share where ParentId in:inputList and RowCause = 'ApexRelationshipSharing__c'];
        //先把原本的砍掉。
        if(deleteRelShareList.size() > 0)
        {
            delete deleteRelShareList;
        }
        list<Relationship__Share> insertRelShareList = new list<Relationship__Share>();
        for(Relationship__c loopRel: [select id, Keyman__r.Ownerid, OwnerId from Relationship__c where id in: inputList])
        {
            Relationship__Share tempShare = new Relationship__Share();
            tempShare.UserOrGroupId = loopRel.Keyman__r.Ownerid;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopRel.id;
            tempShare.RowCause = 'ApexRelationshipSharing__c';
            insertRelShareList.add(tempShare);
        }
        if(insertRelShareList.size() > 0)
        {
            insert insertRelShareList;
        }
    }
    
    @future 
    public static void LoyalSharing(list<string> inputList)
    {
        //忠誠會員申請
        list<LoyalProgramMember__Share> deleteMemberShareList = [select Id from LoyalProgramMember__Share where ParentId in:inputList and RowCause = 'ApexMemberSharing__c'];
        //先把原本的砍掉。
        if(deleteMemberShareList.size() > 0)
        {
            delete deleteMemberShareList;
        }
        list<LoyalProgramMember__Share> insertMemberShareList = new list<LoyalProgramMember__Share>();
        for(LoyalProgramMember__c loopMember: [select id, CarOwner__r.OwnerId from LoyalProgramMember__c where id in: inputList])
        {
            LoyalProgramMember__Share tempShare = new LoyalProgramMember__Share();
            tempShare.UserOrGroupId = loopMember.CarOwner__r.OwnerId;
            tempShare.AccessLevel='Edit';
            tempShare.ParentId = loopMember.id;
            tempShare.RowCause = 'ApexMemberSharing__c';
            insertMemberShareList.add(tempShare);
        }
        if(insertMemberShareList.size() > 0)
        {
            insert insertMemberShareList;
        }
    }
    
    @future 
    public static void TestDriveSharing(list<string> inputList)
    {
        //取還車管理(預約紀錄)
        list<TestDriveReservation__c> reserList = [select id, Opportunity__c, Opportunity__r.OwnerId, Opportunity__r.AccountId, Opportunity__r.Account.OwnerId, OwnerId from TestDriveReservation__c where id in: inputList];
        list<TestDriveReservation__Share> deleteReserShareList = [select Id from TestDriveReservation__Share where ParentId in:inputList and RowCause in ('TestOpportunity__c', 'TestAccount__c')];
        //先把原本的砍掉。
        if(deleteReserShareList.size() > 0)
        {
            delete deleteReserShareList;
        }
        list<TestDriveReservation__Share> insertReserShareList = new list<TestDriveReservation__Share>();
        for(TestDriveReservation__c loopReser: reserList)
        {
            if(loopReser.Opportunity__c != null)
            {
                TestDriveReservation__Share tempShare = new TestDriveReservation__Share();
                tempShare.UserOrGroupId = loopReser.Opportunity__r.OwnerId;
                tempShare.AccessLevel='Edit';
                tempShare.ParentId = loopReser.id;
                tempShare.RowCause = 'TestOpportunity__c';
                insertReserShareList.add(tempShare);
            }
            
            if(loopReser.Opportunity__r.AccountId != null)
            {
                TestDriveReservation__Share tempShare2 = new TestDriveReservation__Share();
                tempShare2.UserOrGroupId = loopReser.Opportunity__r.Account.OwnerId;
                tempShare2.AccessLevel='Edit';
                tempShare2.ParentId = loopReser.id;
                tempShare2.RowCause = 'TestAccount__c';
                insertReserShareList.add(tempShare2);
            }
        }
        if(insertReserShareList.size() > 0)
        {
            insert insertReserShareList;
        }
    }
    
    @future 
    public static void SurveyTakenSharing(list<string> inputList)
    {
        //問卷結果(含交車及試駕問卷的結果)
        list<SurveyTaker__Share> deleteSurveyShareList = [select Id from SurveyTaker__Share where ParentId in:inputList and RowCause in ('SurveyAccount__c', 'SurveyOpportunity__c')];
        //先把原本的砍掉。
        if(deleteSurveyShareList.size() > 0)
        {
            delete deleteSurveyShareList;
        }
        list<SurveyTaker__Share> insertSurveyShareList = new list<SurveyTaker__Share>();
        for(SurveyTaker__c loopSurvey: [select id, Opportunity__c, Opportunity__r.OwnerId, Opportunity__r.AccountId, Opportunity__r.Account.OwnerId from SurveyTaker__c where Id in: inputList])
        {
            if(loopSurvey.Opportunity__c != null)
            {
                SurveyTaker__Share tempShare = new SurveyTaker__Share();
                tempShare.UserOrGroupId = loopSurvey.Opportunity__r.OwnerId;
                tempShare.AccessLevel='Edit';
                tempShare.ParentId = loopSurvey.id;
                tempShare.RowCause = 'SurveyAccount__c';
                insertSurveyShareList.add(tempShare);
            }
            
			if(loopSurvey.Opportunity__r.AccountId != null)
            {	            
                SurveyTaker__Share tempShare2 = new SurveyTaker__Share();
                tempShare2.UserOrGroupId = loopSurvey.Opportunity__r.Account.OwnerId;
                tempShare2.AccessLevel='Edit';
                tempShare2.ParentId = loopSurvey.id;
                tempShare2.RowCause = 'SurveyOpportunity__c';
                insertSurveyShareList.add(tempShare2);
            }
        }
        if(insertSurveyShareList.size() > 0)
        {
            insert insertSurveyShareList;
        }
    }
    
    public static void TestDriveOnlyOne(list<TestDriveReservation__c>inputNew, list<TestDriveReservation__c>inputOld)
    {
        set<string> statusSet = new set<string>();
        for(string loopStr: label.Cons_TestDriveConflictSatus.split(';'))
        {
            statusSet.add(loopStr);
        }
        for(TestDriveReservation__c loopTDR: inputNew)
        {
            if(statusSet.contains(loopTDR.TestDriveStatus__c))
            {
                list<TestDriveReservation__c> checklist = [
                    select id from TestDriveReservation__c where 
                    EndTime__c > :loopTDR.StartTime__c AND StartTime__c < :loopTDR.EndTime__c 
                    AND TestCar__c = :loopTDR.TestCar__c AND ID != :loopTDR.id
                    AND TestDriveStatus__c in: statusSet
                ];
                
                if(checklist.size() > 0)
                {
                    loopTDR.Conflict__c = 'Conflict';
                }
            }
        }
    }
    
    //Asset-更新車主flag。
    //20181016 新增現有車款數及購車總數
    public static void changeCarUserStatus(list<Asset> inputNew, list<Asset> inputOld)
    {
        map<string, account> AccMap =  new map<string, account>();
        //insert
        if(inputOld == null)
        {
            for(integer i=0; i<inputNew.size(); i++)
            {
                AccMap.put(inputNew[i].AccountId, new Account(id=inputNew[i].AccountId, BuyCarNumber__c=0, ExistingCarNumber__c=0));
            }
        }
        else
        {
            for(integer i=0; i<inputNew.size(); i++)
            {
                //排除狀態更新的情況。
                //if(inputNew[i].Status != inputOld[i].Status)
                {
                    AccMap.put(inputNew[i].AccountId, new Account(id=inputNew[i].AccountId, BuyCarNumber__c=0, ExistingCarNumber__c=0));
                }
            }
        }
        //改用自訂標籤，使用; 做分隔
        list<string> statusList = Label.Cons_AssetStatusWithCarOwner.split(';');
        
        //總車輛數
        for(aggregateResult loopAR: [select AccountId ACCID, count(id) QTY from Asset where accountid in: AccMap.keyset() group by accountid])
        {
            Account TempAccount = AccMap.get(string.valueOf(loopAR.get('ACCID')));
            TempAccount.CarOwner__c = false;
            TempAccount.BuyCarNumber__c = integer.valueOf(loopAR.get('QTY'));
        }
        
        //現車總數
        for(aggregateResult loopAR: [select accountid ACCID, count(id) QTY from Asset where accountid in: AccMap.keyset() and Status in: statusList group by accountid])
        {
            Account TempAccount = AccMap.get(string.valueOf(loopAR.get('ACCID')));
            TempAccount.CarOwner__c = true;
            TempAccount.ExistingCarNumber__c = integer.valueOf(loopAR.get('QTY'));
        }
        
        update AccMap.values();
    }
}