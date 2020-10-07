public with sharing class testCallout {
    public static string sendMulticast(string inputToken, string inputUDID, string inputMSG)
    {
        inputToken ='XEKEb3EEdObYe4Sb1JJSdbGag7Os7WbLClK01rxrR3fIMi68B72jAtHEK6Tc1zePGn2Jh7X9qCm+UT0Xs/zpaxiEMR49yPUof4bY5GtX1x4mMF5BXG6fqXagvUCllmohOcgVJwl42JqzU8e3bAZqRQdB04t89/1O/w1cDnyilFU=';
        inputUDID ='Uda1c7c6b6d8a2e5dc809bf1d51947892';
        HttpRequest httpReq = new HttpRequest();
     	httpReq.setEndpoint('https://api.line.me/v2/bot/message/multicast');
     	httpReq.setMethod('POST');
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setHeader('Authorization', 'Bearer ' + inputToken);
        system.debug(inputMSG);
        
        outputMessageRequest tempData = new outputMessageRequest();
        tempData.to.add(inputUDID);
        LineMessages tempMSG = new LineMessages();
        tempMSG.type = 'text';
        tempMSG.text = '123';
        tempMSG.altText = '123';
        tempMSG.quickReply = new LineMessages.quickReplyData();
        tempMSG.quickReply.items = new list<LineMessages.itemsData>();
        {
            LineMessages.itemsData item1 = new LineMessages.itemsData();
            item1.type = 'action';
            item1.action = new LineMessages.actionData();
            item1.action.type = 'camera';
            item1.action.label = 'camera';
            tempMSG.quickReply.items.add(item1);
        }
        {
            LineMessages.itemsData item1 = new LineMessages.itemsData();
            item1.type = 'action';
            item1.action = new LineMessages.actionData();
            item1.action.type = 'cameraRoll';
            item1.action.label = 'cameraRoll';
            tempMSG.quickReply.items.add(item1);
        }

        LineMessages tempMS2 = new LineMessages();
        tempMS2.type = 'image';
        tempMS2.originalContentUrl = 'https://storage.googleapis.com/standardfoods_image/Default/0923.jpg';
        tempMS2.previewImageUrl = 'https://storage.googleapis.com/standardfoods_image/Default/0923.jpg';

        tempData.messages.add(tempMSG);
        tempData.messages.add(tempMS2);
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

    public static string sendMulticast2(string inputToken, string inputUDID, string inputMSG)
    {
        inputToken ='XEKEb3EEdObYe4Sb1JJSdbGag7Os7WbLClK01rxrR3fIMi68B72jAtHEK6Tc1zePGn2Jh7X9qCm+UT0Xs/zpaxiEMR49yPUof4bY5GtX1x4mMF5BXG6fqXagvUCllmohOcgVJwl42JqzU8e3bAZqRQdB04t89/1O/w1cDnyilFU=';
        inputUDID ='Uda1c7c6b6d8a2e5dc809bf1d51947892';
        HttpRequest httpReq = new HttpRequest();
     	httpReq.setEndpoint('https://api.line.me/v2/bot/message/multicast');
     	httpReq.setMethod('POST');
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setHeader('Authorization', 'Bearer ' + inputToken);
        system.debug(inputMSG);
        
        outputMessageRequest tempData = new outputMessageRequest();
        tempData.to.add(inputUDID);
        tempData.to.add('Udf2286ea532388adcb59d0bcb24ceef1');
        LineMessages tempMSG = new LineMessages();
        tempMSG.type = 'text';
        tempMSG.text = '123';
        tempMSG.altText = '123';
        tempMSG.quickReply = new LineMessages.quickReplyData();
        tempMSG.quickReply.items = new list<LineMessages.itemsData>();
        {
            LineMessages.itemsData item1 = new LineMessages.itemsData();
            item1.type = 'action';
            item1.action = new LineMessages.actionData();
            item1.action.type = 'camera';
            item1.action.label = 'camera';
            tempMSG.quickReply.items.add(item1);
        }
        {
            LineMessages.itemsData item1 = new LineMessages.itemsData();
            item1.type = 'action';
            item1.action = new LineMessages.actionData();
            item1.action.type = 'cameraRoll';
            item1.action.label = 'cameraRoll';
            tempMSG.quickReply.items.add(item1);
        }

        LineMessages tempMS2 = new LineMessages();
        tempMS2.type = 'imagemap';
        tempMS2.baseUrl = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000Lv5jAAC.PNG?generation=1601289200901152&alt=media';
        tempMS2.altText = 'testImage';
        tempMS2.baseSize = new LineMessages.areaData();
        tempMS2.baseSize.width=1040;
        tempMS2.baseSize.height=780;
        tempMS2.video = new LineMessages.videoData(); 
        tempMS2.video.area = new LineMessages.areaData();
        tempMS2.video.originalContentUrl = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000Lu5EAAS.MP4?generation=1601104720733735&alt=media';
        tempMS2.video.previewImageUrl = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000Lu5JAAS.PNG?generation=1601104781487266&alt=media';
        tempMS2.video.area.x = 0;
        tempMS2.video.area.y = 0;
        tempMS2.video.area.width = 1040;
        tempMS2.video.area.height = 780;
        /*
        tempMS2.video.externalLink = new LineMessages.imageAction();
        tempMS2.video.externalLink.linkUri = 'https://google.com.tw/';
        tempMS2.video.externalLink.label = 'go to google';
        */
        tempData.messages.add(tempMSG);
        tempData.messages.add(tempMS2);
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