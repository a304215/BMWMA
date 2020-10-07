@isTest
private class MonthlyScalesTargetProcess_scheTest {

    //In the test class, insert 200 Lead records, schedule the
    //DailyLeadProcessor class to run and test that all
    //Lead records were updated correctly.

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @isTest static void testScheduledJob() {

        List<SalesTarget__c> STs = new List<SalesTarget__c>();
        // insert 10 SalesTarget__c
        for (Integer i=0;i<10;i++) {
            STs.add(new SalesTarget__c());
        }
        insert STs;

        //DailyLeadProcessor dlp = new DailyLeadProcessor();
        //// Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        //String sch = '20 30 8 10 2 ?';
        //String jobID = System.schedule('DailyLeadProcessor', sch, dlp);

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
        CRON_EXP,
        new MonthlyScalesTargetProcess_sche()); //new DailyLeadProcessor());
        //// Verify the scheduled job has not run yet.
        //List<Task> lt = [SELECT Id
        //    FROM Task
        //    WHERE WhatId IN :opptyIds];
        //System.assertEquals(0, lt.size(), 'Tasks exist before job has run');
        // Stopping the test will run the job synchronously
        Test.stopTest();

        //ls = [SELECT id from lead where leadsource ='Dreamforce'];
        //System.assertEquals(200,
        //    ls.size(),
        //    'leads were not updated');

    }

}