({
	getAccount : function(component, event) {
        var myAction = component.get("c.getAccount");
        var myACCId = component.get('v.myAccountId');
        
        if(myACCId === "" || myACCId === undefined )
        {
            component.set('v.SelectedAccount.Id', '');
            
            component.set('v.SelectedAccount.LastName', '');
            component.find("LastName").set("v.value", "");
            component.set('v.SelectedAccount.FirstName', '');
            component.find("FirstName").set("v.value", "");
            component.set('v.SelectedAccount.PersonalID__c', '');
            component.find("PersonalID").set("v.value", "");
            component.set('v.SelectedAccount.Gender__pc', '');
            component.find("Gender").set("v.value", "");
            component.set('v.SelectedAccount.ContactMethod__c', '');
            component.find("MainContact").set("v.value", "");
            component.set('v.SelectedAccount.MainContactNumber__c', '');
            component.find("MainPhone").set("v.value", "");
            component.set('v.SelectedAccount.Phone', '');
            component.find("Phone").set("v.value", "");
            component.set('v.SelectedAccount.CompanyPhone__c', '');
            component.find("CompanyPhone").set("v.value", "");
            component.set('v.SelectedAccount.PersonMobilePhone', '');
            component.find("PersonMobilePhone").set("v.value", "");
            component.set('v.SelectedAccount.PersonBirthdate', '');
            component.find("PersonBirthdate").set("v.value", "");
            component.set('v.SelectedAccount.NoEmail__c', false);
            component.find("NoEmail").set("v.value", false);
            component.set('v.SelectedAccount.PersonEmail', '');
            component.find("PersonEmail").set("v.value", "");
            component.set('v.SelectedAccount.MainAddress__c', '');
            component.find("MainAddress").set("v.value", "");
            component.set('v.SelectedAccount.HomeStreet__c', '');
            component.find("HomeStreet").set("v.value", "");
            component.set('v.SelectedAccount.CompanyStreet__c', '');
            component.find("CompanyStreet").set("v.value", "");
            /*Opp資訊不該被清掉
            component.set('v.selectedOpportunity.Estimateddateofnew__c', '');
            component.find("ChageCarDate").set("v.value", "");
            component.set('v.selectedOpportunity.DeliveryDate__c', '');
            component.find("DeliveryDate").set("v.value", "");*/
            
            component.set('v.isHomeCityNull', false);
            component.set('v.isHomeDistrictNull', false);
            component.set('v.isCompanyCityNull', false);
            component.set('v.isCompanyDistrictNull', false);
            
            //要加這一段才可以。
            var evt = $A.get("e.c:PassClearMe");
            evt.fire();
        }
        else
        {
            //傳入event id。
            myAction.setParams({
                AccountId : component.get('v.myAccountId')
            });
            
            myAction.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var returnACC = response.getReturnValue();
                    component.set('v.SelectedAccount', returnACC);
                    component.set('v.SelectedAccount1', returnACC);
                    component.set('v.SelectedAccount2', returnACC);
                    component.set('v.isChoosed', true);
                    
                    //要加這一段才可以。
                    var evt = $A.get("e.c:PassAccount");
                    evt.setParams({"PassAccount" : component.get('v.SelectedAccount.Id')});
                    evt.fire();
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(myAction);
        }
	},
    
    getOpportunity : function(component, event) {
        var myAction = component.get("c.getOpportunity");
        
        //傳入event id。
        myAction.setParams({
			OPPId : event.getParam("PassOpportunity")
        });
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var returnOPP = response.getReturnValue();
                component.find("myACC").set("v.value",returnOPP.Driver__c);
                component.set('v.selectedOpportunity', returnOPP);
                component.set('v.isChoosed', true);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(myAction);
	},
    
    saveTheWorld : function(component, event) {
        var isErrorOccur = false;
        var myACCC = component.get('v.SelectedAccount');
        var myACCC1 = component.get('v.SelectedAccount1');
        var myACCC2 = component.get('v.SelectedAccount2');
        var myOPPP = component.get('v.selectedOpportunity');
        var myMessage = "";
        if(myACCC.LastName === "" || myACCC.LastName === undefined)
        {
            myMessage += "請輸入姓氏。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('LastName');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        /*
        if(myACCC.FirstName === "" || myACCC.FirstName === undefined)
        {
            myMessage += "請輸入名字。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('FirstName');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        */
        if(myACCC.PersonalID__c === "" || myACCC.PersonalID__c === undefined)
        {
            myMessage += "請輸入身份證號碼/統一編號。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('PersonalID');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        /* 因為有歪國人，所以不卡，先註解掉。20180608。
        else if(myACCC.PersonalID__c.length === 8 || myACCC.PersonalID__c.length === 10)
        {
            if(myACCC.PersonalID__c.length === 8)
            {
                if(isNaN(myACCC.PersonalID__c ))
                {
                    myMessage += "身份證號碼/統一編號 格式不符<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('PersonalID');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
            }
            else if(myACCC.PersonalID__c.length === 10)
            {
				var tab = "ABCDEFGHJKLMNPQRSTUVXYWZIO"                     
                var A1 = new Array (1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3 );
                var A2 = new Array (0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5 );
                var Mx = new Array (9,8,7,6,5,4,3,2,1,1);
                
                var i = tab.indexOf( myACCC.PersonalID__c.charAt(0) );
                if ( i == -1 ){
                    myMessage += "身份證號碼/統一編號 格式不符，第一碼須為大寫字母<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('PersonalID');
                    $A.util.addClass(cmpTarget, 'redLine');
                }
                ///* 身份證驗證
                var rightNumber = myACCC.PersonalID__c.substring(1,10);
                if(isNaN(rightNumber))
                {
                    myMessage += "身份證號碼/統一編號 格式不符，後九碼須為數字<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('PersonalID');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
                
                /* 身份證驗證
                var sum = A1[i] + A2[i]*9;
                
                for (var i=1; i<10; i++ ) {
                    var v = parseInt( myACCC.PersonalID__c.charAt(i) );
                    if ( isNaN(v) )
                    {
                        myMessage += "身份證號碼/統一編號 格式不符，後九碼須為數字<br/>";
            			isErrorOccur = true;
                    }
                    sum = sum + v * Mx[i];
                }
                if ( sum % 10 != 0 )
                {
                    myMessage += "身份證號碼/統一編號 格式不符，檢查碼錯誤<br/>";
            		isErrorOccur = true;
                }
                */
        /* 因為有歪國人，所以不卡，先註解掉。20180608。
            }
        } 
		else
        {
            myMessage += "身份證號碼/統一編號字數不符。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('PersonalID');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        因為有歪國人，所以不卡，先註解掉。20180608。 */
        if(myACCC.Gender__pc === "" || myACCC.Gender__pc === undefined)
        {
            myMessage += "請輸入性別。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('Gender');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        if(myACCC.PersonBirthdate === "" || myACCC.PersonBirthdate === undefined)
        {
            myMessage += "請輸入生日。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('PersonBirthdate');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        if(myACCC.ContactMethod__c === "" || myACCC.ContactMethod__c === undefined)
        {
            myMessage += "請選擇主要聯繫方式。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('MainContact');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        //電子郵件為必填。
        //修改為新增一個checkbox 確認。20190619
        else
        {
            //電子郵件為必填。
            if(myACCC.ContactMethod__c === "電子郵件")
            {
                if(myACCC.PersonEmail === "" || myACCC.PersonEmail === undefined)
                {
                    
                    if(myACCC.NoEmail__c === false)
                    {
                        myMessage += "請輸入電子郵件。<br/>";
                        isErrorOccur = true;
                        var cmpTarget = component.find('PersonEmail');
                        $A.util.addClass(cmpTarget, 'redLine');
                    }
                	else
                    {
                    }
                }
                else
                {
                    var re = /^(?:[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$/;
  					if(re.test( String(myACCC.PersonEmail).toLowerCase() ))
                    {
                    }
                    else
                    {
                        myMessage += "電子郵件格式錯誤。<br/>";
                        isErrorOccur = true;
                        var cmpTarget = component.find('PersonEmail');
                        $A.util.addClass(cmpTarget, 'redLine');
                    }
                }
            }
        }
        if(myACCC.MainContactNumber__c === "" || myACCC.MainContactNumber__c === undefined)
        {
            myMessage += "請選擇主要聯繫電話。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('MainPhone');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        else 
        {
            if(myACCC.MainContactNumber__c ==="行動電話")
            {
                if(myACCC.PersonMobilePhone ==="" || myACCC.PersonMobilePhone === undefined)
                {
                    myMessage += "請輸入行動電話。<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('PersonMobilePhone');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
            }
            if(myACCC.MainContactNumber__c ==="公司電話")
            {
                if(myACCC.CompanyPhone__c ==="" || myACCC.CompanyPhone__c === undefined)
                {
                    myMessage += "請輸入公司電話。<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('CompanyPhone');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
            }
            if(myACCC.MainContactNumber__c ==="住宅電話")
            {
                if(myACCC.Phone ==="" || myACCC.Phone === undefined)
                {
                    myMessage += "請輸入住宅電話。<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('Phone');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
            }
        }
        if(myACCC.MainAddress__c === "" || myACCC.MainAddress__c === undefined)
        {
            myMessage += "請選擇主要聯繫地址。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('MainAddress');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        else
        {
			if(myACCC.MainAddress__c === "住家")
            {
				if(myACCC1.HomeCity__c === "" || myACCC1.HomeCity__c === undefined)
                {
                    myMessage += "請選擇住家城市。<br/>";
            		isErrorOccur = true;
                    component.set('v.isHomeCityNull', true);
                }
                if(myACCC1.HomeDistrict__c === "" || myACCC1.HomeDistrict__c === undefined)
                {
                    myMessage += "請選擇住家鄉鎮市區。<br/>";
            		isErrorOccur = true;
                    component.set('v.isHomeDistrictNull', true);
                }
                if(myACCC.HomeStreet__c === "" || myACCC.HomeStreet__c === undefined)
                {
                    myMessage += "請輸入住家街道。<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('HomeStreet');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
            }
            if(myACCC.MainAddress__c === "公司")
            {
				if(myACCC2.CompanyCity__c === "" || myACCC2.CompanyCity__c === undefined)
                {
                    myMessage += "請選擇公司城市。<br/>";
            		isErrorOccur = true;
                    component.set('v.isCompanyCityNull', true);
                }
                if(myACCC2.CompanyDistrict__c === "" || myACCC2.CompanyDistrict__c === undefined)
                {
                    myMessage += "請選擇公司鄉鎮市區。<br/>";
            		isErrorOccur = true;
                    component.set('v.isCompanyDistrictNull', true);
                }
                if(myACCC.CompanyStreet__c === "" || myACCC.CompanyStreet__c === undefined)
                {
                    myMessage += "請輸入公司街道。<br/>";
            		isErrorOccur = true;
                    var cmpTarget = component.find('CompanyStreet');
    				$A.util.addClass(cmpTarget, 'redLine');
                }
            }
        }
        if(myOPPP.Estimateddateofnew__c === "" || myOPPP.Estimateddateofnew__c === undefined)
        {
            myMessage += "請輸入預計換車日。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('ChageCarDate');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
            
        if(myOPPP.DeliveryDate__c === "" || myOPPP.DeliveryDate__c === undefined)
        {
            myMessage += "請輸入交車日期。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('DeliveryDate');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        
        if(isErrorOccur)
        {
            component.set('v.errorMessage', myMessage);
        }
        else
        {
            component.set('v.errorMessage', "");
            var myAction = component.get("c.saveTheWorld");
            //傳入值。
            myAction.setParams({
                OpportunityId : component.get('v.selectedOpportunity.Id'),
                changeCarDate : component.get('v.selectedOpportunity.Estimateddateofnew__c'),
                DeliveryDate : component.get('v.selectedOpportunity.DeliveryDate__c'),
                AccountId : component.get('v.SelectedAccount.Id'),
                LastName : component.get('v.SelectedAccount.LastName'),
                FirstName : component.get('v.SelectedAccount.FirstName'),
                PersonalID : component.get('v.SelectedAccount.PersonalID__c'),
                Gender : component.get('v.SelectedAccount.Gender__pc'),
                MainContact : component.get('v.SelectedAccount.ContactMethod__c'),
                MainNumber : component.get('v.SelectedAccount.MainContactNumber__c'),
                phone : component.get('v.SelectedAccount.Phone'),
                CompanyPhone : component.get('v.SelectedAccount.CompanyPhone__c'),
                PersonMobilePhone : component.get('v.SelectedAccount.PersonMobilePhone'),
                Fax : component.get('v.SelectedAccount.Fax'),
                PersonBirthdate : component.get('v.SelectedAccount.PersonBirthdate'),
                NoEmail : component.get('v.SelectedAccount.NoEmail__c'),
                PersonEmail : component.get('v.SelectedAccount.PersonEmail'),
                MainAddress : component.get('v.SelectedAccount.MainAddress__c'),
                HomeCity : component.get('v.SelectedAccount1.HomeCity__c'),
                HomeDistrict : component.get('v.SelectedAccount1.HomeDistrict__c'),
                HomeStreet : component.get('v.SelectedAccount.HomeStreet__c'),
                CompanyCity : component.get('v.SelectedAccount2.CompanyCity__c'),
                CompanyDistrict : component.get('v.SelectedAccount2.CompanyDistrict__c'),
                CompanyStreet : component.get('v.SelectedAccount.CompanyStreet__c')
            });
            myAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnACC = response.getReturnValue();
                    component.set('v.isSaved', returnACC);
                    var evt = $A.get("e.c:PassMyOPP");
                    evt.setParams({"PassOpportunity" : component.get('v.selectedOpportunity.Id')});
                    evt.fire();
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            alert(errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(myAction);
        }
    },
    
    clearRedLine : function(component, event) {
        var cmpTargetLastName = component.find('LastName');
    	$A.util.removeClass(cmpTargetLastName, 'redLine');
        /*
        var cmpTargetFirstName = component.find('FirstName');
    	$A.util.removeClass(cmpTargetFirstName, 'redLine');
        */
        var cmpTargetPersonalID = component.find('PersonalID');
    	$A.util.removeClass(cmpTargetPersonalID, 'redLine');
        var cmpTargetGender = component.find('Gender');
    	$A.util.removeClass(cmpTargetGender, 'redLine');
        var cmpTargetPersonBirthdate = component.find('PersonBirthdate');
    	$A.util.removeClass(cmpTargetPersonBirthdate, 'redLine');
        var cmpTargetMainContact = component.find('MainContact');
    	$A.util.removeClass(cmpTargetMainContact, 'redLine');
        var cmpTargetPersonEmail = component.find('PersonEmail');
    	$A.util.removeClass(cmpTargetPersonEmail, 'redLine');
        var cmpTargetMainPhone = component.find('MainPhone');
    	$A.util.removeClass(cmpTargetMainPhone, 'redLine');
        var cmpTargetPersonMobilePhone = component.find('PersonMobilePhone');
    	$A.util.removeClass(cmpTargetPersonMobilePhone, 'redLine');
        var cmpTargetCompanyPhone = component.find('CompanyPhone');
    	$A.util.removeClass(cmpTargetCompanyPhone, 'redLine');
        var cmpTargetPhone = component.find('Phone');
    	$A.util.removeClass(cmpTargetPhone, 'redLine');
        var cmpTargetMainAddress = component.find('MainAddress');
    	$A.util.removeClass(cmpTargetMainAddress, 'redLine');
        var cmpTargetMainAddress = component.find('MainAddress');
    	$A.util.removeClass(cmpTargetMainAddress, 'redLine');
        var cmpTargetHomeStreet = component.find('HomeStreet');
    	$A.util.removeClass(cmpTargetHomeStreet, 'redLine');
        var cmpTargetCompanyStreet = component.find('CompanyStreet');
    	$A.util.removeClass(cmpTargetCompanyStreet, 'redLine');
        var cmpTargetChageCarDate = component.find('ChageCarDate');
    	$A.util.removeClass(cmpTargetChageCarDate, 'redLine');
        var cmpDeliveryDate = component.find('DeliveryDate');
    	$A.util.removeClass(cmpDeliveryDate, 'redLine');
        
        component.set('v.isHomeCityNull', false);
        component.set('v.isHomeDistrictNull', false);
        component.set('v.isCompanyCityNull', false);
        component.set('v.isCompanyDistrictNull', false);
    },
})