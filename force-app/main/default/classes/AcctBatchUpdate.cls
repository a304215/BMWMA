global class AcctBatchUpdate implements Database.Batchable<sObject> {

	String query;

	global AcctBatchUpdate() {
		// 查詢所有 客戶
		query =
		'select id, ownerid, recordtypeId, name, lastname '+
		'  from account ';
		// +
		//' where OldCustomerNo__c != \'\' ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<account> scope) {
   		for(account a : scope)
   		{
   			// 處理個人帳戶
   			if( a.recordtypeId == '0127F000000IAMXQA4'){
   				a.lastname = a.lastname;
   			}
   			// 處理公司帳戶
   			else if( a.recordtypeId == '0127F000000IABeQAO' ){
   				a.name = a.name;
   			}
   			else{}
   		}
	}

	global void finish(Database.BatchableContext BC) {

	}

}