global class MigrationHelper_OPP implements Database.Batchable<sObject>{
	String query;

    global MigrationHelper_OPP(string qq) {
        query = qq;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        list<string> uLIst = new list<string>();
		for(MigrationOppty__c loopMO: [select id from MigrationOppty__c where id in:scope])
		{
			uLIst.add(loopMO.id);
		}
		MigrationHelper_OPP.newAll(uLIst);      
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
        list<Opportunity> OPPList = new list<Opportunity>();
        
        integer i = 1;
        for(MigrationOppty__c loopMO: [
            select id,
            NEW_PK1__c, CustomerFirstname__c, CustomerLastname__c, CreatDateTime__c, CreatedDate, 
            SalesPerson__c, fVIP__c, f_Sex__c, Industry__c, CompanyName__c,
            f_ContactCity__c, f_ContactDistrict__c, ContactRoad__c,
            f_CompanyCity__c, f_CompanyDistrict__c, CompanyRoad__c,
            GUINo__c, f_IDCode__c, BDAY__c, MailAddress__c,
            f_CompanyPhone__c, f_HomePhone__c, FaxOfCompany__c,
            f_Mobile__c, f_LikeSports__c,
            Assoluate__c, f_MainAddress__c, f_MainPhone__c, f_ContactMethod__c,
            SourceDealer__c, ExcelSourceDealer__c,
            AccountName__c, ContinueBuy__c, Amount__c, PreChangeCarDate__c,
            f_Payment__c, AccountSource__c,
            CompetitorBrand1__c, CompetitorType1__c, CompetitorBrand2__c, CompetitorType2__c,
			CurrentCarType__c, f_CarOnwerType__c, f_AgeRange__c,
			Negotiator__c, ExcelSourceBrand__c,
			OpptyNo__c
            from MigrationOppty__c
            where id IN: inputList
        ])
        {
            account tempACC = new account();
            opportunity tempOPP = new opportunity();
            string tempACCResult = 'OK!';
            string tempOPPResult = 'OK!';
            
            try
        	{
        		tempACC.RecordTypeId = '0127F000000IAMXQA4';
		        tempACC.pkey__c = loopMO.NEW_PK1__c;
		        tempACC.LastName = MigrationHelper_OPP.NULLValue(loopMO.CustomerLastname__c);
		        tempACC.FirstName = loopMO.CustomerFirstname__c;
		        //無既客編號。
		        //tempACC.CustomNumber__c = MigrationHelper.NULLValue(loopMO.CustomerNO__c);
		        if(loopMO.CreatDateTime__c != null)
		        {
					//格式為11/1/201715:37:57，m/d/yyyyHH:mm:ss		        	
		        	string HH = loopMO.CreatDateTime__c.right(8);
		        	string YY = loopMO.CreatDateTime__c.replace(HH, '');
		        	list<string> YYlist = YY.split('/');
		        	//可以吃2000-1-1的格式。
		        	tempACC.CreatedDate = Datetime.valueOf(YYlist[2]+'-'+YYlist[1]+'-'+YYlist[0]+ ' '+HH);
		        }
		        else
		        {
		        	//不用轉，可以直接用，科科。
		        	tempACC.CreatedDate = loopMO.CreatedDate;
		        }
		        tempACC.Old_Sales__c = loopMO.SalesPerson__c;
		        if(userMap.containsKey(loopMO.SalesPerson__c))
		        {
		            tempACC.OwnerId = userMap.get(loopMO.SalesPerson__c);
		        }
		        tempACC.VIP__c = loopMO.fVIP__c;
		        tempACC.Gender__pc = loopMO.f_Sex__c;
		        tempACC.Industry = loopMO.Industry__c;
		        tempACC.CompanyName__c = loopMO.CompanyName__c;
		        tempACC.HomeCity__c = MigrationHelper_OPP.NULLValue(loopMO.f_ContactCity__c);
		        tempACC.HomeDistrict__c = MigrationHelper_OPP.NULLValue(loopMO.f_ContactDistrict__c);
		        tempACC.HomeStreet__c = MigrationHelper_OPP.NULLValue(loopMO.ContactRoad__c);
		        tempACC.CompanyCity__c = MigrationHelper_OPP.NULLValue(loopMO.f_CompanyCity__c);
		        tempACC.CompanyDistrict__c = MigrationHelper_OPP.NULLValue(loopMO.f_CompanyDistrict__c);
		        tempACC.CompanyStreet__c = MigrationHelper_OPP.NULLValue(loopMO.CompanyRoad__c);
		        tempACC.old_VATNo__c	 = loopMO.GUINo__c;
		        if(!string.isBlank(loopMO.f_IDCode__c))
		        {
		            //取代全型文字。
		            tempACC.PersonalID__c	 = loopMO.f_IDCode__c.replace('Ａ', 'A').replace('Ｂ', 'B').replace('Ｃ', 'C').replace('Ｄ', 'D').replace('Ｅ', 'E').replace('Ｆ', 'F').replace('Ｇ', 'G').replace('Ｈ', 'H').replace('Ｉ', 'I').replace('Ｊ', 'J').replace('Ｋ', 'K').replace('Ｌ', 'L').replace('Ｍ', 'M').replace('Ｎ', 'N').replace('Ｏ', 'O').replace('Ｐ', 'P').replace('Ｑ', 'Q').replace('Ｒ', 'R').replace('Ｓ', 'S').replace('Ｔ', 'T').replace('Ｕ', 'U').replace('Ｖ', 'V').replace('Ｗ', 'W').replace('Ｘ', 'X').replace('Ｙ', 'Y').replace('Ｚ', 'Z');	
		        }
		        //日期
		        if(!string.isblank(MigrationHelper_OPP.NULLValue(loopMO.BDAY__c)))
		        {
		            list<string> alldate = loopMO.BDAY__c.split('/');
		            tempACC.PersonBirthdate	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
		        }
		        string tempEmail = '';
		        if (!String.isBlank(loopMO.MailAddress__c))
		        {
		            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
		            Pattern MyPattern = Pattern.compile(emailRegex);
		            Matcher MyMatcher = MyPattern.matcher(loopMO.MailAddress__c);
		            
		            if (MyMatcher.matches())
		            {
		                tempEmail = loopMO.MailAddress__c;
		            } 
		        }
		        tempACC.PersonEmail	 = tempEmail;
		        tempACC.CompanyPhone__c	 = loopMO.f_CompanyPhone__c;
		        tempACC.Phone	 = loopMO.f_HomePhone__c;
		        tempACC.Fax	 = loopMO.FaxOfCompany__c;
		        tempACC.PersonMobilePhone	 = loopMO.f_Mobile__c;
		        tempACC.Interests__c	 = loopMO.f_LikeSports__c;
		        
		        //tempACC.MaritalStatus__c	 = loopMO.f_Merriage__c; //有望沒有婚姻狀況
		        //tempACC.PersonDoNotCall = (loopMO.f_canICall__c=='false'); //有望沒有是否接受電訪
		        //tempACC.old_Occupation__c	 = MigrationHelper_OPP.NULLValue(loopMO.CreearType__c); //有望沒有職業類別。
		        tempACC.PersonTitle	 = MigrationHelper_OPP.NULLValue(loopMO.Assoluate__c);
		        //tempACC.AnnualIncome__c	 = loopMO.f_AnnualIncome__c; //沒有年收入
		        tempACC.MainAddress__c	 = loopMO.f_MainAddress__c;
		        //tempACC.OldCustomerNo__c	 = MigrationHelper_OPP.NULLValue(loopMO.CustomIndex__c); //有望沒有舊客戶編號。
		        //tempACC.VOCDealerID__c	 = MigrationHelper_OPP.NULLValue(loopMO.VocDealerID__c); //有望沒有vocDealerID。
		        tempACC.MainContactNumber__c = loopMO.f_MainPhone__c;
		        tempACC.ContactMethod__c = loopMO.f_ContactMethod__c;
		        tempACC.Old_Dealer__c = loopMO.SourceDealer__c;
		        //tempACC.Old_Branch__c = MigrationHelper_OPP.NULLValue(loopMO.Branch__c); //有望沒有銷售門市
		        tempACC.Old_SourceDealer__c = loopMO.ExcelSourceDealer__c+'_有望';

		        insert tempACC;
        	}
        	catch (Exception e) {
				tempACCResult = e.getMessage();
			}
			
			try
	        {
	        	tempOPP.Name = loopMO.AccountName__c;
	        	//tempOPP.LicensingType__c = loopMO.f_CarOnwerType__c; //無車主性值
	        	tempOPP.IsRenewal__c = loopMO.ContinueBuy__c;
	        	if(!string.isBlank(loopMO.Amount__c))
	            {
	            	tempOPP.Amount = decimal.valueOf(loopMO.Amount__c);
	            }
	            //tempOPP.LicensingGender__c = loopMO.f_Sex2__c; 無領牌人資訊。
	            //日期
	            if(!string.isblank(loopMO.PreChangeCarDate__c) && loopMO.PreChangeCarDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopMO.PreChangeCarDate__c.split('/');
	                tempOPP.CloseDate	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));
	                tempOPP.Estimateddateofnew__c = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));
	            }
	            else
	            {
	            	tempOPP.CloseDate = Date.newInstance(2018,12,31);
	            }
	            //日期
	            //日期
		        if(!string.isblank(MigrationHelper_OPP.NULLValue(loopMO.BDAY__c)))
		        {
		            list<string> alldate = loopMO.BDAY__c.split('/');
		           	tempOPP.Birthday__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
		        }
		        tempOPP.PaymentMethod__c = loopMO.f_Payment__c;
		        tempOPP.LeadSource = MigrationHelper_OPP.NULLValue(loopMO.AccountSource__c);
	        	tempOPP.ContactMethod__c = loopMO.f_ContactMethod__c;
	        	//tempOPP.DoNotCall__c = (loopMO.f_canICall__c=='false'); //有望沒有是否接受電訪
	        	if(!string.isBlank(loopMO.CompetitorBrand1__c))
	            {
	            	if(compareBrandSet.contains(loopMO.CompetitorBrand1__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase()))
	            	{
	            		tempOPP.CompareBrand1__c = loopMO.CompetitorBrand1__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase();
	            	}
	            }
	            tempOPP.old_CompareBrand1__c = MigrationHelper_OPP.NULLValue(loopMO.CompetitorBrand1__c);
	            tempOPP.old_CompareType1__c = MigrationHelper_OPP.NULLValue(loopMO.CompetitorType1__c);
	            if(!string.isBlank(loopMO.CompetitorBrand2__c))
	            {
	            	if(compareBrandSet.contains(loopMO.CompetitorBrand2__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase()))
	            	{
	            		tempOPP.CompareBrand2__c = loopMO.CompetitorBrand2__c.replace('M-Benz', 'MERCEDES BENZ').toUpperCase();
	            	}
	            }
	            tempOPP.old_CompareBrand2__c = MigrationHelper_OPP.NULLValue(loopMO.CompetitorBrand2__c);
	            tempOPP.old_CompareType2__c = MigrationHelper_OPP.NULLValue(loopMO.CompetitorType2__c);
	            //以現有車款為主。
	            tempOPP.old_CurrentCarInfo__c = MigrationHelper_OPP.NULLValue(loopMO.CurrentCarType__c);
	            //日期，沒有交車日期
	            /*
	            if(!string.isblank(loopMO.HandoverDate__c) && loopMO.HandoverDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopMO.HandoverDate__c.split('/');
	                if(alldate.size() <2)
	                {
	                	//先取代時分秒，再用-分開。
	                	alldate = loopMO.HandoverDate__c.replace(' 00:00:00.000', '').split('-');
	                }
	                tempOPP.DeliveryDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            //日期 //沒有領牌日期
	            if(!string.isblank(loopMO.LicensingDate__c) && loopMO.LicensingDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopMO.LicensingDate__c.split('/');
	                if(alldate.size() <2)
	                {
	                	//先取代時分秒，再用-分開。
	                	alldate = loopMO.LicensingDate__c.replace(' 00:00:00.000', '').split('-');
	                }
	                tempOPP.LicensingOfDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            //VIN處理。//沒有VIN
	            list<newCarPool__c> tempCarPOOL = [select id from newCarPool__c where name =:loopMO.f_VIN__c];
	            if(tempCarPOOL.size() > 0)
	            {
	            	tempOPP.inputVIN__c = loopMO.f_VIN__c;
	            }
	            else
	            {
	            	tempOPP.Old_f_VIN__c = loopMO.VIN__c;
	            }
	           	// 沒有車牌。
	            tempOPP.LicensePlate__c = loopMO.f_CardNO__c;
	            */
	            tempOPP.Old_Sales__c = loopMO.SalesPerson__c;
	            if(userMap.containsKey(loopMO.SalesPerson__c))
	            {
	                tempOPP.OwnerId = userMap.get(loopMO.SalesPerson__c);
	            }
	            //保險的都沒有。
	            /*
	            tempOPP.Insurance__c = MigrationHelper.NULLValue(loopMO.f_AssuranceCompany__c);
	            tempOPP.InsuranceType__c = loopMO.f_AssuranceType__c;
	            //日期
	            if(!string.isblank(MigrationHelper.NULLValue(loopMO.AssuranceStartDate__c)) && loopMO.AssuranceStartDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopMO.AssuranceStartDate__c.split('/');
	                tempOPP.InsuranceStartDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            //日期
	            if(!string.isblank(MigrationHelper.NULLValue(loopMO.AssuranceEndDate__c)) && loopMO.AssuranceEndDate__c != '0000-00-00')
	            {
	                list<string> alldate = loopMO.AssuranceEndDate__c.split('/');
	                tempOPP.InsuranceEndDate__c	 = Date.newInstance(integer.valueOf(alldate[0]), integer.valueOf(alldate[1]), integer.valueOf(alldate[2]));	
	            }
	            
	            //領牌人身份證
	            if(!string.isBlank(loopMO.f_UniIDcode__c))
		        {
		            //取代全型文字。
		            tempOPP.LicensingPersonID__c = loopMO.f_UniIDcode__c.replace('Ａ', 'A').replace('Ｂ', 'B').replace('Ｃ', 'C').replace('Ｄ', 'D').replace('Ｅ', 'E').replace('Ｆ', 'F').replace('Ｇ', 'G').replace('Ｈ', 'H').replace('Ｉ', 'I').replace('Ｊ', 'J').replace('Ｋ', 'K').replace('Ｌ', 'L').replace('Ｍ', 'M').replace('Ｎ', 'N').replace('Ｏ', 'O').replace('Ｐ', 'P').replace('Ｑ', 'Q').replace('Ｒ', 'R').replace('Ｓ', 'S').replace('Ｔ', 'T').replace('Ｕ', 'U').replace('Ｖ', 'V').replace('Ｗ', 'W').replace('Ｘ', 'X').replace('Ｙ', 'Y').replace('Ｚ', 'Z');	
		        }
		        */
		        //待補。
		        //tempOPP.description = '購買車型：['+loopMO.BuyCarBrand__c+']['+loopMO.BuyCarGeneration__c+']['+loopMO.BuyCarDiscription__c+']['+loopMO.BuyCarColor__c+']\n';
	            if(!string.isblank(MigrationHelper_OPP.NULLValue(loopMO.CurrentCarType__c)))
	            {
	            	tempOPP.OtherInfo__c = loopMO.CurrentCarType__c;
	            	list<string> tempSTRList = loopMO.CurrentCarType__c.replace('[', '').split(']');
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
	            //待補。
	            //tempOPP.SellingBrand__c = loopMO.BuyCarBrand__c;
	            //tempOPP.SellingGeneration__c = loopMO.BuyCarGeneration__c;
	            //tempOPP.SellingCarType__c = loopMO.BuyCarDiscription__c;
	            //tempOPP.SellingColor__c = loopMO.BuyCarColor__c;
	            tempOPP.CarOwnerType__c = loopMO.f_CarOnwerType__c;
	            
	            //tempOPP.LeasingCompanyRef__c = MigrationHelper.NULLValue(loopMO.f_RentalCompany__c);
	        	tempOPP.Field1__c = loopMO.f_AgeRange__c;
	        	//舊既有客戶編號。
	            //tempOPP.ExistCustomerID__c = loopMO.CustomerNO__c;//有望沒有客戶編號。
	            tempOPP.Driver__r = new Account(pkey__c = tempACC.pkey__c);
	            tempOPP.Account = new Account(pkey__c = tempACC.pkey__c);
	            tempOPP.Stagename = '來電';
	            if(loopMO.CreatDateTime__c != null)
		        {
					//格式為11/1/201715:37:57，m/d/yyyyHH:mm:ss		        	
		        	string HH = loopMO.CreatDateTime__c.right(8);
		        	string YY = loopMO.CreatDateTime__c.replace(HH, '');
		        	list<string> YYlist = YY.split('/');
		        	//可以吃2000-1-1的格式。
		        	tempOPP.CreatedDate = Datetime.valueOf(YYlist[2]+'-'+YYlist[1]+'-'+YYlist[0]+ ' '+HH);
		        }
		        else
		        {
		        	//不用轉，可以直接用，科科。
		        	tempOPP.CreatedDate = loopMO.CreatedDate;
		        }
		        //tempOPP.LicensingOfPeople__c = MigrationHelper_OPP.NULLValue(loopMO.CarOwnerNAME__c); //無領牌人
		        if(loopMO.ExcelSourceBrand__c !='BPS' )
		        {
		        	//一般銷售。
		        	tempOPP.recordtypeId = '0127F000000IFegQAG';
		        }
		        else
		        {
		        	//中古車銷售。
		        	tempOPP.recordtypeId = '0127F000000J6GGQA0';
		        	tempOPP.IsUsedCar__c = '是';
		        }
		        tempOPP.OpptyNamebackup__c = MigrationHelper_OPP.NULLValue(loopMO.Negotiator__c);
		        tempOPP.CustomerRating__c = 'C';
	            tempOPP.Old_SourceDealer__c = loopMO.ExcelSourceDealer__c+'_有望';
	            tempOPP.oldcustId__c = loopMO.OpptyNo__c; 
				
				insert tempOPP;
	        }
	        catch (Exception e) {
	    		string errorMsg = e.getMessage();
		        if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
		            errorMsg = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
		        }
				tempOPPResult = errorMsg;
			}
			
			update new MigrationOppty__c(
				id=loopMO.id, NEW_ACCResult__c = tempACCResult.left(255), NEW_OPPResult__c= tempOPPResult.left(255),
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
select count(id) from MigrationOppty__c where ExcelSourceDealer__c = '鎔德'
select count(id) from account 
select count(id) from opportunity 
select count(id) from MigrationOppty__c where ExcelSourceDealer__c = '鎔德'
select count(id) from MigrationOppty__c where ExcelSourceDealer__c = '鎔德' and NEW_ACCResult__c != null and NEW_ACCResult__c != 'OK!'
select count(id) from MigrationOppty__c where ExcelSourceDealer__c = '鎔德' and NEW_OPPResult__c != null and NEW_OPPResult__c != 'OK!'

select id, CustomerName__c, CustomerNO__c, NEW_ACCResult__c, NEW_OPPResult__c from dearInfo__c 
where NEW_ACCResult__c!=null and NEW_OPPResult__c!= 'OK!' and ExcelSourceDealer__c = '鎔德'


list<string> t = new list<string>();
t.add('a0WN0000004T3mvMAC');
MigrationHelper_OPP.newAll(t);

list<opportunity> d = [select id from opportunity];
delete d;

list<account> d = [select id from account];
delete d;
*/