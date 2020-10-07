global class MigrationHelper implements Database.Batchable<sObject>{
	String query;

    global MigrationHelper(string qq) {
        query = qq;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        list<string> uLIst = new list<string>();
		for(dearINFO__c loopDI: [select id from dearInfo__c where id in:scope])
		{
			uLIst.add(loopDI.id);
		}
		MigrationHelper.newAll(uLIst);      
    }

    global void finish(Database.BatchableContext BC) {

    }
	
	
	public static void newAll(list<string> inputList)
    {
    	set<String> carBrandSet= new set<String>();
		Schema.DescribeFieldResult fieldResult1 = Opportunity.CurrentCarBrand__c.getDescribe();
		List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple1){
			carBrandSet.add(pickListVal.getLabel().toUpperCase());
		}
		
		set<String> carAgeSet= new set<String>();
		Schema.DescribeFieldResult fieldResult2 = Opportunity.CurrentCarAges__c.getDescribe();
		List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple2){
			carAgeSet.add(pickListVal.getLabel());
		}
		
		set<String> compareBrandSet= new set<String>();
		Schema.DescribeFieldResult fieldResult3 = Opportunity.CompareBrand1__c.getDescribe();
		List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple3){
			compareBrandSet.add(pickListVal.getLabel().toUpperCase());
		}    
    	
        map<string, string> userMap = new map<string, string>();
        for(user loopU: [select name, id from user ])
        {
            userMap.put(loopU.name.replace(' ', ''), loopU.id);
        }
        
        list<account> ACC1List = new list<account>();
        list<account> ACC2List = new list<account>();
        list<Opportunity> OPPList = new list<Opportunity>();
        
        integer i = 1;
        
        for(DearInfo__c loopDI: [
            select id, NEW_PK1__c, CustomerName__c, CustomerLastname__c, CustomerFirstname__c, CustomerNO__c, 
            CraetedDate__c, Sales__c, fVIP__c, f_Sex__c, Industry__c, CompanyName__c,
            CompanyCity__c, f_CompanyCity__c, CompanyDistrict__c, f_CompanyDistrict__c, CompanyRoad__c,
            ContactCity__c, f_ContactCity__c, ContactDistrict__c, f_ContactDistrict__c, ContactRoad__c,
            UniCode__c, IDCode__c, f_IDCode__c, Birthday__c, Email__c, 
            CompanyPhone__c, f_CompanyPhone__c, HomePhone__c, f_HomePhone__c, ComponyFax__c, Mobile__c, f_Mobile__c,
            LikeSports__c, Merriage__c, CreearType__c, Assoluate__c, AnnualIncome__c, f_AnnualIncome__c,
            MailingAddress__c, f_MainAddress__c, f_MainPhone__c, CustomIndex__c, VocDealerID__c, f_canICall__c,
            Branch__c, Dealer__c,
            NEW_PK2__c, CustomerLastname2__c, CustomerFirstname2__c, f_Sex2__c, 
            CompanyPhone2__c, HomePhone2__c, f_Mobile2__c, Birthday2__c,
            f_CompnayCity2__c, f_CompnayDistrict2__c, CompnayRoad2__c, 
            f_HomeCity2__c, f_HomeDistrict2__c, HomeRoad2__c,
            
            f_CarOnwerType__c, ContinueBuy__c, Amount__c, PreChangeCarDate__c, f_Payment__c, 
            Source__c, f_ContactMethod__c,
            CompetitorBrand1__c, CompetitorType1__c, 
            CompetitorBrand2__c, CompetitorType2__c, 
            NowCar__c, HandoverDate__c, LicensingDate__c,
            VIN__c, f_VIN__c, f_CardNO__c, AssuranceCompany__c, f_AssuranceType__c, AssuranceStartDate__c, AssuranceEndDate__c,
            CarOwnerNAME__c, Negotiator__c, f_UniIDcode__c, RentalCompany__c, f_AgeRange__c,
            BuyCarBrand__c, BuyCarGeneration__c, BuyCarDiscription__c, BuyCarColor__c, f_OPPType__c,
            f_LikeSports__c, f_Merriage__c, SourceExcelDealer__c, f_AssuranceCompany__c, f_RentalCompany__c, NEW_OppNumber__c
            from DearInfo__c
            where id IN: inputList
        ])
        {
        	//洽談人
            account tempACC = new account();
            account tempACC2 = new account();
            opportunity tempOPP = new opportunity();
            string tempACCResult = 'OK!';
            string tempOPPResult = 'OK!';
        	try
        	{
        		tempACC.RecordTypeId = '0127F000000IAMXQA4';
		        tempACC.pkey__c = loopDI.NEW_PK1__c;
		        tempACC.LastName = MigrationHelper.NULLValue(loopDI.CustomerLastname__c);
		        tempACC.FirstName = loopDI.CustomerFirstname__c;
		        tempACC.CustomNumber__c = MigrationHelper.NULLValue(loopDI.CustomerNO__c);
		        tempACC.CreatedDate = Datetime.valueOf(loopDI.CraetedDate__c.left(19).replace('T', ' '));
		        tempACC.Old_Sales__c = loopDI.Sales__c;
		        if(userMap.containsKey(loopDI.Sales__c))
		        {
		            tempACC.OwnerId = userMap.get(loopDI.Sales__c);
		        }
		        tempACC.VIP__c = loopDI.fVIP__c;
		        tempACC.Gender__pc = loopDI.f_Sex__c;
		        tempACC.Industry = loopDI.Industry__c;
		        tempACC.CompanyName__c = loopDI.CompanyName__c;
		        
		        tempACC.HomeCity__c = MigrationHelper.NULLValue(loopDI.f_ContactCity__c);
		        tempACC.HomeDistrict__c = MigrationHelper.NULLValue(loopDI.f_ContactDistrict__c);
		        tempACC.HomeStreet__c = MigrationHelper.NULLValue(loopDI.ContactRoad__c);
		        tempACC.CompanyCity__c = MigrationHelper.NULLValue(loopDI.f_CompanyCity__c);
		        tempACC.CompanyDistrict__c = MigrationHelper.NULLValue(loopDI.f_CompanyDistrict__c);
		        tempACC.CompanyStreet__c = MigrationHelper.NULLValue(loopDI.CompanyRoad__c);
		        
		        tempACC.old_VATNo__c	 = loopDI.UniCode__c;
		        if(!string.isBlank(loopDI.f_IDCode__c))
		        {
		            //取代全型文字。
		            tempACC.PersonalID__c	 = loopDI.f_IDCode__c.replace('Ａ', 'A').replace('Ｂ', 'B').replace('Ｃ', 'C').replace('Ｄ', 'D').replace('Ｅ', 'E').replace('Ｆ', 'F').replace('Ｇ', 'G').replace('Ｈ', 'H').replace('Ｉ', 'I').replace('Ｊ', 'J').replace('Ｋ', 'K').replace('Ｌ', 'L').replace('Ｍ', 'M').replace('Ｎ', 'N').replace('Ｏ', 'O').replace('Ｐ', 'P').replace('Ｑ', 'Q').replace('Ｒ', 'R').replace('Ｓ', 'S').replace('Ｔ', 'T').replace('Ｕ', 'U').replace('Ｖ', 'V').replace('Ｗ', 'W').replace('Ｘ', 'X').replace('Ｙ', 'Y').replace('Ｚ', 'Z');	
		        }
		        
		        //日期
		        if(!string.isblank(loopDI.Birthday__c))
		        {
		            list<string> alldate = loopDI.Birthday__c.split('/');
		            tempACC.PersonBirthdate	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
		        }
		        
		        string tempEmail = '';
		        if (!String.isBlank(loopDI.Email__c))
		        {
		            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
		            Pattern MyPattern = Pattern.compile(emailRegex);
		            Matcher MyMatcher = MyPattern.matcher(loopDI.Email__c);
		            
		            if (MyMatcher.matches())
		            {
		                tempEmail = loopDI.Email__c;
		            } 
		        }
		        
		        tempACC.PersonEmail	 = tempEmail;
		        tempACC.CompanyPhone__c	 = loopDI.f_CompanyPhone__c;
		        tempACC.Phone	 = loopDI.f_HomePhone__c;
		        tempACC.Fax	 = loopDI.ComponyFax__c;
		        tempACC.PersonMobilePhone	 = loopDI.f_Mobile__c;
		        tempACC.Interests__c	 = loopDI.f_LikeSports__c;
		        tempACC.MaritalStatus__c	 = loopDI.f_Merriage__c;
		        tempACC.PersonDoNotCall = (loopDI.f_canICall__c=='false');
		        
		        tempACC.old_Occupation__c	 = MigrationHelper.NULLValue(loopDI.CreearType__c);
		        tempACC.PersonTitle	 = MigrationHelper.NULLValue(loopDI.Assoluate__c);
		        tempACC.AnnualIncome__c	 = loopDI.f_AnnualIncome__c;
		        tempACC.MainAddress__c	 = loopDI.f_MainAddress__c;
		        tempACC.OldCustomerNo__c	 = MigrationHelper.NULLValue(loopDI.CustomIndex__c);
		        tempACC.VOCDealerID__c	 = MigrationHelper.NULLValue(loopDI.VocDealerID__c);
		        tempACC.MainContactNumber__c = loopDI.f_MainPhone__c;
		        tempACC.ContactMethod__c = loopDI.f_ContactMethod__c;
		        tempACC.Old_Dealer__c = loopDI.Dealer__c;
		        tempACC.Old_Branch__c = MigrationHelper.NULLValue(loopDI.Branch__c);
		        tempACC.Old_SourceDealer__c = loopDI.SourceExcelDealer__c;
		        
		        insert tempACC;
		        
        	}
        	catch (Exception e) {
				tempACCResult = e.getMessage();
			} 
			
            //看起來很像是領牌人的資訊耶。囧。
            //使用人
            /*  放棄使用人的資訊。
            tempACC2.RecordTypeId = '0127F000000IAMXQA4';
            tempACC2.pkey__c = loopDI.NEW_PK2__c;
            tempACC2.LastName = loopDI.CustomerLastname2__c;
            tempACC2.FirstName = loopDI.CustomerFirstname2__c;
            tempACC2.Old_Sales__c = loopDI.Sales__c;
            if(userMap.containsKey(loopDI.Sales__c))
            {
                tempACC2.OwnerId = userMap.get(loopDI.Sales__c);
            }
            tempACC2.Gender__pc = loopDI.f_Sex2__c;
            tempACC2.CompanyPhone__c = loopDI.CompanyPhone2__c;
            tempACC2.CreatedDate = Datetime.valueOf(loopDI.CraetedDate__c.left(19).replace('T', ' '));
            //使用人沒有客戶編號。
            //tempACC2.CustomNumber__c = loopDI.CustomerNO__c;
            tempACC2.Phone = loopDI.HomePhone2__c;
            tempACC2.PersonMobilePhone = loopDI.f_Mobile2__c;
            //日期
            if(!string.isblank(loopDI.Birthday2__c) && loopDI.Birthday2__c != '0000-00-00')
            {
                list<string> alldate = loopDI.Birthday2__c.split('/');
                tempACC2.PersonBirthdate	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
            }
            tempACC2.MainContactNumber__c = '行動電話';
            
            tempACC2.HomeCity__c = loopDI.f_HomeCity2__c;
            tempACC2.HomeDistrict__c = loopDI.f_HomeDistrict2__c;
            tempACC2.HomeStreet__c = loopDI.HomeRoad2__c;
            tempACC2.CompanyCity__c = loopDI.f_CompnayCity2__c;
            tempACC2.CompanyDistrict__c = loopDI.f_CompnayDistrict2__c;
            tempACC2.CompanyStreet__c = loopDI.CompnayRoad2__c;
            
            tempACC2.Old_Dealer__c = loopDI.Dealer__c;
            tempACC2.Old_Branch__c = loopDI.Branch__c;
            tempACC2.VOCDealerID__c	 = loopDI.VocDealerID__c;
            tempACC2.MainAddress__c	 = loopDI.f_MainAddress__c;
            //使用人沒有客戶流水號。
            //tempACC2.OldCustomerNo__c	 = loopDI.CustomIndex__c;
            if(loopDI.CustomerLastname2__c !=null && loopDI.NEW_PK1__c != loopDI.NEW_PK2__c)
            {
                system.debug('pk1: '+loopDI.NEW_PK1__c);
                system.debug('pk2: '+loopDI.NEW_PK2__c);
                ACC2List.add(tempACC2);
            }
            else
            */
            {
                tempACC2 = tempACC;
            }

            try
	        {
	            tempOPP.Name = loopDI.CustomerName__c;
	            tempOPP.LicensingType__c = loopDI.f_CarOnwerType__c;
	            tempOPP.IsRenewal__c = loopDI.ContinueBuy__c;
	            if(!string.isBlank(loopDI.Amount__c))
	            {
	            	tempOPP.Amount = decimal.valueOf(loopDI.Amount__c);
	            }
	            tempOPP.LicensingGender__c = loopDI.f_Sex2__c;
	            //日期
	            if(!string.isblank(loopDI.PreChangeCarDate__c) && loopDI.PreChangeCarDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopDI.PreChangeCarDate__c.split('/');
	                tempOPP.CloseDate	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));
	                tempOPP.Estimateddateofnew__c = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));
	            }
	            //日期
		        if(!string.isblank(loopDI.Birthday__c))
		        {
		            list<string> alldate = loopDI.Birthday__c.split('/');
		            tempOPP.Birthday__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
		        }
	            
	            tempOPP.PaymentMethod__c = loopDI.f_Payment__c;
	            tempOPP.LeadSource = MigrationHelper.NULLValue(loopDI.Source__c);
	            tempOPP.ContactMethod__c = loopDI.f_ContactMethod__c;
	            tempOPP.DoNotCall__c = (loopDI.f_canICall__c=='false');
	            
	            if(!string.isBlank(loopDI.CompetitorBrand1__c))
	            {
	            	if(compareBrandSet.contains(loopDI.CompetitorBrand1__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase()))
	            	{
	            		loopDI.CompetitorBrand1__c = loopDI.CompetitorBrand1__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase();
	            	}
	            }
	            tempOPP.old_CompareBrand1__c = MigrationHelper.NULLValue(loopDI.CompetitorBrand1__c);
	            tempOPP.old_CompareType1__c = MigrationHelper.NULLValue(loopDI.CompetitorType1__c);
	            if(!string.isBlank(loopDI.CompetitorBrand2__c))
	            {
	            	if(compareBrandSet.contains(loopDI.CompetitorBrand2__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase()))
	            	{
	            		loopDI.CompetitorBrand2__c = loopDI.CompetitorBrand2__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase();
	            	}
	            }
	            tempOPP.old_CompareBrand2__c = MigrationHelper.NULLValue(loopDI.CompetitorBrand2__c);
	            tempOPP.old_CompareType2__c = MigrationHelper.NULLValue(loopDI.CompetitorType2__c);
	            tempOPP.old_CurrentCarInfo__c = MigrationHelper.NULLValue(loopDI.NowCar__c);
	            
	            //日期
	            if(!string.isblank(loopDI.HandoverDate__c) && loopDI.HandoverDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopDI.HandoverDate__c.split('/');
	                if(alldate.size() <2)
	                {
	                	//先取代時分秒，再用-分開。
	                	alldate = loopDI.HandoverDate__c.replace(' 00:00:00.000', '').split('-');
	                }
	                tempOPP.DeliveryDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            
	            //日期
	            if(!string.isblank(loopDI.LicensingDate__c) && loopDI.LicensingDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopDI.LicensingDate__c.split('/');
	                if(alldate.size() <2)
	                {
	                	//先取代時分秒，再用-分開。
	                	alldate = loopDI.LicensingDate__c.replace(' 00:00:00.000', '').split('-');
	                }
	                tempOPP.LicensingOfDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            
	            //VIN處理。
	            list<newCarPool__c> tempCarPOOL = [select id from newCarPool__c where name =:loopDI.f_VIN__c];
	            if(tempCarPOOL.size() > 0)
	            {
	            	tempOPP.inputVIN__c = loopDI.f_VIN__c;
	            }
	            else
	            {
	            	tempOPP.Old_f_VIN__c = loopDI.VIN__c;
	            }
	            
	            tempOPP.LicensePlate__c = loopDI.f_CardNO__c;
	            
	            tempOPP.Old_Sales__c = loopDI.Sales__c;
	            if(userMap.containsKey(loopDI.Sales__c))
	            {
	                tempOPP.OwnerId = userMap.get(loopDI.Sales__c);
	            }
	            
	            tempOPP.Insurance__c = MigrationHelper.NULLValue(loopDI.f_AssuranceCompany__c);
	            tempOPP.InsuranceType__c = loopDI.f_AssuranceType__c;
	            //日期
	            if(!string.isblank(MigrationHelper.NULLValue(loopDI.AssuranceStartDate__c)) && loopDI.AssuranceStartDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopDI.AssuranceStartDate__c.split('/');
	                tempOPP.InsuranceStartDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            //日期
	            if(!string.isblank(MigrationHelper.NULLValue(loopDI.AssuranceEndDate__c)) && loopDI.AssuranceEndDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopDI.AssuranceEndDate__c.split('/');
	                tempOPP.InsuranceEndDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            
	            //領牌人身份證
	            if(!string.isBlank(loopDI.f_UniIDcode__c))
		        {
		            //取代全型文字。
		            tempOPP.LicensingPersonID__c = loopDI.f_UniIDcode__c.replace('Ａ', 'A').replace('Ｂ', 'B').replace('Ｃ', 'C').replace('Ｄ', 'D').replace('Ｅ', 'E').replace('Ｆ', 'F').replace('Ｇ', 'G').replace('Ｈ', 'H').replace('Ｉ', 'I').replace('Ｊ', 'J').replace('Ｋ', 'K').replace('Ｌ', 'L').replace('Ｍ', 'M').replace('Ｎ', 'N').replace('Ｏ', 'O').replace('Ｐ', 'P').replace('Ｑ', 'Q').replace('Ｒ', 'R').replace('Ｓ', 'S').replace('Ｔ', 'T').replace('Ｕ', 'U').replace('Ｖ', 'V').replace('Ｗ', 'W').replace('Ｘ', 'X').replace('Ｙ', 'Y').replace('Ｚ', 'Z');	
		        }
	            
	            tempOPP.description = '購買車型：['+loopDI.BuyCarBrand__c+']['+loopDI.BuyCarGeneration__c+']['+loopDI.BuyCarDiscription__c+']['+loopDI.BuyCarColor__c+']\n';
	            if(!string.isblank(MigrationHelper.NULLValue(loopDI.NowCar__c)))
	            {
	            	tempOPP.OtherInfo__c = loopDI.NowCar__c;
	            	list<string> tempSTRList = loopDI.NowCar__c.replace('[', '').split(']');
	            	if(carBrandSet.contains(tempSTRList[0].replace('M-Benz', 'MERCEDES BENZ').toUpperCase()))
	            	{
	            		tempOPP.CurrentCarBrand__c = tempSTRList[0].replace('M-Benz', 'MERCEDES BENZ').toUpperCase();
	            	}
	            	if(tempSTRList.size() >2)
	            	{
	            		if(carAgeSet.contains(tempSTRList[2]))
		            	{
		            		tempOPP.CurrentCarAges__c = tempSTRList[2];
		            	}
	            	}
	            }
	            
	            tempOPP.SellingBrand__c = loopDI.BuyCarBrand__c;
	            //tempOPP.SellingGeneration__c = loopDI.BuyCarGeneration__c;
	            //tempOPP.SellingCarType__c = loopDI.BuyCarDiscription__c;
	            //tempOPP.SellingColor__c = loopDI.BuyCarColor__c;
	            
	            tempOPP.CarOwnerType__c = loopDI.f_OPPType__c;
	            tempOPP.LeasingCompanyRef__c = MigrationHelper.NULLValue(loopDI.f_RentalCompany__c);
	            tempOPP.Field1__c = loopDI.f_AgeRange__c;
	            //舊既有客戶編號。
	            tempOPP.ExistCustomerID__c = loopDI.CustomerNO__c;
	            tempOPP.Driver__r = new Account(pkey__c = tempACC2.pkey__c);
	            tempOPP.Account = new Account(pkey__c = tempACC.pkey__c);
	            tempOPP.Stagename = '交車';
	            tempOPP.CreatedDate = Datetime.valueOf(loopDI.CraetedDate__c.left(19).replace('T', ' '));
	            tempOPP.LicensingOfPeople__c = MigrationHelper.NULLValue(loopDI.CarOwnerNAME__c);
	            tempOPP.recordtypeId = '0127F000000Iuy0QAC';
	            tempOPP.OpptyNamebackup__c = MigrationHelper.NULLValue(loopDI.Negotiator__c);
	            tempOPP.CustomerRating__c = 'E';
	            tempOPP.Old_SourceDealer__c = loopDI.SourceExcelDealer__c;
	            tempOPP.oldcustId__c = loopDI.NEW_OppNumber__c;
				insert tempOPP;
	        }
	    	catch (Exception e) {
	    		string errorMsg = e.getMessage();
		        if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
		            errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
		        }
				tempOPPResult = errorMsg;
			}
			
			update new DearInfo__c(
				id=loopDI.id, NEW_ACCResult__c = tempACCResult.left(255), NEW_OPPResult__c= tempOPPResult.left(255),
				NEW_AccountID__c = tempACC.id, NEW_OpportunityID__c = tempOPP.id
			);
        } 
    }
    
    public static string NULLValue(string inputString){
    	if(inputString == 'NULL')
    	{
    		inputString = '';
    	}
		return inputString;
    }
}

/*
select count(id) from dearInfo__c where SourceExcelDealer__c = '鎔德'
select count(id) from account 
select count(id) from opportunity 
select count(id) from dearInfo__c where SourceExcelDealer__c = '鎔德'
select count(id) from dearInfo__c where SourceExcelDealer__c = '鎔德' and NEW_ACCResult__c != null and NEW_ACCResult__c != 'OK!'
select count(id) from dearInfo__c where SourceExcelDealer__c = '鎔德' and NEW_OPPResult__c != null and NEW_OPPResult__c != 'OK!'

select id, CustomerName__c, CustomerNO__c, NEW_ACCResult__c, NEW_OPPResult__c from dearInfo__c 
where NEW_ACCResult__c!=null and NEW_OPPResult__c!= 'OK!' and SourceExcelDealer__c = '鎔德'


list<string> t = new list<string>();
t.add('a0WN0000004T3mvMAC');
MigrationHelper.newAll(t);

list<opportunity> d = [select id from opportunity];
delete d;

list<account> d = [select id from account];
delete d;
*/