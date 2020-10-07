/*==============================================================
 * 接收門禁系統 API。
 * 
 *
 *==============================================================*/
@RestResource(urlMapping='/accesscontrol/*') 
global without sharing class AccessControler_REST 
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
        if(restURL.startsWith('/accesscontrol/returncar'))
        {
            //requestData tmpDataModel = (requestData)System.JSON.deserialize(restReq.requestBody.toString(), requestData.class);
            task newTask = new task();
            newTask.subject = 'accesscontrol_0_'+system.now().format('YYYYMMDDHHmmss');
            newTask.description = restReq.requestBody.toString();
            insert newTask;
            outputResponse queryData = new outputResponse();
            queryData.code = '0';
            queryData.tempDesc = '';
            RestResponse res = Restcontext.response;
            res.responseBody = Blob.valueOf(queryData.toJSON());
            system.debug(queryData.toJSON());
        }
        //其他URL。
        else 
        {
            //requestData tmpDataModel = (requestData)System.JSON.deserialize(restReq.requestBody.toString(), requestData.class);
            task newTask = new task();
            newTask.subject = 'accesscontrol_1_'+system.now().format('YYYYMMDDHHmmss');
            newTask.description = restReq.requestBody.toString();
            insert newTask;
            outputResponse queryData = new outputResponse();
            queryData.code = '-1';
            queryData.tempDesc = 'URL錯誤';
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
        public outputResponse(){}
        
        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(false);
            g.writeStartObject();
            g.writeStringField('code', code);
            g.writeStringField('desc', tempDesc);
            g.writeEndObject();
            return g.getAsString();
        }
    }
}