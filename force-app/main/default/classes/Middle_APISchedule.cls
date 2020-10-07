global without sharing class Middle_APISchedule implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {
        System.enqueueJob(new Middle_API(null));
    }
}

/*
Middle_APISchedule r = new Middle_APISchedule();
String hour = String.valueOf(Datetime.now().addMinutes(10).hour());
String min = String.valueOf(Datetime.now().addMinutes(10).minute());
String ss = String.valueOf(Datetime.now().addMinutes(10).second());
ss = '00'; 
ss = '00'; 
String nextFireTime = ss + ' ' + min + ' ' + '*' + ' * * ?';   
System.schedule('Middle_APISchedule start at: ' + String.valueOf(Datetime.now()), nextFireTime, r);
*/