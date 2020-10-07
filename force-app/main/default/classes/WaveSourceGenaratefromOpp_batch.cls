global class WaveSourceGenaratefromOpp_batch implements Database.Batchable<sObject> 
{
    String query;
    String jobid;
    String Year;
    String Month;
    
    global WaveSourceGenaratefromOpp_batch(string OppSOQL, string inputjobid, string inputYear, String inputMonth) 
    {
        query = OppSOQL;
        jobid = inputjobid;
        Year = inputYear;
        Month = inputMonth;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> Opp_L) 
    {
        WaveSourceGenaratefromOpphandler.DoGenarateWaveSource(Opp_L);
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        system.abortJob(jobid);
        datetime nextScheduleTime = system.now().addMinutes(1);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second+' '+minute+' * * * ?' ;
        system.schedule('WaveSourceGenaratefromLead_schedule', cronvalue, new WaveSourceGenaratefromLead_schedule(Year, Month));
    }
    
}