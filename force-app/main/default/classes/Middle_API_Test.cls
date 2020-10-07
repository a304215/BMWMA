/*==============================================================
 * 呼叫Line 中台API。
 *
 *
 *==============================================================*/

public without sharing class Middle_API_Test {
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
        for(Line_Account__c loopAccount: [
            select id, ChannelId__c, ChannelSecret__c, ChannelAccessToken__c
            from Line_Account__c
        ])
        {
            channelData tempAccount1 = new channelData();
            tempAccount1.channelId = loopAccount.ChannelId__c;
            tempAccount1.keywords = new list<keywordData>();
            tempAccount1.defaultMessages = new list<LineMessages>();
            {
                keywordData k1 = new keywordData();
                k1.keyword = '安安';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'text';
                tempMSG.text = '你好安安';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            //modified by luke
            {
                keywordData k1 = new keywordData();
                k1.keyword = 'postme';
                k1.messages = new list<LineMessages>();
                k1.postback = 'action=_1';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = 'postmeAA';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'text';
                tempMSG.text = '你好安安';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '我是單身貴族';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '我有男朋友/女朋友';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '我是新手爸媽';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '我有兩個以上的大小孩';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '我有三個以上的小孩';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '我是退休夫妻';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '就是我時尚搭配';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '乘坐與載物的大空間';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '乘客的安全';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '駕馭的速度感';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '高質感的奢華設計';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '潮流小車';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '中型豪華房車/休旅車';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '大型豪華房車/休旅車';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '性能跑車';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'image';
                tempMSG.originalContentUrl = '';
                tempMSG.previewImageUrl = '';
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }

            {
                keywordData k1 = new keywordData();
                k1.keyword = '【購車資訊-BMW為你推薦】';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【購車資訊-BMW為你推薦】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '一、你的家庭成員';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                 
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'postback';
                        content.action.label = '我是單身貴族';
                        content.action.text = '我是單身貴族';
                        content.action.data = 'action=q1&answer=我是單身貴族';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'postback';
                        content.action.label = '我有男朋友/女朋友';
                        content.action.text = '我有男朋友/女朋友';
                        content.action.data = 'action=q1&answer=我有男朋友/女朋友';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'postback';
                        content.action.label = '我是新手爸媽';
                        content.action.text = '我是新手爸媽';
                        content.action.data = 'action=q1&answer=我是新手爸媽';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'postback';
                        content.action.label = '我有兩個以上的大小孩';
                        content.action.text = '我有兩個以上的大小孩';
                        content.action.data = 'action=q1&answer=我有兩個以上的大小孩';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'postback';
                        content.action.label = '我有三個以上的小孩';
                        content.action.text = '我有三個以上的小孩';
                        content.action.data = 'action=q1&answer=我有三個以上的小孩';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'postback';
                        content.action.label = '我是退休夫妻';
                        content.action.text = '我是退休夫妻';
                        content.action.data = 'action=q1&answer=我是退休夫妻';
                        crlcontent.footer.contents.add(content);
                    }
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '會員註冊';
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'image';
                    tempMSG.originalContentUrl = 'https://www.bmw.com.tw/content/dam/bmw/marketTW/bmw_com_tw/index-4column/configurator.jpg';
                    tempMSG.previewImageUrl = 'https://www.bmw.com.tw/content/dam/bmw/marketTW/bmw_com_tw/index-4column/configurator.jpg';
                    k1.messages.add(tempMSG);
                }
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'text';
                    tempMSG.text = '歡迎來到BMW官方帳號，請繫上安全帶，我將帶你一探 BMW 的領域';
                    k1.messages.add(tempMSG);
                }
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'template';
                    tempMSG.altText = '會員註冊';
                    tempMSG.template = new LineMessages.templateData();
                    tempMSG.template.type = 'confirm';
                    tempMSG.template.text = '如果你已經是車主，花兩分鐘加入會員，即可開始預約進廠、查看你的愛車相關資訊\n\n如果你尚未擁有 BMW，點擊「我不是車主」加入會員，有機會獲得驚喜小禮跟收到 BMW 優惠訊息喔';
                    tempMSG.template.actions = new list<LineMessages.actionData>();
                    {
                        LineMessages.actionData action1 = new LineMessages.actionData();
                        action1.type = 'uri';
                        action1.label = '加入會員';
                        action1.uri = 'https://liff.line.me/1654408823-569bdxjQ';
                        tempMSG.template.actions.add(action1);
                    }
                    {
                        LineMessages.actionData action1 = new LineMessages.actionData();
                        action1.type = 'uri';
                        action1.label = '我不是車主';
                        action1.uri = 'https://liff.line.me/1654408823-OPmzBJVL';
                        tempMSG.template.actions.add(action1);
                    }
                    k1.messages.add(tempMSG);
                }
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【活動新訊】';
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = 'BMW 什麼最新、什麼最New、什麼最夯，我通通知道';
                    k1.messages.add(tempMSG1);
                }
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【活動新訊】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=JPG&versionId=0681s000000LZIE&operationContext=DELIVERY&page=1&d=/a/1s0000000GCe/xColOFN3dwSlQzNnB0kPzjoWyNWYlMta.QCExf7blx8&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW 品牌新訊';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '關於 BMW 的最新動向，讓你輕鬆掌握';
                            contentbase.wrap = true;
                            contentbase.color = '#666666';
                            contentbase.size = 'sm';
                            contentbase.flex = 1;
                            content.contents.add(contentbase);
                        }
                    }                  
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '品牌新訊';
                        content.action.uri = 'https://www.bmw.com.tw/zh/news/info.html';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=JPG&versionId=0681s000000LXew&operationContext=DELIVERY&page=1&d=/a/1s0000000G4k/HqkxD0VNSo3hr4CqKCk3Qkvgbc9Ko2x_ENPZOGBim9A&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW 2020 Kids Campus';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '2020 BMW Kids Campus將汽車與交通安全知識以關卡的方式呈現，結合虛擬實境等多項新穎巧思，讓孩童於玩樂中學習，與父母享受歡樂的暑期時光。';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '活動詳情';
                        content.action.uri = 'https://www.bmw.com.tw/zh/news/info/2020/20200703-BMW-Kids-Campus.html';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '前往報名';
                        content.action.uri = 'https://qrpass.cc/to/bmwkids/';
                        crlcontent.footer.contents.add(content);
                    }
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【購車資訊】';
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = '你的需求我使命必達，我知無不言，言無不盡';
                    k1.messages.add(tempMSG1);
                }
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【購車資訊】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=JPG&versionId=0681s000000LZIO&operationContext=DELIVERY&page=1&d=/a/1s0000000GCj/FHOanRk5ytJee82VRN2xAEcAUyyEdbXysLUGfoK6za0&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW 新車資訊';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '你喜歡時尚帥勁的潮流小車? 還是豪華霸氣的運動休旅? 這裡有最完整豐富的車款資訊讓你好好選擇屬於自己的夢想座駕!';
                            contentbase.color = '#666666';
                            contentbase.wrap = true;
                            contentbase.size = 'sm';
                            contentbase.flex = 1;
                            content.contents.add(contentbase);
                        }
                    }                 
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'message';
                        content.action.label = '新車資訊';
                        content.action.text = '【購車資訊-新車資訊】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=JPG&versionId=0681s000000LZIF&operationContext=DELIVERY&page=1&d=/a/1s0000000GCt/W9xdykRnJSlaQswmR2_fkYIHlXSR9tnGKWjOaPmvPBw&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW為你推薦';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '如果你還沒有遇到心有所屬的BMW，就讓我們來為你推薦吧!';
                            contentbase.wrap = true;
                            contentbase.color = '#666666';
                            contentbase.size = 'sm';
                            contentbase.flex = 1;
                            content.contents.add(contentbase);
                        }
                    }                  
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'message';
                        content.action.label = 'BMW為你推薦';
                        content.action.text = '【購車資訊-BMW為你推薦】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LZIx&operationContext=DELIVERY&page=1&d=/a/1s0000000GD8/vRVcfsuQQ8iwEC8qgaiGW_BOEWxNgXqO1m.s7ziv1KA&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW原廠認證中古車';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '提供最完整嚴格的原廠中古車檢驗機制，讓你安心購買，放心享受，開啟精彩駕馭新旅程！';
                            contentbase.wrap = true;    
                            contentbase.color = '#666666';
                            contentbase.size = 'sm';
                            contentbase.flex = 1;
                            content.contents.add(contentbase);
                        }
                    }                  
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = 'BMW原廠認證中古車';
                        content.action.uri = 'https://bps.bmw.com.tw/?utm_source=official_website';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=JPG&versionId=0681s000000LZJ2&operationContext=DELIVERY&page=1&d=/a/1s0000000GDD/me46JxVsuh16Nj9QiqZd7DavYht6FYzkRg3REmGOtck&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW 展示中心據點';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '千言萬語不如眼見為憑，來展間選擇屬於你的 BMW';
                            contentbase.wrap = true;   
                            contentbase.color = '#666666';
                            contentbase.size = 'sm';
                            contentbase.flex = 1;
                            content.contents.add(contentbase);
                        }
                    }                  
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'message';
                        content.action.label = '展示中心選單';
                        content.action.text = '【購車資訊-展示中心選單】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
          
            
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【預約保養】';
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = '關心你跟你的愛車是我最在乎的事，我必定讓你的車跟新的一樣';
                    k1.messages.add(tempMSG1);
                }
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【預約保養】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LXefAAG.JPG?generation=1599544330883408&alt=media';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '售後線上預約服務';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '現在就啟用線上預約服務，輕鬆預約回廠，只需享受專屬於你的貼心服務，你的愛車就交給我們!';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '開始預約';
                        content.action.uri = 'https://marvelapp.com/prototype/f34gg0e';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=JPG&versionId=0681s000000LZJH&operationContext=DELIVERY&page=1&d=/a/1s0000000GDS/PPaywgTAvwtAVg6eBe9zVLduennRgHZcgKtknssHzhc&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '生活精品線上購物';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '來自原廠的生活精品設計豐富你的生活樣貌，立即前往選擇你所愛!';
                            contentbase.color = '#666666';
                            contentbase.size = 'sm';
                            contentbase.flex = 1;
                            contentbase.wrap = true;
                            content.contents.add(contentbase);
                        }
                    }         
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '生活精品購物';
                        content.action.uri = 'https://www.bmw-shop.com.tw/';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LXekAAG.JPG?generation=1599544399223076&alt=media';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '原廠加裝品';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = 'BMW原廠加裝品為你的愛車提供外型與功能兼具的專屬風格選擇，增添更多樣化的個性與魅力，馬上前往一探究竟。';
                            contentbase.color = '#666666';
                            contentbase.size = 'sm';
                            contentbase.flex = 5;
                            contentbase.wrap = true;
                            content.contents.add(contentbase);
                        }
                    }         
                    crlcontent.footer=new LineMessages.containerData();
                    crlcontent.footer.type = 'box';
                    crlcontent.footer.layout = 'vertical';
                    crlcontent.footer.spacing = 'sm';
                    crlcontent.footer.contents= new list<LineMessages.contentsData>();
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '原廠加裝品全系列';
                        content.action.uri = 'https://www.bmw.com.tw/zh/topics/offers-and-services/original-installation/accessories.html';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LXeuAAG.JPG?generation=1599544645472000&alt=media';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW 服務中心據點';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '想了解與體驗更多BMW售後服務? 點擊下方尋找與你最近的服務中心';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'message';
                        content.action.label = '查詢據點';
                        content.action.text = '【預約保養-服務中心選單】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【智選方案】';
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = 'BMW 跟你的距離比你想像的還近，快來牽一台回家';
                    k1.messages.add(tempMSG1);
                }
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = 'BMW Yours 智選方案';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LZpX&operationContext=DELIVERY&page=1&d=/a/1s0000000GLH/8MKcDq9rbt.meZN.Wjv4E48v6nwVSOZTKZ2naaEOF5s&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = 'BMW Yours 智選方案';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = 'BMW 靈活彈性的財務方案讓我們更靠近，讓你輕鬆入主BMW';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '開始試算';
                        content.action.uri = 'https://bmwyours.bmw.com.tw/index.html';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LYidAAG.JPG?generation=1599617706862961&alt=media';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '限時禮遇';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '入主 BMW 沒有想像的遙遠，這裡有關於購車優惠的資訊給你參考';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '限時禮遇';
                        content.action.uri = 'https://www.bmw.com.tw/zh/news/SP.html';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【會員專區】';
                k1.messages = new list<LineMessages>();
                /*
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【會員專區】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '會員資料';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '修改你的個人資料，如：姓別、email、地址';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '檢視/編輯';
                        content.action.uri = 'https://liff.line.me/1654408823-gE9JYk7j';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '車輛管理';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '查看你的愛車資料，也可新增或移除你的愛車';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '選擇';
                        content.action.uri = 'https://liff.line.me/1654408823-Pp1nr43e';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '優惠卷管理';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '查看你擁有的優惠卷';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '選擇';
                        content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb';
                    crlcontent.hero.size = 'full';
                    crlcontent.hero.aspectRatio = '4:3';
                    crlcontent.hero.aspectMode = 'cover';
                    crlcontent.body = new LineMessages.containerData();
                    crlcontent.body.type='box';
                    crlcontent.body.layout='vertical';
                    crlcontent.body.contents= new list<LineMessages.contentsData>();
                    tempMSG.contents.contents.add(crlcontent);
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'text';
                        content.text = '有任何疑問嗎?';
                        content.weight = 'bold';
                        content.size = 'md';
                        crlcontent.body.contents.add(content);
                    }                          
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'box';
                        content.layout = 'vertical';
                        content.margin = 'lg';
                        content.spacing = 'sm';
                        content.contents = new list<LineMessages.contentsData>();
                        crlcontent.body.contents.add(content);
                        {
                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                            contentbase.type = 'text';
                            contentbase.text = '請於9:00 - 21:00 間撥打客服專線跟我們聯繫';
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
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '撥打客服';
                        content.action.uri = 'tel:0800-291-101';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                k1.messages.add(tempMSG);
                */
                k1.postback = 'action=checkMember';
                tempAccount1.keywords.add(k1);
            }

            map<string, list<CarModels__c>> cmMap = new map<string, list<CarModels__c>>();
            for(CarModels__c loopCarM: [
                select id, Name,
                    LineCarGeneration__c, LineCarType__c, CarGenerationURL__c, CarGenerationShow__c, CarTypeURL__c, CarTypeShow__c, 
                    WebsiteURL__c, IsActive__c, Line_Account__c, CarGenerationDesc__c, CarTypeDesc__c, 
                    StartTime__c, EndTime__c, 
                    SellingGeneration__c, CarCategory__c, Parent_Car_Category__r.Name, TestDriveURL__c, CarDataURL__c, CarInformationURL__c, CustomBMW_URL__c
                from CarModels__c
                where IsActive__c = true
                and Line_Account__c=:loopAccount.id
                order by Parent_Car_Category__r.Count__c, Parent_Car_Category__r.Name, Count__c
            ])
            {
                list<CarModels__c> tempList = cmMap.get(loopCarM.Parent_Car_Category__r.Name);
                if(tempList==null)
                {
                    tempList = new list<CarModels__c>();
                }
                tempList.add(loopCarM);
                cmMap.put(loopCarM.Parent_Car_Category__r.Name, tempList);
            }

            map<string, list<Line_TestDrive__c>> ltMap = new map<string, list<Line_TestDrive__c>>();
            for(Line_TestDrive__c loopTestD: [
                select id, Name,
                    Line_Account__c, SellingGeneration__c, EndTime__c, customBMWweburl__c, LineCarType__c, CarTypeURL__c,
                    CarTypeShow__c, CarTypeDesc__c, Parent_Car_Category__r.Name, LineCarGeneration__c, CarCategory__c,
                    CarGenerationURL__c, CarGenerationShow__c, CarGenerationDes__c, StartTime__c, IsActive__c, WebsiteURL__c
                from Line_TestDrive__c
                where IsActive__c = true
                and Line_Account__c=:loopAccount.id
                order by Parent_Car_Category__r.Count__c, Parent_Car_Category__r.Name, Count__c
            ])
            {
                list<Line_TestDrive__c> tempListlt = ltMap.get(loopTestD.Parent_Car_Category__r.Name);
                if(tempListlt==null)
                {
                    tempListlt = new list<Line_TestDrive__c>();
                }
                tempListlt.add(loopTestD);
                ltMap.put(loopTestD.Parent_Car_Category__r.Name, tempListlt);
            }
            map<string, list<ShowRoom__c>> srMap = new map<string, list<ShowRoom__c>>();
            for(ShowRoom__c loopShowR: [
                select id, Name,
                    Line_Account__c, IsActive__c, Area__c, ShowRoom__c, WebsiteURL__c,
                    Showroom_address__c, Showroom_phone__c, Area_Detail__c, ShowroomURL__c, ShowroomAreaURL__c
                from ShowRoom__c
                where IsActive__c = true
                and Line_Account__c=:loopAccount.id
            ])
            {
                list<ShowRoom__c> tempListlt = srMap.get(loopShowR.Area__c);
                if(tempListlt==null)
                {
                    tempListlt = new list<ShowRoom__c>();
                }
                tempListlt.add(loopShowR);
                srMap.put(loopShowR.Area__c, tempListlt);
            }
            
            
            for(string loopstr: ltMap.keyset())
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【'+(loopstr==null?'預約試駕':'車系-'+loopstr)+'】';
                k1.messages = new list<LineMessages>();
                if(k1.keyword=='【預約試駕】')    
                {                
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = 'BMW 的迷人之處，不用多說，親身體驗之後更明白，先來選一台你想體驗的車';
                    k1.messages.add(tempMSG1);
                }  
                if(k1.keyword=='【車系-'+loopstr+'】')    
                {                
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = 'Excellent choice. 再幫我挑一台你想駕馭的車款，讓我來幫你實現';
                    k1.messages.add(tempMSG1);
                }         
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'flex';
                    tempMSG1.altText = (loopstr==null?'預約試駕':'車系-'+loopstr);
                    tempMSG1.contents = new LineMessages.singleContentData();  
                    tempMSG1.contents.type = 'carousel';
                    tempMSG1.contents.contents= new list<LineMessages.contentsData>();
                    for(Line_TestDrive__c loopCM: ltMap.get(loopstr))               
                    {
                        LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                        crlcontent.type = 'bubble';
                        crlcontent.size = 'kilo';
                        crlcontent.hero = new LineMessages.containerData();
                        crlcontent.hero.type = 'image';
                        crlcontent.hero.url = loopCM.CarGenerationURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.CarGenerationURL__c;
                        crlcontent.hero.size = 'full';
                        crlcontent.hero.aspectRatio = '4:3';
                        crlcontent.hero.aspectMode = 'cover';
                        crlcontent.hero.action = new LineMessages.actionData();
                        crlcontent.hero.action.type = 'uri';
                        crlcontent.hero.action.uri = loopCM.WebsiteURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.WebsiteURL__c;
                        crlcontent.body = new LineMessages.containerData();
                        crlcontent.body.type='box';
                        crlcontent.body.layout='vertical';
                        crlcontent.body.contents= new list<LineMessages.contentsData>();
                        tempMSG1.contents.contents.add(crlcontent);
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            //String stringValue = String.valueOf(j);
                            content.type = 'text';
                            content.text = loopCM.Name;
                            content.weight = 'bold';
                            content.size = 'md';
                            crlcontent.body.contents.add(content);
                        }
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'box';
                            content.layout = 'vertical';
                            content.margin = 'lg';
                            content.spacing = 'sm';
                            content.contents = new list<LineMessages.contentsData>();
                            crlcontent.body.contents.add(content);
                            {
                                LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                contentbase.type = 'box';
                                contentbase.layout = 'baseline';
                                contentbase.spacing = 'sm';
                                contentbase.contents = new list<LineMessages.contentsData>();
                                content.contents.add(contentbase);
                                {
                                    LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                    contenttext.type = 'text';
                                    contenttext.text = loopCM.CarTypeDesc__c==null?loopCM.Name+'123':loopCM.CarTypeDesc__c;
                                    contenttext.wrap = true;
                                    contenttext.color = '#666666';
                                    contenttext.size = 'sm';
                                    contenttext.flex = 5;
                                    contentbase.contents.add(contenttext);
                                }
                            }
                        }
                        crlcontent.footer=new LineMessages.containerData();
                        crlcontent.footer.type = 'box';
                        crlcontent.footer.layout = 'vertical';
                        crlcontent.footer.spacing = 'sm';
                        crlcontent.footer.contents= new list<LineMessages.contentsData>();
                        if(tempMSG1.altText =='預約試駕')
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            content.action.type = 'message';
                            content.action.label = '選擇';
                            content.action.text = '【'+'車系-'+loopCM.Name+'】';
                            crlcontent.footer.contents.add(content);
                        }
                        else if(tempMSG1.altText =='車系-'+loopstr)
                        {
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'uri';
                                content.action.label = '預約賞車';
                                content.action.uri = loopCM.WebsiteURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.WebsiteURL__c;
                                crlcontent.footer.contents.add(content);
                            }
                        }                      
                    }
                    k1.messages.add(tempMSG1);
                }
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            for(string loopstr: cmMap.keyset())
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【'+(loopstr==null?'購車資訊-新車資訊':'新車-'+loopstr)+'】';
                k1.messages = new list<LineMessages>();
                if(k1.keyword=='【購車資訊-新車資訊】')
                {                
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = '你想看哪個系列的車?';
                    k1.messages.add(tempMSG1);
                }
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'flex';
                    tempMSG1.altText = (loopstr==null?'購車資訊-新車資訊':'新車-'+loopstr);
                    tempMSG1.contents = new LineMessages.singleContentData();  
                    tempMSG1.contents.type = 'carousel';
                    tempMSG1.contents.contents= new list<LineMessages.contentsData>();
                    for(CarModels__c loopCM: cmMap.get(loopstr))               
                    {
                        LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                        crlcontent.type = 'bubble';
                        crlcontent.size = 'kilo';
                        crlcontent.hero = new LineMessages.containerData();
                        crlcontent.hero.type = 'image';
                        crlcontent.hero.url = loopCM.CarGenerationURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.CarGenerationURL__c;
                        crlcontent.hero.size = 'full';
                        crlcontent.hero.aspectRatio = '4:3';
                        crlcontent.hero.aspectMode = 'cover';
                        crlcontent.hero.action = new LineMessages.actionData();
                        crlcontent.hero.action.type = 'uri';
                        crlcontent.hero.action.uri = loopCM.WebsiteURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.WebsiteURL__c;
                        crlcontent.body = new LineMessages.containerData();
                        crlcontent.body.type='box';
                        crlcontent.body.layout='vertical';
                        crlcontent.body.contents= new list<LineMessages.contentsData>();
                        tempMSG1.contents.contents.add(crlcontent);
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            //String stringValue = String.valueOf(j);
                            content.type = 'text';
                            content.text = loopCM.Name;
                            content.weight = 'bold';
                            content.size = 'md';
                            crlcontent.body.contents.add(content);
                        }
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'box';
                            content.layout = 'vertical';
                            content.margin = 'lg';
                            content.spacing = 'sm';
                            content.contents = new list<LineMessages.contentsData>();
                            crlcontent.body.contents.add(content);
                            {
                                LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                contentbase.type = 'box';
                                contentbase.layout = 'baseline';
                                contentbase.spacing = 'sm';
                                contentbase.contents = new list<LineMessages.contentsData>();
                                content.contents.add(contentbase);
                                {
                                    LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                    contenttext.type = 'text';
                                    contenttext.text = loopCM.CarTypeDesc__c==null?loopCM.Name+'123':loopCM.CarTypeDesc__c;
                                    contenttext.wrap = true;
                                    contenttext.color = '#666666';
                                    contenttext.size = 'sm';
                                    contenttext.flex = 5;
                                    contentbase.contents.add(contenttext);
                                }
                            }
                        }
                        crlcontent.footer=new LineMessages.containerData();
                        crlcontent.footer.type = 'box';
                        crlcontent.footer.layout = 'vertical';
                        crlcontent.footer.spacing = 'sm';
                        crlcontent.footer.contents= new list<LineMessages.contentsData>();
                        if(tempMSG1.altText =='購車資訊-新車資訊')
                        {
                            LineMessages.contentsData content = new LineMessages.contentsData();
                            content.type = 'button';
                            content.style = 'link';
                            content.height = 'sm';
                            content.action = new LineMessages.actionData();
                            content.action.type = 'message';
                            content.action.label = '選擇';
                            content.action.text = '【'+'新車-'+loopCM.Name+'】';
                            crlcontent.footer.contents.add(content);
                        }
                        else if(tempMSG1.altText =='新車-'+loopstr)
                        {
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'uri';
                                content.action.label = '預約賞車';
                                content.action.uri = loopCM.TestDriveURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.TestDriveURL__c;
                                crlcontent.footer.contents.add(content);
                            }
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'uri';
                                content.action.label = '規格配備';
                                content.action.uri = loopCM.CarDataURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.CarDataURL__c;
                                crlcontent.footer.contents.add(content);
                            }
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'uri';
                                content.action.label = '了解更多';
                                content.action.uri = loopCM.CarInformationURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.CarInformationURL__c;
                                crlcontent.footer.contents.add(content);
                            }
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'uri';
                                content.action.label = '訂製您的BMW';
                                content.action.uri = loopCM.CustomBMW_URL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.CustomBMW_URL__c;
                                crlcontent.footer.contents.add(content);
                            }
                        }
                        
                        if(! cmMap.containsKey(loopCM.Name))
                        {
                            keywordData k2 = new keywordData();
                            k2.keyword = '【'+'新車1-'+loopCM.Name+'】';
                            k2.messages = new list<LineMessages>();
                            {
                                LineMessages tempMSG2 = new LineMessages();
                                tempMSG2.type = 'flex';
                                tempMSG2.altText = '新車1-'+loopCM.Name;
                                tempMSG2.contents = new LineMessages.singleContentData();  
                                tempMSG2.contents.type = 'carousel';
                                tempMSG2.contents.contents= new list<LineMessages.contentsData>();   
                                {
                                    LineMessages.contentsData crlcontent2 = new LineMessages.contentsData();
                                    crlcontent2.type = 'bubble';
                                    crlcontent2.size = 'kilo';
                                    crlcontent2.hero = new LineMessages.containerData();
                                    crlcontent2.hero.type = 'image';
                                    crlcontent2.hero.url = loopCM.CarGenerationURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb:loopCM.CarGenerationURL__c':loopCM.CarGenerationURL__c;
                                    crlcontent2.hero.size = 'full';
                                    crlcontent2.hero.aspectRatio = '4:3';
                                    crlcontent2.hero.aspectMode = 'cover';
                                    crlcontent2.hero.action = new LineMessages.actionData();
                                    crlcontent2.hero.action.type = 'uri';
                                    crlcontent2.hero.action.uri = loopCM.WebsiteURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.WebsiteURL__c;
                                    crlcontent2.body = new LineMessages.containerData();
                                    crlcontent2.body.type='box';
                                    crlcontent2.body.layout='vertical';
                                    crlcontent2.body.contents= new list<LineMessages.contentsData>();
                                    tempMSG2.contents.contents.add(crlcontent2);
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        //String stringValue = String.valueOf(j);
                                        content.type = 'text';
                                        content.text = loopCM.Name;
                                        content.weight = 'bold';
                                        content.size = 'md';
                                        crlcontent2.body.contents.add(content);
                                    }
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        content.type = 'box';
                                        content.layout = 'vertical';
                                        content.margin = 'lg';
                                        content.spacing = 'sm';
                                        content.contents = new list<LineMessages.contentsData>();
                                        crlcontent2.body.contents.add(content);
                                        {
                                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                            contentbase.type = 'box';
                                            contentbase.layout = 'baseline';
                                            contentbase.spacing = 'sm';
                                            contentbase.contents = new list<LineMessages.contentsData>();
                                            content.contents.add(contentbase);
                                            {
                                                LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                                contenttext.type = 'text';
                                                contenttext.text = loopCM.CarTypeDesc__c==null?loopCM.Name+'123':loopCM.CarTypeDesc__c;
                                                contenttext.wrap = true;
                                                contenttext.color = '#666666';
                                                contenttext.size = 'sm';
                                                contenttext.flex = 5;
                                                contentbase.contents.add(contenttext);
                                            }
                                        }
                                    }
                                    crlcontent2.footer=new LineMessages.containerData();
                                    crlcontent2.footer.type = 'box';
                                    crlcontent2.footer.layout = 'vertical';
                                    crlcontent2.footer.spacing = 'sm';
                                    crlcontent2.footer.contents= new list<LineMessages.contentsData>();
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        content.type = 'button';
                                        content.style = 'link';
                                        content.height = 'sm';
                                        content.action = new LineMessages.actionData();
                                        content.action.type = 'uri';
                                        content.action.label = '選擇';
                                        content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                                        crlcontent2.footer.contents.add(content);
                                    }
                                } 
                                {
                                    LineMessages.contentsData crlcontent2 = new LineMessages.contentsData();
                                    crlcontent2.type = 'bubble';
                                    crlcontent2.size = 'kilo';
                                    crlcontent2.hero = new LineMessages.containerData();
                                    crlcontent2.hero.type = 'image';
                                    crlcontent2.hero.url = loopCM.CarGenerationURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.CarGenerationURL__c;
                                    crlcontent2.hero.size = 'full';
                                    crlcontent2.hero.aspectRatio = '4:3';
                                    crlcontent2.hero.aspectMode = 'cover';
                                    crlcontent2.hero.action = new LineMessages.actionData();
                                    crlcontent2.hero.action.type = 'uri';
                                    crlcontent2.hero.action.uri = loopCM.WebsiteURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.WebsiteURL__c;
                                    crlcontent2.body = new LineMessages.containerData();
                                    crlcontent2.body.type='box';
                                    crlcontent2.body.layout='vertical';
                                    crlcontent2.body.contents= new list<LineMessages.contentsData>();
                                    tempMSG2.contents.contents.add(crlcontent2);
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        //String stringValue = String.valueOf(j);
                                        content.type = 'text';
                                        content.text = loopCM.Name;
                                        content.weight = 'bold';
                                        content.size = 'md';
                                        crlcontent2.body.contents.add(content);
                                    }
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        content.type = 'box';
                                        content.layout = 'vertical';
                                        content.margin = 'lg';
                                        content.spacing = 'sm';
                                        content.contents = new list<LineMessages.contentsData>();
                                        crlcontent2.body.contents.add(content);
                                        {
                                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                            contentbase.type = 'box';
                                            contentbase.layout = 'baseline';
                                            contentbase.spacing = 'sm';
                                            contentbase.contents = new list<LineMessages.contentsData>();
                                            content.contents.add(contentbase);
                                            {
                                                LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                                contenttext.type = 'text';
                                                contenttext.text = loopCM.CarTypeDesc__c==null?loopCM.Name+'123':loopCM.CarTypeDesc__c;
                                                contenttext.wrap = true;
                                                contenttext.color = '#666666';
                                                contenttext.size = 'sm';
                                                contenttext.flex = 5;
                                                contentbase.contents.add(contenttext);
                                            }
                                        }
                                    }
                                    crlcontent2.footer=new LineMessages.containerData();
                                    crlcontent2.footer.type = 'box';
                                    crlcontent2.footer.layout = 'vertical';
                                    crlcontent2.footer.spacing = 'sm';
                                    crlcontent2.footer.contents= new list<LineMessages.contentsData>();
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        content.type = 'button';
                                        content.style = 'link';
                                        content.height = 'sm';
                                        content.action = new LineMessages.actionData();
                                        content.action.type = 'uri';
                                        content.action.label = '選擇';
                                        content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                                        crlcontent2.footer.contents.add(content);
                                    }
                                }
                                {
                                    LineMessages.contentsData crlcontent2 = new LineMessages.contentsData();
                                    crlcontent2.type = 'bubble';
                                    crlcontent2.size = 'kilo';
                                    crlcontent2.hero = new LineMessages.containerData();
                                    crlcontent2.hero.type = 'image';
                                    crlcontent2.hero.url = loopCM.CarGenerationURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.CarGenerationURL__c;
                                    crlcontent2.hero.size = 'full';
                                    crlcontent2.hero.aspectRatio = '4:3';
                                    crlcontent2.hero.aspectMode = 'cover';
                                    crlcontent2.hero.action = new LineMessages.actionData();
                                    crlcontent2.hero.action.type = 'uri';
                                    crlcontent2.hero.action.uri = loopCM.WebsiteURL__c==null?'https://www.bmw.com.tw/zh/index.html':loopCM.WebsiteURL__c;
                                    crlcontent2.body = new LineMessages.containerData();
                                    crlcontent2.body.type='box';
                                    crlcontent2.body.layout='vertical';
                                    crlcontent2.body.contents= new list<LineMessages.contentsData>();
                                    tempMSG2.contents.contents.add(crlcontent2);
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        //String stringValue = String.valueOf(j);
                                        content.type = 'text';
                                        content.text = loopCM.Name;
                                        content.weight = 'bold';
                                        content.size = 'md';
                                        crlcontent2.body.contents.add(content);
                                    }
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        content.type = 'box';
                                        content.layout = 'vertical';
                                        content.margin = 'lg';
                                        content.spacing = 'sm';
                                        content.contents = new list<LineMessages.contentsData>();
                                        crlcontent2.body.contents.add(content);
                                        {
                                            LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                            contentbase.type = 'box';
                                            contentbase.layout = 'baseline';
                                            contentbase.spacing = 'sm';
                                            contentbase.contents = new list<LineMessages.contentsData>();
                                            content.contents.add(contentbase);
                                            {
                                                LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                                contenttext.type = 'text';
                                                contenttext.text = loopCM.CarTypeDesc__c==null?loopCM.Name+'123':loopCM.CarTypeDesc__c;
                                                contenttext.wrap = true;
                                                contenttext.color = '#666666';
                                                contenttext.size = 'sm';
                                                contenttext.flex = 5;
                                                contentbase.contents.add(contenttext);
                                            }
                                        }
                                    }
                                    crlcontent2.footer=new LineMessages.containerData();
                                    crlcontent2.footer.type = 'box';
                                    crlcontent2.footer.layout = 'vertical';
                                    crlcontent2.footer.spacing = 'sm';
                                    crlcontent2.footer.contents= new list<LineMessages.contentsData>();
                                    {
                                        LineMessages.contentsData content = new LineMessages.contentsData();
                                        content.type = 'button';
                                        content.style = 'link';
                                        content.height = 'sm';
                                        content.action = new LineMessages.actionData();
                                        content.action.type = 'uri';
                                        content.action.label = '選擇';
                                        content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                                        crlcontent2.footer.contents.add(content);
                                    }
                                }                                                            
                                k2.messages.add(tempMSG2);
                            }
                            k2.postback = '';
                            tempAccount1.keywords.add(k2);
                        }
                    }
                    k1.messages.add(tempMSG1);
                }
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                set<string> tempSet = new set<string>();
                keywordData k1 = new keywordData();
                k1.keyword = '【購車資訊-展示中心選單】';  
                k1.messages = new list<LineMessages>();      
                {                
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = '請先選擇一個區域';
                    k1.messages.add(tempMSG1);
                }
                LineMessages tempMSG1 = new LineMessages();
                tempMSG1.type = 'flex';
                tempMSG1.altText = '【購車資訊-展示中心選單】';
                tempMSG1.contents = new LineMessages.singleContentData();  
                tempMSG1.contents.type = 'carousel';
                tempMSG1.contents.contents= new list<LineMessages.contentsData>();     
                for(string loopstr: srMap.keyset())
                {
                    keywordData k2 = new keywordData();
                    k2.keyword = '【'+'展示中心選單-'+loopstr+'】';
                    k2.messages = new list<LineMessages>();
                    LineMessages tempMSG2 = new LineMessages();
                    tempMSG2.type = 'flex';
                    tempMSG2.altText = '展示中心選單-'+loopStr;
                    tempMSG2.contents = new LineMessages.singleContentData();  
                    tempMSG2.contents.type = 'carousel';
                    tempMSG2.contents.contents= new list<LineMessages.contentsData>();   
                    for(ShowRoom__c loopCM: srMap.get(loopstr))                      
                    {
                        LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                        crlcontent.type = 'bubble';
                        crlcontent.size = 'kilo';
                        crlcontent.hero = new LineMessages.containerData();
                        crlcontent.hero.type = 'image';
                        crlcontent.hero.url = loopCM.ShowroomAreaURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.ShowroomAreaURL__c;
                        crlcontent.hero.size = 'full';
                        crlcontent.hero.aspectRatio = '4:3';
                        crlcontent.hero.aspectMode = 'cover';
                        crlcontent.hero.action = new LineMessages.actionData();
                        crlcontent.hero.action.type = 'uri';
                        crlcontent.hero.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                        crlcontent.body = new LineMessages.containerData();
                        crlcontent.body.type='box';
                        crlcontent.body.layout='vertical';
                        crlcontent.body.contents= new list<LineMessages.contentsData>();
                        if(! tempSet.contains(loopStr))
                        {
                            tempMSG1.contents.contents.add(crlcontent);
                            tempSet.add(loopStr);
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                //String stringValue = String.valueOf(j);
                                content.type = 'text';
                                content.text = loopCM.Area__c;
                                content.weight = 'bold';
                                content.size = 'xl';
                                crlcontent.body.contents.add(content);
                            }
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'box';
                                content.layout = 'vertical';
                                content.margin = 'lg';
                                content.spacing = 'sm';
                                content.contents = new list<LineMessages.contentsData>();
                                crlcontent.body.contents.add(content);
                                {
                                    LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                    contentbase.type = 'box';
                                    contentbase.layout = 'baseline';
                                    contentbase.spacing = 'sm';
                                    contentbase.contents = new list<LineMessages.contentsData>();
                                    content.contents.add(contentbase);
                                    {
                                        LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                        contenttext.type = 'text';
                                        contenttext.text = loopCM.Area_Detail__c;
                                        contenttext.wrap = true;
                                        contenttext.color = '#666666';
                                        contenttext.size = 'sm';
                                        contenttext.flex = 5;
                                        contentbase.contents.add(contenttext);
                                    }
                                }
                            }
                            crlcontent.footer=new LineMessages.containerData();
                            crlcontent.footer.type = 'box';
                            crlcontent.footer.layout = 'vertical';
                            crlcontent.footer.spacing = 'sm';
                            crlcontent.footer.contents= new list<LineMessages.contentsData>();
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'message';
                                content.action.label = '選擇';
                                content.action.text = '【'+'展示中心選單-'+loopCM.Area__c+'】';
                                crlcontent.footer.contents.add(content);
                            }
                        }
                        /*
                        keywordData k2 = new keywordData();
                        k2.keyword = '【'+'展示中心選單-'+loopCM.Area__c+'】';
                        k2.messages = new list<LineMessages>();
                        */
                        {
                            {
                                LineMessages.contentsData crlcontent2 = new LineMessages.contentsData();
                                crlcontent2.type = 'bubble';
                                crlcontent2.size = 'kilo';
                                crlcontent2.hero = new LineMessages.containerData();
                                crlcontent2.hero.type = 'image';
                                crlcontent2.hero.url = loopCM.ShowroomURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.ShowroomURL__c;
                                crlcontent2.hero.size = 'full';
                                crlcontent2.hero.aspectRatio = '4:3';
                                crlcontent2.hero.aspectMode = 'cover';
                                crlcontent2.hero.action = new LineMessages.actionData();
                                crlcontent2.hero.action.type = 'uri';
                                crlcontent2.hero.action.uri ='https://www.bmw.com.tw/zh/index.html';
                                crlcontent2.body = new LineMessages.containerData();
                                crlcontent2.body.type='box';
                                crlcontent2.body.layout='vertical';
                                crlcontent2.body.contents= new list<LineMessages.contentsData>();
                                tempMSG2.contents.contents.add(crlcontent2);
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    //String stringValue = String.valueOf(j);
                                    content.type = 'text';
                                    content.text = loopCM.Name;
                                    content.weight = 'bold';
                                    content.size = 'xl';
                                    crlcontent2.body.contents.add(content);
                                }
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'box';
                                    content.layout = 'vertical';
                                    content.margin = 'lg';
                                    content.spacing = 'sm';
                                    content.contents = new list<LineMessages.contentsData>();
                                    crlcontent2.body.contents.add(content);
                                    {
                                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                        contentbase.type = 'box';
                                        contentbase.layout = 'vertical';
                                        contentbase.spacing = 'sm';
                                        contentbase.contents = new list<LineMessages.contentsData>();
                                        content.contents.add(contentbase);
                                        {
                                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                            contenttext.type = 'text';
                                            contenttext.text = '地址:'+loopCM.Showroom_address__c;
                                            contenttext.wrap = true;
                                            contenttext.color = '#666666';
                                            contenttext.size = 'sm';
                                            contenttext.flex = 5;
                                            contentbase.contents.add(contenttext);
                                        }
                                        {
                                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                            contenttext.type = 'text';
                                            contenttext.text = '連絡電話:'+loopCM.Showroom_phone__c;
                                            contenttext.wrap = true;
                                            contenttext.color = '#666666';
                                            contenttext.size = 'sm';
                                            contenttext.flex = 5;
                                            contentbase.contents.add(contenttext);
                                        }
                                    }
                                }
                                crlcontent2.footer=new LineMessages.containerData();
                                crlcontent2.footer.type = 'box';
                                crlcontent2.footer.layout = 'vertical';
                                crlcontent2.footer.spacing = 'sm';
                                crlcontent2.footer.contents= new list<LineMessages.contentsData>();
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'button';
                                    content.style = 'link';
                                    content.height = 'sm';
                                    content.action = new LineMessages.actionData();
                                    content.action.type = 'uri';
                                    content.action.label = '預約保養';
                                    content.action.uri = 'https://www.bmw.com.tw/zh/testdrive.html';
                                    crlcontent2.footer.contents.add(content);
                                }
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'button';
                                    content.style = 'link';
                                    content.height = 'sm';
                                    content.action = new LineMessages.actionData();
                                    content.action.type = 'uri';
                                    content.action.label = '撥打電話';
                                    content.action.uri = 'tel:'+loopCM.Showroom_phone__c;
                                    crlcontent2.footer.contents.add(content);
                                }
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'button';
                                    content.style = 'link';
                                    content.height = 'sm';
                                    content.action = new LineMessages.actionData();
                                    content.action.type = 'uri';
                                    content.action.label = '導航到這裡';
                                    String encodedString = 'https://www.google.com/maps/place/'+EncodingUtil.urlEncode(loopCM.Showroom_address__c,'UTF-8');
                                    system.debug('==luke: ' + encodedString);
                                    content.action.uri = encodedString;
                                    crlcontent2.footer.contents.add(content);
                                }
                            }                                                         
                        }                     
                    }
                    k2.messages.add(tempMSG2);  
                    k2.postback = '';
                    tempAccount1.keywords.add(k2);                                                         
                }
                k1.messages.add(tempMSG1);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            map<string, list<ServiceCenter__c>> scMap = new map<string, list<ServiceCenter__c>>();
            for(ServiceCenter__c loopServiceC: [
                select id, Name,
                    Line_Account__c, IsActive__c, Area__c, Area_Detail__c, Service_Address__c, ServiceCenter__c, 
                    ServiceCenterURL__c, ServiceCenterAreaURL__c, ServiceCenterPicShow__c, WebsiteURL__c, Service_Phone_Number__c
                from ServiceCenter__c
                where IsActive__c = true
                and Line_Account__c=:loopAccount.id
            ])
            {
                list<ServiceCenter__c> tempListlt = scMap.get(loopServiceC.Area__c);
                if(tempListlt==null)
                {
                    tempListlt = new list<ServiceCenter__c>();
                }
                tempListlt.add(loopServiceC);
                scMap.put(loopServiceC.Area__c, tempListlt);
            }
            {
                set<string> tempSet = new set<string>();
                keywordData k1 = new keywordData();
                k1.keyword = '【預約保養-服務中心選單】';  
                k1.messages = new list<LineMessages>();      
                {                
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'text';
                    tempMSG1.text = '請先選擇一個區域';
                    k1.messages.add(tempMSG1);
                }
                LineMessages tempMSG1 = new LineMessages();
                tempMSG1.type = 'flex';
                tempMSG1.altText = '【預約保養-服務中心選單】';
                tempMSG1.contents = new LineMessages.singleContentData();  
                tempMSG1.contents.type = 'carousel';
                tempMSG1.contents.contents= new list<LineMessages.contentsData>();     
                for(string loopstr: scMap.keyset())
                {
                    keywordData k2 = new keywordData();
                    k2.keyword = '【'+'服務中心選單-'+loopstr+'】';
                    k2.messages = new list<LineMessages>();
                    LineMessages tempMSG2 = new LineMessages();
                    tempMSG2.type = 'flex';
                    tempMSG2.altText = '服務中心選單-'+loopStr;
                    tempMSG2.contents = new LineMessages.singleContentData();  
                    tempMSG2.contents.type = 'carousel';
                    tempMSG2.contents.contents= new list<LineMessages.contentsData>();   
                    for(ServiceCenter__c loopCM: scMap.get(loopstr))                      
                    {
                        LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                        crlcontent.type = 'bubble';
                        crlcontent.size = 'kilo';
                        crlcontent.hero = new LineMessages.containerData();
                        crlcontent.hero.type = 'image';
                        crlcontent.hero.url = loopCM.ServiceCenterAreaURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.ServiceCenterAreaURL__c;
                        crlcontent.hero.size = 'full';
                        crlcontent.hero.aspectRatio = '4:3';
                        crlcontent.hero.aspectMode = 'cover';
                        crlcontent.hero.action = new LineMessages.actionData();
                        crlcontent.hero.action.type = 'uri';
                        crlcontent.hero.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                        crlcontent.body = new LineMessages.containerData();
                        crlcontent.body.type='box';
                        crlcontent.body.layout='vertical';
                        crlcontent.body.contents= new list<LineMessages.contentsData>();
                        if(! tempSet.contains(loopStr))
                        {
                            tempMSG1.contents.contents.add(crlcontent);
                            tempSet.add(loopStr);
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                //String stringValue = String.valueOf(j);
                                content.type = 'text';
                                content.text = loopCM.Area__c;
                                content.weight = 'bold';
                                content.size = 'xl';
                                crlcontent.body.contents.add(content);
                            }
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'box';
                                content.layout = 'vertical';
                                content.margin = 'lg';
                                content.spacing = 'sm';
                                content.contents = new list<LineMessages.contentsData>();
                                crlcontent.body.contents.add(content);
                                {
                                    LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                    contentbase.type = 'box';
                                    contentbase.layout = 'baseline';
                                    contentbase.spacing = 'sm';
                                    contentbase.contents = new list<LineMessages.contentsData>();
                                    content.contents.add(contentbase);
                                    {
                                        LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                        contenttext.type = 'text';
                                        contenttext.text = loopCM.Area_Detail__c;
                                        contenttext.wrap = true;
                                        contenttext.color = '#666666';
                                        contenttext.size = 'sm';
                                        contenttext.flex = 5;
                                        contentbase.contents.add(contenttext);
                                    }
                                }
                            }
                            crlcontent.footer=new LineMessages.containerData();
                            crlcontent.footer.type = 'box';
                            crlcontent.footer.layout = 'vertical';
                            crlcontent.footer.spacing = 'sm';
                            crlcontent.footer.contents= new list<LineMessages.contentsData>();
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'message';
                                content.action.label = '選擇';
                                content.action.text = '【'+'服務中心選單-'+loopCM.Area__c+'】';
                                crlcontent.footer.contents.add(content);
                            }
                        }               
                        {
                            {
                                LineMessages.contentsData crlcontent2 = new LineMessages.contentsData();
                                crlcontent2.type = 'bubble';
                                crlcontent2.size = 'kilo';
                                crlcontent2.hero = new LineMessages.containerData();
                                crlcontent2.hero.type = 'image';
                                crlcontent2.hero.url = loopCM.ServiceCenterURL__c==null?'https://pangerman--lead01--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0681s000000LXUu&operationContext=DELIVERY&page=1&d=/a/1s0000000G4f/sKjCln0CRWBVyvVLX5kj655MYoEgl1CoKTTxs9pfaoI&oid=00D1s0000008axb':loopCM.ServiceCenterURL__c;
                                crlcontent2.hero.size = 'full';
                                crlcontent2.hero.aspectRatio = '4:3';
                                crlcontent2.hero.aspectMode = 'cover';
                                crlcontent2.hero.action = new LineMessages.actionData();
                                crlcontent2.hero.action.type = 'uri';
                                crlcontent2.hero.action.uri ='https://www.bmw.com.tw/zh/index.html';
                                crlcontent2.body = new LineMessages.containerData();
                                crlcontent2.body.type='box';
                                crlcontent2.body.layout='vertical';
                                crlcontent2.body.contents= new list<LineMessages.contentsData>();
                                tempMSG2.contents.contents.add(crlcontent2);
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    //String stringValue = String.valueOf(j);
                                    content.type = 'text';
                                    content.text = loopCM.Name;
                                    content.weight = 'bold';
                                    content.size = 'xl';
                                    crlcontent2.body.contents.add(content);
                                }
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'box';
                                    content.layout = 'vertical';
                                    content.margin = 'lg';
                                    content.spacing = 'sm';
                                    content.contents = new list<LineMessages.contentsData>();
                                    crlcontent2.body.contents.add(content);
                                    {
                                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                                        contentbase.type = 'box';
                                        contentbase.layout = 'vertical';
                                        contentbase.spacing = 'sm';
                                        contentbase.contents = new list<LineMessages.contentsData>();
                                        content.contents.add(contentbase);
                                        {
                                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                            contenttext.type = 'text';
                                            contenttext.text = '地址:'+loopCM.Service_Address__c;
                                            contenttext.wrap = true;
                                            contenttext.color = '#666666';
                                            contenttext.size = 'sm';
                                            contenttext.flex = 5;
                                            contentbase.contents.add(contenttext);
                                        }
                                        {
                                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                                            contenttext.type = 'text';
                                            contenttext.text = '連絡電話:'+loopCM.Service_Phone_Number__c;
                                            contenttext.wrap = true;
                                            contenttext.color = '#666666';
                                            contenttext.size = 'sm';
                                            contenttext.flex = 5;
                                            contentbase.contents.add(contenttext);
                                        }
                                    }
                                }
                                crlcontent2.footer=new LineMessages.containerData();
                                crlcontent2.footer.type = 'box';
                                crlcontent2.footer.layout = 'vertical';
                                crlcontent2.footer.spacing = 'sm';
                                crlcontent2.footer.contents= new list<LineMessages.contentsData>();
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'button';
                                    content.style = 'link';
                                    content.height = 'sm';
                                    content.action = new LineMessages.actionData();
                                    content.action.type = 'uri';
                                    content.action.label = '預約保養';
                                    content.action.uri = 'https://www.bmw.com.tw/zh/testdrive.html';
                                    crlcontent2.footer.contents.add(content);
                                }
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'button';
                                    content.style = 'link';
                                    content.height = 'sm';
                                    content.action = new LineMessages.actionData();
                                    content.action.type = 'uri';
                                    content.action.label = '撥打電話';
                                    content.action.uri = 'tel:'+loopCM.Service_Phone_Number__c;
                                    crlcontent2.footer.contents.add(content);
                                }
                                {
                                    LineMessages.contentsData content = new LineMessages.contentsData();
                                    content.type = 'button';
                                    content.style = 'link';
                                    content.height = 'sm';
                                    content.action = new LineMessages.actionData();
                                    content.action.type = 'uri';
                                    content.action.label = '導航到這裡';
                                    String encodedString = 'https://www.google.com/maps/place/'+EncodingUtil.urlEncode(loopCM.Service_Address__c,'UTF-8');
                                    system.debug('==luke: ' + encodedString);
                                    content.action.uri = encodedString;
                                    crlcontent2.footer.contents.add(content);
                                }
                            }                                                         
                        }                     
                    }
                    k2.messages.add(tempMSG2);  
                    k2.postback = '';
                    tempAccount1.keywords.add(k2);                                                         
                }
                k1.messages.add(tempMSG1);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'text';
            tempMSG1.altText = '功能建置中';
            tempMSG1.text = '功能建置中';
            
            tempAccount1.defaultMessages.add(tempMSG1);
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
}