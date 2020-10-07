public with sharing class post_mail_controller {
    public post_mail_controller() {

    }
    @AuraEnabled
    public static list<Report> getRecord(){
        List<Report> returnReports = new List<Report>();
        List<Folder> matchFolders = [SELECT Id FROM Folder WHERE name =: 'BMWLinePush'];
        List<Report> qeuryAllReports = [SELECT Id, Name FROM Report WHERE OwnerId = :matchFolders.get(0).Id AND Format != 'MultiBlock'];
        for(Report report : qeuryAllReports) {
            String reportId = (String) report.get('Id');
            Reports.ReportDescribeResult results = Reports.ReportManager.describeReport(reportId);
            Reports.ReportMetadata rm = results.getReportMetadata();
            Integer matchColumnNumber = 0;
            for(String columnName : rm.getDetailColumns()) {
                if('Line_User__c.CustomerUser__c.Name'.equalsIgnoreCase(columnName)) {
                    matchColumnNumber++;
                }
                if(matchColumnNumber == 1) {
                    returnReports.add(report);
                    break;
                }
            }
        }
        return returnReports;
    }
    @AuraEnabled
    public static list<string> getRecordDetail(string reportId){
        list<string> return_list = new list<string>();
        list<string> phone_list = new list<string>();
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        List<String> columns = reportMd.getDetailColumns();
		Reports.reportResults results = Reports.ReportManager.runReport(reportId,reportMd, true);
        Reports.ReportFactWithDetails factWithDetails = (Reports.ReportFactWithDetails) results.getFactMap().get('T!T');
        List<Reports.ReportDetailRow> reportRows = factWithDetails.getRows();
        for(Reports.ReportDetailRow reportRow : reportRows) {
            System.debug(reportRow.getDataCells()[0].getValue());
            if(!return_list.contains((string)reportRow.getDataCells()[0].getValue())){
                return_list.add((string)reportRow.getDataCells()[0].getValue());
            }
        }
        for(string line_user :return_list){
            System.debug(return_list);
            // Line_User__c each_line_user = [select id,customerUser__r.Entity__c from Line_User__c where id = 'a171s000000Xz10AAC'];
            // System.debug(each_line_user.customerUser__r.Entity__c);
        }
        return return_list;
    }
    @AuraEnabled
    public static void send_mail_with_line_user(list<string> line_user_record){
        System.debug(line_user_record);
        list<string> send_mail_list = new list<string>();
        for(Integer i = 0 ; i < line_user_record.size();i++){
            if(!send_mail_list.contains(line_user_record[i])){
                send_mail_list.add(line_user_record[i]);
            }
        }
        System.debug(send_mail_list);
    }
}