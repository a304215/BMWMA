global class OpportunityBatchUpdate implements Database.Batchable<sObject> {

	String query;

	global OpportunityBatchUpdate() {
		// 查詢所有 有望
		query =
		'select id, owner.Brand__c, SellingBrand__c, recordtypeId, stageName ' +
		'  from opportunity ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<opportunity> scope) {
		for(opportunity o: scope)
		{
			if( o.stageName == '交車')
			{
				// 交車直接鎖 recordType
				o.recordtypeId = '0127F000000Iuy0QAC';
			}
			else
			{
				// 非交車階段判斷品牌 : MINI
				if(o.owner.Brand__c == 'MINI')
				{
					o.SellingBrand__c = 'MINI';
				}
				// 非交車階段判斷品牌 : BPS
				if(o.owner.Brand__c == 'BPS')
				{
					o.recordtypeId = '0127F000000J6GGQA0';
					o.IsUsedCar__c = '是';
				}
			}
		}

	}

	global void finish(Database.BatchableContext BC) {

	}

}