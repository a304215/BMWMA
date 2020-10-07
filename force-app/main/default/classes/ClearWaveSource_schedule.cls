global class ClearWaveSource_schedule implements Schedulable 
{
  	string year;
    string month;
    
    public ClearWaveSource_schedule(){}
    public ClearWaveSource_schedule(string inputYear, string inputMonth)
    {
        year = inputYear;
        month = inputMonth;
    }

	global void execute(SchedulableContext sc) 
	{
		string ClearSOQL = ' select id ';
    	ClearSOQL += ' from WaveKPISource__c ';

    	if(year != null && month != null)
        {
            ClearSOQL += ' where (Year__c = ' + '\'' + year + '\'' + ' and Month__c = ' + '\'' + month + '\'';
        }
        else if(year != null)
        {
            ClearSOQL += ' where (Year__c = ' + '\'' + year + '\'';
        }
        else
        {
            string todayYear = string.valueof(system.today().addDays(-1).year());
            string todayMonth = string.valueof(system.today().addDays(-1).month()).length()<2 ? '0' + string.valueof(system.today().addDays(-1).month()) : string.valueof(system.today().addDays(-1).month());
            ClearSOQL += ' where (Year__c = ' + '\'' + todayYear + '\'';
        }

        ClearSOQL += ' ) or (Year__c =\'\' or Year__c = null or Month__c = \'\' or Month__c = null) ';

        system.debug('++++ClearSOQL: '+ClearSOQL);

    	try
    	{
    		database.executebatch(new ClearWaveSource_batch(ClearSOQL, sc.getTriggerId(), year, month), 200);
    	}
    	catch (exception ex)
    	{

    	}
    	finally
        {
        }
	}
}