/*==============================================================
 * 接收Line 中台API。
 * Line Messages 獨立出來。
 *
 *==============================================================*/
@RestResource(urlMapping='/Middle_REST/*') 
global without sharing class Middle_REST 
{
    @HttpPost 
    global static void doPost() 
    {
        //設定RestRequest
        RestRequest restReq = RestContext.request;
        string restURL = restReq.requestURI;
        system.debug(restURL);
        string lineChannel = restURL.substring(restURL.lastIndexOf('/')+1);
        system.debug(lineChannel);

        //後台API-3 Postback action
        if(restURL.startsWith('/Middle_REST/line_post/'))
        {
            RestResponse res = Middle_REST.actionType(restReq);
        }
        //其他URL。
        else 
        {
            requestData tmpDataModel = (requestData)System.JSON.deserialize(restReq.requestBody.toString(), requestData.class);
            outputResponse queryData = Middle_REST.defaultAction(tmpDataModel);
            RestResponse res = Restcontext.response;
            res.responseBody = Blob.valueOf(queryData.toJSON());
            system.debug(queryData.toJSON());
        }
        
    }

    //response的data
    public class outputResponse
    {
        public string code {get; set;}
        public string tempDesc {get; set;}
        //獨立出來LineMessages
        public list<LineMessages> data {get; set;}
        public outputResponse(){}
        
        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(false);
            g.writeStartObject();
            g.writeStringField('code', code);
            g.writeStringField('desc', tempDesc);
            g.writeFieldName('data');
            g.writeStartObject();
            if(data.size()>0)
            {
                g.writeFieldName('messages');
                g.writeStartArray();
                for(LineMessages loopMSG: data)
                {
                    loopMSG.toJSON(g);
                }
                g.writeEndArray();
            }
            g.writeEndObject();
            g.writeEndObject();
            return g.getAsString();
        }
    }

    public class requestData
    {
        public string postback {get; set;}
        public string UDID {get; set;}
        public requestData(){}
    }

    public static RestResponse actionType(RestRequest InputRestReq)
    {
        string channelId = InputRestReq.requestURI.substringAfterLast('/');
        requestData tmpDataModel = (requestData)System.JSON.deserialize(InputRestReq.requestBody.toString(), requestData.class);
        system.debug('UDID:'+tmpDataModel.UDID);
        system.debug('postback:'+tmpDataModel.postback);
        outputResponse queryData;
        if(! string.isBlank(tmpDataModel.postback))
        {
            if(tmpDataModel.postback.startsWith('action=view'))
            {
                queryData = posAction1(tmpDataModel);
            }
            else if(tmpDataModel.postback.startsWith('type=1_'))
            {
                queryData = posAction1(tmpDataModel);
            }
            else if(tmpDataModel.postback.startsWith('type=2_'))
            {
                queryData = posAction2(tmpDataModel);
            }
            else if(tmpDataModel.postback.startsWith('type=3_'))
            {
                queryData = posAction3(tmpDataModel);
            }
            else if(tmpDataModel.postback.startsWith('type=4_'))
            {
                queryData = posAction4(tmpDataModel);
            }
            else if(tmpDataModel.postback.startsWith('action=_1'))
            {
                queryData = posAction4(tmpDataModel);
            }
            else if(tmpDataModel.postback.startsWith('action=q1'))
            {
                queryData = posActionQ1(tmpDataModel, channelId);
            }
            else if(tmpDataModel.postback.startsWith('action=q2'))
            {
                queryData = posActionQ2(tmpDataModel, channelId);
            }
            else if(tmpDataModel.postback.startsWith('action=q3'))
            {
                queryData = posActionQ3(tmpDataModel, channelId);
            }
            else if(tmpDataModel.postback.startsWith('action=checkMember'))
            {
                queryData = posActionCheckMember(tmpDataModel, channelId);
            }
            else if(tmpDataModel.postback.startsWith('action=checkTestDrive'))
            {
                queryData = posActionCheckTestDrive(tmpDataModel, channelId);
            }
            else if(tmpDataModel.postback.startsWith('action=checkCampaign'))
            {
                queryData = posActionCheckCampaign(tmpDataModel, channelId);
            }
            else 
            {
                queryData =  new outputResponse();
                queryData.code = '-1';
                queryData.tempDesc = '動作無效。'+tmpDataModel.postback;
                queryData.data = new list<LineMessages>();
            }
        }
        else 
        {
            queryData =  new outputResponse();
            queryData.code = '-1';
            queryData.tempDesc = '動作無效。';
            queryData.data = new list<LineMessages>();
        }
        
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    public static outputResponse posActionQ1(requestData inReq, string inputChannelId)
    {
        list<Line_Account__c> laList = [select id from Line_Account__c where ChannelId__c =: inputChannelId];
        if(laList.size() > 0)
        {
            Line_User__c tempUser = new Line_User__c();
            tempUser.Line_Account__c = laList[0].id;
            tempUser.LineUniqueId__c = laList[0].id + '_' + inReq.UDID;
            tempUser.UDID__c = inReq.UDID;
            tempUser.Q1__c = inReq.postback.substringAfterLast('answer=');
            upsert tempUser LineUniqueId__c;
        }

        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        {
            LineMessages tempMSG = new LineMessages();
            tempMSG.type = 'flex';
            tempMSG.altText = '二、你最注重的車輛特質是?';
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
                    content.text = '二、你最注重的車輛特質是?';
                    content.wrap = true;
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
                    content.action.label = '就是我時尚搭配';
                    content.action.text = '就是我時尚搭配';
                    content.action.data = 'action=q2&answer=就是我時尚搭配';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '乘坐與載物的大空間';
                    content.action.text = '乘坐與載物的大空間';
                    content.action.data = 'action=q2&answer=乘坐與載物的大空間';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '乘客的安全';
                    content.action.text = '乘客的安全';
                    content.action.data = 'action=q2&answer=乘客的安全';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '駕馭的速度感';
                    content.action.text = '駕馭的速度感';
                    content.action.data = 'action=q2&answer=駕馭的速度感';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '高質感的奢華設計';
                    content.action.text = '高質感的奢華設計';
                    content.action.data = 'action=q2&answer=高質感的奢華設計';
                    crlcontent.footer.contents.add(content);
                }
            }
            returnResponse.data.add(tempMSG);
        }

        return returnResponse;
    }

    public static outputResponse posActionQ2(requestData inReq, string inputChannelId)
    {
        list<Line_Account__c> laList = [select id from Line_Account__c where ChannelId__c =: inputChannelId];
        if(laList.size() > 0)
        {
            Line_User__c tempUser = new Line_User__c();
            tempUser.Line_Account__c = laList[0].id;
            tempUser.LineUniqueId__c = laList[0].id + '_' + inReq.UDID;
            tempUser.UDID__c = inReq.UDID;
            tempUser.Q2__c = inReq.postback.substringAfterLast('answer=');
            upsert tempUser LineUniqueId__c;
        }

        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        {
            LineMessages tempMSG = new LineMessages();
            tempMSG.type = 'flex';
            tempMSG.altText = '三、你比較喜歡哪一種車款類型呢?';
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
                    content.text = '三、你比較喜歡哪一種車款類型呢?';
                    content.wrap = true;
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
                    content.action.label = '潮流小車';
                    content.action.text = '潮流小車';
                    content.action.data = 'action=q3&answer=潮流小車';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '中型豪華房車/休旅車';
                    content.action.text = '中型豪華房車/休旅車';
                    content.action.data = 'action=q3&answer=中型豪華房車/休旅車';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '大型豪華房車/休旅車';
                    content.action.text = '大型豪華房車/休旅車';
                    content.action.data = 'action=q3&answer=大型豪華房車/休旅車';
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'postback';
                    content.action.label = '性能跑車';
                    content.action.text = '性能跑車';
                    content.action.data = 'action=q3&answer=性能跑車';
                    crlcontent.footer.contents.add(content);
                }
            }
            returnResponse.data.add(tempMSG);
        }

        return returnResponse;
    }

    public static outputResponse posActionQ3(requestData inReq, string inputChannelId)
    {
        list<Line_Account__c> laList = [select id from Line_Account__c where ChannelId__c =: inputChannelId];
        
        if(laList.size() > 0)
        {
            Line_User__c tempUser = new Line_User__c();
            tempUser.Line_Account__c = laList[0].id;
            tempUser.LineUniqueId__c = laList[0].id + '_' + inReq.UDID;
            tempUser.UDID__c = inReq.UDID;
            tempUser.Q3__c = inReq.postback.substringAfterLast('answer=');
            upsert tempUser LineUniqueId__c;
        }

        list<Line_User__c> theUserList = [
            select q1__c, q2__c, q3__c 
            from line_user__c 
            where Line_Account__c =: laList[0].id
            and UDID__c=: inReq.UDID
        ];
        string theAnswerString = '';
        
        if(theUserList.size() > 0)
        {
            theAnswerString=theUserList[0].q1__c+theUserList[0].q2__c+theUserList[0].q3__c;
        }

        map<string, list<string>> stringMap = new map<string, list<string>>();
        {
            list<string> tempList = new list<string>();
            tempList.add('BMW 3系列');
            tempList.add('BMW 3系列 Touring');
            stringMap.put('我有三個以上的小孩乘客的安全中型豪華房車/休旅車', tempList);
        }
        {
            list<string> tempList = new list<string>();
            tempList.add('BMW 5系列');
            tempList.add('BMW X5');
            tempList.add('BMW X6');
            stringMap.put('我有兩個以上的大小孩乘坐與載物的大空間大型豪華房車/休旅車', tempList);
        }
        {
            list<string> tempList = new list<string>();
            tempList.add('BMW 4系列 Coupé');
            tempList.add('BMW 6系列 Gran Tourism');
            tempList.add('BMW X4');
            tempList.add('BMW X6');
            stringMap.put('我是單身貴族就是我時尚搭配大型豪華房車/休旅車', tempList);
        }

        list<string> tempList = stringMap.get(theAnswerString);
        list<CarModels__c> recommandList =  new list<CarModels__c>();



        if(tempList == null)
        {
            list<CarModels__c> tempCarList =  [
                select id, Name,
                    LineCarGeneration__c, LineCarType__c, CarGenerationURL__c, CarGenerationShow__c, CarTypeURL__c, CarTypeShow__c, 
                    WebsiteURL__c, IsActive__c, Line_Account__c, CarGenerationDesc__c, CarTypeDesc__c, 
                    StartTime__c, EndTime__c, 
                    SellingGeneration__c, CarCategory__c, Parent_Car_Category__r.Name, TestDriveURL__c, CarDataURL__c, CarInformationURL__c, CustomBMW_URL__c
                from CarModels__c
                where IsActive__c = true
                and Line_Account__c=:laList[0].id
                and ButtomLayer__c = true
                order by Count__c
            ];

            set<integer> chooseSet = new set<integer>();
            for(integer i=0; i < 3; i++)
            {
                
                Integer randomNumber = Integer.valueof((Math.random() * tempCarList.size()));
                if(! chooseSet.contains(randomNumber))
                {
                    recommandList.add(tempCarList[randomNumber]);
                }
            }
        }
        else
        {
            for(CarModels__c loopCarM: [
                select id, Name,
                    LineCarGeneration__c, LineCarType__c, CarGenerationURL__c, CarGenerationShow__c, CarTypeURL__c, CarTypeShow__c, 
                    WebsiteURL__c, IsActive__c, Line_Account__c, CarGenerationDesc__c, CarTypeDesc__c, 
                    StartTime__c, EndTime__c, 
                    SellingGeneration__c, CarCategory__c, Parent_Car_Category__r.Name, TestDriveURL__c, CarDataURL__c, CarInformationURL__c, CustomBMW_URL__c
                from CarModels__c
                where IsActive__c = true
                and Line_Account__c=:laList[0].id
                and name in: tempList
                and ButtomLayer__c = true
            ])
            {
                recommandList.add(loopCarM);
            }
        }


        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        {
            LineMessages tempMSG = new LineMessages();
            tempMSG.type = 'text';
            tempMSG.altText = '結果出爐了，希望你會喜歡我的推薦 👊🏼';
            tempMSG.text = '結果出爐了，希望你會喜歡我的推薦 👊🏼';
            returnResponse.data.add(tempMSG);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'flex';
            tempMSG1.altText = '推薦車款';
            tempMSG1.contents = new LineMessages.singleContentData();  
            tempMSG1.contents.type = 'carousel';
            tempMSG1.contents.contents= new list<LineMessages.contentsData>();
            for(CarModels__c loopCM: recommandList)               
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
            //最後一張。
            {
                LineMessages.contentsData crlcontent = new LineMessages.contentsData();
                crlcontent.type = 'bubble';
                crlcontent.size = 'kilo';
                crlcontent.hero = new LineMessages.containerData();
                crlcontent.hero.type = 'image';
                crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LfuCAAS.JPG?generation=1600070024596834&alt=media';
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
                    content.text = '還想看其他的車嗎？';
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
                            contenttext.text = '點擊「再試一次」，我們再來一次吧';
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
                    content.action.label = '再試一次';
                    content.action.text = '【購車資訊-BMW為你推薦】';
                    crlcontent.footer.contents.add(content);
                }
            }
            returnResponse.data.add(tempMSG1);
        }

        return returnResponse;
    }

    public static outputResponse posActionCheckMember(requestData inReq, string inputChannelId)
    {
        boolean isLinked = false;
        list<Line_Account__c> laList = [select id from Line_Account__c where ChannelId__c =: inputChannelId];

        list<Line_User__c> theUserList = [
            select CustomerUser__c
            from line_user__c 
            where Line_Account__c =: laList[0].id
            and UDID__c=: inReq.UDID
        ];
        string theAnswerString = '';
        
        if(theUserList.size() > 0)
        {
            isLinked = (theUserList[0].CustomerUser__c!=null);
        }
        

        outputResponse returnResponse = new outputResponse();
        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        if(isLinked)
        {
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
                crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LYiTAAW.JPG?generation=1599617498600010&alt=media';
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
                crlcontent.hero.url = 'https://storage.googleapis.com/download/storage/v1/b/pgmline/o/keyword%2F0691s000000LYiYAAW.PNG?generation=1599617633764720&alt=media';
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
                    content.text = '活動QR code管理';
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
                        contentbase.text = '查看你擁有的活動QR';
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
                    content.action.label = '選擇';
                    content.action.text = '【活動報名紀錄】';
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
            {
                LineMessages tempMSG1 = new LineMessages();
                tempMSG1.type = 'text';
                tempMSG1.text = '會員的大小事，就是我最關心的事';
                returnResponse.data.add(tempMSG1);
            }
            returnResponse.data.add(tempMSG);
        }
        else
        {
            {
                LineMessages tempMSG = new LineMessages();
                tempMSG.type = 'text';
                tempMSG.text = '你還沒有加入BMW官方帳號的會員喔';
                returnResponse.data.add(tempMSG);
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
                returnResponse.data.add(tempMSG);
            }
        }
        

        return returnResponse;
    }

    public static outputResponse posActionCheckTestDrive(requestData inReq, string inputChannelId)
    {
        outputResponse returnResponse = new outputResponse();
        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();

        list<Line_Account__c> laList = [select id from Line_Account__c where ChannelId__c =: inputChannelId];
        list<TestDriveReservation__c> driveList = [
            select id, StartTime__c, EndTime__c, TestCar__c, Brand__c, TestDriveStatus__c,
            TestCarBranch__c, Owner.Name
            from TestDriveReservation__c 
            where LineKey__c =: inReq.UDID
            and LineKey__c != null
            and EndTime__c >=: system.now()
            order by StartTime__c
            limit 10
        ];
        
        if(driveList.size() > 0)
        {
            {
                LineMessages tempMSG1 = new LineMessages();
                tempMSG1.type = 'text';
                tempMSG1.text = '你已經有'+driveList.size()+'筆預約試駕紀錄，細節如下：';
                returnResponse.data.add(tempMSG1);
            }
            LineMessages tempMSG = new LineMessages();
            tempMSG.type = 'flex';
            tempMSG.altText = '預約試駕';
            tempMSG.contents = new LineMessages.singleContentData();
            tempMSG.contents.type = 'carousel';
            tempMSG.contents.contents = new list<LineMessages.contentsData>();
            for(TestDriveReservation__c loopDrive: driveList)
            {
                list<ShowRoom__c> showL = [select name,Showroom_phone__c from ShowRoom__c where ShowRoom__c=:loopDrive.TestCarBranch__c];

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
                    content.type = 'box';
                    content.layout = 'vertical';
                    content.margin = 'lg';
                    content.spacing = 'sm';
                    content.contents = new list<LineMessages.contentsData>();
                    crlcontent.body.contents.add(content);
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        if(showL.size() >0)
                        {
                            contentbase.text = '預約地點：'+showL[0].Name;
                        }
                        else
                        {
                            contentbase.text = '預約地點：'+loopDrive.TestCarBranch__c;
                        }
                        
                        contentbase.color = '#666666';
                        contentbase.size = 'sm';
                        contentbase.wrap = true;
                        contentbase.flex = 1;
                        content.contents.add(contentbase);
                    }
                    {
                        string dayWeek = loopDrive.StartTime__c.format('EEEE');
                        string dayWeekChinese = '';
                        switch on dayWeek
                        {
                            when 'Sunday'{dayWeekChinese = '日';} 
                            when 'Monday'{dayWeekChinese = '一';} 
                            when 'Tuesday'{dayWeekChinese = '二';} 
                            when 'Wednesday'{dayWeekChinese = '三';} 
                            when 'Thursday'{dayWeekChinese = '四';} 
                            when 'Friday'{dayWeekChinese = '五';} 
                            when 'Saturday'{dayWeekChinese = '六';} 
                        }
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '預約日期：'+loopDrive.StartTime__c.format('MM/dd')+'('+dayWeekChinese+')';
                        contentbase.color = '#666666';
                        contentbase.size = 'sm';
                        contentbase.wrap = true;
                        contentbase.flex = 1;
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '預約時間：'+loopDrive.StartTime__c.format('HH:mm');
                        contentbase.color = '#666666';
                        contentbase.size = 'sm';
                        contentbase.wrap = true;
                        contentbase.flex = 1;
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '銷售顧問：'+loopDrive.Owner.Name;
                        contentbase.color = '#666666';
                        contentbase.size = 'sm';
                        contentbase.wrap = true;
                        contentbase.flex = 1;
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '\n當天請記得攜帶你的駕照';
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
                    if(showL.size() >0)
                    {
                        content.action.type = 'uri';
                        content.action.label = '聯絡專人修改預約';
                        content.action.uri = 'tel:'+showL[0].Showroom_phone__c;
                    }
                    else
                    {
                        content.action.type = 'message';
                        content.action.label = '聯絡專人修改預約';
                        content.action.text = '聯絡專人修改預約';
                    }
                    crlcontent.footer.contents.add(content);
                }
                {
                    LineMessages.contentsData content = new LineMessages.contentsData();
                    content.type = 'button';
                    content.style = 'link';
                    content.height = 'sm';
                    content.action = new LineMessages.actionData();
                    content.action.type = 'message';
                    content.action.label = '再預約一次';
                    content.action.text = '【預約試駕】';
                    crlcontent.footer.contents.add(content);
                }
                
            }
            returnResponse.data.add(tempMSG);
        }
        else
        {
            for(LineMessages loopMSG: queyrMessage('【預約試駕】', laList[0].id))
            {
                returnResponse.data.add(loopMSG);
            }
            
        }
        return returnResponse;
    }

    public static outputResponse posActionCheckCampaign(requestData inReq, string inputChannelId)
    {
        outputResponse returnResponse = new outputResponse();
        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();

        list<Line_Account__c> laList = [select id from Line_Account__c where ChannelId__c =: inputChannelId];
        list<CampaignMember> memberList = [
            select id, Campaign.Name, Campaign.StartDate, QRcodePage__c, Campaign.Line_CampaignLocation__c
            from CampaignMember 
            where HasResponded = true
            and LeadId != null
            and Lead.LINE_Key__c =: inReq.UDID
            and Campaign.Line_Account__c =: laList[0].id
            and Campaign.EndDate >= today
            and Registered__c = false
            order by Campaign.StartDate
            limit 10
        ];
        
        if(memberList.size() > 0)
        {
            {
                LineMessages tempMSG1 = new LineMessages();
                tempMSG1.type = 'text';
                tempMSG1.text = '你所報名的活動如下：';
                returnResponse.data.add(tempMSG1);
            }
            LineMessages tempMSG = new LineMessages();
            tempMSG.type = 'flex';
            tempMSG.altText = '活動報名紀錄';
            tempMSG.contents = new LineMessages.singleContentData();
            tempMSG.contents.type = 'carousel';
            tempMSG.contents.contents = new list<LineMessages.contentsData>();
            for(CampaignMember loopMember: memberList)
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
                    content.text = loopMember.Campaign.Name;
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
                        datetime campaignTime = DateTime.newInstance(
                            loopMember.Campaign.StartDate.year(), 
                            loopMember.Campaign.StartDate.month(), 
                            loopMember.Campaign.StartDate.day()
                        );

                        string dayWeek = campaignTime.format('EEEE');
                        string dayWeekChinese = '';
                        switch on dayWeek
                        {
                            when 'Sunday'{dayWeekChinese = '日';} 
                            when 'Monday'{dayWeekChinese = '一';} 
                            when 'Tuesday'{dayWeekChinese = '二';} 
                            when 'Wednesday'{dayWeekChinese = '三';} 
                            when 'Thursday'{dayWeekChinese = '四';} 
                            when 'Friday'{dayWeekChinese = '五';} 
                            when 'Saturday'{dayWeekChinese = '六';} 
                        }
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '活動日期：'+campaignTime.format('MM/dd')+'('+dayWeekChinese+')';
                        contentbase.color = '#666666';
                        contentbase.size = 'sm';
                        contentbase.wrap = true;
                        contentbase.flex = 1;
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '活動地點：'+loopMember.Campaign.Line_CampaignLocation__c;
                        contentbase.color = '#666666';
                        contentbase.size = 'sm';
                        contentbase.wrap = true;
                        contentbase.flex = 1;
                        content.contents.add(contentbase);
                    }
                    {
                        LineMessages.contentsData contentbase = new LineMessages.contentsData();
                        contentbase.type = 'text';
                        contentbase.text = '\n當天請記得攜帶你的QR Code';
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
                    content.action.label = 'QR Code';
                    content.action.uri = loopMember.QRcodePage__c;
                    crlcontent.footer.contents.add(content);
                }
                
            }
            returnResponse.data.add(tempMSG);
        }
        else
        {
            {
                LineMessages tempMSG1 = new LineMessages();
                tempMSG1.type = 'text';
                tempMSG1.text = '目前尚無報名活動紀錄';
                returnResponse.data.add(tempMSG1);
            }
            
        }
        return returnResponse;
    }

    public static outputResponse posAction1(requestData inReq)
    {
        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'text';
            tempMSG1.text = 'text1';
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'image';
            tempMSG1.originalContentUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
            tempMSG1.previewImageUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'sticker';
            tempMSG1.packageId = '11537';
            tempMSG1.stickerId = '52002735';
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'imagemap';
            tempMSG1.baseUrl = 'https://lineorg-dev-ed--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0682x000000W2jl&operationContext=DELIVERY&page=1&d=/a/2x000000PGn7/DR_ghIBQb9f0knRdwKhB3jIGTkQRjFTI6M2CqauMMfU&oid=00D2x000003up1M';
            tempMSG1.altText = 'testImageMap';
            {
                LineMessages.imageAction action1 = new LineMessages.imageAction();
                action1.type='message';
                action1.text='TEST123';
                action1.area = new LineMessages.areaData();
                action1.area.x=0;
                action1.area.y=0;
                action1.area.width=1040;
                action1.area.height=1040;
                tempMSG1.actions.add(action1);
            }
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'template';
            tempMSG1.altText = 'this is a Image CAROUSEL template';
            tempMSG1.template = new LineMessages.templateData();
            tempMSG1.template.type = 'image_carousel';
            tempMSG1.template.columns = new list<LineMessages.columnData>();
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'postback';
                column1.action.label = 'type1';
                column1.action.data = 'type=1_&itemid=luke5566';
                tempMSG1.template.columns.add(column1);
            }
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'postback';
                column1.action.label = 'type2';
                column1.action.data = 'type=2_&itemid=luke5566';
                tempMSG1.template.columns.add(column1);
            }
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'postback';
                column1.action.label = 'type3';
                column1.action.data = 'type=3_&itemid=luke5566';
                tempMSG1.template.columns.add(column1);
            }
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'message';
                column1.action.label = 'type4';
                column1.action.text = 'type=4';
                tempMSG1.template.columns.add(column1);
            }
            returnResponse.data.add(tempMSG1);
        }
        
        return returnResponse;
    }

    public static outputResponse posAction2(requestData inReq)
    {
        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        LineMessages tempMSG1 = new LineMessages();
        tempMSG1.type = 'image';
        tempMSG1.originalContentUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
        tempMSG1.previewImageUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
        returnResponse.data.add(tempMSG1);
        LineMessages tempMSG2 = new LineMessages();
        tempMSG2.type = 'text';
        tempMSG2.text = 'text2';
        returnResponse.data.add(tempMSG2);

        return returnResponse;
    }

    public static outputResponse posAction3(requestData inReq)
    {
        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        LineMessages tempMSG1 = new LineMessages();
        tempMSG1.type = 'image';
        tempMSG1.originalContentUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
        tempMSG1.previewImageUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
        returnResponse.data.add(tempMSG1);
        LineMessages tempMSG2 = new LineMessages();
        tempMSG2.type = 'text';
        tempMSG2.text = 'text3';
        returnResponse.data.add(tempMSG2);

        return returnResponse;
    }

    public static outputResponse posAction4(requestData inReq)
    {
        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        LineMessages tempMSG1 = new LineMessages();
        tempMSG1.type = 'image';
        tempMSG1.originalContentUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
        tempMSG1.previewImageUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
        returnResponse.data.add(tempMSG1);
        LineMessages tempMSG2 = new LineMessages();
        tempMSG2.type = 'text';
        tempMSG2.text = 'text4';
        returnResponse.data.add(tempMSG2);
        LineMessages tempMSG3 = new LineMessages();
        tempMSG3.type = 'flex';
        tempMSG3.altText = 'this is a flex message';
        tempMSG3.contents = new LineMessages.singleContentData();  
        tempMSG3.contents.type = 'carousel';
        tempMSG3.contents.contents= new list<LineMessages.contentsData>();
        for(integer j=1;j<=5;j++)
        {
            LineMessages.contentsData crlcontent = new LineMessages.contentsData();
            crlcontent.type = 'bubble';
            crlcontent.hero = new LineMessages.containerData();
            crlcontent.hero.type = 'image';
            crlcontent.hero.url = 'https://pic.90sjimg.com/original_origin_pic/18/10/14/5c41131345baff99c2b3d7cb69bbd79c.png';
            crlcontent.hero.size = 'full';
            crlcontent.hero.aspectRatio = '10:10';
            crlcontent.hero.aspectMode = 'cover';
            crlcontent.hero.action = new LineMessages.actionData();
            crlcontent.hero.action.type = 'uri';
            crlcontent.hero.action.uri = 'http://linecorp.com/';
            crlcontent.body = new LineMessages.containerData();
            crlcontent.body.type='box';
            crlcontent.body.layout='vertical';
            crlcontent.body.contents= new list<LineMessages.contentsData>();
            tempMSG3.contents.contents.add(crlcontent);
            {
                LineMessages.contentsData content = new LineMessages.contentsData();
                String stringValue = String.valueOf(j);
                content.type = 'text';
                content.text = 'Cute Pig '+stringValue;
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
                        contenttext.text = 'Taipei';
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
                        contenttext.text = '10:00 - 23:00';
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
        returnResponse.data.add(tempMSG3);

        return returnResponse;
    }


    public static outputResponse defaultAction(requestData inReq)
    {
        outputResponse returnResponse = new outputResponse();

        returnResponse.code = '0';
        returnResponse.tempDesc = '';
        returnResponse.data = new list<LineMessages>();
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'text';
            tempMSG1.text = '這是default Aciton response';
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'image';
            tempMSG1.originalContentUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
            tempMSG1.previewImageUrl = 'https://farm2.staticflickr.com/1527/26153334456_4fd5309f10_b.jpg';
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'sticker';
            tempMSG1.packageId = '11537';
            tempMSG1.stickerId = '52002735';
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'imagemap';
            tempMSG1.baseUrl = 'https://lineorg-dev-ed--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=PNG&versionId=0682x000000W2jl&operationContext=DELIVERY&page=1&d=/a/2x000000PGn7/DR_ghIBQb9f0knRdwKhB3jIGTkQRjFTI6M2CqauMMfU&oid=00D2x000003up1M';
            tempMSG1.altText = 'testImageMap';
            {
                LineMessages.imageAction action1 = new LineMessages.imageAction();
                action1.type='message';
                action1.text='TEST123';
                action1.area = new LineMessages.areaData();
                action1.area.x=0;
                action1.area.y=0;
                action1.area.width=1040;
                action1.area.height=1040;
                tempMSG1.actions.add(action1);
            }
            returnResponse.data.add(tempMSG1);
        }
        {
            LineMessages tempMSG1 = new LineMessages();
            tempMSG1.type = 'template';
            tempMSG1.altText = 'this is a Image CAROUSEL template';
            tempMSG1.template = new LineMessages.templateData();
            tempMSG1.template.type = 'image_carousel';
            tempMSG1.template.columns = new list<LineMessages.columnData>();
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'postback';
                column1.action.label = 'type1';
                column1.action.data = 'type=1_&itemid=luke5566';
                tempMSG1.template.columns.add(column1);
            }
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'postback';
                column1.action.label = 'type2';
                column1.action.data = 'type=2_&itemid=luke5566';
                tempMSG1.template.columns.add(column1);
            }
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'postback';
                column1.action.label = 'type3';
                column1.action.data = 'type=3_&itemid=luke5566';
                tempMSG1.template.columns.add(column1);
            }
            {
                LineMessages.columnData column1 = new LineMessages.columnData();
                column1.imageURL = 'https://storage.googleapis.com/download/storage/v1/b/luke5566/o/testFolder01%2FtestIMG.png?generation=1596772787931723&alt=media';
                column1.action = new LineMessages.actionData();
                column1.action.type = 'message';
                column1.action.label = 'type4';
                column1.action.text = 'type=4';
                tempMSG1.template.columns.add(column1);
            }
            returnResponse.data.add(tempMSG1);
        }
        
        return returnResponse;
    }

    public static list<LineMessages> queyrMessage(string inputString, string inputLAId)
    {
        list<LineMessages> msgList = new list<LineMessages>();
        
        //message
        for(LineMessage__c loopMSG: [
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
            where LineKeyWord__c != null
            and LineKeyWord__r.Name =:inputString
            and LineKeyWord__r.Line_Account__c =:inputLAId
            order by LineKeyWord__c, Index__c
        ])
        {
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
                        tempMSG.altText = inputString;
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

        return  msgList;
    }
}