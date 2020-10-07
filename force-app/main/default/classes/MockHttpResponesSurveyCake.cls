@isTest
global with sharing class MockHttpResponesSurveyCake implements HttpCalloutMock
{
    global string returnBody = '';

    global MockHttpResponesSurveyCake()
    {
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        returnBody = '{"svid":"5566", "title":"1234", "submitTime":"123","result":['+
            '{"subject":"您的姓氏","type":"TXTSHORT","sn":1,"answer":["a"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"您的名字","type":"TXTSHORT","sn":2,"answer":["a"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"性別","type":"TXTSHORT","sn":3,"answer":["男性"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":4,"answer":["20 歲以下"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":41,"answer":["21-30 歲"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":42,"answer":["31-40 歲"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":43,"answer":["41-50 歲"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":44,"answer":["51-60 歲"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":45,"answer":["61-70 歲"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"年齡","type":"TXTSHORT","sn":46,"answer":["70 歲以上"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"電話","type":"TXTSHORT","sn":15,"answer":["0911123456"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"電子郵件","type":"TXTSHORT","sn":6,"answer":["5566@5566.com"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"所屬門市","type":"TXTSHORT","sn":7,"answer":["a"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"請選擇您欲前往的展示中心","type":"TXTSHORT","sn":8,"answer":["a","b","c"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"您是否願意收到BMW品牌活動或新車相關資訊","type":"TXTSHORT","sn":9,"answer":["好，我想了解更多BMW相關資訊"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"下列哪個系列是您最感興趣的BMW車款(至多選擇三項)","type":"TXTSHORT","sn":10,"answer":["a","b","c"],"otherAnswer":["a","b","c"]},'+
            '{"subject":"請填入指定的銷售顧問姓名","type":"TXTSHORT","sn":11,"answer":["a","b","c"],"otherAnswer":["a","b","c"]}'+
            '] }';
        Blob CryptoKey = blob.valueof('5566556655665566');
        Blob CryptoIV = blob.valueof('5566556655665566');
        Blob ClearData = blob.valueOf(returnBody);
        Blob EncryptedData;
        EncryptedData = Crypto.encrypt('AES128', CryptoKey, CryptoIV, ClearData);
        returnBody = EncodingUtil.base64Encode(EncryptedData);
        res.setBody(returnBody);
        res.setStatusCode(200);
        return res;
    }
}