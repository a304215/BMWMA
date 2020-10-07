public without sharing class TestCarHelper {
    public static List<TestDriveReservation__c> getReservations(string TestCarID, string OpportunityId)
    {
		list<TestDriveReservation__c> returnList = new list<TestDriveReservation__c>();
        set<string> AllIdSet = new set<string>();
        set<string> loopIdSet = new set<string>();
        integer i = 1;
        for(TestDriveReservation__c loopItem: [
            select 	id, Name, Title__c, StartTime__c, EndTime__c, TestCar__c, Opportunity__c, Description__c, OwnerId, CarUseType__c, OwnerName__c, isReadable__c, TestDriveStatus__c, TestDrivePerson__c
            from TestDriveReservation__c
            where 
            ((Opportunity__c =: OpportunityId and Opportunity__c != null)
            	or (TestCar__c =: TestCarID and TestCar__c != null)
            ) and TestDriveStatus__c != '已取消'
        ])
        {
            returnList.add(loopItem);
            loopIdSet.add(loopItem.id);
            if(i == 200)
            {
            	i = 0;
                for(UserRecordAccess loopItem2: [
                    SELECT RecordId FROM UserRecordAccess 
                    WHERE UserId =:UserInfo.getUserId() 
                    AND RecordId in: loopIdSet AND HasReadAccess = true])
                {
                    AllIdSet.add(loopItem2.RecordId);
                }
                loopIdSet = new set<string>();
			}
            i++;
        }
        
        if(loopIdSet.size() > 0)
        {
            for(UserRecordAccess loopItem2: [
                SELECT RecordId FROM UserRecordAccess 
                WHERE UserId =:UserInfo.getUserId() 
                AND RecordId in: loopIdSet AND HasReadAccess = true])
            {
                AllIdSet.add(loopItem2.RecordId);
            }
        }
        
        for(TestDriveReservation__c loopItem: returnList)
        {
            if(AllIdSet.contains(loopItem.id))
            {
                loopItem.isReadable__c = true;
            }
            else
            {
                loopItem.isReadable__c = false;
            }
        }
        
        system.debug('===luke: ' + returnList.size());
        
        return returnList;    
    }
    
    public static List<TestDriveReservation__c> getMyReservations()
    {
		list<TestDriveReservation__c> returnList = new list<TestDriveReservation__c>();
        set<string> AllIdSet = new set<string>();
        set<string> loopIdSet = new set<string>();
        integer i = 1;
        for(TestDriveReservation__c loopItem: [
            select 	id, Name, Title__c, StartTime__c, EndTime__c, TestCar__c, Opportunity__c, Description__c, OwnerId, CarUseType__c, OwnerName__c, isReadable__c, TestDriveStatus__c, TestDrivePerson__c
            from TestDriveReservation__c
            where 
            TestDriveStatus__c != '已取消' and ownerid =:UserInfo.getUserId() 
        ])
        {
            loopItem.isReadable__c = true;
            returnList.add(loopItem);   
        }
        system.debug('===luke: ' + returnList.size());
        
        return returnList;    
    }
    
	//MOBILE 使用。
	//會跨天了。
    public static List<TestDriveReservation__c> getDateNCar(string inputDate, string TestCarID, string OpportunityId){
        date tempDate = date.valueOf(inputDate);
        datetime tempDate1 = datetime.valueOf(string.valueOf(tempDate)+' 00:00:00');
        datetime tempDate2 = datetime.valueOf(string.valueOf(tempDate.adddays(1))+' 00:00:00');
        system.debug(tempDate1);
        system.debug(tempDate2);
        list<TestDriveReservation__c> returnList = new list<TestDriveReservation__c>();
        set<string> AllIdSet = new set<string>();
        set<string> loopIdSet = new set<string>();
        integer i = 1;
        for(TestDriveReservation__c loopItem: [
            select 	id, Name, Title__c, StartTime__c, EndTime__c, TestCar__c, Opportunity__c, Description__c, OwnerId, CarUseType__c, OwnerName__c, isReadable__c, TestDriveStatus__c, TestDrivePerson__c
            from TestDriveReservation__c
            where 
            ((Opportunity__c =: OpportunityId and Opportunity__c != null)
            	or (TestCar__c =: TestCarID and TestCar__c != null)	
            ) and TestDriveStatus__c != '已取消'
            and 
            ((StartTime__c <: tempDate1 and EndTime__c >: tempDate1) or
             (StartTime__c >: tempDate1 and EndTime__c <=:tempDate2) or
             (StartTime__c <: tempDate2 and EndTime__c >=:tempDate2) 
            )
            ORDER BY StartTime__c 
        ])
        {
            returnList.add(loopItem);
            loopIdSet.add(loopItem.id);
            if(i == 200)
            {
            	i = 0;
                for(UserRecordAccess loopItem2: [
                    SELECT RecordId FROM UserRecordAccess 
                    WHERE UserId =:UserInfo.getUserId() 
                    AND RecordId in: loopIdSet AND HasReadAccess = true])
                {
                    AllIdSet.add(loopItem2.RecordId);
                }
                loopIdSet = new set<string>();
			}
            i++;
        }
        
        if(loopIdSet.size() > 0)
        {
            for(UserRecordAccess loopItem2: [
                SELECT RecordId FROM UserRecordAccess 
                WHERE UserId =:UserInfo.getUserId() 
                AND RecordId in: loopIdSet AND HasReadAccess = true])
            {
                AllIdSet.add(loopItem2.RecordId);
            }
        }
        
        for(TestDriveReservation__c loopItem: returnList)
        {
            if(AllIdSet.contains(loopItem.id))
            {
                loopItem.isReadable__c = true;
            }
            else
            {
                loopItem.isReadable__c = false;
            }
            //偷偷放在Title__c ;

            //假設是在同一天天。
            string BGcolor = 'lightblue';
            if(loopItem.TestDriveStatus__c=='使用中' || loopItem.TestDriveStatus__c=='維修中')
            {
                BGcolor = 'red';
            }
            if(loopItem.TestDriveStatus__c=='已還車' || loopItem.TestDriveStatus__c=='已完成')
            {
                BGcolor = 'silver';
            }
            loopItem.Title__c = 'background-color:'+BGcolor+';color:rgb(0, 57, 107);top:'+betweenDates(loopItem.StartTime__c, tempDate)+'px;bottom:-'+betweenDates(loopItem.EndTime__c, tempDate)+'px;z-index:1;left:0%;right:0%;';
        }
        
        system.debug('===luke: ' + returnList.size());
        return returnList;
    }
    
    //用來計算與早上七點的間隔。
    public static string betweenDates(Datetime inputDatetime1, Datetime inputDatetime2)
    {
        integer returnInt;
        //如果同一天。
        if(inputDatetime1.date() == inputDatetime2.date())
        {
            if(inputDatetime1.hour() == 0)
            {
                returnInt = 34;
            }
            else
            {
                returnInt = (inputDatetime1.hour()*60 + inputDatetime1.minute() - 7*60 )/ 30;
            }
        }
        else if(inputDatetime1.date() < inputDatetime2.date())
        {
            returnInt = 0;
        }
        else
        {
            returnInt = 34;
        }
        
        return string.valueOf(returnInt*25);
    }
}