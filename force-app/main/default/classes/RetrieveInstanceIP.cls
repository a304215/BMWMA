/* =========================================
 * 定時取得IP位置
 *
 * =========================================*/

public without sharing class RetrieveInstanceIP {
    
    public static void GetIP(){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://icanhazip.com/');
        req.setMethod('GET');
        Http httpReq = new Http();
        HttpResponse res = httpReq.send(req);
        System.debug(res.getBody());
        
        LINE_Account__c tempAcc = [
            select id 
            from LINE_Account__c
            where Brand__c = 'BMW'
        ];
        
        tempAcc.InstanceIP__c = res.getBody();
        update tempAcc;    
        
    }
}