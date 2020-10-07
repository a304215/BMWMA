global class AssetBatchUpdate implements Database.Batchable<sObject> {

	String query;

	global AssetBatchUpdate() {
      // 查詢所有有 VIN 和 車牌 的有望
		query =
      'select OwnerId, LicensePlate__c, DeliveryDate__c, AccountID, Estimateddateofnew__c, ' +
      '       SelectedCar__c, inputVIN__C, Id, Amount, PaymentMethod__c, LicensingOfPeople__c, LicensingPersonID__c, ' +
      '       LicensingGender__c, LicensingOfDate__c, Insurance__c, InsuranceType__c, InsuranceStartDate__c, ' +
	  '       Driver__c, ' +
      '       InsuranceEndDate__c, CarOwnerType__c, LicensingType__c, LeasingPeriod__c ' +
      '  from opportunity where stageName = \'交車\' ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Opportunity> scope) {

        //set<id> opptVINid = new set<id>();
        //set<id> assetVINid = new set<id>();
         // 蒐集 Opportunity 的 VIN
         /*
   		for(opportunity o : scope)
   		{
   		    opptVINid.add(o.SelectedCar__c);
   		}
   		*/
        /* 不用這一段。 讓所有的OPP 都有自己的ASSET。
        // 蒐集 Asset 已存在的 VIN
        for(asset a : [select vin__c from asset where id in : opptVINid]){
            assetVINid.add(a.vin__c);
        }
		*/
   		list<asset> assets = new list<asset>();
         // 蒐集 還沒有 Asset 對應的 有望 Opportunity
   		for(opportunity o : scope)
   		{
   		    //system.debug('o.SelectedCar__c: ' + o.SelectedCar__c);
            //沒對應到 Asset 的 VIN Id 才新增
   		    //if(!assetVINid.contains(o.SelectedCar__c))
   		    {
   		        asset a = new asset();
   		        a.Name  = (o.LicensePlate__c==null?'NULL-NULL':o.LicensePlate__c);
   		        a.RecordTypeId  = '0127F000000IOda';
   		        a.Status  = '舊車補登';
   		        a.NumberPlate__c  = o.LicensePlate__c;
   		        a.InstallDate  = o.DeliveryDate__c;
   		        a.AccountID  = o.Driver__c;
   		        a.UsageEndDate  = o.Estimateddateofnew__c;
   		        //a.VIN__c  = o.SelectedCar__c;
   		        a.AddedVin__c  = o.inputVIN__C;
   		        a.OpportunityFrom__c  = o.Id;
   		        a.Amount__c  = o.Amount;
   		        a.PaymentMethod__c  = o.PaymentMethod__c;
   		        a.Licensee__c  = o.LicensingOfPeople__c;
   		        a.LicenseeIDNo__c  = o.LicensingPersonID__c;
   		        a.LicenseeGender__c  = o.LicensingGender__c;
   		        a.PurchaseDate  = o.LicensingOfDate__c;
   		        a.Insurer__c  = o.Insurance__c;
   		        a.InsuranceType__c  = o.InsuranceType__c;
   		        a.InsuranceStartDate__c  = o.InsuranceStartDate__c;
   		        a.InsuranceEndDate__c  = o.InsuranceEndDate__c;
   		        a.CarOwnerType__c  = o.CarOwnerType__c;
   		        a.LicensingType__c  = o.LicensingType__c;
   		        a.LeasingPeriod__c  = o.LeasingPeriod__c;
   		        a.OwnerId = o.OwnerId;
                a.AssetServicedById = o.AccountID;
   		        assets.add(a);
   		    }
   		    //if(assets.size() > 2500) break;
   		}
   		system.debug(assets.size());
   		insert assets;
	}

	global void finish(Database.BatchableContext BC) {

	}

}