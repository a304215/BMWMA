global class CaseBatchUpdate implements Database.Batchable<sObject> {

	String query;

	global CaseBatchUpdate() {
		// 查詢所有 保修記錄
		query =
		'select id, sys_pk__c, chassisno__c, vin__c, assetid ' +
		'  from case ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<case> scope) {
		set<string> vin = new set<string>();
		// 蒐集 case 中 文字形式的 VIN
		for(case c : scope)
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

		for(case c : scope)
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

		update scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

}