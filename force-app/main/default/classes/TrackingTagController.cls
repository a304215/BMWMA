public without sharing class TrackingTagController 
{
    public string mySiteID = site.getSiteId();
    public string TagId {get; set;}
    public string lineId {get; set;}
    public Line_Account__c LineAccount {get; set;}
    public Tracking_Tag__c theTag {get; set;}

    public TrackingTagController() 
    {
        TagId = ApexPages.currentPage().getParameters().get('tId');
        lineId = ApexPages.currentPage().getParameters().get('lineId');

        for(Line_Account__c loopAccount:[
            select id, name, SiteDomain__c, Disclaimer__c, Link_LineVerify__c, Link_LineInfo__c,
            ExchangeLIFF__c, Link_LineForgetPassword__c, Link_LineLogin__c, Link_LineMember__c,
            Link_LineModify__c, Link_LinePassword__c, Link_LineRegister__c, Link_LineResetPassword__c, Link_LineAsset__c, 
            Link_LineOneTimePassword__c, Link_LineNotOwnerRegister__c
            from Line_Account__c
            where SFDCSiteId__c =:mySiteID
        ])
        {
			LineAccount = loopAccount;
        }
        
        for(Tracking_Tag__c loopTag:[
            select id, name, URL__c
            from Tracking_Tag__c
            where id =:TagId
        ])
        {
			theTag = loopTag;
		}
    }

    public pageReference exchangePage()
    {
        Line_User__c tempUser;
        for(Line_User__c loopUser:[
            select id
            from Line_User__c
            where UDID__c =:lineId
            and Line_Account__c=:LineAccount.id
        ])
        {
            tempUser = loopUser;
        }

        Tracking_Log__c insertRecord = new Tracking_Log__c();
        insertRecord.Line_User__c = tempUser.id;
        insertRecord.Tracking_Tag__c = theTag.id;
        insert insertRecord;
        
        pageReference returnPage = new pageReference(theTag.URL__c);
        returnPage.setRedirect(true);
        return returnPage;
    }
}