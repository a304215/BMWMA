global class WaveSourceGenaratefromLead_batch implements Database.Batchable<sObject> {
	
	String query;
	String jobid;
	
	global WaveSourceGenaratefromLead_batch(string LeadSOQL, string inputjobid) 
	{
		query = LeadSOQL;
		jobid = inputjobid;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<lead> Lead_L) 
   	{
		WaveSourceGenaratefromLeadhandler.DoGenarateWaveSource(Lead_L);
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		system.abortJob(jobid);
	}
	
}