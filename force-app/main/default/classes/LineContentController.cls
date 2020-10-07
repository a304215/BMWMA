/* =======================================================================================================================
 * Lightning Component 的Controller。
 * 
 * 
 * ======================================================================================================================= */
public without sharing class LineContentController {
    public LineContentController() {

    }

    @AuraEnabled  
    public static string pushMessage(){
        
        return '';
    }

    @AuraEnabled  
    public static Line_Content__c initial(string inputContentId){
        Line_Content__c returnRecord = new Line_Content__c(
            Status__c = '草稿'
        );
        
        for(Line_Content__c loopRecord: [
            select id, Name, Line_Account__c, ReportId__c,
                SendNow__c, ScheduleTime__c, Status__c
            from Line_Content__c
            where id=: inputContentId
        ])
        {
            returnRecord = loopRecord;
        }


        return returnRecord;
    }

    @AuraEnabled  
    public static list<Line_Account__c> lineAccountList(){
        list<Line_Account__c> returnList = new list<Line_Account__c>();
        
        for(Line_Account__c loopRecord: [
            select id, Name, ReportFolderName__c
            from Line_Account__c
        ])
        {
            returnList.add(loopRecord);
        }

        return returnList;
    }

    @AuraEnabled  
    public static list<Report> checkReportList(string inputStringName){
        Line_Account__c theAccount;
        for(Line_Account__c loopRecord: [
            select id, Name, ReportFolderName__c
            from Line_Account__c
            where id=: inputStringName
        ])
        {
            theAccount = loopRecord;
        }

        list<Report> returnList = [
            SELECT id, name FROM Report 
            WHERE ownerId IN (SELECT ID FROM Folder WHERE developerName =: theAccount.ReportFolderName__c)
            order by name
        ];
        
        return returnList;
    }
    
    @AuraEnabled  
    public static list<Line_Content_Detail__c> initialD(string inputContentId){
        list<Line_Content_Detail__c> returnList = new list<Line_Content_Detail__c>();

        for(Line_Content_Detail__c loopDetail: [
            select 
            id, Index__c, isDeleted__c,
            MessageType__c, 
            Text1__c, 
            PackageID__c, StickerID__c,
            PicTextType__c,
            PicTextTypeA__c, PicTextTypeB__c, PicTextTypeC__c, PicTextTypeD__c, PicTextTypeE__c, PicTextTypeF__c, 
            PicTextTitleA__c, PicTextTitleB__c, PicTextTitleC__c, PicTextTitleD__c, PicTextTitleE__c, PicTextTitleF__c, 
            PicTextMTextA__c, PicTextMTextB__c, PicTextMTextC__c, PicTextMTextD__c, PicTextMTextE__c, PicTextMTextF__c, 
            ImageURL__c, ImageContentURL__c, 
            VideoURL__c, VideoImageURL__c
            from Line_Content_Detail__c
            where Line_Content__c =: inputContentId
            and Line_Content__c != null
            order by Index__c
        ])
        {
            returnList.add(loopDetail);
        }
        if(returnList.size() ==0)
        {
            returnList.add(
                new Line_Content_Detail__c(
                    MessageType__c = '文字', 
                    Text1__c = '',
                    VideoURL__c = '',
                    isDeleted__c = false
                )
            );
        }
        return returnList;
    }

    @AuraEnabled
    public static Line_Content_Detail__c apexNewContent(){
        Line_Content_Detail__c returnRecord = new Line_Content_Detail__c();
        returnRecord.MessageType__c = '文字';
        returnRecord.Text1__c = '';
        returnRecord.isDeleted__c = false;

        return returnRecord;
    }

    public class tempObject
    {
        public Line_Content__c theContent {get; set;}
        public list<Line_Content_Detail__c> theList {get; set;}
        public tempObject()
        {

        }
    }

    @AuraEnabled
    public static string apexSaveContent(string  inputString){
        string returnString = '';
        LineContentController.tempObject tmpDataList = (LineContentController.tempObject)System.JSON.deserialize(inputString, LineContentController.tempObject.class);
        list<Line_Content_Detail__c> upsertList = new list<Line_Content_Detail__c>();

        if(tmpDataList.theContent.id != null)
        {
            update tmpDataList.theContent;
            for(integer i=0; i<tmpDataList.theList.size(); i++)
            {
                tmpDataList.theList[i].Line_Content__c = tmpDataList.theContent.id;
                tmpDataList.theList[i].Index__c = upsertList.size()+1;
                tmpDataList.theList[i].id = null;
                if(tmpDataList.theList[i].isDeleted__c ==false)
                {
                    upsertList.add(tmpDataList.theList[i]);
                }
            }
        }
        else {
            insert tmpDataList.theContent;

            for(integer i=0; i<tmpDataList.theList.size(); i++)
            {
                tmpDataList.theList[i].Line_Content__c = tmpDataList.theContent.id;
                tmpDataList.theList[i].Index__c = upsertList.size()+1;
                tmpDataList.theList[i].id = null;
                if(tmpDataList.theList[i].isDeleted__c ==false)
                {
                    upsertList.add(tmpDataList.theList[i]);
                }
            }
        }

        list<Line_Content_Detail__c> deleteList = [
            select id 
            from Line_Content_Detail__c
            where Line_Content__c=:tmpDataList.theContent.id
        ];

        if(deleteList.size() >0)
        {
            delete deleteList;
        }

        upsert upsertList;
        returnString = tmpDataList.theContent.Id;
        return returnString;
    }

    @AuraEnabled
    public static string apexCompleteContent(string  inputString){
        string returnString = '';
        LineContentController.tempObject tmpDataList = (LineContentController.tempObject)System.JSON.deserialize(inputString, LineContentController.tempObject.class);
        tmpDataList.theContent.Status__c = '已完成';
        list<Line_Content_Detail__c> upsertList = new list<Line_Content_Detail__c>();

        if(tmpDataList.theContent.id != null)
        {
            update tmpDataList.theContent;
            for(integer i=0; i<tmpDataList.theList.size(); i++)
            {
                tmpDataList.theList[i].Line_Content__c = tmpDataList.theContent.id;
                tmpDataList.theList[i].Index__c = upsertList.size()+1;
                tmpDataList.theList[i].id = null;
                if(tmpDataList.theList[i].isDeleted__c ==false)
                {
                    upsertList.add(tmpDataList.theList[i]);
                }
            }
        }
        else {
            insert tmpDataList.theContent;

            for(integer i=0; i<tmpDataList.theList.size(); i++)
            {
                tmpDataList.theList[i].Line_Content__c = tmpDataList.theContent.id;
                tmpDataList.theList[i].Index__c = upsertList.size()+1;
                tmpDataList.theList[i].id = null;
                if(tmpDataList.theList[i].isDeleted__c ==false)
                {
                    upsertList.add(tmpDataList.theList[i]);
                }
            }
        }

        list<Line_Content_Detail__c> deleteList = [
            select id 
            from Line_Content_Detail__c
            where Line_Content__c=:tmpDataList.theContent.id
        ];

        if(deleteList.size() >0)
        {
            delete deleteList;
        }

        upsert upsertList;

        //代表有值，所以抓取報告的名單產生資料。
        if(! string.isBlank(tmpDataList.theContent.ReportId__c))
        {
            System.enqueueJob(new LineContentQueueable(tmpDataList.theContent));
        }
        
        return returnString;
    }

    //回傳publish link
    @AuraEnabled
    public static string publicLinkStart(string inputDocumentId, string inputType)
    {
    	datetime currentTime = system.now();
        string tempString2 = string.valueOf(currentTime).replaceall(' ','').replaceall(':','').replaceall('-','');
    	
        //先使用current User 的。
        list<ContentDocumentLink> cdl = [
            select contentdocument.id, contentdocument.title, contentdocument.filetype 
            from contentdocumentlink 
            where linkedentityid =: UserInfo.getUserId() and contentdocument.id =: inputDocumentId
        ];
        list<ContentVersion> cv = [select id, FileType from contentversion where contentdocumentid = :cdl[0].contentdocument.id];
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'LineContent:'+tempString2;
        cd.ContentVersionId = cv[0].id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        cd.PreferencesAllowPDFDownload= true;
        insert cd;
        list<ContentDistribution> DownloadCD = [select id, DistributionPublicUrl, ContentDownloadUrl from ContentDistribution where id=: cd.id];
        //DOMAIN 的。
        string returnULR = DownloadCD[0].ContentDownloadUrl.substringBefore('/version/')+'/version/renditionDownload?rendition='+cv[0].FileType;
        returnULR += '&versionId='+string.valueOf(cv[0].id).left(15);
        returnULR += '&operationContext=DELIVERY';
        returnULR += '&page=1&d=/a/'+ DownloadCD[0].DistributionPublicUrl.substringAfter('/a/');
        returnULR += '&oid='+UserInfo.getOrganizationId().left(15);
        //因為Community的帳號會變成.my.salesforce.com ，這個會造成jpg 圖片在桌機版無法顯示。QQ
        returnULR = returnULR.replaceall('.my.salesforce.com', '--c.documentforce.com');
        
        //影片可以直接使用Download URL。
        if(inputType == '影片')
        {
            returnULR = DownloadCD[0].ContentDownloadUrl;
        }
        
        return returnULR;
    }
}