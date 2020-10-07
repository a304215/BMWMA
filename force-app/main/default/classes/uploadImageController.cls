public class uploadImageController 
{
    //回傳publish link
    @AuraEnabled
    public static string publicLinkStart(string inputDocumentId, string inputId, string inputObject, string inputField)
    {
        datetime currentTime = system.now();
        string tempString2 = string.valueOf(currentTime).replaceall(' ','').replaceall(':','').replaceall('-','');
        
        //先使用current User 的。
        list<ContentDocumentLink> cdl = [
            select contentdocument.id, contentdocument.title, contentdocument.filetype 
            from contentdocumentlink 
            where linkedentityid =: UserInfo.getUserId() and contentdocument.id =: inputDocumentId
        ];

        GoogleApiTest dd = new GoogleApiTest(cdl[0].contentdocument.id);

        /*

        list<ContentVersion> cv = [select id, FileType from contentversion where contentdocumentid = :cdl[0].contentdocument.id];
        ContentDistribution cd = new ContentDistribution();
        
        cd.Name = 'Image'+tempString2;
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
        //好像也可以拿掉returnULR += '&dpt=null&viewId=';
        
        //影片可以直接使用Download URL。
        /*
        if(inputType == '影片')
        {
            returnULR = DownloadCD[0].ContentDownloadUrl;
        }
		*/
		
		SObject sObj = Schema.getGlobalDescribe().get(inputObject).newSObject();
		sObj.put('Id', inputId);
        //sObj.put(inputField, returnULR);
        sObj.put(inputField, dd.picURL);
		
		update sObj;
        
        return dd.picURL;
    }
    
}