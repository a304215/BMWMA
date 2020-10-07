/*==============================================================
 * 呼叫Line 中台API。
 *
 *
 *==============================================================*/

public without sharing class Middle_API implements Queueable, Database.AllowsCallouts
{
    public string myStep {get; set;}
    public Middle_API(string inputStep) {
        myStep = inputStep;
    }

    public void execute(QueueableContext context) {
        if(myStep == null)
        {
            generateKeyword();
            System.enqueueJob(new Middle_API('1'));
        }
        else if(myStep == '1')
        {
            pushKeyword();
        }
    }

    private static GCPLineMiddleware__mdt mTheSetting;
    public static GCPLineMiddleware__mdt getTheSetting()
    {
        if(mTheSetting == null)
        {
            mTheSetting = new GCPLineMiddleware__mdt();
            //造道理要有一筆。
            for(GCPLineMiddleware__mdt loopSetting: [
                select 
                APISalt__c, tokenUrl__c,
                client_id__c, client_secret__c,
                username__c, password__c,
                MiddleAPIDomain__c
                from GCPLineMiddleware__mdt
                where developername='default' limit 1
            ])
            {
                mTheSetting = loopSetting;
            }
        }
        return mTheSetting;
    }

    //mAPI-1
    public class LineAccount
    {
        public string channelId {get; set;}
        public string channelSecret {get; set;}
        public string channelAccessToken {get; set;}
        public LineAccount()
        {

        }
    }
    public class outputParam
    {
        public string tokenUrl {get; set;}
        public string client_id {get; set;}
        public string client_secret {get; set;}
        public string username {get; set;}
        public string password {get; set;}
        public list<LineAccount> channels {get; set;}
        public outputParam()
        {
        }

        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(false);
            g.writeStartObject();
                g.writeFieldName('channels');
                g.writeStartArray();
                for(LineAccount loopChannel: channels)
                {
                    g.writeStartObject();
                    g.writeStringField('channelId', loopChannel.channelId);
                    g.writeStringField('channelSecret', loopChannel.channelSecret);
                    g.writeStringField('channelAccessToken', loopChannel.channelAccessToken);
                    g.writeStringField('tokenUrl', tokenUrl);
                    g.writeStringField('client_id', client_id);
                    g.writeStringField('client_secret', client_secret);
                    g.writeStringField('username', username);
                    g.writeStringField('password', password);
                    g.writeEndObject();
                }
                g.writeEndArray();
            g.writeEndObject();
            return g.getAsString();
        }
    }

    //mAPI-1 設定後台API 參數
    public static void putParam()
    {
        datetime currentTime = system.now();
        string tempString1 = getTheSetting().APISalt__c;
        string tempString2 = currentTime.format('YYYYMMddHHmmss');
        string tempString = tempString1 + tempString2;

        Blob targetBlob = Blob.valueOf(tempString);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        string hashString = EncodingUtil.convertToHex(hash);
        outputParam tempData = new outputParam();
        tempData.tokenUrl = getTheSetting().tokenUrl__c;
        tempData.client_id = getTheSetting().client_id__c;
        tempData.client_secret = getTheSetting().client_secret__c;
        tempData.username = getTheSetting().username__c;
        tempData.password = getTheSetting().password__c;
        tempData.channels = new list<LineAccount>();
        for(Line_Account__c loopAccount: [
            select id, ChannelId__c, ChannelSecret__c, ChannelAccessToken__c
            from Line_Account__c
        ])
        {
            LineAccount tempAccount1 = new LineAccount();
            tempAccount1.channelId = loopAccount.ChannelId__c;
            tempAccount1.channelSecret = loopAccount.ChannelSecret__c;
            tempAccount1.channelAccessToken = loopAccount.ChannelAccessToken__c ;
            tempData.channels.add(tempAccount1);
        }

        api_log__c tempLog = new  api_log__c();

        try {
            Httprequest req1 = new HttpRequest();  
            req1.setEndpoint(getTheSetting().MiddleAPIDomain__c+ 'params');
            req1.setMethod('POST');    
            req1.setHeader('Authorization', 'Bearer '+hashString);
            req1.setHeader('timestamp', tempString2);
            req1.setBody(tempData.toJSON());
            req1.setTimeout(120000);
        
            Http http1 = new Http();
            HttpResponse res1 = http1.send(req1);                 
            system.debug(res1.getBody());
            tempLog.Output__c = tempData.toJSON();
            tempLog.Response__c = res1.getBody().left(130000);
        } catch (Exception ex) {
            tempLog.Response__c = ex.getMessage();
        }
        tempLog.Type__c = 'mAPI-1';
        insert tempLog;
    }

    //mAPI-2 前置
    public static void generateKeyword()
    {
        list<LineKeyWord__c> dKlist = [select id from LineKeyWord__c where IsAutomated__c =true];
        delete dklist;
        list<LineMessage__c> dmlist = [select id from LineMessage__c where LineKeyWord__c =null and Line_Content__c=null];
        delete dmlist;
        list<LineMessageContent__c> dclist = [select id from LineMessageContent__c where LineMessage__c =null];
        delete dclist;

        list<keywordClass> allList = new list<keywordClass>();

        for(AutoKeywordSetting__mdt loopSetting: [
            select 
                Id, Object__c, lineAccount__c, 
                firstMessage__c, childMessage__c, 
                subPrefix__c, Parent__c, ParentAction__c, 
                parentImage__c, parentContent__c,
                isLastedKeyword__c, IsOneLevel__c,
                Keyword__c, Title__c, Content__c, imgURL__c, 
                Action1__c, Action2__c, Action3__c, Action4__c, 
                Active__c, index__c, 
                StartTime__c, EndTime__c
            from AutoKeywordSetting__mdt
            where IsActive__c = true
        ])
        {
            list<string> parentList = loopSetting.Parent__c.split('\\.');
            system.debug(parentList);

            string tempSQL = 'select ';
            tempSQL += loopSetting.lineAccount__c + ', ';
            tempSQL += loopSetting.Parent__c + ', ';
            //tempSQL += loopSetting.Keyword__c + ', ';
            tempSQL += loopSetting.Title__c + ', ';
            tempSQL += loopSetting.Content__c + ', ';
            tempSQL += loopSetting.imgURL__c + ', ';
            if(loopSetting.parentImage__c != null)
            {
                tempSQL += loopSetting.parentImage__c + ', ';
            }
            if(loopSetting.parentContent__c != null)
            {
                tempSQL += loopSetting.parentContent__c + ', ';
            }
            if(loopSetting.Action1__c != null)
            {
                tempSQL += loopSetting.Action1__c.substringAfterLast(';') + ', ';
            }
            if(loopSetting.Action2__c != null)
            {
                tempSQL += loopSetting.Action2__c.substringAfterLast(';') + ', ';
            }
            if(loopSetting.Action3__c != null)
            {
                tempSQL += loopSetting.Action3__c.substringAfterLast(';') + ', ';
            }
            if(loopSetting.Action4__c != null)
            {
                tempSQL += loopSetting.Action4__c.substringAfterLast(';') + ', ';
            }
            tempSQL += ' id ';
            tempSQL += ' from '+loopSetting.Object__c;
            tempSQL += ' where '+loopSetting.Active__c +' =true';
            if(loopSetting.StartTime__c != null)
            {
                tempSQL += ' and '+loopSetting.StartTime__c +' > now';
            }
            if(loopSetting.EndTime__c != null)
            {
                tempSQL += ' and '+loopSetting.EndTime__c +' < now';
            }
            tempSQL += ' order by '+loopSetting.index__c;
            system.debug(tempSQL);

            List<sObject> sobjList = Database.query(tempSQL);
            system.debug(sobjList);

            map<string, list<sObject>> sobMap = new map<string, list<sObject>>();
            
            for(sObject loopsob: sobjList)
            {
                string tempStr = loopSetting.Keyword__c;
                if(parentList.size() >1)
                {
                    if(loopsob.getSobject(parentList[0]) != null)
                    {
                        tempStr = string.valueOf(loopsob.getSobject(parentList[0]).get(parentList[1]));
                    }
                }
                else
                {
                    tempStr = string.valueOf(loopsob.get(loopSetting.Parent__c));
                }

                list<sObject> tempList = sobMap.get(tempStr);
                if(tempList == null)
                {
                    tempList = new list<sObject>();
                }
                tempList.add(loopsob);
                sobMap.put(tempStr, tempList);
            }

            //拿來記錄展示中心的。
            keywordClass tempKeyword3 = new keywordClass();
            messageClass tempMessage3 = new messageClass();
            if(loopSetting.parentImage__c != null)
            {
                tempKeyword3.theKeyword.type__c = 'message';
                tempKeyword3.theKeyword.PostbackData__c = '';
                tempKeyword3.theKeyword.Active__c = true;
                tempKeyword3.theKeyword.IsAutomated__c = true;
                tempKeyword3.theKeyword.Name = '【' + loopSetting.Keyword__c +'】';
                if(loopSetting.firstMessage__c != null)
                {
                    messageClass tempMessage = new messageClass();
                    tempMessage.theMessage.MessageType__c = '文字';
                    tempMessage.theMessage.text__c = loopSetting.firstMessage__c;
                    tempMessage.theMessage.Index__c = 1;
                    tempKeyword3.theMessageList.add(tempMessage);
                }

                tempMessage3.theMessage.MessageType__c = '輪播';
                tempMessage3.theMessage.Index__c = 2;
                tempMessage3.theMessage.altText__c = loopSetting.Keyword__c;
                tempMessage3.theMessage.FlexSize__c = 'kilo';
                tempKeyword3.theMessageList.add(tempMessage3);
                allList.add(tempKeyword3);
            }

            integer parentIndex = 1;
            for(string loopStr: sobMap.keyset())
            {
                keywordClass tempKeyword = new keywordClass();
                tempKeyword.theKeyword.type__c = 'message';
                tempKeyword.theKeyword.PostbackData__c = '';
                tempKeyword.theKeyword.Active__c = true;
                tempKeyword.theKeyword.IsAutomated__c = true;
                //代表是頭。
                if(loopStr == loopSetting.Keyword__c)
                {
                    tempKeyword.theKeyword.Name = '【' + loopStr +'】';
                    if(loopSetting.firstMessage__c != null)
                    {
                        messageClass tempMessage = new messageClass();
                        tempMessage.theMessage.MessageType__c = '文字';
                        tempMessage.theMessage.text__c = loopSetting.firstMessage__c;
                        tempMessage.theMessage.Index__c = 1;
                        tempKeyword.theMessageList.add(tempMessage);
                    }
                }
                else
                {
                    if(loopSetting.childMessage__c != null)
                    {
                        messageClass tempMessage = new messageClass();
                        tempMessage.theMessage.MessageType__c = '文字';
                        tempMessage.theMessage.text__c = loopSetting.childMessage__c;
                        tempMessage.theMessage.Index__c = 1;
                        tempKeyword.theMessageList.add(tempMessage);
                    }
                    
                    tempKeyword.theKeyword.Name = '【' + loopSetting.subPrefix__c +'-'+loopStr +'】';
                }
                messageClass tempMessage = new messageClass();
                tempMessage.theMessage.MessageType__c = '輪播';
                tempMessage.theMessage.Index__c = 2;
                tempMessage.theMessage.altText__c = loopSetting.Keyword__c;
                tempMessage.theMessage.FlexSize__c = 'kilo';

                //拿來記錄展示中心的。
                LineMessageContent__c tempContent3 = new LineMessageContent__c();
                tempMessage3.theContentList.add(tempContent3);

                integer tempIndex=1; 
                for(sObject loopsob: sobMap.get(loopStr))
                {
                    //拿來記錄展示中心的。
                    if(loopSetting.parentImage__c != null)
                    {
                        tempKeyword3.theKeyword.Line_Account__c = string.valueOf(loopsob.get(loopSetting.lineAccount__c));
                        tempContent3.Title__c = '【' + loopSetting.subPrefix__c +'-'+loopStr +'】';
                        tempContent3.Content__c = string.valueOf(loopsob.get(loopSetting.parentContent__c));
                        tempContent3.ImageURL__c = string.valueOf(loopsob.get(loopSetting.parentImage__c));
                        tempContent3.Index__c = parentIndex;
                        tempContent3.ActionLabelA__c = loopSetting.ParentAction__c;
                        tempContent3.ActionTypeA__c = '文字';
                        tempContent3.ActionDataA__c = '【' + loopSetting.subPrefix__c +'-'+loopStr +'】';
                    }

                    tempKeyword.theKeyword.Line_Account__c = string.valueOf(loopsob.get(loopSetting.lineAccount__c));
                    LineMessageContent__c tempContent = new LineMessageContent__c();
                    tempContent.Title__c = string.valueOf(loopsob.get(loopSetting.Title__c));
                    tempContent.Content__c = string.valueOf(loopsob.get(loopSetting.Content__c));
                    tempContent.ImageURL__c = string.valueOf(loopsob.get(loopSetting.imgURL__c));
                    tempContent.Index__c = tempIndex;
                    if(loopStr == loopSetting.Keyword__c && !loopSetting.IsOneLevel__c)
                    {
                        tempContent.ActionLabelA__c = loopSetting.ParentAction__c;
                        tempContent.ActionTypeA__c = '文字';
                        tempContent.ActionDataA__c = '【' + loopSetting.subPrefix__c +'-'+loopsob.get(loopSetting.Title__c) +'】';
                    }
                    else
                    {
                        if(loopSetting.Action1__c != null)
                        {
                            if(loopsob.get(loopSetting.Action1__c.substringAfterLast(';')) != null)
                            {
                                string tempData = loopSetting.Action1__c.substringAfter(';');
                                tempContent.ActionLabelA__c = loopSetting.Action1__c.substringBefore(';');
                                tempContent.ActionTypeA__c = '網址';
                                if(tempData.startswith('googlemap;'))
                                {
                                    tempContent.ActionDataA__c = 'https://www.google.com/maps/place/'+ EncodingUtil.urlEncode(string.valueOf(loopsob.get(tempData.substringAfterLast(';'))), 'UTF-8');
                                }
                                else if(tempData.startswith('call;'))
                                {
                                    tempContent.ActionDataA__c = 'tel:'+string.valueOf(loopsob.get(tempData.substringAfterLast(';')));
                                }
                                else
                                {
                                    tempContent.ActionDataA__c = string.valueOf(loopsob.get(tempData));
                                }
                            }
                        }
                        if(loopSetting.Action2__c != null)
                        {
                            if(loopsob.get(loopSetting.Action2__c.substringAfterLast(';')) != null)
                            {
                                string tempData = loopSetting.Action2__c.substringAfter(';');
                                tempContent.ActionLabelB__c = loopSetting.Action2__c.substringBefore(';');
                                tempContent.ActionTypeB__c = '網址';
                                if(tempData.startswith('googlemap;'))
                                {
                                    tempContent.ActionDataB__c = 'https://www.google.com/maps/place/'+ EncodingUtil.urlEncode(string.valueOf(loopsob.get(tempData.substringAfterLast(';'))), 'UTF-8');
                                }
                                else if(tempData.startswith('call;'))
                                {
                                    tempContent.ActionDataB__c = 'tel:'+string.valueOf(loopsob.get(tempData.substringAfterLast(';')));
                                }
                                else
                                {
                                    tempContent.ActionDataB__c = string.valueOf(loopsob.get(tempData));
                                }
                            }
                        }
                        if(loopSetting.Action3__c != null)
                        {
                            if(loopsob.get(loopSetting.Action3__c.substringAfterLast(';')) != null)
                            {
                                string tempData = loopSetting.Action3__c.substringAfter(';');
                                tempContent.ActionLabelC__c = loopSetting.Action3__c.substringBefore(';');
                                tempContent.ActionTypeC__c = '網址';
                                if(tempData.startswith('googlemap;'))
                                {
                                    tempContent.ActionDataC__c = 'https://www.google.com/maps/place/'+ EncodingUtil.urlEncode(string.valueOf(loopsob.get(tempData.substringAfterLast(';'))), 'UTF-8');
                                }
                                else if(tempData.startswith('call;'))
                                {
                                    tempContent.ActionDataC__c = 'tel:'+string.valueOf(loopsob.get(tempData.substringAfterLast(';')));
                                }
                                else
                                {
                                    tempContent.ActionDataC__c = string.valueOf(loopsob.get(tempData));
                                }
                            }
                        }
                        if(loopSetting.Action4__c != null)
                        {
                            if(loopsob.get(loopSetting.Action4__c.substringAfterLast(';')) != null)
                            {
                                string tempData = loopSetting.Action4__c.substringAfter(';');
                                tempContent.ActionLabelD__c = loopSetting.Action4__c.substringBefore(';');
                                tempContent.ActionTypeD__c = '網址';
                                if(tempData.startswith('googlemap;'))
                                {
                                    tempContent.ActionDataD__c = 'https://www.google.com/maps/place/'+ EncodingUtil.urlEncode(string.valueOf(loopsob.get(tempData.substringAfterLast(';'))), 'UTF-8');
                                }
                                else if(tempData.startswith('call;'))
                                {
                                    tempContent.ActionDataD__c = 'tel:'+string.valueOf(loopsob.get(tempData.substringAfterLast(';')));
                                }
                                else
                                {
                                    tempContent.ActionDataD__c = string.valueOf(loopsob.get(tempData));
                                }
                            }
                        }
                    }

                    //新車不用。預約試駕也不用，展示中心，維修中心也不用，囧。
                    if(loopSetting.isLastedKeyword__c && (!sobMap.containsKey(string.valueOf(loopsob.get(loopSetting.Title__c)))))
                    {
                        keywordClass tempKeyword2 = new keywordClass();
                        tempKeyword2.theKeyword.type__c = 'message';
                        tempKeyword2.theKeyword.PostbackData__c = '';
                        tempKeyword2.theKeyword.Active__c = true;
                        tempKeyword2.theKeyword.IsAutomated__c = true;   
                        tempKeyword2.theKeyword.Name = '【' + loopSetting.subPrefix__c +'-'+loopsob.get(loopSetting.Title__c) +'】';
                        {
                            messageClass tempMessage2 = new messageClass();
                            tempMessage2.theMessage.MessageType__c = '輪播';
                            tempMessage2.theMessage.Index__c = 3;
                            tempMessage2.theMessage.altText__c = loopStr;
                            tempMessage2.theMessage.FlexSize__c = 'kilo';
                            {
                                LineMessageContent__c tempContent2 = new LineMessageContent__c();
                                tempContent2.Title__c = string.valueOf(loopsob.get(loopSetting.Title__c));
                                tempContent2.Content__c = string.valueOf(loopsob.get(loopSetting.Content__c));
                                tempContent2.ImageURL__c = string.valueOf(loopsob.get(loopSetting.imgURL__c));
                                tempContent2.Index__c = 1;
                                tempContent2.ActionLabelA__c ='選擇';
                                tempContent2.ActionTypeA__c = '網址';
                                tempContent2.ActionDataA__c = 'https://www.bmw.com.tw/zh/index.html';
                                tempMessage2.theContentList.add(tempContent2);
                            }
                            {
                                LineMessageContent__c tempContent2 = new LineMessageContent__c();
                                tempContent2.Title__c = string.valueOf(loopsob.get(loopSetting.Title__c));
                                tempContent2.Content__c = string.valueOf(loopsob.get(loopSetting.Content__c));
                                tempContent2.ImageURL__c = string.valueOf(loopsob.get(loopSetting.imgURL__c));
                                tempContent2.Index__c = 1;
                                tempContent2.ActionLabelA__c ='選擇';
                                tempContent2.ActionTypeA__c = '網址';
                                tempContent2.ActionDataA__c = 'https://www.bmw.com.tw/zh/index.html';
                                tempMessage2.theContentList.add(tempContent2);
                            }
                            {
                                LineMessageContent__c tempContent2 = new LineMessageContent__c();
                                tempContent2.Title__c = string.valueOf(loopsob.get(loopSetting.Title__c));
                                tempContent2.Content__c = string.valueOf(loopsob.get(loopSetting.Content__c));
                                tempContent2.ImageURL__c = string.valueOf(loopsob.get(loopSetting.imgURL__c));
                                tempContent2.Index__c = 1;
                                tempContent2.ActionLabelA__c ='選擇';
                                tempContent2.ActionTypeA__c = '網址';
                                tempContent2.ActionDataA__c = 'https://www.bmw.com.tw/zh/index.html';
                                tempMessage2.theContentList.add(tempContent2);
                            }

                            tempKeyword2.theMessageList.add(tempMessage2);
                            allList.add(tempKeyword2);
                        }
                    }

                    tempMessage.theContentList.add(tempContent);
                    tempIndex++;
                }
                tempKeyword.theMessageList.add(tempMessage);

                parentIndex++;
                allList.add(tempKeyword);
            }
        }

        list<LineKeyWord__c> insertKeyList = new list<LineKeyWord__c>();
        list<LineMessage__c> insertMessageList = new list<LineMessage__c>();
        list<LineMessageContent__c> insertContentList = new list<LineMessageContent__c>();

        for(keywordClass loopK: allList)
        {
            insertKeyList.add(loopK.theKeyword);
        }
        insert insertKeyList;

        for(keywordClass loopK: allList)
        {
            for(messageClass loopM: loopK.theMessageList)
            {
                loopM.theMessage.LineKeyWord__c = loopK.theKeyword.id;
                insertMessageList.add(loopM.theMessage);
            }
        }
        insert insertMessageList;

        for(keywordClass loopK: allList)
        {
            for(messageClass loopM: loopK.theMessageList)
            {
                for(LineMessageContent__c loopC: loopM.theContentList)
                {
                    loopC.LineMessage__c = loopM.theMessage.id;
                    insertContentList.add(loopC);
                }
            }
        }
        insert insertContentList;
    }

    public class keywordClass
    {
        public LineKeyWord__c theKeyword;
        public list<messageClass> theMessageList;
        public keywordClass()
        {
            theKeyword = new LineKeyWord__c();
            theMessageList = new list<messageClass>();
        }
    }

    public class messageClass
    {
        public LineMessage__c theMessage;
        public list<LineMessageContent__c> theContentList;
        public messageClass()
        {
            theMessage = new LineMessage__c();
            theContentList = new list<LineMessageContent__c>();
        }
    }
    
    

    //mAPI-2
    public class channelData
    {
        public string channelId {get; set;}
        public list<keywordData> keywords {get; set;}
        public list<LineMessages> defaultMessages {get; set;}
        public channelData(){}
    }
    public class keywordData
    {
        public string keyword {get; set;}
        public list<LineMessages> messages {get; set;}
        public string postback {get; set;}
        public keywordData(){}
    }
    public class outputMSG
    {
        public list<channelData> channels {get; set;}
        public outputMSG()
        {
        }

        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(false);
            g.writeStartObject();
                g.writeFieldName('channels');
                g.writeStartArray();
                for(channelData loopChannel: channels)
                {
                    g.writeStartObject();
                    g.writeStringField('id', loopChannel.channelId);
                    g.writeFieldName('keywords');
                    g.writeStartArray();
                        for(keywordData loopKeyword: loopChannel.keywords)
                        {
                            g.writeStartObject();
                            g.writeStringField('keyword', loopKeyword.keyword);
                            g.writeFieldName('messages');
                            g.writeStartArray();
                                for(LineMessages loopMSG: loopKeyword.messages)
                                {
                                    loopMSG.toJSON(g);
                                }
                            g.writeEndArray();
                            g.writeStringField('postback', loopKeyword.postback);
                            g.writeEndObject();
                        }
                    g.writeEndArray();
                    g.writeFieldName('defaultMessages');
                    g.writeStartArray();
                        for(LineMessages loopMSG: loopChannel.defaultMessages)
                        {
                            loopMSG.toJSON(g);
                        }
                    g.writeEndArray();

                    g.writeEndObject();
                }
                g.writeEndArray();
            g.writeEndObject();
            return g.getAsString();
        }
    }

    //mAPI-2 傳送關鍵字
    public static void pushKeyword()
    {
        datetime currentTime = system.now();
        string tempString1 = getTheSetting().APISalt__c;
        string tempString2 = currentTime.format('YYYYMMddHHmmss');
        string tempString = tempString1 + tempString2;

        Blob targetBlob = Blob.valueOf(tempString);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        string hashString = EncodingUtil.convertToHex(hash);
        outputMSG tempData = new outputMSG();
        tempData.channels = new list<channelData>();
        list<Line_Account__c> laList = new list<Line_Account__c>();
        //channelId
        map<string, list<LineKeyWord__c>> keyMap = new map<string, list<LineKeyWord__c>>();
        set<string> keywordSet = new set<string>();
        //keywordId
        map<string, list<LineMessage__c>> msgMap = new map<string, list<LineMessage__c>>();

        //la
        for(Line_Account__c loopAccount: [
            select id, ChannelId__c, ChannelSecret__c, ChannelAccessToken__c
            from Line_Account__c
        ])
        {
            laList.add(loopAccount);
        }
        //keyword
        for(LineKeyWord__c loopKey: [
            select id, Name, Line_Account__c, Type__c, PostbackData__c, Active__c
            from LineKeyWord__c
            where Active__c = true
            and Line_Account__c in: laList
        ])
        {
            list<LineKeyWord__c> tempList = keyMap.get(loopKey.Line_Account__c);
            if(tempList == null)
            {
                tempList = new list<LineKeyWord__c>();
            }
            tempList.add(loopKey);
            keyMap.put(loopKey.Line_Account__c, tempList);
            keywordSet.add(loopKey.id);
        }
        //message
        for(LineMessage__c loopMsg: [
            select 
            id, Index__c, isDeleted__c, LineKeyWord__c, LineKeyWord__r.Name,
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
            where LineKeyWord__c in: keywordSet
            and LineKeyWord__c != null
            order by LineKeyWord__c, Index__c
        ])
        {
            list<LineMessage__c> tempList = msgMap.get(loopMsg.LineKeyWord__c);
            if(tempList == null)
            {
                tempList = new list<LineMessage__c>();
            }
            tempList.add(loopMsg);
            msgMap.put(loopMsg.LineKeyWord__c, tempList);
        }

        for(Line_Account__c loopAccount: laList)
        {
            channelData tempAccount1 = new channelData();
            tempAccount1.channelId = loopAccount.ChannelId__c;
            tempAccount1.keywords = new list<keywordData>();
            tempAccount1.defaultMessages = new list<LineMessages>();
            LineMessages noMSG = new LineMessages();
            noMSG.type = 'image';
            noMSG.originalContentUrl = '';
            noMSG.previewImageUrl = '';

            LineMessages defaultMSG = new LineMessages();
            defaultMSG.type = 'text';
            defaultMSG.altText = '功能建置中';
            defaultMSG.text = '功能建置中';
            tempAccount1.defaultMessages.add(defaultMSG);
            
            if(keyMap.containsKey(loopAccount.id))
            {
                for(LineKeyWord__c loopKey: keyMap.get(loopAccount.id))
                {
                    keywordData k1 = new keywordData();
                    k1.keyword = loopKey.Name;
                    k1.messages = new list<LineMessages>();
                    k1.postback = '';

                    switch on loopKey.type__c
                    {
                        when 'Message', 'Default', 'Welcome'
                        {
                            list<LineMessages> msgList = new list<LineMessages>();
                            if(msgMap.containsKey(loopKey.id))
                            {
                                for(LineMessage__c loopMSG: msgMap.get(loopKey.id))
                                {
                                    system.debug('====luke: '+loopKey.Name + ' : ' + loopMSG.MessageType__c);
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
                                            tempMSG.altText = loopKey.Name;
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
                                            tempMSG.altText = loopMSG.LineKeyWord__r.Name;
                                            tempMSG.contents = new LineMessages.singleContentData();
                                            tempMSG.contents.type = 'carousel';
                                            tempMSG.contents.contents = new list<LineMessages.contentsData>();
                                            for(LineMessageContent__c loopContent: loopMSG.LineMessageContent__r)
                                            {
                                                LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                                                crlcontent.type = 'bubble';
                                                crlcontent.size = loopMSG.FlexSize__c;
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
                                            tempMSG.altText = loopMSG.LineKeyWord__r.Name;
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
                            }

                            switch on loopKey.type__c
                            {
                                when 'Message'
                                {
                                    k1.messages = msgList;
                                    tempAccount1.keywords.add(k1);
                                }
                                when 'Default'
                                {
                                    tempAccount1.defaultMessages = msgList;
                                }
                                when 'Welcome'
                                {

                                }
                            }
                            
                        }
                        when 'Postback'
                        {
                            k1.postback = loopKey.PostbackData__c;
                            tempAccount1.keywords.add(k1);
                        }
                        when 'No Message'
                        {
                            k1.messages.add(noMSG);
                            tempAccount1.keywords.add(k1);
                        }
                        when else
                        {

                        }
                    }
                }
            }
            tempData.channels.add(tempAccount1);
        }
        
        
        
        string calloutBody = tempData.toJSON();
        string calloutResponse = '';
        try {
            Httprequest req1 = new HttpRequest();  
            req1.setEndpoint(getTheSetting().MiddleAPIDomain__c+ 'msg');
            req1.setMethod('POST');    
            req1.setHeader('Authorization', 'Bearer '+hashString);
            req1.setHeader('timestamp', tempString2);
            req1.setBody(calloutBody);
            req1.setTimeout(120000);
        
            Http http1 = new Http();
            HttpResponse res1 = http1.send(req1);                 
            system.debug(res1.getBody());
            calloutResponse = res1.getBody();
        } catch (Exception ex) {
            calloutResponse = ex.getMessage();
        }

        list<api_log__c> insertLog = new list<api_log__c>();
        for(integer i=0; i< calloutBody.length(); i=i+130000)
        {
            if(i+130000 < calloutBody.length())
            {
                API_Log__c newLog = new API_Log__c();
                newLog.Type__c = 'mAPI-2:'+tempString2+':'+string.valueOf(i);
                newLog.Output__c = calloutBody.subString(i, i+130000);
                newLog.Response__c = calloutResponse.left(130000);
                insertLog.add(newLog);
            }
            else
            {
                API_Log__c newLog = new API_Log__c();
                newLog.Type__c = 'mAPI-2:'+tempString2+':'+string.valueOf(i);
                newLog.Output__c = calloutBody.subString(i, calloutBody.length());
                newLog.Response__c = calloutResponse.left(130000);
                insertLog.add(newLog);
            }
        }

        if(insertLog.size() >0)
        {
            insert insertLog;
        }
    }

    //mAPI-3 推播訊息
    public static void pushMessage()
    {

    }
}