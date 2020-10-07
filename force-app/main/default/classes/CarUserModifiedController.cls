public class CarUserModifiedController {
	@AuraEnabled
    public static Account getAccount(string AccountId)
    {
    	Account returnRecord  = new Account();
        for(Account loopAcc: [
            select 	id, Name, LastName, FirstName, PersonalID__c, Gender__pc, 
            ContactMethod__c, MainContactNumber__c, Phone, CompanyPhone__c, PersonMobilePhone, 
            Fax, PersonBirthdate, NoEmail__c, PersonEmail, 
            MainAddress__c, 
            HomeCity__c, HomeDistrict__c, HomeStreet__c,
            CompanyCity__c, CompanyDistrict__c, CompanyStreet__c
            from Account
            where id =: AccountId
        ])
        {
            returnRecord = loopAcc;
        }
        
        return returnRecord;
    }
    
    @AuraEnabled
    public static Opportunity getOpportunity(string OPPId)
    {
    	Opportunity returnRecord  = new Opportunity();
        for(Opportunity loopOPP: [
            select 	id, Estimateddateofnew__c, DeliveryDate__c, Driver__c
            from Opportunity
            where id =: OPPId
        ])
        {
            returnRecord = loopOPP;
        }
        
        return returnRecord;
    }
    
    @AuraEnabled
    public static boolean saveTheWorld(
        string OpportunityId, string changeCarDate, string DeliveryDate, string AccountId, string LastName, string FirstName, string PersonalID, 
        string Gender, string MainContact, string MainNumber, string phone, string CompanyPhone, string PersonMobilePhone, string Fax, string PersonBirthdate, 
        string NoEmail, string PersonEmail, string MainAddress, string HomeCity, string HomeDistrict, string HomeStreet, string CompanyCity, string CompanyDistrict, string CompanyStreet
    )
    {
        Account saveRecord2;
        if(string.isBlank(AccountId))
        {
            //要新增。
            saveRecord2 = new Account();
        }
        else
        {
            //要更新。
            saveRecord2 = new Account(id = AccountId);
        }
        
        if(! string.isBlank(LastName))
        {
            saveRecord2.LastName = LastName;
        }
        if(! string.isBlank(FirstName))
        {
            saveRecord2.FirstName = FirstName;
        }
        if(! string.isBlank(PersonalID))
        {
            saveRecord2.PersonalID__c = PersonalID;
        }
        if(! string.isBlank(Gender))
        {
            saveRecord2.Gender__pc = Gender;
        }
        if(! string.isBlank(MainContact))
        {
            saveRecord2.ContactMethod__c = MainContact;
        }
        if(! string.isBlank(MainNumber))
        {
            saveRecord2.MainContactNumber__c = MainNumber;
        }
        if(! string.isBlank(phone))
        {
            saveRecord2.phone = phone;
        }
        if(! string.isBlank(phone))
        {
            saveRecord2.phone = phone;
        }
        if(! string.isBlank(CompanyPhone))
        {
            saveRecord2.CompanyPhone__c = CompanyPhone;
        }
        if(! string.isBlank(PersonMobilePhone))
        {
            saveRecord2.PersonMobilePhone = PersonMobilePhone;
        }
        if(! string.isBlank(Fax))
        {
            saveRecord2.Fax = Fax;
        }
        if(! string.isBlank(PersonBirthdate))
        {
            saveRecord2.PersonBirthdate = Date.valueOf(PersonBirthdate);
        }
        //修改為checkbox 確認。20190619
        if(! string.isBlank(NoEmail))
        {
            saveRecord2.NoEmail__c = (NoEmail == 'true');
        }
        if(! string.isBlank(PersonEmail))
        {
            saveRecord2.PersonEmail = PersonEmail;
        }
        else
        {
            saveRecord2.PersonEmail  = '';
        }
        if(! string.isBlank(MainAddress))
        {
            saveRecord2.MainAddress__c = MainAddress;
        }
        if(! string.isBlank(HomeCity))
        {
            saveRecord2.HomeCity__c = HomeCity;
        } 
        if(! string.isBlank(HomeDistrict))
        {
            saveRecord2.HomeDistrict__c = HomeDistrict;
        }
        if(! string.isBlank(HomeStreet))
        {
            saveRecord2.HomeStreet__c = HomeStreet;
        }
        if(! string.isBlank(CompanyCity))
        {
            saveRecord2.CompanyCity__c = CompanyCity;
        } 
        if(! string.isBlank(CompanyDistrict))
        {
            saveRecord2.CompanyDistrict__c = CompanyDistrict;
        }
        if(! string.isBlank(CompanyStreet))
        {
            saveRecord2.CompanyStreet__c = CompanyStreet;
        } 
        
        
        try{
            if(string.isBlank(saveRecord2.id) )
            {
                insert saveRecord2;
            }
            else
            {
                update saveRecord2;
            }
            
            Opportunity saveRecord = new Opportunity(id = OpportunityId, Driver__c = saveRecord2.Id, Estimateddateofnew__c=Date.valueOf(changeCarDate), DeliveryDate__c=Date.valueOf(DeliveryDate));        
            update saveRecord;
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
        
        
        
        return true;
    }
}