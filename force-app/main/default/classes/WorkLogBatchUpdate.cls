global class WorkLogBatchUpdate implements Database.Batchable<sObject> {

	String query;

	global WorkLogBatchUpdate() {
      // 查詢所有 聯繫記錄
		query =
		'select id, LogCust__c, LogOppty__c, OldCustomerNo__c, ownerid '+
		'  from worklog__c ' +
		' where OldCustomerNo__c != \'\'  and LogOppty__c = null';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<worklog__c> scope) {
   		set<string> custid = new set<string>();
         // 蒐集 舊客戶編號
   		for(worklog__c wl : scope)
   		{
   		    custid.add(wl.OldCustomerNo__c);
   		}
         // 找到 舊客戶編號 對應的 有望 Opportunity
   		list<opportunity> oppts =
   		    [select id, accountid, oldcustId__c, ownerid
   		     from opportunity where oldcustId__c in : custid];

   		map<string, opportunity> mapCustIdOppts = new map<string, opportunity>();
         // 蒐集 舊客戶編號 和 有望 object 的 map
   		for(opportunity o : oppts)
   		{
   		    mapCustIdOppts.put(o.oldcustId__c, o);
   		}

   		list<worklog__c> result = new list<worklog__c>();
         // 逐筆 WorkLog 填入有望 ID，有望所屬客戶 ID，及有望 OwnerId
   		for(worklog__c wl : scope)
   		{
   		    opportunity o = mapCustIdOppts.get(wl.OldCustomerNo__c);
   		    if(o != null)
   		    {
   		        wl.LogCust__c = o.accountid;
   		        wl.LogOppty__c = o.id;
   		        wl.ownerid = o.ownerid;
   		        result.add(wl);
   		    }
   		}

   		system.debug(result.size());
   		update result;

	}

	global void finish(Database.BatchableContext BC) {

	}

}