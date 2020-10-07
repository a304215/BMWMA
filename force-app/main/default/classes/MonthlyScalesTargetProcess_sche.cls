global class MonthlyScalesTargetProcess_sche implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        MonthlySalesTargetProcessor b = new MonthlySalesTargetProcessor();
        database.executebatch(b);
    }
}