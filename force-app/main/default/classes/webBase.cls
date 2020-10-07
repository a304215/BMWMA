Global without sharing virtual class webBase{
    
    public static string mySiteID = site.getSiteId();
    public static string rawSalt = '00000000000000000000000000000000';
    public boolean displayPopup {get; set;}
    public boolean displayLoginPopup {get; set;}
    public boolean displayPwdPopup {get; set;}
    public boolean displayInfoPopup {get; set;}
    public boolean displayCasePopup {get; set;}
    public boolean displayConfirmPopup {get; set;}
    public boolean displayBindingPopup {get; set;}
    public boolean displayReasonPopup {get; set;}
    public Boolean isLogin {get; set;}
    
    public CustomerUser__c loginCustomer {get; set;}
    public string loginEntityId {get; set;}
    public string loginCustomerId {get; set;}
    public string deleteBindingId {get; set;}
    public string rName {get; set;}
    public string sessionid {get; set;}
    public string session {get; set;}
    //public string rMobile {get; set;}
    public String response {get; set;}
    public String status {get; set;}
    public string userLineID {get; set;}
    //public string selectedTab {get; set;}
    public string reason {get; set;}
    public string reasonText {get; set;}
    
    //重設密碼
    public string onetimepassword {get; set;}
	public string oldPwd {get; set;}
	public string newPwd {get; set;}
    
    //手機認證碼
	public string myValifyCode {get; set;}
    public string otp1 {get; set;}
    public string otp2 {get; set;}
    public string otp3 {get; set;}
    public string otp4 {get; set;}
    public string otp5 {get; set;}
    public string otp6 {get; set;}
    
    //車牌綁定
    public string myAsset {get; set;}
    
    //車牌綁定index_map
    public integer indexofBindingAsset {get;set;}
    public integer lastindexofBindingAsset {get;set;}
    public map<BindingAsset__c,integer> BindingAsset_index_map {get;set;} 
    
    //會員資料
    public string myPhone {get; set;}
    public string myPassword {get; set;}
    public string myConfirmPassowrd {get; set;}
    public string myLastName {get; set;}
    public string myFirstName {get; set;}
    public date myBirthday {get; set;}
    public string myEmail {get; set;}
    public string myGender {get; set;}
    public boolean myAgreement {get; set;}
    public string myAddress {get; set;}
    public boolean isEdit {get; set;}
    public boolean isEditAsset {get; set;}
    
    //LIFF V2
	public string urlvalue {get; set;}
	public string LIFFID {get; set;}
    
    public webBase(){
        
        loginCustomer = new CustomerUser__c();
        //SMSFunction SF = new SMSFunction();
        myPhone = '';
        userLineID = '';
        onetimepassword = '';
        isLogin = false;
        isEdit = false;
        isEditAsset = false;
        //getBindingAssetList();
        //checkCustomer();
        //myAsset2 = new list<tempAsset>();
        
        //車牌綁定index_map
        indexofBindingAsset = 0;
        lastindexofBindingAsset = 0;
        BindingAsset_index_map = new map <BindingAsset__c,integer>();

        
        //checkIsLogin();

    }
    
    // Cookie Class
    // 影響第三步密碼/填個人資料
    public void checkIsLogin()
    {
        isLogin = false;
        system.debug('check1');
        /*
        Cookie sessionID = ApexPages.currentPage().getCookies().get('sessionID');
        system.debug(sessionID);
		if (sessionID != null)
        {
            String encodedValue = sessionID.getValue().replaceAll(' ', '+');
            Blob decodedValue = EncodingUtil.base64Decode(encodedValue);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', Blob.valueOf(webBase.rawSalt), decodedValue);
            String finalSessionId = decryptedData.toString().subString(0,32);
            system.debug('check2');
            system.debug(finalSessionId);
            
            LAP_REST.lapData SessionData = new LAP_REST.lapData();
            SessionData.session = finalSessionId;
            SessionData.brand = 'BMW';
            
            //LAP_REST.user_reg(RegisterData, 'LINE');寫一次就好
            LAP_REST.outputResponse myData = LAP_REST.session(SessionData, 'WEBLogin'); 
            
            list<CustomerUser__c> CustomerList =[
            select id, Name, Entity__c, Email__c, EXID__c, MD5Pwd__c,
            FirstName__c, Brand__c, Address__c, LastName__c, Gender__c,
            Mobile__c, Validate__c, Birthday__c, Source__c, Agreement__c
            from CustomerUser__c
            where id =: myData.data.cid
            ];
            system.debug('check3');
            system.debug(myData.data.cid);
            system.debug(myData.tempDesc);
            
            if (CustomerList.size() > 0){
                loginCustomer = CustomerList[0];
                loginCustomerId = CustomerList[0].id;
                isLogin = true;
                myPhone = CustomerList[0].mobile__c;
                system.debug('check4');
                
            //密碼QQ
            list<CustomerUser__c> NoPwdCustomerList =[
            select id, Name, Entity__c, Email__c, EXID__c, MD5Pwd__c,
            FirstName__c, Brand__c, Address__c, LastName__c, Gender__c,
            Mobile__c, Validate__c, Birthday__c, Source__c, Agreement__c
            from CustomerUser__c
            where id =: myData.data.cid
            and MD5Pwd__c = '81dc9bdb52d04dc20036dbd8313ed055'
            ];
            
            if (NoPwdCustomerList.size() > 0){
                displayPwdPopup = true;
                //response = '您尚未完成註冊, 請先設定一組密碼並填寫個人基本資料';
            }
            else if (CustomerList[0].Birthday__c == null || CustomerList[0].Email__c== null){ 
                displayInfoPopup = true;
                }
            else{
                
            }
            }
            else
            {
                //Cookie sessionID1 = new Cookie('sessionID', '', null, 0, false);
				//ApexPages.currentPage().setCookies(new Cookie[]{sessionID1});
				CheckCustomer();
            } 
        }
        */
        //寫給售服要資料的
        session = ApexPages.currentPage().getParameters().get('session');
        system.debug(session);
		if (session != null)
        {
            //String encodedValue = session.replaceAll(' ', '+');
            //Blob decodedValue = EncodingUtil.base64Decode(encodedValue);
            //Blob decryptedData = Crypto.decryptWithManagedIV('AES256', Blob.valueOf(webBase.rawSalt), decodedValue);
            //String finalSessionId = decryptedData.toString().subString(0,32);
            //system.debug('check2');
            //system.debug(finalSessionId);
            
            LAP_REST.lapData SessionData = new LAP_REST.lapData();
            SessionData.session = session;
            SessionData.brand = 'BMW';
            
            //LAP_REST.user_reg(RegisterData, 'LINE');寫一次就好
            LAP_REST.outputResponse myData = LAP_REST.session(SessionData, 'WEBLogin'); 
            
            list<CustomerUser__c> CustomerList =[
            select id, Name, Entity__c, Email__c, EXID__c, MD5Pwd__c,
            FirstName__c, Brand__c, Address__c, LastName__c, Gender__c,
            Mobile__c, Validate__c, Birthday__c, Source__c, Agreement__c
            from CustomerUser__c
            where id =: myData.data.cid
            ];
            system.debug('check3');
            system.debug(myData.data.cid);
            system.debug(myData.tempDesc);
            
            if (CustomerList.size() > 0 && myData.data.status == '1')
            {
                loginCustomer = CustomerList[0];
                loginCustomerId = CustomerList[0].id;
                isLogin = true;
                myPhone = CustomerList[0].mobile__c;
                system.debug('check4');
                
            }
            else
            {
                //Cookie sessionID1 = new Cookie('sessionID', '', null, 0, false);
				//ApexPages.currentPage().setCookies(new Cookie[]{sessionID1});
				//CheckCustomer();
				system.debug('check5');
				gotoService();
                displayLoginPopup = true;
                response = '請重新登入';
            } 
        }
    }
    
    // API-2 User Register
    public PageReference WebRegister()
    {
        system.debug('================WebRegister');
        myPhone = loginCustomer.Mobile__c;
        myLastName = loginCustomer.LastName__c;
        myFirstName = loginCustomer.FirstName__c;
        myGender = loginCustomer.Gender__c;
        myAgreement = loginCustomer.Agreement__c;
        
        LAP_REST.lapData RegisterData = new LAP_REST.lapData();
        RegisterData.name = myLastName + myFirstName;
        RegisterData.LastName = myLastName;
        RegisterData.FirstName = myFirstName;
        RegisterData.Gender = myGender;
        RegisterData.username = myPhone;
        RegisterData.Agreement = myAgreement;
        RegisterData.brand = 'BMW';
        
        //LAP_REST.user_reg(RegisterData, 'LINE');寫一次就好
        LAP_REST.outputResponse myData = LAP_REST.user_reg(RegisterData, 'WEB'); 
        response = myData.data.tempDesc;
        status = myData.data.status;
        system.debug('Debug==========='+response);
        
        if(status == '1')
        {
            CheckCustomer();
            CheckEntity();
            
            if(myasset.contains('-'))
            {
                myasset = myasset.replaceall('-','');
            }
            
            list<Asset> Assetlist = [
                select id, NumberPlate__c, f_NumberPlate__c
                from asset
                where f_NumberPlate__c =: myasset
                and Entity__c =: loginEntityId
            ];
            
            list<BindingAsset__c> Bindinglist = [
                select id
                from BindingAsset__c
                where Asset__r.f_NumberPlate__c =: myasset
                and IsActive__c = true
            ];
            
            if(Assetlist.size() > 0 && Bindinglist.size() == 0)
            {
                BindingAsset__c tempRecord = new BindingAsset__c();
                tempRecord.BindingDate__c = system.now();
                tempRecord.Asset__c = Assetlist[0].id;
                tempRecord.Entity__c = loginEntityId;
                tempRecord.Asset_UserText__c = myasset;
                tempRecord.IsActive__c = true;
                insert tempRecord;
            } 
            //要改if else 不然會有兩筆 或是加條件
            if(Assetlist.size() == 0 ) 
            {
                BindingAsset__c tempRecord = new BindingAsset__c();
                tempRecord.BindingDate__c = system.now();
                tempRecord.Entity__c = loginEntityId;
                tempRecord.Asset_UserText__c = myasset;
                tempRecord.IsActive__c = False;
                tempRecord.ErrMsg__c = '無相關車牌紀錄';
                insert tempRecord;
            }
            
            if(Bindinglist.size() > 0)
            {
                BindingAsset__c tempRecord = new BindingAsset__c();
                tempRecord.BindingDate__c = system.now();
                tempRecord.Entity__c = loginEntityId;
                tempRecord.Asset_UserText__c = myasset;
                tempRecord.IsActive__c = False;
                tempRecord.ErrMsg__c = '車牌已綁定';
                insert tempRecord;
            }
            
            //因為抓不到SessionID所以要加這段 不然驗證碼那邊GG
            setCookie(loginCustomerId);
            PageReference pageRef = new PageReference('/apex/WebVerify?user='+myPhone);
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineVerify?name='+myPhone);
            //pageRef.setredirect(true);
            return pageRef;
        }
        
        else
        {
            displayPopup = true;
            return null;
        }
    }
    
    // API-2 NotOwner Register
    public PageReference WebNotOwnerRegister()
    {
        system.debug('================WebNotOwnerRegister');
        myPhone = loginCustomer.Mobile__c;
        myLastName = loginCustomer.LastName__c;
        myFirstName = loginCustomer.FirstName__c;
        myGender = loginCustomer.Gender__c;
        myAgreement = loginCustomer.Agreement__c;
        
        LAP_REST.lapData RegisterData = new LAP_REST.lapData();
        RegisterData.name = myLastName + myFirstName;
        RegisterData.LastName = myLastName;
        RegisterData.FirstName = myFirstName;
        RegisterData.Gender = myGender;
        RegisterData.username = myPhone;
        RegisterData.Agreement = myAgreement;
        RegisterData.brand = 'BMW';
        
        //LAP_REST.user_reg(RegisterData, 'LINE');寫一次就好
        LAP_REST.outputResponse myData = LAP_REST.user_reg(RegisterData, 'WEB'); 
        response = myData.data.tempDesc;
        status = myData.data.status;
        system.debug('Debug==========='+response);
        
        if(status == '1')
        {
            CheckCustomer();
            system.debug('myPhone==========='+myPhone);
            CheckEntity();
                        
            //因為抓不到SessionID所以要加這段 不然驗證碼那邊GG
            setCookie(loginCustomerId);
            PageReference pageRef = new PageReference('/apex/WebVerify?user='+myPhone);
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineVerify?name='+myPhone);
            //pageRef.setredirect(true);
            return pageRef;
        }
        
        else
        {
            displayPopup = true;
            return null;
        }
    }
    
    // API-5 User Login
    public PageReference WebLogin()
    {
        //myPhone = loginCustomer.Mobile__c;
        //MyPassword = loginCustomer.MD5Pwd__c;
        
        LAP_REST.lapData LoginData = new LAP_REST.lapData();
		LoginData.username = myPhone;
		LoginData.password = MyPassword;
		LoginData.brand = 'BMW';
        
        //LAP_REST.user_val(LoginData, 'LINE');
        LAP_REST.outputResponse myData = LAP_REST.user_val(LoginData, 'WEB'); 
        response = myData.data.tempDesc;
        status = myData.data.status;
        system.debug('Debug==========='+response);
        system.debug('Debug==========='+status);
        
        if(status == '2')
        {      
            setCookie(loginCustomerId);
            PageReference pageRef = new PageReference('/apex/WebVerify?user='+myPhone);
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineVerify?name='+myPhone);
            //pageRef.setredirect(true); 
            return pageRef;
        }
            if(status == '1')
            {
                list<CustomerUser__c> CustomerList =[
                select id, Mobile__c, Gender__c
                from CustomerUser__c
                where Mobile__c =: myPhone 
                //and Gender__c = null
                ];
            
                    if(CustomerList.size() > 0)
                    {
                       system.debug('Debug====login3');
                        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineMember?name='+myPhone);
                       setCookie(CustomerList[0].id);
                       // return後就不會跑下面 移到新增line user後再跳頁
                       //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineRegistSuccess');
                	   //pageRef.setredirect(true); 
                       //return pageRef; 
                    }
            }
            else
            {
                system.debug('Debug====login1');
                displayPopup = true;
                return null;
            }
        system.debug('Debug====login2');
        CheckCustomer();
        displayPopup = true;
        return null;
    }
    
    // API-3 Mobile Validation
    public PageReference SendMobileCode()
    {
        //網頁才要 因為LIFF已經判斷有登入了就不用 最前面有給myPhone值
        //myPhone= ApexPages.currentPage().getParameters().get('name');
        //myPhone = loginCustomer.Mobile__c;
        LAP_REST.lapData ValidationData = new LAP_REST.lapData();
        ValidationData.username = myPhone;
        ValidationData.brand = 'BMW';
        ValidationData.code = otp1 + otp2 + otp3 + otp4 + otp5 + otp6;
        
        LAP_REST.outputResponse myData = LAP_REST.mobile_val(ValidationData, 'WEB'); 
        response = myData.data.tempDesc;
        status = myData.data.status;
        system.debug('Debug==========='+response+myPhone); 
        
        //新註冊的會員不會有生日 用生日判斷是不是要導去密碼頁
        if(status == '1' && loginCustomer.Birthday__c == null)
        {
            PageReference pageRef = new PageReference('/apex/WebPassword?user='+myPhone);
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LinePassword?name='+myPhone);
            //pageRef.setredirect(true);
            return pageRef;
        }
        if(status == '1' && loginCustomer.Birthday__c != null){
            displayPopup = true;
            return null;
        }
        else
        {
            displayPopup = true;
            return null;
        }
    }
    
    // 回認證頁
    public Pagereference gotoVerify()
    {
        PageReference pageRef = new PageReference('/apex/WebVerify?user='+myPhone);
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineVerify?name='+myPhone);
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // API-4 Resend Mobile Validation
    public void ReSendMobileCode()
    {
        myPhone= ApexPages.currentPage().getParameters().get('user');
        
        LAP_REST.lapData ReSend = new LAP_REST.lapData();
        ReSend.username = myPhone;
        ReSend.brand = 'BMW';
        
        LAP_REST.outputResponse myData = LAP_REST.resend_mobile_val(ReSend, 'WEB');
        response = myData.data.tempDesc;
        system.debug('Debug==========='+response+myPhone);
        
        displayPopup = true;
    }
    
    // 忘記密碼
    public PageReference gotoForgetPassword()
    {
        PageReference pageRef = new PageReference('/apex/WebForgetPassword');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineForgetPassword');
       //pageRef.setredirect(true);
       return pageRef;
    }
    
    // API-6 Forget Password Request
    public PageReference ForgetPassword()
    {            
        myPhone = loginCustomer.Mobile__c;
        
        LAP_REST.lapData PasswordData = new LAP_REST.lapData();
        PasswordData.username = myPhone;
        PasswordData.brand = 'BMW';
        
        LAP_REST.outputResponse myData = LAP_REST.forget_pwd(PasswordData, 'WEB');
        response = myData.data.tempDesc;
        status = myData.data.status;
        system.debug('Debug==========='+response+myPhone); 
        system.debug('DebugStatus==========='+status+myPhone); 
        
        if(status=='1'){
            PageReference pageRef = new PageReference('/apex/WebOneTimePassword');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineOneTimePassword');
        //pageRef.setredirect(true);
        return pageRef;
            
        }
        else
        {
            displayPopup = true;
            return null;
        }
        
        //PageReference pageRef = new PageReference('/apex/WebOneTimePassword');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineOneTimePassword');
        //pageRef.setredirect(true);
        //return pageRef;
        
        //displayPopup = true;
        
        //PageReference pageRef = new PageReference('/apex/LineResetPassword');
        //pageRef.setredirect(true);
        //return pageRef;
    }
    
    public PageReference OneTimePassword()
    {
        
        if(loginCustomerId == null){
            CheckCustomer();
        }

        string encryptedonetimepassword= EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(onetimepassword)));
        
        list<CustomerUser__c> userlist = [
            select id, MD5Pwd__c
            from CustomerUser__c
            where Mobile__c=: myPhone
            and MD5Pwd__c =: encryptedonetimepassword
            and Brand__c= 'BMW'
            ];
        
        if(userlist.size() > 0)
        {
            PageReference pageRef = new PageReference('/apex/WebResetPassword');
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineResetPassword');
            //要傳onetimepassword到下一頁，就不要設定pageRef.setredirect(true);
            //pageRef.setredirect(true);
            return pageRef;
        }
        response = '密碼輸入錯誤';
        return null;

    }
    
    // 回登入頁
    public Pagereference gotoLogin()
    {
        PageReference pageRef = new PageReference('/apex/WebLogin');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineLogin');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    // 回密碼頁
    public Pagereference gotoPassword()
    {
        PageReference pageRef = new PageReference('/apex/WebPassword');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LinePassword');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    // 個資條款
    public Pagereference gotoDisclaimer()
    {
        PageReference pageRef = new PageReference('https://www.bmw.com.tw/zh/footer/metanavigation/legal-disclaimer-pool/legal-disclaimer.html');
        //PageReference pageRef = new PageReference(LineAccount.Disclaimer__c);
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // 售服網站
    public Pagereference gotoService()
    {
        PageReference pageRef = new PageReference('https://marvelapp.com/prototype/f34gg0e/screen/72626294');
        pageRef.setredirect(true);
        return pageRef;
    }
    
    // 愛車資料
    // 因為不要把liff關掉又開, 所以用'/xxx'
    public Pagereference gotoWebAsset()
    {
        myPhone= ApexPages.currentPage().getParameters().get('user');
        PageReference pageRef = new PageReference('/WebAsset?session='+session);
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // 會員資料
    public Pagereference gotoWebModify()
    {
        
        isEdit = false;
        PageReference pageRef = new PageReference('/WebModify?session='+session);
        CheckCustomer();
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // 回註冊頁
    public Pagereference gotoRegister()
    {
        displayPopup = false;
        PageReference pageRef = new PageReference('/apex/WebRegister');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineRegister');
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    public Pagereference gotoWebRegistError()
    {
        PageReference pageRef = new PageReference('/apex/WebRegistError');
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineRegistError');
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // 重設密碼
    public PageReference gotoResetPassword()
    {
       PageReference pageRef = new PageReference('/apex/WebResetPassword');
       //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineResetPassword');
       //pageRef.setredirect(true);
       return pageRef;
    }
    
    // API-7 Reset Password
    public PageReference ResetPassword()
    {            
        myPhone = loginCustomer.Mobile__c;
        //onetimepassword = ApexPages.currentPage().getParameters().get('onetimepassword');
        
        if(loginCustomerId == null){
            CheckCustomer();
        }
        
        LAP_REST.lapData ResetData = new LAP_REST.lapData();
        ResetData.username = myPhone;
        ResetData.oldPwd = onetimepassword;
        ResetData.newPwd = newPwd;
        ResetData.brand = 'BMW';
        
        LAP_REST.outputResponse myData = LAP_REST.reset_pwd(ResetData, 'WEB');
        response = myData.data.tempDesc;
        status = myData.data.status;
        system.debug('Debug==========='+response+myPhone);  
        system.debug('Debug==========='+myData.data.status); 
        
        if(status == '1'){
            //不知道為什麼出不來 先暫時跳售服QQ
            //displayPopup = true;
            PageReference pageRef = new PageReference('https://marvelapp.com/prototype/f34gg0e/screen/72626294');
            pageRef.setredirect(true);
            return pageRef;
        }
        else{
            
            displayPopup = true;
            return null;
        }            
    }
    
    // 註冊設定密碼
    public PageReference SetPassword()
    {
        if(loginCustomerId == null){
            CheckCustomer();
        }
        
        CustomerUser__c tempRecord = [SELECT id FROM CustomerUser__c WHERE id =: loginCustomerId][0];
        string encryptedPassword = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(myPassword)));
        tempRecord.MD5Pwd__c = encryptedPassword;
        update tempRecord;
        
        PageReference pageRef = new PageReference('/apex/WebMember?user='+myPhone);
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineMember?name='+myPhone);
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // 找登入的Entity
    public void CheckEntity()
    {
        //myPhone= ApexPages.currentPage().getParameters().get('user');
        
        list<Entity__c> EntityList = [
            select id, Mobile__c
            from Entity__c
            where (Mobile__c =: myPhone)
            or (Mobile__c =: loginCustomer.Mobile__c)
        ];
        system.debug('Debug==========='+myPhone); 
        if (EntityList.size() > 0)
            loginEntityId = EntityList[0].id;
    }
  
    // 找登入的CustomerUser資料
    public void CheckCustomer()
    {
        //myPhone= ApexPages.currentPage().getParameters().get('user');
        
        list<CustomerUser__c> CustomerList =[
            select id, Name, Entity__c, Email__c, EXID__c, MD5Pwd__c, 
            FirstName__c, Brand__c, Address__c, LastName__c, Gender__c,
            Mobile__c, Validate__c, Birthday__c, Source__c
            from CustomerUser__c
            where Mobile__c =: myPhone       
        ];
        if (CustomerList.size() > 0){
            loginCustomer = CustomerList[0];
            loginCustomerId = CustomerList[0].id;
        }
    }
    
    // 註冊-填寫個人資料
    public pagereference RegistCustomer()
    {
        if(loginEntityId == null){
            CheckEntity();
        }
        
        if(loginCustomerId == null){
            CheckCustomer();
        }
        
        CustomerUser__c tempRecord = [SELECT id FROM CustomerUser__c WHERE id =: loginCustomerId][0]; 
        //tempRecord.LastName__c = loginCustomer.LastName__c; 不知道為什麼這樣寫不進去QAQ
        tempRecord.Address__c = myAddress;
        tempRecord.Birthday__c = myBirthday;
        tempRecord.Email__c = myEmail;
        update tempRecord;
        
        //一人只會註冊一次吧QQ
        list<BindingAsset__c> BindingAssetlist = [
            select id, ErrMsg__c from BindingAsset__c
            where Entity__c =: loginEntityId
            //and ErrMsg__c = null
            order by createddate desc
            limit 1
        ];
        
        list<BindingAsset__c> Nonmemberlist = [
            select id, ErrMsg__c from BindingAsset__c
            where Entity__c =: loginEntityId
            limit 1
        ];
        
        system.debug('EntityId'+loginEntityId);
        //if(BindingAssetlist.size() > 0){
        if(BindingAssetlist.size() > 0 && BindingAssetlist[0].ErrMsg__c == null || BindingAssetlist.size() == 0){
            PageReference pageRef = new PageReference('/apex/WebRegistSuccess');
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineRegistSuccess');
            //pageRef.setredirect(true);
            return pageRef;
        }
        else if(Nonmemberlist.size() == 0)
        {
            PageReference pageRef = new PageReference('/apex/WebAsset');
            //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineAsset');
            //pageRef.setredirect(true);
            return pageRef;  
        }
        else
        {
            //PageReference pageRef = new PageReference('/apex/LineRegistError');
            //pageRef.setredirect(true);
            response = '我們正在處理您的車牌號碼認證作業, 請稍後, 將有服務專人與您聯繫, 感謝您的耐心等候!';
            displayCasePopup = true;
            displayBindingPopup = false;
            return null;
        }  
    }
    
    //新增車牌
    public Pagereference gotoWebBinding()
    {
        PageReference pageRef = new PageReference('/apex/WebBinding?session='+session);
        //PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineBinding');
        //pageRef.setredirect(true);
        return pageRef;
    }
    
    // 車牌綁定
    Public void BindingAsset()
    {
        //myPhone= ApexPages.currentPage().getParameters().get('user');
        CheckEntity();
        if(loginCustomerId == null){
            CheckCustomer();
        }
        
        if(myasset.contains('-'))
            {
                myasset = myasset.replaceall('-','');
            }
        
        list<Asset> Assetlist = [
            select id, NumberPlate__c, f_NumberPlate__c
            from asset
            where f_NumberPlate__c =: myasset
            //and Entity__r.name =: myPhone
            and Entity__c =: loginEntityId
        ];
        
        list<BindingAsset__c> Bindinglist = [
            select id
            from BindingAsset__c
            where Asset__r.f_NumberPlate__c =: myasset
            and IsActive__c = true
        ];
        
        if(Assetlist.size() > 0 && Bindinglist.size() == 0)
        {
            BindingAsset__c tempRecord = new BindingAsset__c();
            tempRecord.BindingDate__c = system.now();
            tempRecord.Asset__c = Assetlist[0].id;
            tempRecord.Entity__c = loginEntityId;
            tempRecord.Asset_UserText__c = myasset;
            tempRecord.IsActive__c = true;
            insert tempRecord;
            response = '綁定成功';
            displayPopup = true;
            displayBindingPopup = false;
        } 
        if(Assetlist.size() == 0 ) 
        {
            BindingAsset__c tempRecord = new BindingAsset__c();
            tempRecord.BindingDate__c = system.now();
            tempRecord.Entity__c = loginEntityId;
            tempRecord.Asset_UserText__c = myasset;
            tempRecord.IsActive__c = False;
            tempRecord.ErrMsg__c = '無相關車牌紀錄';
            insert tempRecord;
            //response = '無相關車牌紀錄，是否建立客服個案';
            response = '我們正在處理您的車牌號碼認證作業, 請稍後, 將有服務專人與您聯繫, 感謝您的耐心等候!';
            displayCasePopup = true;
            displayBindingPopup = false;
        }
        if(Bindinglist.size() > 0)
        {
            BindingAsset__c tempRecord = new BindingAsset__c();
            tempRecord.BindingDate__c = system.now();
            tempRecord.Entity__c = loginEntityId;
            tempRecord.Asset_UserText__c = myasset;
            tempRecord.IsActive__c = False;
            tempRecord.ErrMsg__c = '車牌已綁定';
            insert tempRecord;
            //response = '車牌已綁定，是否建立客服個案';
            response = '我們正在處理您的車牌號碼認證作業, 請稍後, 將有服務專人與您聯繫, 感謝您的耐心等候!';  
            displayCasePopup = true;
            displayBindingPopup = false;
        }
    }
    
    public PageReference CreateCase()
    {
        CheckEntity();
        list<BindingAsset__c> Bindinglist = [
            select id, ErrMsg__c
            from BindingAsset__c
            where Entity__r.id =: loginEntityId
            order by createddate desc
        ];
        
        if (Bindinglist.size() > 0)
        {
            MarketingCase__c MarketingCase = new MarketingCase__c();
            MarketingCase.BindingAsset__c = Bindinglist[0].id;
            MarketingCase.RelativeErrorMsg__c = Bindinglist[0].ErrMsg__c;
            MarketingCase.linecasestatus__c = '新案件';
            MarketingCase.Entity__c = loginEntityId;
            insert MarketingCase;
            displayCasePopup = false;
            
            BindingAsset__c tempRecord = [SELECT id FROM BindingAsset__c WHERE id =: Bindinglist[0].id]; 
            tempRecord.CreateCase__c = true;
            update tempRecord;
            
            //拿掉第二個提示訊息
            //response = '您的車牌資料待驗證，將有專人與您聯繫進行。你也可以撥打0800-291-101聯繫客服';
            displayPopup = false;
            displayCasePopup = false;
            displayBindingPopup = false;
            //displayConfirmPopup = true;
            displayConfirmPopup = false;
            //selectedTab = 'Tab2';
            PageReference pageRef = new PageReference('/apex/WebRegistSuccess');
            //PageReference pageRef = new PageReference('/LineRegistSuccess');
            //pageRef.setredirect(true);
            return pageRef;
        }
        return null;
    }
    
    public void CreateAssetCase()
    {
        CheckEntity();
        list<BindingAsset__c> Bindinglist = [
            select id, ErrMsg__c
            from BindingAsset__c
            where Entity__r.id =: loginEntityId
            order by createddate desc
        ];
        
        if (Bindinglist.size() > 0)
        {
            MarketingCase__c MarketingCase = new MarketingCase__c();
            MarketingCase.BindingAsset__c = Bindinglist[0].id;
            MarketingCase.RelativeErrorMsg__c = Bindinglist[0].ErrMsg__c;
            MarketingCase.linecasestatus__c = '新案件';
            MarketingCase.Entity__c = loginEntityId;
            insert MarketingCase;
            displayCasePopup = false;
            
            BindingAsset__c tempRecord = [SELECT id FROM BindingAsset__c WHERE id =: Bindinglist[0].id]; 
            tempRecord.CreateCase__c = true;
            update tempRecord;
            
            //拿掉第二個提示訊息
            //response = '您的車牌資料待驗證，將有專人與您聯繫進行。你也可以撥打0800-291-101聯繫客服';
            displayPopup = false;
            displayCasePopup = false;
            displayBindingPopup = false;
            //displayConfirmPopup = true;
            displayConfirmPopup = false;
            //selectedTab = 'Tab2';
            //PageReference pageRef = new PageReference('/LineRegistSuccess');
            //pageRef.setredirect(true);
            //return pageRef;
        }
        //return null;
    }
  
    public pagereference gotoInfo()
    {
        //selectedTab = 'Tab2';
        PageReference mainPage = new PageReference('/apex/WebAsset');
        //PageReference mainPage = new PageReference('/'+LineAccount.SiteDomain__c+'/LineAsset');
		mainPage.setRedirect(true);
		return mainPage;
    }
    
    public pagereference gotoSuccess()
    {
        PageReference mainPage = new PageReference('/apex/WebRegistSuccess');
        //PageReference mainPage = new PageReference('/'+LineAccount.SiteDomain__c+'/LineRegistSuccess');
		mainPage.setRedirect(true);
		return mainPage;
    }
    
    public pagereference gotoBinding()
    {
        displayCasePopup = false;
        displayPopup = false;
        PageReference mainPage = new PageReference('/apex/WebAsset');
        //PageReference mainPage = new PageReference('/'+LineAccount.SiteDomain__c+'/LineAsset');
		//mainPage.setRedirect(true);
		return mainPage;
    }
    
    /*
    public void addNewRecord()
    {
        myAsset.add(new tempRecord(new BindingAsset__c()));
    }
*/
    
    // 修改資料
    public void EditMe()
    {
        isEdit = true;
        displayInfoPopUp = false;
    }
    
    // 修改愛車資料
    public void EditAsset()
    {
        isEditAsset = true;
    }
    
    // 關閉新增個案視窗
    public void CloseCaseBtn()
    {
        displayCasePopup = false;
    }
    
    public void CloseAssetBtn()
    {
        displayCasePopup = false;
        displayPopup = false;
    }
    
    //更新修改頁面資料
    public pageReference SaveRegisterMember()
    {
        isEdit = false;
        //selectedTab = 'Tab1';

        CustomerUser__c tempRecord = [SELECT id FROM CustomerUser__c WHERE id =: loginCustomerId][0]; 
        tempRecord.FirstName__c = loginCustomer.FirstName__c;
        tempRecord.LastName__c = loginCustomer.LastName__c;
        tempRecord.Address__c = loginCustomer.Address__c;
        tempRecord.Birthday__c = loginCustomer.Birthday__c;
        tempRecord.Email__c = loginCustomer.Email__c;
        tempRecord.Gender__c = loginCustomer.Gender__c;
        update tempRecord;

		PageReference mainPage = new PageReference('/apex/WebModify');
        //PageReference mainPage = new PageReference('/LineModify');
		//mainPage.setRedirect(true);
		return mainPage;
	}
    
    //車牌綁定紀錄
    private list <BindingAsset__c> mBindingAssetList;
    public list <BindingAsset__c> getBindingAssetList()
    {
        //myPhone= ApexPages.currentPage().getParameters().get('user');
        CheckEntity();
        system.debug('loginEntityId========='+loginEntityId);
        if (mBindingAssetList == null)
        {
           mBindingAssetList = new list <BindingAsset__c>();
            if (loginEntityId != null)
            {
                
                mBindingAssetList = [
                    select id, Asset__r.NumberPlate__c, Asset__r.CarType__c, Asset__r.PurchaseDate, Asset_UserText__c, IsDelete__c
                    from BindingAsset__c
                    //where Entity__c =: loginEntityId
                    where IsDelete__c = false
                    and CreateCase__c = true
                    //and Entity__r.name =: myPhone
                    and Entity__c =: loginEntityId
                    //OR
                    //(IsDelete__c = false
                    //and IsActive__c = true
                    //and Entity__c =: loginEntityId)
                ];
                
                lastindexofBindingAsset = mBindingAssetList.size();
                for (BindingAsset__c BindingAsset: mBindingAssetList)
                {
                    indexofBindingAsset = indexofBindingAsset + 1;
                    BindingAsset_index_map.put(BindingAsset,indexofBindingAsset);
                }
            }
        }
        return mBindingAssetList;
    }
    
    //車牌綁定成功紀錄
    private list <BindingAsset__c> mBindingAssetListSuccess;
    public list <BindingAsset__c> getBindingAssetListSuccess()
    {
        //myPhone= ApexPages.currentPage().getParameters().get('user');
        CheckEntity();
        system.debug(loginEntityId);
        if (mBindingAssetListSuccess == null)
        {
            mBindingAssetListSuccess = new list <BindingAsset__c>();
            if (loginEntityId != null)
            {
                
                mBindingAssetListSuccess = [
                    select id, Asset__r.NumberPlate__c, Asset__r.CarType__c, Asset__r.PurchaseDate, Asset_UserText__c, IsDelete__c
                    from BindingAsset__c
                    //where Entity__c =: loginEntityId
                    where IsActive__c = true
                    and IsDelete__c = false
                    //and Entity__r.name =: myPhone
                    and Entity__c =: loginEntityId
                ];
            }
        }
        return mBindingAssetListSuccess;
    }
    
    //選擇移除原因
    public void ChooseDeleteReason()
    {
        displayReasonPopup = true;
    }
    
    //移除綁定車輛
    public pageReference deleteBindingAsset()
    {
        isEditAsset = false;
        //selectedTab = 'Tab2';
        system.debug(deleteBindingId);
        BindingAsset__c tempRecord = [SELECT id FROM BindingAsset__c WHERE id =: deleteBindingId]; 
        tempRecord.IsDelete__c = true;
        tempRecord.IsActive__c = false;
        tempRecord.DeleteReason__c = reason;
        tempRecord.ReasonText__c = reasonText;
        update tempRecord;
        
        PageReference mainPage = new PageReference('/apex/WebAsset?session='+session);
        //PageReference mainPage = new PageReference('/'+LineAccount.SiteDomain__c+'/LineAsset');
		mainPage.setRedirect(true);
		return mainPage;
    }
    
    //跳出綁定視窗
    public void BindingPopup()
    {
        displayBindingPopup = true;
    }

    public void setCookie(String raw_data) {
        //Integer maxAge = 60*60*24;
		Integer maxAge = -1;
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        Blob key = Blob.valueOf(webBase.rawSalt);
        Blob data = Blob.valueOf(raw_data+hexDigest);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
        string encodeData = EncodingUtil.base64Encode(encryptedData);
	    Cookie sessionID = new Cookie('sessionID', encodeData, null, maxAge, false);
		ApexPages.currentPage().setCookies(new Cookie[]{sessionID});
    }

	public static void StaticSetCookie(String raw_data) {
        //Integer maxAge = 60*60*24;
		Integer maxAge = -1;
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        Blob key = Blob.valueOf(webBase.rawSalt);
        Blob data = Blob.valueOf(raw_data+hexDigest);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
        string encodeData = EncodingUtil.base64Encode(encryptedData);
	    Cookie sessionID = new Cookie('sessionID', encodeData, null, maxAge, false);
		ApexPages.currentPage().setCookies(new Cookie[]{sessionID});
    }
    
    
    //性別
    
    private list<SelectOption> mGenderList;
    public list<SelectOption> getGenderList()
    {
    	if(mGenderList == null)
    	{
    		mGenderList = new list<SelectOption>();
    		//空值。
    		mGenderList.add(new SelectOption('', '請選擇'));
    		Schema.DescribeFieldResult fieldResult = CustomerUser__c.Gender__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple)
			{
				mGenderList.add(new SelectOption(f.getValue(), f.getLabel()));
			}  
    	}
    	return mGenderList;
    }
    
    //移除清單
    public List<SelectOption> getReasonList(){
        Schema.sObjectType sobject_type = BindingAsset__c.getSObjectType();    
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();  
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('DeleteReason__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }

    @RemoteAction 
    global static string checkLinkLine(string inputLineID)
    {
        if (inputLineID == null) return 'NO_LOGIN';  
        else{
            list<CustomerUser__c> CustomerList =[
            select id, Name, Entity__c, Email__c, EXID__c, MD5Pwd__c, 
            FirstName__c, Brand__c, Address__c, LastName__c, //Title__c,
            Mobile__c, Validate__c, Birthday__c, Source__c
            from CustomerUser__c
            WHERE Id in
            (
            	SELECT CustomerUser__c FROM Line_User__c 
             	WHERE UDID__c =: inputLineID 
				and Line_Account__r.SFDCSiteId__c =:Line_webBase.mySiteID
            )
		];
            
        if(CustomerList.size() > 0 )
        {
            CALoginLog__c newLog = new CALoginLog__c();
            newLog.Session__c = LAP_REST.generateRandom(32);
            newLog.SessionExpireTime__c = system.now().addHours(8);
            newLog.SourceIP__c = 'LineLogin';
            newLog.LoginStatus__c = '成功';
            newLog.Type__c = '登入';
            newLog.CustomerUser__c = CustomerList[0].id;
            newLog.UserName__c = CustomerList[0].name;
            insert newLog;
        	//設定cookies
        	Integer maxAge = 60*60*24;
		    String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
		    Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
		    String hexDigest = EncodingUtil.convertToHex(hash);
		    Blob key = Blob.valueOf(rawSalt);
		    Blob data = Blob.valueOf(newLog.Session__c+hexDigest);
		    Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
		    string encodeData = EncodingUtil.base64Encode(encryptedData);
        	return encodeData;
            } else return 'NO_CustomerUser'; 
	   }
    }
}