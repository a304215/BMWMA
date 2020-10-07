public class TriggerHandler_Case 
{
    public static void bindingCaseNAssetNAccount(list<case> updCase)
    {    
        /* 舊der。歷史業障
        // 取得每個 Account 以及交車日期是最新一筆的 Asset
        map<string, Asset> VINAssets = new map<string, Asset>();
        for(Account acct : [select id, (select id, AccountId, VIN__c, InstallDate 
                                        from Assets order by InstallDate desc )
                            from Account])
        {	
			if( acct.Assets != null & acct.Assets.size() > 0)
            {
                list<Asset> tmplst = acct.Assets;
                Asset tmpast = tmplst[0];
                VINAssets.put(string.valueOf(tmpast.VIN__c), tmpast);
            }
		}
        //=> system.debug(VINAssets);
        // 從 Case 的車身碼找出對應的 Account 及 Asset
        for(case c : updCase)
        {
            if( !string.isBlank(c.VIN__c))
            {
                Asset ast = VINAssets.get(string.valueOf(c.VIN__c));
                if( ast != null)
                {
                    c.AssetId = ast.Id;
                    c.AccountId = ast.AccountId;
                }
            }
        }
        //=> system.debug(updCase);
        //=> update updCase;
        //
        */
        
        set<string> vin = new set<string>();
		// 蒐集 case 中 文字形式的 VIN
		for(case c : updCase)
		{
			vin.add(c.chassisno__c);
		}

		map<string, newcarpool__c> mapVINNewCar = new map<string, newcarpool__c>();
		list<newcarpool__c> newcars =
			[select id, vin_short__c
			 from newcarpool__c where vin_short__c in : vin];

		set<Id> VINId = new set<Id>();
		// 蒐集 VIN 短碼 和 車源 object 的 map
		for(newcarpool__c nc : newcars)
		{
			VINId.add(nc.Id);
			newcarpool__c tmpnc = mapVINNewCar.get(nc.vin_short__c);
			if(tmpnc == null)
			{
				mapVINNewCar.put(nc.vin_short__c, nc);
			}
		}

		map<string, asset> mapVINAsset = new map<string, asset>();
		list<asset> assets =
			[select id, vin__c, vin__r.vin_short__c, InstallDate, OwnerId
			 from asset where vin__c in : VINId
			 order by InstallDate desc];
		// 蒐集 VIN 短碼 和 現有車款 object 的 map
		for(asset a : assets)
		{
			asset tmpa = mapVINAsset.get(a.vin__r.vin_short__c);
			if(tmpa == null)
			{
				newcarpool__c nc = a.vin__r;
				if(!string.isblank(nc.vin_short__c))
				{
					mapVINAsset.put(nc.vin_short__c, a);
				}
			}
		}

		for(case c : updCase)
		{
			newcarpool__c tmpnc = mapVINNewCar.get(c.chassisno__c);
			// 填入 車源的 ID
			if( tmpnc != null)
			{
				c.vin__c = tmpnc.Id;
			}
			asset tmpasset = mapVINAsset.get(c.chassisno__c);
			// 填入 現有車款的 ID 和 Owner Id
			if( tmpasset != null)
			{
				c.assetid = tmpasset.Id;
				c.OwnerId = tmpasset.OwnerId;
			}
		}
    }
}