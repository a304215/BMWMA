Global without sharing virtual class Line_actWebBase {
    
    public static string mySiteID = site.getSiteId();
    public static string rawSalt = '00000000000000000000000000000000';
    public Line_Account__c LineAccount {get; set;}
    public string userLineID {get; set;}
    public string CampaignNo {get; set;}
    public string VerifyCode {get; set;}
    //偷加，不然一直error。
    public CampaignStaff__c loginStaff {get; set;}
    public string loginStaffId {get; set;}
    public boolean displayPopUp {get; set;}
    public boolean isLogin {get; set;}
    public string Response {get; set;}
    public string CampaignID {get; set;}
    public string MemberID {get; set;}
    Date myDate = system.today();
    //偷加，不然一直error。
    
    //LIFF V2
	public string urlvalue {get; set;}
	public string LIFFID {get; set;}
    
    public Line_actWebBase(){
        
        for(Line_Account__c loopAccount:[
            select id, name, SiteDomain__c, Link_LineCampaignStaff__c, Link_LineCampaignMember__c, Link_LineCampaignStaffIsLogin__c
            from Line_Account__c
            where SFDCSiteId__c =:Line_actWebBase.mySiteID
        ])
        {
			LineAccount = loopAccount;
		}
        
        displayPopUp = false;
        CampaignID = '';
        MemberID = '';
        
        //LIFF v2
        urlvalue = ApexPages.currentPage().getUrl();
        system.debug(urlvalue);
        if(urlvalue.contains('LineCampaignStaff'))
        {
            LIFFID = LineAccount.Link_LineCampaignStaff__c.replaceall('https://liff.line.me/','');
            system.debug(LIFFID);
        }
        else if(urlvalue.contains('LineCampaignMember'))
        {
            LIFFID = LineAccount.Link_LineCampaignMember__c.replaceall('https://liff.line.me/','');
            system.debug(LIFFID);
            //checkMember();
        }
        else if(urlvalue.contains('LineCampaignIsLogin'))
        {
            LIFFID = LineAccount.Link_LineCampaignStaffIsLogin__c.replaceall('https://liff.line.me/','');
            system.debug(LIFFID);
            //checkMember();
        }
        checkIsLogin();
    }
    
    // Cookie Class
    public void checkIsLogin()
    {
        isLogin = false;
        system.debug('check1');
        
        Cookie ACTsessionID = ApexPages.currentPage().getCookies().get('ACTsessionID');
        system.debug(ACTsessionID);
		if (ACTsessionID != null)
        {
            String encodedValue = ACTsessionID.getValue().replaceAll(' ', '+');
            Blob decodedValue = EncodingUtil.base64Decode(encodedValue);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', Blob.valueOf(Line_actWebBase.rawSalt), decodedValue);
            String finalSessionId = decryptedData.toString().subString(0,18);
            system.debug('check2');
            
            list<CampaignStaff__c> CampaignStaffList =[
            select id
            from CampaignStaff__c
            where id =: finalSessionId
            and Disable__c = false
                /*
            and id in
            (
                select CustomerUser__c
                from Line_User__c
                where Line_Account__c =: LineAccount.id
            )
*/
            ];
            system.debug('check3');
            
            if (CampaignStaffList.size() > 0){
                loginStaff = CampaignStaffList[0];
                loginStaffId = CampaignStaffList[0].id;
                isLogin = true;
                system.debug('check4');
            }
            else
            {
                Cookie ACTsessionID1 = new Cookie('ACTsessionID', '', null, 0, false);
				ApexPages.currentPage().setCookies(new Cookie[]{ACTsessionID1});
            } 
        }
    }
    
    public void enterVerifyCode(){
        
        List<CampaignStaff__c> UpdateStaffList = new List<CampaignStaff__c>();
        List<CampaignStaff__c> RegisteredStaffList = new List<CampaignStaff__c>();
        
        UpdateStaffList = [
            Select id, LINE_UDID__c, Campaign__r.StartDate, Campaign__r.EndDate, Registered__c
            from CampaignStaff__c
            where CampaignNo__c =: CampaignNo
            and VerifyCode__c =: VerifyCode
            //and LINE_UDID__c =: userLineID   
        ];
        
        //同一個人在這活動已經報到過了
        RegisteredStaffList = [
            Select id, LINE_UDID__c, Campaign__r.StartDate, Campaign__r.EndDate, Registered__c
            from CampaignStaff__c
            where CampaignNo__c =: CampaignNo
            //and VerifyCode__c =: VerifyCode
            and LINE_UDID__c =: LineAccount.Id+'_'+userLineID   
        ];
        
        if(RegisteredStaffList.size() > 0)
        {
            Response = '您已報到過';
            displayPopUp = true;
        }
        else
        {
            if(UpdateStaffList.size() > 0 )
            {
                if(UpdateStaffList[0].Registered__c == false)
                {
                    if(system.now() <= UpdateStaffList[0].Campaign__r.EndDate && system.now() >= UpdateStaffList[0].Campaign__r.StartDate)
                    {
                        for(CampaignStaff__c CampaignStaff : UpdateStaffList )
                        {
                            CampaignStaff.LINE_UDID__c = LineAccount.Id+'_'+userLineID;
                            CampaignStaff.Registered__c = true;
                            CampaignStaff.RegisterTime__c = system.now();
                            update UpdateStaffList;
                            Response = '報到成功';
                            displayPopUp = true;
                            loginStaffId = UpdateStaffList[0].id;
                            setCookie(loginStaffId);
                        }    
                    }
                    else
                    {
                        if(system.now() >= UpdateStaffList[0].Campaign__r.EndDate || system.now() <= UpdateStaffList[0].Campaign__r.StartDate)
                        {
                            Response = '請在活動期間輸入活動代碼與認證碼';
                            displayPopUp = true;
                        }
                    }
                }
                else
                {
                    Response = '此驗證碼已被使用';
                    displayPopUp = true; 
                }     
            }
            else
            {
                Response = '請輸入正確活動代碼與驗證碼';
                displayPopUp = true; 
            }        
        }   
    }
    
    //行銷活動成員
    private list <CampaignMember> mCampaignMember;
    public list <CampaignMember> getCampaignMember()
    {
        MemberID = ApexPages.currentPage().getParameters().get('id');
        CampaignID = ApexPages.currentPage().getParameters().get('CID');
        
        if (mCampaignMember == null)
        {            
            mCampaignMember = new list<CampaignMember>();
            mCampaignMember = [
                select id, camp_member_name__c, Campaign.Name, LastName, FirstName
                from CampaignMember
                where id =: MemberID
                //and CampaignId__r.CampaignNo__c =: CampaignID
            ];
        }
        return mCampaignMember;
    }
    
    
    public void checkMember(){ 
        
        List<CampaignMember> CampaignMemberList = new List<CampaignMember>();
        List<CampaignStaff__c> CampaignStaffList = new List<CampaignStaff__c>();
        
        system.debug('=========='+LineAccount.Id);
        system.debug('=========='+userLineID);
        
        CampaignStaffList = [
            select id, Campaign__r.StartDate, Campaign__r.EndDate, Registered__c
            from CampaignStaff__c
            where LINE_UDID__c =: LineAccount.Id+'_'+userLineID 
            and CampaignNo__c =: CampaignID
            and Registered__c = true
            and Campaign__r.StartDate <=: myDate
            and Campaign__r.EndDate >=: myDate
            order by RegisterTime__c desc limit 1
        ];
        
        CampaignMemberList = [
            select id, Registered__c, Campaign.EndDate, Campaign.StartDate
            from CampaignMember
            where id =: MemberID
        ];
        
        if(CampaignStaffList.size() > 0 )
        {
            if(CampaignMemberList[0].Registered__c == false)
            {
                if(system.now() <= CampaignMemberList[0].Campaign.EndDate && system.now() >= CampaignMemberList[0].Campaign.StartDate)
                {
                    for(CampaignMember CampaignMember : CampaignMemberList )
                    {
                        CampaignMember.CampaignStaff__c = CampaignStaffList[0].id;
                        CampaignMember.Registered__c = true;
                        CampaignMember.RegisterTime__c = system.now();
                        update CampaignMember;
                        Response = '報到成功';
                        displayPopUp = true;
                    }  
                }
                else
                {
                    if(system.now() >= CampaignMemberList[0].Campaign.EndDate || system.now() <= CampaignMemberList[0].Campaign.StartDate)
                    {
                        Response = '目前非報到時間';
                        displayPopUp = true;
                    }
                }
            }
            else
            {
                Response = '已報到過';
                displayPopUp = true;
            }   
        }
        else
        {
            Response = '您尚未進行工作人員報到';
            displayPopUp = true;
        }     
    }
    
    //行銷活動工作人員
    private list <CampaignStaff__c> mCampaignStaffLogin;
    public list <CampaignStaff__c> getCampaignStaffLogin()
    {
        if (mCampaignStaffLogin == null){
            if(loginStaffId != null)
        {
            mCampaignStaffLogin = new list <CampaignStaff__c>();  
                mCampaignStaffLogin = [
                    Select id, LINE_UDID__c, Campaign__r.StartDate, Campaign__r.EndDate, Registered__c, Campaign__r.name
                    from CampaignStaff__c
                    where Registered__c = true
                    and id =: loginStaffId
                    and Campaign__r.StartDate <=: myDate
                    and Campaign__r.EndDate >=: myDate
                    order by RegisterTime__c desc
                    limit 1
                ];
          }
        }
        return mCampaignStaffLogin;
    }
           
    // 回報到頁&登出
    public Pagereference gotoRegist()
    {
        isLogin = false;
        List<CampaignStaff__c> DisableCampaignStaff = new List<CampaignStaff__c>();
        
        DisableCampaignStaff = [
            Select id, LINE_UDID__c, Campaign__r.StartDate, Campaign__r.EndDate, Registered__c, Campaign__r.name
            from CampaignStaff__c
            where Registered__c = true
            and id =: loginStaffId
        ];
        
        if(DisableCampaignStaff.size() > 0){
            for(CampaignStaff__c loopDisableCampaignStaff : DisableCampaignStaff)
            {
                loopDisableCampaignStaff.Disable__c = true;
                update loopDisableCampaignStaff;
            } 
        }
        
        PageReference pageRef = new PageReference('/'+LineAccount.SiteDomain__c+'/LineCampaignStaff');
        pageRef.setredirect(true);
        return pageRef;
    }

    public void setCookie(String raw_data) {
        //Integer maxAge = 60*60*24;
		Integer maxAge = -1;
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        Blob key = Blob.valueOf(Line_ActwebBase.rawSalt);
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
        Blob key = Blob.valueOf(Line_ActwebBase.rawSalt);
        Blob data = Blob.valueOf(raw_data+hexDigest);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
        string encodeData = EncodingUtil.base64Encode(encryptedData);
	    Cookie sessionID = new Cookie('sessionID', encodeData, null, maxAge, false);
		ApexPages.currentPage().setCookies(new Cookie[]{sessionID});
    }
    
    @RemoteAction 
    global static string checkLinkLine(string inputLineID)
    {
        Date myDate = system.today();
        if (inputLineID == null) return 'NO_LOGIN';  
        else{
            list<CampaignStaff__c> CampaignStaffList =[
            select id
            from CampaignStaff__c
            WHERE LINE_UDID__c =: 'a131s000000IpaFAAS_'+inputLineID
            and Disable__c = false
		];

        if(CampaignStaffList.size() > 0)
        {
        	//設定cookies
        	Integer maxAge = 60*60*24;
		    String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
		    Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
		    String hexDigest = EncodingUtil.convertToHex(hash);
		    Blob key = Blob.valueOf(rawSalt);
		    Blob data = Blob.valueOf(CampaignStaffList[0].id+hexDigest);
		    Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
		    string encodeData = EncodingUtil.base64Encode(encryptedData);
        	return encodeData;
            } else return 'NO_CustomerUser';
	   }
    }

}