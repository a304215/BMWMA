public without sharing class TriggerHandler_SurveyCake
{
    public static void sentRequest(list<Survey_Cake__c> inputList)
    {
        list<string> idList = new list<string>();
        for(Survey_Cake__c loopSC: inputList)
        {
            idList.add(loopSC.id);
            if(idList.size() == 50)
            {
                fetchData(idList);
                idList = new list<string>();
            }
        }

        if(idList.size() >0)
        {
            fetchData(idList);
        }
    }


    @future(callout=true)
    public static void fetchData(list<string> inputList)
    {
        list<Survey_Cake__c> updateList = new list<Survey_Cake__c>();
        list<Result__c> insertList = new list<Result__c>();
        list<Result__c> deleteList = new list<Result__c>();
        Lead tempLead = new Lead();
        string campId = '';
        string bodyJSON = '';

        for(Survey_Cake__c loopSC: [
            select id, hash__c, svid__c, Survey_Name__c,
            Campaign__r.Hash_Key__c, Campaign__r.IV_Key__c, 
            Campaign__c,
            (select id from Result__r),
            (select id from Lead__r)
                from Survey_Cake__c
            where id in: inputList
        ])
        {
            //直接用get 就好了。
            Httprequest req1 = new HttpRequest();  
            string ppoint = 'https://www.surveycake.com/webhook/v0/'+loopSC.svid__c+'/'+loopSC.hash__c+'';
            system.debug(ppoint);
            req1.setEndpoint(ppoint);
            req1.setMethod('GET');
            req1.setTimeout(120000);
            Http http1 = new Http();
            HttpResponse res1 = http1.send(req1);
            string bodyString = res1.getBody();
            system.debug(bodyString);
            bodyJSON = decryptedData('AES128', loopSC.Campaign__r.Hash_Key__c, loopSC.Campaign__r.IV_Key__c, bodyString);
            system.debug(bodyJSON);

            if(bodyJSON == 'DecryptError')
            {
                //直接用get 就好了。
                //Sandbox
                Httprequest req2 = new HttpRequest();  
                ppoint = 'https://bmw.surveycake.biz/webhook/v0/'+loopSC.svid__c+'/'+loopSC.hash__c+'';
                system.debug(ppoint);
                req2.setEndpoint(ppoint);
                req2.setMethod('GET');
                req2.setTimeout(120000);
                Http http2 = new Http();
                HttpResponse res2 = http2.send(req2);
                bodyString = res2.getBody();
                system.debug(bodyString);
                bodyJSON = decryptedData('AES128', loopSC.Campaign__r.Hash_Key__c, loopSC.Campaign__r.IV_Key__c, bodyString);
            }

            surveyResponse tmpDataModel = (surveyResponse)System.JSON.deserialize(bodyJSON, surveyResponse.class);
            system.debug('svid: '+tmpDataModel.svid);
            system.debug('title: '+tmpDataModel.title);
            system.debug('submitTime: '+tmpDataModel.submitTime);

            list<user> myOwner = [
                select id, username from user where profile.name = 'cust. call center'
            ];

            for(Result__c loopResult: loopSC.Result__r)
            {
                deleteList.add(loopResult);
            }
            for(Lead loopLead: loopSC.Lead__r)
            {
                tempLead = loopLead;
                
            }
            tempLead.SurveyCakeCarType__c = '';


            for(answerClass loopAns: tmpDataModel.result)
            {
                Result__c tempResult = new Result__c();
                tempResult.Question__c = loopAns.subject;
                tempResult.Type__c = loopAns.type;
                tempResult.Answer__c = '';
                
                for(string loopStr: loopAns.answer)
                {
                    tempResult.Answer__c += loopStr + ';';

                    //姓氏 
                    if(loopAns.subject.contains('您的姓氏')|| loopAns.subject.contains('姓氏'))
                    {
                        tempLead.LastName = loopStr;
                    }
                    //名字、姓名
                    if(loopAns.subject.contains('您的名字') || loopAns.subject.contains('您的姓名') || loopAns.subject.contains('名字'))
                    {
                        tempLead.firstName = loopStr;
                    }
                    //性別
                    if(loopAns.subject.contains('性別'))
                    {
                        tempLead.Gender__c = loopStr;
                    }
                    //年齡
                    if(loopAns.subject.contains('年齡'))
                    {
                        if(loopStr.startsWith('20'))
                        {
                            tempLead.opptyage__c = '20 歲以下';
                        }
                        if(loopStr.startsWith('21'))
                        {
                            tempLead.opptyage__c = '21-30 歲';
                        }
                        if(loopStr.startsWith('31'))
                        {
                            tempLead.opptyage__c = '31-40 歲';
                        }
                        if(loopStr.startsWith('41'))
                        {
                            tempLead.opptyage__c = '41-50 歲';
                        }
                        if(loopStr.startsWith('51'))
                        {
                            tempLead.opptyage__c = '51-60 歲';
                        }
                        if(loopStr.startsWith('61'))
                        {
                            tempLead.opptyage__c = '61-70 歲';
                        }
                        if(loopStr.startsWith('70'))
                        {
                            tempLead.opptyage__c = '70 歲以上';
                        }
                        //tempLead.opptyage__c = loopStr;
                    }
                    //電話
                    if(loopAns.subject.contains('行動電話'))
                    {
                        tempLead.MobilePhone = loopStr;
                    }
                    //Email
                    if(loopAns.subject.contains('電子郵件') || loopAns.subject.toUpperCase().contains('EMAIL') || loopAns.subject.toUpperCase().contains('E-MAIL') )
                    {
                        tempLead.Email = loopStr;
                    }
                    //門市
                    if(loopAns.subject.contains('所屬門市') )
                    {
                        tempLead.SaleStore__c = loopStr;
                    }
                    //經銷商
                    if(loopAns.subject.contains('經銷商') )
                    {
                        tempLead.AssginDealer__c = loopStr;
                    }
                    //是否需為您安排前往BMW展示中心賞車?
                    if(loopAns.subject.contains('請選擇您欲前往的展示中心') )
                    {
                        tempLead.InterestCarShowroom__c = loopStr;
                    }
                    //您是否願意收到BMW品牌活動或新車相關資訊? 
                    if(loopAns.subject.contains('您是否願意收到BMW品牌活動或新車相關資訊') )
                    {
                        if(loopStr == '好，我想了解更多BMW相關資訊')
                        {
                            //true
                            tempLead.BMWBrandingInfo__c = true;
                        }
                        else 
                        {
                            //false
                            tempLead.BMWBrandingInfo__c = false;
                        }
                    }
                    //下列哪個系列是您最感興趣的BMW車款(至多選擇三項)
                    if(loopAns.subject.contains('下列哪個系列是您最感興趣的BMW車款(至多選擇三項)') )
                    {
                        tempLead.SurveyCakeCarType__c+=loopStr+';';
                    }
                    //請填入指定的銷售顧問姓名
                    if(loopAns.subject.contains('請填入指定的銷售顧問姓名') )
                    {
                        tempLead.SurveyCake_Consultant__c = loopStr;
                    }
                }
                tempResult.Other__c = '';
                for(string loopStr: loopAns.otherAnswer)
                {
                    tempResult.Other__c += loopStr + ';';
                }
                tempResult.sn__c = string.valueOf(loopAns.sn);
                tempResult.Survey_Cake__c = loopSC.id;
                insertList.add(tempResult);
            }
            tempLead.Source_Survey_Cake__c = loopSC.id;
            tempLead.SourceCampaign__c = loopSC.Campaign__c;
            tempLead.LeadSource = '總代理行銷/CRM活動';
            tempLead.ProjectName__c = tmpDataModel.title;
            
            if(myOwner.size() > 0)
            {
                tempLead.ownerid = myOwner[0].id;
            }
            
            campId = loopSC.Campaign__c;

            Survey_Cake__c updateCake = new Survey_Cake__c(id = loopSC.id);
            updateCake.Survey_Name__c = tmpDataModel.title;
            updateList.add(updateCake);
        }

        //應該只會有一筆。
        if(updateList.size() >0)
        {
            system.debug(tempLead);
            update updateList;
            
            if(! string.isBlank(tempLead.lastName))
            {
                Savepoint sp = Database.setSavepoint();
                try
                {
                    if(tempLead.id != null)
                    {
                        update tempLead;
                    }
                    else 
                    {
                        insert tempLead;

                        Database.DMLOptions dmo = new Database.DMLOptions();
                        dmo.assignmentRuleHeader.useDefaultRule = true;
                        Database.update(tempLead, dmo);
                    }

                    list<CampaignMember> memberList = [
                        select id 
                        from CampaignMember 
                        where LeadId=:tempLead.id
                        and CampaignId=:campId
                    ];

                    if(memberList.size() == 0)
                    {
                        CampaignMember tempMember = new CampaignMember();
                        tempMember.LeadId = tempLead.id;
                        tempMember.CampaignId = campId;
                        insert tempMember;
                    }
                }
                catch(exception ex)
                {
                    Database.rollback(sp);
                    task myTask = new task();
                    myTask.subject = 'Survey Cake Insert Lead Error:' +system.now().format('YYYYMMDDHHmmss');
                    myTask.Description = ex.getMessage() + '\n' + bodyJSON;
                    insert myTask;
                }
            }
        }
        if(deleteList.size() > 0)
        {
            delete deleteList;
        }
        if(insertList.size() >0)
        {
            insert insertList;
        }
    }


    public class surveyResponse
    {
        public string svid;
        public string title;
        public string submitTime;
        public list<answerClass> result;

        public surveyResponse()
        {

        }
    }

    public class answerClass
    {
        public string subject;
        public string type;
        public integer sn;
        public list<string> answer;
        public list<string> otherAnswer;
        public answerClass()
        {

        }
    }

    public static string decryptedData(string inputMethod, string inputKey, string inputIV, string inputData)
    {
        string returnString = '';
        try
        {
            Blob CryptoKey = blob.valueof(inputKey);
            Blob CryptoIV = blob.valueof(inputIV);
            Blob EncryptedData;
            Blob DecryptedData;
            EncryptedData = EncodingUtil.base64Decode(inputData);
            DecryptedData = Crypto.decrypt(inputMethod, CryptoKey, CryptoIV, EncryptedData);
            returnString = DecryptedData.tostring();
        }
        catch (exception ex)
        {
            returnString = 'DecryptError';
        }
        
        return returnString;
    }
    
}