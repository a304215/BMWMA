global class WaveSourceGenaratefromOpp_schedule implements Schedulable 
{
    string year;
    string month;
    public WaveSourceGenaratefromOpp_schedule(){}

    public WaveSourceGenaratefromOpp_schedule(string inputYear, string inputMonth)
    {
        year = inputYear;
        month = inputMonth;
    }

    global void execute(SchedulableContext sc) 
    {
    	string OppSOQL = ' select id, OwnerId, Owner.Retailer__c, Owner.Branch__c, StageName, owner.Profile.Name, LeadSource, SelectedCar__r.CarType__c, ';
    	OppSOQL += ' SelectedCar__r.Brand__c, SelectedCar__r.CarGeneration__c, Owner.LastName, Owner.Firstname, DeliveryDate__c, TestDriveDate__c, SigningDate__c, CreatedDate ';
    	OppSOQL += ' from Opportunity ';

        if(year != null && month != null)
        {
            OppSOQL += ' where CALENDAR_YEAR(CreatedDate) = ' + year + ' and CALENDAR_MONTH(CreatedDate) = ' + month;
        }else if(year != null)
        {
            OppSOQL += ' where CALENDAR_YEAR(CreatedDate) = ' + year;
        }
        else
        {
            string todayYear = string.valueof((system.today()-1).year());
            string todayMonth = string.valueof((system.today()-1).month()).length()<2 ? '0' + string.valueof((system.today()-1).month()) : string.valueof((system.today()-1).month());
            OppSOQL += ' where CALENDAR_YEAR(CreatedDate) = ' + todayYear;
        }

        system.debug('++++OppSOQL: '+OppSOQL);

    	try
    	{
    		database.executebatch(new WaveSourceGenaratefromOpp_batch(OppSOQL, sc.getTriggerId(), year, month), 200);
    	}
    	catch (exception ex)
    	{

    	}
        finally
        {
            
        }
    }
}