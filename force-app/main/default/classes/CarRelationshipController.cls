public class CarRelationshipController {
	@AuraEnabled
    public static Opportunity getOpportunity(string OpportunityId)
    {
    	Opportunity returnRecord ;
        for(Opportunity loopOpp: [
            select 	id, Name, Driver__c, Driver__r.Name, 
            LicensingOfPeople__c, AccountId, Account.Name
            from Opportunity
            where id =: OpportunityId
        ])
        {
            returnRecord = loopOpp;
        }
        
        return returnRecord;
    }
    
    
    @AuraEnabled
    public static Relationship__c getRelationship(string MainId, string SubId)
    {
    	Relationship__c returnRecord = new Relationship__c(
            EXID__c=string.valueOf(MainId) + string.valueOf(SubId),
            Keyman__c = MainId, 
            SecondMan__c = SubId 
        );
        for(Relationship__c loopAcc: [
            select 	EXID__c, Keyman__c, SecondMan__c, Relation__c, Id
            from Relationship__c
            where Keyman__c =: MainId and SecondMan__c =:SubId
        ])
        {
            returnRecord = loopAcc;
        }
        
        return returnRecord;
    }
    
    
    @AuraEnabled
    public static boolean saveRelation(
        string EXID1, string main1, string sub1, string relation1, string EXID2, string relation2, string main2, string sub2
    )
    {
		/* 洽談人先不要。
        if(!string.isblank(main1))
        {
            if(string.isblank(EXID1))
            {
                Relationship__c saveRecord = new Relationship__c(keyman__c = main1, SecondMan__c= sub1, Relation__c = relation1);    
                insert saveRecord;
                system.debug('aa');
            }
            else
            {
                Relationship__c saveRecord = new Relationship__c(id=EXID1, keyman__c = main1, SecondMan__c= sub1, Relation__c = relation1);    
                update saveRecord;
            }
        }
		*/
        try
        {
            if(!string.isblank(main2))
            {
                if(string.isblank(EXID2))
                {
                    system.debug('bb');
                    Relationship__c saveRecord2 = new Relationship__c(keyman__c = main2, SecondMan__c= sub2, Relation__c = relation2);
                    insert saveRecord2;
                }
                else
                {
                    system.debug('bb2');
                    Relationship__c saveRecord2 = new Relationship__c(Id = EXID2, keyman__c = main2, SecondMan__c= sub2, Relation__c = relation2);
                    update saveRecord2;
                }
            }
        }
        catch (Exception e) {
            string errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            }
            throw new AuraHandledException(errorMsg);
            System.debug(e.getMessage());
            return null;
        }
        
        

        //upsert saveRecord EXID__c;
        //upsert saveRecord2 EXID__c;
        return true;
    }
}