@isTest
global with sharing class MockHttpResponesLINE implements HttpCalloutMock
{
    global string returnBody = '';
    global string theType = '';
    
    global MockHttpResponesLINE(string mytype)
    {
        theType = mytype;
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(theType == '')
        {
            returnBody = '{"result: "OK"}';
        }
        else if(theType == 'Line')
        {
            returnBody = '{}';
        }
        else if(theType == 'fb')
        {
            returnBody = '{"status":"0","message":""}';
        }
        else {
            returnBody = '{"result: "OK"}';
        }

        res.setBody(returnBody);
        res.setStatusCode(200);
        return res;
    }
}