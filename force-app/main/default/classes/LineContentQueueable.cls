/* =======================================================================================================================
 * 產生Report List 的QUQUQU。
 * 
 * 
 * ======================================================================================================================= */
public without sharing class LineContentQueueable implements Queueable, Database.AllowsCallouts {

    private LINE_Content__c exportJob;
    private Integer paginationColumn;
    private String paginationField;
    private string currentPageValue;
    

    public LineContentQueueable(LINE_Content__c inputExportJob) {
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
		list<string> newList = rm.getDetailColumns();
		newList.add('Account.MyIndex__c');
        newList.add('Account.Account18ID__c');
		rm.setDetailColumns(newList);
		
		Reports.SortColumn sortcolumn = new Reports.SortColumn();
		sortcolumn.setSortColumn('Account.MyIndex__c');//set the sort coloumn here with the name of the column
		sortcolumn.setSortOrder('ASCENDING');
		list<Reports.SortColumn> lstcolumns = new list<Reports.SortColumn>();
		lstcolumns.add(sortcolumn);
		rm.setSortBy(lstcolumns);
		
		list<Reports.ReportFilter> allFilter = rm.getReportFilters();
		system.debug(rm.getReportBooleanFilter());
		Reports.ReportFilter myFilter  = new Reports.ReportFilter();
		myFilter.setColumn('Account.MyIndex__c');
		myFilter.setOperator('greaterThan');
		myFilter.setValue(currentPageValue);
		allFilter.add(myFilter);
		rm.setReportFilters(allFilter);
		
		//加上判斷customer filter logic。
		string customFilter = rm.getReportBooleanFilter();
		if(customFilter != null)
		{
			customFilter = '(' + customFilter + ') AND ' + string.valueOf(rm.getReportFilters().size());
			rm.setReportBooleanFilter(customFilter);
		}
		
		return rm;
    }

    public void execute(QueueableContext context) {
        if(exportJob.Report_Instance_Id__c == null) {
            exportJob.Report_Instance_Id__c = Reports.ReportManager.runAsyncReport(exportJob.ReportId__c, getReportMetadata(), true).getId();
            update exportJob;
            System.enqueueJob(new LineContentQueueable(exportJob));
            System.debug('Starting first instance of report');
            return;
        }
        Reports.ReportInstance instance = Reports.ReportManager.getReportInstance(exportJob.Report_Instance_Id__c);
        String instanceStatus = instance.getStatus();
        System.debug('instanceStatus: ' + instanceStatus);
        if(instanceStatus == 'Running' || instanceStatus == 'New') {
            System.enqueueJob(new LineContentQueueable(exportJob));
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
            myIndex++;
        }
        //Account.MyIndex__c 為必要欄位。
        for(String key : colMap.KeySet()){
            if(Key == 'Account.MyIndex__c')
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
                    from Line_User__c where Account__c in:accIds
                and Line_Account__c=: exportJob.Line_Account__c
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
    }

    private void requeue() {
        if(!(Test.isRunningTest() && System.isQueueable())) {
            System.enqueueJob(new LineContentQueueable(exportJob));
        }
    }
}