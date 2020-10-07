/* =======================================================================================================================
 * 產生Report List 的QUQUQU。
 * 
 * 
 * ======================================================================================================================= */
public without sharing class LinePushContentReportQueue implements Queueable, Database.AllowsCallouts {

    private LINE_Content__c exportJob;
    private Integer paginationColumn;
    private String paginationField;
    private string currentPageValue;
    private string reportType;
    

    public LinePushContentReportQueue(LINE_Content__c inputExportJob) {
        exportJob = inputExportJob;
        if(exportJob.Total_Rows__c == null) {
            exportJob.Total_Rows__c = 0;
            currentPageValue = '00000000';
        }
    }

    private Reports.ReportMetadata getReportMetadata() {
        // Get the metadata from  Reports.ReportManager.describeReport(exportJob.Report_Id__c)
        // Set the report params so that it is exportable e.g. make sure we include the field
        // to paginate on
        
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(exportJob.ReportId__c);
		// Get the report metadata
        Reports.ReportMetadata rm = describe.getReportMetadata();
        reportType = rm.getReportType().getType();
        list<string> newList = rm.getDetailColumns();
        if(reportType.contains('Account'))
        {
            newList.add('Account.MyIndex__c');
            newList.add('Account.Account18ID__c');
            rm.setDetailColumns(newList);
        }
        else if(reportType.contains('Line_User__c'))
        {
            newList.add('Line_User__c.MyIndex__c');
            newList.add('Line_User__c.User18ID__c');
            rm.setDetailColumns(newList);
        }
        
        list<Reports.ReportFilter> allFilter = rm.getReportFilters();
        system.debug(rm.getReportBooleanFilter());
		if(reportType.contains('Account'))
        {
            Reports.SortColumn sortcolumn = new Reports.SortColumn();
            sortcolumn.setSortColumn('Account.MyIndex__c');//set the sort coloumn here with the name of the column
            sortcolumn.setSortOrder('ASCENDING');
            list<Reports.SortColumn> lstcolumns = new list<Reports.SortColumn>();
            lstcolumns.add(sortcolumn);
            rm.setSortBy(lstcolumns);

            Reports.ReportFilter myFilter  = new Reports.ReportFilter();
            myFilter.setColumn('Account.MyIndex__c');
            myFilter.setOperator('greaterThan');
            myFilter.setValue(currentPageValue);
            allFilter.add(myFilter);
        }
        else if(reportType.contains('Line_User__c'))
        {
            Reports.SortColumn sortcolumn = new Reports.SortColumn();
            sortcolumn.setSortColumn('Line_User__c.MyIndex__c');//set the sort coloumn here with the name of the column
            sortcolumn.setSortOrder('ASCENDING');
            list<Reports.SortColumn> lstcolumns = new list<Reports.SortColumn>();
            lstcolumns.add(sortcolumn);
            rm.setSortBy(lstcolumns);
            
            Reports.ReportFilter myFilter  = new Reports.ReportFilter();
            myFilter.setColumn('Line_User__c.MyIndex__c');
            myFilter.setOperator('greaterThan');
            myFilter.setValue(currentPageValue);
            allFilter.add(myFilter);
            
        }
        system.debug(allFilter);
		rm.setReportFilters(allFilter);
		
		//加上判斷customer filter logic。
		string customFilter = rm.getReportBooleanFilter();
		if(customFilter != null)
		{
            customFilter = '(' + customFilter + ') AND ' + string.valueOf(rm.getReportFilters().size());
            system.debug(customFilter);
			rm.setReportBooleanFilter(customFilter);
		}
		
		return rm;
    }

    public void execute(QueueableContext context) {
        try {
            if(exportJob.Report_Instance_Id__c == null) {
                exportJob.Report_Instance_Id__c = Reports.ReportManager.runAsyncReport(exportJob.ReportId__c, getReportMetadata(), true).getId();
                update exportJob;
                System.enqueueJob(new LinePushContentReportQueue(exportJob));
                System.debug('Starting first instance of report');
                return;
            }
            Reports.ReportInstance instance = Reports.ReportManager.getReportInstance(exportJob.Report_Instance_Id__c);
            String instanceStatus = instance.getStatus();
            System.debug('instanceStatus: ' + instanceStatus);
            if(instanceStatus == 'Running' || instanceStatus == 'New') {
                System.enqueueJob(new LinePushContentReportQueue(exportJob));
                System.debug('Report is still running, re-queueing self');
                return;
            } else if(instanceStatus == 'Error') {
                exportJob.Status__c = '報告產生錯誤';
                update exportJob;
                System.debug('Report has errors, exiting');
                return;
            }
    
            System.debug('Getting results...');
    
            Reports.ReportResults results = instance.getReportResults();
            
            Reports.ReportExtendedMetadata rmd =   results.getReportExtendedMetadata();
            
            // Get detail columns from extended metadata
            Map<String,Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();
            integer myIndex = 0;
            integer myIndex2 = 0;
            //Account.Account18ID__c 為必要欄位。
            for(String key : colMap.KeySet()){
                if(Key == 'Account.Account18ID__c')
                {
                    break;
                }
                if(Key == 'Line_User__c.User18ID__c')
                {
                    break;
                }
                myIndex++;
            }
            //Account.MyIndex__c 為必要欄位。
            for(String key : colMap.KeySet()){
                if(Key == 'Account.MyIndex__c')
                {
                    break;
                }
                if(Key == 'Line_User__c.MyIndex__c')
                {
                    break;
                }
                myIndex2++;
            }
            
            list<string> accIds = new list<string>();
            
            Reports.ReportFactWithDetails factWithDetails = (Reports.ReportFactWithDetails) results.getFactMap().get('T!T');
            
            List<Reports.ReportDetailRow> reportRows = factWithDetails.getRows();
            
            if(reportRows.isEmpty()) {
                exportJob.Status__c = '寄送名單產生完畢';
                
                update exportJob;
                System.debug('Report has no results, exiting');
            } else {
                System.debug('Processing results...');
                exportJob.Total_Rows__c += reportRows.size();
                currentPageValue = (String) reportRows[reportRows.size() - 1].getDataCells()[myIndex2].getValue();
                
                
                for (Reports.ReportDetailRow row : factWithDetails.getRows()) {
                    accIds.add(row.getDataCells()[myIndex].getLabel());
                }
                list<Line_Push__c> insertList = new list<Line_Push__c>();
                
                for(Line_User__c loopID: [
                    select id, UDID__c, Account__c
                    from Line_User__c 
                    where Line_Account__c=: exportJob.Line_Account__c
                    and (Account__c in:accIds or id in: accIds)
                ])
                {
                    insertList.add(new Line_Push__c(
                        Account__c = loopID.Account__c,
                        Line_Account__c = exportJob.Line_Account__c, 
                        Line_User__c = loopID.id, 
                        Line_Content__c = exportJob.id, 
                        SF_Push__c = true
                    ));
                }
                
                insert insertList;
                
                if(reportRows.size() == 2000) {
                    // Add filters to the metadata, using paginationValue
                    exportJob.Report_Instance_Id__c = Reports.ReportManager.runAsyncReport(exportJob.ReportId__c, getReportMetadata(), true).getId();
                    update exportJob;
                    requeue();
                    System.debug('Starting next instance of report');
                } else {
                    if(exportJob.SendNow__c)
                    {
                        exportJob.Status__c = '寄送名單產生完畢';
                    }
                    else
                    {
                        exportJob.Status__c = '寄送名單產生完畢';
                    }
                    update exportJob;
                    System.debug('Less than 2000 rows returned, report complete');
                }
            }
        } catch (Exception ex) {
            exportJob.Status__c = '報告產生錯誤';
            exportJob.reportResult__c = ex.getMessage();
            update exportJob;
        }
        
    }

    private void requeue() {
        if(!(Test.isRunningTest() && System.isQueueable())) {
            System.enqueueJob(new LinePushContentReportQueue(exportJob));
        }
    }
}