global class ClearWaveSource_batch implements Database.Batchable<sObject> {
	
	String query;
	String jobid;
	String Year;
	String Month;
	
	global ClearWaveSource_batch(string ClearSOQL, string inputjobid, string inputYear, String inputMonth) 
	{
		query = ClearSOQL;
		jobid = inputjobid;
		Year = inputYear;
		Month = inputMonth;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<WaveKPISource__c> WKPIS_L) 
   	{
		ClearWaveSourcehandler.doClearWaveSource(WKPIS_L);
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		datetime nextScheduleTime = system.now().addMinutes(1);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second+' '+minute+' * * * ?' ;
        system.schedule('WaveSourceGenaratefromOpp_schedule', cronvalue, new WaveSourceGenaratefromOpp_schedule(Year, Month));
	}
	
}