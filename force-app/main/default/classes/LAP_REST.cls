/*==============================================================
 * LAP API。
 *
 *
 *==============================================================*/
@RestResource(urlMapping='/LAP_REST/*') 
global without sharing class LAP_REST 
{
    @HttpPost 
    global static void doPost() 
    {
        //設定RestRequest
		RestRequest restReq = RestContext.request;
        String APIAction = restReq.requestURI.substring(restReq.requestURI.lastIndexOf('/')+1);
        system.debug(APIAction);
        
        //API-2 User Register
        if(APIAction == 'lap_user_reg')
        {
            RestResponse res = LAP_REST.lap_user_reg(restReq);
        }
        //API-3 Mobile Validation
        else if(APIAction == 'lap_mobile_val')
        {
            RestResponse res = LAP_REST.lap_mobile_val(restReq);
        }
        //API-4 Resend Mobile Validation
        else if(APIAction == 'lap_resend_mobile_val')
        {
            RestResponse res = LAP_REST.lap_resend_mobile_val(restReq);
        }
        //API-5 User Login
        else if(APIAction == 'lap_user_val')
        {
            RestResponse res = LAP_REST.lap_user_val(restReq);
        }
        //API-6 Forget Password Request
        else if(APIAction == 'lap_forget_pwd')
        {
            RestResponse res = LAP_REST.lap_forget_pwd(restReq);
        }
        //API-7 Reset Password
        else if(APIAction == 'lap_reset_pwd')
        {
            RestResponse res = LAP_REST.lap_reset_pwd(restReq);
        }
        //API-8 Check Session
        else if(APIAction == 'lap_session')
        {
            RestResponse res = LAP_REST.lap_session(restReq);
        }
        //API-9 User Logout
        else if(APIAction == 'lap_user_out')
        {
            RestResponse res = LAP_REST.lap_user_out(restReq);
        }
        else
        {
            outputResponse queryData =  new outputResponse();
            queryData.code = '-1';
            queryData.tempDesc = '無對應Function，請檢查URL。'+restReq.requestURI;
            queryData.data = new outputData();
            RestResponse res 	= Restcontext.response;
            res.responseBody = Blob.valueOf(queryData.toJSON());
            system.debug(queryData.toJSON());
        }
    }

    //一開api 的output
    public class outputResponse
    {
        public string code {get; set;}
        public string tempDesc {get; set;}
        public outputData data {get; set;}
        public outputResponse(){}
        
        public string toJSON()
        {
            JSONGenerator g = JSON.createGenerator(false);
            g.writeStartObject();
            g.writeStringField('code', code);
            g.writeStringField('desc', tempDesc);
            g.writeFieldName('data');
            g.writeStartObject();
            if(data.status!=null)
            {
                g.writeStringField('status', data.status);
            }
            if(data.tempDesc!=null)
            {
                g.writeStringField('desc', data.tempDesc);
            }
            if(data.session!=null)
            {
                g.writeStringField('session', data.session);
            }
            if(data.displayName!=null)
            {
                g.writeStringField('displayName', data.displayName);
            }
            if(data.mobile!=null)
            {
                g.writeStringField('mobile', data.mobile);
            }
            if(data.email!=null)
            {
                g.writeStringField('email', data.email);
            }
            if(data.gender!=null)
            {
                g.writeStringField('gender', data.gender);
            }
            if(data.birthday!=null)
            {
                g.writeStringField('birthday', data.birthday);
            }
            if(data.brand!=null)
            {
                g.writeStringField('brand', data.brand);
            }
            if(data.hasUnconfirmCar!=null)
            {
                g.writeStringField('hasUnconfirmCar', data.hasUnconfirmCar);
            }
            /*
            if(data.licenseP!=null)
            {
                g.writeFieldName('licenseP');
                g.writeStartArray();
                for(string loopStr: data.licenseP)
                {
                    g.writeString(loopStr);
                }
                g.writeEndArray();
            }
            */
            if(data.vehicles!=null)
            {
                g.writeFieldName('vehicles');
                g.writeStartArray();
                for(vehicleData loopV: data.vehicles)
                {
                    g.writeStartObject();
                    g.writeStringField('carGeneration', loopV.carGeneration);
                    g.writeStringField('carType', loopV.carType);
                    g.writeStringField('carNumber', loopV.carNumber);
                    //g.writeStringField('isValid', loopV.isValid);
                    g.writeEndObject();
                }
                g.writeEndArray();
            }
            g.writeEndObject();
            g.writeEndObject();
            return g.getAsString();
        }
    }

    public class outputData
    {
        public string status {get; set;}
        public string tempDesc {get; set;}
        public string session {get; set;}
        public string displayName {get; set;}
        public string mobile {get; set;}
        public string email {get; set;}
        public string gender {get; set;}
        public string birthday {get; set;}
        public string brand {get; set;}
        public string hasUnconfirmCar {get; set;}
        public string cid {get; set;}
        //public list<string> licenseP {get; set;}
        public list<vehicleData> vehicles {get; set;}
        public outputData(){}
    }

    public class vehicleData
    {
        public string carGeneration {get; set;}
        public string carType {get; set;}
        public string carNumber {get; set;}
        //public string isValid {get; set;}

        public vehicleData(){}
    }

    public class lapData
    {
        public string name {get; set;}
        public string username {get; set;}
        public string password {get; set;}
        public string brand {get; set;}
        public string code {get; set;}
        public string oldPwd {get; set;}
        public string newPwd {get; set;}
        public string session {get; set;}
        //加入姓氏 名字 性別 同意條款
        public string LastName {get; set;}
        public string FirstName {get; set;}
        public string Gender {get; set;}
        public boolean Agreement {get; set;}

        public lapData(){}
    }

    //API-2 User Register
    public static RestResponse lap_user_reg(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = user_reg(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-2 User Register-innerfunction
    public static outputResponse user_reg(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CustomerUser__c> userList = [
            select id 
            from CustomerUser__c
            where Mobile__c=:tmpDataModel.username
            and Brand__c=:tmpDataModel.brand
        ];

        //代表已經註冊過了。
        if(userList.size() >0)
        {
            queryData.data.status = '2';
            queryData.data.tempDesc = '已註冊過';
        }
        else
        //要加寄簡訊
        {
            Savepoint sp;
            try 
            {
                //用太多了暫時不要發簡訊
                /*
                //Generate Mobile Code
                String valifyCode;
			    valifyCode = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
                //Send SMS
                SMSFunction SF = new SMSFunction();
                SF.myPhone = tmpDataModel.username;
                SF.smbody = '【BMW Taiwan Line官方帳號】親愛的會員您好，您的手機驗證碼為:'+valifyCode+'，請在5分鐘內提交驗證碼以繼續完成註冊流程，謝謝!';
                SF.mitakeSingleCallout();
*/
             
                sp = Database.setSavepoint();
                
                Entity__c tempEntity = new Entity__c();
                tempEntity.name = tmpDataModel.username;
                tempEntity.Mobile__c = tmpDataModel.username;
                upsert tempEntity Mobile__c;

                if(tmpDataModel.password == null)
                {
                    tmpDataModel.password = '1234';
                }
    
                string encryptedPassword = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(tmpDataModel.password)));

                CustomerUser__c newUser = new CustomerUser__c();
                newUser.name = tmpDataModel.name;
                newUser.Entity__c = tempEntity.id;
                newUser.EXID__c = tmpDataModel.brand+'_'+tmpDataModel.username;
                newUser.MD5Pwd__c = encryptedPassword;
                newUser.Brand__c = tmpDataModel.brand;
                newUser.Mobile__c =tmpDataModel.username;
                newUser.Source__c = inputSource;
                newUser.LastName__c = tmpDataModel.LastName;
                newUser.FirstName__c = tmpDataModel.FirstName;
                newUser.Gender__c = tmpDataModel.Gender;
                newUser.Agreement__c = tmpDataModel.Agreement;
                insert newUser;
                
                SMS_Log__c newlog = new SMS_Log__c();
                //先不要發簡訊 註解下面那行 給一個固定的
                //newlog.Validate_Code__c = valifyCode;
                newlog.Validate_Code__c = '123456';
                newlog.Validate_ExpireTime__c = system.now().addminutes(5);
                //newlog.Validate_Code_Sent_Result__c = SF.mitakeSingleCallout();
                newlog.MobilePhone__c = tmpDataModel.username;
                newlog.CustomerUser__c = newUser.id;
                insert newLog; 
                
                queryData.data.status = '1';
                queryData.data.tempDesc = '已發送驗證碼';           
            } 
            
            catch (exception ex) 
            {
                Database.rollback(sp);
                queryData.code = '-1';
                queryData.tempDesc = ex.getMessage();
                queryData.data = new outputData();
            }
        }

        return queryData;
    }

    //API-3 Mobile Validation
    public static RestResponse lap_mobile_val(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = mobile_val(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-3 Mobile Validation-innerfunction
    public static outputResponse mobile_val(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<SMS_Log__c> smslist = [
            select id, Validate_Code__c, Validate_ExpireTime__c, CustomerUser__c
            from SMS_Log__c
            where MobilePhone__c=:tmpDataModel.username
            and Validate_Code__c=:tmpDataModel.code
            order by createddate desc
        ];
        
        //有正確的簡訊紀錄。
        if(smslist.size() >0)
        {
            if(smslist[0].CustomerUser__c == null)
            {
                queryData.data.status = '2';
                queryData.data.tempDesc = '認證碼錯誤';
                queryData.data.session = '';
            }
            else
            {
                if(system.now() <= smslist[0].Validate_ExpireTime__c )
                {
                    Savepoint sp = Database.setSavepoint();

                    try 
                    {
                        CustomerUser__c tempUser = new CustomerUser__c();
                        tempUser.Validate__c = true;
                        tempUser.id = smslist[0].CustomerUser__c;
                        update tempUser;

                        CALoginLog__c newLog = new CALoginLog__c();
                        newLog.Session__c = LAP_REST.generateRandom(32);
                        newLog.SessionExpireTime__c = system.now().addHours(8);
                        newLog.SourceIP__c = inputSource;
                        newLog.LoginStatus__c = '成功';
                        newLog.Type__c = '註冊';
                        newLog.CustomerUser__c = smslist[0].CustomerUser__c;
                        newLog.UserName__c = tmpDataModel.username;
                        insert newLog;

                        queryData.data.status = '1';
                        queryData.data.tempDesc = '認證通過';
                        queryData.data.session = newLog.Session__c;
                    }
                    catch (exception ex) 
                    {
                        Database.rollback(sp);
                        queryData.code = '-1';
                        queryData.tempDesc = ex.getMessage();
                        queryData.data = new outputData();
                    }                
                }
                else
                {
                    queryData.data.status = '2';
                    queryData.data.tempDesc = '認證碼過期';
                    queryData.data.session = '';
                }
            }
        }
        else
        {
            queryData.data.status = '3';
            queryData.data.tempDesc = '認證碼錯誤';
            queryData.data.session = '';
        }

        return queryData;
    }

    //API-4 Resend Mobile Validation
    public static RestResponse lap_resend_mobile_val(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = resend_mobile_val(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-4 Resend Mobile Validation-innerfunction
    public static outputResponse resend_mobile_val(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CustomerUser__c> userlist = [
            select id 
            from CustomerUser__c
            where Mobile__c=:tmpDataModel.username
            and Brand__c=:tmpDataModel.brand
        ];
        
        //使用者存在。
        if(userlist.size() >0)
        {
            Savepoint sp;
            //Savepoint sp = Database.setSavepoint();
            try 
            {
                
                //用太多了暫時不要發簡訊
                
                //Generate Mobile Code
                String valifyCode;
			    valifyCode = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
                //Send SMS
                SMSFunction SF = new SMSFunction();
                SF.myPhone = tmpDataModel.username;
                SF.smbody = '【BMW Taiwan Line官方帳號】親愛的會員您好，您的手機驗證碼為:'+valifyCode+'，請在5分鐘內提交驗證碼以繼續完成註冊流程，謝謝!';
                SF.mitakeSingleCallout();
               
                sp = Database.setSavepoint();
                
                SMS_Log__c newlog = new SMS_Log__c();
                //先不要發簡訊 註解下面那行 給一個固定的
                newlog.Validate_Code__c = valifyCode;
                //newlog.Validate_Code__c = '5566';
                newlog.Validate_ExpireTime__c = system.now().addminutes(5);
                newlog.MobilePhone__c = tmpDataModel.username;
                newlog.CustomerUser__c = userlist[0].id;
                insert newLog;       
            
                queryData.data.status = '1';
                queryData.data.tempDesc = '已發送';
            } 
            catch (exception ex) 
            {
                Database.rollback(sp);
                queryData.code = '-1';
                queryData.tempDesc = ex.getMessage();
                queryData.data = new outputData();
            }
        }
        else
        {
            queryData.data.status = '2';
            queryData.data.tempDesc = '查無使用者';
        }

        return queryData;
    }

    //API-5 User Login
    public static RestResponse lap_user_val(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = user_val(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-5 User Login-innerfunction
    public static outputResponse user_val(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CustomerUser__c> userlist = [
            select id, MD5Pwd__c, Name, Mobile__c, Brand__c, Validate__c,
                Email__c, Gender__c, Birthday__c
            from CustomerUser__c
            where Mobile__c=:tmpDataModel.username
            and Brand__c=:tmpDataModel.brand
        ];
        
        //抓未驗證車牌0924
        list<BindingAsset__c> NotVerifyAssetList = [
            select id, Asset__r.NumberPlate__c, Asset__r.CarType__c, Asset__r.PurchaseDate, Asset_UserText__c, IsDelete__c
            from BindingAsset__c
            where IsDelete__c = false
            and CreateCase__c = true
            and Entity__r.name =:tmpDataModel.username
        ];
        
        //使用者存在。
        if(userlist.size() >0)
        {
            string encryptedPassword = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(tmpDataModel.password)));
            
            if(encryptedPassword.equals(userlist[0].MD5Pwd__c))
            {
                Savepoint sp = Database.setSavepoint();
                try 
                {
                    if(userlist[0].Validate__c)
                    {   
                        if(NotVerifyAssetList.size() == 0)
                        {
                            CALoginLog__c newLog = new CALoginLog__c();
                            newLog.Session__c = LAP_REST.generateRandom(32);
                            newLog.SessionExpireTime__c = system.now().addHours(8);
                            newLog.SourceIP__c = inputSource;
                            newLog.LoginStatus__c = '成功';
                            newLog.Type__c = '登入';
                            newLog.CustomerUser__c = userlist[0].id;
                            newLog.UserName__c = tmpDataModel.username;
                            insert newLog;
                            
                            queryData.data.status = '1';
                            queryData.data.tempDesc = '登入成功';
                            queryData.data.session = newLog.Session__c;
                            queryData.data.displayName = userlist[0].Name;
                            queryData.data.mobile = userlist[0].mobile__c;
                            queryData.data.email = (userlist[0].Email__c!=null?userlist[0].Email__c:'');
                            queryData.data.gender = (userlist[0].Gender__c!=null?(userlist[0].Gender__c=='男'?'1':'2'):'');
                            queryData.data.birthday = (userlist[0].Birthday__c!=null?DateTime.newInstance(userlist[0].Birthday__c.year(),userlist[0].Birthday__c.month(),userlist[0].Birthday__c.day()+1).format('YYYYMMDD'):'');
                            queryData.data.brand = userlist[0].brand__c;
                            queryData.data.hasUnconfirmCar = '0';
                            queryData.data.vehicles = new list<vehicleData>();
                            {
                                for (BindingAsset__c BindingList:[
                                    select id, Asset__r.NumberPlate__c, Asset__r.CarType__c, Asset__r.CarModel_Assest__c, 
                                           IsDelete__c, IsActive__c
                    				from BindingAsset__c
                   				    where IsActive__c = true
                                    and IsDelete__c = false
                                    and Entity__r.name =:tmpDataModel.username
                                ])
                                {
                                    vehicleData tempV1 = new vehicleData();
                                    tempV1.carGeneration = BindingList.Asset__r.CarModel_Assest__c;
                                    tempV1.carType = BindingList.Asset__r.CarType__c;
                                    tempV1.carNumber =  BindingList.Asset__r.NumberPlate__c.replaceall('-','');
                                    queryData.data.vehicles.add(tempV1);
                                }
                            }
                            /*
                            {
                                vehicleData tempV1 = new vehicleData();
                                tempV1.carGeneration = 'F06';
                                tempV1.carType = 'M6 Gran Coupe';
                                tempV1.carNumber = 'AAA-1234'.replaceall('-','');
                                //tempV1.isValid = '1';
                                queryData.data.vehicles.add(tempV1);
                            }
                            
                            {
                                vehicleData tempV1 = new vehicleData();
                                tempV1.carGeneration = 'F02';
                                tempV1.carType = '740Li';
                                tempV1.carNumber = 'BBB-1234'.replaceall('-','');
                                //tempV1.isValid = '1';
                                queryData.data.vehicles.add(tempV1);
                            }
                            {
                                vehicleData tempV1 = new vehicleData();
                                tempV1.carGeneration = 'F01';
                                tempV1.carType = '730i';
                                tempV1.carNumber = 'CCC-1234'.replaceall('-','');
                                //tempV1.isValid = '2';
                                queryData.data.vehicles.add(tempV1);
                            }
                            */
                        }
                        else
                        {
                          CALoginLog__c newLog = new CALoginLog__c();
                          newLog.Session__c = LAP_REST.generateRandom(32);
                          newLog.SessionExpireTime__c = system.now().addHours(8);
                          newLog.SourceIP__c = inputSource;
                          newLog.LoginStatus__c = '成功';
                          newLog.Type__c = '登入';
                          newLog.CustomerUser__c = userlist[0].id;
                          newLog.UserName__c = tmpDataModel.username;
                          insert newLog;
                            
                          queryData.data.status = '1';
                          queryData.data.tempDesc = '登入成功';
                          queryData.data.session = newLog.Session__c;
                          queryData.data.displayName = userlist[0].Name;
                          queryData.data.mobile = userlist[0].mobile__c;
                          queryData.data.email = (userlist[0].Email__c!=null?userlist[0].Email__c:'');
                          queryData.data.gender = (userlist[0].Gender__c!=null?(userlist[0].Gender__c=='男'?'1':'2'):'');
                          queryData.data.birthday = (userlist[0].Birthday__c!=null?DateTime.newInstance(userlist[0].Birthday__c.year(),userlist[0].Birthday__c.month(),userlist[0].Birthday__c.day()+1).format('YYYYMMDD'):'');
                          queryData.data.brand = userlist[0].brand__c;
                          queryData.data.hasUnconfirmCar = '1';
                          queryData.data.vehicles = new list<vehicleData>();
                          {
                              for (BindingAsset__c BindingList:[
                                  select id, Asset__r.NumberPlate__c, Asset__r.CarType__c, Asset__r.CarModel_Assest__c, 
                                  IsDelete__c, IsActive__c
                                  from BindingAsset__c
                                  where IsActive__c = true
                                  and IsDelete__c = false
                                  and Entity__r.name =:tmpDataModel.username
                              ])
                              {
                                  vehicleData tempV1 = new vehicleData();
                                  tempV1.carGeneration = BindingList.Asset__r.CarModel_Assest__c;
                                  tempV1.carType = BindingList.Asset__r.CarType__c;
                                  tempV1.carNumber =  BindingList.Asset__r.NumberPlate__c.replaceall('-','');
                                  queryData.data.vehicles.add(tempV1);
                              }
                           }
                        }
                        /*
                        queryData.data.licenseP = new list<string>();
                        queryData.data.licenseP.add('LKK-5566');
                        queryData.data.licenseP.add('SPP-1122');
                        */
                    }
                    else
                    {
                        CALoginLog__c newLog = new CALoginLog__c();
                        newLog.Session__c = LAP_REST.generateRandom(32);
                        newLog.SessionExpireTime__c = system.now().addHours(8);
                        newLog.SourceIP__c = inputSource;
                        newLog.LoginStatus__c = '成功';
                        newLog.Type__c = '登入';
                        newLog.CustomerUser__c = userlist[0].id;
                        newLog.UserName__c = tmpDataModel.username;
                        insert newLog;

                        queryData.data.status = '2';
                        queryData.data.tempDesc = '未完成手機認證';
                        queryData.data.session = '';
                        queryData.data.displayName = userlist[0].Name;
                        queryData.data.mobile = userlist[0].mobile__c;
                        queryData.data.email = (userlist[0].Email__c!=null?userlist[0].Email__c:'');
                        queryData.data.gender = (userlist[0].Gender__c!=null?(userlist[0].Gender__c=='男'?'1':'2'):'');
                        queryData.data.birthday = (userlist[0].Birthday__c!=null?DateTime.newInstance(userlist[0].Birthday__c.year(),userlist[0].Birthday__c.month(),userlist[0].Birthday__c.day()+1).format('YYYYMMDD'):'');
                        queryData.data.brand = userlist[0].brand__c;
                        //queryData.data.licenseP = new list<string>();
                        queryData.data.vehicles = new list<vehicleData>();
                    }
                } 
                catch (exception ex) 
                {
                    Database.rollback(sp);
                    queryData.code = '-1';
                    queryData.tempDesc = ex.getMessage();
                    queryData.data = new outputData();

                    CALoginLog__c newLog = new CALoginLog__c();
                    newLog.SourceIP__c = inputSource;
                    newLog.LoginStatus__c = '失敗';
                    newLog.Type__c = '登入';
                    newLog.CustomerUser__c = userlist[0].id;
                    newLog.UserName__c = tmpDataModel.username;
                    insert newLog;
                }
            }
            else
            {
                queryData.data.status = '3';
                queryData.data.tempDesc = '密碼錯誤';
                queryData.data.session = '';
                queryData.data.displayName = '';
                queryData.data.mobile = '';
                queryData.data.email = '';
                queryData.data.gender = '';
                queryData.data.birthday = '';
                queryData.data.brand = '';
                //queryData.data.licenseP = new list<string>();
                queryData.data.vehicles = new list<vehicleData>();

                CALoginLog__c newLog = new CALoginLog__c();
                newLog.SourceIP__c = inputSource;
                newLog.LoginStatus__c = '密碼錯誤';
                newLog.Type__c = '登入';
                newLog.CustomerUser__c = userlist[0].id;
                newLog.UserName__c = tmpDataModel.username;
                insert newLog;
            }
        }
        else
        {
            queryData.data.status = '4';
            queryData.data.tempDesc = '查無使用者';
            queryData.data.session = '';
            queryData.data.displayName = '';
            queryData.data.mobile = '';
            queryData.data.email = '';
            queryData.data.gender = '';
            queryData.data.birthday = '';
            queryData.data.brand = '';
            //queryData.data.licenseP = new list<string>();
            queryData.data.vehicles = new list<vehicleData>();

            CALoginLog__c newLog = new CALoginLog__c();
            newLog.SourceIP__c = inputSource;
            newLog.LoginStatus__c = '查無使用者';
            newLog.Type__c = '登入';
            newLog.UserName__c = tmpDataModel.username;
            insert newLog;
        }

        return queryData;
    }

    //API-6 Forget Password Request
    public static RestResponse lap_forget_pwd(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = forget_pwd(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-6 Forget Password Request-innerfunction
    public static outputResponse forget_pwd(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CustomerUser__c> userlist = [
            select id
            from CustomerUser__c
            where Mobile__c=:tmpDataModel.username
            and Brand__c=:tmpDataModel.brand
        ];
        
        //使用者存在。
        if(userlist.size() >0)
        {
            string descryptedPassword = LAP_REST.generateRandom(8);
            //給一個固定的密碼
            //string descryptedPassword = '1234';
            string encryptedPassword = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(descryptedPassword)));
            
            Savepoint sp;
            //Savepoint sp = Database.setSavepoint();
            try 
            { 
                //用太多了暫時不要發簡訊
                
                //Send SMS
                SMSFunction SF = new SMSFunction();
                SF.myPhone = tmpDataModel.username;
                SF.smbody = 'BMW會員通知，您的新密碼為:'+descryptedPassword+'，請重新登入，謝謝';
                SF.mitakeSingleCallout();


                sp = Database.setSavepoint();
                
                SMS_Log__c newlog = new SMS_Log__c();
                newlog.Validate_Code__c = 'resetPWD:'+descryptedPassword;
                //newlog.Validate_Code__c = '1234';
                newlog.MobilePhone__c = tmpDataModel.username;
                newlog.CustomerUser__c = userlist[0].id;
                insert newLog;

                userlist[0].MD5Pwd__c = encryptedPassword;
                update userlist[0];

                queryData.data.status = '1';
                queryData.data.tempDesc = '已發送';
            } 
            catch (exception ex) 
            {
                Database.rollback(sp);
                queryData.code = '-1';
                queryData.tempDesc = ex.getMessage();
                queryData.data = new outputData();
            }
           
        }
        else
        {
            queryData.data.status = '2';
            queryData.data.tempDesc = '查無使用者';
        }

        return queryData;
    }

    //API-7 Reset Password
    public static RestResponse lap_reset_pwd(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = reset_pwd(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-7 Reset Password
    public static outputResponse reset_pwd(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CustomerUser__c> userlist = [
            select id, MD5Pwd__c
            from CustomerUser__c
            where Mobile__c=:tmpDataModel.username
            and Brand__c=:tmpDataModel.brand
        ];
        
        //使用者存在。
        if(userlist.size() >0)
        {
            string encryptedPassword = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(tmpDataModel.oldPwd)));
            
            if(encryptedPassword.equals(userlist[0].MD5Pwd__c))
            {
                //Savepoint sp = Database.setSavepoint();
                Savepoint sp;
                try 
                {
                    sp = Database.setSavepoint();
                    string encryptedPassword2 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(tmpDataModel.newPwd)));
                    userlist[0].MD5Pwd__c = encryptedPassword2;
                    update userlist[0];

                    queryData.data.status = '1';
                    queryData.data.tempDesc = '變更成功';
                }
                catch (exception ex) 
                {
                    Database.rollback(sp);
                    queryData.code = '-1';
                    queryData.tempDesc = ex.getMessage();
                    queryData.data = new outputData();
                }
            }
            else
            {
                queryData.data.status = '2';
                queryData.data.tempDesc = '舊密碼錯誤';
            }
        }
        else
        {
            queryData.data.status = '3';
            queryData.data.tempDesc = '查無使用者';
        }

        return queryData;
    }

    //API-8 Check Session
    public static RestResponse lap_session(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = session(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-8 Check Session-innerfunction
    public static outputResponse session(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CALoginLog__c> loglist = [
            select id, Session__c, SessionExpireTime__c, LoginStatus__c,
            CustomerUser__r.Name, CustomerUser__r.mobile__c, CustomerUser__r.brand__c,
            CustomerUser__r.Email__c, CustomerUser__r.Gender__c, CustomerUser__r.Birthday__c, CustomerUser__c
            from CALoginLog__c
            where Session__c=:tmpDataModel.Session
            and CustomerUser__r.brand__c=:tmpDataModel.brand
            and LoginStatus__c in ('成功')
        ];
        
        //session存在。
        if(loglist.size() >0)
        {
            if(loglist[0].SessionExpireTime__c >= system.now())
            {
                Savepoint sp = Database.setSavepoint();
                try 
                {
                    queryData.data.status = '1';
                    queryData.data.tempDesc = '可使用';
                    queryData.data.cid = loglist[0].CustomerUser__c;
                    queryData.data.displayName = loglist[0].CustomerUser__r.Name;
                    queryData.data.mobile = loglist[0].CustomerUser__r.mobile__c;
                    queryData.data.email = loglist[0].CustomerUser__r.Email__c;
                    queryData.data.gender = (loglist[0].CustomerUser__r.Gender__c!=null?(loglist[0].CustomerUser__r.Gender__c=='男'?'1':'2'):'');
                    queryData.data.birthday = (loglist[0].CustomerUser__r.Birthday__c!=null)?DateTime.newInstance(loglist[0].CustomerUser__r.Birthday__c.year(),loglist[0].CustomerUser__r.Birthday__c.month(),loglist[0].CustomerUser__r.Birthday__c.day()+1).format('YYYYMMDD'):'';
                    queryData.data.brand = loglist[0].CustomerUser__r.brand__c;
                    queryData.data.hasUnconfirmCar = '0';
                    queryData.data.vehicles = new list<vehicleData>();
                    {
                        vehicleData tempV1 = new vehicleData();
                        tempV1.carGeneration = 'F06';
                        tempV1.carType = 'M6 Gran Coupe';
                        tempV1.carNumber = 'AAA-1234'.replaceall('-','');
                        //tempV1.isValid = '1';
                        queryData.data.vehicles.add(tempV1);
                    }
                    {
                        vehicleData tempV1 = new vehicleData();
                        tempV1.carGeneration = 'F02';
                        tempV1.carType = '740Li';
                        tempV1.carNumber = 'BBB-1234'.replaceall('-','');
                        //tempV1.isValid = '1';
                        queryData.data.vehicles.add(tempV1);
                    }
                    {
                        vehicleData tempV1 = new vehicleData();
                        tempV1.carGeneration = 'F01';
                        tempV1.carType = '730i';
                        tempV1.carNumber = 'CCC-1234'.replaceall('-','');
                        //tempV1.isValid = '2';
                        queryData.data.vehicles.add(tempV1);
                    }
                    /*
                    queryData.data.licenseP = new list<string>();
                    queryData.data.licenseP.add('LKK-5566');
                    queryData.data.licenseP.add('SPP-1122');
                    */
                }
                catch (exception ex) 
                {
                    Database.rollback(sp);
                    queryData.code = '-1';
                    queryData.tempDesc = ex.getMessage();
                    queryData.data = new outputData();
                }
            }
            else
            {
                queryData.data.status = '2';
                queryData.data.tempDesc = '已過期';
                queryData.data.displayName = '';
                queryData.data.mobile = '';
                queryData.data.email = '';
                queryData.data.gender = '';
                queryData.data.birthday = '';
                queryData.data.brand = '';
                queryData.data.hasUnconfirmCar = '';
                queryData.data.vehicles = new list<vehicleData>();
            }
        }
        else
        {
            queryData.data.status = '2';
            queryData.data.tempDesc = '已過期';
            queryData.data.displayName = '';
            queryData.data.mobile = '';
            queryData.data.email = '';
            queryData.data.gender = '';
            queryData.data.birthday = '';
            queryData.data.brand = '';
            queryData.data.hasUnconfirmCar = '';
            queryData.data.vehicles = new list<vehicleData>();
        }

        return queryData;
    }

    //API-9 User Logout
    public static RestResponse lap_user_out(RestRequest InputRestReq)
    {
        system.debug('body: ' + InputRestReq.requestBody.toString());
        lapData tmpDataModel = (lapData)System.JSON.deserialize(InputRestReq.requestBody.toString(), lapData.class);
        //拆出來當function
        outputResponse queryData = user_out(tmpDataModel, InputRestReq.remoteAddress);
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        system.debug(queryData.toJSON());
        return res;
    }

    //API-9 User Logout-innerfunction
    public static outputResponse user_out(lapData InputData, string inputSource)
    {
        lapData tmpDataModel = InputData;

        outputResponse queryData =  new outputResponse();
        queryData.code = '0';
        queryData.tempDesc = '';
        queryData.data = new outputData();

        list<CALoginLog__c> loglist = [
            select id, Session__c, SessionExpireTime__c, LoginStatus__c,
            CustomerUser__r.Name, CustomerUser__r.mobile__c, CustomerUser__r.brand__c
            from CALoginLog__c
            where Session__c=:tmpDataModel.Session
            and CustomerUser__r.brand__c=:tmpDataModel.brand
            and LoginStatus__c in ('成功')
        ];
        
        //session存在。
        if(loglist.size() >0)
        {
            if(loglist[0].SessionExpireTime__c >= system.now())
            {
                Savepoint sp = Database.setSavepoint();
                try 
                {
                    loglist[0].SessionExpireTime__c = system.now();
                    update loglist[0];

                    queryData.data.status = '1';
                    queryData.data.tempDesc = '已成功登出';
                }
                catch (exception ex) 
                {
                    Database.rollback(sp);
                    queryData.code = '-1';
                    queryData.tempDesc = ex.getMessage();
                    queryData.data = new outputData();
                }
            }
            else
            {
                queryData.data.status = '1';
                queryData.data.tempDesc = '已成功登出';
            }
        }
        else
        {
            queryData.data.status = '1';
            queryData.data.tempDesc = '已成功登出';
        }

        return queryData;
    }

    public static RestResponse Notyet(RestRequest InputRestReq)
    {
        outputResponse queryData =  new outputResponse();
        queryData.code = '-1';
        queryData.tempDesc = '尚未完成修改，請等待。';
        queryData.data = new outputData();
        RestResponse res 	= Restcontext.response;
        res.responseBody = Blob.valueOf(queryData.toJSON());
        return res;
    }

    public static string generateRandom(integer inputLength)
    {
        string allString = 'abcdefghijklmnopqrstuvwxyz0123456789';

        string returnSTR = '';
        integer randomLength = allString.length();
        for(integer i=0; i <inputLength; i++)
        {
        	returnSTR += allString.mid(Math.round(Math.random()*randomLength), 1);    
        }
        return returnSTR;
    }
}