/* ====================================
 * 呼叫三竹SMS Function 。
 *
 * Single / Bulk Send
 *
 * ====================================*/

public without sharing virtual class SMSFunction {
    
    public string valifyCode {get; set;}
    public string username = '20561562';
    public string password = 'bmw37666666';
    public string myPhone = '';
    public string myName = '';
    public string smbody = '';
    
    //簡訊預約時間
    //格式為YYYYMMDDHHMMSS 或整數值代表幾秒後傳送。
    //即時發送：輸入的預約時間⼩等於系統時間或輸入空⽩。
    //預約發送：輸入的預約時間⼤於系統時間10分鐘
    public string preTime = '';  
    
    //簡訊有效期限，
    //格式為YYYYMMDDHHMMSS 或整數值代表傳送後幾秒後內有效。
    //若未指定則預設為24⼩時。
    public Integer validTime = 600;
    
    //單筆簡訊發送
    public void mitakeSingleCallout(){  
        Httprequest req1 = new HttpRequest(); 
        req1.setEndpoint('https://smsapi.mitake.com.tw/api/mtk/SmSend?CharsetURL=UTF-8'); 
        req1.setMethod('POST');    
        req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        String username = username;
        String password = password;
        String dstaddr = myPhone;
        String destname = myName;
        String dlvtime = preTime;
        Integer vldtime = validTime;
        //String smbody = '';
        System.debug('let go');
        if (!myPhone.contains('+886')) 
        {
         myPhone = myPhone.replaceFirst('09', '+8869');
        }
        req1.setBody('username='+username+'&password='+password+'&dstaddr='+dstaddr+'&destname='+destname+'&dlvtime='+dlvtime+'&vldtime='+vldtime+'&smbody='+smbody);
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug(res1.getBody());
        
        /* 寫在LINE_REST了
        // Generate Mobile Code    
        valifyCode = String.valueOf(Math.round((Math.random() * (900000) + 100000)));           
        Datetime local_time = System.now();
        SMS_Log__c sms_log = new SMS_Log__c ();
        sms_log.MobilePhone__c = myPhone;
        sms_log.Validate_Code__c = valifyCode;
        sms_log.Validate_ExpireTime__c = local_time.addSeconds(600);
        sms_log.Validate_Code_Sent_Result__c = res1.getBody();
        insert sms_log;
*/
    }
    
    //批次簡訊發送
    public void mitakeBulkCallout(){
        Httprequest req1 = new HttpRequest(); 
        req1.setEndpoint('https://smsapi.mitake.com.tw/api/mtk/SmBulkSend?username=20561562&password=bmw37666666&Encoding_PostIn=UTF8');
        req1.setMethod('POST');    
        req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        String username = username;
        String password = password;
        String dstaddr = myPhone;
        String destname = myName;
        String dlvtime = preTime;
        Integer vldtime = validTime;
        String smbody = '批次簡訊發送1';
        String smbody2 = '批次簡訊發送2';
        String ClientID = 'TEST1';
        String ClientID2 = 'TEST2';
        if (!myPhone.contains('+886')) 
        {
         myPhone = myPhone.replaceFirst('09', '+8869');
        }
        req1.setBody(ClientID+'$$'+dstaddr+'$$'+dlvtime+'$$'+vldtime+'$$'+destname+ '$$$$'+ smbody + '\r\n' + ClientID2+'$$'+dstaddr+'$$'+dlvtime+'$$'+vldtime+'$$'+destname+ '$$$$'+smbody2 +'\r\n');
        Http http1 = new Http();
        HttpResponse res1 = http1.send(req1);
        System.debug(res1.getBody());
        
        // Generate Mobile Code    
        valifyCode = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
        
        Datetime local_time = System.now();
        SMS_Log__c sms_log = new SMS_Log__c ();
        sms_log.MobilePhone__c = myPhone;
        sms_log.Validate_Code__c = valifyCode;
        sms_log.Validate_ExpireTime__c = local_time.addSeconds(600);
        sms_log.Validate_Code_Sent_Result__c = res1.getBody();
        insert sms_log;
    }
    
    //sendSMS-innerfunction
/*  No Needed
    public static string sendSMS(string inputMobile, string inputMessage)
    {
    	//username & password & dstaddr & destname & dlvtime & vldtime & smbody
    	SMSFunction.mitakeSingleCallout SF = new SMSFunction.mitakeSingleCallout();
   
    	string myResult = SF.SendSMS(
			'20561562',
			'bmw37666666',
			inputMobile,
			'',
			'',
			'',
			inputMessage
		);
		
		return myResult;
    }
*/
    
}