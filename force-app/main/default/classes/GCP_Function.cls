public without sharing class GCP_Function 
{
    public static string uploadFile(string inputCVID, string inputGCP, string inputBucket, string inputFolder)
    {
        list<GCPSetting__mdt> gcpSetting = [
            select client_email__c, private_key__c, token_uri__c
            from GCPSetting__mdt
            where DeveloperName =:inputGCP
        ];

        if(gcpSetting.size() > 0)
        {
            //要移除\N跟private key
            String jwt = generateJWT(
                gcpSetting[0].token_uri__c,
                gcpSetting[0].private_key__c.remove('\\n').remove('-----BEGIN PRIVATE KEY-----').remove('-----END PRIVATE KEY-----'),
                'https://www.googleapis.com/auth/cloud-platform', 
                gcpSetting[0].client_email__c
            );
            Token t = getToken(jwt, gcpSetting[0].token_uri__c);
            System.debug(t);
            return putImage(t, inputCVID, inputBucket, inputFolder);
        }

        return 'NOIMAGE';
    }


    public static Token getToken(String jwt, string tokenURI) {
        Httprequest req = new HttpRequest();
        req.setEndpoint(tokenURI);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');

        String body = '';
        body = 'grant_type='+EncodingUtil.urlEncode('urn:ietf:params:oauth:grant-type:jwt-bearer','UTF-8');
        body += '&assertion='+jwt;
        req.setBody(body);
        system.debug(body);

        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        return (Token)JSON.deserialize(res.getBody(), Token.Class);
    }

    public static String generateJWT(String myURL, String key, String scope, String clientEmail){
        String header = '{"alg":"RS256","typ":"JWT"}';
        String headerUrlBase64Encode = EncodingUtil.base64Encode(Blob.valueOf(header));
        String headerBase64UrlEncode = EncodingUtil.urlEncode(headerUrlBase64Encode, 'UTF-8');

        system.debug(key);
        system.debug(clientEmail);
        long currentTime = datetime.now().getTime()/1000;
        long expiryTime = datetime.now().addHours(1).getTime()/1000;

        ClaimSet claimSet = new ClaimSet();
        claimSet.iss = clientEmail;
        claimSet.scope = scope;
        claimSet.aud = myURL;
        claimSet.exp = expiryTime;
        claimSet.iat = currentTime;

        String clailSetJson = JSON.serialize(claimSet);
        String claimSetBaseEncode = EncodingUtil.base64Encode(Blob.valueOf(clailSetJson));
        String claimSetBase64UrlEncode = EncodingUtil.urlEncode(claimSetBaseEncode, 'UTF-8');

        String algorithmName = 'RSA-SHA256';
        Blob privateKey = EncodingUtil.base64Decode(key);
        Blob input = Blob.valueOf(headerBase64UrlEncode+'.'+claimSetBase64UrlEncode);
        Blob signed = Crypto.sign(algorithmName, input, privateKey);
        String signedBase64Encode = EncodingUtil.base64Encode(signed);
        String signedStrBase64UrlEncode = EncodingUtil.urlEncode(signedBase64Encode, 'UTF-8');

        String jwt = headerBase64UrlEncode+'.'+claimSetBase64UrlEncode+'.'+signedStrBase64UrlEncode;
        return jwt;
    }

    private class ClaimSet{
        private String iss;
        private String scope;
        private String aud;
        private long exp;
        private long iat;
    }

    public class Token{
        private String access_token;
        private String token_type;
        private String expires_in;
    }


    public static string putImage(token inputT, string inputCVID, string inputBucket, string inputFolder)
    {
        ContentVersion myImage = [select id, VersionData, FileType
                                  from ContentVersion 
                                  where contentdocumentid=:inputCVID
                                  order by createddate desc limit 1];

        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://storage.googleapis.com/upload/storage/v1/b/'+inputBucket+'/o?uploadType=media&name='+inputFolder+'/'+inputCVID+'.'+myImage.FileType);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'image/png');
        if(myImage.FileType == 'png')
        {
            httpReq.setHeader('Content-Type', 'image/png');
        }
        if(myImage.FileType == 'jpg')
        {
            httpReq.setHeader('Content-Type', 'image/jpeg');
        }
        if(myImage.FileType == 'mp4')
        {
            httpReq.setHeader('Content-Type', 'video/mp4');
        }
        httpReq.setHeader('Authorization', 'Bearer ' + inputT.access_token);
        
        Blob imageBody = myImage.VersionData;
        httpReq.setBodyAsBlob(imageBody);
        Http http = new Http();
        HttpResponse httpRes = http.send(httpReq);
        string pushResult = httpRes.getBody();
        system.debug('ttt pushResult ' + pushResult);
        cloudStorageClass responseDATA = (cloudStorageClass)JSON.deserialize(pushResult, cloudStorageClass.Class);

        return responseDATA.mediaLink;
    }


    public class cloudStorageClass
    {
        public string kind;
        public string id;
        public string selfLink;
        public string mediaLink;
        public string name;
        public string bucket;
        public string generation;
        public string metageneration;
        public string contentType;
        public string storageClass;
        public string md5Hash;
        public string crc32c;
        public string etag;
        public string timeCreated;
        public string updated;
        public string timeStorageClassUpdated;
        public cloudStorageClass(){}
    }
}