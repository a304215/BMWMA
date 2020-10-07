/*==============================================================
 * 呼叫Line 中台API。
 *
 *
 *==============================================================*/

public without sharing class Middle_API_Test2 {
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
                k1.keyword = '【購車資訊-BMW推薦】';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【購車資訊-BMW推薦】';
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
                        content.action.label = '我有男朋友 / 女朋友';
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
                    tempMSG.text = '歡迎來到BMW官方帳號，請繫上安全帶，我將帶著你一探BMW的網站';
                    k1.messages.add(tempMSG);
                }
                {
                    LineMessages tempMSG = new LineMessages();
                    tempMSG.type = 'template';
                    tempMSG.altText = '會員註冊';
                    tempMSG.template = new LineMessages.templateData();
                    tempMSG.template.type = 'confirm';
                    tempMSG.template.text = '如果你已經是車主，花兩分鐘加入會員，即可開始預約進廠、查看你的愛車相關資訊';
                    tempMSG.template.actions = new list<LineMessages.actionData>();
                    {
                        LineMessages.actionData action1 = new LineMessages.actionData();
                        action1.type = 'uri';
                        action1.label = '加入會員';
                        action1.uri = 'https://liff.line.me/1654408823-YpEOQlv0';
                        tempMSG.template.actions.add(action1);
                    }
                    {
                        LineMessages.actionData action1 = new LineMessages.actionData();
                        action1.type = 'uri';
                        action1.label = '我不是車主';
                        action1.uri = 'https://liff.line.me/1654408823-YpEOQlv0';
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
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                            contentbase.text = 'BMW 品牌新訊123';
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
                        content.action.uri = 'https://linecorp.com';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 當期活動';
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
                            contentbase.text = 'BMW 當期活動123';
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
                        content.action.label = '活動詳情';
                        content.action.uri = 'https://linecorp.com';
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
                        content.action.uri = 'https://linecorp.com';
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
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                            contentbase.text = 'BMW 新車資訊';
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
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW推薦';
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
                            contentbase.text = 'BMW推薦';
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
                        content.action.label = 'BMW 推薦';
                        content.action.text = '【購車資訊-BMW推薦】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = '購車優惠';
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
                            contentbase.text = '購車優惠';
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
                        content.action.label = '購車優惠';
                        content.action.uri = 'https://linecorp.com';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                            contentbase.text = 'BMW原廠認證中古車';
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
                        content.action.uri = 'https://linecorp.com';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = '展示中心據點';
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
                            contentbase.text = '展示中心據點';
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
                k1.keyword = '【預約試駕】';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【預約試駕】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 預約試駕';
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
                            contentbase.text = 'BMW 預約試駕123';
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
                        content.action.label = '車系選單';
                        content.action.text = '【預約試駕-車系選單】';
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
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 預約保養維修';
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
                            contentbase.text = 'BMW 預約保養維修123';
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
                        content.action.label = '預約保養系統';
                        content.action.text = '【預約保養系統】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW Care客戶服務';
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
                            contentbase.text = 'BMW Care客戶服務123';
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
                        content.action.label = '原廠售後服務';
                        content.action.uri = 'https://linecorp.com';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '原廠零件';
                        content.action.uri = 'https://linecorp.com';
                        crlcontent.footer.contents.add(content);
                    }
                    {
                        LineMessages.contentsData content = new LineMessages.contentsData();
                        content.type = 'button';
                        content.style = 'link';
                        content.height = 'sm';
                        content.action = new LineMessages.actionData();
                        content.action.type = 'uri';
                        content.action.label = '原廠加裝品系列';
                        content.action.uri = 'https://linecorp.com';
                        crlcontent.footer.contents.add(content);
                    }
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = '服務中心據點';
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
                            contentbase.text = '服務中心據點123';
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
                        content.action.label = '服務中心選單';
                        content.action.text = '【服務中心選單】';
                        crlcontent.footer.contents.add(content);
                    }
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【財務方案】';
                k1.messages = new list<LineMessages>();
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'flex';
                tempMSG.altText = '【財務方案】';
                tempMSG.contents = new LineMessages.singleContentData();
                tempMSG.contents.type = 'carousel';
                tempMSG.contents.contents = new list<LineMessages.contentsData>();
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 財務方案';
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
                            contentbase.text = 'BMW 財務方案123';
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
                        content.action.label = '財務試算';
                        content.action.uri = 'https://linecorp.com';
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
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 會員資料';
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
                            contentbase.text = 'BMW 會員資料123';
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
                        content.action.label = '會員資料';
                        content.action.text = '【會員資料】';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 車輛管理';
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
                            contentbase.text = 'BMW 車輛管理123';
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
                        content.action.label = '車輛管理';
                        content.action.text = '【車輛管理】';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                {
                    LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
                    crlcontent.type = 'bubble';
                    crlcontent.size = 'kilo';
                    crlcontent.hero = new LineMessages.containerData();
                    crlcontent.hero.type = 'image';
                    crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        content.text = 'BMW 優惠卷管理';
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
                            contentbase.text = 'BMW 優惠卷管理123';
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
                        content.action.label = '優惠卷管理';
                        content.action.text = '【優惠卷管理】';
                        crlcontent.footer.contents.add(content);
                    }                   
                }
                k1.messages.add(tempMSG);
                k1.postback = '';
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
                    Line_Account__c, IsActive__c, Area__c, ShowRoom__c, WebsiteURL__c
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
            for(string loopstr: srMap.keyset())
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【'+(loopstr==null?'購車資訊-展示中心選單':'展示中心選單-'+loopstr)+'】';  
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'flex';
                    tempMSG1.altText = (loopstr==null?'購車資訊-展示中心選單':'展示中心選單-'+loopstr);
                    tempMSG1.contents = new LineMessages.singleContentData();  
                    tempMSG1.contents.type = 'carousel';
                    tempMSG1.contents.contents= new list<LineMessages.contentsData>();
                    for(ShowRoom__c loopCM: srMap.get(loopstr))               
                    {
                        LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                        crlcontent.type = 'bubble';
                        crlcontent.size = 'kilo';
                        crlcontent.hero = new LineMessages.containerData();
                        crlcontent.hero.type = 'image';
                        crlcontent.hero.url = 'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635';
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
                        tempMSG1.contents.contents.add(crlcontent);
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
                                    contenttext.text = loopCM.Area__c+'123';
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
                        if(tempMSG1.altText =='購車資訊-展示中心選單')
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
                        else if(tempMSG1.altText =='展示中心選單-'+loopstr)
                        {
                            {
                                LineMessages.contentsData content = new LineMessages.contentsData();
                                content.type = 'button';
                                content.style = 'link';
                                content.height = 'sm';
                                content.action = new LineMessages.actionData();
                                content.action.type = 'uri';
                                content.action.label = '預約賞車';
                                content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
                                crlcontent.footer.contents.add(content);
                            }
                        }                      
                    }
                    k1.messages.add(tempMSG1);
                }
                k1.postback = '';
                tempAccount1.keywords.add(k1);
            }
            for(string loopstr: ltMap.keyset())
            {
                keywordData k1 = new keywordData();
                k1.keyword = '【'+(loopstr==null?'預約試駕-車系選單':'車系-'+loopstr)+'】';
                k1.messages = new list<LineMessages>();
                {
                    LineMessages tempMSG1 = new LineMessages();
                    tempMSG1.type = 'flex';
                    tempMSG1.altText = (loopstr==null?'預約試駕-車系選單':'車系-'+loopstr);
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
                        crlcontent.hero.url = loopCM.CarGenerationURL__c==null?'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635':loopCM.CarGenerationURL__c;
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
                        if(tempMSG1.altText =='預約試駕-車系選單')
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
                                content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
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
                                content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
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
                                content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
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
                                content.action.uri = 'https://www.bmw.com.tw/zh/index.html';
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
                        crlcontent.hero.url = loopCM.CarGenerationURL__c==null?'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635':loopCM.CarGenerationURL__c;
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
                                    crlcontent2.hero.url = loopCM.CarGenerationURL__c==null?'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635':loopCM.CarGenerationURL__c;
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
                                    crlcontent2.hero.url = loopCM.CarGenerationURL__c==null?'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635':loopCM.CarGenerationURL__c;
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
                                    crlcontent2.hero.url = loopCM.CarGenerationURL__c==null?'https://vignette.wikia.nocookie.net/logopedia/images/6/6d/BMW_1916.png/revision/latest/scale-to-width-down/1000?cb=20120821220635':loopCM.CarGenerationURL__c;
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
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'flex';
            tempMSG1.altText = '不好意思，我是貓貓';
            tempMSG1.contents = new LineMessages.singleContentData();  
            tempMSG1.contents.type = 'carousel';
            tempMSG1.contents.contents= new list<LineMessages.contentsData>();                       
            {
                LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                crlcontent.type = 'bubble';
                crlcontent.size = 'kilo';
                crlcontent.hero = new LineMessages.containerData();
                crlcontent.hero.type = 'image';
                crlcontent.hero.url = 'https://crazypetter.com.tw/wp-content/uploads/2019/07/BLOW-%E6%88%90%E9%95%B7%E5%8F%B2_190413_0911.jpg';
                crlcontent.hero.size = 'full';
                crlcontent.hero.aspectRatio = '4:3';
                crlcontent.hero.aspectMode = 'cover';
                crlcontent.hero.action = new LineMessages.actionData();
                crlcontent.hero.action.type = 'uri';
                crlcontent.hero.action.uri = 'http://linecorp.com/';
                crlcontent.body = new LineMessages.containerData();
                crlcontent.body.type='box';
                crlcontent.body.layout='vertical';
                crlcontent.body.contents= new list<LineMessages.contentsData>();
                tempMSG1.contents.contents.add(crlcontent);
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    //String stringValue = String.valueOf(j);
                    content.type = 'text';
                    content.text = '不好意思，我是貓貓';
                    content.weight = 'bold';
                    content.size = 'xl';
                    crlcontent.body.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'box';
                    content.layout = 'baseline';
                    content.margin = 'md';
                    content.contents = new list<LineMessages.contentsData>();
                    crlcontent.body.contents.add(content);
                    for(integer i=1;i<=4;i++)
                    {   
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '4.0';
                        contentbase.size = 'sm';
                        contentbase.color = '#999999';
                        contentbase.margin = 'md';
                        contentbase.flex = 0;
                        content.contents.add(contentbase);
                    }
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
                            contenttext.text = 'Place';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '功能還沒做到這。QQ';
                            contenttext.wrap = true;
                            contenttext.color = '#666666';
                            contenttext.size = 'sm';
                            contenttext.flex = 5;
                            contentbase.contents.add(contenttext);
                        }
                    }
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
                            contenttext.text = 'Time';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '不好意思。';
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
                for (integer i=1;i<=4;i++) {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    String stringValue = String.valueOf(i);
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'uri';
                    content.action.label = 'CALL'+stringValue;
                    content.action.uri = 'https://linecorp.com';
                    crlcontent.footer.contents.add(content);
                }           
            }
            {
                LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                crlcontent.type = 'bubble';
                crlcontent.size = 'kilo';
                crlcontent.hero = new LineMessages.containerData();
                crlcontent.hero.type = 'image';
                crlcontent.hero.url = 'https://crazypetter.com.tw/wp-content/uploads/2019/07/BLOW-%E6%88%90%E9%95%B7%E5%8F%B2_190413_0911.jpg';
                crlcontent.hero.size = 'full';
                crlcontent.hero.aspectRatio = '4:3';
                crlcontent.hero.aspectMode = 'cover';
                crlcontent.hero.action = new LineMessages.actionData();
                crlcontent.hero.action.type = 'uri';
                crlcontent.hero.action.uri = 'http://linecorp.com/';
                crlcontent.body = new LineMessages.containerData();
                crlcontent.body.type='box';
                crlcontent.body.layout='vertical';
                crlcontent.body.contents= new list<LineMessages.contentsData>();
                tempMSG1.contents.contents.add(crlcontent);
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    //String stringValue = String.valueOf(j);
                    content.type = 'text';
                    content.text = '不好意思，我是貓貓';
                    content.weight = 'bold';
                    content.size = 'xl';
                    crlcontent.body.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'box';
                    content.layout = 'baseline';
                    content.margin = 'md';
                    content.contents = new list<LineMessages.contentsData>();
                    crlcontent.body.contents.add(content);
                    for(integer i=1;i<=4;i++)
                    {   
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '4.0';
                        contentbase.size = 'sm';
                        contentbase.color = '#999999';
                        contentbase.margin = 'md';
                        contentbase.flex = 0;
                        content.contents.add(contentbase);
                    }
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
                            contenttext.text = 'Place';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '功能還沒做到這。QQ';
                            contenttext.wrap = true;
                            contenttext.color = '#666666';
                            contenttext.size = 'sm';
                            contenttext.flex = 5;
                            contentbase.contents.add(contenttext);
                        }
                    }
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
                            contenttext.text = 'Time';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '不好意思。';
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
                for (integer i=1;i<=4;i++) {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    String stringValue = String.valueOf(i);
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'uri';
                    content.action.label = 'CALL'+stringValue;
                    content.action.uri = 'https://linecorp.com';
                    crlcontent.footer.contents.add(content);
                }           
            }
            {
                LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                crlcontent.type = 'bubble';
                crlcontent.size = 'kilo';
                crlcontent.hero = new LineMessages.containerData();
                crlcontent.hero.type = 'image';
                crlcontent.hero.url = 'https://crazypetter.com.tw/wp-content/uploads/2019/07/BLOW-%E6%88%90%E9%95%B7%E5%8F%B2_190413_0911.jpg';
                crlcontent.hero.size = 'full';
                crlcontent.hero.aspectRatio = '4:3';
                crlcontent.hero.aspectMode = 'cover';
                crlcontent.hero.action = new LineMessages.actionData();
                crlcontent.hero.action.type = 'uri';
                crlcontent.hero.action.uri = 'http://linecorp.com/';
                crlcontent.body = new LineMessages.containerData();
                crlcontent.body.type='box';
                crlcontent.body.layout='vertical';
                crlcontent.body.contents= new list<LineMessages.contentsData>();
                tempMSG1.contents.contents.add(crlcontent);
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    //String stringValue = String.valueOf(j);
                    content.type = 'text';
                    content.text = '不好意思，我是貓貓';
                    content.weight = 'bold';
                    content.size = 'xl';
                    crlcontent.body.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'box';
                    content.layout = 'baseline';
                    content.margin = 'md';
                    content.contents = new list<LineMessages.contentsData>();
                    crlcontent.body.contents.add(content);
                    for(integer i=1;i<=4;i++)
                    {   
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '4.0';
                        contentbase.size = 'sm';
                        contentbase.color = '#999999';
                        contentbase.margin = 'md';
                        contentbase.flex = 0;
                        content.contents.add(contentbase);
                    }
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
                            contenttext.text = 'Place';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '功能還沒做到這。QQ';
                            contenttext.wrap = true;
                            contenttext.color = '#666666';
                            contenttext.size = 'sm';
                            contenttext.flex = 5;
                            contentbase.contents.add(contenttext);
                        }
                    }
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
                            contenttext.text = 'Time';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '不好意思。';
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
                for (integer i=1;i<=4;i++) {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    String stringValue = String.valueOf(i);
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'uri';
                    content.action.label = 'CALL'+stringValue;
                    content.action.uri = 'https://linecorp.com';
                    crlcontent.footer.contents.add(content);
                }           
            }
            {
                LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                crlcontent.type = 'bubble';
                crlcontent.size = 'kilo';
                crlcontent.hero = new LineMessages.containerData();
                crlcontent.hero.type = 'image';
                crlcontent.hero.url = 'https://crazypetter.com.tw/wp-content/uploads/2019/07/BLOW-%E6%88%90%E9%95%B7%E5%8F%B2_190413_0911.jpg';
                crlcontent.hero.size = 'full';
                crlcontent.hero.aspectRatio = '4:3';
                crlcontent.hero.aspectMode = 'cover';
                crlcontent.hero.action = new LineMessages.actionData();
                crlcontent.hero.action.type = 'uri';
                crlcontent.hero.action.uri = 'http://linecorp.com/';
                crlcontent.body = new LineMessages.containerData();
                crlcontent.body.type='box';
                crlcontent.body.layout='vertical';
                crlcontent.body.contents= new list<LineMessages.contentsData>();
                tempMSG1.contents.contents.add(crlcontent);
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    //String stringValue = String.valueOf(j);
                    content.type = 'text';
                    content.text = '不好意思，我是貓貓';
                    content.weight = 'bold';
                    content.size = 'xl';
                    crlcontent.body.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'box';
                    content.layout = 'baseline';
                    content.margin = 'md';
                    content.contents = new list<LineMessages.contentsData>();
                    crlcontent.body.contents.add(content);
                    for(integer i=1;i<=4;i++)
                    {   
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '4.0';
                        contentbase.size = 'sm';
                        contentbase.color = '#999999';
                        contentbase.margin = 'md';
                        contentbase.flex = 0;
                        content.contents.add(contentbase);
                    }
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
                            contenttext.text = 'Place';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '功能還沒做到這。QQ';
                            contenttext.wrap = true;
                            contenttext.color = '#666666';
                            contenttext.size = 'sm';
                            contenttext.flex = 5;
                            contentbase.contents.add(contenttext);
                        }
                    }
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
                            contenttext.text = 'Time';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '不好意思。';
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
                for (integer i=1;i<=4;i++) {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    String stringValue = String.valueOf(i);
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'uri';
                    content.action.label = 'CALL'+stringValue;
                    content.action.uri = 'https://linecorp.com';
                    crlcontent.footer.contents.add(content);
                }           
            }
            {
                LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                crlcontent.type = 'bubble';
                crlcontent.size = 'kilo';
                crlcontent.hero = new LineMessages.containerData();
                crlcontent.hero.type = 'image';
                crlcontent.hero.url = 'https://crazypetter.com.tw/wp-content/uploads/2019/07/BLOW-%E6%88%90%E9%95%B7%E5%8F%B2_190413_0911.jpg';
                crlcontent.hero.size = 'full';
                crlcontent.hero.aspectRatio = '4:3';
                crlcontent.hero.aspectMode = 'cover';
                crlcontent.hero.action = new LineMessages.actionData();
                crlcontent.hero.action.type = 'uri';
                crlcontent.hero.action.uri = 'http://linecorp.com/';
                crlcontent.body = new LineMessages.containerData();
                crlcontent.body.type='box';
                crlcontent.body.layout='vertical';
                crlcontent.body.contents= new list<LineMessages.contentsData>();
                tempMSG1.contents.contents.add(crlcontent);
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    //String stringValue = String.valueOf(j);
                    content.type = 'text';
                    content.text = '不好意思，我是貓貓';
                    content.weight = 'bold';
                    content.size = 'xl';
                    crlcontent.body.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'box';
                    content.layout = 'baseline';
                    content.margin = 'md';
                    content.contents = new list<LineMessages.contentsData>();
                    crlcontent.body.contents.add(content);
                    for(integer i=1;i<=4;i++)
                    {   
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'icon';
                        contentbase.size = 'sm';
                        contentbase.url = 'https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png';
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '4.0';
                        contentbase.size = 'sm';
                        contentbase.color = '#999999';
                        contentbase.margin = 'md';
                        contentbase.flex = 0;
                        content.contents.add(contentbase);
                    }
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
                            contenttext.text = 'Place';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '功能還沒做到這。QQ';
                            contenttext.wrap = true;
                            contenttext.color = '#666666';
                            contenttext.size = 'sm';
                            contenttext.flex = 5;
                            contentbase.contents.add(contenttext);
                        }
                    }
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
                            contenttext.text = 'Time';
                            contenttext.color = '#aaaaaa';
                            contenttext.size = 'sm';
                            contenttext.flex = 1;
                            contentbase.contents.add(contenttext);
                        }
                        {
                            LineMessages.contentsData contenttext = new LineMessages.contentsData();
                            contenttext.type = 'text';
                            contenttext.text = '不好意思。';
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
                for (integer i=1;i<=4;i++) {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    String stringValue = String.valueOf(i);
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'uri';
                    content.action.label = 'CALL'+stringValue;
                    content.action.uri = 'https://linecorp.com';
                    crlcontent.footer.contents.add(content);
                }           
            }
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