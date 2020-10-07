/******** 
 * LineContent的TestMethod。
 * LineContentController、LineContentPushQueueable、
 * LineContentPushSchedule、LineContentQueueable、
 * Callout_Line_API、
 *
 *********/
@isTest

public with sharing class LineContent_TestMethod {
    static testmethod void TestLineContentController()
    {
        Line_Account__c LAccount = new Line_Account__c();
        LAccount.ReportFolderName__c = '321';
        insert LAccount;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.StartTest();
        LineContentController.pushMessage();
        LineContentController.initial('');
        LineContentController.lineAccountList();
        LineContentController.checkReportList(LAccount.id);
        LineContentController.initialD('');
        LineContentController.apexNewContent();
        string myContent = '';
        myContent += '{"theContent":{';
        myContent += '"Name":"123"';
        myContent +='},';
        myContent +='"theList":[';
        myContent +='{';
        myContent += '"Name":"123",';
        myContent += '"IsDeleted__c":false';
        myContent += '}';
        myContent +=']';
        myContent +='}';
        LineContentController.apexSaveContent(myContent);
        LineContentController.apexCompleteContent(myContent);
        LineContentController.publicLinkStart(documents[0].id, 'Png');
        Test.StopTest();
    }

    static testmethod void TestLineContentQueueable()
    {
    	new LineContentQueueable(new line_Content__c() );
    }

    static testmethod void TestPushQueueable()
    {
    	System.enqueueJob(new LineContentPushQueueable(new list<string>(), new list<string>() ));
    }
    
    static testmethod void TestPushScheduleQueueable()
    {
        LineContentPushSchedule testClass = new LineContentPushSchedule();
        String schedule = '0 0 23 * * ?';
		system.schedule('Daily Update', schedule, testClass);
    }  

    static testmethod void TestPushLine1()
    {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponesLINE(''));
        Test.startTest();
        Callout_Line_API.sendMulticast('123', '123', 'hello');
        Test.stopTest();
    }

    static testmethod void TestPushLine2()
    {
        Account ACC = new Account();
        ACC.Name = '5566';
        insert ACC;

        Line_Account__c LAccount = new Line_Account__c();
        LAccount.ChannelAccessToken__c = '123';
        insert LAccount;

        Line_User__c LUser = new Line_User__c();
        LUser.Account__c = ACC.id;
        LUser.UDID__c = '5566';
        LUser.Line_Account__c = LAccount.id;
        insert LUser;

        Line_Content__c myContent = new Line_Content__c();
        myContent.Name = '123';
        insert myContent;

        list<Line_Content_Detail__c> insertCDList = new list<Line_Content_Detail__c>();

        Line_Content_Detail__c myDetail1 = new Line_Content_Detail__c();
        myDetail1.Line_Content__c = myContent.id;
        myDetail1.MessageType__c = '文字';
        myDetail1.Text1__c = 'aaabbbbccc0x1000A0';
        insertCDList.add(myDetail1);

        Line_Content_Detail__c myDetail2 = new Line_Content_Detail__c();
        myDetail2.Line_Content__c = myContent.id;
        myDetail2.MessageType__c = '貼圖';
        myDetail2.PackageID__c = '1';
        myDetail2.StickerID__c = '1';
        insertCDList.add(myDetail2);

        Line_Content_Detail__c myDetail3 = new Line_Content_Detail__c();
        myDetail3.Line_Content__c = myContent.id;
        myDetail3.MessageType__c = '圖片';
        myDetail3.ImageURL__c = '1';
        insertCDList.add(myDetail3);

        Line_Content_Detail__c myDetail4 = new Line_Content_Detail__c();
        myDetail4.Line_Content__c = myContent.id;
        myDetail4.MessageType__c = '圖文';
        myDetail4.ImageContentURL__c = '1';
        myDetail4.PicTextType__c = 'type1';
        myDetail4.PicTextTypeA__c = '網址';
        myDetail4.PicTextMTextA__c = '1';
        myDetail4.PicTextTitleA__c = '1';
        insertCDList.add(myDetail4);

        Line_Content_Detail__c myDetail5 = new Line_Content_Detail__c();
        myDetail5.Line_Content__c = myContent.id;
        myDetail5.MessageType__c = '圖文';
        myDetail5.ImageContentURL__c = '1';
        myDetail5.PicTextType__c = 'type1';
        myDetail5.PicTextTypeA__c = '文字';
        myDetail5.PicTextMTextA__c = '1';
        myDetail5.PicTextTitleA__c = '1';
        insertCDList.add(myDetail5);

        //type2
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type2';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleb__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type2';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            insertCDList.add(myDetail7);
        }
        //type3
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type3';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleb__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type3';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            insertCDList.add(myDetail7);
        }
        //type4
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type4';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleB__c = '1';
            myDetail6.PicTextTypeC__c = '網址';
            myDetail6.PicTextMTextC__c = '1';
            myDetail6.PicTextTitleC__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type4';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            myDetail7.PicTextTypeC__c = '文字';
            myDetail7.PicTextMTextC__c = '1';
            myDetail7.PicTextTitleC__c = '1';
            insertCDList.add(myDetail7);
        }
        //type5
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type5';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleB__c = '1';
            myDetail6.PicTextTypeC__c = '網址';
            myDetail6.PicTextMTextC__c = '1';
            myDetail6.PicTextTitleC__c = '1';
            myDetail6.PicTextTypeD__c = '網址';
            myDetail6.PicTextMTextD__c = '1';
            myDetail6.PicTextTitleD__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type5';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            myDetail7.PicTextTypeC__c = '文字';
            myDetail7.PicTextMTextC__c = '1';
            myDetail7.PicTextTitleC__c = '1';
            myDetail7.PicTextTypeD__c = '文字';
            myDetail7.PicTextMTextD__c = '1';
            myDetail7.PicTextTitleD__c = '1';
            insertCDList.add(myDetail7);
        }
        //type6
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type6';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleB__c = '1';
            myDetail6.PicTextTypeC__c = '網址';
            myDetail6.PicTextMTextC__c = '1';
            myDetail6.PicTextTitleC__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type6';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            myDetail7.PicTextTypeC__c = '文字';
            myDetail7.PicTextMTextC__c = '1';
            myDetail7.PicTextTitleC__c = '1';
            insertCDList.add(myDetail7);
        }
        //type7
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type7';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleB__c = '1';
            myDetail6.PicTextTypeC__c = '網址';
            myDetail6.PicTextMTextC__c = '1';
            myDetail6.PicTextTitleC__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type7';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            myDetail7.PicTextTypeC__c = '文字';
            myDetail7.PicTextMTextC__c = '1';
            myDetail7.PicTextTitleC__c = '1';
            insertCDList.add(myDetail7);
        }
        //type8
        {
            Line_Content_Detail__c myDetail6 = new Line_Content_Detail__c();
            myDetail6.Line_Content__c = myContent.id;
            myDetail6.MessageType__c = '圖文';
            myDetail6.ImageContentURL__c = '1';
            myDetail6.PicTextType__c = 'type8';
            myDetail6.PicTextTypeA__c = '網址';
            myDetail6.PicTextMTextA__c = '1';
            myDetail6.PicTextTitleA__c = '1';
            myDetail6.PicTextTypeB__c = '網址';
            myDetail6.PicTextMTextB__c = '1';
            myDetail6.PicTextTitleB__c = '1';
            myDetail6.PicTextTypeC__c = '網址';
            myDetail6.PicTextMTextC__c = '1';
            myDetail6.PicTextTitleC__c = '1';
            myDetail6.PicTextTypeD__c = '網址';
            myDetail6.PicTextMTextD__c = '1';
            myDetail6.PicTextTitleD__c = '1';
            myDetail6.PicTextTypeE__c = '網址';
            myDetail6.PicTextMTextE__c = '1';
            myDetail6.PicTextTitleE__c = '1';
            myDetail6.PicTextTypeF__c = '網址';
            myDetail6.PicTextMTextF__c = '1';
            myDetail6.PicTextTitleF__c = '1';
            insertCDList.add(myDetail6);

            Line_Content_Detail__c myDetail7 = new Line_Content_Detail__c();
            myDetail7.Line_Content__c = myContent.id;
            myDetail7.MessageType__c = '圖文';
            myDetail7.ImageContentURL__c = '1';
            myDetail7.PicTextType__c = 'type8';
            myDetail7.PicTextTypeA__c = '文字';
            myDetail7.PicTextMTextA__c = '1';
            myDetail7.PicTextTitleA__c = '1';
            myDetail7.PicTextTypeB__c = '文字';
            myDetail7.PicTextMTextB__c = '1';
            myDetail7.PicTextTitleB__c = '1';
            myDetail7.PicTextTypeC__c = '文字';
            myDetail7.PicTextMTextC__c = '1';
            myDetail7.PicTextTitleC__c = '1';
            myDetail7.PicTextTypeD__c = '文字';
            myDetail7.PicTextMTextD__c = '1';
            myDetail7.PicTextTitleD__c = '1';
            myDetail7.PicTextTypeE__c = '文字';
            myDetail7.PicTextMTextE__c = '1';
            myDetail7.PicTextTitleE__c = '1';
            myDetail7.PicTextTypeF__c = '文字';
            myDetail7.PicTextMTextF__c = '1';
            myDetail7.PicTextTitleF__c = '1';
            insertCDList.add(myDetail7);
        }

        Line_Content_Detail__c myDetail8 = new Line_Content_Detail__c();
        myDetail8.Line_Content__c = myContent.id;
        myDetail8.MessageType__c = '影片';
        myDetail8.VideoURL__c = '1';
        myDetail8.VideoImageURL__c = 'type1';
        insertCDList.add(myDetail8);

        insert insertCDList;

        Line_Push__c myPush = new Line_Push__c();
        myPush.Line_User__c = LUser.id;
        myPush.Line_Account__c = LAccount.id;
        myPush.Account__c = ACC.id;
        myPush.Line_Content__c = myContent.id;
        insert myPush;


        Test.setMock(HttpCalloutMock.class, new MockHttpResponesLINE('Line'));
        Test.startTest();
        Callout_Line_API.sendMulticastSFFuture(myPush.id);
        Test.stopTest();
    }  
}