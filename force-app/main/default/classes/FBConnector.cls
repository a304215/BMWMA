public without sharing class FBConnector 
{
    public static string tempToken = '';
    public static boolean isNewToken = false;
    public static FB2WebSetting__c theOrgSetting = FB2WebSetting__c.getOrgDefaults();

    public static lead FBPusher(lead inputLead) 
    {
        string tempPhone = '';
        map<string, WebStore__mdt> storeMap = getStoreMap();
        if(inputLead.fbMobilePhone__c.startsWith('+8869'))
        {
            tempPhone = '09'+inputLead.fbMobilePhone__c.remove('+8869');
        }
        else if(inputLead.fbMobilePhone__c.startsWith('+88609'))
        {
            tempPhone = '09'+inputLead.fbMobilePhone__c.remove('+88609');
        }
        else if(inputLead.fbMobilePhone__c.startsWith('+886'))
        {
            tempPhone = inputLead.fbMobilePhone__c.remove('+886');
            if(!tempPhone.startsWith('0'))
            {
                tempPhone = '0'+tempPhone;
            }
        }

        if(tempPhone.isNumeric() && tempPhone.length()==10 && tempPhone.startsWith('09'))
        {
            inputLead.mobilePhone = tempPhone;
        }
        else if(tempPhone.isNumeric())
        {
            inputLead.MainPhoneNumber__c = '住宅電話';
            inputLead.Phone  = tempPhone;
        }
        else
        {
            tempPhone = '';
        }

        if(tempPhone != '')
        {
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(theOrgSetting.domain__c+'testdrive/process');
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpReq.setTimeout(120000);
            string bbbdy = 'firstname='+inputLead.firstname+
            '&lastname='+inputLead.lastname+
            '&gender='+(inputLead.gender__c=='男性'?'1':'0')+
            '&age='+inputLead.opptyage__c+
            '&email='+inputLead.Email+
            '&mobile='+tempPhone+
            '&reseller_city='+storeMap.get(inputLead.fbSaleStore__c).Area__c+
            '&reseller_store='+inputLead.fbSaleStore__c+
            '&code='+inputLead.ProjectName__c+
            '&token='+tempToken;
            
            httpReq.setBody(bbbdy);
            Http http = new Http();
            HttpResponse httpRes = http.send(httpReq);
            string pushResult = httpRes.getBody();
            myResponse myResponse1 = (myResponse)JSON.deserialize(pushResult, myResponse.Class);
            if(myResponse1.status == '0')
            {
                inputLead.FB2WebStatus__c = '0';
                inputLead.FB2WebMessage__c = '';
            }
            else if(myResponse1.status == '-1')
            {
                if(myResponse1.message == 'token' || myResponse1.message =='驗證檢查失敗')
                {
                    //從取token。
                    tempToken = FBToken(theOrgSetting);

                    HttpRequest httpReq2 = new HttpRequest();
                    httpReq2.setEndpoint(theOrgSetting.domain__c+'testdrive/process');
                    httpReq2.setMethod('POST');
                    httpReq2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    httpReq2.setTimeout(120000);
                    string bbbdy2 = 'firstname='+inputLead.firstname+
                    '&lastname='+inputLead.lastname+
                    '&gender='+(inputLead.gender__c=='男性'?'1':'0')+
                    '&age='+inputLead.opptyage__c+
                    '&email='+inputLead.Email+
                    '&mobile='+tempPhone+
                    '&reseller_city='+storeMap.get(inputLead.fbSaleStore__c).Area__c+
                    '&reseller_store='+inputLead.fbSaleStore__c+
                    '&code='+inputLead.ProjectName__c+
                    '&token='+tempToken;
                    
                    httpReq2.setBody(bbbdy2);
                    Http http2 = new Http();
                    HttpResponse httpRes2 = http2.send(httpReq2);
                    string pushResult2 = httpRes2.getBody();
                    myResponse myResponse2 = (myResponse)JSON.deserialize(pushResult2, myResponse.Class);
                    if(myResponse2.status == '0')
                    {
                        inputLead.FB2WebStatus__c = '0';
                        inputLead.FB2WebMessage__c = '';
                    }
                    else if(myResponse2.status == '-1')
                    {
                        inputLead.FB2WebStatus__c = '-1';
                        inputLead.FB2WebMessage__c = myResponse2.message;
                    }
                    else
                    {
                        inputLead.FB2WebStatus__c = '-1';
                        inputLead.FB2WebMessage__c = pushResult2.left(32767);
                    }
                    system.debug('renew');
                }
                else
                {
                    inputLead.FB2WebStatus__c = '-1';
                    inputLead.FB2WebMessage__c = myResponse1.message;
                }
            }
            else
            {
                inputLead.FB2WebStatus__c = '-1';
                inputLead.FB2WebMessage__c = pushResult.left(32767);
            }
        }
        else
        {
            inputLead.FB2WebStatus__c = '-1';
            inputLead.FB2WebMessage__c = 'sfdcError: 手機or市話號碼格式不符合';
        }

        return inputLead;
    }

    public static string  FBToken(FB2WebSetting__c inputWeb) 
    {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(inputWeb.domain__c+'api/Jwt/get?username='+inputWeb.username__c+'&passwd='+inputWeb.password__c);
        httpReq.setMethod('GET');
        //httpReq.setBody('');
        Http http = new Http();
        HttpResponse httpRes = http.send(httpReq);
        string pushResult = httpRes.getBody();
        return pushResult;
    }

    public class myResponse
    {
        public string status;
        public string message;
        public myResponse(){}
    }

    private static map<string, WebStore__mdt> mStoreMap;
    public static map<string, WebStore__mdt> getStoreMap()
    {
        if(mStoreMap == null)
        {
            mStoreMap = new map<string, WebStore__mdt>();
            //造道理要有一筆。
            for(WebStore__mdt loopStore: [
                select 
                Area__c,
                Store__c, 
                MasterLabel
                from WebStore__mdt
            ])
            {
                mStoreMap.put(loopStore.MasterLabel, loopStore);
            }
            mStoreMap.put(null, new WebStore__mdt());
        }
        return mStoreMap;
    }
    
}