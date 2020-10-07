/* =======================================================================================================================
 * Lightning Component 的Controller。
 * 
 * 
 * ======================================================================================================================= */
public without sharing class LineKeyWordController {
    @AuraEnabled  
    public static string pushMessage(){
        
        return '';
    }

    @AuraEnabled  
    public static LineKeyWord__c initial(string inputKeywordId){
        LineKeyWord__c returnRecord = new LineKeyWord__c();
        returnRecord.Type__c = 'Message';
        
        for(LineKeyWord__c loopRecord: [
            select id, Name, Line_Account__c, Type__c, PostbackData__c, Active__c
            from LineKeyWord__c
            where id=: inputKeywordId
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
    public static list<msgObject> initialD2(string inputKeywordId){
        list<msgObject> returnList = new list<msgObject>();

        for(LineMessage__c loopDetail: [
            select 
            id, Index__c, isDeleted__c,
            MessageType__c, 
            Text__c,
            altText__c,
            PackageID__c, StickerID__c,
            PicTextType__c,
            PicTextTypeA__c, PicTextTypeB__c, PicTextTypeC__c, PicTextTypeD__c, PicTextTypeE__c, PicTextTypeF__c, 
            PicTextTitleA__c, PicTextTitleB__c, PicTextTitleC__c, PicTextTitleD__c, PicTextTitleE__c, PicTextTitleF__c, 
            PicTextMTextA__c, PicTextMTextB__c, PicTextMTextC__c, PicTextMTextD__c, PicTextMTextE__c, PicTextMTextF__c, 
            PicTextTrackingTagA__c, PicTextTrackingTagB__c, PicTextTrackingTagC__c, PicTextTrackingTagD__c,
            PicTextTrackingTagE__c, PicTextTrackingTagF__c,
            ImageURL__c, ImageContentURL__c, 
            VideoURL__c, VideoImageURL__c,
            ConfirmText__c,
            ConfirmActionTypeA__c, ConfirmActionLabelA__c, ConfirmActionTextA__c, ConfirmActionTrackingTagA__c,
            ConfirmActionTypeB__c, ConfirmActionLabelB__c, ConfirmActionTextB__c, ConfirmActionTrackingTagB__c,
            FlexSize__c,
            (
                select id, Name, isDeleted__c, 
                    Title__c, Content__c, ImageURL__c, Index__c, aspectRatio__c, 
                    ActionTypeA__c, ActionTypeB__c, ActionTypeC__c, ActionTypeD__c, ActionTypeE__c, ActionTypeF__c, 
                    ActionLabelA__c, ActionLabelB__c, ActionLabelC__c, ActionLabelD__c, ActionLabelE__c, ActionLabelF__c, 
                    ActionDataA__c, ActionDataB__c, ActionDataC__c, ActionDataD__c, ActionDataE__c,  ActionDataF__c, 
                    TrackingTagA__c, TrackingTagB__c, TrackingTagC__c, TrackingTagD__c, TrackingTagE__c, TrackingTagF__c,
                    LineMessage__c
                from LineMessageContent__r
                order by Index__c
            )
            from LineMessage__c
            where LineKeyWord__c =: inputKeywordId
            and LineKeyWord__c != null
            order by Index__c
        ])
        {
            msgObject tempRecord = new msgObject();
            tempRecord.theMessage = loopDetail;
            tempRecord.theContentList = loopDetail.LineMessageContent__r;
            returnList.add(tempRecord);
        }
        if(returnList.size() ==0)
        {
            msgObject tempRecord = new msgObject();
            tempRecord.theMessage = new LineMessage__c(
                MessageType__c = '文字', 
                Text__c = '',
                VideoURL__c = '',
                ConfirmText__c = '',
                isDeleted__c = false
            );
            tempRecord.theContentList = new list<LineMessageContent__c>();

            returnList.add(tempRecord);
        }
        return returnList;
    }

    @AuraEnabled
    public static msgObject apexNewMessage2(){
        msgObject returnRecord = new msgObject();
        returnRecord.theMessage = new LineMessage__c();
        returnRecord.theMessage.MessageType__c = '文字';
        returnRecord.theMessage.Text__c = '';
        returnRecord.theMessage.VideoURL__c = '';
        returnRecord.theMessage.ConfirmText__c = '';
        returnRecord.theMessage.isDeleted__c = false;
        returnRecord.theContentList = new list<LineMessageContent__c>();

        return returnRecord;
    }

    @AuraEnabled
    public static LineMessageContent__c apexNewMessageContent(){
        LineMessageContent__c returnRecord = new LineMessageContent__c();
        returnRecord.Title__c = '';
        returnRecord.Content__c = '';
        returnRecord.isDeleted__c = false;
        return returnRecord;
    }

    public class tempObject
    {
        public LineKeyWord__c theKeyWord {get; set;}
        public list<msgObject> theList {get; set;}
        public tempObject()
        {

        }
    }

    public class msgObject
    {
        @AuraEnabled
        public LineMessage__c theMessage {get; set;}
        @AuraEnabled
        public list<LineMessageContent__c> theContentList {get; set;}

        public msgObject()
        {

        }
    }

    @AuraEnabled
    public static string apexSaveMessage(string  inputString){
        string returnString = '';
        LineKeyWordController.tempObject tmpDataList = (LineKeyWordController.tempObject)System.JSON.deserialize(inputString, LineKeyWordController.tempObject.class);
        list<LineMessage__c> upsertList = new list<LineMessage__c>();
        list<LineMessageContent__c> upsertContentList = new list<LineMessageContent__c>();

        if(tmpDataList.theKeyWord.id != null)
        {
            update tmpDataList.theKeyWord;
        }
        else {
            insert tmpDataList.theKeyWord;
        }

        list<LineMessage__c> deleteList = [
            select id 
            from LineMessage__c
            where LineKeyWord__c=:tmpDataList.theKeyWord.id
        ];

        list<LineMessageContent__c> deleteContentList = [
            select id 
            from LineMessageContent__c
            where LineMessage__c in: deleteList
        ];

        if(deleteContentList.size() >0)
        {
            delete deleteContentList;
        }

        if(deleteList.size() >0)
        {
            delete deleteList;
        }

        set<string> tagSet = new set<string>(); 

        for(integer i=0; i<tmpDataList.theList.size(); i++)
        {
            if(tmpDataList.theList[i].theMessage.isDeleted__c ==false)
            {
                //upsert tmpDataList.theList[i].theMessage; 

                //PicTextTrackingTagA__c, PicTextTrackingTagB__c, PicTextTrackingTagC__c, PicTextTrackingTagD__c,
                //PicTextTrackingTagE__c, PicTextTrackingTagF__c,
                //ConfirmActionTrackingTagA__c, ConfirmActionTrackingTagB__c,
                if(tmpDataList.theList[i].theMessage.PicTextTypeA__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagA__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.PicTextTrackingTagA__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeB__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagB__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.PicTextTrackingTagB__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeC__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagC__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.PicTextTrackingTagC__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeD__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagD__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.PicTextTrackingTagD__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeE__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagE__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.PicTextTrackingTagE__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeF__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagF__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.PicTextTrackingTagF__c);
                }
                if(tmpDataList.theList[i].theMessage.ConfirmActionTypeA__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagA__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagA__c);
                }
                if(tmpDataList.theList[i].theMessage.ConfirmActionTypeB__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagB__c))
                {
                    tagSet.add(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagB__c);
                }

                for(integer j=0; j<tmpDataList.theList[i].theContentList.size(); j++)
                {
                    if(tmpDataList.theList[i].theContentList[j].isDeleted__c ==false)
                    {
                        //upsertContentList.add(tmpDataList.theList[i].theContentList[j]);

                        //TrackingTagA__c, TrackingTagB__c, TrackingTagC__c, TrackingTagD__c, TrackingTagE__c, TrackingTagF__c,
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeA__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagA__c))
                        {
                            tagSet.add(tmpDataList.theList[i].theContentList[j].TrackingTagA__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeB__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagB__c))
                        {
                            tagSet.add(tmpDataList.theList[i].theContentList[j].TrackingTagB__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeC__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagC__c))
                        {
                            tagSet.add(tmpDataList.theList[i].theContentList[j].TrackingTagC__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeD__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagD__c))
                        {
                            tagSet.add(tmpDataList.theList[i].theContentList[j].TrackingTagD__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeE__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagE__c))
                        {
                            tagSet.add(tmpDataList.theList[i].theContentList[j].TrackingTagE__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeF__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagF__c))
                        {
                            tagSet.add(tmpDataList.theList[i].theContentList[j].TrackingTagF__c);
                        }
                    }
                }
            }
        }

        //id vs url
        map<string, string> tagMap = new map<string, string>();
        for(Tracking_Tag__c loopTag:[
            select id, TrackingURL__c
            from Tracking_Tag__c
            where id in: tagSet
        ])
        {
            tagMap.put(loopTag.id, loopTag.TrackingURL__c);
        }

        for(integer i=0; i<tmpDataList.theList.size(); i++)
        {
            tmpDataList.theList[i].theMessage.LineKeyWord__c = tmpDataList.theKeyWord.id;
            tmpDataList.theList[i].theMessage.Index__c = i+1;
            tmpDataList.theList[i].theMessage.id = null;
            if(tmpDataList.theList[i].theMessage.isDeleted__c ==false)
            {
                if(tmpDataList.theList[i].theMessage.PicTextTypeA__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagA__c))
                {
                    tmpDataList.theList[i].theMessage.PicTextMTextA__c = tagMap.get(tmpDataList.theList[i].theMessage.PicTextTrackingTagA__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeB__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagB__c))
                {
                    tmpDataList.theList[i].theMessage.PicTextMTextB__c = tagMap.get(tmpDataList.theList[i].theMessage.PicTextTrackingTagB__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeC__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagC__c))
                {
                    tmpDataList.theList[i].theMessage.PicTextMTextC__c = tagMap.get(tmpDataList.theList[i].theMessage.PicTextTrackingTagC__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeD__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagD__c))
                {
                    tmpDataList.theList[i].theMessage.PicTextMTextD__c = tagMap.get(tmpDataList.theList[i].theMessage.PicTextTrackingTagD__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeE__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagE__c))
                {
                    tmpDataList.theList[i].theMessage.PicTextMTextE__c = tagMap.get(tmpDataList.theList[i].theMessage.PicTextTrackingTagE__c);
                }
                if(tmpDataList.theList[i].theMessage.PicTextTypeF__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.PicTextTrackingTagF__c))
                {
                    tmpDataList.theList[i].theMessage.PicTextMTextF__c = tagMap.get(tmpDataList.theList[i].theMessage.PicTextTrackingTagF__c);
                }
                if(tmpDataList.theList[i].theMessage.ConfirmActionTypeA__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagA__c))
                {
                    tmpDataList.theList[i].theMessage.ConfirmActionTextA__c = tagMap.get(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagA__c);
                }
                if(tmpDataList.theList[i].theMessage.ConfirmActionTypeB__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagB__c))
                {
                    tmpDataList.theList[i].theMessage.ConfirmActionTextB__c = tagMap.get(tmpDataList.theList[i].theMessage.ConfirmActionTrackingTagB__c);
                }
                upsert tmpDataList.theList[i].theMessage; 

                for(integer j=0; j<tmpDataList.theList[i].theContentList.size(); j++)
                {
                    tmpDataList.theList[i].theContentList[j].LineMessage__c = tmpDataList.theList[i].theMessage.id;
                    tmpDataList.theList[i].theContentList[j].Index__c = j+1;
                    tmpDataList.theList[i].theContentList[j].id = null;
                    if(tmpDataList.theList[i].theContentList[j].isDeleted__c ==false)
                    {
                        //TrackingTagA__c, TrackingTagB__c, TrackingTagC__c, TrackingTagD__c, TrackingTagE__c, TrackingTagF__c,
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeA__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagA__c))
                        {
                            tmpDataList.theList[i].theContentList[j].ActionDataA__c = tagMap.get(tmpDataList.theList[i].theContentList[j].TrackingTagA__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeB__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagB__c))
                        {
                            tmpDataList.theList[i].theContentList[j].ActionDataB__c = tagMap.get(tmpDataList.theList[i].theContentList[j].TrackingTagB__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeC__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagC__c))
                        {
                            tmpDataList.theList[i].theContentList[j].ActionDataC__c = tagMap.get(tmpDataList.theList[i].theContentList[j].TrackingTagC__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeD__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagD__c))
                        {
                            tmpDataList.theList[i].theContentList[j].ActionDataD__c = tagMap.get(tmpDataList.theList[i].theContentList[j].TrackingTagD__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeE__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagE__c))
                        {
                            tmpDataList.theList[i].theContentList[j].ActionDataE__c = tagMap.get(tmpDataList.theList[i].theContentList[j].TrackingTagE__c);
                        }
                        if(tmpDataList.theList[i].theContentList[j].ActionTypeF__c == 'TrackingTag' && !string.isBlank(tmpDataList.theList[i].theContentList[j].TrackingTagF__c))
                        {
                            tmpDataList.theList[i].theContentList[j].ActionDataF__c = tagMap.get(tmpDataList.theList[i].theContentList[j].TrackingTagF__c);
                        }

                        upsertContentList.add(tmpDataList.theList[i].theContentList[j]);
                    }
                }
            }
        }

        if(upsertContentList.size() >0)
        {
            upsert upsertContentList;
        }
        
        returnString = tmpDataList.theKeyWord.Id;
        return returnString;
    }

    //回傳publish link
    @AuraEnabled
    public static string publicLinkStartGCP(string inputDocumentId, string inputType, string inputGCP, string inputBucket, string inputFolder)
    {
        //先使用current User 的。
        list<ContentDocumentLink> cdl = [
            select contentdocument.id, contentdocument.title, contentdocument.filetype 
            from contentdocumentlink 
            where linkedentityid =: UserInfo.getUserId() and contentdocument.id =: inputDocumentId
        ];

        string returnULR = GCP_Function.uploadFile(cdl[0].contentdocument.id, inputGCP, inputBucket, inputFolder);
        return returnULR;
    }
}