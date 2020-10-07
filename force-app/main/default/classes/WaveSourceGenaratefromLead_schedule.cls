global class WaveSourceGenaratefromLead_schedule implements Schedulable 
{
	string year;
    string month;
    public WaveSourceGenaratefromLead_schedule(){}

    public WaveSourceGenaratefromLead_schedule(string inputYear, string inputMonth)
    {
        year = inputYear;
        month = inputMonth;
    }

	global void execute(SchedulableContext sc) 
	{
		string LeadSOQL = ' select id, status, LeadSource, ownerid, ConvertedOpportunityId, ';
    	LeadSOQL += ' CreatedDate ';
    	LeadSOQL += ' from lead ';

    	if(year != null && month != null)
        {
            LeadSOQL += ' where CALENDAR_YEAR(CreatedDate) = ' + year + ' and CALENDAR_Month(CreatedDate) = ' + month;
        }
        else if(year != null)
        {
            LeadSOQL += ' where CALENDAR_YEAR(CreatedDate) = ' + year;
        }
        else
        {
            string todayYear = string.valueof(system.today().year());
            string todayMonth = string.valueof(system.today().month()).length()<2 ? '0' + string.valueof(system.today().month()) : string.valueof(system.today().month());
            LeadSOQL += ' where CALENDAR_YEAR(CreatedDate) = ' + todayYear;
        }

        system.debug('+++LeadSOQL: '+LeadSOQL);

    	try
    	{
    		database.executebatch(new WaveSourceGenaratefromLead_batch(LeadSOQL, sc.getTriggerId()), 200);
    	}
    	catch (exception ex)
    	{

    	}
    	finally
        {
        }
	}
}