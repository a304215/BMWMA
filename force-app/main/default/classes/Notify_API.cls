/*==============================================================
 * Line推播提醒API(活動報名)(試駕預約提醒?)
 * SMS推播提醒API(活動報名)(試駕預約提醒?)
 * EDM推播提醒API(活動報名)(試駕預約提醒?)
 *==============================================================*/
public without sharing class Notify_API implements Queueable, Database.AllowsCallouts
{
    public string executeType {get; set;}
    public list<string> doneList {get; set;}

    public Notify_API(string inputType, list<string> inputDone) 
    {
        executeType = inputType;
        doneList = inputDone;
    }

    public void execute(QueueableContext context) {
        switch on executeType
        {
            when 'LINE_Campaign'{
                doLineCampagin();
            }
            when 'LINE_TestDrive'{
                doLineTestDrive();
            }
            when 'SMS_Campaign'{}
            when 'SMS_TestDrive'{}
            when 'EDM_Campaign'{}
            when 'EDM_TestDrive'{}
        }
    }

    public void doLineCampagin()
    {
        date threedays = system.today().adddays(3);

        //抓取三天後得活動
        list<CampaignMember> memberList = [
            select id, Lead.LINE_Key__c, PushMessage__c, Campaign.Line_Account__r.ChannelAccessToken__c
            from CampaignMember
            where HasResponded = true
            and LeadId != null
            and Lead.LINE_Key__c != null
            and LinePushAlert__c = ''
            and Campaign.Line_Account__c != null
            and Campaign.StartDate = next_n_days:3
            and id not in: doneList
            limit 50
        ];

        for(CampaignMember loopMember: memberList)
        {
            sendCamapginFuture(
                loopMember.Campaign.Line_Account__r.ChannelAccessToken__c,
                loopMember.Lead.LINE_Key__c,
                loopMember.PushMessage__c,
                loopMember.id
            );

            doneList.add(loopMember.id);
        }

        if(memberList.size() >0)
        {
            System.enqueueJob(new Notify_API('LINE_Campaign', doneList));
        }
    }

    @future(callout=true)
    public static void sendCamapginFuture(string inputToken, string inputUDID, string inputContent, string memberId)
    {
        HttpRequest httpReq = new HttpRequest();
     	httpReq.setEndpoint('https://api.line.me/v2/bot/message/multicast');
     	httpReq.setMethod('POST');
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setHeader('Authorization', 'Bearer ' + inputToken);

        outputMessageRequest tempData = new outputMessageRequest();
        tempData.to.add(inputUDID);
        LineMessages tempMS2 = new LineMessages();
        tempMS2.type = 'flex';
        tempMS2.altText = '活動提醒';
        tempMS2.contents = new LineMessages.singleContentData();
        tempMS2.contents.type = 'carousel';
        tempMS2.contents.contents = new list<LineMessages.contentsData>();
        {
            LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
            crlcontent.type = 'bubble';
            crlcontent.size = 'kilo';
            crlcontent.body = new LineMessages.containerData();
            crlcontent.body.type='box';
            crlcontent.body.layout='vertical';
            crlcontent.body.contents= new list<LineMessages.contentsData>();
            tempMS2.contents.contents.add(crlcontent);
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
                    contentbase.text = inputContent;
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
        tempData.messages.add(tempMS2);

        httpReq.setBody(tempData.toJSON());
        system.debug(tempData.toJSON());
        Http http = new Http();
		HttpResponse httpRes = http.send(httpReq);
        string returnString = httpRes.getBody();

        update new CampaignMember(
            id=memberId,
            LinePushAlert__c = returnString.left(255)
        );
    }

    public void doLineTestDrive()
    {
        date threedays = system.today().adddays(3);

        map<string, string> brandMap = new map<string, string>();
        for(Line_Account__c loopLa: [
            select brand__c, ChannelAccessToken__c
            from Line_Account__c
            where brand__c != null
        ])
        {
            brandMap.put(loopLa.brand__c, loopLa.ChannelAccessToken__c);
        }

        list<TestDriveReservation__c> driveList = [
            select id, StartTime__c, EndTime__c, TestCar__c, Brand__c, TestDriveStatus__c,
            TestCarBranch__c, Owner.Name, PushMessage__c, LineKey__c
            from TestDriveReservation__c 
            where LineKey__c != null
            and EndTime__c = next_n_days:3
            and LinePushAlert__c = ''
            and id not in: doneList
            limit 50
        ];

        for(TestDriveReservation__c loopDrive: driveList)
        {
            string acctoken = brandMap.get(loopDrive.Brand__c);

            if(acctoken != null)
            {
                sendTestDriveFuture(
                    acctoken,
                    loopDrive.LineKey__c,
                    loopDrive.PushMessage__c,
                    loopDrive.id
                );
            }
            

            doneList.add(loopDrive.id);
        }

        if(driveList.size() >0)
        {
            System.enqueueJob(new Notify_API('LINE_TestDrive', doneList));
        }
    }

    @future(callout=true)
    public static void sendTestDriveFuture(string inputToken, string inputUDID, string inputContent, string memberId)
    {
        HttpRequest httpReq = new HttpRequest();
     	httpReq.setEndpoint('https://api.line.me/v2/bot/message/multicast');
     	httpReq.setMethod('POST');
		httpReq.setHeader('Content-Type', 'application/json');
		httpReq.setHeader('Authorization', 'Bearer ' + inputToken);

        outputMessageRequest tempData = new outputMessageRequest();
        tempData.to.add(inputUDID);
        LineMessages tempMS2 = new LineMessages();
        tempMS2.type = 'flex';
        tempMS2.altText = '試駕提醒';
        tempMS2.contents = new LineMessages.singleContentData();
        tempMS2.contents.type = 'carousel';
        tempMS2.contents.contents = new list<LineMessages.contentsData>();
        {
            LineMessages.contentsData crlcontent = new LineMessages.contentsData();   
            crlcontent.type = 'bubble';
            crlcontent.size = 'kilo';
            crlcontent.body = new LineMessages.containerData();
            crlcontent.body.type='box';
            crlcontent.body.layout='vertical';
            crlcontent.body.contents= new list<LineMessages.contentsData>();
            tempMS2.contents.contents.add(crlcontent);
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
                    contentbase.text = inputContent;
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
                content.action.text = '【預約賞車】';
                
                crlcontent.footer.contents.add(content);
            }
        }
        tempData.messages.add(tempMS2);

        httpReq.setBody(tempData.toJSON());
        system.debug(tempData.toJSON());
        Http http = new Http();
		HttpResponse httpRes = http.send(httpReq);
        string returnString = httpRes.getBody();

        update new CampaignMember(
            id=memberId,
            LinePushAlert__c = returnString.left(255)
        );
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