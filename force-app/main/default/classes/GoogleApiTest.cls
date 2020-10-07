public with sharing class GoogleApiTest {
    // NOTE - DONT PUT THIS KEY HERE IN A PROD SCENARIO - SEE ARTICLE ON SECURE CODING STORING SECRETS
    //private static final String CLIENT_KEY = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDM8JLY0n3j5FgCie1Xi6NM4GaiUBG1D/TcPfAB38eh/LjQs/Wl8ucmBqaHvM6R3whG2FTrfRMqkM+juvCYfRJWwHPgNV+nsKGXLSnwcFSSzuXU+rhdEROK+JK1/YeVuCWSDMHLXR6ayuYhCtYYBpztuNrGDvmaUIVRg6RlMXgRpqbuj8m98OMmFd3JgV+TWhxFTUaOJO/iSDjR3/+iq2GOmhRZNcoVAHseofkiejug5C5XyS8cA8nuMbWGPye5vBlcEuHKCNXhZmhiDlSkHL63lyz1+updgHmCWATK0w8cSfwZzQnqLCuPZfo60Z4XkpUw5rNhuvjQ9q5Sc59ScVeNAgMBAAECggEAR4/P7zddL0kqdER+ZJ4FeVA4doAYFs4KFifomXbvSkCptnLImdh+X3heCTLkPOqRBNAAozRLD4d+gfFClzTBRRqxu75XdwJGAriKFwPafGMTvTGJVDIkzVesPzFW+XBSajPbLeyHxcyI3Evg44XXoWj1t8g932UzkHmz24QRJbQX/a7bt2nE+W+afj8nXM7UBeF/BBHjwccRkIZr9+ukxgiY8UC1A7+6Tfp+x3nwB40oPLKpTJQFG3dlzK3KVfXHr56099nQUUAO35TKXdLT3CRyqX3TD4z5F/5D2atxuFhuhGTo6haYSI+9cgQAFaPVAlzH2b0Fm/IUXmnLpL7MbwKBgQDzgVSEScxLfqASYY7RvI5wRduGow2n7c/TBl0DS/z6qxqpV0KPI8wzoeD6OKlw17qB7ZAI1J1/8lNIuYQVJmLRCacFKK6tFMYGYsIKya1pFgsK+ZalLXA1P6m58YqfTj1VQPibuBsUAM27Vo32Xjp5Ob787b9DctS7EAwkHN4x9wKBgQDXdKZiXMkTdD3KIegN4DZsB8uAQprX2LImeNwK2XImDf9CRIUcofBTWTGi7odAVEhx06FWCCh4PwnurldgmAMk2x4JHPpVPjYNfIfAYqQSXFaF6qTvExnc9rP0XaUuOck1jnkk7ct2X3tmooP8/gw016DFlpzhmwN9vRBGgjnhmwKBgQCkZsIAGq8inVhHcLRzKGHmrVN8gCOdKDMzH023BxvCxbjXcgGPELUyeu2hIpZLiGr0g8bGH35CvwG5zP6/JM58oY6xLflZA/h6oTyu+eDpXSeRfldWJ+plGRlnYAueaL2CDL6Mq+0kQTKlc9ee6ZmC9RjcPUvvpty3eysnSpI9mwKBgGbwhM5aJnf1AdChgo2eomHbF4+gQvr9vaBD/l3wpmkoJt0yf6a+eGRaKSz/af+CRVqdEmhYXX2WINi402aDOn1Rc3hHMBOqNYkcBoAUoO9kzrIM+eB/78ty02fdlh4P3eKIv7i1JJDZ7cuLuiQV/R8CJv5Ah5QCzBg3TJ9jeOQhAoGAVn5Nwys9GDwed1ZYsOBBKFG+yVVtw6GpT+Wz4rsz8nKyQYnU3LW+WDM8ZfY0czuTJ4b9jbytj325MBz9dYzNIblga0YgxcwGexPvb/alnoP9uq7QOIipvebc1k3zDJXdHMVW487tEHgmnQVdmvlI1pzI/lzPiTrUQYeumJqNCNM=';
    //private static final String CLIENT_SCOPE = 'https://www.googleapis.com/auth/cloud-platform';
    //private static final String CLIENT_EMAIL = 'luke56imageupload@civil-sentry-285701.iam.gserviceaccount.com';
    
    private static final String CLIENT_KEY = 'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC2KkVCDK3fe04YVZ9NBuuE9trkdZ1AWOv/tGpzdu5yQ+wm6KWkFMDVQZQPmPlnWXdygmMIJYkHnH1VHehridzF1M5IWUiEqxFo0SOegyQF8NPoL0p75Zal7L/MOMNOPsgNdpjdAvBkaynZNJTDlDRmYBnt9wExa+wTW2YLwZh/UkyLS2sYC8Mhlmd0k1KyPjzLK7zVl81WIwXWC+OBW8t2RZ6N+6r5cKZvs2ye/9I+Dk53b3v3mgpbsYP5gqRzAdfqxu9mp6PNSsz8FzvYuG7rU50k9srvnHtUhYbms/8CiTSgWh/OvDIHbs/qR+jssd9rLbw69mBGB4kx4vC0UtJvAgMBAAECggEASj1d7nYmYl7pS+eRPZ4lXBIS0WrRhIj43URU4evFb9IYqx7DauR+ViscwWKRujnvAT78RzSs7Oos9gRzVWhhDksVKs0gTdk+Bh69ynsdskIcypKDY40E4WhkHkG/7uKNO1drIx9wgyxdaMUSH8cFt/dQeffhh5e5JYZpRz9F/BUH7hKUXJEpACnULSz60ZinM2F2UeJ5JhiTVbv5q2MKSemo8sp3Wdc1iWkBE4hTa41fVryf/Q09zJR/P1tVrBJ6AnfD0drUvdrGNac5zVDFEyE+IUJHpdJLTx+0ULTJNzimNXScaeVPnwsNhBwCMdrG2iY1clmJR4tfvvpFaZjrgQKBgQD02k5lGV0+SuOzLpXSIFhFFQUeIjL6wiw5Mq3oi/KYqBPa14roBYTV4GDk2/OLIVqH6QyH7hbdxJvvCQmuY3ifWsklZMSqIgF0txZ5KgcTYN4RtQYaEy3x3N4ReqYdSfNnE2tKyojoTCmOh8Lu89Lh0TPpk8Asc0AunI1wGHX/QQKBgQC+dVtGqXfNsve2HRcpJrKTcdzNAGPwwUiXf0SRMlgcpVgzaM8wgQNtj/CxmpscVh3530Dy932lKyDHSiRk8+bTPgPOOnMk1Rcjm0zZhv8pwimyolygQl3UVvhK4/V6x8dBnJYskYy/V8/2BxhA2lp28g84UEmYk+zO8uaGqHkVrwKBgQCX826ZQR9jjBg41500lMwSuxO8+p5Gjf/h0ziny0nXQN9pfT//84TXMfMPtAw0+JL1K0SSisf4Ao5+zk4KwkJWKoIPybRenNHoe8LfmJxhg0jtFjleLy7hHR9XG5VBMeZyvlNkS8Kg3rsfb9MidYAWkby0pPOq4i8ffhosSZHYwQKBgGBxSNEVS4cr0uey/2FlKRQkmixswC7PkRS162Ci359R0sHlltT232eBdd5ZbaYBrZg0Bs2BqWwT1LtVvewo3X+mbYLmchv6k4cCQv37sAXTPg4ozUKRmLXHfF9f45RSyYFd62WSJnVV4AazPQLKDvkgRbi8XygV79ozgaw6b2YdAoGBAKdnzxNAa1yoHP+HarAJCOeg/cN4PSeJuN1Y+Lddy94iBKnskEu+H/uELD1ok6oXT3MnallNKvs0YIDmrxeDrDySCHR7RWZfiQ9G2QULAZRnjrG7tu2mhYNHuK/Mmarob9hdxzpc55HPix68qYVVZnI+8bmVXAVdZoT+c2zfuA55';
    private static final String CLIENT_SCOPE = 'https://www.googleapis.com/auth/cloud-platform';
    private static final String CLIENT_EMAIL = 'imageuploader@pgm-line.iam.gserviceaccount.com';
    public string cvid;
    public string picURL;

    public GoogleApiTest(string inputCVId){
        cvid = inputCVId;
        String jwt = generateJWT(CLIENT_KEY, CLIENT_SCOPE, CLIENT_EMAIL);
        Token t = getToken(jwt);
        System.debug(t);
        picURL = putImage(t);
    }

    public Token getToken(String jwt) {
        Httprequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
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

    private String generateJWT(String key, String scope, String clientEmail){
        String header = '{"alg":"RS256","typ":"JWT"}';
        String headerUrlBase64Encode = EncodingUtil.base64Encode(Blob.valueOf(header));
        String headerBase64UrlEncode = EncodingUtil.urlEncode(headerUrlBase64Encode, 'UTF-8');

        long currentTime = datetime.now().getTime()/1000;
        long expiryTime = datetime.now().addHours(1).getTime()/1000;

        ClaimSet claimSet = new ClaimSet();
        claimSet.iss = clientEmail;
        claimSet.scope = scope;
        claimSet.aud = 'https://www.googleapis.com/oauth2/v4/token';
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

    private class Token{
        private String access_token;
        private String token_type;
        private String expires_in;
    }


    public string putImage(token inputT)
    {
        
        system.debug(cvid);
        ContentVersion myImage = [select id, VersionData, FileType
                                  from ContentVersion 
                                  where contentdocumentid=:cvid
                                  order by createddate desc limit 1];

        HttpRequest httpReq = new HttpRequest();
        //httpReq.setEndpoint('https://storage.googleapis.com/upload/storage/v1/b/luke5566/testFolder01/o?uploadType=media&name='+'testIMG.png');
        //httpReq.setEndpoint('https://storage.googleapis.com/upload/storage/v1/b/luke5566/o?uploadType=media&name='+'testFolder01/testIMG1.png');
        httpReq.setEndpoint('https://storage.googleapis.com/upload/storage/v1/b/pgmline/o?uploadType=media&name='+'LineUpload/'+cvid+'.'+myImage.FileType);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'image/png');
        httpReq.setHeader('Authorization', 'Bearer ' + inputT.access_token);
        //system.debug(inputMSG);
        
        Blob imageBody = myImage.VersionData;
        //set here
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