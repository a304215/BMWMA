public without sharing class Callout_Line_API 
{
    public Callout_Line_API() 
    {

    }

    /*
    public static string sendMulticast(string inputToken, string inputUDID, string inputMSG)
    {
        HttpRequest httpReq = new HttpRequest();
     	httpReq.setEndpoint('https://api.line.me/v2/bot/message/multicast');
     	httpReq.setMethod('POST');
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setHeader('Authorization', 'Bearer ' + inputToken);
        system.debug(inputMSG);
        
        outputMessageRequest tempData = new outputMessageRequest();
        tempData.to.add(inputUDID);
        publicMessage tempMessage = new publicMessage();
        tempMessage.type = 'text';
        tempMessage.text = inputMSG;
        tempData.messages.add(tempMessage);
        httpReq.setBody(tempData.toJSON());
        system.debug(tempData.toJSON());
        Http http = new Http();
		HttpResponse httpRes = http.send(httpReq);
        string pushResult = httpRes.getBody();
        //檢查是否有responseBody
        //if(httpRes.getBody() == null) return;
        system.debug(pushResult);
        return pushResult;
    }
    */

    @future(callout=true)
    public static void sendMulticastSFFuture(string inputString)
    {
        string result = '';
        for(Line_Push__c loopPush:[
            select id, Line_User__r.UDID__c,
                Line_Account__r.ChannelAccessToken__c, 
                Line_Content__c
            from Line_Push__c
            where id=: inputString
            and IsPushed__c = false
        ])
        {
            list<string> dudu = new list<string>();
            dudu.add(loopPush.Line_User__r.UDID__c);
            result = sendMulticastSF(
                loopPush.Line_Account__r.ChannelAccessToken__c,
                dudu,
                loopPush.Line_Content__c
            );
        }

        if(result=='{}')
        {
            update new Line_Push__c(id=inputString, IsPushed__c=true);
        }
        else 
        {
            update new Line_Push__c(id=inputString, PushResult__c=result);
        }
    }

    public static string sendMulticastSF(string inputToken, list<string> inputUDID, string inputContentID)
    {
        string returnString = '';
        HttpRequest httpReq = new HttpRequest();
     	httpReq.setEndpoint('https://api.line.me/v2/bot/message/multicast');
     	httpReq.setMethod('POST');
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setHeader('Authorization', 'Bearer ' + inputToken);

        outputMessageRequest tempData = new outputMessageRequest();
        tempData.to.addAll(inputUDID);
        list<LineMessages> msgList = new list<LineMessages>();
        
        //message
        for(LineMessage__c loopMSG: [
            select 
            id, Index__c, isDeleted__c, LineKeyWord__c, LineKeyWord__r.Name, Line_Content__c, Line_Content__r.Name,
            MessageType__c, 
            Text__c,
            altText__c,
            PackageID__c, StickerID__c,
            PicTextType__c,
            PicTextTypeA__c, PicTextTypeB__c, PicTextTypeC__c, PicTextTypeD__c, PicTextTypeE__c, PicTextTypeF__c, 
            PicTextTitleA__c, PicTextTitleB__c, PicTextTitleC__c, PicTextTitleD__c, PicTextTitleE__c, PicTextTitleF__c, 
            PicTextMTextA__c, PicTextMTextB__c, PicTextMTextC__c, PicTextMTextD__c, PicTextMTextE__c, PicTextMTextF__c, 
            ImageURL__c, ImageContentURL__c, 
            VideoURL__c, VideoImageURL__c,
            ConfirmText__c,
            ConfirmActionTypeA__c, ConfirmActionLabelA__c, ConfirmActionTextA__c, 
            ConfirmActionTypeB__c, ConfirmActionLabelB__c, ConfirmActionTextB__c,
            FlexSize__c,
            (
                select id, Name, isDeleted__c, 
                    Title__c, Content__c, ImageURL__c, Index__c, aspectRatio__c, 
                    ActionTypeA__c, ActionTypeB__c, ActionTypeC__c, ActionTypeD__c, ActionTypeE__c, ActionTypeF__c, 
                    ActionLabelA__c, ActionLabelB__c, ActionLabelC__c, ActionLabelD__c, ActionLabelE__c, ActionLabelF__c, 
                    ActionDataA__c, ActionDataB__c, ActionDataC__c, ActionDataD__c, ActionDataE__c,  ActionDataF__c, 
                    LineMessage__c
                from LineMessageContent__r
                order by Index__c
            )
            from LineMessage__c
            where Line_Content__c =:inputContentID
            and Line_Content__c != null
            order by Line_Content__c, Index__c
        ])
        {
            switch on loopMSG.MessageType__c
            {
                when '文字'
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'text';
                    tempMSG.text = loopMSG.Text__c;
                    msgList.add(tempMSG);
                }
                when '貼圖'
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'sticker';
                    tempMSG.packageId = loopMSG.PackageID__c;
                    tempMSG.stickerId = loopMSG.StickerID__c;
                    msgList.add(tempMSG);
                }
                when '圖片'
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'image';
                    tempMSG.originalContentUrl = loopMSG.ImageURL__c;
                    tempMSG.previewImageUrl = loopMSG.ImageURL__c;
                    msgList.add(tempMSG);
                }
                when '圖文'
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'imagemap';
                    tempMSG.baseUrl = loopMSG.ImageContentURL__c;
                    tempMSG.altText = '圖文訊息';
                    msgList.add(tempMSG);
                    
                    switch on loopMSG.PicTextType__c
                    {
                        when 'type1'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 1040;
                            myAction1.area.height = 1040;
                            tempMSG.actions.add(myAction1);
                        }
                        when 'type2'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 520;
                            myAction1.area.height = 1040;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 520;
                            myAction2.area.y = 0;
                            myAction2.area.width = 520;
                            myAction2.area.height = 1040;
                            tempMSG.actions.add(myAction2);
                        }
                        when 'type3'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 1040;
                            myAction1.area.height = 520;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 0;
                            myAction2.area.y = 520;
                            myAction2.area.width = 1040;
                            myAction2.area.height = 520;
                            tempMSG.actions.add(myAction2);
                        }
                        when 'type4'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 1040;
                            myAction1.area.height = 346;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 0;
                            myAction2.area.y = 346;
                            myAction2.area.width = 1040;
                            myAction2.area.height = 346;
                            tempMSG.actions.add(myAction2);

                            LineMessages.imageAction myAction3 = new LineMessages.imageAction();
                            myAction3.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeC__c =='網址' || loopMSG.PicTextTypeC__c =='TrackingTag')
                            {
                                myAction3.type = 'uri';
                                myAction3.linkUri = loopMSG.PicTextMTextC__c;
                                myAction3.label = loopMSG.PicTextTitleC__c;
                            }
                            else {
                                myAction3.type = 'message';
                                myAction3.text = loopMSG.PicTextMTextC__c;
                            }
                            myAction3.area.x = 0;
                            myAction3.area.y = 692;
                            myAction3.area.width = 1040;
                            myAction3.area.height = 348;
                            tempMSG.actions.add(myAction3);
                        }
                        when 'type5'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 520;
                            myAction1.area.height = 520;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 520;
                            myAction2.area.y = 0;
                            myAction2.area.width = 520;
                            myAction2.area.height = 520;
                            tempMSG.actions.add(myAction2);

                            LineMessages.imageAction myAction3 = new LineMessages.imageAction();
                            myAction3.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeC__c =='網址' || loopMSG.PicTextTypeC__c =='TrackingTag')
                            {
                                myAction3.type = 'uri';
                                myAction3.linkUri = loopMSG.PicTextMTextC__c;
                                myAction3.label = loopMSG.PicTextTitleC__c;
                            }
                            else {
                                myAction3.type = 'message';
                                myAction3.text = loopMSG.PicTextMTextC__c;
                            }
                            myAction3.area.x = 0;
                            myAction3.area.y = 520;
                            myAction3.area.width = 520;
                            myAction3.area.height = 520;
                            tempMSG.actions.add(myAction3);

                            LineMessages.imageAction myAction4 = new LineMessages.imageAction();
                            myAction4.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeD__c =='網址' || loopMSG.PicTextTypeD__c =='TrackingTag')
                            {
                                myAction4.type = 'uri';
                                myAction4.linkUri = loopMSG.PicTextMTextD__c;
                                myAction4.label = loopMSG.PicTextTitleD__c;
                            }
                            else {
                                myAction4.type = 'message';
                                myAction4.text = loopMSG.PicTextMTextD__c;
                            }
                            myAction4.area.x = 520;
                            myAction4.area.y = 520;
                            myAction4.area.width = 520;
                            myAction4.area.height = 520;
                            tempMSG.actions.add(myAction4);
                        }
                        when 'type6'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 1040;
                            myAction1.area.height = 520;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 0;
                            myAction2.area.y = 520;
                            myAction2.area.width = 520;
                            myAction2.area.height = 520;
                            tempMSG.actions.add(myAction2);

                            LineMessages.imageAction myAction3 = new LineMessages.imageAction();
                            myAction3.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeC__c =='網址' || loopMSG.PicTextTypeC__c =='TrackingTag')
                            {
                                myAction3.type = 'uri';
                                myAction3.linkUri = loopMSG.PicTextMTextC__c;
                                myAction3.label = loopMSG.PicTextTitleC__c;
                            }
                            else {
                                myAction3.type = 'message';
                                myAction3.text = loopMSG.PicTextMTextC__c;
                            }
                            myAction3.area.x = 520;
                            myAction3.area.y = 520;
                            myAction3.area.width = 520;
                            myAction3.area.height = 520;
                            tempMSG.actions.add(myAction3);
                        }
                        when 'type7'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 1040;
                            myAction1.area.height = 520;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 0;
                            myAction2.area.y = 520;
                            myAction2.area.width = 1040;
                            myAction2.area.height = 260;
                            tempMSG.actions.add(myAction2);

                            LineMessages.imageAction myAction3 = new LineMessages.imageAction();
                            myAction3.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeC__c =='網址' || loopMSG.PicTextTypeC__c =='TrackingTag')
                            {
                                myAction3.type = 'uri';
                                myAction3.linkUri = loopMSG.PicTextMTextC__c;
                                myAction3.label = loopMSG.PicTextTitleC__c;
                            }
                            else {
                                myAction3.type = 'message';
                                myAction3.text = loopMSG.PicTextMTextC__c;
                            }
                            myAction3.area.x = 0;
                            myAction3.area.y = 780;
                            myAction3.area.width = 1040;
                            myAction3.area.height = 260;
                            tempMSG.actions.add(myAction3);
                        }
                        when 'type8'
                        {
                            LineMessages.imageAction myAction1 = new LineMessages.imageAction();
                            myAction1.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeA__c =='網址' || loopMSG.PicTextTypeA__c =='TrackingTag')
                            {
                                myAction1.type = 'uri';
                                myAction1.linkUri = loopMSG.PicTextMTextA__c;
                                myAction1.label = loopMSG.PicTextTitleA__c;
                            }
                            else {
                                myAction1.type = 'message';
                                myAction1.text = loopMSG.PicTextMTextA__c;
                            }
                            myAction1.area.x = 0;
                            myAction1.area.y = 0;
                            myAction1.area.width = 346;
                            myAction1.area.height = 520;
                            tempMSG.actions.add(myAction1);

                            LineMessages.imageAction myAction2 = new LineMessages.imageAction();
                            myAction2.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeB__c =='網址' || loopMSG.PicTextTypeB__c =='TrackingTag')
                            {
                                myAction2.type = 'uri';
                                myAction2.linkUri = loopMSG.PicTextMTextB__c;
                                myAction2.label = loopMSG.PicTextTitleB__c;
                            }
                            else {
                                myAction2.type = 'message';
                                myAction2.text = loopMSG.PicTextMTextB__c;
                            }
                            myAction2.area.x = 346;
                            myAction2.area.y = 0;
                            myAction2.area.width = 346;
                            myAction2.area.height = 520;
                            tempMSG.actions.add(myAction2);

                            LineMessages.imageAction myAction3 = new LineMessages.imageAction();
                            myAction3.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeC__c =='網址' || loopMSG.PicTextTypeC__c =='TrackingTag')
                            {
                                myAction3.type = 'uri';
                                myAction3.linkUri = loopMSG.PicTextMTextC__c;
                                myAction3.label = loopMSG.PicTextTitleC__c;
                            }
                            else {
                                myAction3.type = 'message';
                                myAction3.text = loopMSG.PicTextMTextC__c;
                            }
                            myAction3.area.x = 692;
                            myAction3.area.y = 0;
                            myAction3.area.width = 348;
                            myAction3.area.height = 520;
                            tempMSG.actions.add(myAction3);

                            LineMessages.imageAction myAction4 = new LineMessages.imageAction();
                            myAction4.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeD__c =='網址' || loopMSG.PicTextTypeD__c =='TrackingTag')
                            {
                                myAction4.type = 'uri';
                                myAction4.linkUri = loopMSG.PicTextMTextD__c;
                                myAction4.label = loopMSG.PicTextTitleD__c;
                            }
                            else {
                                myAction4.type = 'message';
                                myAction4.text = loopMSG.PicTextMTextD__c;
                            }
                            myAction4.area.x = 0;
                            myAction4.area.y = 520;
                            myAction4.area.width = 346;
                            myAction4.area.height = 520;
                            tempMSG.actions.add(myAction4);

                            LineMessages.imageAction myAction5 = new LineMessages.imageAction();
                            myAction5.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeE__c =='網址' || loopMSG.PicTextTypeE__c =='TrackingTag')
                            {
                                myAction5.type = 'uri';
                                myAction5.linkUri = loopMSG.PicTextMTextE__c;
                                myAction5.label = loopMSG.PicTextTitleE__c;
                            }
                            else {
                                myAction5.type = 'message';
                                myAction5.text = loopMSG.PicTextMTextE__c;
                            }
                            myAction5.area.x = 346;
                            myAction5.area.y = 520;
                            myAction5.area.width = 346;
                            myAction5.area.height = 520;
                            tempMSG.actions.add(myAction5);

                            LineMessages.imageAction myAction6 = new LineMessages.imageAction();
                            myAction6.area = new LineMessages.areaData();
                            if(loopMSG.PicTextTypeF__c =='網址' || loopMSG.PicTextTypeF__c =='TrackingTag')
                            {
                                myAction6.type = 'uri';
                                myAction6.linkUri = loopMSG.PicTextMTextF__c;
                                myAction6.label = loopMSG.PicTextTitleF__c;
                            }
                            else {
                                myAction6.type = 'message';
                                myAction6.text = loopMSG.PicTextMTextF__c;
                            }
                            myAction6.area.x = 692;
                            myAction6.area.y = 520;
                            myAction6.area.width = 348;
                            myAction6.area.height = 520;
                            tempMSG.actions.add(myAction6);
                        }
                    }
                }
                when '影片'
                {
                    /*
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'video';
                    tempMSG.originalContentUrl = loopMSG.VideoURL__c;
                    tempMSG.previewImageUrl = loopMSG.VideoImageURL__c;
                    msgList.add(tempMSG);
                    */
                    
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'imagemap';
                    tempMSG.baseUrl = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000Lv5jAAC.PNG?generation=1601289200901152&alt=media';
                    tempMSG.altText = '影片';
                    tempMSG.baseSize = new LineMessages.areaData();
                    tempMSG.baseSize.width=1040;
                    tempMSG.baseSize.height=780;
                    tempMSG.video = new LineMessages.videoData(); 
                    tempMSG.video.area = new LineMessages.areaData();
                    tempMSG.video.originalContentUrl = loopMSG.VideoURL__c;
                    tempMSG.video.previewImageUrl = loopMSG.VideoImageURL__c;
                    tempMSG.video.area.x = 0;
                    tempMSG.video.area.y = 0;
                    tempMSG.video.area.width = 1040;
                    tempMSG.video.area.height = 780;

                    /*
                    tempMSG.video.externalLink = new LineMessages.imageAction();
                    tempMSG.video.externalLink.linkUri = 'https://google.com.tw/';
                    tempMSG.video.externalLink.label = 'go to google';
                    */
                    msgList.add(tempMSG);

                }
                when '輪播'
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'flex';
                    tempMSG.altText = loopMSG.Line_Content__r.Name;
                    tempMSG.contents = new LineMessages.singleContentData();
                    tempMSG.contents.type = 'carousel';
                    tempMSG.contents.contents = new list<LineMessages.contentsData>();
                    for(LineMessageContent__c loopContent: loopMSG.LineMessageContent__r)
                    {
                        LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                        crlcontent.type = 'bubble';
                        crlcontent.size = (loopMSG.FlexSize__c==null?'kilo':loopMSG.FlexSize__c);
                        if(loopContent.ImageURL__c != null)
                        {
                            crlcontent.hero = new LineMessages.containerData();
                            crlcontent.hero.type = 'image';
                            crlcontent.hero.url = loopContent.ImageURL__c;
                            crlcontent.hero.size = 'full';
                            crlcontent.hero.aspectRatio = '4:3';
                            crlcontent.hero.aspectMode = 'cover';
                        }
                        crlcontent.body = new LineMessages.containerData();
                        crlcontent.body.type='box';
                        crlcontent.body.layout='vertical';
                        crlcontent.body.contents= new list<LineMessages.contentsData>();
                        tempMSG.contents.contents.add(crlcontent);
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'text';
                            content.text = loopContent.Title__c;
                            content.weight = 'bold';
                            content.size = 'md';
                            crlcontent.body.contents.add(content);
                        }
                        if(loopContent.Content__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'box';
                            content.layout = 'vertical';
                            content.margin = 'lg';
                            content.spacing = 'sm';
                            content.contents = new list<LineMessages.contentsData>();
                            crlcontent.body.contents.add(content);
                            for(string loopTempStr: loopContent.Content__c.split('`n'))
                            {
                                LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                contentbase.type = 'text';
                                contentbase.text = loopTempStr;
                                contentbase.color = '#666666';
                                contentbase.size = 'sm';
                                contentbase.wrap = true;
                                contentbase.flex = 1;
                                content.contents.add(contentbase);
                            }
                        }         
                        crlcontent.footer=new LineMessages.containerData();
                        crlcontent.footer.type = 'box';
                        crlcontent.footer.layout = 'vertical';
                        crlcontent.footer.spacing = 'sm';
                        crlcontent.footer.contents= new list<LineMessages.contentsData>();
                        if(loopContent.ActionTypeA__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            
                            content.action.label = loopContent.ActionLabelA__c;
                            switch on loopContent.ActionTypeA__c
                            {
                                when '文字'
                                {
                                    content.action.type = 'message';
                                    content.action.text = loopContent.ActionDataA__c;
                                }
                                when '網址'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataA__c;
                                }
                                when 'postback'
                                {
                                    content.action.type = 'postback';
                                    content.action.text = loopContent.ActionLabelA__c;
                                    content.action.data = loopContent.ActionDataA__c;
                                }
                                when 'TrackingTag'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataA__c;
                                }
                            }
                            crlcontent.footer.contents.add(content);
                        }
                        if(loopContent.ActionTypeB__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            
                            content.action.label = loopContent.ActionLabelb__c;
                            switch on loopContent.ActionTypeB__c
                            {
                                when '文字'
                                {
                                    content.action.type = 'message';
                                    content.action.text = loopContent.ActionDataB__c;
                                }
                                when '網址'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataB__c;
                                }
                                when 'postback'
                                {
                                    content.action.type = 'postback';
                                    content.action.text = loopContent.ActionLabelB__c;
                                    content.action.data = loopContent.ActionDataB__c;
                                }
                                when 'TrackingTag'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataB__c;
                                }
                            }
                            crlcontent.footer.contents.add(content);
                        } 
                        if(loopContent.ActionTypeC__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            
                            content.action.label = loopContent.ActionLabelC__c;
                            switch on loopContent.ActionTypeC__c
                            {
                                when '文字'
                                {
                                    content.action.type = 'message';
                                    content.action.text = loopContent.ActionDataC__c;
                                }
                                when '網址'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataC__c;
                                }
                                when 'postback'
                                {
                                    content.action.type = 'postback';
                                    content.action.text = loopContent.ActionLabelC__c;
                                    content.action.data = loopContent.ActionDataC__c;
                                }
                                when 'TrackingTag'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataC__c;
                                }
                            }
                            crlcontent.footer.contents.add(content);
                        } 
                        if(loopContent.ActionTypeD__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            
                            content.action.label = loopContent.ActionLabelD__c;
                            switch on loopContent.ActionTypeD__c
                            {
                                when '文字'
                                {
                                    content.action.type = 'message';
                                    content.action.text = loopContent.ActionDataD__c;
                                }
                                when '網址'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataD__c;
                                }
                                when 'postback'
                                {
                                    content.action.type = 'postback';
                                    content.action.text = loopContent.ActionLabelD__c;
                                    content.action.data = loopContent.ActionDataD__c;
                                }
                                when 'TrackingTag'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataD__c;
                                }
                            }
                            crlcontent.footer.contents.add(content);
                        } 
                        if(loopContent.ActionTypeE__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            
                            content.action.label = loopContent.ActionLabelE__c;
                            switch on loopContent.ActionTypeE__c
                            {
                                when '文字'
                                {
                                    content.action.type = 'message';
                                    content.action.text = loopContent.ActionDataE__c;
                                }
                                when '網址'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataE__c;
                                }
                                when 'postback'
                                {
                                    content.action.type = 'postback';
                                    content.action.text = loopContent.ActionLabelE__c;
                                    content.action.data = loopContent.ActionDataE__c;
                                }
                                when 'TrackingTag'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataE__c;
                                }
                            }
                            crlcontent.footer.contents.add(content);
                        } 
                        if(loopContent.ActionTypeF__c != null)
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            
                            content.action.label = loopContent.ActionLabelF__c;
                            switch on loopContent.ActionTypeF__c
                            {
                                when '文字'
                                {
                                    content.action.type = 'message';
                                    content.action.text = loopContent.ActionDataF__c;
                                }
                                when '網址'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataF__c;
                                }
                                when 'postback'
                                {
                                    content.action.type = 'postback';
                                    content.action.text = loopContent.ActionLabelF__c;
                                    content.action.data = loopContent.ActionDataF__c;
                                }
                                when 'TrackingTag'
                                {
                                    content.action.type = 'uri';
                                    content.action.uri = loopContent.ActionDataF__c;
                                }
                            }
                            crlcontent.footer.contents.add(content);
                        }                   
                    }
                    msgList.add(tempMSG);
                }
                when '確認'
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'template';
                    tempMSG.altText = loopMSG.Line_Content__r.Name;
                    tempMSG.template = new LineMessages.templateData();
                    tempMSG.template.type = 'confirm';
                    tempMSG.template.text = loopMSG.ConfirmText__c;
                    tempMSG.template.actions = new list<LineMessages.actionData>();
                    {
                        LineMessages.actionData action1 = new LineMessages.actionData();
                        action1.label = loopMSG.ConfirmActionLabelA__c;
                        switch on loopMSG.ConfirmActionTypeA__c
                        {
                            when '文字'
                            {
                                action1.type = 'message';
                                action1.text = loopMSG.ConfirmActionTextA__c;
                            }
                            when '網址'
                            {
                                action1.type = 'uri';
                                action1.uri = loopMSG.ConfirmActionTextA__c;
                            }
                            when 'postback'
                            {
                                action1.type = 'postback';
                                action1.text = loopMSG.ConfirmActionLabelA__c;
                                action1.data = loopMSG.ConfirmActionTextA__c;
                            }
                            when 'camera'
                            {
                                action1.type = 'camera';
                            }
                            when 'cameraRoll'
                            {
                                action1.type = 'cameraRoll';
                            }
                            when 'TrackingTag'
                            {
                                action1.type = 'uri';
                                action1.uri = loopMSG.ConfirmActionTextA__c;
                            }
                        }
                        tempMSG.template.actions.add(action1);
                    }
                    {
                        LineMessages.actionData action1 = new LineMessages.actionData();
                        action1.label = loopMSG.ConfirmActionLabelB__c;
                        switch on loopMSG.ConfirmActionTypeB__c
                        {
                            when '文字'
                            {
                                action1.type = 'message';
                                action1.text = loopMSG.ConfirmActionTextB__c;
                            }
                            when '網址'
                            {
                                action1.type = 'uri';
                                action1.uri = loopMSG.ConfirmActionTextB__c;
                            }
                            when 'postback'
                            {
                                action1.type = 'postback';
                                action1.text = loopMSG.ConfirmActionLabelB__c;
                                action1.data = loopMSG.ConfirmActionTextB__c;
                            }
                            when 'camera'
                            {
                                action1.type = 'camera';
                            }
                            when 'cameraRoll'
                            {
                                action1.type = 'cameraRoll';
                            }
                            when 'TrackingTag'
                            {
                                action1.type = 'uri';
                                action1.uri = loopMSG.ConfirmActionTextB__c;
                            }
                        }
                        tempMSG.template.actions.add(action1);
                    }
                    msgList.add(tempMSG);
                }
            }                
        }
        tempData.messages = msgList;

        httpReq.setBody(tempData.toJSON());
        system.debug(tempData.toJSON());
        Http http = new Http();
		HttpResponse httpRes = http.send(httpReq);
        returnString = httpRes.getBody();
        //檢查是否有responseBody
        //if(httpRes.getBody() == null) return;
        system.debug(returnString);

        return returnString;
    }

    //mAPI-3
    public class outputMessageRequest
    {
        public list<string> to {get; set;}
        public list<LineMessages> messages {get; set;}
        public outputMessageRequest(){
            to = new list<string>();
            messages = new list<LineMessages>();
        }

        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(false);
            g.writeStartObject();
            g.writeFieldName('to');
			g.writeStartArray();
            for(string loopStr: to)
            {
                g.writeString(loopStr);
            }
			g.writeEndArray();
            g.writeFieldName('messages');
            g.writeStartArray();
            for(LineMessages loopMSG: messages)
            {
                loopMSG.toJSON(g);
            }
            g.writeEndArray();
            g.writeEndObject();
            return g.getAsString();
        }
    }
}