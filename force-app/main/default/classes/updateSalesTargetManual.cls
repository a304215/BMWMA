public class updateSalesTargetManual {
    private string targetYear{set;get;}
    private string targetMonth{set;get;}
    public string CalculateResult{set;get;}
    private final SalesTarget__c st;
    public string CalculateResult2{set;get;}

    
	public updateSalesTargetManual(ApexPages.StandardController stdController)
    {
        st = (SalesTarget__c)stdController.getRecord();
        st.TargetYear__c = string.valueOf( date.today().year() );
        targetMonth = string.valueOf( date.today().month() );
        if( targetMonth.length() < 2)
        {
            targetMonth = '0' + targetMonth;
        }
        st.TargetMonth__c = targetMonth;
    }

    public void checkScheduleStatus()
    {
        list<CronTrigger> job = new list<CronTrigger>();
        job =  [SELECT CronExpression, CronJobDetailId, EndTime, NextFireTime,State, id  FROM CronTrigger where CronJobDetail.Name = 'ClearWaveSource_schedule_manual'];
        if(job.size() == 1)
        {
            if(job[0].state == 'DELETED')
            {
                if([SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType, State FROM CronTrigger where CronJobDetail.Name in ('WaveSourceGenaratefromOpp_schedule', 'WaveSourceGenaratefromLead_schedule')].size() > 0)
                {
                    CalculateResult2 = '正在進行排程工作.';
                }
                else
                {
                    system.abortJob(job[0].Id);
                    CalculateResult2 = '排程已完成.';
                }
            }
            else
            {
                CalculateResult2 = '正在進行排程工作.';
            }
        }
        else if(job.size() == 0)
        {
            CalculateResult2 = '目前無工作或已完成排程.';
        }
    }
    
    public pagereference startCalculate()
    {
        updateMonthlySalesTarget uST = new updateMonthlySalesTarget();
        system.debug('+++st.TargetYear__c: '+st.TargetYear__c);
        system.debug('+++st.TargetMonth__c: '+st.TargetMonth__c);
        uST.year = st.TargetYear__c;
        uST.month = st.TargetMonth__c;
        uST.updateData();
        CalculateResult = '   計算完成! [' + st.TargetYear__c + '-' + st.TargetMonth__c + ']';
        return null;
    }

    public pagereference scheduleClearWaveSource()
    {
        string jobname = 'ClearWaveSource_schedule_manual';
        String str = Datetime.now().addMinutes(1).format('s m H d M ? yyyy');
        list<CronTrigger> job = new list<CronTrigger>();
        system.debug('+++st.TargetYear__c: '+st.TargetYear__c);
        system.debug('+++st.TargetMonth__c: '+st.TargetMonth__c);
        ClearWaveSource_schedule CWSS = new ClearWaveSource_schedule(st.TargetYear__c, st.TargetMonth__c);
        job =  [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType, State FROM CronTrigger where CronJobDetail.Name =: jobname];

        if(job.size() == 1)
        {
            if(job[0].state == 'DELETED')
            {
                if([SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType, State FROM CronTrigger where CronJobDetail.Name in ('WaveSourceGenaratefromOpp_schedule', 'WaveSourceGenaratefromLead_schedule')].size() > 0)
                {
                    CalculateResult2 = '正在進行排程工作.';
                }
                else
                {
                    system.abortJob(job[0].Id);
                    CalculateResult2 = '排程已完成.';
                }
            }
            else
            {
                CalculateResult2 = '正在進行排程工作.';
            }
        }
        else if(job.size() == 0)
        {
            system.schedule(jobname, str, CWSS);
            CalculateResult2 = '已排程約一分鐘後開始計算.';
        }

        return null;
    }
}