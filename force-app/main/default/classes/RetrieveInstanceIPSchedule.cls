global with sharing class RetrieveInstanceIPSchedule implements Schedulable{
    public RetrieveInstanceIPSchedule() {

    }

    global void execute(SchedulableContext SC) 
    {
        RetrieveInstanceIP.GetIP();
    }
}