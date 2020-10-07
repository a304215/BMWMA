@RestResource(urlMapping='/Surveyhook/*')
global without sharing class SurveyHook 
{
    @HttpPost
	global static void doPost()
    {
		//設定RestRequest
		RestRequest restReq = RestContext.request;
        //QueryClassData tmpDataModel = (QueryClassData)System.JSON.deserialize(restReq.requestBody.toString(), QueryClassData.class);
		
        outputResponse queryData =  new outputResponse();
        queryData.code = '200';
        queryData.status = 'success!';
        //queryData.message = tmpDataModel.message;
        queryData.message = '';
        queryData.reply = 'Hello World';
        
        map<string, string> ddmap = restReq.params;
        //system.debug('luke: svid: ' + ddmap.get('svid'));
        //system.debug('luke: hash: ' + ddmap.get('hash'));
        
        for(string loopstr: ddmap.keyset())
        {
            system.debug('==key: ' +loopstr);
            system.debug('==val: ' +ddmap.get(loopstr));
        }

        list<Campaign> camList = [
            select id
            from Campaign
            where SVID__c =:ddmap.get('svid')
        ];  

        
        Campaign myCamp = new Campaign();
        if(camList.size() ==0)
        {
            myCamp.Name = 'Survey Cake: ' + ddmap.get('svid');
        }
        myCamp.SVID__c = ddmap.get('svid');
        upsert myCamp SVID__c;

        Survey_Cake__c insertCake = new Survey_Cake__c();
        insertCake.Campaign__c  = myCamp.id;
        insertCake.svid__c = ddmap.get('svid');
        insertCake.hash__c = ddmap.get('hash');
        insertCake.SubmitTime__c = system.now();
        insert insertCake;

        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
    }
    
    @HttpGet
    global static void sayhelloi()
    {
        //設定RestRequest
        RestRequest restReq = RestContext.request;

        outputResponse queryData =  new outputResponse();
        queryData.code = '200';
        queryData.status = 'Not Totally Success!';
        //queryData.message = tmpDataModel.message;
        queryData.message = '請使用POST，不要使用GET';
        queryData.reply = 'Hello World';
        
        RestResponse res    = Restcontext.response;
        res.addHeader('Content-Type', 'text/plain; charset=utf-8');
        res.responseBody = Blob.valueOf(queryData.toJSON());
        res.statusCode= 200;
        system.debug(restReq);
        system.debug(restReq.requestBody.toString());
        system.debug(restReq.requestBody.toString());
        
        task newTask  = new task();
        newTask.subject = 'Survey HOOK:' + system.now().format('yyyyMMddHHmmss');
        newTask.description = restReq.requestBody.toString();
        insert newTask;

        lead tempLead = new lead(lastName='lukeTEST'+system.now().format('MMddHHmmss'));
        insert tempLead;
        
    }
    
    
    //一開api 的output
    public class outputResponse
    {
        public string code {get; set;}
        public string status {get; set;}
        public string message {get; set;}
        public string reply {get; set;}
        public outputResponse(){}
        
        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(true);
            g.writeStartObject();
            g.writeStringField('code', code);
            g.writeStringField('status', status);
            g.writeStringField('message', message);
            g.writeStringField('reply', reply);
            g.writeEndObject();
            return g.getAsString();
        }
    }
    
    //查詢課程Data
    public class QueryClassData
    {
        public string message {get; set;}
        public QueryClassData(){}
    }
}