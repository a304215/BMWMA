/*==============================================================
 * Liff Page 跳轉 的Controller。
 *
 *
 *==============================================================*/
global without sharing class LiffExchangeController 
{
    public static string mySiteID = site.getSiteId();
    public string cId {get; set;}
    public string TagId {get; set;}
    public string LIFFID {get; set;}

    public LiffExchangeController() 
    {
        cId = ApexPages.currentPage().getParameters().get('cId');
        TagId = ApexPages.currentPage().getParameters().get('tId');
        for(Line_Account__c loopLA : [
            select id, ExchangeLIFF__c
            from Line_Account__c 
            where SFDCSiteId__c =:LiffExchangeController.mySiteID
        ])
        {
            LIFFID = loopLA.ExchangeLIFF__c;
        }
    }
    
    @RemoteAction 
    global static string exchangePage(string inputLineID, string inputCId, string inputTId)
    {
        List<Line_User__c> userList = [
            select id, CustomerUser__c,
                CustomerUser__r.LastName__c, CustomerUser__r.FirstName__c, CustomerUser__r.Mobile__c, 
                CustomerUser__r.Gender__c, CustomerUser__r.Birthday__c, CustomerUser__r.Email__c
            from Line_User__c 
            where UDID__c =: inputLineID 
            and Line_Account__r.SFDCSiteId__c =:LiffExchangeController.mySiteID
        ];
        
        system.debug('a: '+inputLineID);
    
        if(userList.size() > 0)
        {
            Tracking_Tag__c tmpTag;
            Line_Content__c tmpLC;
            for(Tracking_Tag__c loopTag:[
                select id, name, URL__c
                from Tracking_Tag__c
                where id =:inputTId
            ])
            {
                tmpTag = loopTag;
            }

            for(Line_Content__c loopLC:[
                select id
                from Line_Content__c
                where id =:inputCId
            ])
            {
                tmpLC = loopLC;
            }

            //要再寫入LINE Account
            Tracking_Log__c insertRecord = new Tracking_Log__c();
            insertRecord.Line_User__c = userList[0].id;
            insertRecord.CustomerUser__c = userList[0].CustomerUser__c;
            insertRecord.Tracking_Tag__c = tmpTag.id;
            insertRecord.clicktime__c = system.now();
            if(tmpLC != null)
            {
                insertRecord.Line_Content__c = tmpLC.id;
            }
            insert insertRecord;

            if(LiffExchangeController.isValidSalesforceId(tmpTag.URL__c, CarModels__c.class))
            {
                string returnURL = 'https://sp.bmw.com.tw/testdriveLine/?sellinggeneration=';
                list<CarModels__c> carlist = [select id, SellingGeneration__c from CarModels__c where id=:tmpTag.URL__c];
                if(carlist.size() >0)
                {
                    returnURL += CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',carlist[0].SellingGeneration__c);
                }
                system.debug('==luke: ' + userList[0].CustomerUser__r.LastName__c);
                if(userList[0].CustomerUser__r.LastName__c != null)
                {
                    returnURL += '&lastname='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.LastName__c);
                }
                system.debug('==luke: ' + userList[0].CustomerUser__r.FirstName__c);
                if(userList[0].CustomerUser__r.FirstName__c != null)
                {
                    returnURL += '&firstname='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.FirstName__c);
                }
                system.debug('==luke: ' + userList[0].CustomerUser__r.Gender__c);
                if(userList[0].CustomerUser__r.Gender__c != null)
                {
                    returnURL += '&gender='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',(userList[0].CustomerUser__r.Gender__c=='男'?'先生':'小姐'));
                }
                system.debug('==luke: ' + userList[0].CustomerUser__r.Birthday__c);
                if(userList[0].CustomerUser__r.Birthday__c != null)
                {
                    returnURL += '&birthdate='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',string.valueOf(userList[0].CustomerUser__r.Birthday__c));
                }
                system.debug('==luke: ' + userList[0].CustomerUser__r.Email__c);
                if(userList[0].CustomerUser__r.Email__c != null)
                {
                    returnURL += '&email='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.Email__c);
                }
                system.debug('==luke: ' + userList[0].CustomerUser__r.Mobile__c);
                if(userList[0].CustomerUser__r.Mobile__c != null)
                {
                    returnURL += '&mobile='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.Mobile__c);
                }
                system.debug('==luke: ' + inputLineID);
                if(inputLineID != null)
                {
                    returnURL += '&linekey='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',inputLineID);
                }
                system.debug('==luke: ' +returnURL);

                return returnURL;

            }
            else if(LiffExchangeController.isValidSalesforceId(tmpTag.URL__c, Line_TestDrive__c.class))
            {
                string returnURL = 'https://sp.bmw.com.tw/testdriveLine/?sellinggeneration=';
                list<Line_TestDrive__c> carlist = [select id, SellingGeneration__c from Line_TestDrive__c where id=:tmpTag.URL__c];
                if(carlist.size() >0)
                {
                    returnURL += CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',carlist[0].SellingGeneration__c);
                    
                }
                if(userList[0].CustomerUser__r.LastName__c != null)
                {
                    returnURL += '&lastname='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.LastName__c);
                }
                if(userList[0].CustomerUser__r.FirstName__c != null)
                {
                    returnURL += '&firstname='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.FirstName__c);
                }
                if(userList[0].CustomerUser__r.Gender__c != null)
                {
                    returnURL += '&gender='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',(userList[0].CustomerUser__r.Gender__c=='男'?'先生':'小姐'));
                }
                if(userList[0].CustomerUser__r.Birthday__c != null)
                {

                    returnURL += '&birthdate='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm', string.valueOf(userList[0].CustomerUser__r.Birthday__c));
                }
                if(userList[0].CustomerUser__r.Email__c != null)
                {
                    returnURL += '&email='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.Email__c);
                }
                if(userList[0].CustomerUser__r.Mobile__c != null)
                {
                    returnURL += '&mobile='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',userList[0].CustomerUser__r.Mobile__c);
                }
                if(inputLineID != null)
                {
                    returnURL += '&linekey='+CryptoFunction.encryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm',inputLineID);
                }
                system.debug(returnURL);

                return returnURL;
            }

            return tmpTag.URL__c;

        }
        return 'NONE';
    }

    global static Boolean isValidSalesforceId( String sfdcId, System.Type t ){
        try {
 
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( sfdcId ).matches() ){
                Id id = sfdcId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
 
                return true;
            }
        } catch ( Exception e ){
        }
 
        return false;
    }
}